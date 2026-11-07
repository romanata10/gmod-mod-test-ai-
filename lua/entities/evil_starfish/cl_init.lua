include("shared.lua")
function ENT:Draw() EvilThingsRender.DrawStarfish(self) end
function ENT:DrawTranslucent() self:Draw() end
