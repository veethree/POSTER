// Saturation shader
uniform float amount;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 pixel = Texel(tex, tc);
    float avg = (pixel.r + pixel.g + pixel.b) / 3.0;
    vec4 grayscale = vec4(avg, avg, avg, 1.0);
    return mix(grayscale, pixel, amount);
}
