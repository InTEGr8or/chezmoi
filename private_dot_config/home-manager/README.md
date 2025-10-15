# Personal Home Manager Configuration Guide

## DevOps Process

### Overview of DevOps Components

1. Home Manager's Proper Role:
  • It's primarily meant to manage your user environment in a declarative way
  • It's great for installing and configuring packages
  • It can manage environment variables and program configurations
  • But it shouldn't necessarily overwrite your entire shell configuration
2. For Context Switching (like AWS profiles):
  • Home Manager might not be the best tool for this
  • It's more suited for persistent configuration rather than session-specific states
  • For session-specific contexts, you might want to look at:
      • direnv (which integrates well with Nix)
      • AWS_PROFILE environment variables
      • Shell functions/aliases
      • Zellij's own session management capabilities
3. A Better Approach Might Be:
  • Use Home Manager to install and configure your tools (Zellij, AWS CLI, etc.)
  • Use direnv for project-specific environment variables
  • Use shell scripts or functions for context switching
  • Keep your ~/.bashrc under chezmoi control
  • Have Home Manager add its Nix-specific stuff to a separate file that your ~/.bashrc sources

### 1. Configuration Management

```bash
# Edit configurations
code ~/.config/home-manager/  # Open in VSCode
home-manager edit           # Direct edit

# Test changes
home-manager build         # Test build without applying
home-manager switch        # Apply changes

# Rollback if needed
home-manager generations   # List available generations
home-manager rollback     # Revert to previous generation
```

### 2. Version Control
Your Home Manager configurations should be tracked in version control:
```bash
cd ~/.config/home-manager
git status                # Check changes
git add -A               # Stage changes
git commit -m "feat: add new project configuration"
git push
```

### 3. Adding New Projects
1. Create project configuration in `~/.config/home-manager/projects/`
2. Import in `home.nix`
3. Test with `home-manager build`
4. Apply with `home-manager switch`

## Project Environments

### Available Projects

1. **PRS Project** - Java/AWS EC2 application
   ```bash
   # Development
   prs-dev          # Activate development environment

   # Deployment
   prs-deploy dev   # Deploy to development
   prs-logs         # View application logs
   ```

2. **Handterm Project** - CDK/React application
   ```bash
   # Development Environments
   handterm-dev           # React development
   handterm-cdk-dev       # CDK development

   # Development Containers
   handterm-dev-container react up     # Start React container
   handterm-dev-container react shell  # Shell into container
   handterm-dev-container cdk up       # Start CDK container

   # Deployment
   handterm-deploy-site   # Deploy to GitHub Pages
   handterm-deploy-api    # Deploy API Gateway stack
   ```

## Project Structure
```
~/.config/home-manager/
├── home.nix          # Main configuration
├── powershell.nix    # PowerShell config
├── projects/
│   ├── prs.nix       # PRS project config
│   └── handterm.nix  # Handterm project config
└── README.md         # This guide
```

## Development Containers
- Managed through project-specific commands
- Configurations in respective project directories
- Mounted AWS credentials and other secrets
- VSCode integration included

## Quick Reference

### Common Operations
```bash
# Configuration
home-manager edit                  # Edit configuration
home-manager switch               # Apply changes
home-manager generations         # List backups
home-manager rollback           # Revert changes

# Development
code ~/.config/home-manager/     # Open all configs in VSCode
home-manager build              # Test configuration

# Information
home-manager news               # View updates
home-manager help              # Command help
```

## Resources
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Development Container Spec](https://containers.dev/implementors/spec/)

## Adding New Tools
1. Search for packages: [Nix Package Search](https://search.nixos.org/packages)
2. Add to appropriate .nix file:
   ```nix
   home.packages = with pkgs; [
     new-package
   ];
   ```
3. Or add as a program configuration:
   ```nix
   programs.tool = {
     enable = true;
     # tool-specific config
   };
   ```

## Project-Specific Documentation
- [PRS README](~/projects/prs/README.md)
- [Handterm README](~/repos/handterm-proj/README.md)

## Adding New Tools - Examples

### 1. Simple Package Installation
```nix
# In home.nix or project-specific .nix file
home.packages = with pkgs; [
  # Development tools
  nodejs_20        # Specific version of Node.js
  python311       # Python 3.11
  go_1_21        # Go 1.21

  # CLI tools
  terraform      # Infrastructure as Code
  kubectl        # Kubernetes CLI
  k9s           # Kubernetes TUI

  # Productivity tools
  obsidian      # Note-taking
  slack         # Communication
];
```

### 2. Program Configuration
```nix
# VSCode with extensions
programs.vscode = {
  enable = true;
  extensions = with pkgs.vscode-extensions; [
    ms-python.python
    golang.go
    hashicorp.terraform
  ];
};

# Git with multiple configs
programs.git = {
  enable = true;
  userName = "Your Name";
  includes = [
    {
      # Work-specific configuration
      condition = "gitdir:~/work/";
      contents = {
        user.email = "work@example.com";
      };
    }
  ];
};

# Shell aliases and functions
programs.bash = {
  enable = true;
  shellAliases = {
    k = "kubectl";
    tf = "terraform";
  };
  functions = {
    mkcd = "mkdir -p $1 && cd $1";
  };
};
```

### 3. Environment Variables
```nix
home.sessionVariables = {
  EDITOR = "vim";
  GOPATH = "$HOME/go";
  PATH = "$PATH:$GOPATH/bin";
};
```

## Troubleshooting Guide

### Common Issues

1. **Configuration Not Applied**
   ```bash
   # Check if changes are valid
   home-manager build

   # Look for error messages
   home-manager switch --debug

   # Check current generation
   home-manager generations
   ```

2. **Package Not Found**
   ```bash
   # Search for correct package name
   nix-env -qaP | grep package-name

   # Check if package is available
   nix search nixpkgs package-name
   ```

3. **Development Container Issues**
   ```bash
   # Reset container
   handterm-dev-container react down
   docker system prune -f
   handterm-dev-container react up

   # Check container logs
   docker logs container-name
   ```

4. **Home Manager Generation Issues**
   ```bash
   # List all generations
   home-manager generations

   # Remove old generations
   home-manager expire-generations "-30 days"

   # Garbage collect
   nix-collect-garbage -d
   ```

### Debug Commands
```bash
# Show verbose output
home-manager switch --verbose

# Show debug output
home-manager switch --debug

# Check configuration
home-manager check

# Show package closure
nix why-depends path-to-derivation package-name
```

## New Project Template

Create a new file `~/.config/home-manager/projects/new-project.nix`:

```nix
{ config, pkgs, lib, ... }:

let
  # Project variables
  projectName = "new-project";
  projectRoot = "/path/to/project";

  # Project-specific functions
  projectFunctions = ''
    # Development environment
    function ${projectName}-dev() {
      export PROJECT_ENV=development
      export PATH="${projectRoot}/bin:$PATH"

      cd "${projectRoot}"
      echo "${projectName} development environment activated"
    }

    # Development container management
    function ${projectName}-container() {
      local action="$1"

      case "$action" in
        "up")
          devcontainer up --workspace-folder "${projectRoot}"
          ;;
        "down")
          devcontainer down --workspace-folder "${projectRoot}"
          ;;
        "shell")
          devcontainer open --workspace-folder "${projectRoot}"
          ;;
        *)
          echo "Usage: ${projectName}-container <up|down|shell>"
          return 1
          ;;
      esac
    }

    # Deployment helper
    function ${projectName}-deploy() {
      local env="$1"
      if [ -z "$env" ]; then
        echo "Usage: ${projectName}-deploy <environment>"
        return 1
      fi

      cd "${projectRoot}"
      ./scripts/deploy.sh "$env"
    }
  '';

  # Project-specific packages
  projectPackages = with pkgs; [
    # Development tools
    # Add required packages here

    # Build tools
    # Add build tools here

    # Deployment tools
    # Add deployment tools here
  ];

in {
  # Add project-specific packages
  home.packages = projectPackages;

  # Shell configurations
  programs.bash = {
    enable = true;
    initExtra = projectFunctions;
  };

  # Development container configuration
  home.file = {
    "${projectRoot}/.devcontainer/devcontainer.json" = {
      text = builtins.toJSON {
        name = projectName;
        image = "mcr.microsoft.com/devcontainers/base:ubuntu";  # Change as needed
        customizations = {
          vscode = {
            extensions = [
              # Add VSCode extensions here
            ];
          };
        };
        mounts = [
          # Add volume mounts here
        ];
        postCreateCommand = "echo 'Container ready'";
      };
    };
  };

  # Project-specific VSCode settings
  programs.vscode = {
    enable = true;
    userSettings = {
      # Add VSCode settings here
    };
  };
}
```

To use this template:

1. Copy template to new file:
   ```bash
   cp ~/.config/home-manager/README.md#L"New Project Template" \
      ~/.config/home-manager/projects/my-project.nix
   ```

2. Customize variables:
   - `projectName`
   - `projectRoot`
   - Required packages
   - Development container settings
   - VSCode configurations

3. Import in main configuration:
   ```nix
   # In ~/.config/home-manager/home.nix
   {
     imports = [
       ./projects/my-project.nix
     ];
     # ... rest of configuration
   }
   ```

4. Apply changes:
   ```bash
   home-manager switch
   ```

## Project Templates by Type

### React/TypeScript Web Project
```nix
{ config, pkgs, lib, ... }:

let
  projectName = "web-project";
  projectRoot = "/path/to/web-project";

  webFunctions = ''
    # Development environment
    function ${projectName}-dev() {
      export NODE_ENV=development
      export PATH="${projectRoot}/node_modules/.bin:$PATH"

      cd "${projectRoot}"
      echo "${projectName} development environment activated"
      echo "Available commands: npm start, npm test, npm run build"
    }

    # Package management
    function ${projectName}-update-deps() {
      cd "${projectRoot}"
      npm outdated
      read -p "Update dependencies? [y/N] " -n 1 -r
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        npm update
        npm audit fix
      fi
    }

    # Deployment helpers
    function ${projectName}-deploy() {
      local env="$1"
      cd "${projectRoot}"

      case "$env" in
        "staging")
          npm run build:staging
          aws s3 sync build/ s3://staging-bucket/
          ;;
        "prod")
          npm run build:prod
          aws s3 sync build/ s3://prod-bucket/
          aws cloudfront create-invalidation --distribution-id XYZ
          ;;
        *)
          echo "Usage: ${projectName}-deploy <staging|prod>"
          return 1
          ;;
      esac
    }
  '';

in {
  home.packages = with pkgs; [
    # Node.js development
    nodejs_20
    yarn

    # Build tools
    node2nix

    # AWS deployment
    awscli2

    # Development tools
    lighthouse  # Performance testing
    wait-on    # Wait for services
  ];

  # Shell configuration
  programs.bash.initExtra = webFunctions;

  # Development container
  home.file = {
    "${projectRoot}/.devcontainer/devcontainer.json" = {
      text = builtins.toJSON {
        name = "${projectName}-dev";
        image = "mcr.microsoft.com/devcontainers/typescript-node:1-20-bullseye";
        customizations = {
          vscode = {
            extensions = [
              "dbaeumer.vscode-eslint"
              "esbenp.prettier-vscode"
              "dsznajder.es7-react-js-snippets"
              "formulahendry.auto-rename-tag"
            ];
          };
        };
        forwardPorts = [ 3000 ];
        postCreateCommand = "npm install";
        features = {
          "ghcr.io/devcontainers/features/node:1": {
            version = "20";
          };
        };
      };
    };
  };

  # VSCode settings
  programs.vscode.userSettings = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
    "editor.formatOnSave" = true;
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[typescriptreact]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
  };
}
```

### React Native Mobile Project
```nix
{ config, pkgs, lib, ... }:

let
  projectName = "mobile-app";
  projectRoot = "/path/to/mobile-app";

  mobileFunctions = ''
    # Development environment
    function ${projectName}-dev() {
      export ANDROID_HOME="$HOME/Android/Sdk"
      export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
      export PATH="${projectRoot}/node_modules/.bin:$PATH"

      cd "${projectRoot}"
      echo "${projectName} development environment activated"
      echo "Available commands:"
      echo "  npm start      - Start Metro bundler"
      echo "  npm run android - Run Android app"
      echo "  npm run ios    - Run iOS app"
    }

    # Android emulator helpers
    function ${projectName}-emu() {
      local action="$1"
      local device="${2:-Pixel_6_API_33}"

      case "$action" in
        "list")
          emulator -list-avds
          ;;
        "start")
          emulator -avd "$device" &
          ;;
        "adb")
          adb devices
          ;;
        *)
          echo "Usage: ${projectName}-emu <list|start|adb> [device-name]"
          return 1
          ;;
      esac
    }

    # Build helpers
    function ${projectName}-build() {
      local platform="$1"
      local type="${2:-debug}"

      cd "${projectRoot}"

      case "$platform" in
        "android")
          cd android
          if [ "$type" = "release" ]; then
            ./gradlew assembleRelease
          else
            ./gradlew assembleDebug
          fi
          cd ..
          ;;
        "ios")
          cd ios
          if [ "$type" = "release" ]; then
            xcodebuild -workspace ${projectName}.xcworkspace -scheme ${projectName} -configuration Release
          else
            xcodebuild -workspace ${projectName}.xcworkspace -scheme ${projectName} -configuration Debug
          fi
          cd ..
          ;;
        *)
          echo "Usage: ${projectName}-build <android|ios> [debug|release]"
          return 1
          ;;
      esac
    }
  '';

in {
  home.packages = with pkgs; [
    # Node.js development
    nodejs_20
    yarn

    # Android development
    android-studio
    androidenv.androidPkgs_9_0.platform-tools

    # iOS development (if on macOS)
    # cocoapods

    # Development tools
    watchman
    react-native-cli
  ];

  # Shell configuration
  programs.bash.initExtra = mobileFunctions;

  # Development container
  home.file = {
    "${projectRoot}/.devcontainer/devcontainer.json" = {
      text = builtins.toJSON {
        name = "${projectName}-dev";
        image = "mcr.microsoft.com/devcontainers/typescript-node:1-20-bullseye";
        customizations = {
          vscode = {
            extensions = [
              "msjsdiag.vscode-react-native"
              "dbaeumer.vscode-eslint"
              "esbenp.prettier-vscode"
            ];
          };
        };
        features = {
          "ghcr.io/devcontainers/features/java:1": {
            version = "17",
            installGradle = true
          },
          "ghcr.io/devcontainers/features/android:1": {}
        };
        mounts = [
          "source=${config.home.homeDirectory}/.android,target=/home/node/.android,type=bind"
        ];
        postCreateCommand = "npm install";
      };
    };
  };

  # VSCode settings
  programs.vscode.userSettings = {
    "editor.formatOnSave" = true;
    "react-native.android.androidSdkPath" = "\${env:ANDROID_HOME}";
    "java.configuration.updateBuildConfiguration" = "automatic";
  };
}
```

### Firebase/Node.js Backend Project
```nix
{ config, pkgs, lib, ... }:

let
  projectName = "backend-api";
  projectRoot = "/path/to/backend";

  backendFunctions = ''
    # Development environment
    function ${projectName}-dev() {
      export FIREBASE_PROJECT="my-project"
      export GOOGLE_APPLICATION_CREDENTIALS="${projectRoot}/service-account.json"
      export PATH="${projectRoot}/node_modules/.bin:$PATH"

      cd "${projectRoot}"
      echo "${projectName} development environment activated"
      echo "Available commands:"
      echo "  npm start          - Start local server"
      echo "  firebase serve    - Start Firebase emulator"
      echo "  firebase deploy   - Deploy to Firebase"
    }

    # Firebase emulator helpers
    function ${projectName}-emu() {
      local action="$1"

      cd "${projectRoot}"
      case "$action" in
        "start")
          firebase emulators:start
          ;;
        "export")
          firebase emulators:export ./emulator-data
          ;;
        "import")
          firebase emulators:start --import=./emulator-data
          ;;
        *)
          echo "Usage: ${projectName}-emu <start|export|import>"
          return 1
          ;;
      esac
    }

    # Deployment helpers
    function ${projectName}-deploy() {
      local env="$1"

      cd "${projectRoot}"
      case "$env" in
        "staging")
          firebase use staging
          firebase deploy
          ;;
        "prod")
          firebase use prod
          read -p "Deploy to production? [y/N] " -n 1 -r
          if [[ $REPLY =~ ^[Yy]$ ]]; then
            firebase deploy
          fi
          ;;
        *)
          echo "Usage: ${projectName}-deploy <staging|prod>"
          return 1
          ;;
      esac
    }
  '';

in {
  home.packages = with pkgs; [
    # Node.js development
    nodejs_20
    yarn

    # Firebase tools
    firebase-tools

    # Development tools
    postman
    insomnia  # API testing
  ];

  # Shell configuration
  programs.bash.initExtra = backendFunctions;

  # Development container
  home.file = {
    "${projectRoot}/.devcontainer/devcontainer.json" = {
      text = builtins.toJSON {
        name = "${projectName}-dev",
        image = "mcr.microsoft.com/devcontainers/typescript-node:1-20-bullseye",
        customizations = {
          vscode = {
            extensions = [
              "dbaeumer.vscode-eslint"
              "esbenp.prettier-vscode"
              "github.copilot"
              "firebase.vscode-firebase"
            ];
          };
        };
        features = {
          "ghcr.io/devcontainers/features/node:1": {
            version = "20"
          },
          "ghcr.io/devcontainers/features/firebase-cli:1": {}
        };
        mounts = [
          "source=${config.home.homeDirectory}/.config/firebase,target=/home/node/.config/firebase,type=bind"
        ];
        postCreateCommand = "npm install";
      };
    };
  };

  # VSCode settings
  programs.vscode.userSettings = {
    "editor.formatOnSave" = true;
    "firebase.features.emulator" = true;
    "rest-client.environmentVariables" = {
      "local": {
        "baseUrl": "http://localhost:5001"
      },
      "staging": {
        "baseUrl": "https://staging-xyz.cloudfunctions.net"
      }
    };
  };
}
```

Each template includes:
1. Development environment setup
2. Project-specific commands
3. Deployment helpers
4. Development container configuration
5. VSCode settings and extensions
6. Required packages and tools

Key features:
- React/TypeScript: AWS deployment, testing tools
- React Native: Android/iOS build tools, emulator helpers
- Backend: Firebase tools, API testing, emulator management

Would you like me to:
1. Add more project types (e.g., Python backend, Flutter mobile)?
2. Expand the deployment configurations?
3. Add more development tools to any of these templates?

