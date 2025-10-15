{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "mstouffer";
  home.homeDirectory = "/home/mstouffer";

  # Packages to install
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "mstouffer";
    userEmail = "your.email@example.com";  # Replace with your email
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11";
}
