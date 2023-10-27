{
  programs.starship = {
    enable = true;
    settings = {
      palette = "catppuccin_macchiato";

      format = ''
        $os$time$username($hostname)($kubernetes)($git_branch)($python)($terraform)($golang)
        $directory$character
      '';

      os = {
        disabled = false;
        symbols.Ubuntu = "";
        symbols.Windows = "";
        symbols.Macos = "";
        symbols.Debian = "\uf306";
        symbols.NixOS = "";
        style  = "bg:blue fg:background";
        format = "[ $symbol ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R"; # Hour:Minute Format
        style = "bg:blue fg:background bold";
        format = "[ 󱑍 $time [](fg:blue bg:peach)]($style)";
      };

      username = {
        disabled = false;
        show_always = true;
        style_user = "bg:peach fg:background bold";
        style_root = "bg:peach fg:background bold";
        format = "[ $user [](fg:peach bg:background)]($style)";
      };

      hostname = {
        disabled = false;
        ssh_only = true;
        ssh_symbol = "🌐";
        style = "bg:maroon fg:background bold";
        format = "[ $ssh_symbol $hostname [](fg:maroon bg:background)]($style)";
      };

      git_branch = {
        symbol = "  ";
        style = " bg:yellow fg:background";
        format = "[ $symbol$branch(:$remote_branch) [](fg:yellow bg:background)]($style)";
      };

      kubernetes = {
        disabled = false;
        symbol = "󱃾 ";
        style  = "bg:green fg:background";
        format = "[ $symbol$context \\($namespace\\) [](fg:green bg:background)]($style)";
      };

      python = {
        symbol = " ";
        style  = "bg:flamingo fg:background";
        format = "[ $symbol$pyenv_prefix($version )(\\($virtualenv\\)) [](fg:flamingo bg:background)]($style)";
      };

      golang = {
        symbol = " ";
        style  = "bg:flamingo fg:background";
        format = "[ $symbol($version) [](fg:flamingo bg:background)]($style)";
      };

      terraform = {
        symbol = "󱁢 ";
        style  = "bg:flamingo fg:background";
        format = "[ $symbol$version [](fg:flamingo bg:background)]($style)";
      };

      directory = {
        truncation_length = 4;
        truncation_symbol = "…/";
        style = "fg:lavender";
        format = "[   $path]($style)";
      };

      character = {
        success_symbol = "[ >](bold green)";
        error_symbol = "[ ✗](#E84D44)";
      };

      palettes = {
        catppuccin_macchiato = {
          background = "#24273a";
          rosewater = "#f4dbd6";
          flamingo = "#f0c6c6";
          pink = "#f5bde6";
          mauve = "#c6a0f6";
          red = "#ed8796";
          maroon = "#ee99a0";
          peach = "#f5a97f";
          yellow = "#eed49f";
          green = "#a6da95";
          teal = "#8bd5ca";
          sky = "#91d7e3";
          sapphire = "#7dc4e4";
          blue = "#8aadf4";
          lavender = "#b7bdf8";
          text = "#cad3f5";
          subtext1 = "#b8c0e0";
          subtext0 = "#a5adcb";
          overlay2 = "#939ab7";
          overlay1 = "#8087a2";
          overlay0 = "#6e738d";
          surface2 = "#5b6078";
          surface1 = "#494d64";
          surface0 = "#363a4f";
          base = "#24273a";
          mantle = "#1e2030";
          crust = "#181926";
        };
      };
    };
  };
}
