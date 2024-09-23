local utils = require("git-remote.utils")
local git = require("git-remote.git")
local wk = require("which-key")
local icons = require("mini.icons")

---@param with_lines boolean
local function open_file_on_remote(with_lines)
	local current_file = utils.get_current_file()
	local lines
	if with_lines then
		lines = utils.get_selected_lines()
	end

	local success, data = pcall(git.get_remote_file_url, current_file, lines)

	if not success then
		local message
		if data == Exceptions.GIT_REPO_NOT_FOUND then
			message = "This is not a Git repository."
		elseif data == Exceptions.UNSUPPORTED_REMOTE then
			message = "Unknown remote, only Github and Gitlab are currently supported."
		else
			message = "Unknown error: " + data
		end

		vim.notify(message, vim.log.levels.ERROR)
		return
	end

	utils.open_browser(data)
end

vim.api.nvim_create_user_command("OpenFileOnRemote", function()
	open_file_on_remote(false)
end, {})
vim.api.nvim_create_user_command("OpenFileOnRemoteWithLines", function()
	open_file_on_remote(true)
end, {})

wk.add({
	{
		"<leader>go",
		"<cmd>OpenFileOnRemote<cr>",
		icon = { icon = icons.get("filetype", "git"), color = "orange" },
		desc = "Open file on remote",
		mode = { "n", "v" },
	},
})
wk.add({
	{
		"<leader>gO",
		"<cmd>OpenFileOnRemoteWithLines<cr>",
		icon = { icon = icons.get("filetype", "git"), color = "orange" },
		desc = "Open file on remote with selected lines",
		mode = { "n", "v" },
	},
})
