-- Loader.lua
-- Universal loader untuk Fish It! Script
-- Copy paste code ini ke executor Anda

--[[
    CARA PAKAI:
    1. Buka game Fish It! di Roblox
    2. Buka executor (Synapse X, Fluxus, KRNL, dll)
    3. Copy paste code di bawah ini
    4. Execute
    5. UI akan muncul otomatis
]]

-- Method 1: Direct Load (Paling Simple)
print("Loading Fish It! Script Hub...")

loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/FishItScriptHub/main/Main.lua"))()

--[[═══════════════════════════════════════════════════════════════

    ALTERNATIVE METHODS - Pilih salah satu

═══════════════════════════════════════════════════════════════]]

-- Method 2: With Status Messages
--[[
print("╔════════════════════════════════╗")
print("║   Fish It! Script Hub v1.0    ║")
print("║   Loading...                  ║")
print("╚════════════════════════════════╝")

local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/FishItScriptHub/main/Main.lua"))()
end)

if success then
    print("✅ Script loaded successfully!")
else
    warn("❌ Failed to load script:", err)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Load Failed",
        Text = "Check console for error details",
        Duration = 5
    })
end
]]

-- Method 3: With Cache Bypass (Force Latest Version)
--[[
print("Loading latest version...")

local version = tostring(math.random(1, 999999))
local url = "https://raw.githubusercontent.com/USERNAME/FishItScriptHub/main/Main.lua?v=" .. version

loadstring(game:HttpGet(url))()
]]

-- Method 4: With Loading Screen
--[[
-- Create loading screen
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LoadingScreen"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Fish It! Script Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0, 60)
Status.BackgroundTransparency = 1
Status.Text = "Loading..."
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0.8, 0, 0, 4)
LoadingBar.Position = UDim2.new(0.1, 0, 0, 110)
LoadingBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
LoadingBar.Parent = Frame

local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadingBarFill.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
LoadingBarFill.Parent = LoadingBar

-- Animate loading bar
task.spawn(function()
    for i = 0, 100, 2 do
        LoadingBarFill.Size = UDim2.new(i / 100, 0, 1, 0)
        wait(0.02)
    end
end)

-- Load script
wait(1)
Status.Text = "Fetching script..."
wait(0.5)

local success = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/FishItScriptHub/main/Main.lua"))()
end)

if success then
    Status.Text = "✅ Loaded!"
    wait(1)
    ScreenGui:Destroy()
else
    Status.Text = "❌ Failed to load"
    Status.TextColor3 = Color3.fromRGB(255, 50, 50)
    wait(3)
    ScreenGui:Destroy()
end
]]

-- Method 5: With Auto-Update Check
--[[
local currentVersion = "1.0"
local versionUrl = "https://raw.githubusercontent.com/USERNAME/FishItScriptHub/main/version.txt"

print("Checking for updates...")

local success, latestVersion = pcall(function()
    return game:HttpGet(versionUrl)
end)

if success and latestVersion then
    latestVersion = latestVersion:gsub("%s+", "") -- Remove whitespace
    
    if latestVersion ~= currentVersion then
        print("🔔 New version available: " .. latestVersion)
        print("📥 Downloading latest version...")
    else
        print("✅ You have the latest version")
    end
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/FishItScriptHub/main/Main.lua"))()
]]

-- Method 6: Multi-Game Support (Check PlaceId)
--[[
local supportedGames = {
    [121864768012064] = true -- Fish It! PlaceId
}

local currentPlaceId = game.PlaceId

if supportedGames[currentPlaceId] then
    print("✅ Game supported! Loading script...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/FishItScriptHub/main/Main.lua"))()
else
    warn("❌ This game is not supported!")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Not Supported",
        Text = "This script only works on Fish It!",
        Duration = 5
    })
end
]]

-- Method 7: With Backup URLs (Fallback)
--[[
local urls = {
    "https://raw.githubusercontent.com/USERNAME/FishItScriptHub/main/Main.lua",
    "https://pastebin.com/raw/YOUR_PASTE_ID", -- Backup URL
    "https://your-website.com/script.lua" -- Another backup
}

local loaded = false

for i, url in ipairs(urls) do
    print("Trying URL " .. i .. "...")
    
    local success = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("✅ Loaded from URL " .. i)
        loaded = true
        break
    else
        warn("❌ URL " .. i .. " failed, trying next...")
    end
end

if not loaded then
    warn("❌ All URLs failed to load!")
end
]]

--[[═══════════════════════════════════════════════════════════════

    QUICK SETUP GUIDE

    1. SETUP GITHUB:
       - Buat repository baru (public)
       - Upload Main.lua ke root folder
       - Copy raw URL dari Main.lua
    
    2. EDIT LOADER:
       - Ganti "USERNAME" dengan username GitHub Anda
       - Ganti "FishItScriptHub" dengan nama repo Anda
    
    3. CONTOH URL:
       https://raw.githubusercontent.com/JohnDoe/FishItScriptHub/main/Main.lua
    
    4. TEST:
       - Execute loader di game Fish It!
       - Pastikan UI muncul
       - Test semua features
    
    5. SHARE:
       - Copy loadstring code
       - Share ke teman atau community

═══════════════════════════════════════════════════════════════]]

--[[═══════════════════════════════════════════════════════════════

    TROUBLESHOOTING

    Problem: "attempt to call a nil value"
    Solution: Pastikan URL benar dan file ada di GitHub
    
    Problem: "HttpGet is not allowed"
    Solution: Gunakan executor yang support HttpGet
    
    Problem: Script tidak load
    Solution: 
    - Check internet connection
    - Pastikan repository adalah public
    - Coba cache bypass method
    
    Problem: UI tidak muncul
    Solution:
    - Rejoin game
    - Check console untuk error
    - Pastikan script kompatibel dengan executor
    
    Problem: Features tidak jalan
    Solution:
    - Check game update (script might be outdated)
    - Toggle features ON
    - Check executor compatibility

═══════════════════════════════════════════════════════════════]]

--[[═══════════════════════════════════════════════════════════════

    TIPS & BEST PRACTICES

    ✅ DO:
    - Use alt accounts for testing
    - Start with low settings
    - Monitor for game updates
    - Join script Discord for updates
    - Report bugs via GitHub Issues
    
    ❌ DON'T:
    - Use on main account
    - AFK farm in public servers
    - Share account credentials
    - Modify script without understanding
    - Use for griefing other players

═══════════════════════════════════════════════════════════════]]

print("Fish It! Script Hub - Ready!")
print("Join our Discord for updates and support")
print("Report bugs: github.com/USERNAME/REPO/issues")