// A wavy distortion effect
// Intensity is how strong the effect is
// scale is how large the waves are
// size should be the size of the image
// phase is an offset, If you increment it the waves will animate

uniform float intensity;
uniform float scale;
uniform vec2 imageSize;
uniform float phase;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    tc.x = tc.x + sin(tc.y * imageSize.y * (scale / imageSize.x) + phase) * intensity;
    tc.y = tc.y + sin(tc.x * imageSize.x * (scale / imageSize.y) + phase) * intensity;
    return Texel(tex, tc);
}

