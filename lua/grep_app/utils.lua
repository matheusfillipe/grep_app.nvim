Utils = {}

Utils.table_merge = function(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for k, t in ipairs(tables_to_merge) do
        assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
    end

    local result = tables_to_merge[1]

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for k, v in pairs(from) do
            if type(k) == "number" then
                table.insert(result, v)
            elseif type(k) == "string" then
                if type(v) == "table" then
                    result[k] = result[k] or {}
                    result[k] = Utils.table_merge(result[k], v)
                else
                    result[k] = v
                end
            end
        end
    end

    return result
end

Utils.dump = function (o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. Utils.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

Utils.script_path = function()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

Utils.get_visual_selection = function()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

Utils.get_current_line = function()
  local line = vim.api.nvim_get_current_line()
  return line
end

Utils.unescape_html = function(str)
    str = string.gsub( str, '&lt;', '<' )
    str = string.gsub( str, '&gt;', '>' )
    str = string.gsub( str, '&quot;', '"' )
    str = string.gsub( str, '&apos;', "'" )
    str = string.gsub( str, '&nbsp;', ' ')
    str = string.gsub( str, '&iexcl;', '??')
    str = string.gsub( str, '&cent;', '??')
    str = string.gsub( str, '&pound;', '??')
    str = string.gsub( str, '&curren;', '??')
    str = string.gsub( str, '&yen;', '??')
    str = string.gsub( str, '&brvbar;', '??')
    str = string.gsub( str, '&sect;', '??')
    str = string.gsub( str, '&uml;', '??')
    str = string.gsub( str, '&copy;', '??')
    str = string.gsub( str, '&ordf;', '??')
    str = string.gsub( str, '&laquo;', '??')
    str = string.gsub( str, '&not;', '??')
    str = string.gsub( str, '&shy;', '??')
    str = string.gsub( str, '&reg;', '??')
    str = string.gsub( str, '&macr;', '??')
    str = string.gsub( str, '&deg;', '??')
    str = string.gsub( str, '&plusmn;', '??')
    str = string.gsub( str, '&sup2;', '??')
    str = string.gsub( str, '&sup3;', '??')
    str = string.gsub( str, '&acute;', '??')
    str = string.gsub( str, '&micro;', '??')
    str = string.gsub( str, '&para;', '??')
    str = string.gsub( str, '&middot;', '??')
    str = string.gsub( str, '&cedil;', '??')
    str = string.gsub( str, '&sup1;', '??')
    str = string.gsub( str, '&ordm;', '??')
    str = string.gsub( str, '&raquo;', '??')
    str = string.gsub( str, '&frac14;', '??')
    str = string.gsub( str, '&frac12;', '??')
    str = string.gsub( str, '&frac34;', '??')
    str = string.gsub( str, '&iquest;', '??')
    str = string.gsub( str, '&Agrave;', '??')
    str = string.gsub( str, '&Aacute;', '??')
    str = string.gsub( str, '&Acirc;', '??')
    str = string.gsub( str, '&Atilde;', '??')
    str = string.gsub( str, '&Auml;', '??')
    str = string.gsub( str, '&Aring;', '??')
    str = string.gsub( str, '&AElig;', '??')
    str = string.gsub( str, '&Ccedil;', '??')
    str = string.gsub( str, '&Egrave;', '??')
    str = string.gsub( str, '&Eacute;', '??')
    str = string.gsub( str, '&Ecirc;', '??')
    str = string.gsub( str, '&Euml;', '??')
    str = string.gsub( str, '&Igrave;', '??')
    str = string.gsub( str, '&Iacute;', '??')
    str = string.gsub( str, '&Icirc;', '??')
    str = string.gsub( str, '&Iuml;', '??')
    str = string.gsub( str, '&ETH;', '??')
    str = string.gsub( str, '&Ntilde;', '??')
    str = string.gsub( str, '&Ograve;', '??')
    str = string.gsub( str, '&Oacute;', '??')
    str = string.gsub( str, '&Ocirc;', '??')
    str = string.gsub( str, '&Otilde;', '??')
    str = string.gsub( str, '&Ouml;', '??')
    str = string.gsub( str, '&times;', '??')
    str = string.gsub( str, '&Oslash;', '??')
    str = string.gsub( str, '&Ugrave;', '??')
    str = string.gsub( str, '&Uacute;', '??')
    str = string.gsub( str, '&Ucirc;', '??')
    str = string.gsub( str, '&Uuml;', '??')
    str = string.gsub( str, '&Yacute;', '??')
    str = string.gsub( str, '&THORN;', '??')
    str = string.gsub( str, '&szlig;', '??')
    str = string.gsub( str, '&agrave;', '??')
    str = string.gsub( str, '&aacute;', '??')
    str = string.gsub( str, '&acirc;', '??')
    str = string.gsub( str, '&atilde;', '??')
    str = string.gsub( str, '&auml;', '??')
    str = string.gsub( str, '&aring;', '??')
    str = string.gsub( str, '&aelig;', '??')
    str = string.gsub( str, '&ccedil;', '??')
    str = string.gsub( str, '&egrave;', '??')
    str = string.gsub( str, '&eacute;', '??')
    str = string.gsub( str, '&ecirc;', '??')
    str = string.gsub( str, '&euml;', '??')
    str = string.gsub( str, '&igrave;', '??')
    str = string.gsub( str, '&iacute;', '??')
    str = string.gsub( str, '&icirc;', '??')
    str = string.gsub( str, '&iuml;', '??')
    str = string.gsub( str, '&eth;', '??')
    str = string.gsub( str, '&ntilde;', '??')
    str = string.gsub( str, '&ograve;', '??')
    str = string.gsub( str, '&oacute;', '??')
    str = string.gsub( str, '&ocirc;', '??')
    str = string.gsub( str, '&otilde;', '??')
    str = string.gsub( str, '&ouml;', '??')
    str = string.gsub( str, '&divide;', '??')
    str = string.gsub( str, '&oslash;', '??')
    str = string.gsub( str, '&ugrave;', '??')
    str = string.gsub( str, '&uacute;', '??')
    str = string.gsub( str, '&ucirc;', '??')
    str = string.gsub( str, '&uuml;', '??')
    str = string.gsub( str, '&yacute;', '??')
    str = string.gsub( str, '&thorn;', '??')
    str = string.gsub( str, '&yuml;', '??')
    str = string.gsub( str, '&euro;', '???')
    str = string.gsub( str, '&#(%d+);', function(n) return string.char(n) end )
    str = string.gsub( str, '&#x(%d+);', function(n) return string.char(tonumber(n,16)) end )
    str = string.gsub( str, '&amp;', '&' ) -- Be sure to do this after all others
    return str
end


Utils.strip = function(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

Utils.system = function(cmd)
  return Utils.strip(vim.fn.system(cmd))
end


return Utils
