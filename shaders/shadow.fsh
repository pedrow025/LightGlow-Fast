#version 120

const int   shadowMapResolution = 512;   // 32 blocos / 512 = 1/16 de bloco por pixel
const float shadowDistance      = 16.0;
const float sunPathRotation     = 25.0;  // inclina o sol para a sombra ter silhueta, nao ficar so embaixo

uniform sampler2D texture;
varying vec2 texcoord;

void main() {
    vec4 c = texture2D(texture, texcoord);
    if (c.a < 0.1) discard;
    gl_FragData[0] = c;
}
