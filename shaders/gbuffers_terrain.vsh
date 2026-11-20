#version 120

uniform mat4 gbufferModelViewInverse;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying float fogDist;
varying vec3 viewPos;
varying vec3 worldNormal;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor  = gl_Color;
    viewPos  = (gl_ModelViewMatrix * gl_Vertex).xyz;
    fogDist  = length(viewPos);
    worldNormal = mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal);
}
