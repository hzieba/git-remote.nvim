---@alias url_regex string Compared with remote repository link.
---@alias link_template string Should contain "${base_url}", "${ref}" and "${filepath}" placeholders.
---@alias link_matchers [url_regex, link_template][]

---@alias command string Command for opening links.
---@alias browsers command[]

---Configuration for GitRemote plugin.
---@class opts
---List of link matcher used for generating files to specific files.
---The first match will be used for link creation.
---@field link_matchers? link_matchers
---List of command for opening links.
---First existing command from the list will be used to open link in the browser.
---@field browsers? browsers

---@type opts
local defaults = {
	link_matchers = {
		{ "^https?://[^/]*gitlab[^/]*/.*$", "${base_url}/-/blob/${ref}/${filepath}" },
		{ "^https?://[^/]*github[^/]*/.*$", "${base_url}/blob/${ref}/${filepath}" },
	},
	browsers = {
		"xdg-open",
		"open",
	},
}

---@class configuration
---@field vars opts
---@field setup function(opts?: config)
local M = {}

M.vars = defaults

---@param opts? opts
function M.setup(opts)
	opts = opts or {}
	M.vars = vim.tbl_deep_extend("force", M.vars, opts)
end

return M
