AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model or "models/props_junk/PopCan01a.mdl")
    self:SetModelScale(self.ModelScale or 1)
    self:SetColor(self.Tint or color_white)
    self:SetMaterial(self.Material or "models/debug/debugwhite")
    self:DrawShadow(false)
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
    self.LastMoveTime = CurTime()
    local mins = self.HullMins or Vector(-20,-20,0)
    local maxs = self.HullMaxs or Vector(20,20,50)
    self:SetCollisionBounds(mins, maxs)
    -- Larger bounds keep the complete custom-rendered model inside the PVS/render frustum.
    self:SetRenderBounds(mins - Vector(100,100,100), maxs + Vector(100,100,100))
    if Evil and Evil.Presence then
        Evil.Presence(self, {reach = self.FearReach or 600, dread = self.Dread or 1})
    end
end

function ENT:FindTarget()
    local best, bestDist
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:IsFlagSet(FL_NOTARGET) then
            local dist = self:GetPos():DistToSqr(ply:GetPos())
            if dist < (self.SightRange or 1100)^2 and (not bestDist or dist < bestDist) then
                best, bestDist = ply, dist
            end
        end
    end
    self.Target = best
end

function ENT:Attack(target)
    if not IsValid(target) or not target:Alive() or CurTime() < self:GetNextAttack() then return end
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
    local now = CurTime()
    if now >= self.NextSearch then
        self:FindTarget()
        self.NextSearch = now + 0.5
    end
    local target = self.Target
    if IsValid(target) and target:Alive() then
        local delta = target:GetPos() - self:GetPos()
        delta.z = 0
        local range = self.AttackRange or 90
        if delta:LengthSqr() > range*range then
            local dir = delta:GetNormalized()
            self:SetAngles(Angle(0, dir:Angle().y, 0))
            -- Think runs at 10 Hz, so use elapsed Think time (not engine tick time).
            local dt = math.Clamp(now - (self.LastMoveTime or now), 0, 0.15)
            local destination = self:GetPos() + dir * (self.Speed or 170) * dt
            local mins, maxs = self:GetCollisionBounds()
            local tr = util.TraceHull({
                start = self:GetPos(), endpos = destination, mins = mins, maxs = maxs,
                filter = self, mask = MASK_NPCSOLID
            })
            if not tr.Hit then self:SetPos(tr.HitPos) end
        else
            self:Attack(target)
        end
        if now >= self.NextPower then
            self.NextPower = now + (self.PowerCooldown or 10)
            self:DoSpecialPower(target)
        end
    else
        self.Target = nil
    end
    self.LastMoveTime = now
    self:NextThink(now + 0.1)
    return true
end

function ENT:OnTakeDamage(info)
    self:SetHealth(self:Health() - info:GetDamage())
    if self:Health() <= 0 then
        if Evil and Evil.Absent then Evil.Absent(self) end
        local effect = EffectData()
        effect:SetOrigin(self:GetPos())
        util.Effect("cball_explode", effect, true, true)
        self:Remove()
    end
end

function ENT:OnRemove()
    if Evil and Evil.Absent then Evil.Absent(self) end
end
