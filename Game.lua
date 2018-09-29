local tod = ARWIC_TOD

local function str_split(str, sep)
    local res = {}
    string.gsub(str, "[^"..sep.."]+", function(w)
        table.insert(res, w)
    end)
    return res 
end

local function table_length(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

local function str_starts(str, start)
    return string.sub(str,1,string.len(start)) == start
 end

function tod.SendGameState(player_id)
    print("sending game state to: " .. player.id)
    local gameStateStr = "GS^"
    gameStateStr = gameStateStr .. tod.server.dayNight .. "^"
    gameStateStr = gameStateStr .. tod.server.dayNumber .. "^"
    gameStateStr = gameStateStr .. 15 .. "^" -- role count
    for i=1,15 do
        gameStateStr = gameStateStr .. tod.server.roles[i] .. "^" -- TODO: should send role IDs only
    end
    C_ChatInfo.SendAddonMessage("ARWIC_TOD", "GS^", "WHISPER", player_id)
end

function tod.OnFirstJoin(id)
    -- TODO: make sure only 15 players can join at once
    local player = {}
    player.id = id
    player.name = id
    table.insert(tod.server.players, player)
end

function tod.ParseAddOnMessage(prefix, message, distribution_type, sender)
    if tod.is_host then
        if str_starts(message, "FIRST_JOIN") then
            tod.SendGameState(sender)
        end
    end
    
    if str_starts(message, "GAME_STATE") then
        tod.UpdateGameState(sender)
    end

end

function tod.MainLoop()
    
end