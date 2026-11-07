include("shared.lua")
function ENT:Draw() EvilThingsRender.DrawTower(self) end
function ENT:DrawTranslucent() self:Draw() end
