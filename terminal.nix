#; terminal.nix
{ pkgs, inputs, ... }:

{
  imports = [
    ./helix/hx.nix
  ];
  # zsh as the real login shell (NixOS requires this on before setting it as the shell)
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = false;
  users.users."muffy".shell = pkgs.zsh;

  # Nerd Font
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  # Insults. Ehe.
  security.sudo.extraConfig = "Defaults insults";

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users."muffy" = { pkgs, ... }: {
    programs.foot = {
      enable = true;
      settings.main = {
        font = "JetBrainsMono Nerd Font:size=13";
        shell = "${pkgs.zsh}/bin/zsh";
      };
    };

    programs.fastfetch.enable = true;

    programs.hyfetch = {
      enable = true;
      settings = {
        preset = "transgender";
        mode = "rgb";
        light_dark = "dark";
        color_align.mode = "horizontal";
        backend = "fastfetch";
        pride_month_disable = false;
        pride_month_shown = [ ];
      };
    };

    programs.yazi = {
      enable = true;
      settings.opener.edit = [
        {
          run = ''${pkgs.helix}/bin/hx "$@"'';
          block = true;
        }
      ];
    };

    # Zim: modules list, read by zimfw
    home.file.".zimrc".text = ''
      zmodule environment
      zmodule git
      zmodule input
      zmodule termtitle
      zmodule utility
      zmodule duration-info
      zmodule git-info
      zmodule prompt-pwd
      zmodule agnoster
      zmodule zsh-users/zsh-completions --fpath src
      zmodule completion
      zmodule zsh-users/zsh-syntax-highlighting
      zmodule zsh-users/zsh-autosuggestions
    '';

    programs.zsh.enable = true;
    programs.zsh.enableCompletion = false;

    #programs.zsh.completionInit = "";
    # Merges with the programs.zsh.enable already in configuration.nix
    programs.zsh.initContent = ''
      # Zim bootstrap (the official snippet from the zimfw README)
      ZIM_HOME=$HOME/.zim
      if [[ ! -e $ZIM_HOME/zimfw.zsh ]]; then
        ${pkgs.curl}/bin/curl -fsSL --create-dirs -o $ZIM_HOME/zimfw.zsh \
          https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
      fi
      if [[ ! $ZIM_HOME/init.zsh -nt $HOME/.zimrc ]]; then
        source $ZIM_HOME/zimfw.zsh init
      fi
      source $ZIM_HOME/init.zsh

      hyfetch
    '';
  };
}
