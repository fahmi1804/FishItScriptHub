--[[
╔═══════════════════════════════════════════════════════════════╗
║     FISH IT! HUB - ULTRA SIMPLE VERSION                       ║
║     Dibuat dari NOLLL - 100% Tested & Working                 ║
║     Ultra Lightweight - No Bloat - Pure Function              ║
╚═══════════════════════════════════════════════════════════════╝
]]

-- Wait game load
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
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- Simple Notification
local function notify(txt)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Fish Hub",
        Text = txt,
        Duration = 2
    })
end

notify("Loading...")

-- Config
local cfg = {
    autofish = false,
    autosell = false,
    speed = 16,
    jump = 50,
    noclip = false
}

-- Stats
local stats = {
    caught = 0
}

-- ═══════════════════════════════════════════════════════════
-- FISHING FUNCTIONS (SIMPLE & DIRECT)
-- ═══════════════════════════════════════════════════════════

-- Get rod from character or backpack
local function getRod()
    -- Check what's equipped
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Tool") then
            local n = v.Name:lower()
            if n:match("rod") or n:match("fish") or n:match("pole") then
                return v
            end
        end
    end
    
    -- Check backpack
    for _, v in pairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            local n = v.Name:lower()
            if n:match("rod") or n:match("fish") or n:match("pole") then
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
            hum:EquipTool(rod)
            task.wait(0.5)
        end
        return true
    end
    return false
end

-- Cast (simple mouse click simulation)
local function cast()
    -- Method 1: Activate tool
    local rod = getRod()
    if rod and rod.Parent == char then
        rod:Activate()
        task.wait(0.1)
        
        -- Method 2: Mouse button
        mouse1press()
        task.wait(0.8)
        mouse1release()
        
        return true
    end
    return false
end

-- Check if fish is biting (check GUI)
local function isBiting()
    for _, gui in pairs(plr.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Visible then
            local txt = gui.Text:lower()
            if txt:match("!") or txt:match("click") or txt:match("catch") then
                return true
            end
        end
    end
    return false
end

-- Reel the fish
local function reel()
    local rod = getRod()
    if rod then
        -- Click multiple times
        for i = 1, 5 do
            rod:Activate()
            mouse1click()
            task.wait(0.1)
        end
    end
end

-- Main auto fish loop
local function autoFish()
    while cfg.autofish do
        task.wait(0.5)
        
        -- Step 1: Equip rod
        if not equipRod() then
            notify("No rod found!")
            task.wait(2)
            continue
        end
        
        -- Step 2: Cast
        if not cast() then
            task.wait(1)
            continue
        end
        
        notify("Casting...")
        task.wait(2) -- Wait for line to settle
        
        -- Step 3: Wait for bite
        local waited = 0
        local maxWait = 15
        local gotBite = false
        
        while waited < maxWait and cfg.autofish do
            if isBiting() then
                gotBite = true
                break
            end
            task.wait(0.2)
            waited = waited + 0.2
        end
        
        -- Step 4: Reel if bite detected
        if gotBite then
            notify("Reeling!")
            task.wait(0.3)
            reel()
            
            stats.caught = stats.caught + 1
            task.wait(2) -- Wait for animation
            
            -- Auto sell check
            if cfg.autosell and stats.caught % 10 == 0 then
                autoSell()
            end
        else
            -- Timeout, try again
            task.wait(0.5)
        end
    end
    
    notify("Auto Fish stopped")
end

-- Auto sell function
function autoSell()
    if not root then return end
    
    local oldPos = root.CFrame
    
    -- Find sell NPC/area
    local sell = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("Part") then
            local n = v.Name:lower()
            if n:match("sell") or n:match("shop") or n:match("merchant") then
                sell = v
                break
            end
        end
    end
    
    if sell then
        notify("Selling...")
        
        -- Teleport to sell
        local sellPos
        if sell:IsA("Model") then
            sellPos = sell:GetPivot()
        else
            sellPos = sell.CFrame
        end
        
        root.CFrame = sellPos * CFrame.new(0, 0, 5)
        task.wait(0.8)
        
        -- Trigger proximity prompts
        for _, v in pairs(sell:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            end
        end
        
        task.wait(1.5)
        
        -- Return to original position
        root.CFrame = oldPos
        notify("Sold! Total: " .. stats.caught)
    else
        notify("Sell area not found!")
    end
end

-- ═══════════════════════════════════════════════════════════
-- PLAYER MODS (SIMPLE)
-- ═══════════════════════════════════════════════════════════

-- Speed mod
local function setSpeed(val)
    cfg.speed = val
    hum.WalkSpeed = val
end

-- Jump mod
local function setJump(val)
    cfg.jump = val
    hum.JumpPower = val
end

-- Noclip
game:GetService("RunService").Stepped:Connect(function()
    if cfg.noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Character respawn handler
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    task.wait(1)
    hum.WalkSpeed = cfg.speed
    hum.JumpPower = cfg.jump
end)

-- ═══════════════════════════════════════════════════════════
-- ULTRA SIMPLE UI (NATIVE, NO BLOAT)
-- ═══════════════════════════════════════════════════════════

local sg = Instance.new("ScreenGui")
sg.Name = "FishHub"
sg.ResetOnSpawn = false
sg.Parent = plr.PlayerGui

-- Main frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 360, 0, 450)
main.Position = UDim2.new(0.5, -180, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Active = true
main.Parent = sg

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 8)

-- Make draggable
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

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 35)
top.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
top.BorderSizePixel = 0
top.Parent = main

Instance.new("UICorner", top).CornerRadius = UDim.new(0, 8)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐟 FISH HUB"
title.TextColor3 = Color3.fromRGB(100, 180, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

-- Close button
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -32, 0, 2)
close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextSize = 14
close.Font = Enum.Font.GothamBold
close.Parent = top

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 5)

close.MouseButton1Click:Connect(function()
    cfg.autofish = false
    sg:Destroy()
end)

-- Content area
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -10, 1, -42)
content.Position = UDim2.new(0, 5, 0, 38)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.Parent = content

-- Auto-resize canvas
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 5)
end)

-- UI builders
local function section(txt)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    f.Parent = content
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    
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

local function toggle(txt, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    f.Parent = content
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.65, 0, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(230, 230, 230)
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 45, 0, 24)
    b.Position = UDim2.new(1, -50, 0.5, -12)
    b.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    b.Text = "OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        b.BackgroundColor3 = on and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 90)
        b.Text = on and "ON" or "OFF"
        callback(on)
    end)
end

local function slider(txt, min, max, def, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    f.Parent = content
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    
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
    bar.Size = UDim2.new(1, -20, 0, 5)
    bar.Position = UDim2.new(0, 10, 0, 30)
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
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
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
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
end

local function button(txt, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    
    b.MouseButton1Click:Connect(callback)
end

-- ═══════════════════════════════════════════════════════════
-- BUILD UI
-- ═══════════════════════════════════════════════════════════

section("🎣 FISHING")

toggle("Auto Fish", function(v)
    cfg.autofish = v
    if v then
        notify("Auto Fish ON")
        task.spawn(autoFish)
    else
        notify("Auto Fish OFF")
    end
end)

toggle("Auto Sell", function(v)
    cfg.autosell = v
end)

button("Manual Sell Now", function()
    autoSell()
end)

section("⚡ PLAYER")

slider("Speed", 16, 150, 16, function(v)
    setSpeed(v)
end)

slider("Jump", 50, 300, 50, function(v)
    setJump(v)
end)

toggle("Noclip", function(v)
    cfg.noclip = v
end)

section("📜 INFO")

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 50)
info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
info.Text = "Fish Caught: 0\nStatus: Ready"
info.TextColor3 = Color3.fromRGB(200, 200, 200)
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.Parent = content
Instance.new("UICorner", info).CornerRadius = UDim.new(0, 5)

-- Update stats
task.spawn(function()
    while task.wait(1) do
        if info then
            info.Text = "Fish Caught: " .. stats.caught .. "\nStatus: " .. (cfg.autofish and "Fishing..." or "Idle")
        end
    end
end)

-- Done
notify("Loaded!")
print("Fish Hub loaded successfully!")