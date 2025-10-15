{ config, pkgs, lib, ... }:

let
  # Project configuration
  projectName = "prs";
  projectRoot = "~/projects/${projectName}";

  # Read and process the template
  shellFunctionsTemplate = builtins.readFile ../shell-scripts/prs-functions.sh.tmpl;

in {
  # Install required packages
  home.packages = with pkgs; [
    awscli2
    ssm-session-manager-plugin
    jq
    gawk
  ];

  # Add shell functions but don't handle state
  programs.bash = {
    enable = true;
    initExtra = ''
      # PRS Project Functions
      export PRS_PROJECT_ROOT="${projectRoot}"
      
      ${shellFunctionsTemplate}
    '';
  };

  # Create a script to initialize the project environment
  home.file.".local/bin/prs-init" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      # Switch to PRS AWS profile
      aws-profile westmonroe-support
      
      # Set project-specific environment variables
      export PRS_AWS_REGION="us-east-1"
      export PRS_INSTANCE_TAGS="Name=tag:Project,Values=PRS"
      
      echo "PRS environment initialized"
      aws sts get-caller-identity
    '';
  };

  # Development environment file
  home.file."${projectRoot}/.envrc".text = ''
    # Load project environment
    use nix
    
    # Project-specific variables
    export PRS_PROJECT_ROOT="${projectRoot}"
    export PRS_AWS_REGION="us-east-1"
    export PRS_INSTANCE_TAGS="Name=tag:Project,Values=PRS"
  '';
}
