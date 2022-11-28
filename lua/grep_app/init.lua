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
  local query = utils.get_current_line()
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
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview)
      end,
    },
    finder = finders.new_table {
      results = results,
      entry_maker = function(result)
        return {
          value = result,
          display = result.lines[1].code,
          ordinal = result.lines[1].code,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
  }):find()
end

-- to execute the function
return grepapp
