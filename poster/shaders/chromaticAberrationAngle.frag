// An angle based chromatic aberration shader.

uniform float angle;
uniform float offset;
uniform vec2 imageSize;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    float normalOffsetX = tc.x / imageSize.x + offset * cos(angle);
    float normalOffsetY = tc.y / imageSize.y + offset * sin(angle);
    return vec4( Texel(tex, vec2(tc.x + normalOffsetX, tc.y + normalOffsetY)).r, Texel(tex, tc).g, Texel(tex, vec2(tc.x - normalOffsetX, tc.y - normalOffsetY)).b, 1.0);
}

