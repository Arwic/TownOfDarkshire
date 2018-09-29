local tod = ARWIC_TOD
tod.client = {}

local str_starts = tod.ext.str_starts
local str_split = tod.ext.str_split
local table_length = tod.ext.table_length

function tod.client.SendMsg(msg)
    C_ChatInfo.SendAddonMessage("ARWIC_TOD_SERVER", "REQ_ROLELIST", "WHISPER", tod.client.host)
end

function tod.client.JoinGame(host)
    tod.client.host = host
    print("Joining game hosted by " .. host)
    tod.gui.Build()
    tod.client.SendMsg("FIRST_JOIN")
end

StaticPopupDialogs["ARWIC_TOD_INVITE"] = {
    text = "%s invites you to a game of Town of Darkshire",
    button1 = "Accept",
    button2 = "Decline",
    OnAccept = function(sender, host)
        tod.client.JoinGame(host)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function tod.client.RequestRoleList()
    tod.client.SendMsg("REQ_ROLELIST")
end

function tod.client.ParseRoleList(msg)
    local parts = str_split(msg, "^")
    local len = table_length(parts)
    local roleList = {}
    for i=2,len do
        table.insert(roleList, parts[i])
    end
    tod.gui.RoleList.UpdateLabels(roleList)
    tod.gui.Show()
end

function tod.client.ParseAddOnMessage(prefix, msg, distribution_type, sender)
    if msg == "INVITE" then
        local dialog = StaticPopup_Show("ARWIC_TOD_INVITE", sender)
        if dialog then dialog.data = sender end
    end

    if str_starts(msg, "ROLELIST^") then
        tod.client.ParseRoleList(msg) 
    end
end

function tod.MainLoop()
    
end