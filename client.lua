local JSON = require("JSON")
local htmlparser = require("htmlparser")
local http = require("socket.http")
local API = 'https://grep.app/api/search'

local function search(query)
    local body, code = http.request(API .. '?q=' .. query)
    if code == 200 then
      return JSON:decode(body)
    else
        print('Error: '..code)
    end
end

local obj = search('hello')['hits']['hits']
for i = 1, #obj do
  local match = obj[i]
  local snippet = match.content.snippet
  local root = htmlparser.parse(snippet)
  local lineno = root('.lineno')
  local places = {}
  for _, e in ipairs(lineno) do
    local lnum = e:textonly()
    local url = "https://github.com/" ..
        match.repo.raw.."/blob/" ..
        ((match.branch or {}).raw or 'master').."/"..match.path.raw ..
        "#L"..lnum
    table.insert(places, {lnum = lnum, url = url})
  end
  print(JSON:encode(places[1].url))


  local lines = {}
  -- for pre in soup.find_all('tr'):
  --     pre.find_all('td')[0].decompose()
  --     lines.append(pre.text)

  -- res.append(Result(url, lines))
end

