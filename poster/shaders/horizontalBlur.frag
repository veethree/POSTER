// A fairly low resolution horizontal gaussian blur shader.
uniform vec2 imageSize;
uniform float amount;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 sum = vec4(0.0);
    float normalAmount = amount / imageSize.x;

    sum += Texel(tex, vec2(tc.x - 4.0*normalAmount, tc.y)) * 0.05;
    sum += Texel(tex, vec2(tc.x - 3.0*normalAmount, tc.y)) * 0.09;
    sum += Texel(tex, vec2(tc.x - 2.0*normalAmount, tc.y)) * 0.12;
    sum += Texel(tex, vec2(tc.x - normalAmount, tc.y)) * 0.15;
    sum += Texel(tex, vec2(tc.x, tc.y)) * 0.16;
    sum += Texel(tex, vec2(tc.x + normalAmount, tc.y)) * 0.15;
    sum += Texel(tex, vec2(tc.x + 2.0*normalAmount, tc.y)) * 0.12;
    sum += Texel(tex, vec2(tc.x + 3.0*normalAmount, tc.y)) * 0.09;
    sum += Texel(tex, vec2(tc.x + 4.0*normalAmount, tc.y)) * 0.05;

    return sum;
}