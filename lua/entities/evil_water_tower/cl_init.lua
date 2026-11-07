include("shared.lua")
function ENT:Draw()
    if EvilThingsRender and EvilThingsRender.DrawTower then
        EvilThingsRender.DrawTower(self)
    else
        self:DrawModel()
    end
end
function ENT:DrawTranslucent() self:Draw() end
