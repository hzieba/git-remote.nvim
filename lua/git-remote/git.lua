local utils = require("git-remote.utils")
local config = require("git-remote..config")

local M = {}

Exceptions = {
	GIT_REPO_NOT_FOUND = {},
	UNSUPPORTED_REMOTE = {},
}

---Check if current project is a Git repository.
---@return boolean
function M.is_git_repositor()
	return utils.trim(vim.fn.system('git rev-parse --is-inside-work-tree 2> /dev/null || echo "false"')) == "true"
end

---Execute git command.
---@param cmd string Command to be executed
---@return string result Result of git command
local function exec_git(cmd)
	if not M.is_git_repositor() then
		error("This is not a Git repository.", 0)
	end
	return utils.trim(vim.fn.system(string.format("git %s", cmd)))
end

---Get current remote name.
---@return string remote
function M.get_remote()
	return exec_git("remote")
end

---Get remote repository URL.
---@param remote string Remote name
---@return string url
function M.get_remote_url(remote)
	local url = exec_git(string.format("remote get-url %s", remote))
	return url
end

---Convert remote URL to repository link.
---@param url string Remote repostiory URL
---@return string Link to repository
local function parse_remote_url(url)
	url = url:gsub(":([^/])", "/%1")
	url = url:gsub("ssh://", "")
	url = url:gsub("git@", "https://")
	url = url:gsub("%.git$", "")
	return url
end

---Get repository link for current project.
---@return string link
function M.get_repo_url()
	local remote = M.get_remote()
	local remote_url = M.get_remote_url(remote)
	local url = parse_remote_url(remote_url)
	return url
end

---@alias branch string
---@alias commit string

---Get current branch name.
---If head is currently detached, returns current commit instead.
---@return branch|commit ref Branch or commit reference
function M.get_branch_or_commit()
	local branch = exec_git("branch --show-current")
	local commit = exec_git("rev-parse HEAD")
	return branch ~= "" and branch or commit
end

---Get template for link to specific file.
---The schema may vary depending on repository host (e.g. Gitlab or Github).
---@param url string Link to remote repoitory
---@return string template String template, it contains ${base_url} (repository base link), ${ref} (reference to commit) and ${filepath} (path to file) placeholders for interpolation
local function get_file_url_format(url)
	for _, e in ipairs(config.vars.link_matchers) do
		local regex, pattern = unpack(e)
		if url:match(regex) then
			return pattern
		end
	end
	error("Unknown remote, please consider adding matcher to plugin configuration.", 0)
end

---Get link to file on remote repository.
---@param file string Filepath
---@param lines [integer, integer]|nil Range of lines to be selected
---@return string link Link to file
M.get_remote_file_url = function(file, lines)
	local base_url = M.get_repo_url()
	local ref = M.get_branch_or_commit()
	local format = get_file_url_format(base_url)

	local url = utils.interpolate(format, { base_url = base_url, ref = ref, filepath = file })
	local lines_selector

	if lines == nil then
		lines_selector = ""
	elseif lines[1] == lines[2] then
		lines_selector = string.format("#L%d", lines[1])
	else
		lines_selector = string.format("#L%d-L%d", lines[1], lines[2])
	end

	return url .. lines_selector
end

return M
