{ config, lib, pkgs, ... }:

{
  options.programs.chezmoi = {
    enable = lib.mkEnableOption "chezmoi dotfile manager";
    
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.chezmoi;
      description = "The chezmoi package to use";
    };
  };

  config = lib.mkIf config.programs.chezmoi.enable {
    # Just install chezmoi, nothing else
    home.packages = [ config.programs.chezmoi.package ];

    # Explicitly tell Home Manager to stay away from dotfiles
    home.file = {
      ".bashrc".enable = false;
      ".bash_profile".enable = false;
      ".profile".enable = false;
      ".config/chezmoi".enable = false;
    };
  };
}
