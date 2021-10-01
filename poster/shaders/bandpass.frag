// Bandpass filter shader. 
// Any pixel brighter than 'cutoff' and darker than `cutoff + bandwidth' is returned

uniform float cutoff;
uniform float bandwidth;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 result = vec4(0.0);
    vec4 pixel = Texel(tex, tc);

    float avg = (pixel.r + pixel.g + pixel.b) / 3.0;
    
    if (avg > cutoff && avg < cutoff + bandwidth) {
        result = Texel(tex, tc);
    }
    return result;
}