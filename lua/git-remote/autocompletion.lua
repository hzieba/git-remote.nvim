---Guidelines for autocompletion
---https://github.com/nvim-neorocks/nvim-best-practices?tab=readme-ov-file#white_check_mark-do-1

---@class GitRemoteSubcommands
---@field impl fun(args: string[]) The subcommand implementation
---@field complete? fun(subcmd_arg_lead: string): string[] Command completions callback

local M = {}

---Register subcommands
---@param subcommand_tbl table<string, GitRemoteSubcommands>
function M.setup(subcommand_tbl)
	---@param opts table :h lua-guide-commands-create
	local function GitRemote(opts)
		local fargs = opts.fargs
		local subcommand_key = fargs[1]
		local subcommand = subcommand_tbl[subcommand_key]
		local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
		if not subcommand then
			vim.notify("GitRemote: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
			return
		end

		subcommand.impl(args)
	end

	---Register command and configure autocompletion
	vim.api.nvim_create_user_command("GitRemote", GitRemote, {
		nargs = "+",
		desc = "Manage your remote repository from Neovim",
		complete = function(arg_lead, cmdline, _)
			-- Get the subcommand.
			local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*GitRemote[!]*%s(%S+)%s(.*)$")
			if
				subcmd_key
				and subcmd_arg_lead
				and subcommand_tbl[subcmd_key]
				and subcommand_tbl[subcmd_key].complete
			then
				return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
			end

			-- Check if cmdline is a subcommand
			if cmdline:match("^['<,'>]*GitRemote[!]*%s+%w*$") then
				-- Filter subcommands that match
				local subcommand_keys = vim.tbl_keys(subcommand_tbl)
				return vim.iter(subcommand_keys)
					:filter(function(key)
						return key:find(arg_lead) ~= nil
					end)
					:totable()
			end
		end,
		bang = true, -- If you want to support ! modifiers
	})
end

return M
