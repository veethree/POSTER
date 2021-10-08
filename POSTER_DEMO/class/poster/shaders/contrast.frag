// Contrast shader

uniform float amount;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 pixel = Texel(tex, tc);
    return vec4(pixel.rgb - 0.5 * max(amount, 0) + 0.5, pixel[3]);
}