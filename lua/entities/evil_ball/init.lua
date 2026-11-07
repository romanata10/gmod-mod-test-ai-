AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
    self:DrawShadow(false)
    self:SetRenderBounds(Vector(-80,-80,-80), Vector(80,80,80))
    self:PhysicsInitSphere(24, "metal_bouncy")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetMass(35)
        phys:SetMaterial("metal_bouncy")
        phys:SetDamping(0.05, 0.1)
        phys:Wake()
        phys:SetVelocity(VectorRand():GetNormalized()*450 + Vector(0,0,220))
    end
    self:SetHealth(250)
    self.NextHunt = 0
    self.LastHit = 0
end

function ENT:Think()
    if CurTime() >= self.NextHunt then
        self.NextHunt = CurTime() + 0.35
        local target, best = nil, 1600^2
        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() then
                local d = self:GetPos():DistToSqr(ply:GetPos())
                if d < best then target, best = ply, d end
            end
        end
        local phys = self:GetPhysicsObject()
        if IsValid(target) and IsValid(phys) then
            local vel = phys:GetVelocity()
            local desired = (target:WorldSpaceCenter() - self:GetPos()):GetNormalized()*580 + Vector(0,0,140)
            phys:SetVelocity(vel*0.62 + desired*0.38)
        end
    end
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:PhysicsCollide(data, phys)
    if IsValid(data.HitEntity) and data.HitEntity:IsPlayer() and data.HitEntity:Alive() and CurTime() >= self.LastHit + 0.75 then
        self.LastHit = CurTime()
        local ply = data.HitEntity
        local dmg = DamageInfo(); dmg:SetDamage(55); dmg:SetAttacker(self); dmg:SetInflictor(self); dmg:SetDamageType(DMG_CLUB)
        ply:TakeDamageInfo(dmg)
        ply:SetVelocity((ply:GetPos() - self:GetPos()):GetNormalized()*420 + Vector(0,0,180))
    end
    if IsValid(phys) then
        local vel = data.OurOldVelocity
        if vel:Length() > 120 then
            phys:SetVelocity(vel * 0.88 + data.HitNormal*100)
        end
    end
    local ed = EffectData(); ed:SetOrigin(data.HitPos); ed:SetScale(0.7); util.Effect("cball_bounce", ed, true, true)
end

function ENT:OnTakeDamage(info)
    self:SetHealth(self:Health() - info:GetDamage())
    if self:Health() <= 0 then
        local ed = EffectData(); ed:SetOrigin(self:GetPos()); util.Effect("cball_explode", ed, true, true)
        self:Remove()
    end
end
