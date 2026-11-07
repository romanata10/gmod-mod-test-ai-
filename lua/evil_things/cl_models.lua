-- Original procedural client-side creature designs: no external model assets required.
EvilThingsRender = EvilThingsRender or {}
local R = EvilThingsRender
local function setup(ent)
    ent:SetRenderBounds(Vector(-180,-180,-30), Vector(180,180,260))
end
local function sphere(pos, radius, color, material)
    render.SetColorMaterial()
    render.DrawSphere(pos, radius, 16, 12, color)
end
local function cylinder(pos, radius, height, color, material)
    -- Reliable procedural cylinder approximation built from beam plus spherical caps.
    render.SetMaterial(Material("cable/blue_elec"))
    render.DrawBeam(pos, pos + Vector(0,0,height), radius*2, 0, 1, color)
    sphere(pos, radius, color)
    sphere(pos + Vector(0,0,height), radius, color)
end

function R.DrawStarfish(ent)
    setup(ent)
    local t, origin = CurTime(), ent:GetPos() + Vector(0,0,15 + math.sin(CurTime()*3)*3)
    local ang = ent:GetAngles()
    render.SetMaterial(Material("cable/redlaser"))
    for i=0,4 do
        local phase = t*1.7 + i*math.pi*2/5
        local dir = ang:Forward()*math.cos(phase) + ang:Right()*math.sin(phase)
        local tip = origin + dir*(68 + math.sin(t*4+i)*5)
        render.DrawBeam(origin, tip, 21, 0, 1, Color(205,40,58))
        sphere(tip, 9, Color(255,90,84))
        sphere(origin + dir*28 + Vector(0,0,7), 13, Color(230,68,62))
    end
    sphere(origin + Vector(0,0,10), 24, Color(168,25,48))
    -- Two bright, unblinking eyes give it a distinct readable face.
    local front = ang:Forward()*18 + Vector(0,0,16)
    sphere(origin + front + ang:Right()*-8, 4, Color(255,235,190))
    sphere(origin + front + ang:Right()*8, 4, Color(255,235,190))
end

function R.DrawTower(ent)
    setup(ent)
    local p, t = ent:GetPos(), CurTime()
    local pulse = 1 + math.sin(t*2.3)*0.035
    local steel = Color(55,128,168)
    -- Ribbed, tapering water tank and a tall skeletal support frame.
    cylinder(p + Vector(0,0,16), 25, 28, Color(35,84,110))
    for i=0,3 do
        local a = i*math.pi/2
        local x,y = math.cos(a)*18, math.sin(a)*18
        render.SetMaterial(Material("cable/blue_elec"))
        render.DrawBeam(p + Vector(x,y,5), p + Vector(x*0.6,y*0.6,125), 4, 0, 1, steel)
    end
    cylinder(p + Vector(0,0,118), 42*pulse, 54, steel)
    cylinder(p + Vector(0,0,172), 35*pulse, 10, Color(34,75,98))
    cylinder(p + Vector(0,0,185), 5, 25, Color(210,55,50))
    sphere(p + Vector(0,0,116), 9 + math.sin(t*5)*2, Color(70,220,255))
    -- Nozzle and rotating spray ring.
    local ring = p + Vector(0,0,88)
    render.SetMaterial(Material("cable/blue_elec"))
    for i=0,7 do
        local a = t*0.7 + i*math.pi/4
        local q = ring + Vector(math.cos(a)*48, math.sin(a)*48, 0)
        render.DrawBeam(ring, q, 2, 0, 1, Color(95,210,245,180))
    end
end

function R.DrawSlime(ent)
    setup(ent)
    local p, t = ent:GetPos(), CurTime()
    local bounce = math.abs(math.sin(t*3.3))*8
    local green = Color(75,225,102,235)
    render.SetBlend(0.92)
    sphere(p + Vector(0,0,18+bounce), 30, green)
    sphere(p + Vector(13,0,13+bounce), 18, Color(65,195,91,230))
    sphere(p + Vector(-12,4,11+bounce), 15, Color(104,245,112,220))
    sphere(p + Vector(0,0,8), 25, Color(43,143,69,235))
    local wobble = math.sin(t*4)*2
    sphere(p + Vector(-9,24,23+bounce+wobble), 3.5, Color(20,38,28))
    sphere(p + Vector(9,24,23+bounce-wobble), 3.5, Color(20,38,28))
    -- Small orbiting acid droplets animate around the body.
    for i=0,2 do
        local a = t*1.4 + i*math.pi*2/3
        sphere(p + Vector(math.cos(a)*39, math.sin(a)*28, 20+math.sin(t*3+i)*9), 5, Color(150,255,114,220))
    end
    render.SetBlend(1)
end
