local tod = ARWIC_TOD
tod.client = {}
local c = tod.client


local str_starts = tod.ext.str_starts
local str_split = tod.ext.str_split
local table_length = tod.ext.table_length

function c.SendMsg(msg)
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_SERVER", msg, "WHISPER", c.host)
end

function c.JoinGame(host, nickname)
    c.host = host
    print("Joining game hosted by " .. host)
    tod.gui.Build()
    c.SendMsg("FIRST_JOIN^"..nickname)
end

StaticPopupDialogs["ARWIC_TOD_INVITE"] = {
    text = "%s invites you to a game of Town of Darkshire.\n\nType the name you wish to use.",
    button1 = "Accept",
    button2 = "Decline",
    OnAccept = function(sender, host)
        local nickname = sender.editBox:GetText()
        nickname = nickname:gsub("%A","")
        c.JoinGame(host, nickname)
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

StaticPopupDialogs["ARWIC_TOD_GAMEFULL"] = {
    text = "The game is full.",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function c.ParsePlayerList(msg)
    print('parsing player list')
    local parts = str_split(msg, "^")
    local len = table_length(parts)
    local playerList = {}
    for i=2,len do
        table.insert(playerList, parts[i])
    end
    tod.gui.PlayerList.UpdateLabels(playerList)
end

function c.ParseRoleList(msg)
    local parts = str_split(msg, "^")
    local len = table_length(parts)
    local roleList = {}
    for i=2,len do
        table.insert(roleList, parts[i])
    end
    tod.gui.RoleList.UpdateLabels(roleList)
end

function c.ParsePlayer(msg)
    local parts = str_split(msg, "^")
    local name = parts[2]
    local role = parts[3]
    tod.gui.TopBar.SetName(name)
    tod.gui.Info.SetRole(tonumber(role))
    -- show the UI now that we have our player data
    tod.gui.Show()
end

function c.OnChatBoxEnterPressed(str)
    c.SendMsg("CHATMSG^" .. str)
end

function c.ParseChat_Player(msg)
    local parts = str_split(msg, "^")
    tod.gui.Chat.AddMessage(parts[2])
end

function c.ParseNewPhase(msg)
    local parts = str_split(msg, "^")
    local name = parts[2]
    tod.gui.TopBar.SetPhase(name)
end

function c.ParseAddOnMessage(prefix, msg, distribution_type, sender)
    if str_starts(msg, "INVITE") then
        local dialog = StaticPopup_Show("ARWIC_TOD_INVITE", sender)
        if dialog then dialog.data = sender end
    elseif str_starts(msg, "PLAYER") then
        c.ParsePlayer(msg)
    elseif str_starts(msg, "ROLELIST") then
        c.ParseRoleList(msg)
    elseif str_starts(msg, "PLAYERLIST") then
        c.ParsePlayerList(msg)
    elseif str_starts(msg, "GAMEFULL") then
        StaticPopup_Show("ARWIC_TOD_GAMEFULL", sender)
    elseif str_starts(msg, "PHASE") then
        c.ParseNewPhase(msg)
    elseif str_starts(msg, "CHATPLAYER") then
        c.ParseChat_Player(msg)
    end
end

function tod.MainLoop()
    
end