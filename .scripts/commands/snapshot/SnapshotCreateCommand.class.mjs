class SnapshotCreateCommand {
  constructor(args) {
    this.help = args["help"] || false
    this.pvc = args["pvc"] || argv["p"] || process.env.PVC
    this.namespace = args["namespace"] || process.env.NAMESPACE
  }

  usage = function () {
    const helpText = [
      "usage: glue snapshot create --pvc <pvc> [optional arguments]",
      "",
      "required arguments:",
      "  pvc:               create a snapshot for this PVC",
      "",
      "optional arguments:",
      "  namespace:         the namespace in which the snapshot CronJob can be found (defaults to 'default')",
    ].join("\n")
    console.log(helpText)
  }

  async run() {
    if (this.help) {
      this.usage()
      return
    }

    if (!this.pvc) {
      throw new Error("Argument --pvc, -p or env PVC not set")
    }
    if (!this.namespace) {
      throw new Error("Argument --namespace or env NAMESPACE not set")
    }

    const jobRaw = await $`kubectl -n ${this.namespace} create job --from=cronjob/${this.pvc}-snapshot ${this.pvc}-snapshot-${+new Date} --dry-run=client --output json`
    const jobJson = JSON.parse(jobRaw.stdout)
    delete jobJson.spec.template.spec.initContainers
    const jobYaml = new YAML.Document();
    jobYaml.contents = jobJson;
    await $`echo ${jobYaml.toString()}`.pipe($`kubectl apply -f -`)
  }
}

export { SnapshotCreateCommand }
