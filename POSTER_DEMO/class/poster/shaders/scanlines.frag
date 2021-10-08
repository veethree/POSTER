// scanline shader

uniform vec2 imageSize;
uniform float opacity;
uniform float scale;
uniform float phase;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 pixel = Texel(tex, tc);
    pixel.rgb = pixel.rgb * clamp(ceil(sin(phase + tc.y * imageSize.y * scale)), opacity, 1);
    return pixel;
}
