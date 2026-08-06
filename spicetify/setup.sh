#!/bin/sh
set -e

# Replicate this machine's spicetify setup on a fresh Arch machine.
# Assumes: Arch Linux, git, stow, curl, unzip, and an AUR helper (yay).
# Assumes ~/dotfiles is already cloned on this machine.

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
SPICETIFY_CONFIG="$HOME/.config/spicetify"
THEMES_COMMIT="08ce8dc"

echo "==> Installing spotify + spicetify-cli (AUR)"
yay -S --needed spotify spicetify-cli

echo "==> Giving spicetify write access to Spotify"
sudo chmod a+rwX /opt/spotify/Apps

if [ ! -d "$SPICETIFY_CONFIG/Themes/.git" ]; then
    echo "==> Cloning spicetify-themes (Sleek + TokyoNight live here)"
    mkdir -p "$SPICETIFY_CONFIG"
    git clone https://github.com/spicetify/spicetify-themes.git "$SPICETIFY_CONFIG/Themes"
    git -C "$SPICETIFY_CONFIG/Themes" checkout "$THEMES_COMMIT"
fi

echo "==> Stowing dotfiles spicetify package"
stow -d "$DOTFILES" -t "$HOME" spicetify --ignore=setup.sh

echo "==> Fixing prefs_path for this user"
sed -i "s|/home/ret2hell|$HOME|g" "$SPICETIFY_CONFIG/config-xpui.ini"

if [ ! -d "$SPICETIFY_CONFIG/CustomApps/marketplace" ]; then
    echo "==> Installing Marketplace"
    RELEASES_URI="https://github.com/spicetify/marketplace/releases"
    TAG=$(curl -LsH 'Accept: application/json' "$RELEASES_URI/latest")
    TAG=${TAG%\,\"update_url*}
    TAG=${TAG##*tag_name\":\"}
    TAG=${TAG%\"}
    mkdir -p "$SPICETIFY_CONFIG/CustomApps"
    curl --fail -L -o "$SPICETIFY_CONFIG/CustomApps/marketplace-dist.zip" "$RELEASES_URI/download/v$TAG/marketplace.zip"
    unzip -q -o "$SPICETIFY_CONFIG/CustomApps/marketplace-dist.zip" -d "$SPICETIFY_CONFIG/CustomApps/marketplace-tmp"
    mv "$SPICETIFY_CONFIG/CustomApps/marketplace-tmp/marketplace-dist" "$SPICETIFY_CONFIG/CustomApps/marketplace"
    rm -rf "$SPICETIFY_CONFIG/CustomApps/marketplace-tmp" "$SPICETIFY_CONFIG/CustomApps/marketplace-dist.zip"
fi

echo "==> Backing up and applying"
spicetify backup
spicetify apply

echo "Done. Open Spotify and check the sidebar for Marketplace and Lyrics Plus."
