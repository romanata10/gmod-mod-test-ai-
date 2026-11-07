AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model or "models/props_junk/PopCan01a.mdl")
    self:SetModelScale(self.ModelScale or 1)
    self:SetColor(self.Tint or color_white)
    self:SetMaterial(self.Material or "models/debug/debugwhite")
    self:SetHealth(self.HealthAmount or 120)
    self:SetMaxHealth(self.HealthAmount or 120)
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)
    self:SetUseType(SIMPLE_USE)
    self:SetNextAttack(CurTime() + 1)
    self.Target = nil
    self.NextSearch = 0
    self.NextPower = CurTime() + (self.PowerCooldown or 10)
    self:SetCollisionBounds(self.HullMins or Vector(-20,-20,0), self.HullMaxs or Vector(20,20,50))
    if Evil and Evil.Presence then Evil.Presence(self, {reach = self.FearReach or 600, dread = self.Dread or 1}) end
end

function ENT:FindTarget()
    local best, bestDist
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:IsFlagSet(FL_NOTARGET) then
            local dist = self:GetPos():DistToSqr(ply:GetPos())
            if dist < (self.SightRange or 1100)^2 and (not bestDist or dist < bestDist) then best, bestDist = ply, dist end
        end
    end
    self.Target = best
end

function ENT:Attack(target)
    if not IsValid(target) or CurTime() < self:GetNextAttack() then return end
    if self:GetPos():DistToSqr(target:GetPos()) > (self.AttackRange or 90)^2 then return end
    self:SetNextAttack(CurTime() + (self.AttackCooldown or 1.5))
    local dmg = DamageInfo()
    dmg:SetDamage(self.AttackDamage or 18)
    dmg:SetAttacker(self)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_SLASH)
    target:TakeDamageInfo(dmg)
    self:DoAttackPower(target)
end

function ENT:DoAttackPower(_) end
function ENT:DoSpecialPower(_) end

function ENT:Think()
    if CurTime() >= self.NextSearch then self:FindTarget(); self.NextSearch = CurTime() + 0.7 end
    local target = self.Target
    if IsValid(target) and target:Alive() then
        local delta = target:GetPos() - self:GetPos()
        delta.z = 0
        if delta:LengthSqr() > (self.AttackRange or 90)^2 then
            local dir = delta:GetNormalized()
            self:SetAngles(Angle(0, dir:Angle().y, 0))
            self:SetPos(self:GetPos() + dir * (self.Speed or 170) * engine.TickInterval())
        else self:Attack(target) end
        if CurTime() >= self.NextPower then
            self.NextPower = CurTime() + (self.PowerCooldown or 10)
            self:DoSpecialPower(target)
        end
    end
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:OnTakeDamage(info)
    self:SetHealth(self:Health() - info:GetDamage())
    if self:Health() <= 0 then
        if Evil and Evil.Absent then Evil.Absent(self) end
        local effect = EffectData(); effect:SetOrigin(self:GetPos()); util.Effect("cball_explode", effect, true, true)
        self:Remove()
    end
end

function ENT:OnRemove()
    if Evil and Evil.Absent then Evil.Absent(self) end
end
