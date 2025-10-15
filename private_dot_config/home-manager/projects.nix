{ config, pkgs, lib, ... }:

let
  # Define project-specific shell functions
  prsProjectFunctions = ''
    # PRS Project functions
    function prs-dev() {
      # Set up PRS development environment
      export AWS_PROFILE=prs-dev
      export JAVA_HOME=${pkgs.jdk17}
      export PATH=$JAVA_HOME/bin:$PATH
      export PRS_ENV=development
      
      # Add project-specific bin to PATH
      export PATH=$HOME/projects/prs/bin:$PATH
      
      echo "PRS development environment activated"
      echo "Java version: $(java -version 2>&1 | head -n 1)"
      echo "AWS Profile: $AWS_PROFILE"
    }
    
    function prs-logs() {
      local date_filter="$1"
      if [ -z "$date_filter" ]; then
        date_filter=$(date +%Y-%m-%d)
      fi
      
      aws logs get-log-events \
        --log-group-name /aws/ec2/prs \
        --filter-pattern "$date_filter" \
        --output json | jq .
    }
    
    function prs-deploy() {
      local env="$1"
      if [ -z "$env" ]; then
        echo "Usage: prs-deploy <environment>"
        return 1
      fi
      
      # Run deployment script
      $HOME/projects/prs/scripts/deploy.sh "$env"
    }
  '';

  # Project-specific packages
  prsPackages = with pkgs; [
    # Java development
    jdk17
    maven
    gradle
    
    # AWS tools
    awscli2
    ssm-session-manager-plugin
    aws-sam-cli
    
    # Log processing
    jq
    yq
    gawk
    
    # Development tools
    docker
    docker-compose
  ];

in {
  # Add project-specific packages
  home.packages = prsPackages;

  # Project-specific shell configurations
  programs.bash = {
    enable = true;
    initExtra = prsProjectFunctions;
  };

  # Create project directory structure
  home.file = {
    # PRS project scripts
    "projects/prs/scripts/deploy.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        
        ENV="$1"
        
        # Deployment logic here
        echo "Deploying PRS to $ENV..."
        
        # Example deployment steps
        case "$ENV" in
          "dev")
            aws ssm send-command \
              --targets "Key=tag:Environment,Values=development" \
              --document-name "AWS-RunShellScript" \
              --parameters "commands=['/opt/prs/scripts/update.sh']"
            ;;
          "prod")
            echo "Production deployment requires approval"
            exit 1
            ;;
          *)
            echo "Unknown environment: $ENV"
            exit 1
            ;;
        esac
      '';
    };

    # Log processing scripts
    "projects/prs/scripts/process-logs.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        
        INPUT_FILE="$1"
        OUTPUT_DIR="$2"
        
        if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_DIR" ]; then
          echo "Usage: process-logs.sh <input-file> <output-dir>"
          exit 1
        fi
        
        mkdir -p "$OUTPUT_DIR"
        
        # Split logs by date
        awk '
          /[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
            date = substr($0, match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2}/), 10)
            print > "'$OUTPUT_DIR'/" date ".log"
          }
        ' "$INPUT_FILE"
        
        echo "Logs processed and split into $OUTPUT_DIR"
      '';
    };

    # VSCode workspace settings
    "projects/prs/.vscode/settings.json" = {
      text = builtins.toJSON {
        "java.configuration.updateBuildConfiguration" = "automatic";
        "java.compile.nullAnalysis.mode" = "automatic";
        "aws.telemetry" = false;
        "[java]" = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "redhat.java";
        };
      };
    };
  };

  # Project-specific Git configuration
  programs.git.includes = [
    {
      condition = "gitdir:~/projects/prs/";
      contents = {
        core = {
          autocrlf = "input";
        };
        branch.autosetuprebase = "always";
      };
    }
  ];
}
