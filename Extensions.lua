ARWIC_TOD = {}
local tod = ARWIC_TOD
tod.ext = {}

function tod.ext.str_split(str, sep)
    local res = {}
    string.gsub(str, "[^"..sep.."]+", function(w)
        table.insert(res, w)
    end)
    return res 
end

function tod.ext.table_length(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function tod.ext.table_shuffle(t)
    local len = tod.ext.table_length(t)
    for i = len, 1, -1 do
        local rand = math.random(len)
        t[i], t[rand] = t[rand], t[i]
    end
    return t
end

function tod.ext.str_starts(str, start)
    return string.sub(str,1,string.len(start)) == start
end

