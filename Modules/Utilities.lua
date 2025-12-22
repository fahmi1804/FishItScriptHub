-- Modules/Utilities.lua
-- Utility functions for Fish It! Script

local Utilities = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Notification System
function Utilities:Notify(title, text, duration, icon)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = icon and icon .. " " .. title or title,
        Text = text,
        Duration = duration or 3,
        Icon = ""
    })
end

-- Tween Position (Smooth Teleport)
function Utilities:TweenPosition(object, targetCFrame, speed)
    speed = speed or 100
    
    local distance = (object.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = targetCFrame}
    )
    
    tween:Play()
    tween.Completed:Wait()
end

-- Get Character Parts
function Utilities:GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function Utilities:GetHumanoid()
    local character = self:GetCharacter()
    return character:FindFirstChildOfClass("Humanoid")
end

function Utilities:GetRootPart()
    local character = self:GetCharacter()
    return character:FindFirstChild("HumanoidRootPart")
end

-- Find Tool by Keyword
function Utilities:FindTool(keyword)
    keyword = keyword:lower()
    
    -- Check backpack
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find(keyword) then
            return tool
        end
    end
    
    -- Check character
    local character = self:GetCharacter()
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find(keyword) then
            return tool
        end
    end
    
    return nil
end

-- Equip Tool
function Utilities:EquipTool(tool)
    if tool and tool:IsA("Tool") then
        local humanoid = self:GetHumanoid()
        if humanoid then
            humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

-- Unequip Current Tool
function Utilities:UnequipTools()
    local humanoid = self:GetHumanoid()
    if humanoid then
        humanoid:UnequipTools()
    end
end

-- Check if Player is Alive
function Utilities:IsAlive()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    return humanoid and rootPart and humanoid.Health > 0
end

-- Find Nearest Object
function Utilities:FindNearest(className, maxDistance)
    maxDistance = maxDistance or math.huge
    local rootPart = self:GetRootPart()
    
    if not rootPart then return nil end
    
    local nearestObj = nil
    local nearestDist = maxDistance
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA(className) and obj.Name ~= "HumanoidRootPart" then
            local distance = (rootPart.Position - obj.Position).Magnitude
            if distance < nearestDist then
                nearestDist = distance
                nearestObj = obj
            end
        end
    end
    
    return nearestObj, nearestDist
end

-- Find Objects by Name Pattern
function Utilities:FindObjectsByPattern(pattern, parent)
    parent = parent or workspace
    local results = {}
    
    for _, obj in pairs(parent:GetDescendants()) do
        if obj.Name:lower():find(pattern:lower()) then
            table.insert(results, obj)
        end
    end
    
    return results
end

-- Wait for Child with Timeout
function Utilities:WaitForChildTimeout(parent, childName, timeout)
    timeout = timeout or 5
    local startTime = tick()
    
    while tick() - startTime < timeout do
        local child = parent:FindFirstChild(childName)
        if child then
            return child
        end
        wait(0.1)
    end
    
    return nil
end

-- Create ESP/Highlight
function Utilities:CreateHighlight(object, color, fillTransparency, outlineTransparency)
    if not object or not object:IsA("Instance") then return nil end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = object
    highlight.FillColor = color or Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = fillTransparency or 0.5
    highlight.OutlineTransparency = outlineTransparency or 0
    highlight.Parent = object
    
    return highlight
end

-- Remove all highlights
function Utilities:RemoveHighlights(parent)
    parent = parent or workspace
    
    for _, obj in pairs(parent:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "ESP_Highlight" then
            obj:Destroy()
        end
    end
end

-- Create Billboard GUI
function Utilities:CreateBillboard(object, text, color, size)
    if not object or not object:IsA("BasePart") then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = object
    billboard.Size = size or UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or object.Name
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.5
    label.Parent = billboard
    
    return billboard
end

-- Distance to Object
function Utilities:GetDistance(object)
    local rootPart = self:GetRootPart()
    if not rootPart or not object then return math.huge end
    
    local objPosition = object:IsA("Model") and object:GetPivot().Position or object.Position
    return (rootPart.Position - objPosition).Magnitude
end

-- Format Number (Add commas)
function Utilities:FormatNumber(number)
    local formatted = tostring(number)
    local k
    
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    
    return formatted
end

-- Format Time (Seconds to HH:MM:SS)
function Utilities:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Anti-AFK
function Utilities:AntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Random String Generator
function Utilities:RandomString(length)
    length = length or 10
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local str = ""
    
    for i = 1, length do
        local rand = math.random(1, #chars)
        str = str .. chars:sub(rand, rand)
    end
    
    return str
end

-- Table to String (for debugging)
function Utilities:TableToString(tbl, indent)
    indent = indent or 0
    local str = "{\n"
    
    for k, v in pairs(tbl) do
        str = str .. string.rep("  ", indent + 1)
        str = str .. "[" .. tostring(k) .. "] = "
        
        if type(v) == "table" then
            str = str .. self:TableToString(v, indent + 1)
        else
            str = str .. tostring(v)
        end
        
        str = str .. ",\n"
    end
    
    str = str .. string.rep("  ", indent) .. "}"
    return str
end

-- Safe pcall with error logging
function Utilities:SafeCall(func, ...)
    local success, result = pcall(func, ...)
    
    if not success then
        warn("Error in SafeCall:", result)
        self:Notify("Error", "Function failed - check console", 3)
    end
    
    return success, result
end

-- Copy to Clipboard (if supported)
function Utilities:CopyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        self:Notify("Clipboard", "Copied to clipboard!", 2)
        return true
    else
        self:Notify("Error", "Clipboard not supported", 3)
        return false
    end
end

-- Get Ping
function Utilities:GetPing()
    return math.floor(LocalPlayer:GetNetworkPing() * 1000)
end

-- Get FPS
function Utilities:GetFPS()
    local fps = 0
    local startTime = tick()
    
    RunService.RenderStepped:Wait()
    
    fps = 1 / (tick() - startTime)
    return math.floor(fps)
end

return Utilities