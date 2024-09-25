local utils = require("git-remote.utils")
local git = require("git-remote.git")
local wk = require("which-key")
local icons = require("mini.icons")
local autocompletion = require("git-remote.autocompletion")

---Open current file in remote repository
---@param with_selection boolean? Whether or not to include selection in the link
local function open_file_on_remote(with_selection)
	local current_file = utils.get_current_file()
	local lines = nil
	if with_selection then
		lines = { utils.get_selected_lines() }
	end

	local success, err = pcall(function()
		local url = git.get_remote_file_url(current_file, lines)
		utils.open_browser(url)
	end)

	if not success then
		vim.notify(string.format("%s", err), vim.log.levels.ERROR)
	end
end

---Possible flags
local FLAGS = {
	WITH_SELECTION = "--with-selection",
}

---Subcommands implementation
---@type table<string, GitRemoteSubcommands>
local subcommand_tbl = {
	OpenCurrent = {
		impl = function(args)
			local with_selection = utils.contains(args, FLAGS.WITH_SELECTION)
			open_file_on_remote(with_selection)
		end,
		complete = function(subcmd_arg_lead)
			local install_args = {
				FLAGS.WITH_SELECTION,
			}
			return vim.iter(install_args)
				:filter(function(install_arg)
					return install_arg:find(subcmd_arg_lead) ~= nil
				end)
				:totable()
		end,
	},
}

autocompletion.setup(subcommand_tbl)

wk.add({
	{
		"<leader>go",
		"<cmd>GitRemote OpenCurrent --with-selection<cr>",
		icon = { icon = icons.get("filetype", "git"), color = "orange" },
		desc = "Open current file on remote",
		mode = { "n", "v" },
	},
})
wk.add({
	{
		"<leader>gO",
		"<cmd>GitRemote OpenCurrent --with-selection<cr>",
		icon = { icon = icons.get("filetype", "git"), color = "orange" },
		desc = "Open current file on remote with selected lines",
		mode = { "n", "v" },
	},
})
