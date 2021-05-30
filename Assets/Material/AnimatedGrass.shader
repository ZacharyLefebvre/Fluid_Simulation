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
		_Transmission("Transmission", Float) = 0
		_Trans("Trans", Float) = 0
		_NoiseScale("NoiseScale", Float) = 0
		_NoiseDir("NoiseDir", Vector) = (0,0,0,0)
		_NoiseStrength("NoiseStrength", Vector) = (0,0,0,0)
		_NoiseColorScale("NoiseColorScale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
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

		uniform float _NoiseColorScale;
		uniform float _MaxVelocityMagnitude;
		uniform float3 _NoiseDir;
		uniform float _NoiseScale;
		uniform float2 _NoiseStrength;
		uniform float _Stretching;
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
			float simplePerlin2D28 = snoise( (ase_worldPos).xz*_NoiseColorScale );
			simplePerlin2D28 = simplePerlin2D28*0.5 + 0.5;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult40 = (float4(0.0 , ( ( ( ( simplePerlin2D28 + 1.0 ) * 0.5 ) * ase_vertex3Pos.y ) - ase_vertex3Pos.y ) , 0.0 , 0.0));
			float3 temp_output_51_0 = ( ase_worldPos + ( _Time.y * _NoiseDir ) );
			float simplePerlin2D46 = snoise( (temp_output_51_0).xz*_NoiseScale );
			float3 break59 = temp_output_51_0;
			float2 appendResult60 = (float2(break59.z , break59.x));
			float simplePerlin2D58 = snoise( appendResult60*_NoiseScale );
			float2 appendResult61 = (float2(simplePerlin2D46 , simplePerlin2D58));
			float2 temp_output_67_0 = ( appendResult61 * _NoiseStrength );
			float temp_output_6_0 = length( temp_output_67_0 );
			float temp_output_25_0 = ( _MaxVelocityMagnitude / max( _MaxVelocityMagnitude , temp_output_6_0 ) );
			float2 break63 = temp_output_67_0;
			float4 appendResult4 = (float4(( temp_output_25_0 * break63.x * _Stretching ) , ( _Flattening * -1.0 * ase_vertex3Pos.y * temp_output_6_0 * temp_output_25_0 ) , ( temp_output_25_0 * _Stretching * break63.y ) , 0.0));
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
			float simplePerlin2D28 = snoise( (ase_worldPos).xz*_NoiseColorScale );
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
0;73;2560;928;1527.653;-65.66299;1;True;False
Node;AmplifyShaderEditor.Vector3Node;53;-2807.268,1009.242;Inherit;False;Property;_NoiseDir;NoiseDir;16;0;Create;True;0;0;False;0;False;0,0,0;0.5,0,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;50;-2824.106,910.1061;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;49;-2652.106,752.1059;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-2609.106,940.106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-2416.106,854.1061;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;59;-2264.219,989.0549;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;60;-2034.017,996.3549;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2080.317,855.8389;Inherit;False;Property;_NoiseScale;NoiseScale;15;0;Create;True;0;0;False;0;False;0;0.78;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;56;-2266.265,641.2422;Inherit;True;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;46;-1864.552,652.9858;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;58;-1865.917,1001.355;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;-1573.901,794.8159;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;68;-1547.351,1034.41;Inherit;False;Property;_NoiseStrength;NoiseStrength;17;0;Create;True;0;0;False;0;False;0,0;0.25,0.25;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1282.351,885.4095;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;64;-161.5785,-425.9474;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;66;22.42151,-414.9474;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;6;-908.7954,778.034;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;42.03806,-199.0432;Inherit;False;Property;_NoiseColorScale;NoiseColorScale;18;0;Create;True;0;0;False;0;False;0;17.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-981.3834,609.7864;Inherit;False;Property;_MaxVelocityMagnitude;MaxVelocityMagnitude;12;0;Create;True;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;28;234.9053,-309.7882;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;24;-602.3512,733.8551;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-220.7376,1088.656;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;63;-930.4906,956.2507;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-398.3532,629.0687;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-695.6136,276.0244;Inherit;False;Property;_Flattening;Flattening;9;0;Create;True;0;0;False;0;False;0;0.87;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;468.9935,-145.2701;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;26;-600.0792,415.4635;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-534.7107,886.4474;Inherit;False;Property;_Stretching;Stretching;11;0;Create;True;0;0;False;0;False;1;0.09;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;17.45025,1137.254;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-172.0224,935.7729;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;36;560.9304,-26.25658;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;616.0619,-143.5954;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-175.7481,759.0107;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-211.3592,398.2439;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;199.6563,1124.174;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;810.2302,-123.756;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;115.785,766.4282;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;981.2296,-1.956474;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;427.4725,818.0999;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;-1,1,-1,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TransformDirectionNode;15;618.473,813.0999;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;32;1100.898,-502.9264;Inherit;False;Property;_Secondarycolor;Secondary color;8;0;Create;True;0;0;False;0;False;0.2087931,0.8679245,0.3234242,0;0.7550451,0.986,0.1598919,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;40;1156.498,-24.98173;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;1;1110.339,-718.0296;Inherit;False;Property;_Primarycolor;Primary color;7;0;Create;True;0;0;False;0;False;0.2087931,0.8679245,0.3234242,0;0.1563939,0.794,0.2646666,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;1430.36,-213.3377;Inherit;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;False;0;False;0;0.482;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;1394.822,68.5881;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;43;1566.96,-42.63773;Inherit;False;Property;_Trans;Trans;14;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;33;1516.792,-366.2829;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;1536.959,-123.1377;Inherit;False;Property;_Transmission;Transmission;13;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-2556.869,158.9186;Inherit;False;simulation_uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1764.354,-258.177;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AnimatedGrass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;0;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;50;0
WireConnection;52;1;53;0
WireConnection;51;0;49;0
WireConnection;51;1;52;0
WireConnection;59;0;51;0
WireConnection;60;0;59;2
WireConnection;60;1;59;0
WireConnection;56;0;51;0
WireConnection;46;0;56;0
WireConnection;46;1;62;0
WireConnection;58;0;60;0
WireConnection;58;1;62;0
WireConnection;61;0;46;0
WireConnection;61;1;58;0
WireConnection;67;0;61;0
WireConnection;67;1;68;0
WireConnection;66;0;64;0
WireConnection;6;0;67;0
WireConnection;28;0;66;0
WireConnection;28;1;29;0
WireConnection;24;0;22;0
WireConnection;24;1;6;0
WireConnection;63;0;67;0
WireConnection;25;0;22;0
WireConnection;25;1;24;0
WireConnection;38;0;28;0
WireConnection;14;0;12;2
WireConnection;11;0;25;0
WireConnection;11;1;9;0
WireConnection;11;2;63;1
WireConnection;41;0;38;0
WireConnection;10;0;25;0
WireConnection;10;1;63;0
WireConnection;10;2;9;0
WireConnection;7;0;8;0
WireConnection;7;2;26;2
WireConnection;7;3;6;0
WireConnection;7;4;25;0
WireConnection;27;0;14;0
WireConnection;27;1;14;0
WireConnection;37;0;41;0
WireConnection;37;1;36;2
WireConnection;4;0;10;0
WireConnection;4;1;7;0
WireConnection;4;2;11;0
WireConnection;39;0;37;0
WireConnection;39;1;36;2
WireConnection;13;0;4;0
WireConnection;13;2;27;0
WireConnection;15;0;13;0
WireConnection;40;1;39;0
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
//CHKSM=D32D73851A7BBB429C2AA088B312907268CD697E