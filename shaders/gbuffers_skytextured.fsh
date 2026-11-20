#version 120

#define ECLIPSE_STRENGTH 1.0 //[0.0 0.25 0.5 0.75 1.0]
#define ATMOSPHERE 1 //[0 1]

uniform sampler2D texture;
uniform vec3 fogColor;
uniform vec3 sunPosition;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 vpos;

void main() {
    vec4 tex = texture2D(texture, texcoord) * glcolor;

    float dayF = smoothstep(0.25, 0.65, dot(fogColor, vec3(0.333)));
    float e = (ATMOSPHERE == 0 ? ECLIPSE_STRENGTH * dayF : 0.0);

    vec3 v = normalize(vpos);
    vec3 s = normalize(sunPosition);
    float c = dot(v, s);

    if (e > 0.02 && c > 0.5) {
        float d = length(v / c - s);                       // distância ao centro do sol
        float disc = 1.0 - smoothstep(0.080, 0.086, d);    // disco negro
        float ring = (1.0 - disc) * exp(-(d - 0.083) * 16.0) * (1.0 - smoothstep(0.20, 0.29, d));
        vec3 col = mix(vec3(1.0, 0.55, 0.25), vec3(1.0, 0.95, 0.85), exp(-(d - 0.083) * 30.0)) * ring * 2.0;
        vec4 ec = vec4(col, clamp(ring + disc, 0.0, 1.0));
        tex = mix(tex, ec, e);
    }

#if ATMOSPHERE == 1
    // Estilo sombrio: sol e lua escondidos atrás da neblina pesada
    tex *= 1.0 - 0.85 * ECLIPSE_STRENGTH;
#endif
    gl_FragData[0] = tex;
}
