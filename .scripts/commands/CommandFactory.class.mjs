import { SnapshotCommand } from "./snapshot/SnapshotCommand.class.mjs"

class ErrorCommand {
  constructor(command) {
    this.command = command
  }

  async run() {
    console.log(
      "Sorry! The '%s' command is not implemented. Please type 'glue help' to see what I can help you with.",
      this.command
    );
  }
}

class HelpCommand {
  async run() {
    const helpText = [
      "usage: glue <command>",
      "",
      "available commands:",
      "  snapshot:   manage PMB snapshots",
      "  help:       used to print the usage guide",
    ].join("\n")
    console.log(helpText)
  }
}

class CommandFactory {
  getCommand(command, args) {
    if (!command) {
      return new HelpCommand();
    }
    switch (command) {
      case "snapshot":
        return new SnapshotCommand(args)
      case "help":
        return new HelpCommand()
      default:
        return new ErrorCommand(command);
    }
  }
}

export { CommandFactory }
