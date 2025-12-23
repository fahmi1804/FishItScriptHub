--[[
    AutoFish.lua - Auto Fishing Logic
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AutoFish = {}
local Config, Utils
local Active = false

function AutoFish.Init(config, utils)
    Config = config
    Utils = utils
end

function AutoFish.GetRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Check equipped
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():match("rod") or tool.Name:lower():match("fish")) then
            return tool
        end
    end
    
    -- Check backpack
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():match("rod") or tool.Name:lower():match("fish")) then
            return tool
        end
    end
    
    return nil
end

function AutoFish.EquipRod()
    local rod = AutoFish.GetRod()
    if not rod then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    if rod.Parent ~= char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum:EquipTool(rod)
            task.wait(0.3)
            return true
        end
    end
    return true
end

function AutoFish.Cast()
    local rod = AutoFish.GetRod()
    if not rod then return false end
    
    pcall(function()
        rod:Activate()
    end)
    
    return true
end

function AutoFish.CheckBite()
    local gui = LocalPlayer.PlayerGui
    
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            local text = v.Text:lower()
            if text:match("!") or text:match("catch") or text:match("reel") or text:match("click") then
                return true
            end
        end
    end
    
    return false
end

function AutoFish.Start()
    if Active then return end
    Active = true
    
    Utils.Notify("Auto Fish", "Started!")
    
    spawn(function()
        while Active and task.wait(0.5) do
            if not Config.AutoFish then
                Active = false
                break
            end
            
            -- Equip rod
            if AutoFish.EquipRod() then
                -- Cast
                AutoFish.Cast()
                task.wait(1)
                
                -- Wait for bite
                for i = 1, 20 do
                    if AutoFish.CheckBite() then
                        if Config.InstantCatch then
                            AutoFish.Cast()
                        else
                            task.wait(0.3)
                            AutoFish.Cast()
                        end
                        
                        Config.Stats.FishCaught = Config.Stats.FishCaught + 1
                        task.wait(2)
                        break
                    end
                    task.wait(0.3)
                end
            else
                Utils.Notify("Auto Fish", "No rod found!")
                task.wait(5)
            end
        end
        
        Utils.Notify("Auto Fish", "Stopped!")
    end)
end

function AutoFish.Stop()
    Active = false
end

return AutoFish