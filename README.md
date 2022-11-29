> Work in progress

## What it does

This is a telescope extension for grabing code from https://grep.app directly from neovim. You can then view it in a temporary buffer.


## Dependencies

[plenary](https://github.com/nvim-lua/plenary.nvim)

## Install

```vim
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'matheusfillipe/grep_app.nvim'
```

## Example config

Add to your init.vim:

```vim
lua << EOF
  require('telescope').load_extension('grep_app')
EOF
nnoremap <space>ga <cmd>Telescope grep_app<cr>
vnoremap <space>ga <cmd>Telescope grep_app<cr>
```

Then `<space>ga` will search for your current line in grep.app
