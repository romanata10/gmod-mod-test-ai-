include("shared.lua")
function ENT:Draw() EvilThingsRender.DrawSlime(self) end
function ENT:DrawTranslucent() self:Draw() end
