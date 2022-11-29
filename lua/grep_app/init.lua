local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local previewers = require "telescope.previewers"

local grepclient = require("grep_app.client")
local utils = require("grep_app.utils")
local language_map = require("grep_app.language_map")


local grepapp = {}
grepapp.picker = function(opts)
  local ftype = opts.ftype or vim.bo.filetype
  local lang = language_map[ftype]
  local params = {words = true, case = false, regexp = true, lang = lang}
  local mode = opts.grep_app_mode

  local query
  if opts.search_query then
    query = opts.search_query
  else
    query = utils.get_current_line()
  end
  print(query)
  local results, lang_suggestions = grepclient.Grep(query, params)

  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "grep.app",
    previewer = previewers.new_buffer_previewer {
      dyn_title = function(_, entry)
        return entry.value.raw_url
      end,
      define_preview = function (self, entry, status)
        local preview = {}
        for _,line in pairs(entry.value.lines) do
          table.insert(preview, line.code)
        end
        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", ftype)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview)
      end,
    },
    finder = finders.new_table {
      results = results,
      entry_maker = function(result)
        return {
          value = result,
          display = result.repo..": "..result.lines[1].code,
          ordinal = result.lines[1].code,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local raw_url = entry.value.raw_url
        local code = grepclient.Code_from_url(raw_url)
        -- Create a new buffer with that code
        local bufnr = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_set_current_buf(bufnr)
        local lines = {}
        for line in code:gmatch("([^\n]*)\n?") do
          table.insert(lines, line)
        end
        vim.api.nvim_buf_set_text(bufnr, 0, 0, 0, 0, lines)
        -- switch to new buffer
        vim.api.nvim_buf_set_option(bufnr, "filetype", ftype)
        vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")

        local lnum = entry.value.lines[1].lnum
        vim.api.nvim_win_set_cursor(0, {lnum, 0})
    end)
    return true
  end
  }):find()
end

-- to execute the function
return grepapp
