// Upgrade NOTE: upgraded instancing buffer 'Nenuphar' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nenuphar"
{
	Properties
	{
		_MainColor("MainColor", Color) = (0.06723652,0.3207547,0.02874688,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.71
		[PerRendererData]_Id("Id", Int) = 0
		_ParticleTextureSize("ParticleTextureSize", Int) = 0
		_HeightAmplitude("HeightAmplitude", Range( 0 , 1)) = 0
		_PondScale("PondScale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform sampler2D particleTexture;
		uniform int _ParticleTextureSize;
		uniform float2 particleInvTextureSize;
		uniform float _PondScale;
		uniform sampler2D _SmokeTexture;
		uniform float _HeightAmplitude;
		uniform float4 _MainColor;
		uniform float _Smoothness;

		UNITY_INSTANCING_BUFFER_START(Nenuphar)
			UNITY_DEFINE_INSTANCED_PROP(int, _Id)
#define _Id_arr Nenuphar
		UNITY_INSTANCING_BUFFER_END(Nenuphar)

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			int _Id_Instance = UNITY_ACCESS_INSTANCED_PROP(_Id_arr, _Id);
			float2 appendResult12 = (float2((float)fmod( (float)_Id_Instance , (float)_ParticleTextureSize ) , (float)floor( ( _Id_Instance / _ParticleTextureSize ) )));
			float4 tex2DNode3 = tex2Dlod( particleTexture, float4( ( ( appendResult12 / _ParticleTextureSize ) - ( particleInvTextureSize * float2( 0.5,0.5 ) ) ), 0, 0.0) );
			float4 break32 = ( 1.0 - tex2DNode3 );
			float3 appendResult33 = (float3(break32.r , 0.0 , break32.g));
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 break39 = tex2DNode3;
			float2 appendResult30 = (float2(break39.r , break39.g));
			float3 Displacement9 = ( ( appendResult33 * _PondScale ) + ase_vertex3Pos + ( ( tex2Dlod( _SmokeTexture, float4( appendResult30, 0, 0.0) ).r + 0.001 ) * _HeightAmplitude * float3(0,1,0) ) );
			v.vertex.xyz = Displacement9;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _MainColor.rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
0;73;2560;928;2709.135;-235.4443;1;True;False
Node;AmplifyShaderEditor.IntNode;6;-3784.241,422.1364;Inherit;False;InstancedProperty;_Id;Id;3;1;[PerRendererData];Create;True;0;0;False;0;False;0;36;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;7;-3841.241,656.1367;Inherit;False;Property;_ParticleTextureSize;ParticleTextureSize;5;0;Create;True;0;0;False;0;False;0;64;0;1;INT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-3495.241,610.1365;Inherit;False;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.FloorOpNode;13;-3347.241,605.1366;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.FmodOpNode;10;-3491.241,514.1364;Inherit;False;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-3190.242,517.1364;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;34;-3360.226,777.4957;Inherit;False;Global;particleInvTextureSize;particleInvTextureSize;8;0;Create;True;0;0;False;0;False;0,0;0.0625,0.0625;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-3076.226,797.4957;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-3061.242,670.1367;Inherit;False;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-2896.226,727.4957;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-2957.343,331.0367;Inherit;True;Global;particleTexture;particleTexture;4;0;Create;False;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;3;-2661.414,431.1356;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;39;-2182.383,595.9348;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TexturePropertyNode;23;-1903.996,366.5683;Inherit;True;Global;_SmokeTexture;_SmokeTexture;2;0;Create;True;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;30;-1895.289,573.6299;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;31;-2350.951,305.4398;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;32;-2161.344,305.6013;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;22;-1654.696,525.1684;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-1530.135,721.4443;Inherit;False;Constant;_Small_Offset;Small_Offset;8;0;Create;True;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-1859.642,218.5012;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1321.135,614.4443;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1669.595,859.3688;Inherit;False;Property;_HeightAmplitude;HeightAmplitude;6;0;Create;True;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;28;-1555.445,951.3479;Inherit;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;27;-1306.247,227.7495;Inherit;False;Property;_PondScale;PondScale;7;0;Create;True;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;19;-1327.309,316.8872;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1100.485,168.0649;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1141.896,662.5681;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-962.4363,409.9679;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-809.6201,414.5558;Inherit;False;Displacement;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-313.6276,147.1702;Inherit;False;Property;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;False;0.71;0.71;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-248.293,-145.0797;Inherit;False;Property;_MainColor;MainColor;0;0;Create;True;0;0;False;0;False;0.06723652,0.3207547,0.02874688,0;0.02012577,0.1509434,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;8;-195.3629,283.8405;Inherit;False;9;Displacement;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Nenuphar;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;6;0
WireConnection;14;1;7;0
WireConnection;13;0;14;0
WireConnection;10;0;6;0
WireConnection;10;1;7;0
WireConnection;12;0;10;0
WireConnection;12;1;13;0
WireConnection;35;0;34;0
WireConnection;15;0;12;0
WireConnection;15;1;7;0
WireConnection;36;0;15;0
WireConnection;36;1;35;0
WireConnection;3;0;4;0
WireConnection;3;1;36;0
WireConnection;39;0;3;0
WireConnection;30;0;39;0
WireConnection;30;1;39;1
WireConnection;31;0;3;0
WireConnection;32;0;31;0
WireConnection;22;0;23;0
WireConnection;22;1;30;0
WireConnection;33;0;32;0
WireConnection;33;2;32;1
WireConnection;41;0;22;1
WireConnection;41;1;40;0
WireConnection;29;0;33;0
WireConnection;29;1;27;0
WireConnection;24;0;41;0
WireConnection;24;1;26;0
WireConnection;24;2;28;0
WireConnection;20;0;29;0
WireConnection;20;1;19;0
WireConnection;20;2;24;0
WireConnection;9;0;20;0
WireConnection;0;0;1;0
WireConnection;0;4;2;0
WireConnection;0;11;8;0
ASEEND*/
//CHKSM=473452F4BACF5A29E14AAE41C00382A434C66A0D