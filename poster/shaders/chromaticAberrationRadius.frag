// A radius based chromatic aberration shader.
// Any pixel brighter than 'cutoff' and darker than `cutoff + bandwidth' is returned

uniform vec2 position;
uniform float radius;
uniform vec2 imageSize;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    float offset = distance(tc, position / imageSize) * (radius / max(imageSize.x, imageSize.y));
    return vec4( Texel(tex, vec2(tc.x + offset, tc.y + offset)).r, Texel(tex, tc).g, Texel(tex, vec2(tc.x - offset, tc.y - offset)).b, 1.0);
}

