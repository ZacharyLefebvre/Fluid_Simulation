// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pond"
{
	Properties
	{
		[NoScaleOffset]_Heightmap("Heightmap", 2D) = "white" {}
		_WaterColor("WaterColor", Color) = (0,0,0,0)
		_Opacity("Opacity", Range( 0 , 1)) = 0
		_MovementGlobalAmplitude("MovementGlobalAmplitude", Range( 0 , 0.5)) = 0
		_WaterSize("WaterSize", Range( 0 , 1)) = 0
		_RippleSize("RippleSize", Range( 0 , 1)) = 0
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 25
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#pragma target 5.0
		#pragma surface surf Standard alpha:fade keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _SmokeTexture;
		uniform float4 _SmokeTexture_ST;
		uniform float _WaterSize;
		uniform sampler2D WaterRipples;
		SamplerState samplerWaterRipples;
		uniform float4 WaterRipples_ST;
		uniform float InjectionForce;
		uniform float _RippleSize;
		uniform float _MovementGlobalAmplitude;
		uniform float4 _WaterColor;
		uniform sampler2D _Heightmap;
		SamplerState sampler_Heightmap;
		uniform float _Opacity;
		uniform float _TessValue;

		float4 tessFunction( )
		{
			return _TessValue;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_SmokeTexture = v.texcoord * _SmokeTexture_ST.xy + _SmokeTexture_ST.zw;
			float2 uvWaterRipples = v.texcoord * WaterRipples_ST.xy + WaterRipples_ST.zw;
			float temp_output_32_0 = ( ( tex2Dlod( _SmokeTexture, float4( uv_SmokeTexture, 0, 0.0) ).r * _WaterSize ) + ( ( tex2Dlod( WaterRipples, float4( uvWaterRipples, 0, 0.0) ).r / ( max( InjectionForce , 0.001 ) * 2.0 ) ) * _RippleSize ) );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( temp_output_32_0 * ase_vertexNormal * _MovementGlobalAmplitude );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_SmokeTexture = i.uv_texcoord * _SmokeTexture_ST.xy + _SmokeTexture_ST.zw;
			float2 uvWaterRipples = i.uv_texcoord * WaterRipples_ST.xy + WaterRipples_ST.zw;
			float temp_output_32_0 = ( ( tex2D( _SmokeTexture, uv_SmokeTexture ).r * _WaterSize ) + ( ( tex2D( WaterRipples, uvWaterRipples ).r / ( max( InjectionForce , 0.001 ) * 2.0 ) ) * _RippleSize ) );
			o.Albedo = ( _WaterColor * (saturate( temp_output_32_0 )*0.25 + 0.75) ).rgb;
			float2 uv_Heightmap24 = i.uv_texcoord;
			float smoothstepResult27 = smoothstep( 0.0 , 1.5 , ( 1.0 - tex2D( _Heightmap, uv_Heightmap24 ).r ));
			float Opacity28 = ( smoothstepResult27 * _Opacity );
			o.Alpha = Opacity28;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1081;73;653;642;2490.298;281.3569;1.429576;True;False
Node;AmplifyShaderEditor.RangedFloatNode;39;-1913.436,278.035;Inherit;False;Global;InjectionForce;InjectionForce;10;0;Create;True;0;0;False;0;False;0;209.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;40;-1658.436,209.035;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1907.65,-149.5826;Inherit;True;Global;_SmokeTexture;_SmokeTexture;4;0;Create;False;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;30;-2061.044,84.09399;Inherit;True;Global;WaterRipples;WaterRipples;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1510.436,218.035;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-1320.436,160.035;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1513.813,336.4424;Inherit;False;Property;_RippleSize;RippleSize;8;0;Create;True;0;0;False;0;False;0;0.025;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1591.759,65.39481;Inherit;False;Property;_WaterSize;WaterSize;7;0;Create;True;0;0;False;0;False;0;0.33;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1671.884,-142.8666;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;24;-2391.561,445.8028;Inherit;True;Property;_Heightmap;Heightmap;0;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;295b997eccbc9d5469dacd0b1bc7f615;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1257.759,-54.60519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-2074.31,506.2749;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1168.813,240.4424;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1998.109,647.9648;Inherit;False;Property;_Opacity;Opacity;3;0;Create;True;0;0;False;0;False;0;0.48;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;27;-1892.014,509.1594;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-1000.881,126.8514;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1591.242,500.9212;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;21;-871.7986,4.240997;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;5;-583.1766,320.1632;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-1406.536,499.451;Inherit;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;8;-875.2381,-285.2788;Inherit;False;Property;_WaterColor;WaterColor;1;0;Create;True;0;0;False;0;False;0,0,0,0;0.6839622,0.967977,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;23;-682.8861,3.862579;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-587.3431,480.153;Inherit;False;Property;_MovementGlobalAmplitude;MovementGlobalAmplitude;6;0;Create;True;0;0;False;0;False;0;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-406.6718,-143.3285;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SurfaceDepthNode;16;-1207.109,1103.629;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;11;-1079.131,853.6127;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-179.3036,211.6248;Inherit;False;28;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-235.0084,303.4016;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1400.262,934.3151;Inherit;False;Property;_Depth_Distance;Depth_Distance;2;0;Create;True;0;0;False;0;False;0;25;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-798.0388,805.1837;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;19;-1316.52,752.0304;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;15;-1053.109,1001.629;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;17;-856.0771,1108.915;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;7;ASEMaterialInspector;0;0;Standard;Pond;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;1;25;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;9;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;40;0;39;0
WireConnection;41;0;40;0
WireConnection;38;0;30;1
WireConnection;38;1;41;0
WireConnection;2;0;3;0
WireConnection;36;0;2;1
WireConnection;36;1;37;0
WireConnection;25;0;24;1
WireConnection;34;0;38;0
WireConnection;34;1;35;0
WireConnection;27;0;25;0
WireConnection;32;0;36;0
WireConnection;32;1;34;0
WireConnection;26;0;27;0
WireConnection;26;1;9;0
WireConnection;21;0;32;0
WireConnection;28;0;26;0
WireConnection;23;0;21;0
WireConnection;22;0;8;0
WireConnection;22;1;23;0
WireConnection;11;1;19;0
WireConnection;11;0;14;0
WireConnection;6;0;32;0
WireConnection;6;1;5;0
WireConnection;6;2;7;0
WireConnection;12;0;9;0
WireConnection;12;1;11;0
WireConnection;17;0;16;0
WireConnection;0;0;22;0
WireConnection;0;9;29;0
WireConnection;0;11;6;0
ASEEND*/
//CHKSM=C9CDC47505A5A1CDC9A44E0711CF207485350C4B