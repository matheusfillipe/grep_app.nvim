Utils = {}
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

return Utils
