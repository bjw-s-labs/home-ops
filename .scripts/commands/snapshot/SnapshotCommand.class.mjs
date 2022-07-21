import { SnapshotListCommand } from "./SnapshotListCommand.class.mjs"
import { SnapshotCreateCommand } from "./SnapshotCreateCommand.class.mjs"

class SnapshotCommand {
  constructor(args) {
    this.args = args
    this.help = args["help"] || false
    this.pvc = args["pvc"] || process.env.PVC
    this.namespace = args["namespace"] || args["n"] || process.env.NAMESPACE
  }

  usage = function() {
    const helpText = [
      "usage: glue snapshot <command>",
      "",
      "available commands:",
      "  list:     list snapshots for a PVC",
      "  create:   create a new snapshot for a PVC",
    ].join("\n")
    console.log(helpText)
  }

  async run() {
    const snapshotCommand = this.args["_"][0]
    this.args["_"].splice(0, 1)
    if (!snapshotCommand) {
      this.usage()
      return
    }

    let commandObject
    switch (snapshotCommand) {
      case "list":
        commandObject = new SnapshotListCommand(this.args)
        break;
      case "create":
        commandObject = new SnapshotCreateCommand(this.args)
        break;
      default:
        commandObject = new SnapshotErrorCommand(snapshotCommand)
    }
    await commandObject.run()
  }
}

class SnapshotErrorCommand {
  constructor(command) {
    this.command = command
  }

  async run() {
    console.log(
      "Sorry! The '%s' command is not implemented. Please type 'glue snapshot --help' to see what I can help you with.",
      this.command
    )
  }
}

export { SnapshotCommand }
