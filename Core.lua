local tod = ARWIC_TOD


SLASH_ARWIC_TOD1 = "/tod"
SlashCmdList["ARWIC_TOD"] = function(msg)
    if msg == "host" then
        tod.server.HostGame()
    end
end 

-------------------- EVENTS --------------------

tod.events = {}

function tod.events:CHAT_MSG_ADDON(prefix, message, distribution_type, sender)
    print(prefix, message, distribution_type, sender)
    if prefix == "ARWIC_TOD_CLIENT" then
        tod.client.ParseAddOnMessage(prefix, message, distribution_type, sender)
    elseif prefix == "ARWIC_TOD_SERVER" then
        tod.server.ParseAddOnMessage(prefix, message, distribution_type, sender)
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
    C_ChatInfo.RegisterAddonMessagePrefix("ARWIC_TOD_CLIENT")
    C_ChatInfo.RegisterAddonMessagePrefix("ARWIC_TOD_SERVER")
    -- register wow events
    RegisterEvents()
    -- tell the user wev successfully loaded
    print("Town of Darkshrie Loaded. Run '/tod host' to start a new game!")
end

Init()
