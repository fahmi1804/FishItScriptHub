--[[
    Fish It! Script Hub v1.0
    Native Roblox UI - Fixed Version
    Compatible: Xeno (PC) & Delta (Mobile)
]]

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Dual Execute - Remove old GUI
task.wait(0.5)
pcall(function()
    local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    if PlayerGui:FindFirstChild("FishItHub") then
        PlayerGui.FishItHub:Destroy()
        task.wait(0.3)
    end
end)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Notification
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🐟 " .. title;
            Text = text;
            Duration = 3;
        })
    end)
end

notify("Fish It!", "Creating UI...")

-- Global Config
_G.FishItSettings = _G.FishItSettings or {
    AutoFish = false,
    InstantCatch = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    AntiAFK = false
}

-- ========================================
-- AUTO FISH
-- ========================================
local AutoFishing = false

local function GetRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():match("rod") or tool.Name:lower():match("fish") then
                return tool
            end
        end
    end
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():match("rod") or tool.Name:lower():match("fish") then
                return tool
            end
        end
    end
    
    return nil
end

local function CastRod()
    local rod = GetRod()
    if not rod then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if rod.Parent ~= char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(rod)
            task.wait(0.4)
        end
    end
    
    pcall(function()
        rod:Activate()
    end)
end

local function CheckBite()
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local text = gui.Text:lower()
            if text:match("catch") or text:match("!") or text:match("reel") then
                return true
            end
        end
    end
    return false
end

spawn(function()
    while task.wait(1) do
        if _G.FishItSettings.AutoFish then
            CastRod()
            task.wait(1)
            
            for i = 1, 10 do
                if CheckBite() then
                    if _G.FishItSettings.InstantCatch then
                        CastRod()
                    else
                        task.wait(0.5)
                        CastRod()
                    end
                    break
                end
                task.wait(0.5)
            end
        end
    end
end)

-- ========================================
-- PLAYER MODS
-- ========================================

-- WalkSpeed & JumpPower
spawn(function()
    while task.wait(0.5) do
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = _G.FishItSettings.WalkSpeed
                hum.JumpPower = _G.FishItSettings.JumpPower
            end
        end
    end
end)

-- Noclip
RunService.Heartbeat:Connect(function()
    if _G.FishItSettings.Noclip then
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
local FlyBody = nil

spawn(function()
    while task.wait() do
        if _G.FishItSettings.Fly then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and not FlyBody then
                    FlyBody = Instance.new("BodyVelocity")
                    FlyBody.Parent = hrp
                    FlyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    FlyBody.Velocity = Vector3.new(0, 0, 0)
                end
                
                if FlyBody then
                    local cam = workspace.CurrentCamera
                    local speed = _G.FishItSettings.FlySpeed
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
            end
        else
            if FlyBody then
                FlyBody:Destroy()
                FlyBody = nil
            end
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
ScreenGui.DisplayOrder = 999

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 480)
Main.Position = UDim2.new(0.5, -210, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 40)
Top.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = Top

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 10)
TopFix.Position = UDim2.new(0, 0, 1, -10)
TopFix.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopFix.BorderSizePixel = 0
TopFix.Parent = Top

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐟 Fish It! Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

-- Close
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 16
Close.Font = Enum.Font.GothamBold
Close.Parent = Top

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    notify("Fish It!", "GUI Closed")
end)

-- Scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -48)
Scroll.Position = UDim2.new(0, 8, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 8)
List.Parent = Scroll

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 8)
end)

-- ========================================
-- UI BUILDERS
-- ========================================

local function Section(text)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -8, 0, 32)
    F.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    F.BorderSizePixel = 0
    F.Parent = Scroll
    
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = F
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 1, 0)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 14
    L.Font = Enum.Font.GothamBold
    L.Parent = F
end

local function Toggle(text, default, callback)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -8, 0, 40)
    F.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    F.BorderSizePixel = 0
    F.Parent = Scroll
    
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = F
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -60, 1, 0)
    L.Position = UDim2.new(0, 12, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 13
    L.Font = Enum.Font.Gotham
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
    
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 45, 0, 26)
    B.Position = UDim2.new(1, -52, 0.5, -13)
    B.BackgroundColor3 = default and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 110)
    B.Text = default and "ON" or "OFF"
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.TextSize = 12
    B.Font = Enum.Font.GothamBold
    B.Parent = F
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 6)
    BC.Parent = B
    
    local on = default
    
    B.MouseButton1Click:Connect(function()
        on = not on
        B.BackgroundColor3 = on and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 110)
        B.Text = on and "ON" or "OFF"
        callback(on)
    end)
end

local function Button(text, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -8, 0, 38)
    B.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
    B.BorderSizePixel = 0
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.TextSize = 13
    B.Font = Enum.Font.GothamBold
    B.Parent = Scroll
    
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = B
    
    B.MouseButton1Click:Connect(callback)
end

local function Slider(text, min, max, default, callback)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -8, 0, 50)
    F.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    F.BorderSizePixel = 0
    F.Parent = Scroll
    
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = F
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -16, 0, 18)
    L.Position = UDim2.new(0, 12, 0, 6)
    L.BackgroundTransparency = 1
    L.Text = text .. ": " .. default
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 12
    L.Font = Enum.Font.Gotham
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 6)
    Bar.Position = UDim2.new(0, 12, 1, -14)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Bar.BorderSizePixel = 0
    Bar.Parent = F
    
    local BarC = Instance.new("UICorner")
    BarC.CornerRadius = UDim.new(1, 0)
    BarC.Parent = Bar
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    
    local FillC = Instance.new("UICorner")
    FillC.CornerRadius = UDim.new(1, 0)
    FillC.Parent = Fill
    
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
        if dragging then
            local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            L.Text = text .. ": " .. val
            callback(val)
        end
    end)
end

-- ========================================
-- BUILD
-- ========================================

Section("⚡ Auto Farm")
Toggle("Auto Fish", false, function(v)
    _G.FishItSettings.AutoFish = v
    notify("Auto Fish", v and "Enabled" or "Disabled")
end)
Toggle("Instant Catch", false, function(v)
    _G.FishItSettings.InstantCatch = v
end)
Button("Cast Rod Now", function()
    CastRod()
    notify("Fish It!", "Rod cast!")
end)

Section("👤 Player")
Slider("WalkSpeed", 16, 200, 16, function(v)
    _G.FishItSettings.WalkSpeed = v
end)
Slider("JumpPower", 50, 200, 50, function(v)
    _G.FishItSettings.JumpPower = v
end)
Toggle("Noclip", false, function(v)
    _G.FishItSettings.Noclip = v
end)
Toggle("Fly (WASD)", false, function(v)
    _G.FishItSettings.Fly = v
end)
Slider("Fly Speed", 10, 150, 50, function(v)
    _G.FishItSettings.FlySpeed = v
end)

Section("⚙️ Settings")
Button("Destroy GUI", function()
    ScreenGui:Destroy()
    notify("Fish It!", "GUI Destroyed!")
end)

-- Parent and finalize
task.wait(0.2)
ScreenGui.Parent = PlayerGui

notify("Fish It!", "Loaded!")
print("🐟 Fish It! Hub loaded successfully!")
print("✅ Drag the UI to move it")
print("✅ All features ready!")
--update test 1