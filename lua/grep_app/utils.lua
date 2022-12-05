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
    str = string.gsub( str, '&iexcl;', '¡')
    str = string.gsub( str, '&cent;', '¢')
    str = string.gsub( str, '&pound;', '£')
    str = string.gsub( str, '&curren;', '¤')
    str = string.gsub( str, '&yen;', '¥')
    str = string.gsub( str, '&brvbar;', '¦')
    str = string.gsub( str, '&sect;', '§')
    str = string.gsub( str, '&uml;', '¨')
    str = string.gsub( str, '&copy;', '©')
    str = string.gsub( str, '&ordf;', 'ª')
    str = string.gsub( str, '&laquo;', '«')
    str = string.gsub( str, '&not;', '¬')
    str = string.gsub( str, '&shy;', '­')
    str = string.gsub( str, '&reg;', '®')
    str = string.gsub( str, '&macr;', '¯')
    str = string.gsub( str, '&deg;', '°')
    str = string.gsub( str, '&plusmn;', '±')
    str = string.gsub( str, '&sup2;', '²')
    str = string.gsub( str, '&sup3;', '³')
    str = string.gsub( str, '&acute;', '´')
    str = string.gsub( str, '&micro;', 'µ')
    str = string.gsub( str, '&para;', '¶')
    str = string.gsub( str, '&middot;', '·')
    str = string.gsub( str, '&cedil;', '¸')
    str = string.gsub( str, '&sup1;', '¹')
    str = string.gsub( str, '&ordm;', 'º')
    str = string.gsub( str, '&raquo;', '»')
    str = string.gsub( str, '&frac14;', '¼')
    str = string.gsub( str, '&frac12;', '½')
    str = string.gsub( str, '&frac34;', '¾')
    str = string.gsub( str, '&iquest;', '¿')
    str = string.gsub( str, '&Agrave;', 'À')
    str = string.gsub( str, '&Aacute;', 'Á')
    str = string.gsub( str, '&Acirc;', 'Â')
    str = string.gsub( str, '&Atilde;', 'Ã')
    str = string.gsub( str, '&Auml;', 'Ä')
    str = string.gsub( str, '&Aring;', 'Å')
    str = string.gsub( str, '&AElig;', 'Æ')
    str = string.gsub( str, '&Ccedil;', 'Ç')
    str = string.gsub( str, '&Egrave;', 'È')
    str = string.gsub( str, '&Eacute;', 'É')
    str = string.gsub( str, '&Ecirc;', 'Ê')
    str = string.gsub( str, '&Euml;', 'Ë')
    str = string.gsub( str, '&Igrave;', 'Ì')
    str = string.gsub( str, '&Iacute;', 'Í')
    str = string.gsub( str, '&Icirc;', 'Î')
    str = string.gsub( str, '&Iuml;', 'Ï')
    str = string.gsub( str, '&ETH;', 'Ð')
    str = string.gsub( str, '&Ntilde;', 'Ñ')
    str = string.gsub( str, '&Ograve;', 'Ò')
    str = string.gsub( str, '&Oacute;', 'Ó')
    str = string.gsub( str, '&Ocirc;', 'Ô')
    str = string.gsub( str, '&Otilde;', 'Õ')
    str = string.gsub( str, '&Ouml;', 'Ö')
    str = string.gsub( str, '&times;', '×')
    str = string.gsub( str, '&Oslash;', 'Ø')
    str = string.gsub( str, '&Ugrave;', 'Ù')
    str = string.gsub( str, '&Uacute;', 'Ú')
    str = string.gsub( str, '&Ucirc;', 'Û')
    str = string.gsub( str, '&Uuml;', 'Ü')
    str = string.gsub( str, '&Yacute;', 'Ý')
    str = string.gsub( str, '&THORN;', 'Þ')
    str = string.gsub( str, '&szlig;', 'ß')
    str = string.gsub( str, '&agrave;', 'à')
    str = string.gsub( str, '&aacute;', 'á')
    str = string.gsub( str, '&acirc;', 'â')
    str = string.gsub( str, '&atilde;', 'ã')
    str = string.gsub( str, '&auml;', 'ä')
    str = string.gsub( str, '&aring;', 'å')
    str = string.gsub( str, '&aelig;', 'æ')
    str = string.gsub( str, '&ccedil;', 'ç')
    str = string.gsub( str, '&egrave;', 'è')
    str = string.gsub( str, '&eacute;', 'é')
    str = string.gsub( str, '&ecirc;', 'ê')
    str = string.gsub( str, '&euml;', 'ë')
    str = string.gsub( str, '&igrave;', 'ì')
    str = string.gsub( str, '&iacute;', 'í')
    str = string.gsub( str, '&icirc;', 'î')
    str = string.gsub( str, '&iuml;', 'ï')
    str = string.gsub( str, '&eth;', 'ð')
    str = string.gsub( str, '&ntilde;', 'ñ')
    str = string.gsub( str, '&ograve;', 'ò')
    str = string.gsub( str, '&oacute;', 'ó')
    str = string.gsub( str, '&ocirc;', 'ô')
    str = string.gsub( str, '&otilde;', 'õ')
    str = string.gsub( str, '&ouml;', 'ö')
    str = string.gsub( str, '&divide;', '÷')
    str = string.gsub( str, '&oslash;', 'ø')
    str = string.gsub( str, '&ugrave;', 'ù')
    str = string.gsub( str, '&uacute;', 'ú')
    str = string.gsub( str, '&ucirc;', 'û')
    str = string.gsub( str, '&uuml;', 'ü')
    str = string.gsub( str, '&yacute;', 'ý')
    str = string.gsub( str, '&thorn;', 'þ')
    str = string.gsub( str, '&yuml;', 'ÿ')
    str = string.gsub( str, '&euro;', '€')
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
