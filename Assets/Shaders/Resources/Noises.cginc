float Hash(float n)
{
	return frac(sin(n)*43758.5453123);
}

float Hash3(float3 n)
{
	float3 p = frac(n * .1031);
	p += dot(p, p.yzx + float3(19.19, 17.15, 13.18));
	return frac((p.x + p.y)*p.z);
}

float Perlin1D(float x)
{
	float xI = floor(x);
	float xF = frac(x);

	xF = xF * xF*(3.0 - 2.0*xF);

	return lerp(Hash(xI), Hash(xI + 1.0), xF);
}

float Perlin3D(float3 x)
{
	float3 xI = floor(x);
	float3 xF = frac(x);

	xF = xF * xF*(3.0 - 2.0*xF);

	float2 offs = float2(0.0, 1.0);

	return lerp(lerp(lerp(Hash3(xI + offs.xxx), Hash3(xI+ offs.yxx), xF.x),
		lerp(Hash3(xI + offs.xyx), Hash3(xI + offs.yyx), xF.x), xF.y),
		lerp(lerp(Hash3(xI + offs.xxy), Hash3(xI + offs.yxy), xF.x),
			lerp(Hash3(xI + offs.xyy), Hash3(xI + offs.yyy), xF.x), xF.y), xF.z);
}