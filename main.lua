-- written by groverbuger for g3d
-- september 2021
-- MIT license

local g3d = require "g3d"
local earth = g3d.newModel("assets/sphere.obj", "assets/earth.png", {4,0,0})
local moon = g3d.newModel("assets/sphere.obj", "assets/moon.png", {4,5,0}, nil, 0.5)
local background = g3d.newModel("assets/sphere.obj", "assets/starfield.png", nil, nil, 500)
local timer = 0

local can = love.graphics.newCanvas()

function love.update(dt)
    timer = timer + dt
    moon:setTranslation(math.cos(timer)*5 + 4, math.sin(timer)*5, 0)
    moon:setRotation(0, 0, timer - math.pi/2)
    g3d.camera.current():firstPersonMovement(dt)
    if love.keyboard.isDown "escape" then
        love.event.push "quit"
    end
    local x, y, z = unpack(g3d.camera.current().position)
    local tx, ty, tz = unpack(moon.translation)
    g3d.camera.current():lookAt(x, y, z, tx, ty, tz)
end

function love.draw()
    love.graphics.setCanvas({can, depth = true})
    earth:draw()
    moon:draw()
    background:draw()
    love.graphics.setCanvas()
    love.graphics.draw(can)
end

function love.mousemoved(x,y, dx,dy)
    --g3d.camera.current():firstPersonLook(dx,dy)
end
