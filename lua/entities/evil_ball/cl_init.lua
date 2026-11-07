include("shared.lua")
function ENT:Draw() EvilThingsRender.DrawBall(self) end
function ENT:DrawTranslucent() self:Draw() end
