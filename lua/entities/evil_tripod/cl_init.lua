include("shared.lua")
function ENT:Draw()
    if EvilThingsRender and EvilThingsRender.DrawTripod then
        EvilThingsRender.DrawTripod(self)
    else
        self:DrawModel()
    end
end
function ENT:DrawTranslucent() self:Draw() end
