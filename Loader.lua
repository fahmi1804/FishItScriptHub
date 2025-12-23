--[[
    Fish It Script Hub - Loader.lua
    Simple loadstring loader
]]

local ScriptURL = "https://raw.githubusercontent.com/fahmi1804/FishItScriptHub/refs/heads/main/Main.lua"

print("Loading Fish Hub...")

local success, result = pcall(function()
    return game:HttpGet(ScriptURL, true)
end)

if success and result then
    local executeSuccess, executeError = pcall(function()
        loadstring(result)()
    end)
    
    if executeSuccess then
        print("✓ Fish Hub loaded successfully!")
    else
        warn("✗ Execution error:", executeError)
    end
else
    warn("✗ Failed to fetch script:", result)
end