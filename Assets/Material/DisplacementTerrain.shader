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
		_New_Graph_roughness("New_Graph_roughness", 2D) = "white" {}
		_Heightmap("Heightmap", 2D) = "white" {}
		_Terrainheight("Terrain height", Range( 0 , 5)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
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
		uniform sampler2D _Normalmap;
		uniform float4 _Normalmap_ST;
		uniform sampler2D _New_Graph_basecolor;
		uniform float4 _New_Graph_basecolor_ST;
		uniform sampler2D _New_Graph_roughness;
		SamplerState sampler_New_Graph_roughness;
		uniform float4 _New_Graph_roughness_ST;
		uniform float _TessValue;

		float4 tessFunction( )
		{
			return _TessValue;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_vertexNormal = v.normal.xyz;
			float2 uv_Heightmap = v.texcoord * _Heightmap_ST.xy + _Heightmap_ST.zw;
			v.vertex.xyz += ( ase_vertexNormal * _Terrainheight * tex2Dlod( _Heightmap, float4( uv_Heightmap, 0, _Miplevel) ).g );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normalmap = i.uv_texcoord * _Normalmap_ST.xy + _Normalmap_ST.zw;
			o.Normal = UnpackNormal( tex2Dlod( _Normalmap, float4( uv_Normalmap, 0, _Miplevel) ) );
			float2 uv_New_Graph_basecolor = i.uv_texcoord * _New_Graph_basecolor_ST.xy + _New_Graph_basecolor_ST.zw;
			o.Albedo = tex2D( _New_Graph_basecolor, uv_New_Graph_basecolor ).rgb;
			float2 uv_New_Graph_roughness = i.uv_texcoord * _New_Graph_roughness_ST.xy + _New_Graph_roughness_ST.zw;
			o.Smoothness = ( 1.0 - tex2D( _New_Graph_roughness, uv_New_Graph_roughness ).g );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
431;170;1371;667;1178.685;293.8568;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1511.401,460.7;Inherit;True;Property;_Heightmap;Heightmap;9;0;Create;True;0;0;False;0;False;None;6c7fae575084f6144a6d1511ff256de7;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;9;-1509.1,684.3445;Inherit;False;Property;_Miplevel;Mip level;7;0;Create;True;0;0;False;0;False;0;2.37;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-861.1999,412.4;Inherit;False;Property;_Terrainheight;Terrain height;10;0;Create;True;0;0;False;0;False;0;0.99;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;4;-780.1999,254.4;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1100.699,521.4999;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;8;-1614.765,-348.7647;Inherit;True;Property;_Normalmap;Normalmap;5;0;Create;True;0;0;False;0;False;None;014af435445e5ff4799d62ace52bd09d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;11;-750.2175,-20.69589;Inherit;True;Property;_New_Graph_roughness;New_Graph_roughness;8;0;Create;True;0;0;False;0;False;-1;38f4d96aa2e8b964087f051b0d38cb84;38f4d96aa2e8b964087f051b0d38cb84;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-473.2,428.4;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;6;-756.6284,-568.1326;Inherit;False;Constant;_Color0;Color 0;3;0;Create;True;0;0;False;0;False;0.5754717,0.34272,0.1818708,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-1017.728,-599.2881;Inherit;True;Property;_New_Graph_basecolor;New_Graph_basecolor;6;0;Create;True;0;0;False;0;False;-1;6834ad1b24541f544bd551d08ddfc16f;6834ad1b24541f544bd551d08ddfc16f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1322.764,-366.0388;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;12;-332.6852,14.14325;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-48,-113;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;DisplacementTerrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;1;32;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;0;2;0
WireConnection;1;2;9;0
WireConnection;5;0;4;0
WireConnection;5;1;3;0
WireConnection;5;2;1;2
WireConnection;7;0;8;0
WireConnection;7;2;9;0
WireConnection;12;0;11;2
WireConnection;0;0;10;0
WireConnection;0;1;7;0
WireConnection;0;4;12;0
WireConnection;0;11;5;0
ASEEND*/
//CHKSM=83745AB886E5B73CE85B269E8EBD3C4E944B9F73