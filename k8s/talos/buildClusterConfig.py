from curses import has_key
import jsonpatch
import subprocess
import sys
import typer
import yaml

from pathlib import Path
from typing import Optional
from loguru import logger

app = typer.Typer(add_completion=False)


def _setup_logging(debug):
    """
    Setup the log formatter for Excludarr
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


def process_node(hostname: str, template: str, config_patches: list):
    logger.info(f"Processing node {hostname}")

    with template.open('r') as fp:
        node_template = yaml.safe_load(fp)

    node_configpatches = [
        {'op': 'add', 'path': '/machine/network/hostname', 'value': hostname}
    ]

    if config_patches:
        node_configpatches = node_configpatches + config_patches
    node_configpatches = jsonpatch.JsonPatch(node_configpatches)

    result = node_configpatches.apply(node_template)
    return result


@app.command()
def main(
    cluster_config_file: Path = typer.Argument(
        ..., help="The YAML file containing the cluster configuration."),
    output_folder: Path = typer.Argument(
        None, help="Folder where the output should be written."),
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

    # Render control plane nodes
    for node in cluster_config['nodes']:
        hostname = node['hostname']
        if node.get('controlplane') and node['controlplane']:
            template = template_controlplane
            config_patches = cluster_config['controlplane'].get(
                'configPatches') or []
        else:
            template = template_worker
            config_patches = cluster_config['workers'].get(
                'configPatches') or []

        config_patches = config_patches + (node.get('configPatches') or [])
        result = process_node(hostname, template, config_patches)
        with Path.joinpath(output_folder, f"{node['hostname']}.yaml") .open('w') as fp:
            yaml.safe_dump(result, fp)

    # Render worker nodes
    logger.info("Done")


if __name__ == "__main__":
    app()
