local tod = ARWIC_TOD
tod.server = {}

local str_starts = tod.ext.str_starts
local str_split = tod.ext.str_split
local table_length = tod.ext.table_length
local table_shuffle = tod.ext.table_shuffle

function tod.server.SendMsg(msg)
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_CLIENT", "REQ_ROLELIST", "WHISPER", tod.client.host)
end

-- hosts a new game of town of darkshire
function tod.server.HostGame()
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
        "Jailor",
        "Investigator",
        "Spy",
        "Doctor",
        "Veteran",
        "Mayor",
        "Crusader",
        "Medium",
        "Vigilante",
        "Godfather",
        "Mafioso",
        "Blackmailer",
        "Janitor",
        "Jester",
        "Werewolf"
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
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_CLIENT", msg, "WHISPER", player_id)
end

function tod.server.OnFirstJoin(id)
    -- TODO: make sure only 15 players can join at once
    local player = {}
    player.id = id
    player.name = id -- TODO: let player pick this
    -- give the player the next role from the shuffled roles array
    tod.server.numRolesAssigned = tod.server.numRolesAssigned + 1
    player.role = tod.server.roles[tod.server.numRolesAssigned]
    table.insert(tod.server.players, player)

    local msg = "PLAYER^"
    msg = msg .. name .. "^"
    msg = msg .. role .. "^"
    C_ChatInfo.SendAddonMessage("ARWIC_TOD", msg, "WHISPER", player_id)
end

function tod.server.ParseAddOnMessage(prefix, message, distribution_type, sender)
    if str_starts(message, "FIRST_JOIN") then
        tod.server.OnFirstJoin(sender)
    elseif str_starts(message, "REQ_ROLELIST") then
        tod.server.SendRoleList(sender)
    end
end

function tod.MainLoop()
    
end