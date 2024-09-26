local M = {}

function M.setup(opts)
	print("Hello")
	require("git-remote.init").setup(opts)
end

return M
