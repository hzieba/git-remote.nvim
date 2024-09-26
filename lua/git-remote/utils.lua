local config = require("git-remote.config")

local M = {}

---Trim string.
---@param s string
---@return string
function M.trim(s)
	return s:match("^%s*(.-)%s*$")
end

---Check if array contains an element.
---@generic T: any
---@param table T[] Table to be scanned
---@param element T Element to be found
---@return boolean
function M.contains(table, element)
	for _, e in ipairs(table) do
		if e == element then
			return true
		end
	end
	return false
end

---Open link in a browser.
---@param url string
function M.open_browser(url)
	for _, cmd in ipairs(config.vars.browsers) do
		vim.fn.system(string.format("%s %s", cmd, url))
		if vim.v.shell_error == 0 then
			return
		end
	end
	error("Unable to find command for opening links.", 0)
end

---Interpolate string with variables.
---Use ${var_name} as a placeholders.
---
---E.g.
---> interpolate("Hello ${who}", { "who": "World! "}).
---< "Hello World!".
---@param s string String template
---@param tab { [string]: string } Dictionary with variable values
---@return string string Interpolated string
function M.interpolate(s, tab)
	return (s:gsub("($%b{})", function(w)
		return tab[w:sub(3, -2)] or w
	end))
end

---Get currently open file path.
---@return string path Path to file relative to project root
function M.get_current_file()
	return vim.fn.expand("%:.")
end

---Get range of currently selected lines.
---@return integer first First line of the selection
---@return integer last Last line of the selection
function M.get_selected_lines()
	local pos1 = vim.fn.getpos(".")
	local pos2 = vim.fn.getpos("v")

	local row1 = pos1[2]
	local row2 = pos2[2]

	if row1 > row2 then
		local tmp = row1
		row1 = row2
		row2 = tmp
	end

	return row1, row2
end

return M
