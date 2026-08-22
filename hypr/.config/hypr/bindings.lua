-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Replace the default Obsidian and Omawrite shortcuts.
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Omawrite", { launch = "omawrite" })

hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

hl.unbind("SUPER + SHIFT + ALT + G")

-- Remove Tmux shortcuts and move the Herdr launcher.
hl.unbind("SUPER + ALT + RETURN")
hl.unbind("SUPER + ALT + K")

hl.unbind("SUPER + CTRL + RETURN")
o.bind("SUPER + SHIFT + H", "Herdr", { omarchy = "terminal-herdr" })

-- Use terminal file manager and activity monitor shortcuts.
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { tui = "yazi" })

hl.unbind("SUPER + CTRL + T")
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })

-- Move Spotify to the former Google Maps shortcut.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Music", { omarchy = "spotify" })

hl.unbind("SUPER + SHIFT + M")

-- Make the default agent easier to launch.
hl.unbind("SUPER + SHIFT + CTRL + A")
o.bind("SUPER + A", "Agent", "omarchy-agent --pick")
