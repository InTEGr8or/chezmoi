{ config, pkgs, ... }:

{
  # Only configure VS Code Insiders settings for WSL
  home.file = {
    # VS Code Insiders Server settings
    ".vscode-server-insiders/data/Machine/settings.json" = {
      text = builtins.toJSON {
        # Shell script settings
        "[shellscript]" = {
          "editor.defaultFormatter" = "foxundermoon.shell-format";
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
        };

        # Shell integration
        "terminal.integrated.defaultProfile.linux" = "bash";
        "terminal.integrated.shell.linux" = "${pkgs.bash}/bin/bash";

        # Enable shellcheck
        "shellcheck.enable" = true;
        "shellcheck.useWorkspaceRootAsCwd" = true;
        "shellcheck.run" = "onSave";

        # General settings
        "editor.formatOnSave" = true;
        "editor.renderWhitespace" = "boundary";
        "files.trimTrailingWhitespace" = true;

        # Nix syntax highlighting
        "[nix]" = {
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
        };

        # Git integration
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
      };
    };
  };

  # Install development tools that VSCode will use
  home.packages = with pkgs; [
    shellcheck    # Shell script checking
    nixfmt       # Nix formatting
  ];
}
