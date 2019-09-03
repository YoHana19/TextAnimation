#include "UnityCG.cginc"

// Hash function from H. Schechter & R. Bridson, goo.gl/RXiKaH
uint Hash(uint s)
{
    s ^= 2747636419u;
    s *= 2654435769u;
    s ^= s >> 16;
    s *= 2654435769u;
    s ^= s >> 16;
    s *= 2654435769u;
    return s;
}

float Random(uint seed)
{
    return float(Hash(seed)) / 4294967295.0; // 2^32-1
}

// Uniformaly distributed points on a unit sphere
// http://mathworld.wolfram.com/SpherePointPicking.html
float3 RandomUnitVector(uint seed)
{
    float PI2 = 6.28318530718;
    float z = 1 - 2 * Random(seed);
    float xy = sqrt(1.0 - z * z);
    float sn, cs;
    sincos(PI2 * Random(seed + 1), sn, cs);
    return float3(sn * xy, cs * xy, z);
}

// Uniformaly distributed points inside a unit sphere
float3 RandomVector(uint seed)
{
    return RandomUnitVector(seed) * sqrt(Random(seed + 2));
}

// Uniformaly distributed points inside a unit cube
float3 RandomVector01(uint seed)
{
    return float3(Random(seed), Random(seed + 1), Random(seed + 2));
}

inline fixed4 RGB2HSL(fixed4 rgb) {
	fixed4 hsl = fixed4(0.0, 0.0, 0.0, rgb.w);

	fixed vMin = min(min(rgb.x, rgb.y), rgb.z);
	fixed vMax = max(max(rgb.x, rgb.y), rgb.z);
	fixed vDelta = vMax - vMin;

	hsl.z = (vMax + vMin) / 2.0;

	if (vDelta == 0.0) {
		hsl.x = hsl.y = 0.0;
	}
	else {
		if (hsl.z < 0.5) hsl.y = vDelta / (vMax + vMin);
		else hsl.y = vDelta / (2.0 - vMax - vMin);

		float rDelta = (((vMax - rgb.x) / 6.0) + (vDelta / 2.0)) / vDelta;
		float gDelta = (((vMax - rgb.y) / 6.0) + (vDelta / 2.0)) / vDelta;
		float bDelta = (((vMax - rgb.z) / 6.0) + (vDelta / 2.0)) / vDelta;

		if (rgb.x == vMax) hsl.x = bDelta - gDelta;
		else if (rgb.y == vMax) hsl.x = (1.0 / 3.0) + rDelta - bDelta;
		else if (rgb.z == vMax) hsl.x = (2.0 / 3.0) + gDelta - rDelta;

		if (hsl.x < 0.0) hsl.x += 1.0;
		if (hsl.x > 1.0) hsl.x -= 1.0;
	}

	return hsl;
}

inline fixed Hue2RGB(float v1, float v2, float vH) {
	if (vH < 0.0) vH += 1.0;
	if (vH > 1.0) vH -= 1.0;
	if ((6.0 * vH) < 1.0) return (v1 + (v2 - v1) * 6.0 * vH);
	if ((2.0 * vH) < 1.0) return (v2);
	if ((3.0 * vH) < 2.0) return (v1 + (v2 - v1) * ((2.0 / 3.0) - vH) * 6.0);
	return v1;
}

inline fixed4 HSL2RGB(fixed4 hsl) {
	fixed4 rgb = fixed4(0.0, 0.0, 0.0, hsl.w);

	if (hsl.y == 0) {
		rgb.xyz = hsl.zzz;
	}
	else {
		float v1;
		float v2;

		if (hsl.z < 0.5) v2 = hsl.z * (1 + hsl.y);
		else v2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);

		v1 = 2.0 * hsl.z - v2;

		rgb.x = Hue2RGB(v1, v2, hsl.x + (1.0 / 3.0));
		rgb.y = Hue2RGB(v1, v2, hsl.x);
		rgb.z = Hue2RGB(v1, v2, hsl.x - (1.0 / 3.0));
	}

	return rgb;
}

// Euler angles rotation matrix
float3x3 Euler3x3(float3 v)
{
    float sx, cx;
    float sy, cy;
    float sz, cz;

    sincos(v.x, sx, cx);
    sincos(v.y, sy, cy);
    sincos(v.z, sz, cz);

    float3 row1 = float3(sx*sy*sz + cy*cz, sx*sy*cz - cy*sz, cx*sy);
    float3 row3 = float3(sx*cy*sz - sy*cz, sx*cy*cz + sy*sz, cx*cy);
    float3 row2 = float3(cx*sz, cx*cz, -sx);

    return float3x3(row1, row2, row3);
}
