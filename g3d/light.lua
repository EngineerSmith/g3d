local g3d = g3d

local camera = require(g3d.path .. ".camera")

local light = { }
light.__index = light

-- Spotlight
function light.new(x, y, z, dx, dy, dz, radius, angle, r, g, b, intensity)
  radius = radius or 100

  local lightCam = camera.newCamera()
  lightCam.farClip = radius * 1.1
  lightCam.fov = math.rad(angle or 12)
  lightCam:lookAt(x, y, z, dx, dy, dz)

  return setmetatable({
    camera = lightCam,
    radius = radius,
    color = { r or 1, g or 1, b or 1 },
    intensity = intensity or 1,
  }, light)
end

local trySend = function(shader, var, ...)
  if shader:hasUniform(var) then
    shader:send(var, ...)
  end
end

function light:send(shader, variableName)
  trySend(shader, variableName..".position", self.camera.position)
  trySend(shader, variableName..".direction", self.camera.target)
  trySend(shader, variableName..".color", self.color)
  trySend(shader, variableName..".intensity", self.intensity)
  trySend(shader, variableName..".radius", self.radius)
  trySend(shader, variableName..".coneAngle", self.camera.fov / 1.1)
  trySend(shader, variableName..".viewMatrix", self.camera.viewMatrix)
end

return light