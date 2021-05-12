float SmoothMin(float a, float b, float k)
{
	float x = exp(-k * a);
	float y = exp(-k * b);
	return (a * x + b * y) / (x + y);
}

float SmoothMax(float a, float b, float k)
{
	return SmoothMin(a, b, -k);
}

float4 raymarch(float2 uv, sampler2D raymarchSampler, float3 viewDirTgtSpc, float3 smokeColor, float3 shadowColor, float maxDistance, 
	float smokeSmoothness, float maxSimDensity, float smokeDensity, float volumetricThickness, float shadowDensity, float3 lightDirTgtSpc)
{
	float invMaxSimDensity = 1.0f / maxSimDensity;
	float stepCount = 50.0f;
	float shadowStepDepth = volumetricThickness/8.0f;

	float stepDepth = volumetricThickness / stepCount;
	float3 stepDir = -viewDirTgtSpc * stepDepth / viewDirTgtSpc.z;
	float stepLen = length(stepDir);

	float3 currentPosition = float3(uv, 0.0f);
	float4 color = 0.0.xxxx;
	float transmittance = 1.0f;
	float accumulatedDistance = 0.0f;

	[unroll]
	for (float i = 0.0; i < stepCount; i++)
	{
		currentPosition += stepDir;

		float normalizedDepth = -currentPosition.z / volumetricThickness;

		float localDensity = tex2Dlod(raymarchSampler, float4(currentPosition.xy, 0.0f, 0.0f)).r * invMaxSimDensity;
//		float localDensity = SmoothMin(1.0, tex2Dlod(raymarchSampler,
//			float4(currentPosition.xy, 0.0f, 0.0f)).r * invMaxSimDensity, 8.0);
		
		if (any(currentPosition.xy < 0.0.xx) || any(currentPosition.xy >= 1.0.xx))
			localDensity = 0.0f;

		float distanceToMidplane = abs(normalizedDepth - 0.5) * 2.0f;
		float weight = smoothstep(localDensity , localDensity - smokeSmoothness, distanceToMidplane);
		float3 lightColor = 1.0.xxx;

		if (localDensity > 0.001f) {
			float3 shadowCurrentPosition = currentPosition;
			float3 shadowStepDir = lightDirTgtSpc * max(shadowStepDepth / lightDirTgtSpc.z, shadowStepDepth * 0.1f);
			float shadowStepLen = length(shadowStepDir);
			float accumulatedDensity = 0.0f;
			
			int maxIterationCount = 10;

			while((shadowCurrentPosition.z < 0.0) && (maxIterationCount>0))
			{
				shadowCurrentPosition += shadowStepDir;

				float shadowLocalDensity = min( 1.0, tex2Dlod(raymarchSampler, float4(shadowCurrentPosition.xy, 0.0f, 0.0f)).r * invMaxSimDensity);
//				float shadowLocalDensity = SmoothMin( 1.0, tex2Dlod(raymarchSampler, 
//					float4(shadowCurrentPosition.xy, 0.0f, 0.0f)).r * invMaxSimDensity, 8.0);

				float shadowNormalizedDepth = -shadowCurrentPosition.z / volumetricThickness;
				float shadowDistanceToMidplane = abs(shadowNormalizedDepth - 0.5) * 2.0f;
				float shadowWeight = smoothstep(shadowLocalDensity, shadowLocalDensity - smokeSmoothness, shadowDistanceToMidplane);

				accumulatedDensity += shadowWeight * shadowStepLen * shadowDensity;
				maxIterationCount--;
			}

			lightColor = exp(-accumulatedDensity * shadowColor);
		}

		float3 localColor = smokeColor * lightColor;

		accumulatedDistance += stepLen;
		float density = 1.0 - exp(-smokeDensity * stepLen * weight);

		if (accumulatedDistance > maxDistance*0.05)
			density = 0.0f;

		color.rgb += localColor * transmittance * density;
		transmittance *= saturate(1.0 - density);
	}
	color.a = 1.0 - transmittance;

	return color;
}