AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function thaw(victim)
    if not IsValid(victim) then return end
    victim:SetNW2Bool("EvilCreatureCaptured",false)
    if Evil and Evil.Thaw then Evil.Thaw(victim) else victim:Freeze(false) end
end

function ENT:DoAttackPower(ply)
    if not IsValid(ply) or not ply:Alive() or self.Capturing then return end
    self.Capturing=true
    self.CaptureReleased=false
    self.CaptureVictim=ply
    self:SetNW2Entity("EvilTowerVictim",ply)
    ply:SetNW2Bool("EvilCreatureCaptured",true)
    if Evil and Evil.Claim and not Evil.Claim(ply,self) then
        self.Capturing=false; self.CaptureVictim=nil; self:SetNW2Entity("EvilTowerVictim",NULL); ply:SetNW2Bool("EvilCreatureCaptured",false); return
    end
    if Evil and Evil.Freeze then Evil.Freeze(ply) else ply:Freeze(true) end

    local function reel()
        if not IsValid(self) or not IsValid(ply) or not ply:Alive() or not self.Capturing then return end
        -- Pull the victim beneath the belly hatch, then slowly raise them into the tank.
        local rise=math.min((CurTime()-(self.CaptureStarted or CurTime()))*14,76)
        ply:SetPos(self:GetPos()+Vector(0,0,98+rise))
        ply:SetEyeAngles((self:GetPos()-ply:GetPos()):Angle())
    end
    self.CaptureStarted=CurTime()
    timer.Create("EvilTowerReel_"..self:EntIndex(),0.05,110,reel)

    local settled=false
    local release
    self.EscapeHookName="EvilTowerEscape_"..self:EntIndex()
    local presses=0
    hook.Add("KeyPress",self.EscapeHookName,function(who,key)
        if who~=ply or key~=IN_JUMP or settled then return end
        presses=presses+1
        if presses>=8 then settled=true; release(ply,false) end
    end)
    ply:ChatPrint("Щупальца тащат тебя в бак! Нажми ПРЫЖОК 8 раз, чтобы вырваться и отлететь.")

    release=function(victim,drown)
        if not IsValid(self) or self.CaptureReleased then return end
        self.CaptureReleased=true
        hook.Remove("KeyPress",self.EscapeHookName)
        timer.Remove("EvilTowerReel_"..self:EntIndex())
        timer.Remove("EvilTowerDrown_"..self:EntIndex())
        if IsValid(victim) then
            thaw(victim)
            if Evil and Evil.Unclaim then Evil.Unclaim(victim,self) end
            if drown and victim:Alive() then
                local dmg=DamageInfo(); dmg:SetDamage(9999); dmg:SetAttacker(self); dmg:SetInflictor(self); dmg:SetDamageType(DMG_DROWN)
                victim:TakeDamageInfo(dmg)
            end
        end
        if IsValid(victim) and Evil and Evil.StopMash then Evil.StopMash(victim) end
        if not drown and IsValid(victim) and EvilThings and EvilThings.ThrowFree then EvilThings.ThrowFree(victim,self,520,320) end
        self:SetNW2Entity("EvilTowerVictim",NULL)
        self.Capturing=false; self.CaptureVictim=nil
    end
    self.ReleaseVictim=release
    if Evil and Evil.Mash then
        Evil.Mash(ply,self,{key=IN_JUMP,gain=0.13,decay=0.11,time=5.5,
            done=function(v) if IsValid(self) and self.Capturing then release(v,false) end end,
            fail=function(v) if IsValid(self) and self.Capturing then release(v,true) end end})
    end
    timer.Create("EvilTowerDrown_"..self:EntIndex(),5.6,1,function()
        if IsValid(self) and self.Capturing then settled=true; release(ply,true) end
    end)
end

function ENT:DoSpecialPower(target)
    -- A weighty stomp cracks the ground and hurts players close to a planted foot.
    local radius=210
    for _,ply in ipairs(ents.FindInSphere(self:GetPos(),radius)) do
        if ply:IsPlayer() and ply:Alive() and ply~=self.CaptureVictim then
            local d=DamageInfo(); d:SetDamage(22); d:SetAttacker(self); d:SetInflictor(self); d:SetDamageType(DMG_CLUB)
            ply:TakeDamageInfo(d)
            local away=(ply:GetPos()-self:GetPos()):GetNormalized()
            ply:SetVelocity(away*240+Vector(0,0,100))
        end
    end
    local fx=EffectData(); fx:SetOrigin(self:GetPos()); fx:SetScale(1.4); util.Effect("cball_bounce",fx,true,true)
end

function ENT:OnRemove()
    if self.EscapeHookName then hook.Remove("KeyPress",self.EscapeHookName) end
    timer.Remove("EvilTowerReel_"..self:EntIndex())
    timer.Remove("EvilTowerDrown_"..self:EntIndex())
    if IsValid(self.CaptureVictim) then
        if Evil and Evil.StopMash then Evil.StopMash(self.CaptureVictim) end
        thaw(self.CaptureVictim)
        if Evil and Evil.Unclaim then Evil.Unclaim(self.CaptureVictim,self) end
    end
    if Evil and Evil.Absent then Evil.Absent(self) end
end
