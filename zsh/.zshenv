# Minimal wrapper: all zsh config lives in ~/.config/zsh (ZDOTDIR).
# The actual z4h bootstrap is sourced from $ZDOTDIR/.zshenv.
export ZDOTDIR="$HOME/.config/zsh"
[[ -f "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"
