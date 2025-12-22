-- Main.lua - Fish It! Script Hub
-- Game: Fish It! by Fish Atelier
-- Educational Purpose Only

-- Anti Double Execute
if getgenv().FishItLoaded then
    warn("Fish It Script already loaded!")
    return
end
getgenv().FishItLoaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local Config = {
    AutoFish = false,
    AutoSell = false,
    AutoReel = false,
    ESP = false,
    Noclip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FishDelay = 0.5,
    TeleportEnabled = false,
    ShowFishNotification = true
}

-- Storage
getgenv().FishItHub = {
    Config = Config,
    Connections = {},
    ESPObjects = {},
    FishingStats = {
        TotalCaught = 0,
        RareCaught = 0,
        LegendaryCaught = 0,
        SessionTime = 0
    },
    Locations = {
        Starter = CFrame.new(0, 5, 0), -- Default spawn
        Dock = nil,
        Beach = nil,
        DeepSea = nil
    }
}

-- Utility Functions
local Utils = {}

function Utils:Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

function Utils:GetRodTool()
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool.Name:lower():find("fishing")) then
            return tool
        end
    end
    
    for _, tool in pairs(Character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool.Name:lower():find("fishing")) then
            return tool
        end
    end
    
    return nil
end

function Utils:EquipRod()
    local rod = self:GetRodTool()
    if rod and rod.Parent == LocalPlayer.Backpack then
        Humanoid:EquipTool(rod)
        wait(0.3)
        return true
    end
    return false
end

function Utils:Teleport(cframe)
    if Character and HumanoidRootPart then
        HumanoidRootPart.CFrame = cframe
    end
end

function Utils:FindNearestFishingSpot()
    local nearestDist = math.huge
    local nearestPos = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("fish") or obj.Name:lower():find("water")) then
            local dist = (HumanoidRootPart.Position - obj.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestPos = obj.Position
            end
        end
    end
    
    return nearestPos
end

function Utils:CreateESP(object, color)
    if not object or not object:IsA("BasePart") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. object.Name
    highlight.Adornee = object
    highlight.FillColor = color or Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = object
    
    table.insert(getgenv().FishItHub.ESPObjects, highlight)
end

function Utils:RemoveAllESP()
    for _, esp in pairs(getgenv().FishItHub.ESPObjects) do
        if esp then esp:Destroy() end
    end
    getgenv().FishItHub.ESPObjects = {}
end

-- Fish It Specific Functions
local FishIt = {}

function FishIt:Cast()
    local rod = Utils:GetRodTool()
    if not rod or rod.Parent ~= Character then
        return false
    end
    
    -- Simulate mouse click/hold to cast
    local mouse = LocalPlayer:GetMouse()
    
    -- Hold to charge cast
    mouse1press()
    wait(0.8) -- Charge time
    mouse1release()
    
    return true
end

function FishIt:Reel()
    -- Auto clicking for reeling
    local startTime = tick()
    local maxReelTime = 10 -- Maximum 10 seconds to reel
    
    while tick() - startTime < maxReelTime do
        if not Config.AutoReel then break end
        
        -- Fast clicking to reel in fish
        mouse1click()
        wait(0.05) -- Fast clicking
        
        -- Check if fish is caught (you can add detection here)
        local rod = Utils:GetRodTool()
        if not rod or rod.Parent ~= Character then
            break
        end
    end
end

function FishIt:AutoFishRoutine()
    if not Config.AutoFish then return end
    
    -- Equip rod
    if not Utils:EquipRod() then
        Utils:Notify("Auto Fish", "No fishing rod found!", 3)
        Config.AutoFish = false
        return
    end
    
    wait(0.5)
    
    while Config.AutoFish do
        -- Cast the line
        local casted = self:Cast()
        
        if casted then
            -- Wait for bite (detect by bobber animation or GUI changes)
            wait(Config.FishDelay + math.random(2, 5))
            
            -- Auto reel
            if Config.AutoReel then
                self:Reel()
            end
            
            -- Update stats
            getgenv().FishItHub.FishingStats.TotalCaught = getgenv().FishItHub.FishingStats.TotalCaught + 1
            
            if Config.ShowFishNotification then
                Utils:Notify("Fish Caught!", "Total: " .. getgenv().FishItHub.FishingStats.TotalCaught, 1)
            end
            
            -- Wait before next cast
            wait(Config.FishDelay)
            
            -- Auto sell if enabled
            if Config.AutoSell then
                self:SellFish()
            end
        else
            wait(1)
        end
    end
end

function FishIt:SellFish()
    -- Find sell NPC or area
    local sellArea = Workspace:FindFirstChild("SellArea") or Workspace:FindFirstChild("Shop")
    
    if sellArea then
        local originalPos = HumanoidRootPart.CFrame
        
        -- Teleport to sell area
        if sellArea:FindFirstChild("Position") then
            Utils:Teleport(sellArea.Position.CFrame)
        elseif sellArea:IsA("BasePart") then
            Utils:Teleport(sellArea.CFrame)
        end
        
        wait(0.5)
        
        -- Trigger sell (usually proximity prompt or click detector)
        for _, child in pairs(sellArea:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                fireproximityprompt(child)
            elseif child:IsA("ClickDetector") then
                fireclickdetector(child)
            end
        end
        
        wait(0.5)
        
        -- Return to original position
        Utils:Teleport(originalPos)
    end
end

function FishIt:ESPFishingSpots()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Name:lower():find("fishingspot") or obj.Name:lower():find("spot") then
                Utils:CreateESP(obj, Color3.fromRGB(0, 255, 255))
            elseif obj.Name:lower():find("rare") or obj.Name:lower():find("legendary") then
                Utils:CreateESP(obj, Color3.fromRGB(255, 215, 0))
            end
        end
    end
end

-- Features Module
local Features = {}

function Features:ToggleAutoFish(enabled)
    Config.AutoFish = enabled
    
    if enabled then
        Utils:Notify("Auto Fish", "Enabled - Starting fishing!", 2)
        
        task.spawn(function()
            FishIt:AutoFishRoutine()
        end)
    else
        Utils:Notify("Auto Fish", "Disabled", 2)
    end
end

function Features:ToggleAutoSell(enabled)
    Config.AutoSell = enabled
    Utils:Notify("Auto Sell", enabled and "Enabled" or "Disabled", 2)
end

function Features:ToggleAutoReel(enabled)
    Config.AutoReel = enabled
    Utils:Notify("Auto Reel", enabled and "Enabled" or "Disabled", 2)
end

function Features:ToggleESP(enabled)
    Config.ESP = enabled
    
    if enabled then
        Utils:Notify("ESP", "Enabled - Showing fishing spots!", 2)
        FishIt:ESPFishingSpots()
    else
        Utils:Notify("ESP", "Disabled", 2)
        Utils:RemoveAllESP()
    end
end

function Features:ToggleNoclip(enabled)
    Config.Noclip = enabled
    
    if enabled then
        Utils:Notify("Noclip", "Enabled", 2)
        
        local noclipConnection
        noclipConnection = RunService.Stepped:Connect(function()
            if not Config.Noclip then
                noclipConnection:Disconnect()
                return
            end
            
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        
        table.insert(getgenv().FishItHub.Connections, noclipConnection)
    else
        Utils:Notify("Noclip", "Disabled", 2)
        
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

function Features:SetWalkSpeed(speed)
    Config.WalkSpeed = speed
    Humanoid.WalkSpeed = speed
end

function Features:SetJumpPower(power)
    Config.JumpPower = power
    Humanoid.JumpPower = power
end

function Features:ResetStats()
    getgenv().FishItHub.FishingStats = {
        TotalCaught = 0,
        RareCaught = 0,
        LegendaryCaught = 0,
        SessionTime = 0
    }
    Utils:Notify("Stats Reset", "All fishing stats cleared!", 2)
end

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItScriptHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 600)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 150, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Title.BorderSizePixel = 0
Title.Text = "🐟 Fish It! Script Hub v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
MinimizeButton.Position = UDim2.new(1, -80, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = Title

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 450, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 450, 0, 600), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        MinimizeButton.Text = "-"
    end
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 150, 255)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- UI Creation Functions
local function CreateSection(name)
    local Section = Instance.new("Frame")
    Section.Name = name
    Section.Size = UDim2.new(1, 0, 0, 30)
    Section.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    Section.Parent = ScrollFrame
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = Section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "⚡ " .. name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Section
end

local function CreateToggle(name, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Name = name
    Toggle.Size = UDim2.new(1, 0, 0, 45)
    Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Toggle.Parent = ScrollFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = Toggle
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 70, 0, 32)
    Button.Position = UDim2.new(1, -80, 0.5, -16)
    Button.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Toggle
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    local isEnabled = false
    
    Button.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        Button.BackgroundColor3 = isEnabled and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(255, 60, 60)
        Button.Text = isEnabled and "ON" or "OFF"
        callback(isEnabled)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local Slider = Instance.new("Frame")
    Slider.Name = name
    Slider.Size = UDim2.new(1, 0, 0, 65)
    Slider.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Slider.Parent = ScrollFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = Slider
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 22)
    Label.Position = UDim2.new(0, 10, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 8)
    SliderBar.Position = UDim2.new(0, 10, 0, 40)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Parent = Slider
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(1, 0)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    SliderFill.Parent = SliderBar
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 18, 0, 18)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Text = ""
    SliderButton.Parent = SliderBar
    
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(1, 0)
    SliderButtonCorner.Parent = SliderButton
    
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = SliderBar.AbsolutePosition.X
            local sliderSize = SliderBar.AbsoluteSize.X
            
            local value = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local finalValue = math.floor(min + (max - min) * value)
            
            SliderFill.Size = UDim2.new(value, 0, 1, 0)
            SliderButton.Position = UDim2.new(value, -9, 0.5, -9)
            Label.Text = name .. ": " .. finalValue
            
            callback(finalValue)
        end
    end)
end

local function CreateButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ScrollFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(70, 170, 255)
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    end)
end

-- Stats Display
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, 0, 0, 80)
StatsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
StatsFrame.Parent = ScrollFrame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -20, 1, -20)
StatsLabel.Position = UDim2.new(0, 10, 0, 10)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "📊 Fishing Stats\nTotal Caught: 0\nSession: Active"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 13
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextXAlignment.Top
StatsLabel.Parent = StatsFrame

-- Update stats every second
task.spawn(function()
    while wait(1) do
        if StatsLabel then
            StatsLabel.Text = string.format(
                "📊 Fishing Stats\nTotal Caught: %d\nSession: Active",
                getgenv().FishItHub.FishingStats.TotalCaught
            )
        end
    end
end)

-- Create UI Elements
CreateSection("Main Features")
CreateToggle("🎣 Auto Fish", function(enabled)
    Features:ToggleAutoFish(enabled)
end)

CreateToggle("🔄 Auto Reel", function(enabled)
    Features:ToggleAutoReel(enabled)
end)

CreateToggle("💰 Auto Sell", function(enabled)
    Features:ToggleAutoSell(enabled)
end)

CreateSection("Visual")
CreateToggle("👁️ ESP (Fishing Spots)", function(enabled)
    Features:ToggleESP(enabled)
end)

CreateSection("Player")
CreateToggle("👻 Noclip", function(enabled)
    Features:ToggleNoclip(enabled)
end)

CreateSlider("WalkSpeed", 16, 200, 16, function(value)
    Features:SetWalkSpeed(value)
end)

CreateSlider("JumpPower", 50, 300, 50, function(value)
    Features:SetJumpPower(value)
end)

CreateSection("Settings")
CreateSlider("Fish Delay", 0, 3, 0.5, function(value)
    Config.FishDelay = value
end)

CreateSection("Actions")
CreateButton("🔄 Reset Stats", function()
    Features:ResetStats()
end)

CreateButton("🏠 Teleport to Spawn", function()
    local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
    if spawn then
        Utils:Teleport(spawn.CFrame + Vector3.new(0, 5, 0))
        Utils:Notify("Teleport", "Teleported to spawn!", 2)
    end
end)

-- Update canvas size for scroll frame
task.spawn(function()
    wait(0.1)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
end)

-- Character Reset Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    
    wait(1)
    
    if Config.WalkSpeed ~= 16 then
        Humanoid.WalkSpeed = Config.WalkSpeed
    end
    
    if Config.JumpPower ~= 50 then
        Humanoid.JumpPower = Config.JumpPower
    end
end)

-- Initialize
Utils:Notify("Fish It! Script", "Loaded successfully! 🎣", 3)
print("=================================")
print("Fish It! Script Hub v1.0")
print("Game: Fish It! by Fish Atelier")
print("Status: Ready")
print("=================================")