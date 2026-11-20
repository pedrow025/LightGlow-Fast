#version 120

#define ECLIPSE_STRENGTH 1.0 //[0.0 0.25 0.5 0.75 1.0]
#define ATMOSPHERE 1 //[0 1]

uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;

varying vec4 glcolor;
varying float starData;

void main() {
    if (starData > 0.5) {
        gl_FragData[0] = glcolor;      // estrelas do jogo, sem mexer
        return;
    }

    vec4 p = gbufferProjectionInverse * vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
    vec3 dir = normalize(p.xyz / p.w);
    float up = dot(dir, normalize(upPosition));
    float t = max(up, 0.0);

    // céu normal do jogo
    vec3 vanilla = mix(fogColor, skyColor, smoothstep(0.0, 0.35, t));

    // céu de eclipse: brasa no horizonte, anil no alto
    vec3 horizon = vec3(0.38, 0.21, 0.20);
    vec3 mid     = vec3(0.12, 0.08, 0.22);
    vec3 zenith  = vec3(0.025, 0.03, 0.10);
    vec3 ec = mix(horizon, mid, smoothstep(0.0, 0.30, t));
    ec = mix(ec, zenith, smoothstep(0.25, 0.9, t));

    // brilho quente em volta do sol escurecido
    float sd = max(dot(dir, normalize(sunPosition)), 0.0);
    ec += vec3(1.0, 0.55, 0.28) * (pow(sd, 40.0) * 0.9 + pow(sd, 6.0) * 0.12);

    float dayF = smoothstep(0.25, 0.65, dot(fogColor, vec3(0.333)));
    float e = ECLIPSE_STRENGTH * dayF;

#if ATMOSPHERE == 1
    // Estilo sombrio: céu cinza-esverdeado e pesado de dia, quase preto à noite
    vec3 hDay   = mix(vec3(0.30, 0.34, 0.34), vec3(0.20, 0.25, 0.26), smoothstep(0.0, 0.6, t));
    vec3 hNight = mix(vec3(0.015, 0.018, 0.03), vec3(0.0, 0.0, 0.01), smoothstep(0.0, 0.6, t));
    vec3 hs = mix(hNight, hDay, dayF);
    gl_FragData[0] = vec4(mix(vanilla, hs, ECLIPSE_STRENGTH), 1.0);
#else
    gl_FragData[0] = vec4(mix(vanilla, ec, e), 1.0);
#endif
}
