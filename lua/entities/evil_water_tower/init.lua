AddCSLuaFile("shared.lua"); AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:DoAttackPower(ply)
    if IsValid(ply) then ply:SetVelocity(Vector(0,0,270)) end
end
function ENT:DoSpecialPower(_)
    -- Pressure-wave splash: hurts nearby opponents and briefly knocks their aim off.
    for _, ply in ipairs(ents.FindInSphere(self:GetPos(), 340)) do
        if ply:IsPlayer() and ply:Alive() then
            local dmg = DamageInfo(); dmg:SetDamage(12); dmg:SetAttacker(self); dmg:SetInflictor(self); dmg:SetDamageType(DMG_DROWN)
            ply:TakeDamageInfo(dmg)
            local push = (ply:GetPos() - self:GetPos()):GetNormalized() * 300 + Vector(0,0,110)
            ply:SetVelocity(push)
        end
    end
    local ed = EffectData(); ed:SetOrigin(self:GetPos() + Vector(0,0,60)); ed:SetScale(2); util.Effect("watersplash", ed, true, true)
end
