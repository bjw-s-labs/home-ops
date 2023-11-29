{ pkgs, ... }:
let
  vscode-extensions = (import ../../editor/vscode/extensions.nix){pkgs = pkgs;};
in
{
  modules.users.bjw-s.kubernetes.k9s.enable = true;
  modules.users.bjw-s.kubernetes.krew.enable = true;
  modules.users.bjw-s.kubernetes.kubecm.enable = true;
  modules.users.bjw-s.kubernetes.stern.enable = true;

  modules.users.bjw-s.shell.fish = {
    config.programs.fish = {
      shellAliases = {
        k = "kubectl";
      };
      interactiveShellInit = ''
        flux completion fish | source
      '';
    };
  };

  modules.users.bjw-s.editor.vscode = {
    extensions = with vscode-extensions; [
      ms-kubernetes-tools.vscode-kubernetes-tools
    ];

    config = {
      vs-kubernetes = {
        "vs-kubernetes.crd-code-completion" = "disabled";
      };
    };
  };
}
