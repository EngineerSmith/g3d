local newMatrix = require(g3d.path .. ".matrices")
local g3d = g3d

local lg = love.graphics

--[[
Color information
World-space position
Normal vectors
]]

local gbuffer = { }
gbuffer.shader = lg.newShader(g3d.shaderpath, g3d.directory .. "/gbuffer.frag")
gbuffer.shadowShader = lg.newShader(g3d.directory .. "/shadow.frag")

local findFormat
findFormat = function(formats, format, ...)
  if format == nil then
    return nil
  end
  if formats[format] then
    return format
  end
  return findFormat(formats, ...)
end

gbuffer.resize = function(w, h, msaa)
  local format = findFormat(love.graphics.getTextureFormats({
      canvas = true,
      readable = true,
    }), "rgba32f", "rgba16f")

  if not format then
    return error("System graphics not supported - todo disable lighting?")
  end

  local settings = {
    readable = true,
    format = format,
  }

  local diffuse = lg.newCanvas(w, h, { msaa = msaa or 0, readable = true })
  local normal = lg.newCanvas(w, h, settings)
  local world = lg.newCanvas(w, h, settings)

  gbuffer.setup = {
    diffuse, normal, world, depth = true, stencil = false,
  }

  gbuffer.renderTargets = {
    lg.newCanvas(w, h, {
      msaa = msaa or 0,
      readable = true,
    }),
    lg.newCanvas(w, h, {
      msaa = msaa or 0,
      readable = true,
    })
  }

  local format = findFormat(love.graphics.getTextureFormats({
      canvas = true,
      readable = true,
    }), "depth32f", "depth24", "depth16")

  if not format then
    return error("System graphics not supported - todo disable shadows?")
  end

  gbuffer.shadowMap = lg.newCanvas(32^2, 32^2, {
    format = format,
    readable = true,
  })
  gbuffer.shadowMap:setDepthSampleMode("gequal")
end

gbuffer.set = function()
  lg.push("all")

  lg.setCanvas(gbuffer.setup)
  love.graphics.setDepthMode("lequal", true)
  lg.clear(0,0,0,1, false, true)
  lg.setShader(gbuffer.shader)
end

gbuffer.unset = function()
  lg.pop()
end

gbuffer.clearRenderTargets = function(r, g, b, a)
  lg.push("all")
  love.graphics.setCanvas(gbuffer.renderTargets)
  love.graphics.clear(r, g, b, a)
  lg.pop()
end

local oldCamera
gbuffer.prepareLight = function(light)
  oldCamera = g3d.camera.current()
  lg.push("all")

  g3d.camera.setCurrent(light.camera)
  lg.setCanvas({ depthstencil = gbuffer.shadowMap })
  lg.clear(0, 0, 0, 0, false, true)
  lg.setDepthMode("lequal", true)
  lg.setMeshCullMode("front")
end

gbuffer.processlight = function(light)

  lg.pop()
  g3d.camera.setCurrent(oldCamera)
  lg.push("all")
  lg.setCanvas(gbuffer.renderTargets[2])
  lg.clear(0,0,0,0)

  lg.setShader(gbuffer.shadowShader)

  light:send(gbuffer.shadowShader, "light")
  if gbuffer.shadowShader:hasUniform("shadowMap") then
    gbuffer.shadowShader:send("shadowMap", gbuffer.shadowMap)
  end
  
  if gbuffer.shadowShader:hasUniform("worldPosition") then
    gbuffer.shadowShader:send("worldPosition", gbuffer.setup[3])
  end
  if gbuffer.shadowShader:hasUniform("fragmentNormal") then
    gbuffer.shadowShader:send("fragmentNormal", gbuffer.setup[2])
  end

  lg.origin()
  lg.draw(gbuffer.renderTargets[1])
  lg.pop()
  -- swap targets
  gbuffer.renderTargets[1], gbuffer.renderTargets[2] = gbuffer.renderTargets[2], gbuffer.renderTargets[1]
end

gbuffer.present = function()
  lg.draw(gbuffer.renderTargets[1])
end

return gbuffer