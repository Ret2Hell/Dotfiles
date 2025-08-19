#!/bin/bash

# Simple Dotfiles Real-time Monitor
# Watches configuration files and automatically syncs when changes are detected

set -e

# Configuration
DOTFILES_DIR="$HOME/Dev/Dotfiles"
SYNC_SCRIPT="$DOTFILES_DIR/sync-dotfiles.sh"
DEBOUNCE_TIME=3  # seconds to wait before syncing after a change

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
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

# Files to monitor
WATCH_FILES=(
    "$HOME/.zshrc"
    "$HOME/.config/starship.toml"
    "$HOME/.config/ghostty/config"
)

# Check dependencies
if ! command -v inotifywait &> /dev/null; then
    error "inotifywait not found. Install with: sudo apt install inotify-tools"
    exit 1
fi

if [[ ! -x "$SYNC_SCRIPT" ]]; then
    error "Sync script not found: $SYNC_SCRIPT"
    exit 1
fi

# Debounced sync function
last_sync_time=0
sync_dotfiles() {
    local current_time=$(date +%s)
    local time_diff=$((current_time - last_sync_time))
    
    if [[ $time_diff -lt $DEBOUNCE_TIME ]]; then
        return 0
    fi
    
    log "Running dotfiles sync..."
    if "$SYNC_SCRIPT"; then
        success "Dotfiles synced and pushed to GitHub"
    else
        error "Sync failed"
    fi
    
    last_sync_time=$current_time
}

# Build watch arguments
watch_args=()
log "Monitoring files:"
for file in "${WATCH_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        watch_args+=("$file")
        log "  📁 $file"
    else
        warning "  ❌ $file (not found)"
    fi
done

if [[ ${#watch_args[@]} -eq 0 ]]; then
    error "No files to monitor"
    exit 1
fi

# Cleanup on exit
cleanup() {
    log "Stopping monitor..."
    exit 0
}
trap cleanup SIGINT SIGTERM

# Main monitoring loop
success "Real-time dotfiles monitor started"
log "Press Ctrl+C to stop"
echo ""

while true; do
    # Wait for file changes
    if file_changed=$(inotifywait -e modify -e move -e create --format '%w%f' "${watch_args[@]}" 2>/dev/null); then
        log "Change detected: $(basename "$file_changed")"
        
        # Small delay to ensure file write is complete
        sleep 1
        
        # Sync in background to avoid blocking
        sync_dotfiles &
    fi
done
