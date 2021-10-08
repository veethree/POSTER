// RGB mix shader

uniform vec3 rgb;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 pixel = Texel(tex, tc);
    return vec4(pixel.r * rgb.r, pixel.g * rgb.g, pixel.b * rgb.b, pixel.a);
}
