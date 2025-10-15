# Home Manager Configuration Architecture

## Overview

This Home Manager configuration is designed to separate concerns between:
1. System configuration (managed by Home Manager)
2. State management (handled by specialized tools)
3. Dotfile management (managed by chezmoi)

## Directory Structure

```
~/.config/home-manager/
├── home.nix                # Main configuration entry point
├── lib/                    # Shared Nix functions
│   └── default.nix        # Helper functions for projects and state management
├── modules/               # Custom modules
│   └── chezmoi.nix       # Chezmoi integration
├── state-management/      # State management modules
│   └── aws.nix           # AWS profile management
├── programs/              # Program-specific configurations
│   ├── neovim.nix
│   └── vscode.nix
└── projects/             # Project-specific configurations
    └── prs.nix          # PRS project configuration
```

## Key Components

### 1. State Management
- State (like AWS profiles) is managed outside of Home Manager
- Uses specialized scripts in ~/.local/bin/
- Configuration lives in appropriate config files (~/.aws/credentials)
- Switching between states is handled by shell functions

### 2. Chezmoi Integration
- Manages dotfiles and personal configurations
- Handles files that should not be managed by Home Manager
- Provides version control and synchronization
- Configuration: ~/.config/chezmoi/chezmoi.toml

### 3. Project Management
Projects focus on:
- Package dependencies
- Development tools
- Project-specific aliases and functions
- NOT state management or credentials

## Usage Examples

### AWS Profile Management
```bash
# List available profiles
aws-profile

# Switch to a specific profile
aws-profile myproject-dev
```

### Project Setup
```bash
# Using a project configuration
home-manager switch

# Project-specific development environment
cd ~/projects/myproject
direnv allow  # If using .envrc
```

### State Management
- Credentials: Managed by chezmoi (~/.aws/, ~/.ssh/)
- Local state: Managed by project-specific tools
- Environment variables: Managed by direnv

## Persistence

1. Home Manager State:
   - Packages: ~/.nix-profile/
   - Configurations: ~/.config/
   - Generation state: ~/.local/state/home-manager/

2. User State:
   - Dotfiles: Managed by chezmoi
   - Credentials: Managed by chezmoi (encrypted when needed)
   - Project state: Managed by project-specific tools

3. Environment State:
   - Session variables: Set by ~/.profile
   - Project variables: Managed by direnv
   - AWS profiles: Managed by aws-profile script

## Adding New Components

### New Project
1. Create project configuration in projects/
2. Define required packages and tools
3. Add project-specific functions
4. Import in home.nix

### New State Management
1. Create module in state-management/
2. Define state handling functions
3. Create appropriate scripts
4. Import in home.nix

## Best Practices

1. State Management:
   - Keep state out of Home Manager
   - Use appropriate tools for state
   - Document state locations

2. Project Configuration:
   - Focus on development environment
   - Use direnv for project-specific vars
   - Keep credentials separate

3. Tool Integration:
   - Use chezmoi for dotfiles
   - Use direnv for local env
   - Use Home Manager for packages

4. Security:
   - Never store credentials in Home Manager
   - Use chezmoi templates for sensitive data
   - Keep AWS credentials in ~/.aws/credentials
