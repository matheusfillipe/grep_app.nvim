> Work in progress

## What it does

This is a telescope extension for grabing code from https://grep.app directly from neovim. You can then view it in a temporary buffer.


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

# Recommended keymaps
nnoremap <space>ga <cmd>Telescope grep_app<cr>
nnoremap <space>gz <cmd>Telescope grep_app live<cr>
vnoremap <space>ga "zy:Telescope grep_app search_query=<C-r>z<cr>
nnoremap <space>gol <cmd>Telescope grep_app open_line<cr>
vnoremap <space>gol <esc><cmd>Telescope grep_app open_line<cr>
nnoremap <space>gor <cmd>Telescope grep_app open_repo<cr>
nnoremap <space>gcl <cmd>Telescope grep_app copy_line_url<cr>
nnoremap <space>gcr <cmd>Telescope grep_app copy_repo_url<cr>
vnoremap <space>gcl <esc><cmd>Telescope grep_app copy_line_url visual=true<cr>
```

Then `<space>ga` will search for your current line in grep.app

## Usage

### Grep commands

There are two main commands: `grep_app` and `grep_app live`. You invoke them as:
```vim
:Telescope grep_app [arg=value...]
:Telescope grep_app live [arg=value...]
```

Currently the commands supports the following parameters:

* `search=<text>` Search query. Defaults to current line. In grep live it becomes the default prompt.

* `lang=<text>` override language in github format. Example: `lang=Python`. Defaults to the current buffer's language. check out `lua/grep_app/language_map.lua`

* `word=<bool>` Either true or false, defaults to true for matching entire words.

* `case=<bool>` If true case will be considered. Defaults to false.

* `regexp=<bool>` If true search query will be validated as regex. Defaults to false.

* `max_results=<int>` Max number of results to get from grep.app. Defaults to 20.

Notice that all those arguments can be either invoked in the command or passed as configuration. For example:

```lua
  require("telescope").setup({
    extensions = {
      grep_app = {
        --- Your options
        open_browser_cmd = "chrome"
        max_results = 5
      }
    },
  })
```

## Extras
These were only tested for github.

### Browser commands
These subcommands will open in the default browser.

* `open_repo`: Opens current repository in browser.
* `open_line`: Open current file/branch/line in broweser. You can set `branch=` into the command to set a default branch name.

Example: `:Telescope grep_app open_line`


### URL commands

These commands will copy to the `+` register.

* `copy_repo_url`: Simply copies this repo's url
* `copy_line_url`: Copies the web url for the current line or range if `visual=true`. You can also set `branch=<name>` to set a default branch.


## Configuration

All of the arguments mentioned above can have their defaults changed like:

```lua
require("telescope").setup({
extensions = {
  grep_app = {
    word = false,
    regexp = true,
    max_results = 50,
  }
},
})
require('telescope').load_extension('grep_app')
```

## TODO

- [ ] live grep.app prompt updating in real time. `grep_app live` 
   - Fix laggyness (monothread)
- [ ] Auto completion for args/subcommands
- [x] Clone result repo
