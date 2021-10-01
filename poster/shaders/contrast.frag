// Contrast shader
// < 1 is less contrast, 1 is normal, > 1 is more contrast. negative values do something odd./*  */


uniform float amount;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 pixel = Texel(tex, tc);
    return vec4(pixel.rgb - 0.5 * max(amount, 0) + 0.5, pixel[3]);
}

//pixelColor.rgb = ((pixelColor.rgb - 0.5f) * max(Contrast, 0)) + 0.5f;