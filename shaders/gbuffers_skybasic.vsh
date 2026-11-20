#version 120

varying vec4 glcolor;
varying float starData;

#ifdef MC_RENDER_STAGE_STARS
uniform int renderStage;
#endif

void main() {
    gl_Position = ftransform();
    glcolor = gl_Color;
#ifdef MC_RENDER_STAGE_STARS
    starData = float(renderStage == MC_RENDER_STAGE_STARS);
#else
    starData = float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0);
#endif
}
