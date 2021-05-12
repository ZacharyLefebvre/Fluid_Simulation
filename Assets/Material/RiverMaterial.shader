// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RiverMaterial"
{
	Properties
	{
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_Watercolor("Water color", Color) = (0.2055892,0.5338864,0.7924528,0)
		[HDR]_Foamcolor("Foam color", Color) = (0.754717,0.754717,0.754717,0)
		_Refraction("Refraction", Range( 0 , 2)) = 0
		_Normalintensity("Normal intensity", Float) = 0
		_Watersmoothness("Water smoothness", Range( 0 , 1)) = 0
		_Foamsmoothness("Foam smoothness", Range( 0 , 1)) = 0
		_Waves("Waves", 2D) = "bump" {}
		_Foamnormal("Foam normal", 2D) = "bump" {}
		_Foam("Foam", 2D) = "white" {}
		_Wavestiling("Waves tiling", Float) = 0
		_Foamtiling("Foam tiling", Float) = 0
		_Wavesscale("Waves scale", Range( 0 , 2)) = 0
		_Wavesflowspeed("Waves flow speed", Range( 0 , 2)) = 0
		_Flowintensity("Flow intensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
		};

		uniform sampler2D _Waves;
		uniform float _Wavestiling;
		uniform sampler2D _VelocityTexture;
		uniform float4 _VelocityTexture_ST;
		uniform float _Wavesflowspeed;
		uniform float _Flowintensity;
		uniform float _Wavesscale;
		uniform sampler2D _SmokeTexture;
		uniform float4 _SmokeTexture_ST;
		float4 _SmokeTexture_TexelSize;
		uniform float _Normalintensity;
		uniform sampler2D _Foamnormal;
		uniform float _Foamtiling;
		uniform float4 _Watercolor;
		uniform float4 _Foamcolor;
		uniform sampler2D _Foam;
		uniform float _Watersmoothness;
		uniform float _Foamsmoothness;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _Refraction;

		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) );
			float2 cameraRefraction = float2( refractionOffset.x, refractionOffset.y );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			color.rgb = color.rgb + Refraction( i, o, _Refraction, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 temp_cast_0 = (_Wavestiling).xx;
			float2 uv_TexCoord36 = i.uv_texcoord * temp_cast_0;
			float2 uv_VelocityTexture = i.uv_texcoord * _VelocityTexture_ST.xy + _VelocityTexture_ST.zw;
			float4 tex2DNode43 = tex2D( _VelocityTexture, uv_VelocityTexture );
			float2 appendResult47 = (float2(tex2DNode43.r , tex2DNode43.g));
			float mulTime48 = _Time.y * _Wavesflowspeed;
			float FractTime65 = frac( mulTime48 );
			float2 temp_output_51_0 = ( appendResult47 * float2( -1,-1 ) * FractTime65 * _Flowintensity );
			float2 temp_output_55_0 = ( appendResult47 * float2( -1,-1 ) * frac( ( mulTime48 + 0.5 ) ) * _Flowintensity );
			float temp_output_70_0 = abs( ( 1.0 - ( FractTime65 * 2.0 ) ) );
			float3 lerpResult63 = lerp( UnpackScaleNormal( tex2D( _Waves, ( uv_TexCoord36 + temp_output_51_0 ) ), _Wavesscale ) , UnpackScaleNormal( tex2D( _Waves, ( uv_TexCoord36 + temp_output_55_0 ) ), _Wavesscale ) , temp_output_70_0);
			float3 normalizeResult64 = normalize( lerpResult63 );
			float3 HighFreqNormal38 = normalizeResult64;
			float2 uv_SmokeTexture = i.uv_texcoord * _SmokeTexture_ST.xy + _SmokeTexture_ST.zw;
			float2 appendResult15 = (float2(( uv_SmokeTexture.x - _SmokeTexture_TexelSize.x ) , uv_SmokeTexture.y));
			float2 appendResult14 = (float2(( uv_SmokeTexture.x + _SmokeTexture_TexelSize.x ) , uv_SmokeTexture.y));
			float2 appendResult22 = (float2(uv_SmokeTexture.x , ( uv_SmokeTexture.y - _SmokeTexture_TexelSize.y )));
			float2 appendResult21 = (float2(uv_SmokeTexture.x , ( uv_SmokeTexture.y + _SmokeTexture_TexelSize.y )));
			float3 appendResult30 = (float3(( ( tex2D( _SmokeTexture, appendResult15 ).r - tex2D( _SmokeTexture, appendResult14 ).r ) * _Normalintensity ) , ( _Normalintensity * ( tex2D( _SmokeTexture, appendResult22 ).r - tex2D( _SmokeTexture, appendResult21 ).r ) ) , 1.0));
			float3 normalizeResult31 = normalize( appendResult30 );
			float3 LowFreqNormal34 = normalizeResult31;
			float2 temp_cast_1 = (_Foamtiling).xx;
			float2 uv_TexCoord73 = i.uv_texcoord * temp_cast_1;
			float2 temp_output_74_0 = ( uv_TexCoord73 + temp_output_51_0 );
			float2 temp_output_75_0 = ( uv_TexCoord73 + temp_output_55_0 );
			float3 lerpResult96 = lerp( UnpackNormal( tex2D( _Foamnormal, temp_output_74_0 ) ) , UnpackNormal( tex2D( _Foamnormal, temp_output_75_0 ) ) , temp_output_70_0);
			float temp_output_86_0 = saturate( tex2D( _SmokeTexture, uv_SmokeTexture ).r );
			float3 lerpResult97 = lerp( float3(0,0,1) , lerpResult96 , temp_output_86_0);
			float3 normalizeResult100 = normalize( lerpResult97 );
			float3 FoamNormal99 = normalizeResult100;
			o.Normal = BlendNormals( BlendNormals( HighFreqNormal38 , LowFreqNormal34 ) , FoamNormal99 );
			float lerpResult78 = lerp( tex2D( _Foam, temp_output_74_0 ).r , tex2D( _Foam, temp_output_75_0 ).r , temp_output_70_0);
			float Foam79 = ( temp_output_86_0 * lerpResult78 );
			float4 lerpResult81 = lerp( _Watercolor , _Foamcolor , Foam79);
			o.Albedo = lerpResult81.rgb;
			float lerpResult88 = lerp( _Watersmoothness , _Foamsmoothness , Foam79);
			o.Smoothness = lerpResult88;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth3 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth3 = saturate( abs( ( screenDepth3 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 3.0 ) ) );
			float lerpResult91 = lerp( distanceDepth3 , 1.0 , Foam79);
			o.Alpha = lerpResult91;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred 

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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
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
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
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
1786;256;1601;795;1439.597;2763.318;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;50;-2131.969,-1441.353;Inherit;False;Property;_Wavesflowspeed;Waves flow speed;16;0;Create;True;0;0;False;0;False;0;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;5;-2952.36,-517.585;Inherit;True;Global;_SmokeTexture;_SmokeTexture;5;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode;48;-1823.594,-1442.095;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;49;-1577.693,-1445.994;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;46;-1878.204,-1672.13;Inherit;True;Global;_VelocityTexture;_VelocityTexture;9;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2655.959,-646.4849;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexelSizeNode;11;-2650.759,-503.1852;Inherit;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;43;-1598.204,-1666.13;Inherit;True;Property;_TextureSample5;Texture Sample 5;8;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-2312.971,-362.1857;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-2308.959,-742.485;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-2316.959,-634.4849;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1376.391,-1447.219;Inherit;False;FractTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1470.729,-1196.707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2648.474,-325.2751;Inherit;False;HeightTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-2312.271,-470.0855;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-2152.959,-622.4849;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-2154.872,-12.18597;Inherit;False;16;HeightTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FractNode;58;-1320.678,-1194.686;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;47;-1290.094,-1635.494;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-2164.074,-841.6749;Inherit;False;16;HeightTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1335.716,-1329.057;Inherit;False;Property;_Flowintensity;Flow intensity;17;0;Create;True;0;0;False;0;False;0;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-2145.959,-740.485;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2151.792,-475.3432;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1553.849,-1824.648;Inherit;False;Property;_Wavestiling;Waves tiling;13;0;Create;True;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-403.0153,-1201.643;Inherit;False;65;FractTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-2145.692,-360.2433;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1563.423,-2277.453;Inherit;False;Property;_Foamtiling;Foam tiling;14;0;Create;True;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-1894.249,-568.9946;Inherit;True;Property;_TextureSample1;Texture Sample 0;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-1909.259,-18.78497;Inherit;True;Property;_TextureSample3;Texture Sample 0;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-1891.259,-808.6848;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-1893.658,-228.385;Inherit;True;Property;_TextureSample2;Texture Sample 0;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1074.299,-1299.448;Inherit;False;4;4;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1093.717,-1634.558;Inherit;False;4;4;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-1338.849,-1829.648;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-188.3758,-1193.72;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;73;-1328.423,-2276.453;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-854.4748,-1413.906;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;35;-685.0488,-1904.849;Inherit;True;Property;_Waves;Waves;10;0;Create;True;0;0;False;0;False;None;44e241897024fbf4583457e66f3ac78d;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-1490.296,-107.1913;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-122.0205,-2628.968;Inherit;False;16;HeightTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1584.896,-380.3913;Inherit;False;Property;_Normalintensity;Normal intensity;6;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;69;-32.37581,-1191.72;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-1498.296,-626.1912;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-757.6609,-1582.797;Inherit;False;Property;_Wavesscale;Waves scale;15;0;Create;True;0;0;False;0;False;0;1.347;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-882.6161,-1721.456;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;93;-746.1257,-3051.814;Inherit;True;Property;_Foamnormal;Foam normal;11;0;Create;True;0;0;False;0;False;None;937d398465498494e9d5ceb89a7a94bb;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-825.5792,-2139.159;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-815.6791,-2317.859;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;83;108.1439,-2626.777;Inherit;True;Property;_TextureSample9;Texture Sample 9;12;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;95;-358.6698,-2885.611;Inherit;True;Property;_TextureSample11;Texture Sample 8;13;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;94;-350.9938,-3124.307;Inherit;True;Property;_TextureSample10;Texture Sample 7;12;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;70;138.6242,-1195.72;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1326.296,-133.1913;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;61;-374.2093,-1424.538;Inherit;True;Property;_TextureSample6;Texture Sample 4;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1318.296,-611.1912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-368.3817,-1659.633;Inherit;True;Property;_TextureSample4;Texture Sample 4;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;71;-756.2296,-2543.525;Inherit;True;Property;_Foam;Foam;12;0;Create;True;0;0;False;0;False;None;b45cae56e93fc10489a2bd1e387789d7;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;30;-1095.296,-356.1913;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;98;394.0265,-3215.195;Inherit;False;Constant;_Vector0;Vector 0;17;0;Create;True;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;96;299.3055,-3025.58;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;86;436.2438,-2600.877;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;77;-384.2458,-2191.041;Inherit;True;Property;_TextureSample8;Texture Sample 8;13;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;76;-364.7458,-2435.441;Inherit;True;Property;_TextureSample7;Texture Sample 7;12;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;63;437.5913,-1498.637;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;97;628.8264,-3058.594;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;64;626.0915,-1507.738;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;78;188.6181,-2278.868;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;31;-929.6066,-357.1087;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-744.7183,-371.7886;Inherit;False;LowFreqNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;776.5439,-2345.977;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;100;845.0189,-3045.681;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;830.3513,-1508.948;Inherit;False;HighFreqNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;637.0547,-474.4249;Inherit;False;34;LowFreqNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;642.1257,-618.1152;Inherit;False;38;HighFreqNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;1057.321,-3039.552;Inherit;False;FoamNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;950.4539,-2283.749;Inherit;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;835.1414,-190.1968;Inherit;False;99;FoamNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;1156.57,298.6291;Inherit;False;79;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;1069.726,145.4243;Inherit;False;Property;_Foamsmoothness;Foam smoothness;8;0;Create;True;0;0;False;0;False;0;0.499;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;41;916.0267,-561.4354;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;1415.311,-473.7525;Inherit;False;79;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;1057.517,37.37105;Inherit;False;Property;_Watersmoothness;Water smoothness;7;0;Create;True;0;0;False;0;False;0;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;1437.726,669.4243;Inherit;False;79;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;1364.302,-825.735;Inherit;False;Property;_Watercolor;Water color;2;0;Create;True;0;0;False;0;False;0.2055892,0.5338864,0.7924528,0;0.2055892,0.5338864,0.7924528,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;80;1362.311,-655.7525;Inherit;False;Property;_Foamcolor;Foam color;3;1;[HDR];Create;True;0;0;False;0;False;0.754717,0.754717,0.754717,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;3;1422.533,401.677;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;101;1240.741,-313.6967;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;91;1733.726,602.4243;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;1476.533,257.6771;Inherit;False;Property;_Refraction;Refraction;4;0;Create;True;0;0;False;0;False;0;1.281;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;81;1714.311,-658.7525;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;88;1476.57,108.6291;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2072.802,-52.23497;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;RiverMaterial;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;0;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;48;0;50;0
WireConnection;49;0;48;0
WireConnection;10;2;5;0
WireConnection;11;0;5;0
WireConnection;43;0;46;0
WireConnection;20;0;10;2
WireConnection;20;1;11;2
WireConnection;12;0;10;1
WireConnection;12;1;11;1
WireConnection;13;0;10;1
WireConnection;13;1;11;1
WireConnection;65;0;49;0
WireConnection;60;0;48;0
WireConnection;16;0;5;0
WireConnection;19;0;10;2
WireConnection;19;1;11;2
WireConnection;15;0;13;0
WireConnection;15;1;10;2
WireConnection;58;0;60;0
WireConnection;47;0;43;1
WireConnection;47;1;43;2
WireConnection;14;0;12;0
WireConnection;14;1;10;2
WireConnection;21;0;10;1
WireConnection;21;1;19;0
WireConnection;22;0;10;1
WireConnection;22;1;20;0
WireConnection;7;0;17;0
WireConnection;7;1;15;0
WireConnection;9;0;18;0
WireConnection;9;1;22;0
WireConnection;6;0;17;0
WireConnection;6;1;14;0
WireConnection;8;0;18;0
WireConnection;8;1;21;0
WireConnection;55;0;47;0
WireConnection;55;2;58;0
WireConnection;55;3;52;0
WireConnection;51;0;47;0
WireConnection;51;2;65;0
WireConnection;51;3;52;0
WireConnection;36;0;37;0
WireConnection;68;0;67;0
WireConnection;73;0;72;0
WireConnection;62;0;36;0
WireConnection;62;1;55;0
WireConnection;24;0;9;1
WireConnection;24;1;8;1
WireConnection;69;0;68;0
WireConnection;26;0;7;1
WireConnection;26;1;6;1
WireConnection;53;0;36;0
WireConnection;53;1;51;0
WireConnection;75;0;73;0
WireConnection;75;1;55;0
WireConnection;74;0;73;0
WireConnection;74;1;51;0
WireConnection;83;0;87;0
WireConnection;95;0;93;0
WireConnection;95;1;75;0
WireConnection;94;0;93;0
WireConnection;94;1;74;0
WireConnection;70;0;69;0
WireConnection;28;0;29;0
WireConnection;28;1;24;0
WireConnection;61;0;35;0
WireConnection;61;1;62;0
WireConnection;61;5;42;0
WireConnection;27;0;26;0
WireConnection;27;1;29;0
WireConnection;33;0;35;0
WireConnection;33;1;53;0
WireConnection;33;5;42;0
WireConnection;30;0;27;0
WireConnection;30;1;28;0
WireConnection;96;0;94;0
WireConnection;96;1;95;0
WireConnection;96;2;70;0
WireConnection;86;0;83;1
WireConnection;77;0;71;0
WireConnection;77;1;75;0
WireConnection;76;0;71;0
WireConnection;76;1;74;0
WireConnection;63;0;33;0
WireConnection;63;1;61;0
WireConnection;63;2;70;0
WireConnection;97;0;98;0
WireConnection;97;1;96;0
WireConnection;97;2;86;0
WireConnection;64;0;63;0
WireConnection;78;0;76;1
WireConnection;78;1;77;1
WireConnection;78;2;70;0
WireConnection;31;0;30;0
WireConnection;34;0;31;0
WireConnection;85;0;86;0
WireConnection;85;1;78;0
WireConnection;100;0;97;0
WireConnection;38;0;64;0
WireConnection;99;0;100;0
WireConnection;79;0;85;0
WireConnection;41;0;39;0
WireConnection;41;1;40;0
WireConnection;101;0;41;0
WireConnection;101;1;102;0
WireConnection;91;0;3;0
WireConnection;91;2;92;0
WireConnection;81;0;1;0
WireConnection;81;1;80;0
WireConnection;81;2;82;0
WireConnection;88;0;32;0
WireConnection;88;1;90;0
WireConnection;88;2;89;0
WireConnection;0;0;81;0
WireConnection;0;1;101;0
WireConnection;0;4;88;0
WireConnection;0;8;2;0
WireConnection;0;9;91;0
ASEEND*/
//CHKSM=836EF1B86218BAF5A58C431315ED0F3E2852A127