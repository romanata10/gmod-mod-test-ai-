AddCSLuaFile("shared.lua"); AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:DoAttackPower(ply)
    if not IsValid(ply) then return end
    -- Slime's sticky hit slows movement for a moment; timer restores the original speed.
    local oldWalk, oldRun = ply:GetWalkSpeed(), ply:GetRunSpeed()
    ply:SetWalkSpeed(math.max(80, oldWalk * 0.55)); ply:SetRunSpeed(math.max(120, oldRun * 0.55))
    timer.Create("EvilSlimeSlow_" .. ply:EntIndex(), 3.5, 1, function()
        if IsValid(ply) then ply:SetWalkSpeed(oldWalk); ply:SetRunSpeed(oldRun) end
    end)
end
function ENT:DoSpecialPower(target)
    if IsValid(target) and self:GetPos():DistToSqr(target:GetPos()) < 500^2 then
        local ed = EffectData(); ed:SetOrigin(self:GetPos()); ed:SetScale(1.2); util.Effect("GlassImpact", ed, true, true)
        for _, ply in ipairs(ents.FindInSphere(self:GetPos(), 170)) do
            if ply:IsPlayer() and ply:Alive() then
                local dmg = DamageInfo(); dmg:SetDamage(8); dmg:SetAttacker(self); dmg:SetInflictor(self); dmg:SetDamageType(DMG_ACID)
                ply:TakeDamageInfo(dmg)
                ply:SetVelocity((ply:GetPos() - self:GetPos()):GetNormalized() * 180)
            end
        end
    end
end
