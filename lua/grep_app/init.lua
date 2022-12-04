local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"
local conf = require("telescope.config").values
local previewers = require "telescope.previewers"

local grepclient = require("grep_app.client")
local utils = require("grep_app.utils")
local language_map = require("grep_app.language_map")

local grepapp = {}
grepapp.config = {}


grepapp.setup = function(ext_config, _)
  -- ext_config overrides opts
  ext_config = ext_config or {}
  for k, v in pairs(ext_config) do
    grepapp.config[k] = v
  end
end

local make_previewer = function(opts)
  return previewers.new_buffer_previewer {
      dyn_title = function(_, entry)
        return entry.value.raw_url
      end,
      define_preview = function (self, entry, status)
        local preview = {}
        for _,line in pairs(entry.value.lines) do
          table.insert(preview, line.code)
        end
        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", opts.ftype)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview)
      end,
    }
end


local result_entry_maker = function(result)
  return {
    value = result,
    display = result.repo..": "..result.main_line.code,
    ordinal = result.main_line.code,
  }
end

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

local clone = function(opts, result)
  --- Clone the repo and open the file
  local repo = result.repo
  -- prompt for directory
  local dir = vim.fn.input("Clone to: ", vim.fn.getcwd().."/"..result.repo, "dir")
  -- clone repo
  local clone_cmd = "git clone "..result.clone_url.." "..dir
  local checkout_cmd = "git checkout "..result.branch
  local on_stderr = function(_, data, _)
    for _, line in pairs(data) do
      print(line)
    end
  end
  vim.fn.jobstart(clone_cmd, {
    on_stderr = on_stderr,
    on_exit = function(_, code)
      if code == 0 then
        -- Start job for checkign out branch
        vim.fn.jobstart(checkout_cmd, {
          on_stderr = on_stderr,
          on_exit = function(_, ccode)
            if ccode ~= 0 then
              print("Failed to checkout branch! Trying to open anyway.")
            end
              -- open file
              local file = result.main_line.path
              local path = dir.."/"..file
              vim.cmd("edit "..path)
              -- jump to line
              local lnum = result.main_line.lnum
              vim.api.nvim_win_set_cursor(0, {lnum, 0})
            end,
          cwd = dir
        })
      else
        print("Error cloning repo: "..result.clone_url.."  to "..dir)
      end
    end
  })
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
        {value = "Open raw in scratch buffer", action = create_raw_buffer},
        {value = "Paste line in current buffer", action = paste},
        {value = "Clone repo and open file", action = clone},
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

local parse_opts = function(opts)
  -- Command args override config
  for k, v in pairs(grepapp.config) do
    if opts[k] == nil then
      opts[k] = v
    end
  end

  local ftype = opts.ftype or vim.bo.filetype
  opts.ftype = ftype
  local max_results = opts.max_results or 20
  opts.max_results = max_results
  local lang = opts.lang or language_map[ftype]
  local api_params = {
    words = opts.words or false,
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

  return opts, api_params, query
end

grepapp.picker = function(opts)
  local _opts, api_params, query = parse_opts(opts)
  opts = _opts
  local results, lang_suggestions = grepclient.Grep(query, api_params, opts.max_results)

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
    previewer = make_previewer(opts),
    finder = finders.new_table {
      results = results,
      entry_maker = result_entry_maker
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
  local _opts, api_params, query = parse_opts(opts)
  opts = _opts

  local dyn_finder = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      query = prompt or query
      local results, lang_suggestions = grepclient.Grep(query, api_params, opts.max_results)
      return results
    end

  opts.entry_maker = result_entry_maker
  opts.fn = dyn_finder

  local live_grepper = finders.new_dynamic(opts)

  opts.sorting_strategy = "ascending"

  pickers.new(opts, {
    title = "Live grep.app",
    prompt_title = "Search",
    finder = live_grepper,
    previewer = make_previewer(opts),
    sorter = sorters.highlighter_only(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        action_picker(opts, action_state.get_selected_entry())
    end)
    return true
  end
  }):find()
end

-- to execute the function
return grepapp
