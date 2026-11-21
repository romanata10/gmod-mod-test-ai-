if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("evil_things/cl_models.lua")
    EvilThings = EvilThings or {}
    function EvilThings.ThrowFree(victim, source, horizontal, vertical)
        if not IsValid(victim) then return end
        local away=IsValid(source) and (victim:GetPos()-source:GetPos()) or victim:GetForward()
        away.z=0
        if away:LengthSqr()<0.01 then away=VectorRand(); away.z=0 end
        away:Normalize()
        victim:SetVelocity(away*(horizontal or 420)+Vector(0,0,vertical or 260))
    end
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
