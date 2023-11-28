{lib, ... }:
{
  editor = {
    bracketPairColorization = {
      enabled = true;
    };
    defaultFormatter = "esbenp.prettier-vscode";
    fontFamily = (lib.strings.concatStringsSep "," [
      "'FiraCode Nerd Font'"
      "'Font Awesome 6 Free Solid'"
    ]);
    fontLigatures = true;
    formatOnSave = true;
    guides = {
      bracketPairs = true;
      bracketPairsHorizontal = true;
      highlightActiveBracketPair = true;
    };
    stickyScroll = {
      enabled = true;
    };
    tabSize = 2;
  };

  explorer = {
    compactFolders = false;
    confirmDelete = false;
    confirmDragAndDrop = false;
  };

  extensions.autoUpdate = false;

  files = {
    associations = {};
    autoSave = "onFocusChange";
    eol = "\n";
    insertFinalNewline = true;
    trimFinalNewlines = true;
    trimTrailingWhitespace = true;
  };

  git = {
    autofetch = true;
    confirmSync = false;
  };

  update = {
    showReleaseNotes = false;
  };

  window = {
    commandCenter = false;
    newWindowDimensions = "maximized";
    restoreWindows = "none";
    titleBarStyle = "custom";
  };

  workbench = {
    colorTheme = "Catppuccin Macchiato";
    iconTheme = "catppuccin-macchiato";
    sideBar = {
      location = "left";
    };
    startupEditor = "newUntitledFile";
    tree = {
      renderIndentGuides = "none";
    };
  };

  "workbench.iconTheme" = "catppuccin-macchiato";

  # Language settings
  nix = {
    enableLanguageServer = true;
    serverPath = "nil";
  };

  "[go]" = {
    editor.defaultFormatter = "golang.go";
    toolsManagement.autoUpdate = true;
  };

  "[terraform]" = {
    editor.defaultFormatter = "hashicorp.terraform";
  };

  # Extension specific settings
  path-autocomplete.triggerOutsideStrings = true;

  redhat.telemetry.enabled= false;

  sops.beta = false;

  todo-tree = {
    highlights.useColourScheme = true;
    tree.expanded = true;
  };
}
