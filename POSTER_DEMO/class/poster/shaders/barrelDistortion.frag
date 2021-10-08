// scanline shader

uniform vec2 imageSize;
uniform float power;

// Credit: https://prideout.net/barrel-distortion
vec2 Distort(vec2 p)
{
    float theta  = atan(p.y, p.x);
    float radius = length(p);
    radius = pow(radius, power);
    p.x = radius * cos(theta);
    p.y = radius * sin(theta);
    return 0.5 * (p + 1.0);
}

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec2 xy = 2.0 * tc - 1.0;
    vec2 uv;
    float d = length(xy);
    if (d < 1.0)
    {
        uv = Distort(xy);
    }
    else
    {
        uv = tc;
    }
    return Texel(tex, uv);
}

// float theta  = atan(p.y, p.x);
// float radius = length(p);
// radius = pow(radius, BarrelPower);
// p.x = radius * cos(theta);
// p.y = radius * sin(theta);
// return 0.5 * (p + 1.0);