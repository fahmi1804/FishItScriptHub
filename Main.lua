--[[
╔═══════════════════════════════════════════════════════════════╗
║     FISH IT! HUB - MANUAL CONTROL EDITION                     ║
║     Full Manual Settings - Adjustable Everything              ║
║     Compatible dengan Chloe X style GUI di screenshot         ║
╚═══════════════════════════════════════════════════════════════╝
]]

repeat task.wait() until game:IsLoaded()

-- Anti-AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

-- Remove old GUI
task.wait(0.3)
pcall(function()
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("FishHub") then
        game.Players.LocalPlayer.PlayerGui.FishHub:Destroy()
    end
end)

-- Services
local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- Get character
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- Notification
local function notify(txt)
    game.StarterGui:SetCore("SendNotification", {
        Title = "🐟 Fish Hub",
        Text = txt,
        Duration = 2
    })
end

notify("Loading Manual Control...")

-- Config dengan pengaturan manual
local cfg = {
    -- Fishing settings
    autofish = false,
    autosell = false,
    
    -- Manual timing (ADJUST INI!)
    castHoldTime = 0.8,      -- Berapa lama hold mouse saat cast
    waitAfterCast = 2.0,     -- Tunggu setelah cast sebelum cek bite
    biteCheckInterval = 0.2, -- Seberapa sering cek bite
    maxWaitTime = 20,        -- Max tunggu bite (detik)
    reelClicks = 5,          -- Berapa kali klik saat reel
    reelDelay = 0.1,         -- Delay antar klik reel
    animationWait = 2.5,     -- Tunggu animasi selesai
    
    -- Sell settings
    sellEvery = 10,          -- Jual setiap X ikan
    
    -- Player mods
    speed = 16,
    jump = 50,
    noclip = false,
    
    -- Detection method
    detectionMethod = "gui", -- "gui", "sound", "animation"
    useRemotes = true,       -- Coba fire remote events
    
    -- Debug
    showDebug = false
}

-- Stats
local stats = {
    caught = 0,
    casts = 0,
    bites = 0,
    misses = 0
}

-- Debug log
local function debug(txt)
    if cfg.showDebug then
        print("[FISH DEBUG] " .. txt)
    end
end

-- ═══════════════════════════════════════════════════════════
-- FISHING FUNCTIONS - MANUAL CONTROL
-- ═══════════════════════════════════════════════════════════

-- Get rod
local function getRod()
    -- Check equipped first
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Tool") then
            local n = v.Name:lower()
            if n:match("rod") or n:match("fish") or n:match("pole") or n:match("element") then
                debug("Found equipped rod: " .. v.Name)
                return v
            end
        end
    end
    
    -- Check backpack
    for _, v in pairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            local n = v.Name:lower()
            if n:match("rod") or n:match("fish") or n:match("pole") or n:match("element") then
                debug("Found rod in backpack: " .. v.Name)
                return v
            end
        end
    end
    
    return nil
end

-- Equip rod
local function equipRod()
    local rod = getRod()
    if rod then
        if rod.Parent == plr.Backpack then
            debug("Equipping rod...")
            hum:EquipTool(rod)
            task.wait(0.5)
        end
        return true
    end
    debug("No rod found!")
    return false
end

-- Cast dengan timing yang bisa diatur
local function cast()
    local rod = getRod()
    if not rod or rod.Parent ~= char then
        debug("Rod not equipped!")
        return false
    end
    
    debug("Casting... Hold time: " .. cfg.castHoldTime .. "s")
    
    -- Method 1: Tool activation
    pcall(function()
        rod:Activate()
    end)
    
    -- Method 2: Mouse hold (ADJUSTABLE)
    mouse1press()
    task.wait(cfg.castHoldTime) -- SETTING MANUAL
    mouse1release()
    
    -- Method 3: Try fire remotes if enabled
    if cfg.useRemotes then
        pcall(function()
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    local n = v.Name:lower()
                    if n:match("cast") or n:match("throw") or n:match("fish") then
                        v:FireServer()
                        debug("Fired remote: " .. v.Name)
                    end
                end
            end
        end)
    end
    
    stats.casts = stats.casts + 1
    return true
end

-- Check bite dengan multiple methods
local function isBiting()
    -- Method 1: GUI Detection
    if cfg.detectionMethod == "gui" or cfg.detectionMethod == "all" then
        for _, gui in pairs(plr.PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible then
                local txt = gui.Text:lower()
                if txt:match("!") or txt:match("click") or txt:match("catch") or txt:match("reel") or txt:match("pull") then
                    debug("Bite detected via GUI: " .. gui.Text)
                    return true
                end
            end
            
            -- Check images too
            if gui:IsA("ImageLabel") and gui.Visible then
                local n = gui.Name:lower()
                if n:match("catch") or n:match("bite") or n:match("fish") then
                    debug("Bite detected via Image: " .. gui.Name)
                    return true
                end
            end
        end
    end
    
    -- Method 2: Sound Detection
    if cfg.detectionMethod == "sound" or cfg.detectionMethod == "all" then
        local rod = getRod()
        if rod then
            for _, v in pairs(rod:GetDescendants()) do
                if v:IsA("Sound") and v.Playing then
                    debug("Bite detected via Sound: " .. v.Name)
                    return true
                end
            end
        end
    end
    
    -- Method 3: Animation Detection
    if cfg.detectionMethod == "animation" or cfg.detectionMethod == "all" then
        if char:FindFirstChild("Humanoid") then
            local animator = char.Humanoid:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    local n = (track.Animation and track.Animation.Name or ""):lower()
                    if n:match("reel") or n:match("catch") or n:match("bite") then
                        debug("Bite detected via Animation: " .. n)
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Reel dengan settings manual
local function reel()
    local rod = getRod()
    if not rod then
        debug("No rod to reel with!")
        return
    end
    
    debug("Reeling... Clicks: " .. cfg.reelClicks .. ", Delay: " .. cfg.reelDelay .. "s")
    
    for i = 1, cfg.reelClicks do -- SETTING MANUAL
        -- Tool activation
        pcall(function()
            rod:Activate()
        end)
        
        -- Mouse click
        mouse1click()
        
        -- Try fire reel remotes
        if cfg.useRemotes then
            pcall(function()
                for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        local n = v.Name:lower()
                        if n:match("reel") or n:match("catch") or n:match("complete") then
                            v:FireServer()
                            v:FireServer(true)
                        end
                    end
                end
            end)
        end
        
        task.wait(cfg.reelDelay) -- SETTING MANUAL
    end
end

-- Main auto fish loop
local function autoFish()
    while cfg.autofish do
        task.wait(0.5)
        
        -- Step 1: Equip rod
        if not equipRod() then
            notify("⚠️ NO ROD FOUND!")
            task.wait(2)
            continue
        end
        
        -- Step 2: Cast
        if not cast() then
            task.wait(1)
            continue
        end
        
        notify("🎣 Casting...")
        task.wait(cfg.waitAfterCast) -- SETTING MANUAL
        
        -- Step 3: Wait for bite
        local waited = 0
        local gotBite = false
        
        debug("Waiting for bite... Max: " .. cfg.maxWaitTime .. "s")
        
        while waited < cfg.maxWaitTime and cfg.autofish do
            if isBiting() then
                gotBite = true
                stats.bites = stats.bites + 1
                break
            end
            task.wait(cfg.biteCheckInterval) -- SETTING MANUAL
            waited = waited + cfg.biteCheckInterval
        end
        
        -- Step 4: Reel if bite detected
        if gotBite then
            notify("🐟 BITE! Reeling...")
            reel()
            
            stats.caught = stats.caught + 1
            task.wait(cfg.animationWait) -- SETTING MANUAL
            
            -- Auto sell check
            if cfg.autosell and stats.caught % cfg.sellEvery == 0 then
                task.spawn(autoSell)
                task.wait(3)
            end
        else
            -- Timeout
            stats.misses = stats.misses + 1
            debug("Timeout - no bite detected")
            task.wait(0.5)
        end
    end
    
    notify("Auto Fish Stopped")
end

-- Auto sell
function autoSell()
    if not root then return end
    
    local oldPos = root.CFrame
    
    -- Find sell area
    local sell = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("Part") then
            local n = v.Name:lower()
            if n:match("sell") or n:match("shop") or n:match("merchant") or n:match("npc") then
                sell = v
                break
            end
        end
    end
    
    if sell then
        notify("💰 Selling...")
        
        -- Teleport
        local sellPos
        if sell:IsA("Model") then
            sellPos = sell:GetPivot()
        else
            sellPos = sell.CFrame
        end
        
        root.CFrame = sellPos * CFrame.new(0, 0, 5)
        task.wait(0.8)
        
        -- Trigger prompts
        for _, v in pairs(sell:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            elseif v:IsA("ClickDetector") then
                fireclickdetector(v)
            end
        end
        
        task.wait(1.5)
        root.CFrame = oldPos
        
        notify("✅ Sold! Total: " .. stats.caught)
    else
        notify("❌ Sell area not found!")
    end
end

-- ═══════════════════════════════════════════════════════════
-- PLAYER MODS
-- ═══════════════════════════════════════════════════════════

rs.Stepped:Connect(function()
    if cfg.noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    task.wait(1)
    hum.WalkSpeed = cfg.speed
    hum.JumpPower = cfg.jump
end)

-- ═══════════════════════════════════════════════════════════
-- UI - MANUAL SETTINGS STYLE
-- ═══════════════════════════════════════════════════════════

local sg = Instance.new("ScreenGui")
sg.Name = "FishHub"
sg.ResetOnSpawn = false
sg.Parent = plr.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 550)
main.Position = UDim2.new(0.5, -200, 0.5, -275)
main.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
main.BorderSizePixel = 0
main.Active = true
main.Parent = sg

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Draggable
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐟 FISH HUB - MANUAL CONTROL"
title.TextColor3 = Color3.fromRGB(100, 180, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -70, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
minimize.Text = "-"
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.TextSize = 18
minimize.Font = Enum.Font.GothamBold
minimize.Parent = top
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 6)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextSize = 14
close.Font = Enum.Font.GothamBold
close.Parent = top
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -12, 1, -48)
content.Position = UDim2.new(0, 6, 0, 44)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 5
content.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.Parent = content

list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 6)
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main:TweenSize(UDim2.new(0, 400, 0, 40), "Out", "Quad", 0.2, true)
        content.Visible = false
        minimize.Text = "+"
    else
        main:TweenSize(UDim2.new(0, 400, 0, 550), "Out", "Quad", 0.2, true)
        content.Visible = true
        minimize.Text = "-"
    end
end)

close.MouseButton1Click:Connect(function()
    cfg.autofish = false
    sg:Destroy()
end)

-- UI Helpers
local function section(txt)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    f.Parent = content
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = 13
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
end

local function toggle(txt, def, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    f.Parent = content
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.65, 0, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(230, 230, 230)
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 48, 0, 26)
    b.Position = UDim2.new(1, -54, 0.5, -13)
    b.BackgroundColor3 = def and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(70, 70, 80)
    b.Text = def and "ON" or "OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    
    local on = def
    b.MouseButton1Click:Connect(function()
        on = not on
        b.BackgroundColor3 = on and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(70, 70, 80)
        b.Text = on and "ON" or "OFF"
        callback(on)
    end)
end

local function slider(txt, min, max, def, step, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 52)
    f.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    f.Parent = content
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 18)
    l.Position = UDim2.new(0, 10, 0, 5)
    l.BackgroundTransparency = 1
    l.Text = txt .. ": " .. def
    l.TextColor3 = Color3.fromRGB(200, 200, 200)
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    bar.BorderSizePixel = 0
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 2, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = bar
    
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pos
        val = math.floor(val / step + 0.5) * step -- Round to step
        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        l.Text = txt .. ": " .. val
        callback(val)
    end
    
    local drag = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            update(input)
        end
    end)
    
    uis.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
end

local function button(txt, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback)
end

-- ═══════════════════════════════════════════════════════════
-- BUILD UI WITH MANUAL SETTINGS
-- ═══════════════════════════════════════════════════════════

section("🎣 AUTO FISHING")

toggle("Auto Fish", false, function(v)
    cfg.autofish = v
    if v then
        notify("Auto Fish ON")
        task.spawn(autoFish)
    else
        notify("Auto Fish OFF")
    end
end)

toggle("Auto Sell", false, function(v)
    cfg.autosell = v
end)

slider("Sell Every (Fish)", 5, 50, 10, 5, function(v)
    cfg.sellEvery = v
end)

section("⚙️ TIMING SETTINGS (PENTING!)")

slider("Cast Hold Time (s)", 0.1, 3, 0.8, 0.1, function(v)
    cfg.castHoldTime = v
end)

slider("Wait After Cast (s)", 0.5, 5, 2.0, 0.5, function(v)
    cfg.waitAfterCast = v
end)

slider("Max Wait Bite (s)", 10, 30, 20, 5, function(v)
    cfg.maxWaitTime = v
end)

slider("Reel Clicks", 1, 10, 5, 1, function(v)
    cfg.reelClicks = v
end)

slider("Reel Delay (s)", 0.05, 0.5, 0.1, 0.05, function(v)
    cfg.reelDelay = v
end)

slider("Animation Wait (s)", 1, 5, 2.5, 0.5, function(v)
    cfg.animationWait = v
end)

section("⚡ PLAYER MODS")

slider("Speed", 16, 150, 16, 5, function(v)
    cfg.speed = v
    hum.WalkSpeed = v
end)

slider("Jump", 50, 300, 50, 25, function(v)
    cfg.jump = v
    hum.JumpPower = v
end)

toggle("Noclip", false, function(v)
    cfg.noclip = v
end)

section("🔍 ADVANCED")

toggle("Use Remotes", true, function(v)
    cfg.useRemotes = v
end)

toggle("Show Debug", false, function(v)
    cfg.showDebug = v
end)

button("Manual Sell Now", function()
    autoSell()
end)

section("📊 STATS")

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 80)
statsLabel.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
statsLabel.Text = "Loading..."
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextSize = 10
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.Parent = content
Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 6)

local padding = Instance.new("UIPadding", statsLabel)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 8)

-- Update stats
task.spawn(function()
    while task.wait(1) do
        if statsLabel then
            statsLabel.Text = string.format(
                "Fish Caught: %d\nCasts: %d\nBites: %d\nMisses: %d\nStatus: %s",
                stats.caught,
                stats.casts,
                stats.bites,
                stats.misses,
                cfg.autofish and "FISHING..." or "Idle"
            )
        end
    end
end)

notify("Loaded! Adjust timing settings!")
print("Fish Hub Manual Control loaded!")