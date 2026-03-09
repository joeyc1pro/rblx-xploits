-- FlyNoClip Script by Claude
-- Features: Custom UI, Fly, NoClip toggles

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
local flySpeed = 50
local flyConnection = nil
local noClipConnection = nil
local bodyGyro = nil
local bodyVelocity = nil

-- ============================================================
-- UI SETUP
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyNoClipUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 260)
mainFrame.Position = UDim2.new(0, 20, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Accent border
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 80, 220)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Fix bottom corners of title bar
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

-- Title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "FlyNoClip"
titleLabel.TextColor3 = Color3.fromRGB(220, 210, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -34, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 90)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(200, 190, 255)
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
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Helper: create toggle button
local function createToggle(parent, yPos, labelText, color)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 48)
    row.Position = UDim2.new(0, 12, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(26, 24, 38)
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 32, 1, 0)
    icon.Position = UDim2.new(0, 8, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = labelText == "Fly" and "🚀" or "👻"
    icon.TextSize = 18
    icon.Font = Enum.Font.Gotham
    icon.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -90, 1, 0)
    lbl.Position = UDim2.new(0, 44, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(210, 205, 240)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Toggle pill
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 44, 0, 24)
    pill.Position = UDim2.new(1, -52, 0.5, -12)
    pill.BackgroundColor3 = Color3.fromRGB(50, 45, 70)
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = pill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(180, 170, 220)
    knob.BorderSizePixel = 0
    knob.Parent = pill

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- Click area
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    local isOn = false

    local function setToggle(state)
        isOn = state
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
        if isOn then
            TweenService:Create(pill, tweenInfo, {BackgroundColor3 = color}):Play()
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            TweenService:Create(knob, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(pill, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 45, 70)}):Play()
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            TweenService:Create(knob, tweenInfo, {BackgroundColor3 = Color3.fromRGB(180, 170, 220)}):Play()
        end
    end

    return btn, setToggle
end

-- Speed slider label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -24, 0, 20)
speedLabel.Position = UDim2.new(0, 12, 0, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Fly Speed: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(180, 170, 220)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = content

-- Speed slider track
local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1, -24, 0, 6)
sliderTrack.Position = UDim2.new(0, 12, 0, 34)
sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 45, 70)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = content

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = sliderTrack

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.4, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(100, 80, 220)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = sliderFill

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new(0.4, -8, 0.5, -8)
sliderKnob.BackgroundColor3 = Color3.fromRGB(140, 110, 255)
sliderKnob.Text = ""
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 5
sliderKnob.Parent = sliderTrack

local knobCorner2 = Instance.new("UICorner")
knobCorner2.CornerRadius = UDim.new(1, 0)
knobCorner2.Parent = sliderKnob

-- Slider drag logic
local dragging = false
sliderKnob.MouseButton1Down:Connect(function()
    dragging = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackSize = sliderTrack.AbsoluteSize.X
        local relX = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relX, -8, 0.5, -8)
        flySpeed = math.floor(10 + relX * 190)
        speedLabel.Text = "Fly Speed: " .. flySpeed
        if bodyVelocity then
            -- speed updates live
        end
    end
end)

-- Fly & NoClip toggles
local flyBtn, setFlyToggle = createToggle(content, 52, "Fly", Color3.fromRGB(80, 160, 255))
local noClipBtn, setNoClipToggle = createToggle(content, 112, "NoClip", Color3.fromRGB(160, 80, 255))

-- Keybind hint
local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, -24, 0, 30)
hintLabel.Position = UDim2.new(0, 12, 0, 172)
hintLabel.BackgroundColor3 = Color3.fromRGB(26, 24, 38)
hintLabel.BorderSizePixel = 0
hintLabel.Text = "F = Fly  |  G = NoClip"
hintLabel.TextColor3 = Color3.fromRGB(120, 110, 160)
hintLabel.TextSize = 11
hintLabel.Font = Enum.Font.Gotham
hintLabel.Parent = content

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 8)
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
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end

        bodyVelocity.Velocity = moveDir * flySpeed
        bodyGyro.CFrame = cf
    end)
end

local function disableFly()
    flyEnabled = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
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
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoClip()
    noClipEnabled = false
    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end
    -- Restore collision
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- ============================================================
-- BUTTON EVENTS
-- ============================================================

flyBtn.MouseButton1Click:Connect(function()
    if flyEnabled then
        disableFly()
        setFlyToggle(false)
    else
        enableFly()
        setFlyToggle(true)
    end
end)

noClipBtn.MouseButton1Click:Connect(function()
    if noClipEnabled then
        disableNoClip()
        setNoClipToggle(false)
    else
        enableNoClip()
        setNoClipToggle(true)
    end
end)

-- ============================================================
-- KEYBINDS
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flyEnabled then
            disableFly()
            setFlyToggle(false)
        else
            enableFly()
            setFlyToggle(true)
        end
    elseif input.KeyCode == Enum.KeyCode.G then
        if noClipEnabled then
            disableNoClip()
            setNoClipToggle(false)
        else
            enableNoClip()
            setNoClipToggle(true)
        end
    end
end)

-- ============================================================
-- MINIMIZE BUTTON
-- ============================================================

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if minimized then
        TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 220, 0, 40)}):Play()
        minBtn.Text = "+"
        content.Visible = false
    else
        content.Visible = true
        TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 220, 0, 260)}):Play()
        minBtn.Text = "−"
    end
end)

-- ============================================================
-- CHARACTER RESPAWN HANDLING
-- ============================================================

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")

    -- Re-enable active features on respawn
    if flyEnabled then
        task.wait(0.5)
        enableFly()
    end
    if noClipEnabled then
        task.wait(0.5)
        enableNoClip()
    end
end)

print("[FlyNoClip] Script loaded. Press F to toggle fly, G to toggle noclip.")
