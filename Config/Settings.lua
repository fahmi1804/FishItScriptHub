-- Config/Settings.lua
-- Fish It! Configuration File

return {
    -- Script Info
    ScriptName = "Fish It! Script Hub",
    Version = "1.0",
    Author = "Your Name",
    
    -- Default Settings
    DefaultConfig = {
        AutoFish = false,
        AutoSell = false,
        AutoReel = false,
        ESP = false,
        Noclip = false,
        WalkSpeed = 16,
        JumpPower = 50,
        FishDelay = 0.5,
        ShowNotifications = true,
        AutoEquipRod = true
    },
    
    -- UI Settings
    UI = {
        Theme = "Dark",
        AccentColor = Color3.fromRGB(50, 150, 255),
        BackgroundColor = Color3.fromRGB(25, 25, 30),
        Position = UDim2.new(0.5, -225, 0.5, -300),
        Size = UDim2.new(0, 450, 0, 600),
        Draggable = true,
        MinimizeButton = true
    },
    
    -- Fishing Spots (CFrame positions)
    FishingSpots = {
        Starter = {
            Name = "Starter Area",
            Position = CFrame.new(0, 5, 0),
            Description = "Best for beginners"
        },
        Dock = {
            Name = "Dock",
            Position = CFrame.new(100, 5, 100),
            Description = "Common fish spawns"
        },
        Beach = {
            Name = "Beach",
            Position = CFrame.new(-150, 5, 200),
            Description = "Rare fish location"
        },
        DeepSea = {
            Name = "Deep Sea",
            Position = CFrame.new(500, 5, 500),
            Description = "Legendary fish area"
        }
    },
    
    -- Fish Rarity Colors
    RarityColors = {
        Common = Color3.fromRGB(150, 150, 150),
        Uncommon = Color3.fromRGB(50, 255, 50),
        Rare = Color3.fromRGB(50, 150, 255),
        Epic = Color3.fromRGB(150, 50, 255),
        Legendary = Color3.fromRGB(255, 215, 0),
        Mythic = Color3.fromRGB(255, 50, 150)
    },
    
    -- Auto Farm Settings
    AutoFarm = {
        CastDelay = 0.5,
        ReelSpeed = 0.05,
        MaxReelTime = 10,
        SellInterval = 20, -- Sell after catching X fish
        ReturnToSpot = true
    },
    
    -- Anti-AFK
    AntiAFK = {
        Enabled = true,
        RandomMovement = true,
        JumpInterval = 60 -- Jump every 60 seconds
    },
    
    -- Security
    Security = {
        AntiKick = true,
        AntiTeleportDetection = true,
        StealthMode = false
    }
}