// Saturation shader
// 0 is grayscale, 1 is normal, 2 is 2x etc. negative values do something odd./*  */

uniform float amount;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 pixel = Texel(tex, tc);
    float avg = (pixel.r + pixel.g + pixel.b) / 3.0;
    vec4 grayscale = vec4(avg, avg, avg, 1.0);
    return mix(grayscale, pixel, amount);
}
