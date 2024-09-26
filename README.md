# git-remote.nvim

Tool for managing remote repositories.

## Instalation

Using `lazy.vim`

```lua
{
  "hzieba/git-remote.nvim",
  opts = {}
}
```

### Options

Defaults should work for:

* Github and Gitlab repositories
* For Linux and MacOS

```lua
opts = {
  -- Description how to generate links
  link_templates = {
    -- Example configuration for Github
    {
      -- Regex compared with remote repository URL to determine what syntax does it use
      "^https?://[^/]*gitlab[^/]*/.*$",
      -- Description how to generate file link from remote URL, reference to commit (branch) and path to file
      "${base_url}/-/blob/${ref}/${filepath}" },
    },
  },
  -- Set of commands for opening a browser
  browser = {
    "xdg-open", -- Open default browser (Linux)
    "open", -- Open default browser (MacOS)
  },
}
```

## Keymaps

| Mode     | Keymap       | Function                                                         |
|----------|--------------|------------------------------------------------------------------|
| `n`, `v` | `<leader>go` | Open current file on remote in browser.                          |
| `n`, `v` | `<leader>gO` | Open current file on remote in browser (include selected lines). |

See `GitRemote` for all commands.

## TODO

* Refactor keymaps configuration
