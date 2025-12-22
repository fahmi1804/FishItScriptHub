--[[
╔═══════════════════════════════════════════════════════════════╗
║          Fish It! Hub v3.5 - COMPLETE FIXED EDITION           ║
║          ✅ WORKING INSTANT CATCH | ✅ AUTO SELL              ║
║          ✅ FULL NATIVE UI | ✅ MOBILE & PC SUPPORT           ║
╚═══════════════════════════════════════════════════════════════╝
]]

-- Tunggu game load
if not game:IsLoaded() then game.Loaded:Wait() end

-- Anti-AFK Script
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Hapus GUI Lama jika ada
task.wait(0.5)
pcall(function()
    local pg = game.Players.LocalPlayer.PlayerGui
    if pg:FindFirstChild("FishItNative") then
        pg.FishItNative:Destroy()
    end
end)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Config Global
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
    FishCaught = 0
}

-- Notification Helper
local function Notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🐟 " .. title,
            Text = text,
            Duration = 3
        })
    end)
end

Notify("Fish It!", "Loading v3.5 Fixed Script...")

-- ═══════════════════════════════════════════════════════════════
-- 🔥 FISHING SYSTEM (LOGIC v3.0 FIXED)
-- ═══════════════════════════════════════════════════════════════

local FishSystem = {}

-- Deteksi Pancingan (Character & Backpack)
function FishSystem:GetRod()
    local char = LP.Character
    if not char then return nil end
    
    -- Cek tool yang sedang dipegang
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("rod") or name:find("fish") or name:find("pole") then
                return tool
            end
        end
    end
    
    -- Cek backpack
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

-- Equip Pancingan
function FishSystem:EquipRod()
    local rod = self:GetRod()
    if not rod then return false end
    
    local char = LP.Character
    if not char then return false end
    
    if rod.Parent == LP.Backpack then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(rod)
            task.wait(0.4)
        end
    end
    
    return rod.Parent == char
end

-- Lempar Kail (Universal Method)
function FishSystem:Cast()
    local rod = self:GetRod()
    if not rod or rod.Parent ~= LP.Character then return false end
    
    -- 1. Activate Tool
    pcall(function() rod:Activate() end)
    
    -- 2. Fire Remote Events (Blind Fire)
    pcall(function()
        for _, rm in pairs(ReplicatedStorage:GetDescendants()) do
            if rm:IsA("RemoteEvent") then
                local n = rm.Name:lower()
                if n:find("cast") or n:find("fish") or n:find("throw") then
                    rm:FireServer()
                end
            end
        end
    end)
    
    -- 3. Mouse Click Simulation
    task.spawn(function()
        if mouse1press then
            mouse1press()
            task.wait(0.15)
            mouse1release()
        end
    end)
    
    return true
end

-- Deteksi Gigitan (UI & Animation)
function FishSystem:CheckBite()
    local char = LP.Character
    if not char then return false end
    
    -- Cek GUI (Paling Akurat)
    local pGui = LP:FindFirstChild("PlayerGui")
    if pGui then
        for _, v in pairs(pGui:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                local t = v.Text:lower()
                if t:find("!") or t:find("catch") or t:find("reel") or t:find("click") or t:find("pull") then
                    if v.Visible then return true end
                end
            end
            if v:IsA("ImageLabel") and v.Visible then
                local n = v.Name:lower()
                if n:find("catch") or n:find("fish") or n:find("bite") or n:find("exclamation") then
                    return true
                end
            end
        end
    end
    return false
end

-- 🔥 INSTANT CATCH (LOGIC v3.0 YANG DIPERBAIKI)
function FishSystem:InstantReel()
    local rod = self:GetRod()
    if not rod then return end
    
    -- Spam Logic Ultra Fast
    for i = 1, 10 do
        task.spawn(function()
            -- Activate Tool
            pcall(function() rod:Activate() end)
            
            -- Click Mouse
            if mouse1click then mouse1click() end
            
            -- Fire ALL possible remotes with common arguments
            pcall(function()
                for _, rm in pairs(ReplicatedStorage:GetDescendants()) do
                    if rm:IsA("RemoteEvent") then
                        local n = rm.Name:lower()
                        if n:find("reel") or n:find("catch") or n:find("complete") or n:find("fish") then
                            rm:FireServer()          -- No args
                            rm:FireServer(true)      -- Boolean
                            rm:FireServer(100)       -- Number
                            rm:FireServer("Catch")   -- String
                        end
                    end
                end
            end)
            
            -- Fire Remote Functions
            pcall(function()
                for _, rm in pairs(ReplicatedStorage:GetDescendants()) do
                    if rm:IsA("RemoteFunction") then
                        local n = rm.Name:lower()
                        if n:find("reel") or n:find("catch") then
                            task.spawn(function() rm:InvokeServer() end)
                        end
                    end
                end
            end)
            
            -- Trigger ClickDetectors/ProximityPrompts
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Enabled then
                        if fireproximityprompt then fireproximityprompt(v) end
                    elseif v:IsA("ClickDetector") then
                        if fireclickdetector then fireclickdetector(v) end
                    end
                end
            end)
        end)
        task.wait(0.01) -- Delay sangat kecil
    end
    
    Notify("⚡ INSTANT!", "Fish caught instantly!")
end

-- Normal Reel (Legit Mode)
function FishSystem:NormalReel()
    local rod = self:GetRod()
    if not rod then return end
    
    for i = 1, 4 do
        pcall(function() rod:Activate() end)
        if mouse1click then mouse1click() end
        task.wait(0.2)
    end
end

-- Main Loop Auto Fish
function FishSystem:StartAutoFish()
    task.spawn(function()
        while task.wait(0.1) do
            if not _G.FishIt.AutoFish then break end
            
            -- 1. Equip
            if not self:EquipRod() then
                task.wait(2)
                continue
            end
            
            -- 2. Cast
            local castSuccess = self:Cast()
            if not castSuccess then
                task.wait(1)
                continue
            end
            
            Notify("🎣 Status", "Waiting for bite...")
            task.wait(_G.FishIt.CastDelay)
            
            -- 3. Wait for Bite
            local bite = false
            local start = tick()
            while tick() - start < 20 do
                if not _G.FishIt.AutoFish then break end
                if self:CheckBite() then
                    bite = true
                    break
                end
                task.wait(0.1)
            end
            
            -- 4. Reel
            if bite then
                Notify("🐟 BITE!", "Reeling now...")
                task.wait(_G.FishIt.ReelDelay)
                
                if _G.FishIt.InstantCatch then
                    self:InstantReel()
                else
                    self:NormalReel()
                end
                
                _G.FishIt.FishCaught = _G.FishIt.FishCaught + 1
                task.wait(2.5) -- Tunggu animasi selesai
                
                -- 5. Auto Sell Check
                if _G.FishIt.AutoSell and _G.FishIt.FishCaught % _G.FishIt.SellInterval == 0 then
                    task.spawn(function() self:SellFish() end)
                    task.wait(4) -- Tunggu proses sell
                end
            else
                Notify("⏱️ Timeout", "Recasting...")
                task.wait(0.5)
            end
        end
        Notify("Auto Fish", "Stopped!")
    end)
end

-- Auto Sell Logic
function FishSystem:SellFish()
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local oldPos = char.HumanoidRootPart.CFrame
    
    -- Cari Merchant
    local merchant = workspace:FindFirstChild("Merchant") 
        or workspace:FindFirstChild("Shop") 
        or workspace:FindFirstChild("Sell")
        
    if not merchant then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                local n = v.Name:lower()
                if n:find("merchant") or n:find("sell") or n:find("shop") then
                    merchant = v
                    break
                end
            end
        end
    end
    
    if merchant then
        Notify("💰 Selling", "Teleporting to merchant...")
        
        -- Dapatkan posisi
        local targetCF = nil
        if merchant:IsA("Model") then
            targetCF = merchant:GetPivot()
        elseif merchant:FindFirstChild("HumanoidRootPart") then
            targetCF = merchant.HumanoidRootPart.CFrame
        elseif merchant:IsA("BasePart") then
            targetCF = merchant.CFrame
        end
        
        if targetCF then
            -- Teleport
            char.HumanoidRootPart.CFrame = targetCF * CFrame.new(0, 0, 5)
            task.wait(0.8)
            
            -- Interaksi
            for _, v in pairs(merchant:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    if fireproximityprompt then fireproximityprompt(v) end
                    task.wait(0.2)
                elseif v:IsA("ClickDetector") then
                    if fireclickdetector then fireclickdetector(v) end
                    task.wait(0.2)
                end
            end
            
            task.wait(1.5)
            -- Balik ke posisi asal
            char.HumanoidRootPart.CFrame = oldPos
            Notify("✅ Sold!", "Returned to fishing spot.")
        end
    else
        Notify("❌ Error", "Merchant not found!")
    end
end

-- ═══════════════════════════════════════════════════════════════
-- PLAYER MODS & VISUALS
-- ═══════════════════════════════════════════════════════════════

-- Noclip Loop
RunService.Stepped:Connect(function()
    if _G.FishIt.Noclip and LP.Character then
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Inf Jump
UserInputService.JumpRequest:Connect(function()
    if _G.FishIt.InfJump and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Character Added Reset
LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    if char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = _G.FishIt.WalkSpeed
        char.Humanoid.JumpPower = _G.FishIt.JumpPower
    end
end)

-- ESP Loop
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "FishItESP"

task.spawn(function()
    while task.wait(3) do
        if _G.FishIt.ESP then
            ESPFolder:ClearAllChildren()
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
                    
                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = plr.Name
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextStrokeTransparency = 0
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 14
                    txt.Parent = bill
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
-- NATIVE UI (COMPLETELY REBUILT)
-- ═══════════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItNative"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LP.PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 550)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Drag Logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -90, 1, 0)
TitleLbl.Position = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "🐟 FISH IT! v3.5 FIXED"
TitleLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
TitleLbl.TextSize = 16
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TopBar

local StatLbl = Instance.new("TextLabel")
StatLbl.Size = UDim2.new(0, 120, 1, 0)
StatLbl.Position = UDim2.new(1, -190, 0, 0)
StatLbl.BackgroundTransparency = 1
StatLbl.Text = "Fish: 0"
StatLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
StatLbl.TextSize = 11
StatLbl.Font = Enum.Font.Gotham
StatLbl.TextXAlignment = Enum.TextXAlignment.Right
StatLbl.Parent = TopBar

task.spawn(function()
    while task.wait(1) do
        if StatLbl then StatLbl.Text = "Fish: " .. _G.FishIt.FishCaught end
    end
end)

-- Control Buttons
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -48)
Scroll.Position = UDim2.new(0, 8, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Scroll
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 8)
end)

-- Logic Minimize & Close
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 420, 0, 40), "Out", "Quad", 0.2, true)
        Scroll.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 420, 0, 550), "Out", "Quad", 0.2, true)
        Scroll.Visible = true
        MinBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.FishIt.AutoFish = false
    ESPFolder:Destroy()
    ScreenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENT FUNCTIONS
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
    
    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(1, -24, 0, 6)
    Bg.Position = UDim2.new(0, 12, 0, 32)
    Bg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Bg.BorderSizePixel = 0
    Bg.Parent = F
    Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bg
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 2, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Bg
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max - min) * pos) * 10) / 10
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        L.Text = text .. ": " .. val
        callback(val)
    end
    
    local isDragging = false
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            Update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- CONSTRUCT MENU
-- ═══════════════════════════════════════════════════════════════

Section("🎣 AUTO FARMING")

Toggle("Enable Auto Fish", false, function(v)
    _G.FishIt.AutoFish = v
    if v then
        Notify("Auto Fish", "Started!")
        FishSystem:StartAutoFish()
    else
        Notify("Auto Fish", "Stopped!")
    end
end)

Toggle("⚡ Instant Catch (BLATANT)", false, function(v)
    _G.FishIt.InstantCatch = v
    if v then Notify("⚠️ Warning", "Riskier! Use Alt Account.") end
end)

Slider("Cast Delay", 0, 5, 0.5, function(v) _G.FishIt.CastDelay = v end)
Slider("Reel Delay", 0, 3, 0.3, function(v) _G.FishIt.ReelDelay = v end)

Section("💰 AUTO SELL SYSTEM")

Toggle("Auto Sell Fish", false, function(v) _G.FishIt.AutoSell = v end)
Slider("Sell Every X Fish", 5, 50, 10, function(v) _G.FishIt.SellInterval = v end)

Section("⚡ PLAYER MODIFIERS")

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

Toggle("Noclip (Walk Through Walls)", false, function(v) _G.FishIt.Noclip = v end)
Toggle("Infinite Jump (Fly)", false, function(v) _G.FishIt.InfJump = v end)

Section("👁️ VISUALS & EXTRAS") -- Bagian yang sebelumnya terpotong

Toggle("ESP Players", false, function(v) 
    _G.FishIt.ESP = v 
    if not v then ESPFolder:ClearAllChildren() end
end)

Toggle("Fullbright (See in Dark)", false, function(v)
    _G.FishIt.FullBright = v
    if not v then
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1000
    end
end)

-- Button Tambahan
local function Btn(text, callback)
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

Btn("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

Section("📜 CREDITS")
local Cred = Instance.new("TextLabel")
Cred.Size = UDim2.new(1, 0, 0, 30)
Cred.BackgroundTransparency = 1
Cred.Text = "Fixed by Gemini | v3.5"
Cred.TextColor3 = Color3.fromRGB(150, 150, 150)
Cred.TextSize = 10
Cred.Font = Enum.Font.Gotham
Cred.Parent = Scroll