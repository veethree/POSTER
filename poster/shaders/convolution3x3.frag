// A 3x3 convolution shader.
// Faster than 'convolution.frag' because it doesnt use loops. Better suited for real time effects.
// It takes the kernel as a 1d array.
// 'size' needs to be the size of your image as its used to calculate stepSize.

uniform vec2 imageSize;
uniform float kernel[9];
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 sum = vec4(0.0);
    vec2 stepSize = 1.0 / imageSize;

    sum += Texel(tex, vec2(tc.x - stepSize.x, tc.y - stepSize.y)) * kernel[0];
    sum += Texel(tex, vec2(tc.x, tc.y - stepSize.y)) * kernel[1];
    sum += Texel(tex, vec2(tc.x + stepSize.x, tc.y - stepSize.y)) * kernel[2];

    sum += Texel(tex, vec2(tc.x - stepSize.x, tc.y)) * kernel[3];
    sum += Texel(tex, vec2(tc.x, tc.y)) * kernel[4];
    sum += Texel(tex, vec2(tc.x + stepSize.x, tc.y)) * kernel[5];

    sum += Texel(tex, vec2(tc.x - stepSize.x, tc.y + stepSize.y)) * kernel[6];
    sum += Texel(tex, vec2(tc.x, tc.y + stepSize.y)) * kernel[7];
    sum += Texel(tex, vec2(tc.x + stepSize.x, tc.y + stepSize.y)) * kernel[8];

    return sum ;
}