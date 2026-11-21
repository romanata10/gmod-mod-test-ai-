AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function freeVictim(victim)
    if not IsValid(victim) then return end
    victim:SetNW2Bool("EvilCreatureCaptured", false)
    if Evil and Evil.Thaw then Evil.Thaw(victim) else victim:Freeze(false) end
end

function ENT:DoAttackPower(ply)
    if not IsValid(ply) or not ply:Alive() or self.Capturing then return end
    self.Capturing = true
    self.CaptureVictim = ply
    self:SetNW2Entity("EvilStarTarget", ply)
    ply:SetNW2Bool("EvilCreatureCaptured", true)
    if Evil and Evil.Claim then
        if not Evil.Claim(ply,self) then
            self.Capturing=false; self.CaptureVictim=nil; self:SetNW2Entity("EvilStarTarget",NULL)
            ply:SetNW2Bool("EvilCreatureCaptured",false)
            return
        end
    end
    if Evil and Evil.Freeze then Evil.Freeze(ply) else ply:Freeze(true) end

    local function drag()
        if not IsValid(self) or not IsValid(ply) or not ply:Alive() or not self.Capturing then return end
        local sink = self:GetPos() + Vector(0,0,7) - self:GetForward()*5
        ply:SetPos(sink)
        ply:SetEyeAngles((self:GetPos() - ply:GetPos()):Angle())
    end
    timer.Create("EvilStarDrag_"..self:EntIndex(), 0.05, 80, drag)

    local settled=false
    local release
    self.EscapeHookName="EvilStarEscape_"..self:EntIndex()
    local presses=0
    hook.Add("KeyPress",self.EscapeHookName,function(who,key)
        if who~=ply or key~=IN_JUMP or settled then return end
        presses=presses+1
        if presses>=8 then release(false) end
    end)
    ply:ChatPrint("Щупальца схватили тебя! Нажми ПРЫЖОК 8 раз, чтобы вырваться и отлететь.")

    release=function(eaten)
        if settled or not IsValid(self) then return end
        settled=true
        hook.Remove("KeyPress",self.EscapeHookName)
        timer.Remove("EvilStarDrag_"..self:EntIndex())
        timer.Remove("EvilStarEat_"..self:EntIndex())
        if IsValid(ply) then
            freeVictim(ply)
            if Evil and Evil.Unclaim then Evil.Unclaim(ply, self) end
            if eaten and ply:Alive() then
                local dmg = DamageInfo(); dmg:SetDamage(9999); dmg:SetAttacker(self); dmg:SetInflictor(self); dmg:SetDamageType(DMG_SLASH)
                ply:TakeDamageInfo(dmg)
            end
        end
        if IsValid(ply) and Evil and Evil.StopMash then Evil.StopMash(ply) end
        self.Capturing = false
        self.CaptureVictim = nil
        self:SetNW2Entity("EvilStarTarget", NULL)
        if eaten then
            self:RunAwayAfterMeal(IsValid(ply) and ply:GetPos() or self:GetPos())
        elseif IsValid(ply) then
            if EvilThings and EvilThings.ThrowFree then EvilThings.ThrowFree(ply,self,500,300) end
            local away=(self:GetPos()-ply:GetPos()):GetNormalized()
            self.Target=nil; self.NextSearch=CurTime()+5; self.FleeGoal=self:GetPos()+away*280
        end
    end
    self.ReleaseCapture = release

    if Evil and Evil.Mash then
        Evil.Mash(ply, self, {
            key = IN_JUMP, gain = 0.12, decay = 0.1, time = 4,
            done = function() if IsValid(self) and self.Capturing then release(false) end end,
            fail = function() if IsValid(self) and self.Capturing then release(true) end end
        })
    end
    timer.Create("EvilStarEat_"..self:EntIndex(),4.2,1,function()
        if IsValid(self) and self.Capturing then release(true) end
    end)
end

function ENT:RunAwayAfterMeal(fromPos)
    local waterGoal
    for radius=160,960,160 do
        for i=0,15 do
            local a=i*math.pi*2/16
            for z=-32,64,32 do
                local probe=self:GetPos()+Vector(math.cos(a)*radius,math.sin(a)*radius,z)
                if bit.band(util.PointContents(probe),CONTENTS_WATER)~=0 then waterGoal=probe; break end
            end
            if waterGoal then break end
        end
        if waterGoal then break end
    end
    self.Target=nil
    self.NextSearch=CurTime()+25
    if waterGoal then
        self.FleeGoal=waterGoal
    else
        local away=(self:GetPos()-fromPos):GetNormalized()
        if away:LengthSqr()<0.01 then away=VectorRand():GetNormalized() end
        self.FleeGoal=self:GetPos()+away*700+Vector(0,0,0)
    end
end

function ENT:DoSpecialPower(_)
    -- Irregular spines and a quick arm-flail burst around the brittle-star body.
    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 145)) do
        if ent:IsPlayer() and ent:Alive() and ent ~= self.CaptureVictim then
            local away=(ent:GetPos()-self:GetPos()):GetNormalized()
            ent:SetVelocity(away*210+Vector(0,0,70))
        end
    end
    local fx=EffectData(); fx:SetOrigin(self:GetPos()); fx:SetScale(0.55); util.Effect("cball_explode",fx,true,true)
end

function ENT:OnRemove()
    timer.Remove("EvilStarDrag_"..self:EntIndex())
    timer.Remove("EvilStarEat_"..self:EntIndex())
    if self.EscapeHookName then hook.Remove("KeyPress",self.EscapeHookName) end
    if IsValid(self.CaptureVictim) then
        if Evil and Evil.StopMash then Evil.StopMash(self.CaptureVictim) end
        freeVictim(self.CaptureVictim)
        if Evil and Evil.Unclaim then Evil.Unclaim(self.CaptureVictim,self) end
    end
    if Evil and Evil.Absent then Evil.Absent(self) end
end
