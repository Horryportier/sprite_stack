shader_type canvas_item;


uniform sampler2D iImage;

uniform vec2 iScrOffset;
uniform vec2 iScrSize;
uniform vec2 iTexSize;
uniform vec2 iFrameOffset;
uniform vec2 iFrameSize;
uniform float iFrames;
uniform vec3 iScale;
uniform vec3 iRayDir;
uniform vec3 iUDir;
uniform vec3 iVDir;
uniform float iShadow;



const int steps = 256;


const vec4 oob = vec4(0, 0, 0, 0);

vec4 tex3D(vec3 pos, vec2 uv, vec3 u_dir, vec3 v_dir) {
    vec3 xyz = vec3(pos);
    xyz += uv.x * u_dir;
    xyz += uv.y * v_dir;

    vec2 xy = vec2(0);

    float x = xyz.x * iScale.x + 0.5;
    if (x < 0.) return oob;
    if (x >= 1.) return oob;
    //    x *= iFrameSize.x / 128;
    //    x -= fract(xy.x);
    //    x /= iFrameSize.x / 128;
    xy.x = x;

    float frame = (xyz.y * iScale.y + 0.5) * iFrames;
    frame -= fract(frame);
    if (frame < 0.) return oob;
    if (frame >= iFrames) return oob;
    frame /= iFrames;
    xy.y = frame;

    float d = xyz.z * iScale.z + 0.5;
    if (d < 0.) return oob;
    if (d >= 1.) return oob;
    //    d *= iFrameSize.y;
    //    d -= fract(d);
    //    d /= iFrameSize.y;
    xy.y += d / iFrames;

    xy.x /= iTexSize.x / iFrameSize.x;
    xy.y /= iTexSize.y / iFrameSize.y / iFrames;
    xy.x += iFrameOffset.x;
    xy.y += iFrameOffset.y;

    return texture(iImage, xy);
}

void fragment() {
	vec3 dir = vec3(1, 0, 0);
	vec3 u_dir = vec3(0, 0, 1);
 	vec3 v_dir = vec3(0, 1, 0);

	float u_step = 1. / iFrameSize.x;
	float v_step = 1. / iFrameSize.y;
    dir.xyz = iRayDir.xyz;
    u_dir.xyz = iUDir.xyz;
    v_dir.xyz = iVDir.xyz;

    vec2 uv = UV;
    uv.x -= iScrOffset.x;
    uv.y -= iScrOffset.y;
    uv.x /= iScrSize.x;
    uv.y /= iScrSize.y;
    uv.x -= 0.5;
    uv.y -= 0.5;

    dir = dir / vec3(float(steps));

    vec3 pos = vec3(dir);
    vec2 uvd = vec2(uv);
    uvd.x += u_step;
    uvd.y += v_step;
    pos *= vec3(float(steps / 2));
    for (int i = 0; i < steps; i++) {
        vec4 c = tex3D(pos, uv, u_dir, v_dir);
        if (c.x > 0. || c.y > 0. || c.z > 0.) {
            if (iShadow == 0.) {
                COLOR = c;
                vec4 s = tex3D(pos, uvd, u_dir, v_dir);
                if (s.a <= 0.001) {
                    COLOR.xyz *= 0.8;
                }

            }


        }
        pos -= dir;
    }

    COLOR = oob;
}