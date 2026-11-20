#version 120

// ---- Opções (menu de shaders do Iris) ----
#define TORCH_BRIGHTNESS 1.6 //[1.0 1.2 1.4 1.6 1.8 2.0 2.4]
#define TORCH_WARMTH 1.0 //[0.5 0.75 1.0 1.25]
#define SHADOW_STRENGTH 1.0 //[0.0 0.5 1.0 1.5]
#define ECLIPSE_STRENGTH 1.0 //[0.0 0.25 0.5 0.75 1.0]
#define ATMOSPHERE 1 //[0 1]


uniform sampler2D texture;
uniform sampler2D lightmap;
uniform vec4 entityColor;
uniform float rainStrength;
uniform int isEyeInWater;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying float fogDist;

void main() {
    vec4 c = texture2D(texture, texcoord) * glcolor;
    if (c.a < 0.1) discard;
    c.rgb = mix(c.rgb, entityColor.rgb, entityColor.a);

    float bl = clamp((lmcoord.x - 0.03125) * 1.0666667, 0.0, 1.0);
    float sl = clamp((lmcoord.y - 0.03125) * 1.0666667, 0.0, 1.0);

    // ---- eclipse: só de dia, no Overworld, fora da água ----
    float dayF = smoothstep(0.25, 0.65, dot(gl_Fog.color.rgb, vec3(0.333)));
    float inAir = (isEyeInWater == 0 ? 1.0 : 0.0);
    float e  = (ATMOSPHERE == 0 ? ECLIPSE_STRENGTH * dayF * inAir : 0.0);
    float hy = (ATMOSPHERE == 1 ? ECLIPSE_STRENGTH * inAir : 0.0);
    // Nether: fog vermelha e escura -> estilo sombrio bem mais fraco lá
    float nether = step(3.0 * gl_Fog.color.g + 0.03, gl_Fog.color.r) * step(dot(gl_Fog.color.rgb, vec3(0.333)), 0.25);
    hy *= 1.0 - 0.7 * nether;

    vec3 sky = texture2D(lightmap, vec2(0.03125, lmcoord.y)).rgb;
    // Estilo sombrio: dia sombrio e esverdeado, noite bem escura, cores apagadas
    sky *= mix(vec3(1.0), mix(vec3(0.45, 0.50, 0.70), vec3(0.50, 0.57, 0.55), dayF), hy);
    c.rgb = mix(vec3(dot(c.rgb, vec3(0.299, 0.587, 0.114))), c.rgb, 1.0 - 0.35 * hy);
    sky *= mix(vec3(1.0), vec3(0.62, 0.60, 0.82), e);      // luz do dia escurecida e fria
    float skyLum = dot(sky, vec3(0.333));

    vec3 shadowTint = mix(vec3(0.74, 0.84, 1.12), vec3(1.0), smoothstep(0.0, 1.0, sl));
    vec3 sunTint    = mix(vec3(1.0), vec3(1.05, 1.0, 0.90), smoothstep(0.75, 1.0, sl) * skyLum * (1.0 - 0.8 * e));
    sky *= mix(vec3(1.0), shadowTint * sunTint, SHADOW_STRENGTH);

    vec3 torchCol = max(mix(vec3(1.0, 0.82, 0.62), vec3(1.0, 0.52, 0.20), TORCH_WARMTH), vec3(0.0));
    float t = pow(bl, 1.6) * TORCH_BRIGHTNESS;
    vec3 blockLight = torchCol * t;

    vec3 light = sky + blockLight * (1.0 - 0.6 * skyLum);

    c.rgb *= min(light, vec3(1.5));


    // neblina: cor de brasa no horizonte durante o eclipse (igual ao céu)
    if (gl_Fog.end > gl_Fog.start && gl_Fog.end > 0.0) {
        float fEnd   = gl_Fog.end * mix(1.0, 0.5, hy);       // neblina mais perto
        float fStart = gl_Fog.start * mix(1.0, 0.25, hy);
        float fog = clamp((fEnd - fogDist) / max(fEnd - fStart, 0.001), 0.0, 1.0);
        vec3 hysFog = mix(vec3(0.015, 0.018, 0.03), vec3(0.30, 0.34, 0.34), dayF);
        vec3 fogCol = mix(mix(gl_Fog.color.rgb, vec3(0.38, 0.21, 0.20), e), hysFog, hy);
        c.rgb = mix(fogCol, c.rgb, fog);
    }

    gl_FragData[0] = c;
}
