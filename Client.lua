local tod = ARWIC_TOD
tod.client = {}

local str_starts = tod.ext.str_starts
local str_split = tod.ext.str_split
local table_length = tod.ext.table_length

function tod.client.SendMsg(msg)
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_SERVER", msg, "WHISPER", tod.client.host)
end

function tod.client.JoinGame(host, nickname)
    tod.client.host = host
    print("Joining game hosted by " .. host)
    tod.gui.Build()
    tod.client.SendMsg("FIRST_JOIN^"..nickname)
end

StaticPopupDialogs["ARWIC_TOD_INVITE"] = {
    text = "%s invites you to a game of Town of Darkshire.\n\nType the name you wish to use.",
    button1 = "Accept",
    button2 = "Decline",
    OnAccept = function(sender, host)
        local nickname = sender.editBox:GetText()
        nickname = nickname:gsub('%A','')
        tod.client.JoinGame(host, nickname)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    hasEditBox = true,
    OnShow = function(self, data)
        self.editBox:SetText(UnitName("player"))
    end,
}

function tod.client.ParsePlayerList(msg)
    print('parsing player list')
    local parts = str_split(msg, "^")
    local len = table_length(parts)
    local playerList = {}
    for i=2,len do
        table.insert(playerList, parts[i])
    end
    tod.gui.PlayerList.UpdateLabels(playerList)
end

function tod.client.ParseRoleList(msg)
    local parts = str_split(msg, "^")
    local len = table_length(parts)
    local roleList = {}
    for i=2,len do
        table.insert(roleList, parts[i])
    end
    tod.gui.RoleList.UpdateLabels(roleList)
end

function tod.client.ParsePlayer(msg)
    local parts = str_split(msg, "^")
    local name = parts[2]
    local role = parts[3]
    tod.gui.TopBar.SetName(name)
    tod.gui.Info.SetRole(tonumber(role))
    tod.client.SendMsg("REQ_ROLELIST")
    tod.client.SendMsg("REQ_PLAYERLIST")
    -- show the UI now that we have our player data
    tod.gui.Show()
end

function tod.client.ParseAddOnMessage(prefix, msg, distribution_type, sender)
    if msg == "INVITE" then
        local dialog = StaticPopup_Show("ARWIC_TOD_INVITE", sender)
        if dialog then dialog.data = sender end
    end

    if str_starts(msg, "PLAYER^") then
        tod.client.ParsePlayer(msg)
    elseif str_starts(msg, "ROLELIST^") then
        tod.client.ParseRoleList(msg)
    elseif str_starts(msg, "PLAYERLIST^") then
        tod.client.ParsePlayerList(msg)
    end
end

function tod.MainLoop()
    
end