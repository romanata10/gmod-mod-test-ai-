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

-- Flexible tentacle/leg drawn as a chain, with its joints seeking nearby world/prop surfaces.
-- Cached traces keep the animated rigs cheap enough to render on several NPCs at once.
local function drawAdaptiveLimb(ent, id, root, endPos, width, color, seed, spikes)
    local now = CurTime()
    ent.LimbSurfaceCache = ent.LimbSurfaceCache or {}
    local cache = ent.LimbSurfaceCache[id]
    if not cache or now >= cache.nextUpdate then
        cache = {points={}, nextUpdate=now+0.08}
        local delta=endPos-root
        local side=Vector(-delta.y,delta.x,0):GetNormalized()
        if side:LengthSqr()<0.01 then side=Vector(1,0,0) end
        for i=0,8 do
            local u=i/8
            local wave=math.sin(now*2.2+seed+u*6)*math.sin(u*math.pi)*10
            local ideal=root+delta*u+side*wave+Vector(0,0,math.sin(now*3+seed+u*4)*6*math.sin(u*math.pi))
            local best, bestDist
            local dirs={Vector(0,0,-1),Vector(0,0,1),side,-side,delta:GetNormalized(),-delta:GetNormalized()}
            for _,dir in ipairs(dirs) do
                local tr=util.TraceLine({start=ideal+dir*30,endpos=ideal-dir*30,filter=function(e) return e==ent or e:IsPlayer() end,mask=MASK_SOLID})
                if tr.Hit then
                    local d=tr.HitPos:DistToSqr(ideal)
                    if not bestDist or d<bestDist then best,bestDist=tr.HitPos+tr.HitNormal*2,d end
                end
            end
            cache.points[i+1]=best or ideal
        end
        ent.LimbSurfaceCache[id]=cache
    end
    render.SetMaterial(blueBeam)
    for i=1,8 do
        local taper=1-(i/9)*0.7
        render.DrawBeam(cache.points[i],cache.points[i+1],width*taper,0,1,color)
        if spikes and i>2 and i<8 and i%2==0 then
            local p=cache.points[i]
            local outward=(p-root):GetNormalized()
            render.DrawBeam(p,p+outward*7,width*0.22,0,1,Color(176,160,121))
        end
    end
    sphere(cache.points[9],width*0.55,color)
end

function R.DrawStarfish(ent)
    bounds(ent, 225, 80)
    local p,a=ent:GetPos(),ent:GetAngles()
    local t=CurTime()
    local center=p+Vector(0,0,12+math.sin(t*3.5)*2)
    -- Brittle-star body: tiny dark disc and five long, boned, independently probing arms.
    sphere(center,23,Color(25,30,34))
    for i=0,4 do
        local theta=math.rad(a.y)+i*math.pi*2/5+math.sin(t*1.8+i)*0.08
        local dir=Vector(math.cos(theta),math.sin(theta),0)
        local root=center+dir*12
        local endPos=center+dir*(177+math.sin(t*2.3+i)*12)+Vector(0,0,math.sin(t*2+i)*8)
        drawAdaptiveLimb(ent,"star_"..i,root,endPos,9,Color(29,39,43),i*1.7,true)
    end
    local front=a:Forward()*16+Vector(0,0,13)
    sphere(center+front+a:Right()*-7,3,Color(234,215,171))
    sphere(center+front+a:Right()*7,3,Color(234,215,171))
    local captive=ent:GetNW2Entity("EvilStarTarget")
    if IsValid(captive) then
        for i=0,2 do
            local theta=math.rad(a.y)+i*math.pi*2/3
            local start=center+Vector(math.cos(theta)*10,math.sin(theta)*10,3)
            drawAdaptiveLimb(ent,"star_grab_"..i,start,captive:GetPos()+Vector(0,0,32),7,Color(56,61,59),i+10,true)
        end
    end
end

function R.DrawTower(ent)
    bounds(ent,150,265)
    local p,t=ent:GetPos(),CurTime()
    local tank=p+Vector(0,0,160)
    -- Three articulated supports plant their feet against nearby ground/prop surfaces.
    for i=0,2 do
        local a=t*0.12+i*math.pi*2/3
        local foot=p+Vector(math.cos(a)*66,math.sin(a)*66,3)
        local hip=p+Vector(math.cos(a)*20,math.sin(a)*20,125)
        drawAdaptiveLimb(ent,"tower_leg_"..i,hip,foot,10,Color(75,110,123),i*2,false)
        sphere(hip,9,Color(49,91,111))
    end
    tube(p+Vector(0,0,115),16,35,Color(53,111,138))
    sphere(tank,43+math.sin(t*2)*1.5,Color(70,142,175))
    tube(p+Vector(0,0,186),39,12,Color(38,86,107))
    tube(p+Vector(0,0,198),5,28,Color(185,52,47))
    sphere(p+Vector(0,0,153),10+math.sin(t*5)*2,Color(75,230,255))
    local nozzle=tank+Vector(0,0,-18)
    for i=0,7 do local a=t*0.8+i*math.pi/4; beam(nozzle,nozzle+Vector(math.cos(a)*50,math.sin(a)*50,2),2,Color(104,213,244,210),blueBeam) end
    -- Hinged belly hatch and the tendrils that reel captured victims up inside.
    local victim=ent:GetNW2Entity("EvilTowerVictim")
    local hatch=p+Vector(0,0,108)
    if IsValid(victim) then
        -- Twin hinged doors fold open while tentacles reel the player into the tank.
        local flap=math.sin(t*4)*18
        beam(hatch+Vector(-28,0,0),hatch+Vector(-4,-flap,-5),9,Color(32,64,76))
        beam(hatch+Vector(28,0,0),hatch+Vector(4,flap,-5),9,Color(32,64,76))
        for i=0,3 do
            local a=t*0.5+i*math.pi/2
            drawAdaptiveLimb(ent,"tower_tentacle_"..i,hatch,victim:GetPos()+Vector(0,0,34),5,Color(45,64,65),i+12,true)
        end
    else
        beam(p+Vector(-24,0,111),p+Vector(24,0,111),5,Color(34,65,77))
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
    for i=0,3 do
        local a=t*0.7+i*math.pi/2
        local root=p+Vector(math.cos(a)*17,math.sin(a)*17,15+bounce)
        local tip=p+Vector(math.cos(a)*65,math.sin(a)*65,5+math.sin(t*2+i)*12)
        drawAdaptiveLimb(ent,"slime_feeler_"..i,root,tip,4,Color(72,191,83),i+5,false)
    end
    sphere(p+Vector(-9,24,23+bounce), 3.5, Color(20,35,20))
    sphere(p+Vector(9,24,23+bounce), 3.5, Color(20,35,20))
    for i=0,2 do
        local a = t*1.4 + i*math.pi*2/3
        sphere(p+Vector(math.cos(a)*40,math.sin(a)*30,22+math.sin(t*3+i)*8), 5, Color(168,255,116))
    end
end

function R.DrawTripod(ent)
    bounds(ent,450,260)
    local p,t,ang=ent:GetPos(),CurTime(),ent:GetAngles()
    local hub=p+Vector(0,0,145+math.sin(t*2)*2)
    for i=0,2 do
        local a=t*0.18+i*math.pi*2/3
        local foot=p+Vector(math.cos(a)*112,math.sin(a)*112,2)
        local hip=p+Vector(math.cos(a)*23,math.sin(a)*23,132)
        drawAdaptiveLimb(ent,"tripod_leg_"..i,hip,foot,9,Color(69,84,92),i*2.2,false)
        sphere(hip,8,Color(183,198,196))
        sphere(foot,10,Color(40,49,56))
    end
    -- Angular hood/head inspired by the reference silhouette; all geometry is original.
    sphere(hub,35,Color(28,34,38))
    beam(hub+Vector(-5,0,10),hub+ang:Forward()*46+Vector(0,0,78),26,Color(34,41,44),whiteMaterial)
    beam(hub+Vector(5,0,10),hub-ang:Forward()*10+Vector(0,0,82),23,Color(30,36,39),whiteMaterial)
    sphere(hub+ang:Forward()*36+Vector(0,0,19),11,Color(81,103,107))
    local eye=hub+ang:Forward()*46+Vector(0,0,16)
    sphere(eye,7,Color(255,37,23))
    beam(eye,eye+ang:Forward()*390,3+math.abs(math.sin(t*8))*2,Color(255,38,18,205),redLaser)
    local captive=ent:GetNW2Entity("EvilTripodCageTarget")
    if IsValid(captive) then
        local cp=captive:GetPos()
        for i=0,7 do
            local a=t*0.35+i*math.pi/4
            local off=Vector(math.cos(a)*29,math.sin(a)*29,0)
            local nextA=t*0.35+(i+1)*math.pi/4
            local nextOff=Vector(math.cos(nextA)*29,math.sin(nextA)*29,0)
            beam(cp+off,cp+off+Vector(0,0,78),3,Color(60,190,255,230),blueBeam)
            beam(cp+off+Vector(0,0,78),cp+nextOff+Vector(0,0,78),2,Color(120,230,255,230),blueBeam)
            local root=hub+Vector(math.cos(a)*24,math.sin(a)*24,-5)
            drawAdaptiveLimb(ent,"tripod_grab_"..i,root,cp+off+Vector(0,0,38),5,Color(70,104,111),i+15,true)
        end
    end
end

function R.DrawBall(ent)
    bounds(ent, 65, 65)
    local p,t,a=ent:GetPos(),CurTime(),ent:GetAngles()
    local squash=math.Clamp((ent:GetNW2Float("EvilBallSquashUntil",0)-t)/0.18,0,1)
    local center=p+Vector(0,0,-2*squash)
    sphere(center,25-1.5*squash,Color(188,32,43))
    beam(center-a:Forward()*24,center+a:Forward()*24,7+2*squash,Color(255,206,45),yellowBeam)
    beam(center-a:Right()*23,center+a:Right()*23,5+2*squash,Color(255,242,172),yellowBeam)
    sphere(center+a:Forward()*17+Vector(0,0,5),4,Color(22,20,21))
    sphere(center+a:Forward()*17-Vector(0,0,5),4,Color(22,20,21))
    sphere(center+a:Forward()*23,3+math.abs(math.sin(t*8))*2,Color(255,90,25))
    if squash>0 then beam(p+Vector(-18,0,-16),p+Vector(18,0,-16),20*squash,Color(145,30,35,155),redLaser) end
end
