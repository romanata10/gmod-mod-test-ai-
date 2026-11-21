include("shared.lua")
function ENT:Draw()
    if EvilThingsRender and EvilThingsRender.DrawSlime then
        EvilThingsRender.DrawSlime(self)
    else
        self:DrawModel()
    end
end
function ENT:DrawTranslucent() self:Draw() end
