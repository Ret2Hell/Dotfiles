-- Status bar

-- Show the hovered symlink's target.
Status:children_add(function(self)
	local hovered = self._current.hovered
	if hovered and hovered.link_to then
		return " -> " .. tostring(hovered.link_to)
	end
	return ""
end, 3300, Status.LEFT)

-- Show the hovered file's owner and group on Unix.
Status:children_add(function()
	local hovered = cx.active.current.hovered
	if not hovered or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line({
		ui.Span(ya.user_name(hovered.cha.uid) or tostring(hovered.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(hovered.cha.gid) or tostring(hovered.cha.gid)):fg("magenta"),
		" ",
	})
end, 500, Status.RIGHT)

-- Plugins
require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})

require("full-border"):setup({
	type = ui.Border.PLAIN,
})

require("recycle-bin"):setup()
