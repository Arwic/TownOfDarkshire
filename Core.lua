ARWIC_TOD = {}
local tod = ARWIC_TOD

-------------------- HELPERS --------------------

local function str_split(str, sep)
    local res = {}
    string.gsub(str, "[^"..sep.."]+", function(w)
        table.insert(res, w)
    end)
    return res 
end

function tod.Print(msg)
    print(format("ToD: %s", msg))
end

-- hosts a new game of town of darkshire
function tod.HostGame()
    -- reset the server state
    tod.is_host = true
    tod.server = {}
    tod.server.dayNight = "day"
    tod.server.dayNumber = 1
    tod.server.players = {}
    -- TODO: custom role lists
    tod.server.roles = {
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
    C_ChatInfo.SendAddonMessage("ARWIC_TOD", "INVITE", "PARTY")
    tod.Print("Hosting a new game")
end

function tod.JoinGame(host)
    tod.Print("Joining game hosted by " .. host)
    tod.gui.Build()
    C_ChatInfo.SendAddonMessage("ARWIC_TOD", "FIRST_JOIN", "WHISPER", host)
end

SLASH_ARWIC_TOD1 = "/tod"
SlashCmdList["ARWIC_TOD"] = function(msg)
    if msg == "host" then
        tod.HostGame()
    end
end 

StaticPopupDialogs["ARWIC_TOD_INVITE"] = {
    text = "%s invites you to a game of Town of Darkshire",
    button1 = "Accept",
    button2 = "Decline",
    OnAccept = function(sender, host)
        tod.JoinGame(host)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-------------------- EVENTS --------------------

tod.events = {}

function tod.events:CHAT_MSG_ADDON(prefix, message, distribution_type, sender)
    print("asasdasd")
    -- only act on messages sent by the host
    if prefix == "ARWIC_TOD" then
        print(prefix, message, distribution_type, sender)
        if message == "INVITE" then
            local dialog = StaticPopup_Show("ARWIC_TOD_INVITE", sender)
            if dialog then dialog.data = sender end
        end
        tod.ParseAddOnMessage(prefix, message, distribution_type, sender)
    end
end

local function RegisterEvents()
    local eventFrame = CreateFrame("FRAME", "ARWIC_TOD_eventFrame")
    local tod = tod
    eventFrame:SetScript("OnEvent", function(self, event, ...)
            tod.events[event](self, ...)
    end)
    for k, v in pairs(tod.events) do
        eventFrame:RegisterEvent(k)
    end
end

local function Init()
    -- register the addon msg prefix so we can recieve msgs from other players
    C_ChatInfo.RegisterAddonMessagePrefix("ARWIC_TOD")
    -- register wow events
    RegisterEvents()
    -- tell the user wev successfully loaded
    print("Town of Darkshrie Loaded. Run '/tod host' to start a new game!")
end

Init()
