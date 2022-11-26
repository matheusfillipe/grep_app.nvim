local JSON = require("JSON")
local htmlparser = require("htmlparser")
local http = require("socket.http")

local API = 'https://grep.app/api/search'

local function api_request(query, params)
  local params_str = ''
  if params then
    for k, v in pairs(params) do
      if k == "lang" then k = "f.lang" end
      params_str = params_str .. '&' .. k .. '=' .. tostring(v)
    end
  end

  local url = API .. '?q=' .. query .. params_str
  local body, code = http.request(url)
  if code == 200 then
    return JSON:decode(body)
  else
      print('Error: '..code)
  end
end


function Grep(search_query, params)
  local results = {}
  local api_response = api_request(search_query, params)
  local hits = api_response['hits']['hits']

  if hits then
    for i = 1, #hits do
      local match = hits[i]
      local snippet = match.content.snippet
      local root = htmlparser.parse(snippet)
      local lineno = root('tr')
      local lines = {}
      for _, e in ipairs(lineno) do
        local lnum = e.attributes["data-line"] - 1
        local line = e('pre')[1]:textonly()
        local url = "https://github.com/" ..
            match.repo.raw.."/blob/" ..
            ((match.branch or {}).raw or 'master').."/"..match.path.raw ..
            "#L"..lnum
        table.insert(lines, {lnum = lnum, url = url, code = line})
      local raw_url = "https://raw.githubusercontent.com/" ..
          match.repo.raw.."/"..((match.branch or {}).raw or 'master').."/"..match.path.raw
      table.insert(results, {lines = lines, raw_url = raw_url})
      end
    end
  end

  local languages = {}
  for _, match in ipairs(api_response.facets.lang.buckets) do
    table.insert(languages, match.val)
  end

  return results, languages
end

function Code_from_url(url)
  local body, code = http.request(url)
  if code == 200 then
    return body
  else
    print('Error: '..code)
  end
end



local params = {words = true, case = false, regexp = true, lang = "Python"}
local results, suggestions = Grep("print", params)
local result = results[1]
if result then
  print(result.lines[1].url)
  print(Code_from_url(result.raw_url))
else
  print("No results found. Suggested langs")
  print(JSON:encode(suggestions))
end
