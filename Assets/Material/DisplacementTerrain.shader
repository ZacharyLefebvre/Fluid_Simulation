// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DisplacementTerrain"
{
	Properties
	{
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 32
		_Normalmap("Normalmap", 2D) = "white" {}
		_New_Graph_basecolor("New_Graph_basecolor", 2D) = "white" {}
		_Miplevel("Mip level", Range( 0 , 5)) = 0
		_Dirt_AO("Dirt_AO", 2D) = "white" {}
		_New_Graph_roughness("New_Graph_roughness", 2D) = "white" {}
		_Dirt_Displacement("Dirt_Displacement", 2D) = "white" {}
		_TextureSample2("Texture Sample 2", 2D) = "bump" {}
		_TextureSample3("Texture Sample 3", 2D) = "white" {}
		_Heightmap("Heightmap", 2D) = "white" {}
		_Displacement_Intensity("Displacement_Intensity", Range( 0 , 2)) = 0
		_Terrainheight("Terrain height", Range( 0 , 5)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _Terrainheight;
		uniform sampler2D _Heightmap;
		uniform float4 _Heightmap_ST;
		uniform float _Miplevel;
		uniform sampler2D _New_Graph_roughness;
		SamplerState sampler_New_Graph_roughness;
		uniform float4 _New_Graph_roughness_ST;
		uniform sampler2D _Dirt_Displacement;
		SamplerState sampler_Dirt_Displacement;
		uniform float4 _Dirt_Displacement_ST;
		uniform float _Displacement_Intensity;
		uniform sampler2D _Normalmap;
		uniform float4 _Normalmap_ST;
		uniform sampler2D _TextureSample2;
		uniform float4 _TextureSample2_ST;
		uniform sampler2D _New_Graph_basecolor;
		uniform float4 _New_Graph_basecolor_ST;
		uniform sampler2D _TextureSample3;
		SamplerState sampler_TextureSample3;
		uniform float4 _TextureSample3_ST;
		uniform sampler2D _Dirt_AO;
		SamplerState sampler_Dirt_AO;
		uniform float4 _Dirt_AO_ST;
		uniform float _TessValue;

		float4 tessFunction( )
		{
			return _TessValue;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_vertexNormal = v.normal.xyz;
			float2 uv_Heightmap = v.texcoord * _Heightmap_ST.xy + _Heightmap_ST.zw;
			float2 uv_New_Graph_roughness = v.texcoord * _New_Graph_roughness_ST.xy + _New_Graph_roughness_ST.zw;
			float4 tex2DNode11 = tex2Dlod( _New_Graph_roughness, float4( uv_New_Graph_roughness, 0, 0.0) );
			float2 uv_Dirt_Displacement = v.texcoord * _Dirt_Displacement_ST.xy + _Dirt_Displacement_ST.zw;
			float4 tex2DNode14 = tex2Dlod( _Dirt_Displacement, float4( uv_Dirt_Displacement, 0, 0.0) );
			v.vertex.xyz += ( ( ase_vertexNormal * _Terrainheight * tex2Dlod( _Heightmap, float4( uv_Heightmap, 0, _Miplevel) ).g ) + ( ( ( 1.0 - tex2DNode11.r ) * 0.5 ) * tex2DNode14.g * _Displacement_Intensity ) );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normalmap = i.uv_texcoord * _Normalmap_ST.xy + _Normalmap_ST.zw;
			float2 uv_TextureSample2 = i.uv_texcoord * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
			o.Normal = BlendNormals( UnpackNormal( tex2Dlod( _Normalmap, float4( uv_Normalmap, 0, _Miplevel) ) ) , UnpackNormal( tex2D( _TextureSample2, uv_TextureSample2 ) ) );
			float2 uv_New_Graph_basecolor = i.uv_texcoord * _New_Graph_basecolor_ST.xy + _New_Graph_basecolor_ST.zw;
			o.Albedo = tex2D( _New_Graph_basecolor, uv_New_Graph_basecolor ).rgb;
			float2 uv_New_Graph_roughness = i.uv_texcoord * _New_Graph_roughness_ST.xy + _New_Graph_roughness_ST.zw;
			float4 tex2DNode11 = tex2D( _New_Graph_roughness, uv_New_Graph_roughness );
			float2 uv_TextureSample3 = i.uv_texcoord * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
			o.Smoothness = saturate( ( tex2DNode11.r + ( 1.0 - tex2D( _TextureSample3, uv_TextureSample3 ).r ) ) );
			float2 uv_Dirt_AO = i.uv_texcoord * _Dirt_AO_ST.xy + _Dirt_AO_ST.zw;
			o.Occlusion = tex2D( _Dirt_AO, uv_Dirt_AO ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
0;73;2560;928;1952.739;-276.455;1;True;False
Node;AmplifyShaderEditor.SamplerNode;11;-921.2175,-130.6959;Inherit;True;Property;_New_Graph_roughness;New_Graph_roughness;9;0;Create;True;0;0;False;0;False;-1;38f4d96aa2e8b964087f051b0d38cb84;cd1e7afc1e10c7942bb84aaeccfeb816;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-916.0815,62.45477;Inherit;True;Property;_TextureSample3;Texture Sample 3;12;0;Create;True;0;0;False;0;False;-1;None;70624e52eb3b2fa4e93dd5796fc3cc63;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-1509.1,684.3445;Inherit;False;Property;_Miplevel;Mip level;7;0;Create;True;0;0;False;0;False;0;2.37;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1511.401,460.7;Inherit;True;Property;_Heightmap;Heightmap;13;0;Create;True;0;0;False;0;False;None;295b997eccbc9d5469dacd0b1bc7f615;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.OneMinusNode;23;-712.2603,664.1086;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1022.937,755.9047;Inherit;True;Property;_Dirt_Displacement;Dirt_Displacement;10;0;Create;True;0;0;False;0;False;-1;d3aae06293862e843a9620a430bd18b1;d3aae06293862e843a9620a430bd18b1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1100.699,521.4999;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-861.1999,412.4;Inherit;False;Property;_Terrainheight;Terrain height;15;0;Create;True;0;0;False;0;False;0;0.99;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;4;-780.1999,254.4;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;8;-1614.765,-348.7647;Inherit;True;Property;_Normalmap;Normalmap;5;0;Create;True;0;0;False;0;False;None;715c173adf5d3e0478954da6d201fc6c;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.OneMinusNode;20;-602.0815,43.45477;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-773.2622,1005.297;Inherit;False;Property;_Displacement_Intensity;Displacement_Intensity;14;0;Create;True;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-552.3602,714.209;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-473.2,428.4;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;17;-1288.364,-121.9023;Inherit;True;Property;_TextureSample2;Texture Sample 2;11;0;Create;True;0;0;False;0;False;-1;None;e0017262790bf334ea96f908aecfb97c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-399.0815,-32.54523;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-1322.764,-366.0388;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-455.0621,837.4978;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;18;-928.2628,-248.0022;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;22;-237.0815,-19.54523;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-578.3286,-536.8882;Inherit;True;Property;_New_Graph_basecolor;New_Graph_basecolor;6;0;Create;True;0;0;False;0;False;-1;6834ad1b24541f544bd551d08ddfc16f;29f4481392f7c1649920183ed652d67c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-428.5974,110.9616;Inherit;True;Property;_Dirt_AO;Dirt_AO;8;0;Create;True;0;0;False;0;False;-1;4d144e1838ea46c4998ab8f3b86cf0c8;4d144e1838ea46c4998ab8f3b86cf0c8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-228.6604,556.0086;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-693.26,826.6086;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-48,-113;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;DisplacementTerrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;1;32;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;11;1
WireConnection;1;0;2;0
WireConnection;1;2;9;0
WireConnection;20;0;19;1
WireConnection;24;0;23;0
WireConnection;5;0;4;0
WireConnection;5;1;3;0
WireConnection;5;2;1;2
WireConnection;21;0;11;1
WireConnection;21;1;20;0
WireConnection;7;0;8;0
WireConnection;7;2;9;0
WireConnection;15;0;24;0
WireConnection;15;1;14;2
WireConnection;15;2;16;0
WireConnection;18;0;7;0
WireConnection;18;1;17;0
WireConnection;22;0;21;0
WireConnection;25;0;5;0
WireConnection;25;1;15;0
WireConnection;26;0;14;0
WireConnection;0;0;10;0
WireConnection;0;1;18;0
WireConnection;0;4;22;0
WireConnection;0;5;13;1
WireConnection;0;11;25;0
ASEEND*/
//CHKSM=91860630F2410B181A738A11386E86D7F6D13B55