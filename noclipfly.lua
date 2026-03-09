-- FlyNoClip + ESP Script by Claude
-- Features: Fly, NoClip, Player ESP, Bright UI, No Shadows

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- State
local flyEnabled = false
local noClipEnabled = false
local espEnabled = false
local flySpeed = 50
local flyConnection = nil
local noClipConnection = nil
local espConnection = nil
local bodyGyro = nil
local bodyVelocity = nil
local espBoxes = {}

-- ============================================================
-- COLORS (bright/light theme)
-- ============================================================
local C = {
    bg        = Color3.fromRGB(245, 245, 255),
    titleBg   = Color3.fromRGB(230, 228, 255),
    row       = Color3.fromRGB(235, 233, 252),
    border    = Color3.fromRGB(180, 160, 255),
    accent    = Color3.fromRGB(110, 80, 230),
    accentOff = Color3.fromRGB(190, 185, 210),
    text      = Color3.fromRGB(40, 30, 80),
    subtext   = Color3.fromRGB(110, 100, 160),
    white     = Color3.fromRGB(255, 255, 255),
    minBtn    = Color3.fromRGB(210, 205, 240),
    hint      = Color3.fromRGB(220, 217, 245),
}

-- ============================================================
-- REMOVE SHADOWS & BRIGHTEN WORLD
-- ============================================================
local lighting = game:GetService("Lighting")
lighting.GlobalShadows = false
lighting.Brightness = 3
lighting.Ambient = Color3.fromRGB(180, 180, 180)
lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
for _, effect in ipairs(lighting:GetChildren()) do
    if effect:IsA("ShadowMap") or effect:IsA("DepthOfField") or effect:IsA("BloomEffect") then
        pcall(function() effect.Enabled = false end)
    end
end

-- ============================================================
-- UI SETUP
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyNoClipUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 230, 0, 310)
mainFrame.Position = UDim2.new(0, 20, 0.5, -155)
mainFrame.BackgroundColor3 = C.bg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = C.border
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = C.titleBg
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = C.titleBg
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "FlyNoClip"
titleLabel.TextColor3 = C.accent
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -36, 0.5, -14)
minBtn.BackgroundColor3 = C.minBtn
minBtn.Text = "-"
minBtn.TextColor3 = C.accent
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

-- Content frame
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -42)
content.Position = UDim2.new(0, 0, 0, 42)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- ============================================================
-- HELPER: toggle row
-- ============================================================
local function createToggle(parent, yPos, labelText, onColor)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 50)
    row.Position = UDim2.new(0, 12, 0, yPos)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = C.border
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.5
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 44, 0, 24)
    pill.Position = UDim2.new(1, -54, 0.5, -12)
    pill.BackgroundColor3 = C.accentOff
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = pill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.Parent = pill

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    local function setToggle(state)
        local ti = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
        if state then
            TweenService:Create(pill, ti, {BackgroundColor3 = onColor}):Play()
            TweenService:Create(knob, ti, {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
        else
            TweenService:Create(pill, ti, {BackgroundColor3 = C.accentOff}):Play()
            TweenService:Create(knob, ti, {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
        end
    end

    return btn, setToggle
end

-- ============================================================
-- SPEED SLIDER
-- ============================================================

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -24, 0, 20)
speedLabel.Position = UDim2.new(0, 14, 0, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Fly Speed: " .. flySpeed
speedLabel.TextColor3 = C.text
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = content

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1, -24, 0, 6)
sliderTrack.Position = UDim2.new(0, 12, 0, 34)
sliderTrack.BackgroundColor3 = C.accentOff
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = content

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = sliderTrack

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.22, 0, 1, 0)
sliderFill.BackgroundColor3 = C.accent
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = sliderFill

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new(0.22, -8, 0.5, -8)
sliderKnob.BackgroundColor3 = C.accent
sliderKnob.Text = ""
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 5
sliderKnob.Parent = sliderTrack

local knobCorner2 = Instance.new("UICorner")
knobCorner2.CornerRadius = UDim.new(1, 0)
knobCorner2.Parent = sliderKnob

local dragging = false
sliderKnob.MouseButton1Down:Connect(function() dragging = true end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relX, -8, 0.5, -8)
        flySpeed = math.floor(10 + relX * 190)
        speedLabel.Text = "Fly Speed: " .. flySpeed
    end
end)

-- ============================================================
-- TOGGLE BUTTONS
-- ============================================================

local flyBtn,    setFlyToggle    = createToggle(content, 50,  "Fly",        Color3.fromRGB(80, 160, 255))
local noClipBtn, setNoClipToggle = createToggle(content, 112, "NoClip",     Color3.fromRGB(160, 80, 255))
local espBtn,    setEspToggle    = createToggle(content, 174, "Player ESP", Color3.fromRGB(255, 100, 100))

local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, -24, 0, 28)
hintLabel.Position = UDim2.new(0, 12, 0, 238)
hintLabel.BackgroundColor3 = C.hint
hintLabel.BorderSizePixel = 0
hintLabel.Text = "F = Fly   G = NoClip   H = ESP"
hintLabel.TextColor3 = C.subtext
hintLabel.TextSize = 11
hintLabel.Font = Enum.Font.Gotham
hintLabel.Parent = content

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 6)
hintCorner.Parent = hintLabel

-- ============================================================
-- FLY LOGIC
-- ============================================================

local function enableFly()
    flyEnabled = true
    humanoid.PlatformStand = true

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.Parent = rootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = rootPart

    local camera = workspace.CurrentCamera
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local moveDir = Vector3.zero
        local cf = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        bodyVelocity.Velocity = moveDir * flySpeed
        bodyGyro.CFrame = cf
    end)
end

local function disableFly()
    flyEnabled = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    humanoid.PlatformStand = false
end

-- ============================================================
-- NOCLIP LOGIC
-- ============================================================

local function enableNoClip()
    noClipEnabled = true
    noClipConnection = RunService.Stepped:Connect(function()
        if not noClipEnabled then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function disableNoClip()
    noClipEnabled = false
    if noClipConnection then noClipConnection:Disconnect(); noClipConnection = nil end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

-- ============================================================
-- ESP LOGIC
-- ============================================================

local ESP_COLORS = {
    Color3.fromRGB(255, 80,  80),
    Color3.fromRGB(80,  200, 255),
    Color3.fromRGB(100, 255, 120),
    Color3.fromRGB(255, 200, 60),
    Color3.fromRGB(220, 80,  255),
    Color3.fromRGB(255, 140, 60),
}
local colorIndex = 0
local function nextColor()
    colorIndex = (colorIndex % #ESP_COLORS) + 1
    return ESP_COLORS[colorIndex]
end

local function createEspForPlayer(target)
    if target == player then return end
    if espBoxes[target] then return end

    local espColor = nextColor()

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. target.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 90, 0, 120)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    billboard.ResetOnSpawn = false
    billboard.Enabled = false

    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = target.Name
    nameLabel.TextColor3 = espColor
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard

    -- Distance
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 20)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "? studs"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = billboard

    -- Box (4 border lines)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 1, -40)
    box.Position = UDim2.new(0, 0, 0, 40)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = billboard

    local function makeLine(size, pos)
        local f = Instance.new("Frame")
        f.Size = size
        f.Position = pos
        f.BackgroundColor3 = espColor
        f.BorderSizePixel = 0
        f.Parent = box
    end
    makeLine(UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0, 0))        -- top
    makeLine(UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 1, -2))       -- bottom
    makeLine(UDim2.new(0, 2, 1, 0), UDim2.new(0, 0, 0, 0))        -- left
    makeLine(UDim2.new(0, 2, 1, 0), UDim2.new(1, -2, 0, 0))       -- right

    espBoxes[target] = { billboard = billboard, distLabel = distLabel }

    local function attachTo(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            billboard.Adornee = hrp
            billboard.Parent = hrp
            billboard.Enabled = true
        end
    end

    if target.Character then attachTo(target.Character) end
    target.CharacterAdded:Connect(attachTo)
end

local function removeEspForPlayer(target)
    local data = espBoxes[target]
    if data then
        data.billboard:Destroy()
        espBoxes[target] = nil
    end
end

local function enableEsp()
    espEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do
        createEspForPlayer(p)
    end

    espConnection = RunService.RenderStepped:Connect(function()
        local myRoot = character:FindFirstChild("HumanoidRootPart")
        for target, data in pairs(espBoxes) do
            local targetChar = target.Character
            if targetChar and myRoot then
                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                local hum = targetChar:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local dist = math.floor((myRoot.Position - hrp.Position).Magnitude)
                    data.distLabel.Text = dist .. " studs"
                    data.billboard.Enabled = true
                else
                    data.billboard.Enabled = false
                end
            else
                data.billboard.Enabled = false
            end
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        if espEnabled then createEspForPlayer(p) end
    end)
    Players.PlayerRemoving:Connect(function(p)
        removeEspForPlayer(p)
    end)
end

local function disableEsp()
    espEnabled = false
    if espConnection then espConnection:Disconnect(); espConnection = nil end
    for target, _ in pairs(espBoxes) do
        removeEspForPlayer(target)
    end
end

-- ============================================================
-- BUTTON EVENTS
-- ============================================================

flyBtn.MouseButton1Click:Connect(function()
    if flyEnabled then disableFly(); setFlyToggle(false)
    else enableFly(); setFlyToggle(true) end
end)

noClipBtn.MouseButton1Click:Connect(function()
    if noClipEnabled then disableNoClip(); setNoClipToggle(false)
    else enableNoClip(); setNoClipToggle(true) end
end)

espBtn.MouseButton1Click:Connect(function()
    if espEnabled then disableEsp(); setEspToggle(false)
    else enableEsp(); setEspToggle(true) end
end)

-- ============================================================
-- KEYBINDS
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flyEnabled then disableFly(); setFlyToggle(false)
        else enableFly(); setFlyToggle(true) end
    elseif input.KeyCode == Enum.KeyCode.G then
        if noClipEnabled then disableNoClip(); setNoClipToggle(false)
        else enableNoClip(); setNoClipToggle(true) end
    elseif input.KeyCode == Enum.KeyCode.H then
        if espEnabled then disableEsp(); setEspToggle(false)
        else enableEsp(); setEspToggle(true) end
    end
end)

-- ============================================================
-- MINIMIZE
-- ============================================================

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if minimized then
        content.Visible = false
        TweenService:Create(mainFrame, ti, {Size = UDim2.new(0, 230, 0, 42)}):Play()
        minBtn.Text = "+"
    else
        content.Visible = true
        TweenService:Create(mainFrame, ti, {Size = UDim2.new(0, 230, 0, 310)}):Play()
        minBtn.Text = "-"
    end
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    if flyEnabled then enableFly() end
    if noClipEnabled then enableNoClip() end
end)

print("[FlyNoClip] Loaded. F=Fly | G=NoClip | H=ESP")
