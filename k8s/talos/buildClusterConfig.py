import jsonpatch
import re
import subprocess
import sys
import typer
import yaml

from pathlib import Path
from loguru import logger

app = typer.Typer(add_completion=False)


def _setup_logging(debug):
    """
    Setup the log formatter for this script
    """

    log_level = "INFO"
    if debug:
        log_level = "DEBUG"

    logger.remove()
    logger.add(
        sys.stdout,
        colorize=True,
        format="<level>{message}</level>",
        level=log_level,
    )


def process_node(hostname: str, domain: str, template: str, config_patches: list) -> dict:
    logger.info(f"Processing node {hostname}")

    with template.open('r') as fp:
        node_template = yaml.safe_load(fp)

    node_configpatches = [
        {'op': 'add', 'path': '/machine/network/hostname', 'value': f"{hostname}.{domain}"}
    ]

    if config_patches:
        node_configpatches = node_configpatches + config_patches
    node_configpatches = jsonpatch.JsonPatch(node_configpatches)

    result = node_configpatches.apply(node_template)

    return result


def _load_variables_from_file(path: Path) -> dict:
    file_parts = path.name.split('.')
    if file_parts[-2] == 'sops':
        logger.info("Detected encrypted variables file, trying to decrypt.")
        sops_result = subprocess.run(
            [
                "sops", "-d", str(path)
            ],
            capture_output=True,
            encoding="utf8"
        )
        if sops_result.returncode != 0:
            logger.error("Could not decrypt variables file.")

        data = sops_result.stdout
    else:
        with open(path, 'r') as fh:
            data = fh.readlines()

    output = yaml.safe_load(data)
    return(output)


def parse_variables(input: dict, variable_pattern: str, variables: dict) -> dict:
    if isinstance(input, dict):
        return {k: parse_variables(v, variable_pattern, variables) for k, v in input.items()}
    elif isinstance(input, list):
        return [parse_variables(v, variable_pattern, variables) for v in input]
    elif isinstance(input, str):
        return re.sub(variable_pattern, lambda line: _replace_variable(line, variables), input)

    return input


def _replace_variable(variable: re.Match, variables: dict) -> str:
    from functools import reduce
    variable_path = variable.groups()[0]
    try:
        env_var_value = reduce(
            lambda a, b: a[b], variable_path.split("."), variables
        )
    except KeyError:
        env_var_value = ""
    return env_var_value


@app.command()
def main(
    cluster_config_file: Path = typer.Argument(
        ..., help="The YAML file containing the cluster configuration."),
    output_folder: Path = typer.Option(
        None, help="Folder where the output should be written."),
    variables_file: Path = typer.Option(
        None, help="File containing variables to load."),
    debug: bool = False,
):
    _setup_logging(debug)

    if not cluster_config_file.is_file():
        logger.error(f"Could not find file {str(cluster_config_file)}")
        raise typer.Exit()

    base_folder = cluster_config_file.parent

    if output_folder is None:
        output_folder = Path.joinpath(base_folder, "machineConfigs")

    if not output_folder.is_dir():
        create_output_folder = typer.confirm(
            f"Folder '{str(output_folder)}' does not exist. Create it?")
        if not create_output_folder:
            raise typer.Abort()

        output_folder.mkdir()

    with cluster_config_file.open('r') as fp:
        cluster_config = yaml.safe_load(fp)

    logger.info(
        f"Generating talos configuration files for cluster '{cluster_config['name']}'")

    template_controlplane = Path.joinpath(base_folder, 'controlplane.yaml')
    template_worker = Path.joinpath(base_folder, 'worker.yaml')
    template_taloscfg = Path.joinpath(base_folder, 'talosconfig')
    if not (template_controlplane.exists() and template_worker.exists()):
        logger.info(
            f"No existing configuration templates found in {str(base_folder)}, generating new ones.")

        subprocess.run(
            [
                "talosctl", "gen", "config",
                cluster_config['name'],
                cluster_config['controlplane']['endpoint'],
                "--output-dir", str(base_folder)
            ],
            stdout=subprocess.DEVNULL
        )
        template_taloscfg.unlink()

    variables = None
    if variables_file and variables_file.exists():
        variables = _load_variables_from_file(variables_file)

    # Render control plane nodes
    for node in cluster_config['nodes']:
        hostname = node['hostname']
        domain = node['domain']
        if node.get('controlplane') and node['controlplane']:
            template = template_controlplane
            config_patches = cluster_config['controlplane'].get(
                'configPatches') or []
        else:
            template = template_worker
            config_patches = cluster_config['workers'].get(
                'configPatches') or []

        config_patches = config_patches + (node.get('configPatches') or [])
        result = process_node(hostname, domain, template, config_patches)
        if variables:
            result = parse_variables(result, r"\$\{(.*)\}", variables)

        with Path.joinpath(output_folder, f"{hostname}.yaml") .open('w') as fp:
            yaml.safe_dump(result, fp)

    # Render worker nodes
    logger.info("Done")


if __name__ == "__main__":
    app()
