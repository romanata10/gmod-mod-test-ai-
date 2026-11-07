AddCSLuaFile("shared.lua"); AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:DoAttackPower(ply)
    if not IsValid(ply) then return end
    local push = (ply:GetPos() - self:GetPos()):GetNormalized() * 230 + Vector(0, 110, 0)
    ply:SetVelocity(push)
    ply:ScreenFade(SCREENFADE.IN, Color(180, 20, 35, 100), 0.18, 0.25)
end
function ENT:DoSpecialPower(target)
    if not IsValid(target) then return end
    -- Five-armed burst: a short, readable radial shove, without trapping the player.
    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 220)) do
        if ent:IsPlayer() and ent:Alive() then
            local away = (ent:GetPos() - self:GetPos()):GetNormalized()
            ent:SetVelocity(away * 380 + Vector(0,0,150))
        end
    end
    local ed = EffectData(); ed:SetOrigin(self:GetPos()); ed:SetScale(0.7); util.Effect("cball_explode", ed, true, true)
end
