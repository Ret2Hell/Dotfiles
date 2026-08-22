# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'ask'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Move prompt to the bottom when zsh starts and on Ctrl+L.
zstyle ':z4h:' prompt-at-bottom 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'
# End-of-line accepts the suggestion one line at a time ('partial-accept')
# instead of the whole thing at once.
zstyle ':z4h:autosuggestions' end-of-line  partial-accept

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'yes'
# Accept the current selection with Tab and immediately re-open fzf.
zstyle ':z4h:fzf-complete'    fzf-bindings tab:repeat
zstyle ':z4h:cd-down'         fzf-bindings tab:repeat
zstyle ':z4h:fzf-dir-history' fzf-bindings tab:repeat
# Highlight fzf matches in blue instead of the default pink.
zstyle ':z4h:*' fzf-flags --color=hl:5,hl+:5

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Export environment variables.
export GPG_TTY=$TTY

# Copy the current command line to the clipboard (requires wl-clipboard).
function z4h-copy-buffer() {
  emulate -L zsh
  print -rn -- "$BUFFER" | command wl-copy 2>/dev/null || return 1
  zle reset-prompt
}
zle -N z4h-copy-buffer

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-copy-buffer Ctrl+O

# Autoload functions.
autoload -Uz zmv

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt auto_menu     # press TAB for the second time when the first TAB inserts an unambiguous prefix

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load personal shell configuration (aliases, functions, environment, tool init)
z4h source $HOME/.config/zsh/all
