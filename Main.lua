--[[
    Fish It! Script Hub - Main.lua
    Entry Point - Loads all modules
    GitHub: fahmi1804/FishItScriptHub
]]

repeat task.wait() until game:IsLoaded()

-- Anti double load
if _G.FishItHubLoaded then
    warn("[Fish It!] Already loaded!")
    local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("FishItHub")
    if gui then gui:Destroy() end
    task.wait(0.5)
end
_G.FishItHubLoaded = true

print("[Fish It!] Loading modules...")

-- Base URL
local BASE_URL = "https://raw.githubusercontent.com/fahmi1804/FishItScriptHub/main/"

-- Load function
local function LoadModule(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    
    if success then
        print("[Fish It!] ✓ Loaded: " .. path)
        return result
    else
        warn("[Fish It!] ✗ Failed: " .. path)
        warn(result)
        return nil
    end
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Load Config
local Config = LoadModule("Config/Settings.lua")
if not Config then
    error("[Fish It!] Failed to load config!")
    return
end

-- Load Utilities
local Utils = LoadModule("Modules/Utilities.lua")
if not Utils then
    error("[Fish It!] Failed to load utilities!")
    return
end

-- Load Modules
local AutoFish = LoadModule("Modules/AutoFish.lua")
local Merchant = LoadModule("Modules/Merchant.lua")
local Teleport = LoadModule("Modules/Teleport.lua")
local ESP = LoadModule("Modules/ESP.lua")

-- Load UI
local UILib = LoadModule("UI/Library.lua")
if not UILib then
    error("[Fish It!] Failed to load UI!")
    return
end

-- Initialize modules
if AutoFish then AutoFish.Init(Config, Utils) end
if Merchant then Merchant.Init(Config, Utils) end
if Teleport then Teleport.Init(Config, Utils) end
if ESP then ESP.Init(Config, Utils) end

-- Create UI
local Window = UILib:CreateWindow({
    Title = "🐟 Fish It! Hub",
    Size = UDim2.new(0, 450, 0, 520)
})

-- Auto Farm Tab
local AutoTab = Window:CreateTab("⚡ Auto Farm")

AutoTab:CreateToggle("Auto Fish", false, function(value)
    Config.AutoFish = value
    if AutoFish then
        if value then
            AutoFish.Start()
        else
            AutoFish.Stop()
        end
    end
end)

AutoTab:CreateToggle("Instant Catch", false, function(value)
    Config.InstantCatch = value
end)

AutoTab:CreateToggle("Auto Equip Best Rod", false, function(value)
    Config.AutoEquipBestRod = value
end)

AutoTab:CreateButton("Cast Rod Now", function()
    if AutoFish then
        AutoFish.Cast()
    end
end)

-- Merchant Tab
local MerchantTab = Window:CreateTab("💰 Merchant")

MerchantTab:CreateToggle("Auto Sell", false, function(value)
    Config.AutoSell = value
    if Merchant and value then
        Merchant.StartAutoSell()
    end
end)

MerchantTab:CreateToggle("Sell Common", true, function(value)
    Config.SellCommon = value
end)

MerchantTab:CreateToggle("Sell Rare", false, function(value)
    Config.SellRare = value
end)

MerchantTab:CreateToggle("Sell Legendary", false, function(value)
    Config.SellLegendary = value
end)

MerchantTab:CreateButton("TP to Merchant", function()
    if Merchant then
        Merchant.TeleportToMerchant()
    end
end)

MerchantTab:CreateButton("Sell All Now", function()
    if Merchant then
        Merchant.SellAll()
    end
end)

-- Teleport Tab
local TPTab = Window:CreateTab("🌍 Teleport")

TPTab:CreateButton("Spawn", function()
    if Teleport then Teleport.ToSpawn() end
end)

TPTab:CreateButton("Fishing Spot 1", function()
    if Teleport then Teleport.ToFishingSpot(1) end
end)

TPTab:CreateButton("Fishing Spot 2", function()
    if Teleport then Teleport.ToFishingSpot(2) end
end)

TPTab:CreateButton("Deep Ocean", function()
    if Teleport then Teleport.ToDeepOcean() end
end)

-- ESP Tab
local ESPTab = Window:CreateTab("👁️ ESP")

ESPTab:CreateToggle("Fish ESP", false, function(value)
    Config.FishESP = value
    if ESP then
        ESP.ToggleFishESP(value)
    end
end)

ESPTab:CreateToggle("Merchant ESP", false, function(value)
    Config.MerchantESP = value
    if ESP then
        ESP.ToggleMerchantESP(value)
    end
end)

ESPTab:CreateToggle("NPC ESP", false, function(value)
    Config.NPCESP = value
    if ESP then
        ESP.ToggleNPCESP(value)
    end
end)

-- Player Tab
local PlayerTab = Window:CreateTab("👤 Player")

PlayerTab:CreateSlider("WalkSpeed", 16, 300, 16, function(value)
    Config.WalkSpeed = value
    local char = Player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = value end
    end
end)

PlayerTab:CreateSlider("JumpPower", 50, 300, 50, function(value)
    Config.JumpPower = value
    local char = Player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = value end
    end
end)

PlayerTab:CreateToggle("Noclip", false, function(value)
    Config.Noclip = value
end)

PlayerTab:CreateToggle("Infinite Jump", false, function(value)
    Config.InfJump = value
end)

PlayerTab:CreateToggle("Fly (WASD)", false, function(value)
    Config.Fly = value
end)

PlayerTab:CreateSlider("Fly Speed", 10, 200, 50, function(value)
    Config.FlySpeed = value
end)

-- Settings Tab
local SettingsTab = Window:CreateTab("⚙️ Settings")

SettingsTab:CreateButton("Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end)

SettingsTab:CreateButton("Server Hop", function()
    local success, servers = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
    end)
    
    if success and servers then
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                break
            end
        end
    end
end)

SettingsTab:CreateButton("Destroy GUI", function()
    _G.FishItHubLoaded = false
    Config.AutoFish = false
    Config.Fly = false
    Window:Destroy()
end)

-- Apply player mods
RunService.Heartbeat:Connect(function()
    if Config.Noclip then
        local char = Player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfJump then
        local char = Player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Fly System
local FlyBody = nil
spawn(function()
    while task.wait() do
        if Config.Fly then
            local char = Player.Character
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
                    local speed = Config.FlySpeed
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

-- Done
if Utils then
    Utils.Notify("Fish It!", "Loaded Successfully!")
end
print("[Fish It!] All modules loaded!")
print("[Fish It!] Script ready!")