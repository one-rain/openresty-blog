--
-- String process.
-- User: one-rain
-- Date: 2016/8/7
-- Time: 15:06
-- To change this template use File | Settings | File Templates.
--

local strutil = {}

strutil._VERSION = "0.0.1"


-- string split
function strutil.split(str, delimiter)
    if str == nil or str == '' or delimiter == nil then
        return nil
    end

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end


-- url decode
function strutil.unescape(s)
    local str = string.gsub(s, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end)
    return str
end

return strutil
