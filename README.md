# Work in progress

# What it does

Browse and grab code from https://grep.app directly from neovim.


# Dependencies

[plenary](https://github.com/nvim-lua/plenary.nvim)

```
luarocks install luasec --local
luarocks install luasocket --local
luarocks install lua-json --local
luarocks install htmlparser --local
eval "$(luarocks path)"
lua grepclient.lua
```
