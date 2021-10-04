// Pixelation shader
uniform vec2 resolution;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    tc.x -= mod(tc.x, 1.0 / resolution.x);
    tc.y -= mod(tc.y, 1.0 / resolution.y);
    return Texel(tex, tc);
}