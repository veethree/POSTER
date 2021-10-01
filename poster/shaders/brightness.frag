// Brightness shader
// 0 is grayscale, 1 is normal, 2 is 2x etc. negative values do something odd./*  */

uniform float amount;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    return Texel(tex, tc) + amount;
}

//pixelColor.rgb = ((pixelColor.rgb - 0.5f) * max(Contrast, 0)) + 0.5f;