// A radius based chromatic aberration shader.

uniform vec2 position;
uniform float offset;
uniform vec2 imageSize;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    float offset = distance(tc, position / imageSize) * (offset / max(imageSize.x, imageSize.y));
    return vec4( Texel(tex, vec2(tc.x + offset, tc.y + offset)).r, Texel(tex, tc).g, Texel(tex, vec2(tc.x - offset, tc.y - offset)).b, 1.0);
}

