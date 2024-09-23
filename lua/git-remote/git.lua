local utils = require("git-remote.utils")

local M = {}

Exceptions = {
	GIT_REPO_NOT_FOUND = {},
	UNSUPPORTED_REMOTE = {},
}

---@return boolean
function M.is_git_repositor()
	return utils.trim(vim.fn.system('git rev-parse --is-inside-work-tree 2> /dev/null || echo "false"')) == "true"
end

---@param cmd string
---@return string
local function exec_git(cmd)
	if not M.is_git_repositor() then
		error(Exceptions.GIT_REPO_NOT_FOUND)
	end
	return utils.trim(vim.fn.system(string.format("git %s", cmd)))
end

---@return string
function M.get_remote()
	return exec_git("remote")
end

---@param remote string
---@return string
function M.get_remote_url(remote)
	local url = exec_git(string.format("remote get-url %s", remote))
	return url
end

---@param url string
---@return string
local function parse_remote_url(url)
	url = url:gsub(":([^/])", "/%1")
	url = url:gsub("ssh://", "")
	url = url:gsub("git@", "https://")
	url = url:gsub("%.git$", "")
	return url
end

---@return string
function M.get_repo_url()
	local remote = M.get_remote()
	local remote_url = M.get_remote_url(remote)
	local url = parse_remote_url(remote_url)
	return url
end

---@return string
function M.get_branch_or_commit()
	local branch = exec_git("branch --show-current")
	local commit = exec_git("rev-parse HEAD")
	return branch ~= "" and branch or commit
end

---@param url string
---@return string
local function get_file_url_format(url)
	if url:find("gitlab") then
		return "${base_url}/-/blob/${ref}/${filepath}"
	elseif url:find("github") then
		return "${base_url}/blob/${ref}/${filepath}"
	else
		error(Exceptions.UNSUPPORTED_REMOTE)
	end
end

---@param file string
---@param lines any?
---@return string
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
