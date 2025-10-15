{ config, lib, pkgs, ... }:

let
  cfg = config.state-management.aws;
in {
  options.state-management.aws = {
    enable = lib.mkEnableOption "AWS state management";
    
    profilesFile = lib.mkOption {
      type = lib.types.path;
      default = ~/.aws/credentials;
      description = "Path to AWS credentials file";
    };

    generateScripts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to generate AWS profile management scripts";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ awscli2 ];

    # Generate AWS profile management scripts
    home.file.".local/bin/aws-profile".executable = true;
    home.file.".local/bin/aws-profile".text = ''
      #!/usr/bin/env bash
      
      if [ $# -eq 0 ]; then
        echo "Current AWS_PROFILE: $AWS_PROFILE"
        aws sts get-caller-identity 2>/dev/null || echo "No active profile"
        echo -e "\nAvailable profiles:"
        aws configure list-profiles
        return
      fi

      export AWS_PROFILE="$1"
      echo "Switched to profile: $AWS_PROFILE"
      aws sts get-caller-identity || echo "Failed to assume profile"
    '';

    # Add to PATH
    home.sessionVariables = {
      PATH = "$HOME/.local/bin:$PATH";
    };
  };
}
