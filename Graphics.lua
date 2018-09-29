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
    local topBarFrame = CreateFrame("Frame", "ARWIC_TOD_topBarFrame", mainFrame)
    CreateFrameTexture(topBarFrame)
    tod.gui.TopBar.lblMyName = NewLabel(topBarFrame, 20, "MY_NAME")
    tod.gui.TopBar.lblMyName:SetPoint("LEFT", topBarFrame)

    return topBarFrame
end

function tod.gui.TopBar.SetName(name)
    tod.gui.TopBar.lblMyName:SetText(name)
end

---------- GRAVEYARD ----------
tod.gui.Graveyard = {}

function tod.gui.Graveyard.Build(mainFrame)
    local graveyardFrame = CreateFrame("Frame", "ARWIC_TOD_graveyardFrame", mainFrame)
    CreateFrameTexture(graveyardFrame)
    local titleBar = NewTitleBar(graveyardFrame, "Graveyard")
    
    tod.gui.Graveyard.Labels = {}
    local lastlbl = titleBar
    for i=1,15 do
        local lbl = NewLabel(graveyardFrame, 18, "")
        lbl:SetPoint("TOP", lastlbl, "BOTTOM")
        lastlbl = lbl
        table.insert(tod.gui.Graveyard.Labels, lbl)
    end

    return graveyardFrame
end

function tod.gui.Graveyard.UpdateLabels(deadPlayers)
    local numDead = table_length(deadPlayers)
    for i=1,numDead do
        local lbl = tod.gui.Graveyard.Labels[i]
        local player = deadPlayers[i]
        lbl:SetText(foramt("%s (%s)", player.Name, player.Role.Name))
    end
    for i=numDead,15 do
        tod.gui.Graveyard.Labels[i]:SetText("")
    end
end

---------- CHAT ----------
tod.gui.Chat = {}

function tod.gui.Chat.Build(mainFrame)
    local chatFrame = CreateFrame("Frame", "ARWIC_TOD_chatFrame", mainFrame)
    CreateFrameTexture(chatFrame)
    local titleBar = NewTitleBar(chatFrame, "Chat")
    return chatFrame
end

---------- INFO ----------
tod.gui.Info = {}

function tod.gui.Info.Build(mainFrame)
    local infoFrame = CreateFrame("Frame", "ARWIC_TOD_infoFrame", mainFrame)
    CreateFrameTexture(infoFrame)
    infoFrame:SetSize(200, 500)
    tod.gui.Info.TitleBar, tod.gui.Info.TitleBarText = NewTitleBar(infoFrame, "ROLE_NAME")

    return infoFrame
end

function tod.gui.Info.SetRole(role_id)
    tod.gui.Info.TitleBarText:SetText(tod.roles[role_id].name)
end

---------- ROLE LIST ----------
tod.gui.RoleList = {}

function tod.gui.RoleList.Build(mainFrame)
    local roleListFrame = CreateFrame("Frame", "ARWIC_TOD_roleListFrame", mainFrame)
    CreateFrameTexture(roleListFrame)
    roleListFrame:SetSize(200, 500)
    local titleBar = NewTitleBar(roleListFrame, "Role List")
    
    tod.gui.RoleList.Labels = {}
    local lastlbl = titleBar
    for i=1,15 do
        local lbl = NewLabel(roleListFrame, 18, "...")
        lbl:SetPoint("TOP", lastlbl, "BOTTOM")
        lastlbl = lbl
        table.insert(tod.gui.RoleList.Labels, lbl)
    end

    return roleListFrame
end

-- sets all the labels in the role list, list of roles should contain "Town Investigative", "Random Town" etc. not exact names or role objects
function tod.gui.RoleList.UpdateLabels(roleEntries)
    for i=1,15 do
        local lbl = tod.gui.RoleList.Labels[i]
        lbl:SetText(roleEntries[i])
    end
end

---------- PLAYER LIST ----------
tod.gui.PlayerList = {}

function tod.gui.PlayerList.Build(mainFrame)
    local playerListFrame = CreateFrame("Frame", "ARWIC_TOD_playerListFrame", mainFrame)
    CreateFrameTexture(playerListFrame)
    playerListFrame:SetSize(200, 500)
    local titleBar = NewTitleBar(playerListFrame, "Player List")
    
    tod.gui.PlayerList.Labels = {}
    local lastlbl = titleBar
    for i=1,15 do
        local lbl = NewLabel(playerListFrame, 18, i.." ...")
        lbl:SetPoint("TOP", lastlbl, "BOTTOM")
        lastlbl = lbl
        table.insert(tod.gui.PlayerList.Labels, lbl)
    end

    return playerListFrame
end

function tod.gui.PlayerList.UpdateLabels(players)
    for i=1,15 do
        local lbl = tod.gui.PlayerList.Labels[i]
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