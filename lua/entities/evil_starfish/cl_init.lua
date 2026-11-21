include("shared.lua")
function ENT:Draw()
    if EvilThingsRender and EvilThingsRender.DrawStarfish then
        EvilThingsRender.DrawStarfish(self)
    else
        self:DrawModel()
    end
end
function ENT:DrawTranslucent() self:Draw() end
