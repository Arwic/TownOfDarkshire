local tod = ARWIC_TOD
tod.gui = {}

local str_starts = tod.ext.str_starts
local str_split = tod.ext.str_split
local table_length = tod.ext.table_length
local table_shuffle = tod.ext.table_shuffle

---------- HELPERS ----------

local function NewLabel(parent, fontHeight, text)
    local str = parent:CreateFontString()
    str:SetParent(parent)
    str:SetFont("fonts/ARIALN.ttf", fontHeight)
    str:SetText(text)
    return str
end

local function NewTitleBar(parent, text)
    local titleBar = CreateFrame("FRAME", parent:GetName().."_titleBar", parent)
    titleBar:SetPoint("TOP", parent)
    titleBar:SetPoint("LEFT", parent)
    titleBar:SetPoint("RIGHT", parent)
    titleBar:SetHeight(20)
    titleBar.texture = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBar.texture:SetColorTexture(0.15, 0.15, 0.3, 1.0)
    titleBar.texture:SetAllPoints(titleBar)
    local titleBarText = NewLabel(titleBar, 20, text)
    titleBarText:SetAllPoints(titleBar)
    return titleBar, titleBarText
end

local function CreateFrameTexture(frame)
    frame.texture = frame:CreateTexture(nil, "BACKGROUND")
    frame.texture:SetColorTexture(0.1, 0.1, 0.1, 0.9)
    frame.texture:SetAllPoints(frame)
end

---------- TOP BAR ----------
tod.gui.TopBar = {}

function tod.gui.TopBar.Build(mainFrame)
    local tb = tod.gui.TopBar
    local topBarFrame = CreateFrame("Frame", "ARWIC_TOD_topBarFrame", mainFrame)
    CreateFrameTexture(topBarFrame)
    tb.MyName = NewLabel(topBarFrame, 20, "")
    tb.MyName:SetPoint("LEFT", topBarFrame)

    tb.Timer = NewLabel(topBarFrame, 20, "")
    tb.Timer:SetPoint("RIGHT", topBarFrame)
    tb.Timer.EventFrame = CreateFrame("FRAME")
    tb.Timer.PhaseLength = -1
    tb.Timer.PhaseName = "Waiting for Players"
    tb.Timer.CurrentVal = tb.Timer.PhaseLength
    tb.Timer.EventFrame:SetScript("OnUpdate", function(self, elapsed)
        tb.Timer.CurrentVal = tb.Timer.CurrentVal - elapsed
        if tb.Timer.CurrentVal < 0 then tb.Timer.CurrentVal = 0 end
        if tb.Timer.PhaseLength == -1 then
            tb.Timer:SetText(tb.Timer.PhaseName)
        else
            tb.Timer:SetText(format("%s: %d", tb.Timer.PhaseName, tb.Timer.CurrentVal))
        end
    end)

    return topBarFrame
end

function tod.gui.TopBar.SetName(name)
    local tb = tod.gui.TopBar
    tb.MyName:SetText(name)
end

function tod.gui.TopBar.SetPhase(name)
    local tb = tod.gui.TopBar
    print("new phase name: " .. name)
    print("new phase len: " .. tod.data.phaseLengths[name])
    tb.Timer.PhaseLength = tod.data.phaseLengths[name]
    tb.Timer.PhaseName = name
    -- reset the timer
    tb.Timer.CurrentVal = tb.Timer.PhaseLength
end

---------- GRAVEYARD ----------
tod.gui.Graveyard = {}

function tod.gui.Graveyard.Build(mainFrame)
    local gy = tod.gui.Graveyard
    local graveyardFrame = CreateFrame("Frame", "ARWIC_TOD_graveyardFrame", mainFrame)
    CreateFrameTexture(graveyardFrame)
    local titleBar = NewTitleBar(graveyardFrame, "Graveyard")
    
    gy.Labels = {}
    local lastlbl = titleBar
    for i=1,15 do
        local lbl = NewLabel(graveyardFrame, 18, "")
        lbl:SetPoint("TOP", lastlbl, "BOTTOM")
        lbl:SetPoint("LEFT", graveyardFrame, "LEFT")
        lbl:SetJustifyH("LEFT")
        lastlbl = lbl
        table.insert(gy.Labels, lbl)
    end

    return graveyardFrame
end

function tod.gui.Graveyard.UpdateLabels(deadPlayers)
    local gy = tod.gui.Graveyard
    local numDead = table_length(deadPlayers)
    for i=1,numDead do
        local lbl = gy.Labels[i]
        local player = deadPlayers[i]
        lbl:SetText(foramt("%s (%s)", player.Name, player.Role.Name))
    end
    for i=numDead,15 do
        gy.Labels[i]:SetText("")
    end
end

---------- CHAT ----------
tod.gui.Chat = {}

function tod.gui.Chat.Build(mainFrame)
    local chat = tod.gui.Chat
    local chatFrame = CreateFrame("Frame", "ARWIC_TOD_chatFrame", mainFrame)
    CreateFrameTexture(chatFrame)
    local titleBar = NewTitleBar(chatFrame, "Chat")

    local editBox = CreateFrame("EditBox", "ARWIC_TOD_chatFrame_editBox", chatFrame)
    editBox:SetHeight(30)
    editBox:SetPoint("BOTTOMLEFT", chatFrame, "BOTTOMLEFT")
    editBox:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMRIGHT")
    editBox:SetFont("fonts/ARIALN.ttf", 20)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEnterPressed", function(self)
        local str = self:GetText()
        self:SetText("")
        tod.client.OnChatBoxEnterPressed(str)
    end)
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    chat.Labels = {}
    local lastlbl = editBox
    for i=1,15 do
        local lbl = NewLabel(chatFrame, 18, "")
        lbl:SetPoint("BOTTOM", lastlbl, "TOP", 0, 0)
        lbl:SetPoint("LEFT", chatFrame, "LEFT")
        lbl:SetJustifyH("LEFT")
        lastlbl = lbl
        table.insert(chat.Labels, lbl)
    end

    return chatFrame
end

function tod.gui.Chat.AddMessage(msg)
    local chat = tod.gui.Chat
    if chat.history == nil then chat.history = {} end
    table.insert(chat.history, msg)
    
    local histLen = table_length(chat.history)
    for i=1,15 do
        local j = histLen - i + 1
        chat.Labels[i]:SetText(chat.history[j])
    end
end

---------- INFO ----------
tod.gui.Info = {}

function tod.gui.Info.Build(mainFrame)
    local info = tod.gui.Info
    local infoFrame = CreateFrame("Frame", "ARWIC_TOD_infoFrame", mainFrame)
    CreateFrameTexture(infoFrame)
    infoFrame:SetSize(200, 500)
    info.TitleBar, info.TitleBarText = NewTitleBar(infoFrame, "")

    return infoFrame
end

function tod.gui.Info.SetRole(role_id)
    if role_id == nil then
        print("Error role_id is nil")
        return
    end
    tod.gui.Info.TitleBarText:SetText(tod.data.roles[role_id].name)
end

---------- ROLE LIST ----------
tod.gui.RoleList = {}

function tod.gui.RoleList.Build(mainFrame)
    local rl = tod.gui.RoleList
    local roleListFrame = CreateFrame("Frame", "ARWIC_TOD_roleListFrame", mainFrame)
    CreateFrameTexture(roleListFrame)
    roleListFrame:SetSize(200, 500)
    local titleBar = NewTitleBar(roleListFrame, "Role List")
    
    rl.Labels = {}
    local lastlbl = titleBar
    for i=1,15 do
        local lbl = NewLabel(roleListFrame, 18, "...")
        lbl:SetPoint("TOP", lastlbl, "BOTTOM")
        lbl:SetPoint("LEFT", roleListFrame, "LEFT")
        lbl:SetJustifyH("LEFT")
        lastlbl = lbl
        table.insert(rl.Labels, lbl)
    end

    return roleListFrame
end

-- sets all the labels in the role list, list of roles should contain "Town Investigative", "Random Town" etc. not exact names or role objects
function tod.gui.RoleList.UpdateLabels(roleEntries)
    local rl = tod.gui.RoleList
    for i=1,15 do
        local lbl = rl.Labels[i]
        lbl:SetText(roleEntries[i])
    end
end

---------- PLAYER LIST ----------
tod.gui.PlayerList = {}

function tod.gui.PlayerList.Build(mainFrame)
    local pl = tod.gui.PlayerList
    local playerListFrame = CreateFrame("Frame", "ARWIC_TOD_playerListFrame", mainFrame)
    CreateFrameTexture(playerListFrame)
    playerListFrame:SetSize(200, 500)
    local titleBar = NewTitleBar(playerListFrame, "Player List")
    
    pl.Labels = {}
    local lastlbl = titleBar
    for i=1,15 do
        local lbl = NewLabel(playerListFrame, 18, i.." ...")
        lbl:SetPoint("TOP", lastlbl, "BOTTOM")
        lbl:SetPoint("LEFT", playerListFrame, "LEFT")
        lbl:SetJustifyH("LEFT")
        lastlbl = lbl
        table.insert(pl.Labels, lbl)
    end

    return playerListFrame
end

function tod.gui.PlayerList.UpdateLabels(players)
    local pl = tod.gui.PlayerList
    for i=1,15 do
        local lbl = pl.Labels[i]
        if lbl ~= nil and players[i] ~= nil then
            lbl:SetText(i .. " " .. players[i])
        end
    end
end

---------- BUILD ----------

function tod.gui.Build()
    -- dont remake the frame if it already exists
    if ARWIC_TOD_mainFrame ~= nil then return end

    -- main frame
    local mainFrame = CreateFrame("Frame", "ARWIC_TOD_mainFrame", UIParent)
    --table.insert(UISpecialFrames, mainFrame:GetName()) -- make frame close with escape
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:SetPoint("CENTER",0,0)
    mainFrame.texture = mainFrame:CreateTexture(nil, "BACKGROUND")
    mainFrame.texture:SetColorTexture(0.1, 0.1, 0.1, 0.9)
    mainFrame.texture:SetAllPoints(mainFrame)
    mainFrame:EnableMouse(true)
    mainFrame:SetMovable(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    mainFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    mainFrame:SetSize(1000,800)
    mainFrame:SetShown(false)

    -- title bar
    local titleBar = NewTitleBar(mainFrame, "Town of Darkshire")
    
    -- close button
    local closeButton = CreateFrame("BUTTON", "ARWIC_TOD_mainFrame_titleBar_closeButton", titleBar, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", 0, 0)
    closeButton:SetWidth(titleBar:GetHeight())
    closeButton:SetHeight(titleBar:GetHeight())
    closeButton:SetScript("OnClick", function()
        mainFrame:Hide()
    end)

    local topBarFrame = tod.gui.TopBar.Build(mainFrame)
    local graveyardFrame = tod.gui.Graveyard.Build(mainFrame)
    local roleListFrame = tod.gui.RoleList.Build(mainFrame)
    local chatFrame = tod.gui.Chat.Build(mainFrame)
    local infoFrame = tod.gui.Info.Build(mainFrame)
    local playerListFrame = tod.gui.PlayerList.Build(mainFrame)

    topBarFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT")
    topBarFrame:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT")
    topBarFrame:SetHeight(40)

    graveyardFrame:SetPoint("TOPLEFT", topBarFrame, "BOTTOMLEFT")
    graveyardFrame:SetWidth(200)
    graveyardFrame:SetHeight(300)
    
    roleListFrame:SetPoint("TOPLEFT", graveyardFrame, "TOPRIGHT")
    roleListFrame:SetPoint("BOTTOMLEFT", graveyardFrame, "BOTTOMRIGHT")
    roleListFrame:SetWidth(200)
    roleListFrame:SetHeight(300)

    chatFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT")
    chatFrame:SetWidth(500)
    chatFrame:SetHeight(300)

    infoFrame:SetPoint("TOPRIGHT", topBarFrame, "BOTTOMRIGHT")
    infoFrame:SetWidth(200)
    infoFrame:SetHeight(300)

    playerListFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT")
    playerListFrame:SetWidth(200)
    playerListFrame:SetHeight(300)
end

function tod.gui.Show()
    if ARWIC_TOD_mainFrame == nil then tod.gui.Build() end
    ARWIC_TOD_mainFrame:Show()
end