include("shared.lua")
function ENT:Draw() EvilThingsRender.DrawTripod(self) end
function ENT:DrawTranslucent() self:Draw() end
