-- ================================================
--                   RIVALS ESP
--       Toggle with RightShift | Roblox Script
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ================================================
--                   CONFIG
-- ================================================
local Config = {
    ToggleKey = Enum.KeyCode.RightShift,
    
    -- Box ESP
    BoxEnabled = true,
    BoxColor = Color3.fromRGB(255, 60, 60),
    BoxThickness = 1.5,

    -- Name ESP
    NameEnabled = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 13,

    -- Health Bar
    HealthBarEnabled = true,

    -- Distance
    DistanceEnabled = true,
    DistanceColor = Color3.fromRGB(180, 180, 180),

    -- Tracer
    TracerEnabled = true,
    TracerColor = Color3.fromRGB(255, 60, 60),
    TracerThickness = 1,

    -- Chams (highlight)
    ChamsEnabled = true,
    ChamsColor = Color3.fromRGB(255, 40, 40),
    ChamsTransparency = 0.4,

    -- Max distance to render (studs)
    MaxDistance = 1000,
}

-- ================================================
--                   UI PANEL
-- ================================================
local ESPEnabled = false

-- Remove old GUI if exists
if CoreGui:FindFirstChild("RivalsESP_GUI") then
    CoreGui:FindFirstChild("RivalsESP_GUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsESP_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- ---- Main Panel ----
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 240, 0, 320)
Panel.Position = UDim2.new(0, 20, 0.5, -160)
Panel.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true
Panel.Visible = false
Panel.Parent = ScreenGui

-- Glow border effect
local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(220, 30, 30)
Border.Thickness = 1.5
Border.Parent = Panel

local CornerPanel = Instance.new("UICorner")
CornerPanel.CornerRadius = UDim.new(0, 6)
CornerPanel.Parent = Panel

-- ---- Title Bar ----
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Panel

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = TitleBar

-- Square off bottom corners of title bar
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚔  RIVALS ESP"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Toggle key hint in title
local KeyHint = Instance.new("TextLabel")
KeyHint.Size = UDim2.new(0, 90, 1, 0)
KeyHint.Position = UDim2.new(1, -95, 0, 0)
KeyHint.BackgroundTransparency = 1
KeyHint.Text = "[RShift]"
KeyHint.TextColor3 = Color3.fromRGB(255, 180, 180)
KeyHint.TextSize = 10
KeyHint.Font = Enum.Font.Gotham
KeyHint.TextXAlignment = Enum.TextXAlignment.Right
KeyHint.Parent = TitleBar

-- ---- Status Indicator ----
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, -20, 0, 34)
StatusFrame.Position = UDim2.new(0, 10, 0, 46)
StatusFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = Panel
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 4)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusFrame
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 1, 0)
StatusLabel.Position = UDim2.new(0, 30, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ESP: DISABLED"
StatusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFrame

-- ---- Toggle Buttons ----
local function CreateToggle(parent, label, yPos, configKey, defaultState)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -20, 0, 28)
    Row.Position = UDim2.new(0, 10, 0, yPos)
    Row.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Row.BorderSizePixel = 0
    Row.Parent = parent
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -50, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local ToggleTrack = Instance.new("Frame")
    ToggleTrack.Size = UDim2.new(0, 34, 0, 16)
    ToggleTrack.Position = UDim2.new(1, -44, 0.5, -8)
    ToggleTrack.BackgroundColor3 = defaultState and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(50, 50, 60)
    ToggleTrack.BorderSizePixel = 0
    ToggleTrack.Parent = Row
    Instance.new("UICorner", ToggleTrack).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = defaultState and UDim2.new(0, 20, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleTrack
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = defaultState

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Row

    Btn.MouseButton1Click:Connect(function()
        state = not state
        Config[configKey] = state
        ToggleTrack.BackgroundColor3 = state and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(50, 50, 60)
        Knob.Position = state and UDim2.new(0, 20, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    end)

    return Row
end

-- Divider
local function Divider(parent, yPos)
    local D = Instance.new("Frame")
    D.Size = UDim2.new(1, -20, 0, 1)
    D.Position = UDim2.new(0, 10, 0, yPos)
    D.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    D.BorderSizePixel = 0
    D.Parent = parent
end

local function SectionLabel(parent, text, yPos)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -20, 0, 18)
    L.Position = UDim2.new(0, 10, 0, yPos)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(200, 30, 30)
    L.TextSize = 10
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
end

SectionLabel(Panel, "VISUAL",           88)
CreateToggle(Panel, "Bounding Box",      104, "BoxEnabled",       Config.BoxEnabled)
CreateToggle(Panel, "Player Names",      136, "NameEnabled",      Config.NameEnabled)
CreateToggle(Panel, "Health Bar",        168, "HealthBarEnabled", Config.HealthBarEnabled)
CreateToggle(Panel, "Distance",          200, "DistanceEnabled",  Config.DistanceEnabled)

Divider(Panel, 232)
SectionLabel(Panel, "ADVANCED",         236)
CreateToggle(Panel, "Tracers",           252, "TracerEnabled",    Config.TracerEnabled)
CreateToggle(Panel, "Highlight (Chams)", 284, "ChamsEnabled",     Config.ChamsEnabled)

-- Player count
local PlayerCount = Instance.new("TextLabel")
PlayerCount.Size = UDim2.new(1, -20, 0, 16)
PlayerCount.Position = UDim2.new(0, 10, 1, -20)
PlayerCount.BackgroundTransparency = 1
PlayerCount.Text = "Players: 0"
PlayerCount.TextColor3 = Color3.fromRGB(70, 70, 80)
PlayerCount.TextSize = 10
PlayerCount.Font = Enum.Font.Gotham
PlayerCount.TextXAlignment = Enum.TextXAlignment.Right
PlayerCount.Parent = Panel

-- ================================================
--                 ESP DRAWING
-- ================================================
local ESPObjects = {} -- [Player] = { drawings... }
local Highlights  = {} -- [Player] = Highlight instance

local function NewDrawing(class, props)
    local d = Drawing.new(class)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local drawings = {}

    -- Box (4 lines)
    drawings.BoxLines = {}
    for i = 1, 4 do
        local success, line = pcall(function()
            return NewDrawing("Line", {
                Visible = false,
                Color   = Config.BoxColor,
                Thickness = Config.BoxThickness,
            })
        end)
        if success then
            drawings.BoxLines[i] = line
        end
    end

    -- Name label
    local success, name = pcall(function()
        return NewDrawing("Text", {
            Visible  = false,
            Color    = Config.NameColor,
            Size     = Config.NameSize,
            Center   = true,
            Outline  = true,
            OutlineColor = Color3.fromRGB(0,0,0),
            Text     = player.Name,
        })
    end)
    if success then drawings.Name = name end

    -- Distance label
    success, name = pcall(function()
        return NewDrawing("Text", {
            Visible  = false,
            Color    = Config.DistanceColor,
            Size     = 10,
            Center   = true,
            Outline  = true,
            OutlineColor = Color3.fromRGB(0,0,0),
        })
    end)
    if success then drawings.Distance = name end

    -- Health bar (2 lines: background + foreground)
    success, name = pcall(function()
        return NewDrawing("Line", {
            Visible   = false,
            Color     = Color3.fromRGB(30,30,30),
            Thickness = 4,
        })
    end)
    if success then drawings.HealthBG = name end

    success, name = pcall(function()
        return NewDrawing("Line", {
            Visible   = false,
            Color     = Color3.fromRGB(50,230,50),
            Thickness = 3,
        })
    end)
    if success then drawings.HealthFG = name end

    -- Tracer
    success, name = pcall(function()
        return NewDrawing("Line", {
            Visible   = false,
            Color     = Config.TracerColor,
            Thickness = Config.TracerThickness,
        })
    end)
    if success then drawings.Tracer = name end

    ESPObjects[player] = drawings

    -- Highlight (Chams) - wait for character to load
    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local ok, hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "ESPHighlight"
            h.FillColor = Config.ChamsColor
            h.FillTransparency = Config.ChamsTransparency
            h.OutlineColor = Config.BoxColor
            h.OutlineTransparency = 0
            h.Adornee = character
            h.Parent = character
            return h
        end)
        if ok and hl then 
            Highlights[player] = hl 
        end
    end)
end

local function RemoveESPForPlayer(player)
    local drawings = ESPObjects[player]
    if drawings then
        for _, line in ipairs(drawings.BoxLines or {}) do
            pcall(function() line:Remove() end)
        end
        for _, key in ipairs({"Name","Distance","HealthBG","HealthFG","Tracer"}) do
            if drawings[key] then pcall(function() drawings[key]:Remove() end) end
        end
        ESPObjects[player] = nil
    end

    local hl = Highlights[player]
    if hl then
        pcall(function() hl:Destroy() end)
        Highlights[player] = nil
    end
end

local function HideESP(player)
    local d = ESPObjects[player]
    if not d then return end
    
    if d.BoxLines then
        for _, l in ipairs(d.BoxLines) do 
            if l then pcall(function() l.Visible = false end) end
        end
    end
    
    if d.Name then pcall(function() d.Name.Visible = false end) end
    if d.Distance then pcall(function() d.Distance.Visible = false end) end
    if d.HealthBG then pcall(function() d.HealthBG.Visible = false end) end
    if d.HealthFG then pcall(function() d.HealthFG.Visible = false end) end
    if d.Tracer then pcall(function() d.Tracer.Visible = false end) end
    
    local hl = Highlights[player]
    if hl then 
        pcall(function() 
            hl.Enabled = false
        end) 
    end
end

-- ================================================
--              WORLD → SCREEN UTILS
-- ================================================
local function GetCorners(cf, size)
    local corners = {}
    local hw, hh, hd = size.X/2, size.Y/2, size.Z/2
    local offsets = {
        Vector3.new(-hw, -hh, -hd), Vector3.new( hw, -hh, -hd),
        Vector3.new(-hw,  hh, -hd), Vector3.new( hw,  hh, -hd),
        Vector3.new(-hw, -hh,  hd), Vector3.new( hw, -hh,  hd),
        Vector3.new(-hw,  hh,  hd), Vector3.new( hw,  hh,  hd),
    }
    for _, offset in ipairs(offsets) do
        table.insert(corners, cf:PointToWorldSpace(offset))
    end
    return corners
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetBoundingBox(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local allOnScreen = false

    -- Use character bounding box
    local parts = {}
    for _, p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            table.insert(parts, p)
        end
    end
    if #parts == 0 then table.insert(parts, root) end

    for _, part in ipairs(parts) do
        local corners = GetCorners(part.CFrame, part.Size)
        for _, corner in ipairs(corners) do
            local screenPos, onScreen, depth = WorldToScreen(corner)
            if onScreen and depth > 0 then
                allOnScreen = true
                minX = math.min(minX, screenPos.X)
                minY = math.min(minY, screenPos.Y)
                maxX = math.max(maxX, screenPos.X)
                maxY = math.max(maxY, screenPos.Y)
            end
        end
    end

    if not allOnScreen then return nil end

    local pad = 2
    return {
        topLeft     = Vector2.new(minX - pad, minY - pad),
        topRight    = Vector2.new(maxX + pad, minY - pad),
        bottomLeft  = Vector2.new(minX - pad, maxY + pad),
        bottomRight = Vector2.new(maxX + pad, maxY + pad),
    }
end

-- ================================================
--              MAIN UPDATE LOOP
-- ================================================
local function UpdatePlayer(player)
    local d = ESPObjects[player]
    if not d then return end

    if not ESPEnabled then
        HideESP(player)
        return
    end

    local character = player.Character
    if not character then
        HideESP(player)
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        HideESP(player)
        return
    end

    local rootPos = root.Position
    local distance = (Camera.CFrame.Position - rootPos).Magnitude

    if distance > Config.MaxDistance then
        HideESP(player)
        return
    end

    local bb = GetBoundingBox(character)
    local rootScreen, onScreen, _ = WorldToScreen(rootPos)

    if not onScreen or not bb then
        HideESP(player)
        return
    end

    -- ---- BOX ----
    if Config.BoxEnabled then
        local tl, tr, bl, br = bb.topLeft, bb.topRight, bb.bottomLeft, bb.bottomRight
        d.BoxLines[1].From    = tl; d.BoxLines[1].To = tr  -- top
        d.BoxLines[2].From    = bl; d.BoxLines[2].To = br  -- bottom
        d.BoxLines[3].From    = tl; d.BoxLines[3].To = bl  -- left
        d.BoxLines[4].From    = tr; d.BoxLines[4].To = br  -- right
        for _, l in ipairs(d.BoxLines) do
            l.Color   = Config.BoxColor
            l.Thickness = Config.BoxThickness
            l.Visible = true
        end
    else
        for _, l in ipairs(d.BoxLines) do l.Visible = false end
    end

    -- ---- NAME ----
    if Config.NameEnabled then
        d.Name.Position = Vector2.new(bb.topLeft.X + (bb.topRight.X - bb.topLeft.X)/2, bb.topLeft.Y - 16)
        d.Name.Text     = player.Name
        d.Name.Color    = Config.NameColor
        d.Name.Visible  = true
    else
        d.Name.Visible  = false
    end

    -- ---- DISTANCE ----
    if Config.DistanceEnabled then
        local distStr = string.format("[%d]", math.floor(distance))
        d.Distance.Position = Vector2.new(bb.topLeft.X + (bb.topRight.X - bb.topLeft.X)/2, bb.bottomLeft.Y + 2)
        d.Distance.Text     = distStr
        d.Distance.Color    = Config.DistanceColor
        d.Distance.Visible  = true
    else
        d.Distance.Visible  = false
    end

    -- ---- HEALTH BAR ----
    if Config.HealthBarEnabled then
        local hp    = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local barH  = bb.bottomLeft.Y - bb.topLeft.Y
        local barX  = bb.topLeft.X - 6
        local topY  = bb.topLeft.Y
        local botY  = bb.bottomLeft.Y

        d.HealthBG.From    = Vector2.new(barX, topY)
        d.HealthBG.To      = Vector2.new(barX, botY)
        d.HealthBG.Color   = Color3.fromRGB(20,20,20)
        d.HealthBG.Thickness = 4
        d.HealthBG.Visible = true

        local hpColor = Color3.fromRGB(math.floor((1-hp)*255), math.floor(hp*200)+55, 30)
        d.HealthFG.From    = Vector2.new(barX, botY)
        d.HealthFG.To      = Vector2.new(barX, botY - barH * hp)
        d.HealthFG.Color   = hpColor
        d.HealthFG.Thickness = 3
        d.HealthFG.Visible = true
    else
        d.HealthBG.Visible = false
        d.HealthFG.Visible = false
    end

    -- ---- TRACER ----
    if Config.TracerEnabled and d.Tracer then
        local screenSize = Camera.ViewportSize
        pcall(function()
            d.Tracer.From    = Vector2.new(screenSize.X / 2, screenSize.Y)
            d.Tracer.To      = Vector2.new(rootScreen.X, rootScreen.Y)
            d.Tracer.Color   = Config.TracerColor
            d.Tracer.Thickness = Config.TracerThickness
            d.Tracer.Visible = true
        end)
    elseif d.Tracer then
        pcall(function() d.Tracer.Visible = false end)
    end

    -- ---- CHAMS / HIGHLIGHT ----
    local hl = Highlights[player]
    if hl then
        pcall(function()
            if Config.ChamsEnabled then
                hl.FillColor = Config.ChamsColor
                hl.FillTransparency = Config.ChamsTransparency
                hl.OutlineColor = Config.BoxColor
                hl.OutlineTransparency = 0
                hl.Enabled = true
                if hl.Adornee ~= character then
                    hl.Adornee = character
                end
            else
                hl.Enabled = false
            end
        end)
    end
end

-- ================================================
--          PLAYER MANAGEMENT
-- ================================================
local function OnPlayerAdded(player)
    CreateESPForPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        -- Recreate highlight for new character
        local old_hl = Highlights[player]
        if old_hl then
            pcall(function() old_hl:Destroy() end)
        end
        
        local ok, hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "ESPHighlight"
            h.FillColor = Config.ChamsColor
            h.FillTransparency = Config.ChamsTransparency
            h.OutlineColor = Config.BoxColor
            h.OutlineTransparency = 0
            h.Adornee = character
            h.Enabled = ESPEnabled and Config.ChamsEnabled
            h.Parent = character
            return h
        end)
        if ok and hl then 
            Highlights[player] = hl 
        end
    end)
end

local function OnPlayerRemoving(player)
    RemoveESPForPlayer(player)
end

for _, player in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end
Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- ================================================
--            UPDATE & TOGGLE LOGIC
-- ================================================
local function UpdateStatus()
    if ESPEnabled then
        StatusLabel.Text = "ESP: ACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 230, 80)
        StatusDot.BackgroundColor3 = Color3.fromRGB(80, 230, 80)
    else
        StatusLabel.Text = "ESP: DISABLED"
        StatusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.ToggleKey then
        Panel.Visible = not Panel.Visible
        if not Panel.Visible then
            -- Also disable ESP when hiding panel
            ESPEnabled = false
            UpdateStatus()
            for _, player in ipairs(Players:GetPlayers()) do
                HideESP(player)
            end
        end
    end
end)

-- Master ESP toggle button (click title to toggle ESP on/off)
local ESPToggleBtn = Instance.new("TextButton")
ESPToggleBtn.Size = UDim2.new(0, 60, 0, 22)
ESPToggleBtn.Position = UDim2.new(0.5, -30, 0, 42)
ESPToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ESPToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ESPToggleBtn.Text = "TOGGLE"
ESPToggleBtn.TextSize = 10
ESPToggleBtn.Font = Enum.Font.GothamBold
ESPToggleBtn.BorderSizePixel = 0
ESPToggleBtn.Parent = nil -- not shown, handled by StatusFrame click

-- Make StatusFrame clickable
local StatusBtn = Instance.new("TextButton")
StatusBtn.Size = UDim2.new(1,0,1,0)
StatusBtn.BackgroundTransparency = 1
StatusBtn.Text = ""
StatusBtn.Parent = StatusFrame

StatusBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    UpdateStatus()
    if not ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            HideESP(player)
        end
    end
end)

-- Render loop
RunService.RenderStepped:Connect(function()
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            count = count + 1
            UpdatePlayer(player)
        end
    end
    PlayerCount.Text = "Players: " .. count
end)

-- Show panel on start
Panel.Visible = true

UpdateStatus()

print("[RivalsESP] Loaded! Press RightShift to show/hide panel. Click the status bar to toggle ESP.")
