{ config, pkgs, lib, ... }:

let
  projectRoot = "/home/mstouffer/repos/handterm-proj";
  
  # Development container management functions
  devcontainerFunctions = ''
    function handterm-dev-container() {
      local component="$1"
      local action="$2"
      
      case "$component" in
        "cdk")
          cd "${projectRoot}/handterm-cdk"
          ;;
        "react")
          cd "${projectRoot}/handterm"
          ;;
        *)
          echo "Usage: handterm-dev-container <cdk|react> <up|down|shell>"
          return 1
          ;;
      esac
      
      case "$action" in
        "up")
          devcontainer up --workspace-folder .
          ;;
        "down")
          devcontainer down --workspace-folder .
          ;;
        "shell")
          devcontainer open --workspace-folder .
          ;;
        *)
          echo "Unknown action: $action"
          return 1
          ;;
      esac
    }
  '';
  
  # Project-specific functions
  handtermFunctions = ''
    # Handterm React development environment
    function handterm-dev() {
      export HANDTERM_ENV=development
      export PATH="${projectRoot}/handterm/node_modules/.bin:$PATH"
      
      cd "${projectRoot}/handterm"
      echo "Handterm React development environment activated"
      echo "Available commands: npm start, npm test, npm run deploy"
    }
    
    # Handterm CDK development environment
    function handterm-cdk-dev() {
      export AWS_PROFILE=handterm
      export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
      export CDK_DEFAULT_REGION=us-west-2
      
      cd "${projectRoot}/handterm-cdk"
      echo "Handterm CDK development environment activated"
      echo "Available commands: cdk deploy, cdk diff, cdk synth"
    }
    
    # Deployment helpers
    function handterm-deploy-site() {
      cd "${projectRoot}/handterm"
      npm run deploy
    }
    
    function handterm-deploy-api() {
      cd "${projectRoot}/handterm-cdk"
      cdk deploy
    }
  '';

  # Project-specific packages
  handtermPackages = with pkgs; [
    # Node.js development
    nodejs_20
    yarn
    
    # AWS CDK tools
    aws-cdk
    awscli2
    
    # Development container support
    docker
    docker-compose
    devcontainer-cli
    
    # Development tools
    gh  # GitHub CLI
  ];

in {
  # Add project-specific packages
  home.packages = handtermPackages;

  # Project-specific shell configurations
  programs.bash = {
    enable = true;
    initExtra = devcontainerFunctions + handtermFunctions;
  };

  # Development container configurations
  home.file = {
    # React app devcontainer config
    "${projectRoot}/handterm/.devcontainer/devcontainer.json" = {
      text = builtins.toJSON {
        name = "Handterm React";
        image = "mcr.microsoft.com/devcontainers/typescript-node:1-20-bullseye";
        customizations = {
          vscode = {
            extensions = [
              "dbaeumer.vscode-eslint"
              "esbenp.prettier-vscode"
            ];
          };
        };
        forwardPorts = [ 3000 ];
        postCreateCommand = "npm install";
      };
    };

    # CDK app devcontainer config
    "${projectRoot}/handterm-cdk/.devcontainer/devcontainer.json" = {
      text = builtins.toJSON {
        name = "Handterm CDK";
        image = "mcr.microsoft.com/devcontainers/typescript-node:1-20-bullseye";
        customizations = {
          vscode = {
            extensions = [
              "dbaeumer.vscode-eslint"
              "aws-scripting-guy.cdk-swiss-army-knife"
            ];
          };
        };
        mounts = [
          "source=${config.home.homeDirectory}/.aws,target=/home/node/.aws,type=bind,consistency=cached"
        ];
        postCreateCommand = "npm install";
      };
    };
  };

  # Project-specific VSCode settings
  programs.vscode = {
    enable = true;
    userSettings = {
      "files.associations" = {
        "*.tsx" = "typescriptreact";
      };
      "editor.formatOnSave" = true;
    };
  };
}
