# Zeen Nvim
[Zeen Programming Language](https://github.com/mealet/zeen) support for Neovim.

## Installation
Make sure you have installed `zeen` and `zeen-lsp` binaries from the latest release.

### Lazy
```lua
return {
  "mealet/zeen-nvim"
}
```

With settings:
```lua
return {
    "mealet/zeen-nvim",
    opts = {
        cmd = { "zeen-lsp" },
        root_markers = { ".git" },
        inlay_hints = true,
    },
    config = function(_, opts)
        require("zeen-lsp").setup(opts)
    end,
}
```

### Packer
```lua
use({
    "mealet/zeen-nvim",
    config = function()
        require("zeen-lsp").setup()
    end,
})
```

### Vim-plug
```
Plug 'mealet/zeen-nvim'
require("zeen-lsp").setup()
```
