--[[
    ESP Module
    Visual ESP for fish, merchants, NPCs
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.FishESPEnabled = false
ESP.MerchantESPEnabled = false
ESP.NPCESPEnabled = false
ESP.ESPObjects = {}

-- Create ESP highlight
function ESP:CreateHighlight(object, color, text)
    if not object or not object:IsA("BasePart") and not object:IsA("Model") then
        return nil
    end
    
    -- Create highlight effect
    local highlight = Instance.new("Highlight")
    highlight.Parent = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    -- Create BillboardGui for text
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = object
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    
    -- Store for cleanup
    local espData = {
        Highlight = highlight,
        Billboard = billboard,
        Object = object
    }
    
    table.insert(self.ESPObjects, espData)
    
    return espData
end

-- Remove all ESP
function ESP:ClearESP()
    for _, espData in pairs(self.ESPObjects) do
        if espData.Highlight then
            espData.Highlight:Destroy()
        end
        if espData.Billboard then
            espData.Billboard:Destroy()
        end
    end
    
    self.ESPObjects = {}
end

-- Get rarity color
function ESP:GetRarityColor(rarity)
    rarity = rarity:lower()
    
    if rarity:match("mythic") then
        return Color3.fromRGB(255, 0, 255) -- Purple
    elseif rarity:match("legendary") then
        return Color3.fromRGB(255, 215, 0) -- Gold
    elseif rarity:match("epic") then
        return Color3.fromRGB(148, 0, 211) -- Dark purple
    elseif rarity:match("rare") then
        return Color3.fromRGB(0, 112, 255) -- Blue
    elseif rarity:match("uncommon") then
        return Color3.fromRGB(0, 255, 0) -- Green
    else
        return Color3.fromRGB(255, 255, 255) -- White (common)
    end
end

-- Fish ESP
function ESP:ToggleFishESP(enabled)
    self.FishESPEnabled = enabled
    
    if not enabled then
        self:ClearESP()
        print("[ESP] Fish ESP disabled")
        return
    end
    
    print("[ESP] Fish ESP enabled")
    
    -- Scan for fish
    spawn(function()
        while self.FishESPEnabled and task.wait(2) do
            if not getgenv().FishIt.FishESP then
                self.FishESPEnabled = false
                self:ClearESP()
                break
            end
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():match("fish") then
                    -- Check if already has ESP
                    local hasESP = false
                    for _, espData in pairs(self.ESPObjects) do
                        if espData.Object == obj then
                            hasESP = true
                            break
                        end
                    end
                    
                    if not hasESP then
                        local rarity = obj:GetAttribute("Rarity") or "Common"
                        local color = self:GetRarityColor(rarity)
                        self:CreateHighlight(obj, color, obj.Name .. " [" .. rarity .. "]")
                    end
                end
            end
        end
    end)
end

-- Merchant ESP
function ESP:ToggleMerchantESP(enabled)
    self.MerchantESPEnabled = enabled
    
    if not enabled then
        print("[ESP] Merchant ESP disabled")
        return
    end
    
    print("[ESP] Merchant ESP enabled")
    
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and (npc.Name:lower():match("merchant") or npc.Name:lower():match("shop")) then
            self:CreateHighlight(npc, Color3.fromRGB(255, 255, 0), npc.Name .. " [MERCHANT]")
        end
    end
    
    -- Watch for new merchants
    workspace.DescendantAdded:Connect(function(obj)
        if self.MerchantESPEnabled and obj:IsA("Model") and obj.Name:lower():match("merchant") then
            task.wait(0.5)
            self:CreateHighlight(obj, Color3.fromRGB(255, 255, 0), obj.Name .. " [MERCHANT]")
        end
    end)
end

-- NPC ESP
function ESP:ToggleNPCESP(enabled)
    self.NPCESPEnabled = enabled
    
    if not enabled then
        print("[ESP] NPC ESP disabled")
        return
    end
    
    print("[ESP] NPC ESP enabled")
    
    -- Find NPCs folder
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in pairs(npcs:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                self:CreateHighlight(npc, Color3.fromRGB(0, 255, 255), npc.Name .. " [NPC]")
            end
        end
    end
    
    -- Fallback: Scan all humanoids
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
            local player = Players:GetPlayerFromCharacter(npc)
            if not player then -- Not a player
                self:CreateHighlight(npc, Color3.fromRGB(0, 255, 255), npc.Name .. " [NPC]")
            end
        end
    end
end

-- Distance ESP (show distance to important objects)
function ESP:UpdateDistances()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local hrp = character.HumanoidRootPart
    
    for _, espData in pairs(self.ESPObjects) do
        if espData.Billboard and espData.Object then
            pcall(function()
                local dist = (espData.Object:GetPivot().Position - hrp.Position).Magnitude
                local textLabel = espData.Billboard:FindFirstChildOfClass("TextLabel")
                if textLabel then
                    local originalText = textLabel.Text:match("(.+) %[")
                    local rarity = textLabel.Text:match("%[(.+)%]")
                    textLabel.Text = originalText .. " [" .. rarity .. "] - " .. math.floor(dist) .. "m"
                end
            end)
        end
    end
end

-- Start distance updater
RunService.Heartbeat:Connect(function()
    if #ESP.ESPObjects > 0 then
        ESP:UpdateDistances()
    end
end)

-- Tracers (lines from player to objects)
function ESP:CreateTracer(object, color)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local hrp = character.HumanoidRootPart
    
    local beam = Instance.new("Beam")
    local attach0 = Instance.new("Attachment", hrp)
    local attach1 = Instance.new("Attachment", object)
    
    beam.Attachment0 = attach0
    beam.Attachment1 = attach1
    beam.Color = ColorSequence.new(color)
    beam.FaceCamera = true
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.Parent = hrp
    
    return beam
end

return ESP