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
vnoremap <space>ga "zy:Telescope grep_app search=<C-r>z<cr>
nnoremap <space>gz <cmd>Telescope grep_app_live<cr>
```

Then `<space>ga` will search for your current line in grep.app

## Usage

There are two commands: `grep_app` and `grep_app live`. You invoke them as:
```vim
:Telescope grep_app [arg=value...]
:Telescope grep_app live [arg=value...]
```

Currently the commands supports the following parameters:

* `search=[text]` Search query. Defaults to current line. In grep live it becomes the default prompt.

* `lang=[text]` override language in github format. Example: `lang=Python`. Defaults to the current buffer's language. check out `lua/grep_app/language_map.lua`

* `word=[bool]` Either true or false, defaults to true for matching entire words.

* `case=[bool]` If true case will be considered. Defaults to false.

* `regexp=[bool]` If true search query will be validated as regex. Defaults to false.


## TODO

- [ ] live grep.app prompt updating in real time. `grep_app live`
