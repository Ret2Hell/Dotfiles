# Dotfiles

A collection of personal configuration files for a modern Linux development environment.

## 📖 Overview

This repository contains my personal dotfiles and configuration settings for various tools and applications I use daily for development and productivity.

## 🛠️ What's Included

### Shell Configuration
- **Zsh** with Oh My Zsh framework
- **Starship** prompt with Catppuccin Mocha theme
- Useful aliases for enhanced productivity
- Multiple Oh My Zsh plugins for improved workflow

### Terminal
- **Ghostty** terminal configuration
- Catppuccin Mocha color scheme
- FiraCode Nerd Font with optimized settings
- Transparency and blur effects

### Key Features
- 🎨 **Consistent theming** across all applications (Catppuccin Mocha)
- ⚡ **Performance optimized** shell with modern tools
- 🔧 **Developer-friendly** aliases and shortcuts
- 📦 **Plugin management** for enhanced functionality

## 🚀 Tools & Applications

### Shell & Terminal
- **Zsh** - Primary shell
- **Oh My Zsh** - Zsh framework
- **Starship** - Cross-shell prompt
- **Ghostty** - Modern terminal emulator

### CLI Tools & Utilities
- **eza** - Modern replacement for `ls`
- **bat** - Syntax highlighting for `cat`
- **zoxide** - Smarter `cd` command
- **fzf** - Fuzzy finder
- **ripgrep** - Fast text search
- **trash-put** - Safe file deletion

### Development Tools
- **NVM** - Node.js version manager
- **Bun** - JavaScript runtime and toolkit
- **Docker** & **Docker Compose**
- **Terraform** - Infrastructure as code
- **Azure CLI** - Azure cloud tools
- **Neovim** - Text editor

## 🎨 Theme

All configurations use the **Catppuccin Mocha** color scheme for a consistent and pleasing visual experience across all applications.

## 📋 Zsh Plugins

The configuration includes the following Oh My Zsh plugins:
- `git` - Git aliases and functions
- `fzf` - Fuzzy finder integration
- `fzf-tab` - Enhanced tab completion
- `zsh-syntax-highlighting` - Command syntax highlighting
- `zsh-autosuggestions` - Command autosuggestions
- `docker` & `docker-compose` - Docker shortcuts
- `bun` - Bun.js integration
- `ssh` - SSH helper functions
- `branch` - Git branch utilities
- `git-auto-fetch` - Automatic git fetching
- `nvm` - Node Version Manager
- `npm` - NPM shortcuts
- `terraform` - Terraform completion
- `azure` - Azure CLI integration

## ⚡ Useful Aliases

```bash
alias ls="eza --icons -G"          # Enhanced file listing
alias update="sudo apt update && sudo apt upgrade -y"  # System update
alias cat="batcat"                 # Syntax highlighted cat
alias cd="z"                       # Smart directory jumping
alias grep="rg"                    # Fast text search
alias rm="trash-put"               # Safe file deletion
```

## 🏗️ Installation

### Prerequisites
Make sure you have the following installed:
- Git
- Zsh
- Oh My Zsh
- Required fonts (FiraCode Nerd Font)

### Quick Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Ret2Hell/Dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Install dependencies:**
   ```bash
   # Install Oh My Zsh (if not already installed)
   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   
   # Install Starship
   curl -sS https://starship.rs/install.sh | sh
   
   # Install zsh plugins
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
   ```

3. **Create symbolic links:**
   ```bash
   # Backup existing configs
   mv ~/.zshrc ~/.zshrc.backup 2>/dev/null || true
   mv ~/.config/starship.toml ~/.config/starship.toml.backup 2>/dev/null || true
   mv ~/.config/ghostty ~/.config/ghostty.backup 2>/dev/null || true
   
   # Create symlinks
   ln -sf ~/.dotfiles/.zshrc ~/.zshrc
   ln -sf ~/.dotfiles/.config/starship.toml ~/.config/starship.toml
   ln -sf ~/.dotfiles/.config/ghostty ~/.config/ghostty
   ```

4. **Install additional tools:**
   ```bash
   # Install modern CLI tools
   sudo apt update
   sudo apt install -y eza bat ripgrep trash-cli zoxide fzf
   ```

5. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

## 🔧 Customization

Feel free to modify any configuration files to suit your preferences:

- **Shell aliases**: Edit `.zshrc`
- **Prompt appearance**: Modify `.config/starship.toml`
- **Terminal settings**: Adjust `.config/ghostty/config`

## 📝 Notes

- The configuration assumes a Linux environment (specifically Ubuntu/Debian)
- Make sure to install the FiraCode Nerd Font for proper icon display
- Some tools may require additional setup (NVM, Bun, etc.)

## 🤝 Contributing

If you have suggestions for improvements or find any issues, feel free to open an issue or submit a pull request!