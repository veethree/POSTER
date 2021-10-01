// A loop based convolution shader
// By default, Can run any kernel with a maximum of 25 values. (e.g. 5x5)
// You can change MAX_KERNEL to a higher value if you want larger kernels.
#define MAX_KERNEL 25

uniform vec2 imageSize;
uniform int kernelWidth;
uniform int kernelHeight;
uniform float kernel[MAX_KERNEL];

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 sum = vec4(0.0);

    int w = kernelWidth / 2;
    int h = kernelHeight / 2;
    int i = 0;
    for (int x = -w; x <= w; x++) {
        for (int y = -h; y <= h; y++) {
            sum += Texel(tex, tc + vec2(x / imageSize.x, y / imageSize.y)) * kernel[i];
            i++;
        }
    }

    return sum;
}