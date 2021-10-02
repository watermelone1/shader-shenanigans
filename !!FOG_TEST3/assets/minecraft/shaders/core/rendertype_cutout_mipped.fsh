#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 normal;
in vec3 position;

out vec4 fragColor;

#define RED vec4(1,0,0,1);
#define PI 3.14159

float rand(vec2 c){
	return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p, float freq ){
	float unit = 50/freq;
	vec2 ij = floor(p/unit);
	vec2 xy = mod(p,unit)/unit;
	//xy = 3.*xy*xy-2.*xy*xy*xy;
	xy = .5*(1.-cos(PI*xy));
	float a = rand((ij+vec2(0.,0.)));
	float b = rand((ij+vec2(1.,0.)));
	float c = rand((ij+vec2(0.,1.)));
	float d = rand((ij+vec2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

float pNoise(vec2 p, int res){
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;
	int iCount = 0;
	for (int i = 0; i<50; i++){
		n+=amp*noise(p, f);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}
	float nf = n/normK;
	return nf*nf*nf*nf;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.5) discard;
    float height = 0;
    float vdist = clamp((position.y - 1.6) * 0.65, -17, 0);
    vec2 pos = vec2(position.x, position.z);
    pos.x += GameTime * 10000;
    float noise = pNoise(pos, 1) * 0.5 + 0.5;
    float m0 = clamp(vdist / (-32 * noise), 0, 1.5);
    float jitter = rand(position.xz);
    vec4 fogcol = vec4(153, 173, 210, 255) / 255. * clamp(m0,0,1.5) * clamp(200 / (length(position) * 2), 0, 1);
    fragColor = linear_fog(color, vertexDistance, -100, FogEnd, fogcol);
    // fragColor = vec4(vec3(noise), 1);
}
