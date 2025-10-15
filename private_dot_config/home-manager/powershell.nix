{ config, pkgs, ... }:

{
  # PowerShell module installation configuration
  programs.powershell = {
    enable = true;
    modules = [
      "powershell-yaml"
      "ULID"
      # Add other modules you want to install
    ];
  };

  # Track only specific PowerShell files
  home.file = {
    # Profile
    ".config/powershell/profile.ps1" = {
      source = "/mnt/c/Users/xgenx/OneDrive/Documents2/PowerShell/profile.ps1";
    };

    # Custom Scripts directory
    ".config/powershell/Scripts" = {
      source = "/mnt/c/Users/xgenx/OneDrive/Documents2/PowerShell/Scripts";
      recursive = true;
      exclude = [
        "InstalledScriptInfos/**"  # Exclude installation metadata
        "**/Help/**"               # Exclude help files
        "**/__pycache__/**"        # Exclude Python cache
        "**/Modules/**"            # Exclude module files
      ];
    };

    # Create a PowerShell profile that sources our managed profile
    "Documents/PowerShell/Microsoft.PowerShell_profile.ps1" = {
      text = ''
        # Source the Home Manager managed profile
        . "$env:USERPROFILE\.config\powershell\profile.ps1"
      '';
    };
  };
}
