# chef-lsp-occurrence
##### Traverse identifier occurrences with accuracy and ease

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.8+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

## Why
Using vim's `*` / `#` actions for finding the next/prev occurrence of an identifier in the current code file is just not accurate.
It will find unwanted matches such as an identically named local variable in a different function, or maybe somthing like this thing: `myVar = "myVar"`.
A better approach is to go the next occurrence of the identifier under the cursor, with the code-wise definition of identifier (scope and all).

Fortunately, Neovim implements LSP (language server protocol) and supports document highlighting. The missing link is automatically calling document
highlighting for the identifier under cursor, and then supporting jump to next/prev LSP highlight.

## Installation
* First, configuring your LSP is required (as LSP is used for the highlighting groups). This can be done using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).
* Install using your favorite plugin manager. For example: install using [lazy.nvim](https://github.com/folke/lazy.nvim) (Simple approach)
```lua
require("lazy").setup({
    { "neovim/nvim-lspconfig" config = ... },
    { "frenchef156/chef-lsp-occurrence" }
})
```
* The actual recommended configuration (using [lazy.nvim](https://github.com/folke/lazy.nvim)):
```lua
require("lazy").setup({
    {
        "neovim/nvim-lspconfig",
        dependencies = { "frenchef156/chef-lsp-occurrence" },

        config = function()
            -- Add LSP configuration here

            -- Setup identifier highlighting and occurrence traversing
            local chefOccurrence = require("chefLspOccurrence")
            chefOccurrence.setup()
            vim.keymap.set("n", "<leader><C-n>", chefOccurrence.next)
            vim.keymap.set("n", "<leader><C-p>", chefOccurrence.prev)
            vim.o.updatetime = 500 -- Add this line to show highlighting faster
        end,
    }
})
```
