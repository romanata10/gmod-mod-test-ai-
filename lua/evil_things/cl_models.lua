
function R.DrawTripod(ent)
    setup(ent)
    local p, t, ang = ent:GetPos(), CurTime(), ent:GetAngles()
    local silver, dark = Color(108,132,145), Color(45,56,68)
    local hub = p + Vector(0,0,92 + math.sin(t*2)*2)
    render.SetMaterial(Material("cable/blue_elec"))
    for i=0,2 do
        local a = t*0.12 + i*math.pi*2/3
        local foot = p + Vector(math.cos(a)*78, math.sin(a)*78, 4)
        local knee = p + Vector(math.cos(a)*36, math.sin(a)*36, 43 + math.sin(t*2+i)*3)
        render.DrawBeam(hub, knee, 9, 0, 1, silver)
        render.DrawBeam(knee, foot, 6, 0, 1, dark)
        sphere(knee, 7, Color(190,200,195))
        sphere(foot, 9, dark)
    end
    cylinder(hub + Vector(0,0,-10), 22, 24, dark)
    sphere(hub + ang:Forward()*12 + Vector(0,0,15), 21, silver)
    local eye = hub + ang:Forward()*30 + Vector(0,0,15)
    sphere(eye, 8, Color(255,35,20))
    render.SetMaterial(Material("cable/redlaser"))
    render.DrawBeam(eye, eye + ang:Forward()*510, 4 + math.abs(math.sin(t*8))*2, 0, 1, Color(255,30,20,210))

    local captive = ent:GetNW2Entity("EvilTripodCageTarget")
    if IsValid(captive) then
        local cp = captive:GetPos()
        local bottom, top = cp - Vector(0,0,3), cp + Vector(0,0,78)
        render.SetMaterial(Material("cable/blue_elec"))
        for i=0,7 do
            local a = t*0.35 + i*math.pi/4
            local offset = Vector(math.cos(a)*29, math.sin(a)*29, 0)
            render.DrawBeam(bottom+offset, top+offset, 3, 0, 1, Color(60,180,255,220))
            local nextA = t*0.35 + (i+1)*math.pi/4
            local nextOffset = Vector(math.cos(nextA)*29, math.sin(nextA)*29, 0)
            render.DrawBeam(top+offset, top+nextOffset, 2, 0, 1, Color(120,230,255,220))
            render.DrawBeam(bottom+offset, bottom+nextOffset, 2, 0, 1, Color(120,230,255,220))
        end
        -- Tentacles visibly connect the tripod to the energy cage.
        for i=0,2 do
            local a = t*0.8 + i*math.pi*2/3
            local root = hub + Vector(math.cos(a)*16, math.sin(a)*16, 0)
            local tip = cp + Vector(math.cos(a)*24, math.sin(a)*24, 42)
            render.DrawBeam(root, (root+tip)*0.5 + Vector(0,0,18), 5, 0, 1, Color(90,120,130))
            render.DrawBeam((root+tip)*0.5 + Vector(0,0,18), tip, 3, 0, 1, Color(80,200,255))
        end
    end
end

function R.DrawBall(ent)
    setup(ent)
    local p, t = ent:GetPos(), CurTime()
    local spin = ent:GetAngles()
    sphere(p, 25, Color(185,32,42))
    -- Two raised yellow racing bands rotate with the tumbling ball.
    render.SetMaterial(Material("cable/yellowlaser"))
    local f, r = spin:Forward(), spin:Right()
    render.DrawBeam(p-f*23, p+f*23, 7, 0, 1, Color(255,205,45))
    render.DrawBeam(p-r*22, p+r*22, 5, 0, 1, Color(255,245,170))
    sphere(p + f*16 + Vector(0,0,4), 4, Color(20,20,22))
    sphere(p + f*16 + Vector(0,0,-4), 4, Color(20,20,22))
    local glow = 3 + math.abs(math.sin(t*8))*2
    sphere(p + f*22, glow, Color(255,90,25))
end
