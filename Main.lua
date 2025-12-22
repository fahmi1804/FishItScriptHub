--[[
╔═══════════════════════════════════════════════════════════════╗
║          Fish It! Hub v2.5 REPAIRED - FULL VERSION            ║
║          Restored Original Logic + Fixed Instant Catch        ║
║          No Cut-off Code | Full UI                            ║
╚═══════════════════════════════════════════════════════════════╝
]]

-- Wait for game load
if not game:IsLoaded() then game.Loaded:Wait() end

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Remove old GUI
task.wait(0.5)
pcall(function()
    local pg = game.Players.LocalPlayer.PlayerGui
    if pg:FindFirstChild("FishItNative") then
        pg.FishItNative:Destroy()
        task.wait(0.3)
    end
end)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Notification
local function Notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🐟 " .. title,
            Text = text,
            Duration = 3
        })
    end)
end

Notify("Fish It!", "Loading Full Script...")

-- Config
_G.FishIt = _G.FishIt or {
    -- Farming
    AutoFish = false,
    InstantCatch = false,
    CastDelay = 0.5,
    ReelDelay = 0.3,
    AutoSell = false,
    SellInterval = 10,
    
    -- Player
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    InfJump = false,
    
    -- Visual
    ESP = false,
    FullBright = false,
    
    -- Stats
    FishCaught = 0,
    MoneyEarned = 0
}

-- ═══════════════════════════════════════════════════════════════
-- FISHING SYSTEM (COMBINED ORIGINAL + INSTANT FIX)
-- ═══════════════════════════════════════════════════════════════

local FishingSystem = {}

-- Get Fishing Rod
function FishingSystem:GetRod()
    local char = LP.Character
    if not char then return nil end
    
    -- Check equipped first
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("rod") or name:find("fish") or name:find("pole") then
                return tool
            end
        end
    end
    
    -- Check backpack
    for _, tool in pairs(LP.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("rod") or name:find("fish") or name:find("pole") then
                return tool
            end
        end
    end
    
    return nil
end

-- Equip Rod
function FishingSystem:EquipRod()
    local rod = self:GetRod()
    if not rod then return false end
    
    local char = LP.Character
    if not char then return false end
    
    if rod.Parent == LP.Backpack then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(rod)
            task.wait(0.3)
        end
    end
    
    return rod.Parent == char
end

-- Cast Fishing Line
function FishingSystem:Cast()
    local rod = self:GetRod()
    if not rod or rod.Parent ~= LP.Character then return false end
    
    -- Method 1: Tool Activation
    pcall(function()
        rod:Activate()
    end)
    
    -- Method 2: Remote Event (Blind Fire)
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("cast") or v.Name:lower():find("throw")) then
                v:FireServer()
            end
        end
    end)
    
    -- Method 3: Virtual Mouse Click
    task.spawn(function()
        if mouse1press then
            mouse1press()
            task.wait(0.1)
            mouse1release()
        end
    end)
    
    return true
end

-- Detect Bite
function FishingSystem:CheckBite()
    local char = LP.Character
    if not char then return false end
    
    -- Method 1: Check GUI
    local gui = LP.PlayerGui
    for _, v in pairs(gui:GetDescendants()) do
        if v.Visible then
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                local text = v.Text:lower()
                if text:find("!") or text:find("catch") or text:find("reel") or text:find("click") then
                    return true
                end
            end
            
            if v:IsA("ImageLabel") then
                local name = v.Name:lower()
                if name:find("catch") or name:find("fish") or name:find("bite") then
                    return true
                end
            end
        end
    end
    
    -- Method 2: Check Rod Animation/Sound
    local rod = self:GetRod()
    if rod then
        for _, v in pairs(rod:GetDescendants()) do
            if v:IsA("Sound") and v.Playing then
                return true
            end
        end
    end
    
    return false
end

-- Reel Fish (Modified with Instant Logic)
function FishingSystem:Reel(instant)
    local rod = self:GetRod()
    if not rod then return end
    
    if instant then
        -- Instant Catch: Spam klik cepat & Fire Remotes
        for i = 1, 8 do
            pcall(function() rod:Activate() end)
            if mouse1click then mouse1click() end
            
            -- Brutal Remote Firing
            pcall(function()
                for _, rm in pairs(ReplicatedStorage:GetDescendants()) do
                    if rm:IsA("RemoteEvent") then
                        local n = rm.Name:lower()
                        if n:find("reel") or n:find("catch") or n:find("fish") then
                            rm:FireServer()
                            rm:FireServer(true) -- Try bool
                        end
                    end
                end
            end)
            task.wait(0.02)
        end
    else
        -- Normal: Klik beberapa kali
        for i = 1, 3 do
            pcall(function() rod:Activate() end)
            if mouse1click then mouse1click() end
            task.wait(0.15)
        end
    end
end

-- Main Auto Fish Loop
function FishingSystem:StartAutoFish()
    task.spawn(function()
        while task.wait(0.1) do
            if not _G.FishIt.AutoFish then break end
            
            -- Equip rod
            if not self:EquipRod() then
                task.wait(2)
                -- continue (Fixed for old Lua)
            else
                -- Cast
                local casted = self:Cast()
                
                if casted then
                    -- Wait for cast delay
                    task.wait(_G.FishIt.CastDelay)
                    
                    -- Wait for bite
                    local bitten = false
                    local startTime = tick()
                    
                    while tick() - startTime < 15 do
                        if not _G.FishIt.AutoFish then break end
                        
                        if self:CheckBite() then
                            bitten = true
                            break
                        end
                        
                        task.wait(0.1)
                    end
                    
                    if bitten then
                        -- Wait reel delay
                        task.wait(_G.FishIt.ReelDelay)
                        
                        -- Reel
                        self:Reel(_G.FishIt.InstantCatch)
                        
                        -- Update stats
                        _G.FishIt.FishCaught = _G.FishIt.FishCaught + 1
                        
                        -- Wait animation
                        task.wait(2)
                        
                        -- Auto sell check
                        if _G.FishIt.AutoSell and _G.FishIt.FishCaught % _G.FishIt.SellInterval == 0 then
                            task.spawn(function()
                                FishingSystem:SellFish()
                            end)
                            task.wait(3) -- Wait for sell
                        end
                    else
                        -- Timeout - reset
                        self:Cast()
                        task.wait(1)
                    end
                else
                    task.wait(1)
                end
            end
        end
        Notify("Auto Fish", "Loop Stopped")
    end)
end

-- Auto Sell
function FishingSystem:SellFish()
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local oldPos = char.HumanoidRootPart.CFrame
    
    -- Find merchant/sell area
    local merchant = workspace:FindFirstChild("Merchant") 
        or workspace:FindFirstChild("Shop")
        or workspace:FindFirstChild("Sell")
    
    if not merchant then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                local name = v.Name:lower()
                if name:find("merchant") or name:find("sell") or name:find("shop") then
                    merchant = v
                    break
                end
            end
        end
    end
    
    if merchant then
        Notify("Auto Sell", "Selling fish...")
        
        -- Teleport
        local targetCF = merchant:GetPivot()
        if not targetCF and merchant:FindFirstChild("HumanoidRootPart") then
            targetCF = merchant.HumanoidRootPart.CFrame
        elseif not targetCF and merchant:IsA("BasePart") then
            targetCF = merchant.CFrame
        end

        if targetCF then
            char.HumanoidRootPart.CFrame = targetCF * CFrame.new(0, 0, 5)
            task.wait(0.5)
            
            -- Trigger sell
            for _, v in pairs(merchant:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                    task.wait(0.2)
                elseif v:IsA("ClickDetector") then
                    fireclickdetector(v)
                    task.wait(0.2)
                end
            end
            
            task.wait(1)
            
            -- Return
            char.HumanoidRootPart.CFrame = oldPos
            Notify("Auto Sell", "Sold! Total: " .. _G.FishIt.FishCaught)
        end
    else
        Notify("Error", "Merchant not found!")
    end
end

-- ═══════════════════════════════════════════════════════════════
-- PLAYER MODS
-- ═══════════════════════════════════════════════════════════════

-- Noclip
RunService.Stepped:Connect(function()
    if _G.FishIt.Noclip and LP.Character then
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if _G.FishIt.InfJump and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Character Reset Handler
LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    if char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = _G.FishIt.WalkSpeed
        char.Humanoid.JumpPower = _G.FishIt.JumpPower
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════

local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "FishItESP"

task.spawn(function()
    while task.wait(3) do
        if _G.FishIt.ESP then
            ESPFolder:ClearAllChildren()
            
            -- ESP Players
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = plr.Character
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = ESPFolder
                    
                    local bill = Instance.new("BillboardGui")
                    bill.Adornee = plr.Character.HumanoidRootPart
                    bill.Size = UDim2.new(0, 100, 0, 40)
                    bill.StudsOffset = Vector3.new(0, 3, 0)
                    bill.AlwaysOnTop = true
                    bill.Parent = ESPFolder
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.Name
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Parent = bill
                end
            end
        else
            ESPFolder:ClearAllChildren()
        end
    end
end)

-- Fullbright Loop
task.spawn(function()
    while task.wait(1) do
        if _G.FishIt.FullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- NATIVE UI CREATION
-- ═══════════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItNative"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LP.PlayerGui

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 550)
Main.Position = UDim2.new(0.5, -210, 0.5, -275)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Make Draggable
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 40)
Top.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Top.BorderSizePixel = 0
Top.Parent = Main

Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 10)

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 10)
TopFix.Position = UDim2.new(0, 0, 1, -10)
TopFix.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopFix.BorderSizePixel = 0
TopFix.Parent = Top

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐟 FISH IT! HUB v2.5 REPAIRED"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

-- Stats Display
local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(0, 120, 1, 0)
Stats.Position = UDim2.new(1, -190, 0, 0)
Stats.BackgroundTransparency = 1
Stats.Text = "Fish: 0"
Stats.TextColor3 = Color3.fromRGB(200, 200, 200)
Stats.TextSize = 11
Stats.Font = Enum.Font.Gotham
Stats.TextXAlignment = Enum.TextXAlignment.Right
Stats.Parent = Top

task.spawn(function()
    while task.wait(1) do
        if Stats then
            Stats.Text = "Fish: " .. _G.FishIt.FishCaught
        end
    end
end)

-- Minimize Button
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Position = UDim2.new(1, -70, 0, 5)
Minimize.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 18
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Top

Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 6)

-- Close Button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 14
Close.Font = Enum.Font.GothamBold
Close.Parent = Top

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

-- Scroll Frame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -48)
Scroll.Position = UDim2.new(0, 8, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
Scroll.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 8)
List.Parent = Scroll

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 8)
end)

-- Minimize Logic
local minimized = false
Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 420, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        Scroll.Visible = false
        Minimize.Text = "+"
    else
        Main:TweenSize(UDim2.new(0, 420, 0, 550), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        Scroll.Visible = true
        Minimize.Text = "-"
    end
end)

Close.MouseButton1Click:Connect(function()
    _G.FishIt.AutoFish = false
    ESPFolder:Destroy()
    ScreenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENTS
-- ═══════════════════════════════════════════════════════════════

local function Section(text)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, 0, 0, 32)
    F.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    F.Parent = Scroll
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 1, 0)
    L.Position = UDim2.new(0, 10, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
end

local function Toggle(text, default, callback)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, 0, 0, 40)
    F.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    F.Parent = Scroll
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.68, 0, 1, 0)
    L.Position = UDim2.new(0, 12, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(240, 240, 240)
    L.TextSize = 12
    L.Font = Enum.Font.Gotham
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
    
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 48, 0, 26)
    B.Position = UDim2.new(1, -56, 0.5, -13)
    B.BackgroundColor3 = default and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(70, 70, 80)
    B.Text = default and "ON" or "OFF"
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.TextSize = 11
    B.Font = Enum.Font.GothamBold
    B.Parent = F
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 5)
    
    local on = default
    B.MouseButton1Click:Connect(function()
        on = not on
        B.BackgroundColor3 = on and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(70, 70, 80)
        B.Text = on and "ON" or "OFF"
        callback(on)
    end)
end

local function Slider(text, min, max, default, callback)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, 0, 0, 55)
    F.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    F.Parent = Scroll
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -20, 0, 18)
    L.Position = UDim2.new(0, 12, 0, 6)
    L.BackgroundTransparency = 1
    L.Text = text .. ": " .. default
    L.TextColor3 = Color3.fromRGB(200, 200, 200)
    L.TextSize = 11
    L.Font = Enum.Font.Gotham
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
    
    local BgBar = Instance.new("Frame")
    BgBar.Size = UDim2.new(1, -24, 0, 6)
    BgBar.Position = UDim2.new(0, 12, 0, 32)
    BgBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    BgBar.BorderSizePixel = 0
    BgBar.Parent = F
    Instance.new("UICorner", BgBar).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = BgBar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local DragBtn = Instance.new("TextButton")
    DragBtn.Size = UDim2.new(1, 0, 2, 0)
    DragBtn.BackgroundTransparency = 1
    DragBtn.Text = ""
    DragBtn.Parent = BgBar
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - BgBar.AbsolutePosition.X) / BgBar.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max - min) * pos) * 10) / 10
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        L.Text = text .. ": " .. val
        callback(val)
    end
    
    local dragging = false
    DragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function Button(text, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 36)
    B.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.TextSize = 12
    B.Font = Enum.Font.GothamBold
    B.Parent = Scroll
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    
    B.MouseButton1Click:Connect(function()
        B.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
        task.wait(0.1)
        B.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        callback()
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- BUILD UI (RESTORING THE MISSING PARTS)
-- ═══════════════════════════════════════════════════════════════

Section("🎣 AUTO FARMING")

Toggle("Auto Fish", false, function(v)
    _G.FishIt.AutoFish = v
    if v then
        Notify("Auto Fish", "Started!")
        FishingSystem:StartAutoFish()
    else
        Notify("Auto Fish", "Stopped") 
    end
end)

Toggle("⚡ Instant Catch", false, function(v)
    _G.FishIt.InstantCatch = v
end)

Slider("Cast Delay", 0, 5, 0.5, function(v)
    _G.FishIt.CastDelay = v
end)

Slider("Reel Delay", 0, 3, 0.3, function(v)
    _G.FishIt.ReelDelay = v
end)

Section("💰 AUTO SELL")

Toggle("Enable Auto Sell", false, function(v)
    _G.FishIt.AutoSell = v
end)

Slider("Sell Interval (Fish)", 5, 50, 10, function(v)
    _G.FishIt.SellInterval = v
end)

Button("Teleport to Shop Manually", function()
    FishingSystem:SellFish()
end)

Section("⚡ PLAYER MODS")

Slider("WalkSpeed", 16, 200, 16, function(v)
    _G.FishIt.WalkSpeed = v
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = v
    end
end)

Slider("JumpPower", 50, 400, 50, function(v)
    _G.FishIt.JumpPower = v
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.JumpPower = v
    end
end)

Toggle("Noclip (Walk Thru Walls)", false, function(v)
    _G.FishIt.Noclip = v
end)

Toggle("Infinite Jump", false, function(v)
    _G.FishIt.InfJump = v
end)

Section("👁️ VISUALS")

Toggle("ESP Players", false, function(v)
    _G.FishIt.ESP = v
    if not v then
        ESPFolder:ClearAllChildren()
    end
end)

Toggle("Fullbright (Night Vision)", false, function(v)
    _G.FishIt.FullBright = v
    if not v then
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
    end
end)

Section("📜 OTHER")

Button("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 30)
Credit.BackgroundTransparency = 1
Credit.Text = "Repaired & Fixed by Gemini"
Credit.TextColor3 = Color3.fromRGB(100, 100, 100)
Credit.TextSize = 10
Credit.Font = Enum.Font.Gotham
Credit.Parent = Scroll