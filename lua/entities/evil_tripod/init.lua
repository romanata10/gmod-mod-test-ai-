AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:DoSpecialPower(target)
    if not IsValid(target) then return end
    local start = self:GetPos() + Vector(0,0,135)
    local finish = target:WorldSpaceCenter()
    local tr = util.TraceLine({start=start, endpos=finish, filter=self, mask=MASK_SHOT})
    local hitPos = tr.HitPos
    local ed = EffectData(); ed:SetStart(start); ed:SetOrigin(hitPos); ed:SetEntity(self); ed:SetScale(2)
    util.Effect("ToolTracer", ed, true, true)
    if tr.Entity == target then
        local dmg = DamageInfo(); dmg:SetDamage(34); dmg:SetAttacker(self); dmg:SetInflictor(self); dmg:SetDamageType(DMG_DISSOLVE)
        target:TakeDamageInfo(dmg)
    end
end

function ENT:DoAttackPower(ply)
    if not IsValid(ply) or self.Capturing then return end
    self.Capturing = true
    self:SetNW2Entity("EvilTripodCageTarget", ply)
    ply:SetNW2Bool("EvilTripodCaptured", true)
    if Evil and Evil.Claim then Evil.Claim(ply, self) end
    if Evil and Evil.Freeze then Evil.Freeze(ply) else ply:Freeze(true) end
    local cagePos = self:GetPos() + self:GetForward()*88 + Vector(0,0,8)
    ply:SetPos(cagePos)
    ply:SetEyeAngles((self:GetPos() - ply:GetPos()):Angle())

    local function release(victim, kill)
        if not IsValid(self) then return end
        if IsValid(victim) then
            victim:SetNW2Bool("EvilTripodCaptured", false)
            if Evil and Evil.Thaw then Evil.Thaw(victim) else victim:Freeze(false) end
            if Evil and Evil.Unclaim then Evil.Unclaim(victim, self) end
            if kill and victim:Alive() then
                local d = DamageInfo(); d:SetDamage(9999); d:SetAttacker(self); d:SetInflictor(self); d:SetDamageType(DMG_DISSOLVE)
                victim:TakeDamageInfo(d)
            end
        end
        self:SetNW2Entity("EvilTripodCageTarget", NULL)
        self.Capturing = false
    end

    local settled = false
    if Evil and Evil.Mash then
        Evil.Mash(ply, self, {
            key = IN_JUMP, gain = 0.14, decay = 0.12, time = 5, prompt = true,
            done = function(victim) if not settled then settled = true; release(victim, false) end end,
            fail = function(victim) if not settled then settled = true; release(victim, true) end end
        })
    end
    timer.Create("EvilTripodCage_" .. self:EntIndex(), 5.1, 1, function()
        if not settled then settled = true; release(ply, true) end
    end)
end

function ENT:OnRemove()
    timer.Remove("EvilTripodCage_" .. self:EntIndex())
    local victim = self:GetNW2Entity("EvilTripodCageTarget")
    if IsValid(victim) then
        victim:SetNW2Bool("EvilTripodCaptured", false)
        if Evil and Evil.Thaw then Evil.Thaw(victim) else victim:Freeze(false) end
        if Evil and Evil.Unclaim then Evil.Unclaim(victim, self) end
    end
    if Evil and Evil.Absent then Evil.Absent(self) end
end
