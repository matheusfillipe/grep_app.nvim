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

local function create_raw_buffer(opts, result)
  local raw_url = result.raw_url
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
  vim.api.nvim_buf_set_option(bufnr, "filetype", opts.ftype)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")

  local lnum = result.main_line.lnum
  vim.api.nvim_win_set_cursor(0, {lnum, 0})
end

local paste = function(opts, result)
  -- Paste result.main_line.code into current buffer
  local code = result.main_line.code
  vim.api.nvim_put({code}, "l", true, true)
end

local open_browser = function(opts, result)
  local url = result.main_line.url
  -- open using xdg-open if on linux and open if on mac and start if on windows
  if vim.fn.has("mac") == 1 then
    vim.fn.system("open " .. url)
  elseif vim.fn.has("unix") == 1 then
    vim.fn.system("xdg-open " .. url)
  elseif vim.fn.has("win32") == 1 then
    vim.fn.system("start " .. url)
  else
    print("Unsupported OS")
    print(url)
  end
end

local action_picker = function(opts, result)
  pickers.new(opts, {
    title = "Choose an action",
    prompt_title = "What to do?",
    finder = finders.new_table {
      results = {
        {value = "Open raw buffer", action = create_raw_buffer},
        {value = "Paste line", action = paste},
        {value = "Open repo in browser", action = open_browser}
      },
      entry_maker = function(this_result)
        return {
          result = result,
          value = this_result.value,
          action = this_result.action,
          display = this_result.value,
          ordinal = this_result.value
        }
      end
    },
    sorter = conf.generic_sorter(opts),

    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action = action_state.get_selected_entry().action
        local this_result = action_state.get_selected_entry().result.value
        action(opts, this_result)
    end)
    return true
  end
  }):find()
end

local lang_repeat_picker = function(opts, languages)
  pickers.new(opts, {
    title = "The language you want to search",
    prompt_title = "Languages",
    finder = finders.new_table {
      results = languages,
    },
    sorter = conf.generic_sorter(opts),

    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        opts.lang = action_state.get_selected_entry().value
        grepapp.picker(opts)
    end)
    return true
  end
  }):find()
end

grepapp.picker = function(opts)
  local ftype = opts.ftype or vim.bo.filetype
  opts.ftype = ftype
  local max_results = opts.max_results or 20
  opts.max_results = max_results
  local lang = opts.lang or language_map[ftype]
  local api_params = {
    words = opts.words or true,
    case = opts.case or false,
    regexp = opts.regex or false,
    lang = lang
  }

  for k, v in pairs(opts) do
    opts[k] = v
  end
  for k, v in pairs(api_params) do
    opts[k] = v
  end

  local query
  if opts.search_query then
    query = opts.search_query
  elseif opts.search then
    query = opts.search
  else
    query = utils.get_current_line()
  end
  local results, lang_suggestions = grepclient.Grep(query, api_params, max_results)

  if #results == 0 then
    if #lang_suggestions > 0 then
      print("No results found for that language! Try another one")
      lang_repeat_picker(opts, lang_suggestions)
    end
    print("No results found!")
    return
  end

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
          display = result.repo..": "..result.main_line.code,
          ordinal = result.main_line.code,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        action_picker(opts, action_state.get_selected_entry())
    end)
    return true
  end
  }):find()
end

grepapp.live_picker = function(opts)
  print("Live grep is not supported yet")
end

-- to execute the function
return grepapp
