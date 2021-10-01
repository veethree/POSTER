// A highpass filter shader
// Any pixel with a brightness higher than 'cutoff' is returned.

uniform float cutoff;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 result = vec4(0.0);
    vec4 pixel = Texel(tex, tc);
    
    if (pixel.r < cutoff && pixel.g < cutoff && pixel.b < cutoff) {
        result = Texel(tex, tc);
    }
    return result;
}