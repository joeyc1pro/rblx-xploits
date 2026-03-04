----------------------------------------------------------------
-- Setup stuff
----------------------------------------------------------------

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Defaults / Shared Values
local speed = 60
local defaultWalkSpeed = 16
local defaultJumpPower = 50

-- Window
local MainWindow = Rayfield:CreateWindow({
   Name = "McDonalds Hub",
   LoadingTitle = "Loading McDonalds Hub...",
   LoadingSubtitle = "by Ronald",
   ToggleUIKeybind = "M",
   ConfigurationSaving = {
      Enabled = true,
      FileName = "McDonalds Hub"
   }
})

local MainTab = MainWindow:CreateTab("Main", 4483362458)

----------------------------------------------------------------
-- FLY
----------------------------------------------------------------
local flying = false
local gyro, vel, flyConn

MainTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      local char = player.Character or player.CharacterAdded:Wait()
      local hrp = char:WaitForChild("HumanoidRootPart")
      local hum = char:WaitForChild("Humanoid")

      flying = Value

      if flying then
         hum.PlatformStand = true

         gyro = Instance.new("BodyGyro")
         gyro.P = 100000
         gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
         gyro.Parent = hrp

         vel = Instance.new("BodyVelocity")
         vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
         vel.Parent = hrp

         flyConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local dir = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0,1,0) end

            vel.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
            gyro.CFrame = cam.CFrame
         end)
      else
         hum.PlatformStand = false
         if flyConn then flyConn:Disconnect() end
         if gyro then gyro:Destroy() end
         if vel then vel:Destroy() end
      end
   end
})

MainTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 200},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = speed,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      speed = Value
   end
})

----------------------------------------------------------------
-- NOCLIP
----------------------------------------------------------------
local noclip = false
local noclipConn

MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      noclip = Value

      if noclip then
         noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
               for _, v in ipairs(char:GetDescendants()) do
                  if v:IsA("BasePart") then
                     v.CanCollide = false
                  end
               end
            end
         end)
      else
         if noclipConn then noclipConn:Disconnect() end
         local char = player.Character
         if char then
            for _, v in ipairs(char:GetDescendants()) do
               if v:IsA("BasePart") then
                  v.CanCollide = true
               end
            end
         end
      end
   end
})

----------------------------------------------------------------
-- WALKSPEED
----------------------------------------------------------------
local walkEnabled = false

MainTab:CreateToggle({
   Name = "Enable WalkSpeed",
   CurrentValue = false,
   Flag = "WalkSpeedToggle",
   Callback = function(Value)
      walkEnabled = Value
      local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
      if hum then
         hum.WalkSpeed = Value and hum.WalkSpeed or defaultWalkSpeed
      end
   end
})

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = defaultWalkSpeed,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
      if hum and walkEnabled then
         hum.WalkSpeed = Value
      end
   end
})

----------------------------------------------------------------
-- JUMP POWER (FIXED)
----------------------------------------------------------------
local jumpEnabled = false
local jumpValue = defaultJumpPower

MainTab:CreateToggle({
   Name = "Enable JumpPower",
   CurrentValue = false,
   Flag = "JumpPowerToggle",
   Callback = function(Value)
      jumpEnabled = Value
      local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
      if not hum then return end

      if Value then
         hum.JumpPower = jumpValue
      else
         hum.JumpPower = defaultJumpPower
      end
   end
})

MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 10,
   Suffix = "Power",
   CurrentValue = defaultJumpPower,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      jumpValue = Value
      local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
      if hum and jumpEnabled then
         hum.JumpPower = Value
      end
   end
})


----------------------------------------------------------------
-- ANTI STUN
----------------------------------------------------------------
local antiStun = false
local antiStunConn

MainTab:CreateToggle({
   Name = "Anti Stun",
   CurrentValue = false,
   Flag = "AntiStunToggle",
   Callback = function(Value)
      antiStun = Value

      if antiStun then
         antiStunConn = RunService.Stepped:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
               hum.PlatformStand = false
               hum.Sit = false

               -- Force normal movement state
               hum:ChangeState(Enum.HumanoidStateType.Running)
            end
         end)
      else
         if antiStunConn then
            antiStunConn:Disconnect()
            antiStunConn = nil
         end
      end
   end,
})


----------------------------------------------------------------
-- FORCEFIELD (GODMODE)
----------------------------------------------------------------
local forcefield = nil

MainTab:CreateToggle({
   Name = "ForceField Godmode",
   CurrentValue = false,
   Flag = "ForceFieldToggle",
   Callback = function(Value)
      local char = player.Character
      if not char then return end

      if Value then
         if not char:FindFirstChild("ForceField") then
            forcefield = Instance.new("ForceField")
            forcefield.Visible =  -- set true if you want the bubble
            forcefield.Parent = char
         end
      else
         local ff = char:FindFirstChild("ForceField")
         if ff then ff:Destroy() end
      end
   end,
})


----------------------------------------------------------------
-- PRIVATE SERVER STRESS TEST (SAFE) jk it crashes the server
----------------------------------------------------------------
local stressEnabled = false
local stressParts = {}
local MAX_PARTS = 1000000        -- SAFE LIMIT (do NOT raise in public servers)
local SPAWN_PER_TICK = 1000

MainTab:CreateToggle({
   Name = "Game Crasher",
   CurrentValue = false,
   Flag = "StressTestToggle",
   Callback = function(Value)
      stressEnabled = Value

      if stressEnabled then
         task.spawn(function()
            while stressEnabled and #stressParts < MAX_PARTS do
               local char = player.Character
               local hrp = char and char:FindFirstChild("HumanoidRootPart")
               if not hrp then break end

               for i = 1, SPAWN_PER_TICK do
                  if #stressParts >= MAX_PARTS then break end

                  local p = Instance.new("Part")
                  p.Size = Vector3.new(2, 2, 2)
                  p.Anchored = false
                  p.CanCollide = true
                  p.Material = Enum.Material.Neon
                  p.Position = hrp.Position + Vector3.new(
                     math.random(-20,20),
                     math.random(5,20),
                     math.random(-20,20)
                  )
                  p.Parent = workspace

                  table.insert(stressParts, p)
               end

               task.wait(0.1)
            end
         end)
      else
         -- cleanup
         for _, p in ipairs(stressParts) do
            if p and p.Parent then
               p:Destroy()
            end
         end
         table.clear(stressParts)
      end
   end,
})


----------------------------------------------------------------
-- PLAYER ESP
----------------------------------------------------------------

-- CONFIG
local MAX_ESP_DISTANCE = 99999 -- studs
local SHOW_TEAMMATES = true

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local espEnabled = false
local espObjects = {}

-- REMOVE ESP
local function removeESP(player)
    if espObjects[player] then
        espObjects[player].Billboard:Destroy()
        espObjects[player] = nil
    end
end

-- CREATE ESP
local function createESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    if not SHOW_TEAMMATES and player.Team == LocalPlayer.Team then return end

    local char = player.Character
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not humanoid or not hrp then return end

    removeESP(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 220, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true

    -- Name + distance
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.35, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Parent = billboard

    -- Health bar background
    local healthBG = Instance.new("Frame")
    healthBG.Size = UDim2.new(1, -12, 0.2, 0)
    healthBG.Position = UDim2.new(0, 6, 0.42, 0)
    healthBG.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    healthBG.BorderSizePixel = 0
    healthBG.Parent = billboard
    Instance.new("UICorner", healthBG).CornerRadius = UDim.new(0, 6)

    -- Health fill
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBG
    Instance.new("UICorner", healthFill).CornerRadius = UDim.new(0, 6)

    -- HP text
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 0.25, 0)
    hpLabel.Position = UDim2.new(0, 0, 0.68, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.TextScaled = true
    hpLabel.Font = Enum.Font.SourceSans
    hpLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    hpLabel.TextStrokeTransparency = 0.2
    hpLabel.Parent = billboard

    billboard.Parent = head

    espObjects[player] = {
        Billboard = billboard,
        Name = nameLabel,
        HealthFill = healthFill,
        HP = hpLabel,
        Humanoid = humanoid,
        HRP = hrp
    }

    humanoid.Died:Connect(function()
        removeESP(player)
    end)
end

-- ENABLE ESP
local function enableESP()
    espEnabled = true

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            createESP(player)
        end

        player.CharacterAdded:Connect(function()
            if espEnabled then
                task.wait(1)
                createESP(player)
            end
        end)
    end
end

-- DISABLE ESP
local function disableESP()
    espEnabled = false
    for player in pairs(espObjects) do
        removeESP(player)
    end
end

-- UPDATE LOOP
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end

    local lchar = LocalPlayer.Character
    local lhrp = lchar and lchar:FindFirstChild("HumanoidRootPart")
    if not lhrp then return end

    for plr, data in pairs(espObjects) do
        if not plr.Character or not data.HRP or not data.Humanoid then
            removeESP(plr)
            continue
        end

        local dist = math.floor((data.HRP.Position - lhrp.Position).Magnitude)
        data.Billboard.Enabled = dist <= MAX_ESP_DISTANCE

        local hp = math.clamp(data.Humanoid.Health, 0, data.Humanoid.MaxHealth)
        local maxHp = data.Humanoid.MaxHealth
        local ratio = hp / maxHp

        data.Name.Text = plr.Name .. " | " .. dist .. " studs"
        data.HP.Text = math.floor(hp) .. " / " .. math.floor(maxHp)

        data.HealthFill.Size = UDim2.new(ratio, 0, 1, 0)
        data.HealthFill.BackgroundColor3 =
            Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)

     local Players = game:GetService("Players")
    end
end)



-- RAYFIELD TOGGLE
local ESPToggle = MainTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        if Value then
            enableESP()
        else
            disableESP()
        end
    end,
})
