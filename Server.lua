local tod = ARWIC_TOD
tod.server = {}

local str_starts = tod.ext.str_starts
local str_split = tod.ext.str_split
local table_length = tod.ext.table_length
local table_shuffle = tod.ext.table_shuffle

function tod.server.SendMsg(msg, target)
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_CLIENT", msg, "WHISPER", target)
end

-- hosts a new game of town of darkshire
function tod.server.HostGame()
    -- close the GUI
    if ARWIC_TOD_mainFrame ~= nil then
        ARWIC_TOD_mainFrame:Hide()
    end
    -- reset the server state
    tod.host = UnitName("player") .. "-" .. GetRealmName()
    tod.server.dayNight = "day"
    tod.server.dayNumber = 1
    tod.server.players = {}
    -- TODO: custom role lists
    tod.server.roleList = {
        "Jailor",
        "Town Investigative",
        "Town Investigative",
        "Town Protective",
        "Town Killing",
        "Town Support",
        "Random Town",
        "Random Town",
        "Random Town",
        "Godfather",
        "Mafioso",
        "Random Mafia",
        "Random Mafia",
        "Neutral Evil",
        "Neutral Killing"
    }
    tod.server.roles = {
        6, --"Jailor",
        0, --"Investigator",
        4, --"Spy",
        11, --"Doctor",
        8, --"Veteran",
        15, --"Mayor",
        12, --"Crusader",
        16, --"Medium",
        6, --"Vigilante",
        0000, --"Godfather",
        0000, --"Mafioso",
        0000, --"Blackmailer",
        0000, --"Janitor",
        0000, --"Jester",
        0000, --"Werewolf"
    }
    tod.server.numRolesAssigned = 0
    table_shuffle(tod.server.roles)
    
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_CLIENT", "INVITE", "PARTY")
    print("Hosting a new game")
end

function tod.server.SendRoleList(player_id)
    local msg = "ROLELIST^"
    for k,v in pairs(tod.server.roleList) do
        msg = msg .. v .. "^"
    end
    tod.server.SendMsg(msg, player_id)
end

function tod.server.SendPlayerList(player_id)
    local msg = "PLAYERLIST^"
    for k,v in pairs(tod.server.players) do
        msg = msg .. v.name .. "^"
    end
    tod.server.SendMsg(msg, player_id)
end

function tod.server.OnFirstJoin(player_id, msg)
    local parts = str_split(msg, "^")
    local nickname = parts[2]
    if nickname == nil or nickname == "" then
        nickname = player_id
    end
    -- TODO: make sure only 15 players can join at once
    local player = {}
    player.id = player_id
    player.name = nickname
    -- give the player the next role from the shuffled roles array
    tod.server.numRolesAssigned = tod.server.numRolesAssigned + 1
    player.role = tod.server.roles[tod.server.numRolesAssigned]
    table.insert(tod.server.players, player)
    local msg = "PLAYER^"
    msg = msg .. player.name .. "^"
    msg = msg .. player.role .. "^"
    tod.server.SendMsg(msg, player_id)
end

function tod.server.ParseAddOnMessage(prefix, msg, distribution_type, sender)
    if str_starts(msg, "FIRST_JOIN") then
        tod.server.OnFirstJoin(sender, msg)
    elseif str_starts(msg, "REQ_ROLELIST") then
        tod.server.SendRoleList(sender)
    elseif str_starts(msg, "REQ_PLAYERLIST") then
        tod.server.SendPlayerList(sender)
    end
end

function tod.MainLoop()
    
end