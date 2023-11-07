{ inputs, system, ... }:
final: prev:
{
  # talosctl = prev.talosctl.override {
  #   buildGoModule = args: prev.buildGoModule (args // {
  #     version = "1.5.1";
  #     src = prev.fetchFromGitHub {
  #       owner = "siderolabs";
  #       repo = "talos";
  #       rev = "v1.5.1";
  #       hash = "sha256-HYIk1oZbtcnHLap+4AMwoQN0k44zjiiwDzGcNW+9qqM=";
  #     };
  #     vendorHash = "sha256-Aefwa8zdKWV9TE9rwNA4pzKZekTurkD0pTDm3QfKdUQ=";
  #   });
  # };
}
