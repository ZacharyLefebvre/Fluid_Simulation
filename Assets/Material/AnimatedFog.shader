// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AnimatedFog"
{
	Properties
	{
		_Smokecolor("Smoke color", Color) = (0.7169812,0.7169812,0.7169812,0)
		_Shadowcolor("Shadow color", Color) = (0.7169812,0.7169812,0.7169812,0)
		_Smokesmoothness("Smoke smoothness", Range( 0 , 1)) = 0
		_Maxsimulationdensity("Max simulation density", Range( 0 , 10)) = 3
		_Smokedensity("Smoke density", Range( 0 , 250)) = 100
		_Volumetricthickness("Volumetric thickness", Range( 0 , 0.2)) = 0.05
		_Shadowdensity("Shadow density", Range( 0 , 250)) = 100
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#include "Assets/Material/SmokeRaymarcher.cginc"
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		uniform sampler2D _SmokeTexture;
		uniform float3 _MinSimulationBBox;
		uniform float3 _MaxSimulationBBox;
		uniform float4 _Smokecolor;
		uniform float4 _Shadowcolor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Smokesmoothness;
		uniform float _Maxsimulationdensity;
		uniform float _Smokedensity;
		uniform float _Volumetricthickness;
		uniform float _Shadowdensity;


		float4 Raymarcher14( sampler2D SmokeTexture, float2 UV, float3 ViewDirTgtSpace, float3 SmokeColor, float3 ShadowColor, float MaxDistance, float SmokeSmoothness, float MaxSimDensity, float SmokeDensity, float VolumetricThickness, float ShadowDensity, float3 LightDirectionTgtSpace )
		{
			return raymarch(UV, SmokeTexture, ViewDirTgtSpace, SmokeColor, ShadowColor, MaxDistance, SmokeSmoothness, MaxSimDensity, SmokeDensity, VolumetricThickness, ShadowDensity, LightDirectionTgtSpace);
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			sampler2D SmokeTexture14 = _SmokeTexture;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult6 = (float2((1.0 + (ase_worldPos.x - _MinSimulationBBox.x) * (0.0 - 1.0) / (_MaxSimulationBBox.x - _MinSimulationBBox.x)) , (1.0 + (ase_worldPos.z - _MinSimulationBBox.z) * (0.0 - 1.0) / (_MaxSimulationBBox.z - _MinSimulationBBox.z))));
			float2 simulation_uv7 = appendResult6;
			float2 UV14 = simulation_uv7;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 ase_tanViewDir = mul( ase_worldToTangent, ase_worldViewDir );
			float3 ViewDirTgtSpace14 = ase_tanViewDir;
			float3 SmokeColor14 = _Smokecolor.rgb;
			float3 ShadowColor14 = ( 1.0 - _Shadowcolor ).rgb;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth23 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth23 = abs( ( screenDepth23 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 1.0 ) );
			float3 worldToTangentDir26 = mul( ase_worldToTangent, ( distanceDepth23 * ase_worldViewDir ));
			float MaxDistance14 = length( worldToTangentDir26 );
			float SmokeSmoothness14 = _Smokesmoothness;
			float MaxSimDensity14 = _Maxsimulationdensity;
			float SmokeDensity14 = _Smokedensity;
			float VolumetricThickness14 = _Volumetricthickness;
			float ShadowDensity14 = _Shadowdensity;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 worldToTangentDir29 = normalize( mul( ase_worldToTangent, ase_worldlightDir) );
			float3 LightDirectionTgtSpace14 = worldToTangentDir29;
			float4 localRaymarcher14 = Raymarcher14( SmokeTexture14 , UV14 , ViewDirTgtSpace14 , SmokeColor14 , ShadowColor14 , MaxDistance14 , SmokeSmoothness14 , MaxSimDensity14 , SmokeDensity14 , VolumetricThickness14 , ShadowDensity14 , LightDirectionTgtSpace14 );
			float4 break17 = localRaymarcher14;
			float3 appendResult18 = (float3(break17.x , break17.y , break17.z));
			o.Emission = appendResult18;
			o.Alpha = break17.w;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 screenPos : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
629;195;1793;940;2039.618;-460.2922;1.3;True;False
Node;AmplifyShaderEditor.Vector3Node;3;-2591.453,992.174;Inherit;False;Global;_MinSimulationBBox;_MinSimulationBBox;3;0;Create;True;0;0;False;0;False;0,0,0;-10,0.21,-10;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;1;-2592.453,1158.174;Inherit;False;Global;_MaxSimulationBBox;_MaxSimulationBBox;3;0;Create;True;0;0;False;0;False;0,0,0;10,0.21,10;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-2598.453,815.1739;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;5;-2235.452,1069.174;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;4;-2233.452,868.1739;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;23;-1492.687,918.5661;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;24;-1447.233,1063.636;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;6;-2003.452,864.1739;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1203.833,1020.936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;28;-1019.118,1621.192;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;19;-1062.193,807.2482;Inherit;False;Property;_Shadowcolor;Shadow color;1;0;Create;True;0;0;False;0;False;0.7169812,0.7169812,0.7169812,0;0.8113208,0.6756768,0.3482556,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;26;-1066.533,1016.436;Inherit;False;World;Tangent;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-1811.484,857.7766;Inherit;False;simulation_uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-863.118,1487.292;Inherit;False;Property;_Shadowdensity;Shadow density;8;0;Create;True;0;0;False;0;False;100;22.4;0;250;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;16;-1041.631,414.6512;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;15;-959.3793,276.7725;Inherit;False;7;simulation_uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;27;-824.2329,1042.536;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;29;-705.8184,1602.992;Inherit;False;World;Tangent;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;35;-635.6179,821.6924;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-876.1174,1150.593;Inherit;False;Property;_Smokesmoothness;Smoke smoothness;4;0;Create;True;0;0;False;0;False;0;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-864.4178,1229.893;Inherit;False;Property;_Maxsimulationdensity;Max simulation density;5;0;Create;True;0;0;False;0;False;3;8.67;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-877.4188,1318.292;Inherit;False;Property;_Smokedensity;Smoke density;6;0;Create;True;0;0;False;0;False;100;100;0;250;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-1103.195,591.1328;Inherit;False;Property;_Smokecolor;Smoke color;0;0;Create;True;0;0;False;0;False;0.7169812,0.7169812,0.7169812,0;0.764151,0.764151,0.764151,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;34;-864.4176,1404.092;Inherit;False;Property;_Volumetricthickness;Volumetric thickness;7;0;Create;True;0;0;False;0;False;0.05;0.05;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-968.7142,70.56003;Inherit;True;Global;_SmokeTexture;_SmokeTexture;3;0;Create;True;0;0;False;0;False;None;;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CustomExpressionNode;14;-255.7329,717.1505;Inherit;False;return raymarch(UV, SmokeTexture, ViewDirTgtSpace, SmokeColor, ShadowColor, MaxDistance, SmokeSmoothness, MaxSimDensity, SmokeDensity, VolumetricThickness, ShadowDensity, LightDirectionTgtSpace)@;4;False;12;True;SmokeTexture;SAMPLER2D;;In;;Inherit;False;True;UV;FLOAT2;0,0;In;;Inherit;False;True;ViewDirTgtSpace;FLOAT3;0,0,0;In;;Inherit;False;True;SmokeColor;FLOAT3;0,0,0;In;;Inherit;False;True;ShadowColor;FLOAT3;0,0,0;In;;Inherit;False;True;MaxDistance;FLOAT;0;In;;Inherit;False;True;SmokeSmoothness;FLOAT;0;In;;Inherit;False;True;MaxSimDensity;FLOAT;0;In;;Inherit;False;True;SmokeDensity;FLOAT;0;In;;Inherit;False;True;VolumetricThickness;FLOAT;0;In;;Inherit;False;True;ShadowDensity;FLOAT;0;In;;Inherit;False;True;LightDirectionTgtSpace;FLOAT3;0,0,0;In;;Inherit;False;Raymarcher;True;False;0;12;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;17;-73.9324,456.851;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DepthFade;12;-1502.105,-110.8818;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1177.861,-182.7729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;11;-972.3049,-294.8818;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;250.6758,419.6551;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;8;-1606.138,-337.072;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;428.1,314.1;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AnimatedFog;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;1;Include;;True;c42692a3a4c772140826d3d4f6466a71;Custom;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;2;3
WireConnection;5;1;3;3
WireConnection;5;2;1;3
WireConnection;4;0;2;1
WireConnection;4;1;3;1
WireConnection;4;2;1;1
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;26;0;25;0
WireConnection;7;0;6;0
WireConnection;27;0;26;0
WireConnection;29;0;28;0
WireConnection;35;0;19;0
WireConnection;14;0;9;0
WireConnection;14;1;15;0
WireConnection;14;2;16;0
WireConnection;14;3;10;0
WireConnection;14;4;35;0
WireConnection;14;5;27;0
WireConnection;14;6;30;0
WireConnection;14;7;31;0
WireConnection;14;8;32;0
WireConnection;14;9;34;0
WireConnection;14;10;33;0
WireConnection;14;11;29;0
WireConnection;17;0;14;0
WireConnection;13;0;8;1
WireConnection;13;1;12;0
WireConnection;11;0;13;0
WireConnection;18;0;17;0
WireConnection;18;1;17;1
WireConnection;18;2;17;2
WireConnection;0;2;18;0
WireConnection;0;9;17;3
ASEEND*/
//CHKSM=484221BC357B3715BEC44A774964E7337911597B