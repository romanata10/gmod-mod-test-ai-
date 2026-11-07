if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("evil_things/cl_models.lua")
else
    include("evil_things/cl_models.lua")
end

-- Optional Evil API integration: API code is a separate Workshop dependency.
local function LoadEvilAPI()
    if Evil and Evil.Presence then return true end
    if file.Exists("evil_api/init.lua", "LUA") then
        include("evil_api/init.lua")
        return Evil and Evil.Presence ~= nil
    end
    return false
end

hook.Add("Initialize", "EvilThings_LoadAPI", LoadEvilAPI)
