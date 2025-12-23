--[[
    Utilities.lua - Helper Functions
]]

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

-- Notification
function Utils.Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🐟 " .. title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- Get Character
function Utils.GetCharacter()
    return LocalPlayer.Character
end

-- Get Humanoid
function Utils.GetHumanoid()
    local char = Utils.GetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

-- Get Root
function Utils.GetRoot()
    local char = Utils.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Teleport
function Utils.Teleport(position)
    local root = Utils.GetRoot()
    if root then
        root.CFrame = CFrame.new(position)
        return true
    end
    return false
end

-- Find NPC by name
function Utils.FindNPC(name)
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name:lower():match(name:lower()) then
            if npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart then
                return npc
            end
        end
    end
    return nil
end

return Utils