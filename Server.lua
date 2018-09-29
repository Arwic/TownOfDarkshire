local tod = ARWIC_TOD
tod.server = {}
local s = tod.server

local str_starts = tod.ext.str_starts
local str_split = tod.ext.str_split
local table_length = tod.ext.table_length
local table_shuffle = tod.ext.table_shuffle

local phaseLengths = {
    ["Day 1"] = 15,
    ["Discussion"] = 45,
    ["Voting"] = 30,
    ["Defense"] = 20,
    ["Judgement"] = 20,
    ["Last Words"] = 5,
    ["Night"] = 30,
}

local function GetNextPhase(curPhase)
    if curPhase == "Day 1" then
        return "Night"
    elseif curPhase == "Discussion" then
        return "Voting"
    elseif curPhase == "Night" then
        return "Discussion"
    end
end

function s.SendMsg(msg, target)
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_CLIENT", msg, "WHISPER", target)
end

function s.SendMsgToAll(msg)
    for k,v in pairs(s.players) do
        s.SendMsg(msg, v.id)
    end
end

-- hosts a new game of town of darkshire
function s.HostGame()
    -- close the GUI
    if ARWIC_TOD_mainFrame ~= nil then
        ARWIC_TOD_mainFrame:Hide()
    end
    -- reset the server state
    tod.host = UnitName("player") .. "-" .. GetRealmName()
    s.phase = "Waiting for Players"
    s.nextPhase = "Day 1"
    s.dayNumber = 1
    s.players = {}
    s.maxPlayers = 1 --15
    -- TODO: custom role lists
    s.roleList = {
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
    s.roles = {
        6, --"Jailor",
        0, --"Investigator",
        4, --"Spy",
        11, --"Doctor",
        8, --"Veteran",
        15, --"Mayor",
        12, --"Crusader",
        16, --"Medium",
        6, --"Vigilante", -- TODO: add missing (evil/neutral) roles
        -1, --"Godfather",
        -1, --"Mafioso",
        -1, --"Blackmailer",
        -1, --"Janitor",
        -1, --"Jester",
        -1, --"Werewolf"
    }
    s.numRolesAssigned = 0
    table_shuffle(s.roles)
    
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_CLIENT", "INVITE", "PARTY")
    print("Hosting a new game")
end

function s.SendNewPhaseToAll()
    local msg = "PHASE^" .. s.phase
    s.SendMsgToAll(msg)
end

function s.SendRoleList(player_id)
    local msg = "ROLELIST^"
    for k,v in pairs(s.roleList) do
        msg = msg .. v .. "^"
    end
    s.SendMsg(msg, player_id)
end

function s.SendPlayerListToAll()
    local msg = "PLAYERLIST^"
    for k,v in pairs(s.players) do
        msg = msg .. v.name .. "^"
    end
    s.SendMsgToAll(msg)
end

function s.OnFirstJoin(player_id, msg)
    if table_length(s.players) > s.maxPlayers - 1 then
        s.SendMsg("GAMEFULL", player_id)
        return
    end
    local parts = str_split(msg, "^")
    local nickname = parts[2]
    if nickname == nil or nickname == "" then
        nickname = player_id
    end
    local player = {}
    player.id = player_id
    player.name = nickname
    -- give the player the next role from the shuffled roles array
    s.numRolesAssigned = s.numRolesAssigned + 1
    player.role = s.roles[s.numRolesAssigned]
    table.insert(s.players, player)
    local msg = "PLAYER^"
    msg = msg .. player.name .. "^"
    msg = msg .. player.role .. "^"
    s.SendMsg(msg, player_id)
    s.SendPlayerListToAll()

    -- start the game once it is full
    if table_length(s.players) >= s.maxPlayers then
        s.StartGame()
    end
end

function s.ParseAddOnMessage(prefix, msg, distribution_type, sender)
    if str_starts(msg, "FIRST_JOIN") then
        s.OnFirstJoin(sender, msg)
    elseif str_starts(msg, "REQ_ROLELIST") then
        s.SendRoleList(sender)
    end
end

function s.DoNightActions()
    -- first pass
    for _, player in pairs(players) do
        if player.lastNight == nil then player.lastNight = {} end
        player.lastNight.results = palyer.role.night_action(player, player.target1, player.target2)
    end
    -- second pass
    for _, player in pairs(players) do
        if player.lastNight.roleBlocked then
            player.lastNight.results = { "Someone occupied your night. You were roled blocked." }
        end
        if player.lastNight.killed then
            table.insert(player.lastNight.results, "You have died!")
        end
        for k,v in pairs(results) do
            s.SendMsg("NIGHTRESULT^"..v)
        end
    end
end

function s.EndPhase(phase)
    if phase == "Day 1" then
        s.BeginNewPhase("Night")
    elseif phase == "Night" then
        -- TODO: night actions
        s.BeginNewPhase("Discussion")
    elseif phase == "Discussion" then
        s.BeginNewPhase("Voting")
    elseif phase == "Voting" then
        s.BeginNewPhase("Night")
    elseif phase == "Defense" then
        s.BeginNewPhase("Judgement")
    elseif phase == "Judgement" then
        s.BeginNewPhase("Last Words")
    elseif phase == "Last Words" then
        s.BeginNewPhase("Night")
    end
end

function s.BeginNewPhase(phase)
    s.phase = phase
    s.SendNewPhaseToAll()
    local phaseLength = tod.data.phaseLengths[phase]
    s.phaseTimer = C_Timer.NewTimer(phaseLength, function()
        s.EndPhase(phase)
    end)
end

function s.StartGame()
    s.phase = "Day 1"
    s.SendNewPhaseToAll()
    s.BeginNewPhase(s.phase)
end
