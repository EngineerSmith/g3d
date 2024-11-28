// written by groverbuger for g3d
// september 2021
// MIT license

// this vertex shader is what projects 3d vertices in models onto your 2d screen

uniform mat4 projectionMatrix; // handled by the camera
uniform mat4 viewMatrix;       // handled by the camera
uniform mat4 modelMatrix;      // models send their own model matrices when drawn

// the vertex normal attribute must be defined, as it is custom unlike the other attributes

attribute layout(location = 3) vec3 VertexNormal;

// define some varying vectors that are useful for writing custom fragment shaders
varying vec4 worldPosition;
varying vec4 viewPosition;
varying vec4 screenPosition;
varying vec3 vertexNormal;
varying vec4 vertexColor;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    // calculate the positions of the transformed coordinates on the screen
    // save each step of the process, as these are often useful when writing custom fragment shaders
    worldPosition = modelMatrix * vertexPosition;
    viewPosition = viewMatrix * worldPosition;
    screenPosition = projectionMatrix * viewPosition;

    // save some data from this vertex for use in fragment shaders
    vertexNormal = VertexNormal;
    vertexColor = VertexColor;

    return screenPosition;
}
