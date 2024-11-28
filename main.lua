-- written by groverbuger for g3d
-- september 2021
-- MIT license

local g3d = require "g3d"
local earth = g3d.newModel("assets/sphere.obj", "assets/earth.png", {4,0,0})
local moon = g3d.newModel("assets/sphere.obj", "assets/moon.png", {4,5,0}, nil, 0.5)
local background = g3d.newModel("assets/sphere.obj", "assets/starfield.png", nil, nil, 500)
local timer = 0

local x, y, z = unpack(g3d.camera.current().position)
local tx, ty, tz = unpack(earth.translation)
g3d.camera.current():lookAt(x, y, z, tx, ty, tz)

local light = g3d.light.new(-2)


function love.update(dt)
    timer = timer + dt
    moon:setTranslation(math.cos(timer)*5 + 4, math.sin(timer)*5, 0)
    moon:setRotation(0, 0, timer - math.pi/2)
    g3d.camera.current():firstPersonMovement(dt)
    if love.keyboard.isDown "escape" then
        love.event.push "quit"
    end
end

local shader = love.graphics.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    texturecolor.r = abs(-(texturecolor.r - 0.99) * 10);
    return texturecolor.rrra;
}
]])

local d = function()
    earth:draw()
    moon:draw()
    --background:draw()
end

function love.draw()
    g3d.gbuffer.set()
    d()
    g3d.gbuffer.unset()

    g3d.gbuffer.clearRenderTargets(0,0,0,0)
    do
        g3d.gbuffer.prepareLight(light)
        d()
        g3d.gbuffer.processlight(light)
    end

    love.graphics.setBlendMode("alpha", "premultiplied")
    --love.graphics.draw(g3d.gbuffer.setup[1])
    g3d.gbuffer.present()

    
    --love.graphics.origin()
    --love.graphics.setShader(shader)
    --love.graphics.draw(g3d.gbuffer.shadowMap)
    --love.graphics.setShader()

end

function love.mousemoved(x,y, dx,dy)
    --g3d.camera.current():firstPersonLook(dx,dy)
end

function love.resize(w, h)
    g3d.gbuffer.resize(w, h)
end