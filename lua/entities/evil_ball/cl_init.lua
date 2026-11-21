include("shared.lua")
function ENT:Draw()
    if EvilThingsRender and EvilThingsRender.DrawBall then
        EvilThingsRender.DrawBall(self)
    else
        self:DrawModel()
    end
end
function ENT:DrawTranslucent() self:Draw() end
