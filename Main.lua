--[[
    Fish It! Script Hub v2.0 (Expanded)
    Added: Manual Delays, Auto Sell Logic, ESP, Anti-AFK, Server Hop
    Compatible: Xeno (PC) & Delta (Mobile)
]]

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Anti-AFK Script (Supaya gak disconnect)
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

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
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

-- Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Notification Helper
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🐟 " .. title;
            Text = text;
            Duration = 3;
        })
    end)
end

notify("Fish It!", "Loading Extra Features...")

-- Global Config (Expanded)
_G.FishItSettings = _G.FishItSettings or {
    -- Farming
    AutoFish = false,
    InstantCatch = false,
    AutoEquipBestRod = false,
    CastDelay = 0.5, -- NEW
    ReelDelay = 0.5, -- NEW
    
    -- Selling
    AutoSell = false,
    SellDelay = 5,
    
    -- Player
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    InfJump = false,
    
    -- Visuals
    ESPPlayer = false,
    ESPFish = false,
    FullBright = false
}

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

local function GetRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:match("rod") or name:match("fish") then
                return tool
            end
        end
    end
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:match("rod") or name:match("fish") then
                return tool
            end
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if not rod then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    
    if rod.Parent ~= char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(rod)
            task.wait(0.3)
            return true
        end
    end
    return true
end

local function ClickRod()
    local rod = GetRod()
    if not rod then return end
    pcall(function() rod:Activate() end)
end

-- Deteksi Gigitan (UI Based Detection)
local function CheckBite()
    local gui = LocalPlayer.PlayerGui
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            local text = v.Text:lower()
            if text:match("!") or text:match("catch") or text:match("reel") then
                return true
            end
        end
        if v:IsA("ImageLabel") and v.Visible then
            if v.Name:lower():match("catch") or v.Name:lower():match("fish") then
                return true
            end
        end
    end
    return false
end

-- ========================================
-- AUTO FISH SYSTEM (IMPROVED)
-- ========================================

spawn(function()
    while task.wait(0.1) do
        if _G.FishItSettings.AutoFish then
            if EquipRod() then
                -- Step 1: Cast
                ClickRod()
                
                -- Manual Cast Delay (Fitur Request)
                task.wait(_G.FishItSettings.CastDelay) 
                
                -- Wait for bite
                local bitten = false
                local startTime = tick()
                
                repeat
                    if CheckBite() then
                        bitten = true
                    end
                    task.wait(0.1)
                until bitten or tick() - startTime > 20 or not _G.FishItSettings.AutoFish
                
                if bitten then
                    -- Manual Reel Delay (Fitur Request)
                    task.wait(_G.FishItSettings.ReelDelay)
                    
                    if _G.FishItSettings.InstantCatch then
                        ClickRod() -- Sekali klik
                    else
                        -- Spam klik dikit buat narik
                        ClickRod()
                        task.wait(0.1)
                        ClickRod()
                    end
                    
                    -- Tunggu animasi selesai
                    task.wait(2.5)
                else
                    -- Reset jika terlalu lama
                    ClickRod() 
                    task.wait(1)
                end
            else
                -- Jika tidak ada rod
                task.wait(2)
            end
        end
    end
end)

-- ========================================
-- AUTO SELL SYSTEM (NEW LOGIC)
-- ========================================

local function FindMerchant()
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and (model.Name:lower():match("merchant") or model.Name:lower():match("sell")) then
            if model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart then
                return model
            end
        end
    end
    return nil
end

spawn(function()
    while task.wait(1) do
        if _G.FishItSettings.AutoSell then
            task.wait(_G.FishItSettings.SellDelay)
            
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local oldPos = char.HumanoidRootPart.CFrame
                local merchant = FindMerchant()
                
                if merchant then
                    notify("Auto Sell", "Selling fish...")
                    
                    -- Teleport ke merchant
                    local targetPos = merchant:GetPivot()
                    char.HumanoidRootPart.CFrame = targetPos * CFrame.new(0, 0, 3)
                    task.wait(0.5)
                    
                    -- Trigger Proximity Prompts
                    for _, prompt in pairs(merchant:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            fireproximityprompt(prompt)
                            task.wait(0.2)
                        end
                    end
                    
                    task.wait(1)
                    -- Balik ke posisi asal
                    char.HumanoidRootPart.CFrame = oldPos
                end
            end
        end
    end
end)

-- ========================================
-- ESP / VISUALS (NEW)
-- ========================================

local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "FishItESP"

local function CreateESP(target, text, color)
    if not target then return end
    
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "ESP"
    BillboardGui.Adornee = target
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Parent = ESPFolder
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = text
    TextLabel.TextColor3 = color
    TextLabel.TextStrokeTransparency = 0
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 14
    TextLabel.Parent = BillboardGui
    
    -- Highlight
    local Highlight = Instance.new("Highlight")
    Highlight.Adornee = target.Parent
    Highlight.FillColor = color
    Highlight.OutlineColor = Color3.new(1,1,1)
    Highlight.FillTransparency = 0.5
    Highlight.Parent = ESPFolder
end

-- ESP Loop
spawn(function()
    while task.wait(2) do
        ESPFolder:ClearAllChildren()
        
        if _G.FishItSettings.ESPPlayer then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    CreateESP(plr.Character.HumanoidRootPart, plr.Name, Color3.fromRGB(255, 0, 0))
                end
            end
        end
        
        if _G.FishItSettings.ESPFish then
            -- Contoh deteksi area mancing (sesuaikan nama part di game)
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():match("zone") or v.Name:lower():match("fish")) then
                   -- CreateESP(v, "Fishing Spot", Color3.fromRGB(0, 255, 255))
                   -- (Di-comment biar ga lag kalau kebanyakan part, aktifkan jika tau nama part spesifik)
                end
            end
        end
    end
end)

-- ========================================
-- UI CREATION
-- ========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 480, 0, 600) -- Size diperbesar
Main.Position = UDim2.new(0.5, -240, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 45)
Top.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = Top

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 10)
TopFix.Position = UDim2.new(0, 0, 1, -10)
TopFix.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TopFix.BorderSizePixel = 0
TopFix.Parent = Top

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐟 Fish It! Hub v2.0 (MAX)"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

-- Minimize Button
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 35, 0, 35)
Minimize.Position = UDim2.new(1, -80, 0, 5)
Minimize.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
Minimize.Text = "_"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 22
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Top
Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0,8)

-- Close Button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Close.Parent = Top
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,8)

-- Scroll Area
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -55)
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
Scroll.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 10)
List.Parent = Scroll

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
end)

-- Logic Minimize
local minimized = false
local originalSize = Main.Size
Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 480, 0, 45)}):Play()
        Scroll.Visible = false
        Minimize.Text = "+"
    else
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = originalSize}):Play()
        Scroll.Visible = true
        Minimize.Text = "_"
    end
end)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.FishItSettings.AutoFish = false
    ESPFolder:Destroy()
end)

-- ========================================
-- UI COMPONENTS (BUILDERS)
-- ========================================

local function Section(text)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 35)
    F.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    F.Parent = Scroll
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 1, 0)
    L.BackgroundTransparency = 1
    L.Text = "  " .. text
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 15
    L.Font = Enum.Font.GothamBlack
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
end

local function Toggle(text, default, callback)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 45)
    F.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    F.Parent = Scroll
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.7, 0, 1, 0)
    L.Position = UDim2.new(0, 15, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 14
    L.Font = Enum.Font.Gotham
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
    
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 50, 0, 28)
    B.Position = UDim2.new(1, -60, 0.5, -14)
    B.BackgroundColor3 = default and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(80, 80, 90)
    B.Text = default and "ON" or "OFF"
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.TextSize = 12
    B.Font = Enum.Font.GothamBold
    B.Parent = F
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    
    local on = default
    B.MouseButton1Click:Connect(function()
        on = not on
        B.BackgroundColor3 = on and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(80, 80, 90)
        B.Text = on and "ON" or "OFF"
        callback(on)
    end)
end

local function Slider(text, min, max, default, callback)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 60)
    F.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    F.Parent = Scroll
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -20, 0, 20)
    L.Position = UDim2.new(0, 15, 0, 5)
    L.BackgroundTransparency = 1
    L.Text = text .. ": " .. default
    L.TextColor3 = Color3.fromRGB(200, 200, 200)
    L.TextSize = 13
    L.Font = Enum.Font.Gotham
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
    
    local BgBar = Instance.new("Frame")
    BgBar.Size = UDim2.new(1, -30, 0, 6)
    BgBar.Position = UDim2.new(0, 15, 0, 35)
    BgBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    BgBar.Parent = F
    Instance.new("UICorner", BgBar).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
    Fill.Parent = BgBar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local DragBtn = Instance.new("TextButton")
    DragBtn.Size = UDim2.new(1, 0, 1, 0)
    DragBtn.BackgroundTransparency = 1
    DragBtn.Text = ""
    DragBtn.Parent = BgBar
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - BgBar.AbsolutePosition.X) / BgBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos * 10) / 10 -- Round 1 decimal
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
        if dragging then Update(input) end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function Button(text, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -5, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.TextSize = 14
    B.Font = Enum.Font.GothamBold
    B.Parent = Scroll
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
    
    B.MouseButton1Click:Connect(function()
        B.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
        task.wait(0.1)
        B.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        callback()
    end)
end

-- ========================================
-- UI BUILD OUT
-- ========================================

Section("🎣 MAIN FARMING")
Toggle("Enable Auto Fish", false, function(v) 
    _G.FishItSettings.AutoFish = v 
    if v then notify("System", "Auto Fish Started!") end
end)

Toggle("Instant Catch (Blatant)", false, function(v)
    _G.FishItSettings.InstantCatch = v
end)

-- REQUESTED FEATURES: MANUAL DELAY
Slider("Cast Delay (Detik)", 0, 5, 0.5, function(v)
    _G.FishItSettings.CastDelay = v
end)

Slider("Reel Delay (Detik)", 0, 5, 0.5, function(v)
    _G.FishItSettings.ReelDelay = v
end)

Section("💰 AUTO SELL")
Toggle("Auto Sell (Teleport)", false, function(v)
    _G.FishItSettings.AutoSell = v
end)

Slider("Sell Loop Delay (Detik)", 5, 60, 10, function(v)
    _G.FishItSettings.SellDelay = v
end)

Section("🌍 TELEPORTS")
Button("Teleport to Spawn", function()
    local spawn = workspace:FindFirstChild("SpawnLocation")
    if spawn then 
        LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
    end
end)

Button("Teleport to Merchant", function()
    local m = FindMerchant()
    if m then
        LocalPlayer.Character.HumanoidRootPart.CFrame = m:GetPivot() * CFrame.new(0,0,3)
    else
        notify("Error", "Merchant not found!")
    end
end)

Section("👁️ VISUALS (ESP)")
Toggle("ESP Players", false, function(v)
    _G.FishItSettings.ESPPlayer = v
end)
Toggle("Fullbright (Terang)", false, function(v)
    if v then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    else
        Lighting.Brightness = 1
        Lighting.FogEnd = 500
    end
end)

Section("⚡ PLAYER MODS")
Slider("WalkSpeed", 16, 200, 16, function(v)
    LocalPlayer.Character.Humanoid.WalkSpeed = v
end)
Slider("JumpPower", 50, 400, 50, function(v)
    LocalPlayer.Character.Humanoid.JumpPower = v
end)
Toggle("Noclip", false, function(v)
    _G.FishItSettings.Noclip = v
    RunService.Stepped:Connect(function()
        if _G.FishItSettings.Noclip and LocalPlayer.Character then
            for _,p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

Section("⚙️ SERVER & MISC")
Button("Server Hop (Pindah Server)", function()
    local x = {}
    for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
        if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
            x[#x + 1] = v.id
        end
    end
    if #x > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)], LocalPlayer)
    else
        notify("Server Hop", "No other servers found!")
    end
end)

Button("FPS Boost (Anti-Lag)", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("UnionOperation") then
            v.Material = Enum.Material.SmoothPlastic
            v.Color = Color3.new(0,0,0)
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        end
    end
    notify("System", "FPS Boosted!")
end)

Button("Unload UI", function()
    ScreenGui:Destroy()
    ESPFolder:Destroy()
    _G.FishItSettings.AutoFish = false
end)

-- Finalize
ScreenGui.Parent = PlayerGui
notify("Fish It!", "Loaded! Scroll down for new features.")