--[[
    Fish It! Script Hub v1.0
    Native Roblox UI - Complete All-in-One
    Compatible: Xeno (PC) & Delta (Mobile)
    Author: fahmi1804
]]

-- Dual Execute - Remove old GUI
pcall(function()
    if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FishItHub") then
        game:GetService("Players").LocalPlayer.PlayerGui.FishItHub:Destroy()
    end
end)

wait(0.5)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Global Config
getgenv().FishIt = getgenv().FishIt or {
    AutoFish = false,
    AutoSell = false,
    InstantCatch = false,
    AutoEquipBestRod = false,
    AntiAFK = false,
    
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    
    SellCommon = true,
    SellRare = false,
    SellLegendary = false
}

-- Notification
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🐟 " .. title;
        Text = text;
        Duration = duration or 3;
    })
end

notify("Fish It!", "Script loading...", 2)

-- ========================================
-- AUTO FISH MODULE
-- ========================================
local AutoFishModule = {
    Active = false,
    Fishing = false
}

function AutoFishModule:GetRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Check equipped
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():match("rod") or tool.Name:lower():match("fish")) then
            return tool
        end
    end
    
    -- Check backpack
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():match("rod") or tool.Name:lower():match("fish")) then
            return tool
        end
    end
    
    return nil
end

function AutoFishModule:Cast()
    local rod = self:GetRod()
    if not rod then 
        notify("Auto Fish", "No rod found!", 2)
        return false 
    end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Equip rod
    if rod.Parent ~= char then
        char.Humanoid:EquipTool(rod)
        task.wait(0.5)
    end
    
    -- Cast
    pcall(function()
        rod:Activate()
    end)
    
    self.Fishing = true
    return true
end

function AutoFishModule:Reel()
    pcall(function()
        local rod = self:GetRod()
        if rod then
            rod:Activate()
        end
    end)
    self.Fishing = false
end

function AutoFishModule:CheckBite()
    local gui = LocalPlayer.PlayerGui
    
    -- Check for catch UI
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            local text = v.Text:lower()
            if text:match("catch") or text:match("!") or text:match("reel") then
                return true
            end
        end
    end
    
    return false
end

function AutoFishModule:Start()
    self.Active = true
    notify("Auto Fish", "Started!", 2)
    
    spawn(function()
        while self.Active and task.wait(0.8) do
            if not getgenv().FishIt.AutoFish then
                self.Active = false
                break
            end
            
            -- Cast if not fishing
            if not self.Fishing then
                self:Cast()
                task.wait(1.5)
            end
            
            -- Check bite
            if self:CheckBite() then
                if getgenv().FishIt.InstantCatch then
                    self:Reel()
                else
                    task.wait(0.5)
                    self:Reel()
                end
                task.wait(2)
            end
        end
        notify("Auto Fish", "Stopped!", 2)
    end)
end

-- ========================================
-- MERCHANT MODULE
-- ========================================
local MerchantModule = {}

function MerchantModule:Find()
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") then
            if npc.Name:lower():match("merchant") or npc.Name:lower():match("shop") then
                return npc
            end
        end
    end
    return nil
end

function MerchantModule:Teleport()
    local merchant = self:Find()
    if not merchant then
        notify("Merchant", "Not found!", 2)
        return
    end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = merchant:GetPivot() * CFrame.new(0, 3, 5)
        notify("Merchant", "Teleported!", 2)
    end
end

-- ========================================
-- TELEPORT MODULE
-- ========================================
local TeleportModule = {}

function TeleportModule:To(position)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

function TeleportModule:Spawn()
    local spawn = workspace:FindFirstChild("SpawnLocation")
    if spawn then
        self:To(spawn.Position + Vector3.new(0, 5, 0))
        notify("Teleport", "Spawn!", 1)
    end
end

-- ========================================
-- PLAYER MODS
-- ========================================

-- WalkSpeed/JumpPower
spawn(function()
    while task.wait(0.5) do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = getgenv().FishIt.WalkSpeed
            char.Humanoid.JumpPower = getgenv().FishIt.JumpPower
        end
    end
end)

-- Noclip
RunService.Heartbeat:Connect(function()
    if getgenv().FishIt.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Fly
local Flying = false
local FlyBody = nil

function StartFly()
    local char = LocalPlayer.Character
    if not char or Flying then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    Flying = true
    
    FlyBody = Instance.new("BodyVelocity")
    FlyBody.Parent = hrp
    FlyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBody.Velocity = Vector3.new(0, 0, 0)
    
    spawn(function()
        while getgenv().FishIt.Fly and task.wait() do
            if not FlyBody then break end
            
            local cam = workspace.CurrentCamera
            local speed = getgenv().FishIt.FlySpeed
            local vel = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vel = vel + (cam.CFrame.LookVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vel = vel - (cam.CFrame.LookVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vel = vel - (cam.CFrame.RightVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vel = vel + (cam.CFrame.RightVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, speed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                vel = vel - Vector3.new(0, speed, 0)
            end
            
            FlyBody.Velocity = vel
        end
        
        if FlyBody then FlyBody:Destroy() end
        Flying = false
    end)
end

-- Anti AFK
spawn(function()
    while task.wait(300) do
        if getgenv().FishIt.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
end)

-- ========================================
-- CREATE UI
-- ========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 12)
TitleCover.Position = UDim2.new(0, 0, 1, -12)
TitleCover.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleBar

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐟 Fish It! Script Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -100, 0, 15)
Subtitle.Position = UDim2.new(0, 15, 0, 25)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "v1.0 | Mobile Safe"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    getgenv().FishIt.AutoFish = false
    getgenv().FishIt.Fly = false
    notify("Fish It!", "GUI Closed", 2)
end)

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -65)
ScrollFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.Parent = ScrollFrame

-- Auto-resize canvas
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- ========================================
-- UI ELEMENTS
-- ========================================

local function CreateSection(name)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 35)
    Section.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
    Section.BorderSizePixel = 0
    Section.Parent = ScrollFrame
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 8)
    SCorner.Parent = Section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "⚡ " .. name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 16
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Section
end

local function CreateToggle(name, default, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -10, 0, 45)
    Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Toggle.BorderSizePixel = 0
    Toggle.Parent = ScrollFrame
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 8)
    TCorner.Parent = Toggle
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 30)
    Button.Position = UDim2.new(1, -60, 0.5, -15)
    Button.BackgroundColor3 = default and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(120, 120, 130)
    Button.Text = default and "ON" or "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Toggle
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = Button
    
    local enabled = default
    
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        Button.BackgroundColor3 = enabled and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(120, 120, 130)
        Button.Text = enabled and "ON" or "OFF"
        callback(enabled)
    end)
end

local function CreateButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 45)
    Button.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
    Button.BorderSizePixel = 0
    Button.Text = "▶ " .. name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ScrollFrame
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
end

local function CreateSlider(name, min, max, default, callback)
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, -10, 0, 55)
    Slider.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Slider.BorderSizePixel = 0
    Slider.Parent = ScrollFrame
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 8)
    SCorner.Parent = Slider
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 15, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -30, 0, 8)
    Bar.Position = UDim2.new(0, 15, 1, -18)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Bar.BorderSizePixel = 0
    Bar.Parent = Slider
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    local dragging = false
    
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            Label.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

-- ========================================
-- BUILD UI
-- ========================================

CreateSection("Auto Farm")

CreateToggle("Auto Fish", false, function(val)
    getgenv().FishIt.AutoFish = val
    if val then
        AutoFishModule:Start()
    else
        AutoFishModule.Active = false
    end
end)

CreateToggle("Instant Catch", false, function(val)
    getgenv().FishIt.InstantCatch = val
end)

CreateToggle("Auto Equip Best Rod", false, function(val)
    getgenv().FishIt.AutoEquipBestRod = val
end)

CreateButton("Cast Rod Now", function()
    AutoFishModule:Cast()
end)

CreateSection("Merchant")

CreateToggle("Sell Common", true, function(val)
    getgenv().FishIt.SellCommon = val
end)

CreateToggle("Sell Rare", false, function(val)
    getgenv().FishIt.SellRare = val
end)

CreateToggle("Sell Legendary", false, function(val)
    getgenv().FishIt.SellLegendary = val
end)

CreateButton("Teleport to Merchant", function()
    MerchantModule:Teleport()
end)

CreateSection("Teleport")

CreateButton("Spawn", function()
    TeleportModule:Spawn()
end)

CreateSection("Player")

CreateSlider("WalkSpeed", 16, 200, 16, function(val)
    getgenv().FishIt.WalkSpeed = val
end)

CreateSlider("JumpPower", 50, 200, 50, function(val)
    getgenv().FishIt.JumpPower = val
end)

CreateToggle("Noclip", false, function(val)
    getgenv().FishIt.Noclip = val
end)

CreateToggle("Fly (WASD)", false, function(val)
    getgenv().FishIt.Fly = val
    if val then
        StartFly()
    end
end)

CreateSlider("Fly Speed", 10, 150, 50, function(val)
    getgenv().FishIt.FlySpeed = val
end)

CreateToggle("Anti AFK", false, function(val)
    getgenv().FishIt.AntiAFK = val
end)

CreateSection("Settings")

CreateButton("Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

CreateButton("Destroy GUI", function()
    ScreenGui:Destroy()
    getgenv().FishIt.AutoFish = false
    notify("Fish It!", "GUI Destroyed!", 2)
end)

-- ========================================
-- FINALIZE
-- ========================================

ScreenGui.Parent = LocalPlayer.PlayerGui

notify("Fish It!", "Loaded successfully!", 3)
print("[Fish It!] Script loaded!")
print("[Fish It!] Drag the UI to move it")
print("[Fish It!] Made by fahmi1804")