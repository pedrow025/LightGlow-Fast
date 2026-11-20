#version 120

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 vpos;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor  = gl_Color;
    vpos     = (gl_ModelViewMatrix * gl_Vertex).xyz;
}
