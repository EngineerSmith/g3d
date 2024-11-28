varying vec4 worldPosition;
varying vec3 vertexNormal;
varying vec4 vertexColor;

uniform Image MainTex;

#define DIFFUSE_CANVAS love_Canvases[0]
#define NORMAL_CANVAS love_Canvases[1]
#define WORLD_CANVAS love_Canvases[2]

void effect()
{
  vec4 textureColor = texture(MainTex, VaryingTexCoord.xy);
  DIFFUSE_CANVAS = vertexColor * textureColor;
  NORMAL_CANVAS = vec4(vertexNormal.xyz, 0);
  WORLD_CANVAS = worldPosition;
}