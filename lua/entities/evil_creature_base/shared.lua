ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Evil Creature"
ENT.Category = "Evil Things"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "NextAttack")
end
