#!/bin/bash

# Dotfiles Sync Script
# Automatically syncs configuration files to the dotfiles repository and pushes to GitHub

set -e  # Exit on any error

# Configuration
DOTFILES_DIR="$HOME/Dev/Dotfiles"
COMMIT_MESSAGE_PREFIX="Auto-sync dotfiles"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the dotfiles directory
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
    error "Dotfiles directory not found or not a git repository: $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# Function to copy file if it exists and has changed
sync_file() {
    local source="$1"
    local dest="$2"
    local desc="$3"
    
    if [[ -f "$source" ]]; then
        # Create destination directory if it doesn't exist
        mkdir -p "$(dirname "$dest")"
        
        # Check if file has changed
        if [[ ! -f "$dest" ]] || ! cmp -s "$source" "$dest"; then
            cp "$source" "$dest"
            success "Synced $desc: $source → $dest"
            return 0
        else
            log "No changes in $desc"
            return 1
        fi
    else
        warning "$desc not found: $source"
        return 1
    fi
}

# Main sync function
sync_dotfiles() {
    log "Starting dotfiles sync..."
    
    local changes_made=false
    
    # Sync Zsh configuration
    if sync_file "$HOME/.zshrc" "$DOTFILES_DIR/.zshrc" "Zsh configuration"; then
        changes_made=true
    fi
    
    # Sync Starship configuration
    if sync_file "$HOME/.config/starship.toml" "$DOTFILES_DIR/.config/starship.toml" "Starship configuration"; then
        changes_made=true
    fi
    
    # Sync Ghostty configuration
    if sync_file "$HOME/.config/ghostty/config" "$DOTFILES_DIR/.config/ghostty/config" "Ghostty configuration"; then
        changes_made=true
    fi
    
    # Add more configuration files here as needed
    
    if [[ "$changes_made" == true ]]; then
        success "Configuration files synced successfully!"
        return 0
    else
        log "No changes detected in any configuration files"
        return 1
    fi
}

# Function to commit and push changes
commit_and_push() {
    log "Checking for git changes..."
    
    # Check if there are any changes
    if git diff --quiet && git diff --cached --quiet; then
        log "No git changes to commit"
        return 0
    fi
    
    # Stage all changes
    git add .
    
    # Create commit message
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local commit_msg="$COMMIT_MESSAGE_PREFIX - $timestamp"
    
    # Get list of changed files for better commit message
    local changed_files=$(git diff --cached --name-only | tr '\n' ' ')
    if [[ -n "$changed_files" ]]; then
        commit_msg="$commit_msg

Changed files: $changed_files"
    fi
    
    # Commit changes
    log "Committing changes..."
    git commit -m "$commit_msg"
    success "Changes committed: $commit_msg"
    
    # Push to GitHub
    log "Pushing to GitHub..."
    if git push origin main; then
        success "Successfully pushed to GitHub!"
    else
        error "Failed to push to GitHub"
        return 1
    fi
}

# Main execution
log "=== Dotfiles Auto-Sync Started ==="

if sync_dotfiles; then
    commit_and_push
fi

log "=== Dotfiles Auto-Sync Completed ==="
