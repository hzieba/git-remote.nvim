local M = {}

---@param s string
---@return string
function M.trim(s)
	return s:match("^%s*(.-)%s*$")
end

---@param url string
function M.open_browser(url)
	vim.fn.system(string.format("open %s", url))
end

---@param s string
---@param tab any
---@return string
function M.interpolate(s, tab)
	return (s:gsub("($%b{})", function(w)
		return tab[w:sub(3, -2)] or w
	end))
end

---@return string
function M.get_current_file()
	return vim.fn.expand("%:.")
end

---@return any
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

	return { row1, row2 }
end

return M
