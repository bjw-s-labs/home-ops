class SnapshotListCommand {
  constructor(args) {
    this.help = args["help"] || false
    this.pvc = args["pvc"] || argv["p"] || process.env.PVC
    this.namespace = args["namespace"] || process.env.NAMESPACE
    this.kopiaApp = args["kopia-app"] || process.env.KOPIA_APP || "kopia"
    this.kopiaNamespace = args["kopia-namespace"] || process.env.KOPIA_NAMESPACE || "default"
  }

  usage = function () {
    const helpText = [
      "usage: glue snapshot list --pvc <pvc> [optional arguments]",
      "",
      "required arguments:",
      "  pvc:               list snapshots for this PVC",
      "",
      "optional arguments:",
      "  namespace:         the namespace in which the PVC can be found (defaults to 'default')",
      "  kopia-app:         the name of the Kopia Deployment to query (defaults to 'kopia')",
      "  kopia-namespace:   the namespace in which the Kopia Deployment can be found (defaults to 'default')",
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

    const snapshots =
      await $`kubectl -n ${this.kopiaNamespace} exec -it deployment/${this.kopiaApp} -- kopia snapshot list /data/${this.namespace}/${this.pvc} --json`
    let structData = []
    for (const obj of JSON.parse(snapshots.stdout)) {
      const latest = obj.retentionReason.includes("latest-1")
      structData.push({
        "snapshot id": obj.id,
        "date created": obj.startTime,
        latest: latest,
      })
    }
    console.table(structData)
  }
}

export { SnapshotListCommand }
