#pragma language glsl3

struct spotlight {
  vec3 position;
  vec3 direction;
  vec3 color;
  float intensity;
  float radius;
  float coneAngle;
  mat4 viewMatrix;
};

uniform Image worldPosition;
uniform Image fragmentNormal;

uniform sampler2DShadow shadowMap;
uniform spotlight light;

vec3 calculateSpotLighting(vec4 worldPos, vec3 normal)
{
  vec3 lightDir = normalize(light.position - worldPos.xyz);
  float distance = length(light.position - worldPos.xyz);

  float diffuseFactor = max(dot(normal, lightDir), 0.0);

  float attenuation = 1.0 / (distance*distance + light.radius*light.radius); // distance*distance*light.radius

  float angleCos = dot(-lightDir, light.direction);
  float coneCos = cos(light.coneAngle);
  float coneFactor = clamp((angleCos - coneCos) / (1.0 - coneCos), 0.0, 1.0);

  vec3 shadowCoords = (light.viewMatrix * worldPos).xyz*vec3(.5) + vec3(0.5);
  float shadowFactor = texture(shadowMap, shadowCoords);

  //return light.intensity * light.color * diffuseFactor * attenuation * coneFactor * -shadowFactor;
  return vec3(1.0) * light.intensity * light.color * shadowFactor;
}

vec4 effect(vec4 color, Image lightBuffer, vec2 uv, vec2 _)
{
  vec4 worldPos = texture(worldPosition, uv).xyzw;
  vec3 normal = texture(fragmentNormal, uv).xyz;

  vec3 newLighting = calculateSpotLighting(worldPos, normal);

  vec4 currentLighting = texture(lightBuffer, uv).rgba;

  return currentLighting + vec4(newLighting, 1.0);
}
