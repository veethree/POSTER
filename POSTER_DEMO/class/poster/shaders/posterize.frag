// Posterize shader

uniform float colors;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec3 pixel = Texel(tex, tc).rgb;
    pixel = floor(pixel * colors) / colors;
    return vec4(pixel.r, pixel.g, pixel.b, Texel(tex, tc).a);
}