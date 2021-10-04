// Vignette shader
uniform float radius;
uniform vec3 color;
uniform float opacity;
uniform float softness;

vec4 effect(vec4 col, Image tex, vec2 tc, vec2 sc) {
    float vignette = 1.0 - smoothstep(radius, radius - softness, length(tc - vec2(0.5)));
    return mix(Texel(tex, tc), vec4(color.r, color.g, color.b, 1.0), vignette*opacity);
}