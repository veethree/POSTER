// A fairly low resolution vertical gaussian blur shader.
uniform vec2 imageSize;
uniform float amount;


vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 sum = vec4(0.0);
    float normalAmount = amount / imageSize.y;

    sum += Texel(tex, vec2(tc.x, tc.y - 4.0*normalAmount)) * 0.05;
    sum += Texel(tex, vec2(tc.x, tc.y - 3.0*normalAmount)) * 0.09;
    sum += Texel(tex, vec2(tc.x, tc.y - 2.0*normalAmount)) * 0.12;
    sum += Texel(tex, vec2(tc.x, tc.y - normalAmount)) * 0.15;
    sum += Texel(tex, vec2(tc.x, tc.y)) * 0.16;
    sum += Texel(tex, vec2(tc.x, tc.y + normalAmount)) * 0.15;
    sum += Texel(tex, vec2(tc.x, tc.y + 2.0*normalAmount)) * 0.12;
    sum += Texel(tex, vec2(tc.x, tc.y + 3.0*normalAmount)) * 0.09;
    sum += Texel(tex, vec2(tc.x, tc.y + 4.0*normalAmount)) * 0.05;

    return sum;
}

// color += Texel(tex, tc + intensity*vec2(0.0, 0.0));