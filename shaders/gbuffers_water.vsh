#version 120

// ---- Opções (menu de shaders do Iris) ----
#define WAVE_HEIGHT 0.05 //[0.02 0.03 0.05 0.07 0.09]
#define WAVE_SPEED 1.0 //[0.5 0.75 1.0 1.5]

attribute vec4 mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying float fogDist;
varying vec3 viewPos;
varying vec3 worldNormal;
varying float waveShade;
varying float isWater;

// altura da onda (-1..1), função só da posição no mundo => blocos vizinhos não racham
float waveH(vec2 p, float t) {
    return sin(p.x * 1.1 + t * 1.6) * 0.40
         + sin(p.y * 0.9 + t * 1.2) * 0.35
         + sin((p.x + p.y) * 0.6 - t * 0.9) * 0.25;
}

void main() {
    vec4 vp = gl_ModelViewMatrix * gl_Vertex;
    isWater = float(abs(mc_Entity.x - 10001.0) < 0.5);

    vec3 rel = (gbufferModelViewInverse * vp).xyz;
    vec3 ap  = rel + cameraPosition;
    waveShade = 1.0;

    // só mexe nos vértices da superfície (não no fundo/lados fixos)
    if (isWater > 0.5 && fract(ap.y + 0.01) > 0.02) {
        float t = frameTimeCounter * WAVE_SPEED;
        float h  = waveH(ap.xz, t);
        float hx = waveH(ap.xz + vec2(0.1, 0.0), t);
        float hz = waveH(ap.xz + vec2(0.0, 0.1), t);
        rel.y += h * WAVE_HEIGHT;

        // sombreamento leve pela inclinação da onda, para a onda aparecer
        vec3 n = normalize(vec3(-(hx - h) * 10.0 * WAVE_HEIGHT * 6.0, 1.0, -(hz - h) * 10.0 * WAVE_HEIGHT * 6.0));
        vec3 L = normalize(vec3(0.5, 0.8, 0.3));
        waveShade = clamp(1.0 + (dot(n, L) - L.y) * 1.6, 0.8, 1.2);
    }

    vp = gbufferModelView * vec4(rel, 1.0);
    gl_Position = gl_ProjectionMatrix * vp;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor  = gl_Color;
    viewPos  = vp.xyz;
    fogDist  = length(vp.xyz);
    worldNormal = mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal);
}
