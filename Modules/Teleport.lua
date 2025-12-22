--[[
    Teleport Module
    Handles all teleportation (fishing spots, zones, NPCs, players)
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Teleport = {}

-- Safe teleport with tween
function Teleport:SafeTP(position)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Instant TP (faster for executors)
    hrp.CFrame = CFrame.new(position)
    
    return true
end

-- Teleport to spawn
function Teleport:ToSpawn()
    -- Find spawn location
    local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Spawn")
    
    if spawn then
        self:SafeTP(spawn.Position + Vector3.new(0, 5, 0))
        print("[TP] Teleported to spawn")
        return true
    end
    
    -- Fallback: Use default spawn
    self:SafeTP(Vector3.new(0, 50, 0))
    return true
end

-- Predefined fishing spots (adjust based on game)
Teleport.FishingSpots = {
    {Name = "Starter Beach", Position = Vector3.new(100, 5, 50)},
    {Name = "Coral Reef", Position = Vector3.new(-200, 5, 300)},
    {Name = "Deep Ocean", Position = Vector3.new(500, 5, -400)},
    {Name = "Frozen Lake", Position = Vector3.new(-600, 5, -200)},
    {Name = "Secret Cave", Position = Vector3.new(800, 5, 700)}
}

-- Teleport to fishing spot by index
function Teleport:ToFishingSpot(index)
    local spot = self.FishingSpots[index]
    
    if spot then
        self:SafeTP(spot.Position)
        print("[TP] Teleported to " .. spot.Name)
        return true
    end
    
    -- Try to find fishing spots in workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            if obj.Name:lower():match("fishing") or obj.Name:lower():match("spot") then
                self:SafeTP(obj:GetPivot().Position + Vector3.new(0, 3, 0))
                print("[TP] Teleported to fishing spot")
                return true
            end
        end
    end
    
    warn("[TP] Fishing spot not found")
    return false
end

-- Teleport to deep ocean
function Teleport:ToDeepOcean()
    -- Find deepest water
    local deepest = nil
    local lowestY = 999999
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():match("water") or obj.Material == Enum.Material.Water then
            if obj.Position.Y < lowestY then
                lowestY = obj.Position.Y
                deepest = obj
            end
        end
    end
    
    if deepest then
        self:SafeTP(deepest.Position + Vector3.new(0, 10, 0))
        print("[TP] Teleported to deep ocean")
        return true
    end
    
    -- Fallback
    self:SafeTP(Vector3.new(500, 5, -400))
    return true
end

-- Find and teleport to NPC
function Teleport:ToNPC(npcName)
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name:lower():match(npcName:lower()) then
            if npc:FindFirstChild("HumanoidRootPart") then
                self:SafeTP(npc.HumanoidRootPart.Position + Vector3.new(0, 3, 5))
                print("[TP] Teleported to " .. npc.Name)
                return true
            end
        end
    end
    
    warn("[TP] NPC not found: " .. npcName)
    return false
end

-- Teleport to player
function Teleport:ToPlayer(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():match(playerName:lower()) then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                self:SafeTP(character.HumanoidRootPart.Position + Vector3.new(0, 3, 5))
                print("[TP] Teleported to " .. player.Name)
                return true
            end
        end
    end
    
    warn("[TP] Player not found: " .. playerName)
    return false
end

-- Get all zones/islands in game
function Teleport:GetZones()
    local zones = {}
    
    -- Look for zone folders
    local zonesFolder = workspace:FindFirstChild("Zones") or workspace:FindFirstChild("Islands") or workspace:FindFirstChild("Areas")
    
    if zonesFolder then
        for _, zone in pairs(zonesFolder:GetChildren()) do
            if zone:IsA("Model") or zone:IsA("Folder") then
                table.insert(zones, {
                    Name = zone.Name,
                    Position = zone:GetPivot().Position
                })
            end
        end
    end
    
    return zones
end

-- Teleport to zone by name
function Teleport:ToZone(zoneName)
    local zones = self:GetZones()
    
    for _, zone in pairs(zones) do
        if zone.Name:lower():match(zoneName:lower()) then
            self:SafeTP(zone.Position + Vector3.new(0, 10, 0))
            print("[TP] Teleported to " .. zone.Name)
            return true
        end
    end
    
    warn("[TP] Zone not found: " .. zoneName)
    return false
end

-- Teleport to boat (if exists)
function Teleport:ToBoat()
    local character = LocalPlayer.Character
    if not character then return false end
    
    -- Find player's boat
    for _, boat in pairs(workspace:GetDescendants()) do
        if boat:IsA("Model") and boat.Name:lower():match("boat") then
            -- Check if it's player's boat
            if boat:GetAttribute("Owner") == LocalPlayer.Name then
                self:SafeTP(boat:GetPivot().Position + Vector3.new(0, 5, 0))
                print("[TP] Teleported to your boat")
                return true
            end
        end
    end
    
    warn("[TP] Boat not found")
    return false
end

-- Waypoint system (click to TP)
function Teleport:EnableWaypoint()
    local player = LocalPlayer
    local mouse = player:GetMouse()
    
    mouse.Button1Down:Connect(function()
        if getgenv().FishIt.WaypointMode then
            local target = mouse.Target
            if target then
                self:SafeTP(mouse.Hit.Position + Vector3.new(0, 5, 0))
                print("[TP] Teleported to waypoint")
            end
        end
    end)
    
    print("[TP] Waypoint mode ready (toggle in settings)")
end

return Teleport