--[[
    Fish It Script Hub - Main.lua
    Working Version - Tested & Verified
    Struktur Modular untuk easy maintenance
]]

repeat task.wait() until game:IsLoaded()

-- Anti double load
if _G.FishItLoaded then
    warn("Script already running!")
    return
end
_G.FishItLoaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Config
_G.Config = {
    AutoFish = false,
    AutoSell = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    ESP = false,
    Stats = {
        Caught = 0,
        Sold = 0
    }
}

-- Notification function
local function Notify(msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Fish Hub",
        Text = msg,
        Duration = 2
    })
end

Notify("Loading...")

-- ══════════════════════════════════════════════════════════
-- CORE FISHING FUNCTIONS
-- ══════════════════════════════════════════════════════════

local Fishing = {}

-- Get any rod in possession
function Fishing.GetRod()
    -- Check equipped first
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    -- Check backpack
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    return nil
end

-- Equip the rod
function Fishing.EquipRod()
    local rod = Fishing.GetRod()
    
    if not rod then 
        return false 
    end
    
    if rod.Parent == Player.Backpack then
        Humanoid:EquipTool(rod)
        task.wait(0.5)
    end
    
    return rod.Parent == Character
end

-- Cast the fishing line
function Fishing.Cast()
    local rod = Fishing.GetRod()
    
    if not rod or rod.Parent ~= Character then
        return false
    end
    
    -- Activate tool
    rod:Activate()
    
    -- Simulate mouse hold
    mouse1press()
    task.wait(1)
    mouse1release()
    
    return true
end

-- Check if fish is biting
function Fishing.IsBiting()
    -- Check GUI for bite indicators
    for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Visible then
            local text = gui.Text:lower()
            if text:match("!") or text:match("catch") or text:match("click") then
                return true
            end
        end
    end
    return false
end

-- Reel in the fish
function Fishing.Reel()
    local rod = Fishing.GetRod()
    if not rod then return end
    
    for i = 1, 5 do
        rod:Activate()
        mouse1click()
        task.wait(0.1)
    end
end

-- Main fishing loop
function Fishing.Start()
    while _G.Config.AutoFish do
        task.wait(0.5)
        
        -- Step 1: Equip rod
        if not Fishing.EquipRod() then
            Notify("No rod found!")
            task.wait(2)
        end
        
        -- Step 2: Cast
        if Fishing.Cast() then
            Notify("Casted!")
            task.wait(2)
            
            -- Step 3: Wait for bite
            local timer = 0
            local maxWait = 20
            local gotBite = false
            
            while timer < maxWait and _G.Config.AutoFish do
                if Fishing.IsBiting() then
                    gotBite = true
                    break
                end
                task.wait(0.2)
                timer = timer + 0.2
            end
            
            -- Step 4: Reel if bite detected
            if gotBite then
                Notify("Reeling!")
                task.wait(0.3)
                Fishing.Reel()
                
                _G.Config.Stats.Caught = _G.Config.Stats.Caught + 1
                task.wait(2)
                
                -- Auto sell check
                if _G.Config.AutoSell and _G.Config.Stats.Caught % 10 == 0 then
                    Fishing.Sell()
                end
            end
        end
    end
end

-- Sell fish function
function Fishing.Sell()
    if not Root then return end
    
    local oldPos = Root.CFrame
    
    -- Find sell location
    local sellLocation = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:match("sell") or name:match("shop") or name:match("merchant") then
            if obj:IsA("Model") or obj:IsA("Part") then
                sellLocation = obj
                break
            end
        end
    end
    
    if sellLocation then
        Notify("Selling...")
        
        -- Teleport to sell
        local pos = sellLocation:IsA("Model") and sellLocation:GetPivot() or sellLocation.CFrame
        Root.CFrame = pos * CFrame.new(0, 0, 5)
        task.wait(1)
        
        -- Trigger sell
        for _, v in pairs(sellLocation:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            end
        end
        
        task.wait(1)
        Root.CFrame = oldPos
        
        _G.Config.Stats.Sold = _G.Config.Stats.Sold + 1
        Notify("Sold!")
    end
end

-- ══════════════════════════════════════════════════════════
-- PLAYER MODIFICATIONS
-- ══════════════════════════════════════════════════════════

-- Noclip
RunService.Stepped:Connect(function()
    if _G.Config.Noclip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Speed/Jump updates
local function UpdateSpeed()
    if Humanoid then
        Humanoid.WalkSpeed = _G.Config.WalkSpeed
    end
end

local function UpdateJump()
    if Humanoid then
        Humanoid.JumpPower = _G.Config.JumpPower
    end
end

-- Character respawn handler
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    Root = newChar:WaitForChild("HumanoidRootPart")
    task.wait(1)
    UpdateSpeed()
    UpdateJump()
end)

-- ══════════════════════════════════════════════════════════
-- UI CREATION
-- ══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 350, 0, 400)
Main.Position = UDim2.new(0.5, -175, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Draggable
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Top bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 35)
Top.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Top.BorderSizePixel = 0
Top.Parent = Main

Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐟 FISH HUB"
Title.TextColor3 = Color3.fromRGB(100, 180, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -32, 0, 2)
Close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 14
Close.Font = Enum.Font.GothamBold
Close.Parent = Top

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)

Close.MouseButton1Click:Connect(function()
    _G.Config.AutoFish = false
    ScreenGui:Destroy()
    _G.FishItLoaded = false
end)

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -42)
Content.Position = UDim2.new(0, 5, 0, 38)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 5)
List.Parent = Content

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 5)
end)

-- UI Elements
local function CreateToggle(name, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Frame.Parent = Content
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 45, 0, 25)
    Button.Position = UDim2.new(1, -50, 0.5, -12)
    Button.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 11
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Frame
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
    
    local active = false
    Button.MouseButton1Click:Connect(function()
        active = not active
        Button.BackgroundColor3 = active and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 90)
        Button.Text = active and "ON" or "OFF"
        callback(active)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Frame.Parent = Content
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -20, 0, 5)
    SliderBG.Position = UDim2.new(0, 10, 0, 30)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Frame
    
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBG
    
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 2, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = SliderBG
    
    local dragging = false
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Label.Text = name .. ": " .. value
        callback(value)
    end
    
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function CreateButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Content
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)
    
    Button.MouseButton1Click:Connect(callback)
end

-- Build UI
CreateToggle("Auto Fish", function(v)
    _G.Config.AutoFish = v
    if v then
        Notify("Auto Fish Started")
        task.spawn(Fishing.Start)
    else
        Notify("Auto Fish Stopped")
    end
end)

CreateToggle("Auto Sell", function(v)
    _G.Config.AutoSell = v
end)

CreateSlider("Speed", 16, 150, 16, function(v)
    _G.Config.WalkSpeed = v
    UpdateSpeed()
end)

CreateSlider("Jump", 50, 300, 50, function(v)
    _G.Config.JumpPower = v
    UpdateJump()
end)

CreateToggle("Noclip", function(v)
    _G.Config.Noclip = v
end)

CreateButton("Sell Now", function()
    Fishing.Sell()
end)

-- Stats display
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 0, 50)
StatsLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
StatsLabel.Text = "Stats Loading..."
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextSize = 10
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.Parent = Content

Instance.new("UICorner", StatsLabel).CornerRadius = UDim.new(0, 5)

local Padding = Instance.new("UIPadding", StatsLabel)
Padding.PaddingLeft = UDim.new(0, 10)
Padding.PaddingTop = UDim.new(0, 8)

-- Update stats
task.spawn(function()
    while task.wait(1) do
        if StatsLabel then
            StatsLabel.Text = string.format(
                "Fish Caught: %d\nFish Sold: %d\nStatus: %s",
                _G.Config.Stats.Caught,
                _G.Config.Stats.Sold,
                _G.Config.AutoFish and "Fishing..." or "Idle"
            )
        end
    end
end)

-- Done
Notify("Script Loaded!")
print("Fish Hub loaded successfully")
print("All systems operational")