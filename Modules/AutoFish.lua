--[[
    AutoFish Module
    Handles auto fishing, perfect catch, instant catch
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AutoFish = {}
AutoFish.Active = false
AutoFish.PerfectCatch = false

-- Find player's fishing rod
function AutoFish:GetEquippedRod()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():match("rod") or tool.Name:lower():match("fishing")) then
            return tool
        end
    end
    
    -- Check backpack
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():match("rod") or tool.Name:lower():match("fishing")) then
            return tool
        end
    end
    
    return nil
end

-- Cast fishing rod
function AutoFish:CastRod()
    local rod = self:GetEquippedRod()
    if not rod then 
        warn("[AutoFish] No fishing rod found!")
        return false
    end
    
    -- Equip if not equipped
    if rod.Parent ~= LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:EquipTool(rod)
        task.wait(0.5)
    end
    
    -- Try to find cast remote
    pcall(function()
        if getgenv().FishIt.Remotes.CastRod then
            getgenv().FishIt.Remotes.CastRod:FireServer()
        else
            -- Fallback: Activate tool
            rod:Activate()
        end
    end)
    
    print("[AutoFish] Rod cast!")
    return true
end

-- Reel in fish
function AutoFish:ReelIn()
    pcall(function()
        if getgenv().FishIt.Remotes.ReelIn then
            getgenv().FishIt.Remotes.ReelIn:FireServer()
        end
    end)
    print("[AutoFish] Reeled in!")
end

-- Detect fish bite (look for UI changes or fish model)
function AutoFish:DetectBite()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Method 1: Check for bite UI
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local text = gui.Text:lower()
            if text:match("bite") or text:match("catch") or text:match("reel") then
                return true
            end
        end
    end
    
    -- Method 2: Check for fish model near player
    local character = LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():match("fish") then
                    local dist = (obj:GetPivot().Position - hrp.Position).Magnitude
                    if dist < 30 then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Perfect catch timing
function AutoFish:PerfectCatchTiming()
    if not self.PerfectCatch then return end
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Look for timing bar
    pcall(function()
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") and gui.Name:lower():match("bar") then
                -- Check for green zone indicator
                for _, child in pairs(gui:GetChildren()) do
                    if child:IsA("Frame") and child.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
                        -- Click when indicator is in green zone
                        local indicator = gui:FindFirstChild("Indicator")
                        if indicator then
                            local greenPos = child.Position.X.Scale
                            local indicatorPos = indicator.Position.X.Scale
                            
                            if math.abs(greenPos - indicatorPos) < 0.05 then
                                self:ReelIn()
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Auto equip best rod
function AutoFish:AutoEquipRod(enabled)
    if not enabled then return end
    
    local bestRod = nil
    local highestPower = 0
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():match("rod") then
            -- Check for power attribute or tier
            local power = tool:GetAttribute("Power") or 0
            
            -- Detect by name (Legendary Rod > Epic Rod > Rare Rod)
            if tool.Name:lower():match("legendary") then
                power = 100
            elseif tool.Name:lower():match("mythic") then
                power = 150
            elseif tool.Name:lower():match("epic") then
                power = 75
            elseif tool.Name:lower():match("rare") then
                power = 50
            end
            
            if power > highestPower then
                highestPower = power
                bestRod = tool
            end
        end
    end
    
    if bestRod then
        LocalPlayer.Character.Humanoid:EquipTool(bestRod)
        print("[AutoFish] Equipped: " .. bestRod.Name)
    end
end

-- Main auto fish loop
function AutoFish:Toggle(enabled)
    self.Active = enabled
    
    if not enabled then
        print("[AutoFish] Stopped")
        return
    end
    
    print("[AutoFish] Started")
    
    spawn(function()
        while self.Active and task.wait(1) do
            if not getgenv().FishIt.AutoFish then
                self.Active = false
                break
            end
            
            -- Cast rod if not fishing
            local isFishing = false
            pcall(function()
                -- Check if player is actively fishing
                local character = LocalPlayer.Character
                if character then
                    local rod = character:FindFirstChildOfClass("Tool")
                    if rod and rod.Name:lower():match("rod") then
                        -- Check for fishing animation or cast state
                        isFishing = rod:GetAttribute("Casted") or false
                    end
                end
            end)
            
            if not isFishing then
                self:CastRod()
                task.wait(2)
            end
            
            -- Detect bite and reel
            if self:DetectBite() then
                if getgenv().FishIt.InstantCatch then
                    self:ReelIn()
                else
                    task.wait(0.5) -- Natural delay
                    self:ReelIn()
                end
            end
            
            -- Perfect catch timing
            if self.PerfectCatch then
                self:PerfectCatchTiming()
            end
        end
    end)
end

function AutoFish:SetPerfectCatch(enabled)
    self.PerfectCatch = enabled
    print("[AutoFish] Perfect Catch: " .. tostring(enabled))
end

return AutoFish