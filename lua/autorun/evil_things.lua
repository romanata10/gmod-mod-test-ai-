if SERVER then AddCSLuaFile() end

-- Evil API is an optional Workshop dependency. We do not copy or bundle it.
local function LoadEvilAPI()
    if Evil and Evil.Presence then return true end
    if file.Exists("evil_api/init.lua", "LUA") then
        include("evil_api/init.lua")
        return Evil and Evil.Presence ~= nil
    end
    return false
end

hook.Add("Initialize", "EvilThings_LoadAPI", LoadEvilAPI)
