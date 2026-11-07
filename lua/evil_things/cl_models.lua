-- Client-side procedural models/effects for Evil Things. No external model download required.
EvilThingsRender = EvilThingsRender or {}
local R = EvilThingsRender
local whiteMaterial = Material("models/debug/debugwhite")
local redLaser = Material("cable/redlaser")
local blueBeam = Material("cable/blue_elec")
local yellowBeam = Material("cable/yellowlaser")

local function bounds(ent, radius, height)
    ent:SetRenderBounds(Vector(-radius,-radius,-radius), Vector(radius,radius,height or radius))
end
local function sphere(pos, radius, color, material)
    render.SetMaterial(material or whiteMaterial)
    render.DrawSphere(pos, radius, 20, 16, color)
end
local function beam(a, b, width, color, material)
    render.SetMaterial(material or whiteMaterial)
    render.DrawBeam(a, b, width, 0, 1, color)
end
local function tube(pos, radius, height, color)
    local up = pos + Vector(0,0,height)
    beam(pos, up, radius*2, color, whiteMaterial)
    sphere(pos, radius, color)
    sphere(up, radius, color)
end

function R.DrawStarfish(ent)
    bounds(ent, 100, 75)
    local p, a = ent:GetPos(), ent:GetAngles()
    local t = CurTime()
    local center = p + Vector(0,0,13 + math.sin(t*4)*3)
    for i=0,4 do
        local ang = math.rad(a.y) + i*math.pi*2/5 + math.sin(t*3+i)*0.1
        local dir = Vector(math.cos(ang), math.sin(ang), 0)
        local elbow = center + dir*31 + Vector(0,0,math.sin(t*5+i)*4)
        local tip = center + dir*(65 + math.sin(t*4+i)*5)
        beam(center, elbow, 26, Color(178,24,42), redLaser)
        beam(elbow, tip, 18, Color(220,42,55), redLaser)
        sphere(tip, 8, Color(245,74,71))
        sphere(elbow, 11, Color(212,38,54))
    end
    sphere(center, 24, Color(168,20,39))
    local front = a:Forward()*16 + Vector(0,0,16)
    sphere(center + front + a:Right()*-8, 4, Color(255,240,205))
    sphere(center + front + a:Right()*8, 4, Color(255,240,205))
end

function R.DrawTower(ent)
    bounds(ent, 110, 245)
    local p, t = ent:GetPos(), CurTime()
    local steel = Color(70,142,175)
    local tank = p + Vector(0,0,140)
    -- Three independently swaying legs and a broad tank silhouette.
    for i=0,2 do
        local a = t*0.1 + i*math.pi*2/3
        local foot = p + Vector(math.cos(a)*52, math.sin(a)*52, 3)
        local shoulder = p + Vector(math.cos(a)*19, math.sin(a)*19, 115)
        beam(foot, shoulder, 8, Color(49,91,111), blueBeam)
        sphere(foot, 8, Color(57,105,128))
    end
    tube(p+Vector(0,0,105), 16, 30, Color(53,111,138))
    sphere(tank, 41 + math.sin(t*2)*1.5, steel)
    tube(p+Vector(0,0,164), 37, 12, Color(38,86,107))
    tube(p+Vector(0,0,176), 5, 27, Color(185,52,47))
    sphere(p+Vector(0,0,133), 10+math.sin(t*5)*2, Color(75,230,255))
    local nozzle = tank + Vector(0,0,-18)
    for i=0,7 do
        local a = t*0.8 + i*math.pi/4
        beam(nozzle, nozzle+Vector(math.cos(a)*48,math.sin(a)*48,2), 2, Color(104,213,244,210), blueBeam)
    end
end

function R.DrawSlime(ent)
    bounds(ent, 85, 85)
    local p, t = ent:GetPos(), CurTime()
    local bounce = math.abs(math.sin(t*3.2))*8
    sphere(p+Vector(0,0,20+bounce), 29, Color(90,230,102,245))
    sphere(p+Vector(17,0,14+bounce), 17, Color(75,190,84,235))
    sphere(p+Vector(-15,4,13+bounce), 17, Color(126,245,115,230))
    sphere(p+Vector(0,0,8), 23, Color(43,139,60,245))
    sphere(p+Vector(-9,24,23+bounce), 3.5, Color(20,35,20))
    sphere(p+Vector(9,24,23+bounce), 3.5, Color(20,35,20))
    for i=0,2 do
        local a = t*1.4 + i*math.pi*2/3
        sphere(p+Vector(math.cos(a)*40,math.sin(a)*30,22+math.sin(t*3+i)*8), 5, Color(168,255,116))
    end
end

function R.DrawTripod(ent)
    bounds(ent, 115, 235)
    local p, t, ang = ent:GetPos(), CurTime(), ent:GetAngles()
    local hub = p+Vector(0,0,125+math.sin(t*2)*2)
    for i=0,2 do
        local a = t*0.12+i*math.pi*2/3
        local foot = p+Vector(math.cos(a)*80,math.sin(a)*80,5)
        local knee = p+Vector(math.cos(a)*36,math.sin(a)*36,58+math.sin(t*2+i)*3)
        beam(hub,knee,10,Color(113,139,148),blueBeam)
        beam(knee,foot,7,Color(53,67,77),blueBeam)
        sphere(knee,7,Color(185,201,200))
        sphere(foot,9,Color(45,57,66))
    end
    tube(hub-Vector(0,0,22),21,25,Color(49,63,73))
    sphere(hub+ang:Forward()*12+Vector(0,0,12),22,Color(119,145,152))
    local eye=hub+ang:Forward()*31+Vector(0,0,12)
    sphere(eye,8,Color(255,38,18))
    beam(eye,eye+ang:Forward()*430,3+math.abs(math.sin(t*8))*2,Color(255,38,18,210),redLaser)
    local captive=ent:GetNW2Entity("EvilTripodCageTarget")
    if IsValid(captive) then
        local cp=captive:GetPos()
        for i=0,7 do
            local a=t*0.35+i*math.pi/4
            local off=Vector(math.cos(a)*30,math.sin(a)*30,0)
            local nextA=t*0.35+(i+1)*math.pi/4
            local nextOff=Vector(math.cos(nextA)*30,math.sin(nextA)*30,0)
            beam(cp+off,cp+off+Vector(0,0,78),3,Color(60,190,255,230),blueBeam)
            beam(cp+off+Vector(0,0,78),cp+nextOff+Vector(0,0,78),2,Color(120,230,255,230),blueBeam)
            local root=hub+Vector(math.cos(a)*17,math.sin(a)*17,0)
            beam(root,cp+off+Vector(0,0,38),5,Color(83,155,192),blueBeam)
        end
    end
end

function R.DrawBall(ent)
    bounds(ent, 65, 65)
    local p, t, a=ent:GetPos(),CurTime(),ent:GetAngles()
    sphere(p,25,Color(188,32,43))
    beam(p-a:Forward()*24,p+a:Forward()*24,7,Color(255,206,45),yellowBeam)
    beam(p-a:Right()*23,p+a:Right()*23,5,Color(255,242,172),yellowBeam)
    sphere(p+a:Forward()*17+Vector(0,0,5),4,Color(22,20,21))
    sphere(p+a:Forward()*17-Vector(0,0,5),4,Color(22,20,21))
    sphere(p+a:Forward()*23,3+math.abs(math.sin(t*8))*2,Color(255,90,25))
end
