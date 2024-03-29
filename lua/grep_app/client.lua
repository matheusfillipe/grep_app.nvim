local curl = require("plenary.curl")
local json = require("grep_app.lib.json_lua.json")
local utils = require("grep_app.utils")

local API = 'https://grep.app/api/search'


local function get_htmlparser()
  local original_package_path = package.path
  local htmlparser_dir = utils.script_path().."lib/lua-htmlparser/src/?.lua"
  package.path = package.path .. ";" .. htmlparser_dir
  local htmlparser = require("grep_app.lib.lua-htmlparser.src.htmlparser")
  package.path = original_package_path
  return htmlparser
end


local function api_request(query, params, dry_run, custom_curl_cmd)
  params.q = query
  if params then
    for k, v in pairs(params) do
      if k == "lang" then
        params["f.lang"] = v
        params[k] = nil
      end
      params[k] = tostring(v)
    end
  end

  -- encode query
  local res = curl.request({method = "get", url = API, query = params, compressed = false, dry_run = dry_run})
  if dry_run then
    table.insert(res, 1, custom_curl_cmd or 'curl')
    return res
  end
  if res.status == 200 then
    return json.decode(res.body)
  else
      print('Error: '..res.status)
      print(res.body)
  end
end

local function get_results_and_langs(search_query, params, page)
  local results = {}
  params.page = page
  local api_response = api_request(search_query, params)
  if not api_response then
    return results, {}
  end
  local hits = api_response['hits']['hits']

  if hits then
    for i = 1, #hits do
      local match = hits[i]
      local snippet = match.content.snippet
      local htmlparser = get_htmlparser()
      local root = htmlparser.parse(snippet)
      local lineno = root('tr')
      local lines = {}
      local main_line
      local branch = ((match.branch or {}).raw or 'main')
      for _, e in ipairs(lineno) do
        local lnum = tonumber(e.attributes["data-line"])
        local line = utils.unescape_html(e('pre')[1]:textonly())
        local url = "https://github.com/" ..
            match.repo.raw.."/blob/" ..
            branch.."/"..match.path.raw ..
            "#L"..lnum

        line = {lnum = lnum, url = url, code = line, path = match.path.raw}
        table.insert(lines, line)

        if main_line == nil or e('mark') then
          main_line = line
        end
      end
      local raw_url = "https://raw.githubusercontent.com/" ..
      match.repo.raw.."/"..branch.."/"..match.path.raw
      table.insert(results, {
        lines = lines,
        raw_url = raw_url,
        repo = match.repo.raw,
        path = match.path.raw,
        branch = branch,
        main_line = main_line,
        clone_url = "https://github.com/"..match.repo.raw..".git",
      })
    end
  end

  local languages = {}
  for _, match in ipairs(api_response.facets.lang.buckets) do
    table.insert(languages, match.val)
  end
  return results, languages
end


function Grep(search_query, params, max_results)
  local results = {}
  local languages = {}

  local page = 1
  while #results < max_results do
    local res, langs = get_results_and_langs(search_query, params, page)
    if #res == 0 then
      break
    end
    for _, r in ipairs(res) do
      table.insert(results, r)
    end
    for _, l in ipairs(langs) do
      table.insert(languages, l)
    end
    page = page + 1
  end
  return results, languages
end

function Code_from_url(url)
  local res = curl.request({method = "get", url = url, compressed = false})
  if res.status == 200 then
    return res.body
  else
    print('Error: '..res.status)
  end
end

return {
  Grep = Grep,
  Code_from_url = Code_from_url
}

-- local params = {words = true, case = false, regexp = true, lang = "Python"}
-- local results, suggestions = Grep("print", params)
-- local result = results[1]
-- if result then
--   print(result.lines[1].url)
--   print(Code_from_url(result.raw_url))
-- else
--   print("No results found. Suggested langs")
--   print(json.encode(suggestions))
-- end
