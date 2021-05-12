// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AnimatedGrass"
{
	Properties
	{
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_Primarycolor("Primary color", Color) = (0.2087931,0.8679245,0.3234242,0)
		_Secondarycolor("Secondary color", Color) = (0.2087931,0.8679245,0.3234242,0)
		_Flattening("Flattening", Range( 0 , 2)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Stretching("Stretching", Range( 0 , 2)) = 1
		_MaxVelocityMagnitude("MaxVelocityMagnitude", Float) = 0
		_NoiseScale("NoiseScale", Float) = 0
		_Transmission("Transmission", Float) = 0
		_Trans("Trans", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
			half3 Translucency;
		};

		uniform float3 _MinSimulationBBox;
		uniform float3 _MaxSimulationBBox;
		uniform float _NoiseScale;
		uniform sampler2D _VelocityTexture;
		uniform float _Stretching;
		uniform float _MaxVelocityMagnitude;
		uniform float _Flattening;
		uniform float4 _Primarycolor;
		uniform float4 _Secondarycolor;
		uniform float _Smoothness;
		uniform float _Transmission;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform float _Trans;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult21 = (float2((1.0 + (ase_worldPos.x - _MinSimulationBBox.x) * (0.0 - 1.0) / (_MaxSimulationBBox.x - _MinSimulationBBox.x)) , (1.0 + (ase_worldPos.z - _MinSimulationBBox.z) * (0.0 - 1.0) / (_MaxSimulationBBox.z - _MinSimulationBBox.z))));
			float2 simulation_uv31 = appendResult21;
			float simplePerlin2D28 = snoise( simulation_uv31*_NoiseScale );
			simplePerlin2D28 = simplePerlin2D28*0.5 + 0.5;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult40 = (float4(0.0 , ( ( ( ( simplePerlin2D28 + 1.0 ) * 0.5 ) * ase_vertex3Pos.y ) - ase_vertex3Pos.y ) , 0.0 , 0.0));
			float4 tex2DNode2 = tex2Dlod( _VelocityTexture, float4( simulation_uv31, 0, 0.0) );
			float2 appendResult5 = (float2(tex2DNode2.r , tex2DNode2.g));
			float temp_output_6_0 = length( appendResult5 );
			float temp_output_25_0 = ( _MaxVelocityMagnitude / max( temp_output_6_0 , _MaxVelocityMagnitude ) );
			float4 appendResult4 = (float4(( tex2DNode2.r * _Stretching * temp_output_25_0 ) , ( _Flattening * -1.0 * temp_output_6_0 * temp_output_25_0 * ase_vertex3Pos.y ) , ( tex2DNode2.g * _Stretching * temp_output_25_0 ) , 0.0));
			float temp_output_14_0 = ( 1.0 - v.texcoord.xy.y );
			float3 worldToObjDir15 = mul( unity_WorldToObject, float4( ( appendResult4 * float4( -1,1,-1,0 ) * ( temp_output_14_0 * temp_output_14_0 ) ).xyz, 0 ) ).xyz;
			v.vertex.xyz += ( appendResult40 + float4( worldToObjDir15 , 0.0 ) ).xyz;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c + d;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult21 = (float2((1.0 + (ase_worldPos.x - _MinSimulationBBox.x) * (0.0 - 1.0) / (_MaxSimulationBBox.x - _MinSimulationBBox.x)) , (1.0 + (ase_worldPos.z - _MinSimulationBBox.z) * (0.0 - 1.0) / (_MaxSimulationBBox.z - _MinSimulationBBox.z))));
			float2 simulation_uv31 = appendResult21;
			float simplePerlin2D28 = snoise( simulation_uv31*_NoiseScale );
			simplePerlin2D28 = simplePerlin2D28*0.5 + 0.5;
			float4 lerpResult33 = lerp( _Primarycolor , _Secondarycolor , simplePerlin2D28);
			o.Albedo = lerpResult33.rgb;
			o.Smoothness = _Smoothness;
			float3 temp_cast_1 = (_Transmission).xxx;
			o.Transmission = temp_cast_1;
			float3 temp_cast_2 = (_Trans).xxx;
			o.Translucency = temp_cast_2;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1989;54;1920;1149;-596.3593;584.4377;1;True;False
Node;AmplifyShaderEditor.Vector3Node;17;-2435.912,505.9143;Inherit;False;Global;_MaxSimulationBBox;_MaxSimulationBBox;3;0;Create;True;0;0;False;0;False;0,0,0;10,0.21,10;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;18;-2401.912,178.9142;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;16;-2434.912,339.9142;Inherit;False;Global;_MinSimulationBBox;_MinSimulationBBox;3;0;Create;True;0;0;False;0;False;0,0,0;-10,0.21,-10;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;19;-2076.911,215.9142;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;20;-2078.911,416.9142;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-1846.911,211.9142;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1637.944,206.5169;Inherit;False;simulation_uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1646.64,-9.535652;Inherit;True;Global;_VelocityTexture;VelocityTexture;7;0;Create;True;0;0;False;0;False;None;;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;2;-1259.745,148.5805;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;5;-813,77.5;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-784.272,591.9499;Inherit;False;Property;_MaxVelocityMagnitude;MaxVelocityMagnitude;13;0;Create;True;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;6;-647.2725,61.94992;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;19.9498,-591.6728;Inherit;False;31;simulation_uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;29;24.42978,-465.7694;Inherit;False;Property;_NoiseScale;NoiseScale;14;0;Create;True;0;0;False;0;False;0;17.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;24;-483.7375,494.3891;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;28;272.2968,-503.5144;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;26;-750.738,-136.6109;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-16.56198,540.1743;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;38;468.6134,-392.6741;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1041.272,427.9499;Inherit;False;Property;_Stretching;Stretching;12;0;Create;True;0;0;False;0;False;1;0.87;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-776.2725,-276.0501;Inherit;False;Property;_Flattening;Flattening;10;0;Create;True;0;0;False;0;False;0;0.87;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-275.7375,585.3891;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;617.982,-339.8994;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;218.0818,588.7727;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-33.27249,-168.0501;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;36;381.6133,-191.6742;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-25.27252,188.9499;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-28.27252,316.9499;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;478.262,531.3891;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;386.3539,191.3229;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;772.6134,-267.6741;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;593.0814,217.7728;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;-1,1,-1,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;956.6134,-181.6742;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;771.9983,-716.1263;Inherit;False;Property;_Secondarycolor;Secondary color;9;0;Create;True;0;0;False;0;False;0.2087931,0.8679245,0.3234242,0;0.8867924,0.5112029,0.2551619,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;40;1117.982,-33.89935;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TransformDirectionNode;15;784.082,212.7728;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;1;917.939,-851.9294;Inherit;False;Property;_Primarycolor;Primary color;8;0;Create;True;0;0;False;0;False;0.2087931,0.8679245,0.3234242,0;0.2087931,0.8679245,0.3234242,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;1248.359,-124.4377;Inherit;False;Property;_Transmission;Transmission;15;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;1306.143,116.5845;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;33;1131.992,-623.683;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;43;1265.359,-11.43774;Inherit;False;Property;_Trans;Trans;16;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;1287.359,-222.4377;Inherit;False;Property;_Smoothness;Smoothness;11;0;Create;True;0;0;False;0;False;0;0.24;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1764.354,-258.177;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AnimatedGrass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;0;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;19;0;18;1
WireConnection;19;1;16;1
WireConnection;19;2;17;1
WireConnection;20;0;18;3
WireConnection;20;1;16;3
WireConnection;20;2;17;3
WireConnection;21;0;19;0
WireConnection;21;1;20;0
WireConnection;31;0;21;0
WireConnection;2;0;3;0
WireConnection;2;1;31;0
WireConnection;5;0;2;1
WireConnection;5;1;2;2
WireConnection;6;0;5;0
WireConnection;24;0;6;0
WireConnection;24;1;22;0
WireConnection;28;0;30;0
WireConnection;28;1;29;0
WireConnection;38;0;28;0
WireConnection;25;0;22;0
WireConnection;25;1;24;0
WireConnection;41;0;38;0
WireConnection;14;0;12;2
WireConnection;7;0;8;0
WireConnection;7;2;6;0
WireConnection;7;3;25;0
WireConnection;7;4;26;2
WireConnection;10;0;2;1
WireConnection;10;1;9;0
WireConnection;10;2;25;0
WireConnection;11;0;2;2
WireConnection;11;1;9;0
WireConnection;11;2;25;0
WireConnection;27;0;14;0
WireConnection;27;1;14;0
WireConnection;4;0;10;0
WireConnection;4;1;7;0
WireConnection;4;2;11;0
WireConnection;37;0;41;0
WireConnection;37;1;36;2
WireConnection;13;0;4;0
WireConnection;13;2;27;0
WireConnection;39;0;37;0
WireConnection;39;1;36;2
WireConnection;40;1;39;0
WireConnection;15;0;13;0
WireConnection;35;0;40;0
WireConnection;35;1;15;0
WireConnection;33;0;1;0
WireConnection;33;1;32;0
WireConnection;33;2;28;0
WireConnection;0;0;33;0
WireConnection;0;4;44;0
WireConnection;0;6;42;0
WireConnection;0;7;43;0
WireConnection;0;11;35;0
ASEEND*/
//CHKSM=DECCF8C86DFB739AA1C71780F2D444547F4F058D