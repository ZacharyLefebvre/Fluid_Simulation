// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FluidDebug"
{
	Properties
	{
		_SmokeTexture("SmokeTexture", 2D) = "white" {}
		_ColliderTexture("ColliderTexture", 2D) = "white" {}
		_VelocityTexture("VelocityTexture", 2D) = "white" {}
		_DivergenceTexture("DivergenceTexture", 2D) = "white" {}
		_PressureTexture("PressureTexture", 2D) = "white" {}
		_VorticityTexture("VorticityTexture", 2D) = "white" {}
		[Enum(Smoke,0,Velocity,1,Divergence,2,Pressure,3,Vorticity,4)]_Textureselect("Texture select", Int) = 0
		_Divergenceboost("Divergence boost", Range( 1 , 10)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform int _Textureselect;
			uniform sampler2D _SmokeTexture;
			uniform float4 _SmokeTexture_ST;
			uniform sampler2D _VelocityTexture;
			uniform float4 _VelocityTexture_ST;
			uniform float _Divergenceboost;
			uniform sampler2D _DivergenceTexture;
			uniform float4 _DivergenceTexture_ST;
			uniform sampler2D _PressureTexture;
			uniform float4 _PressureTexture_ST;
			uniform sampler2D _VorticityTexture;
			uniform float4 _VorticityTexture_ST;
			uniform sampler2D _ColliderTexture;
			uniform float4 _ColliderTexture_ST;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_SmokeTexture = i.ase_texcoord1.xy * _SmokeTexture_ST.xy + _SmokeTexture_ST.zw;
				float4 tex2DNode1 = tex2D( _SmokeTexture, uv_SmokeTexture );
				float3 appendResult9 = (float3(tex2DNode1.r , tex2DNode1.r , tex2DNode1.r));
				float2 uv_VelocityTexture = i.ase_texcoord1.xy * _VelocityTexture_ST.xy + _VelocityTexture_ST.zw;
				float4 tex2DNode4 = tex2D( _VelocityTexture, uv_VelocityTexture );
				float3 appendResult10 = (float3(saturate( ( tex2DNode4.r + 0.5 ) ) , saturate( ( tex2DNode4.g + 0.5 ) ) , 0.0));
				float2 uv_DivergenceTexture = i.ase_texcoord1.xy * _DivergenceTexture_ST.xy + _DivergenceTexture_ST.zw;
				float temp_output_27_0 = saturate( ( ( _Divergenceboost * tex2D( _DivergenceTexture, uv_DivergenceTexture ).r ) + 0.5 ) );
				float3 appendResult11 = (float3(temp_output_27_0 , temp_output_27_0 , temp_output_27_0));
				float2 uv_PressureTexture = i.ase_texcoord1.xy * _PressureTexture_ST.xy + _PressureTexture_ST.zw;
				float temp_output_29_0 = saturate( ( tex2D( _PressureTexture, uv_PressureTexture ).r + 0.5 ) );
				float3 appendResult12 = (float3(temp_output_29_0 , temp_output_29_0 , temp_output_29_0));
				float2 uv_VorticityTexture = i.ase_texcoord1.xy * _VorticityTexture_ST.xy + _VorticityTexture_ST.zw;
				float temp_output_35_0 = saturate( ( tex2D( _VorticityTexture, uv_VorticityTexture ).r + 0.5 ) );
				float3 appendResult36 = (float3(temp_output_35_0 , temp_output_35_0 , temp_output_35_0));
				float4 color41 = IsGammaSpace() ? float4(0,0.5551643,1,0) : float4(0,0.2686992,1,0);
				float2 uv_ColliderTexture = i.ase_texcoord1.xy * _ColliderTexture_ST.xy + _ColliderTexture_ST.zw;
				float4 lerpResult40 = lerp( float4( ( (float)_Textureselect == 0.0 ? appendResult9 : ( (float)_Textureselect == 1.0 ? appendResult10 : ( (float)_Textureselect == 2.0 ? appendResult11 : ( (float)_Textureselect == 3.0 ? appendResult12 : appendResult36 ) ) ) ) , 0.0 ) , color41 , tex2D( _ColliderTexture, uv_ColliderTexture ).r);
				
				
				finalColor = lerpResult40;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18500
0;6;1920;1143;1998.447;479.1599;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;6;-1585.1,445.7999;Inherit;True;Property;_DivergenceTexture;DivergenceTexture;3;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;32;-1544.099,932.2763;Inherit;True;Property;_VorticityTexture;VorticityTexture;5;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;8;-1590.1,665.7997;Inherit;True;Property;_PressureTexture;PressureTexture;4;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;7;-1279.1,663.7997;Inherit;True;Property;_TextureSample3;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-1131.599,227.2763;Inherit;False;Property;_Divergenceboost;Divergence boost;7;0;Create;True;0;0;False;0;False;1;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-1233.099,930.2763;Inherit;True;Property;_TextureSample4;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1274.1,443.7999;Inherit;True;Property;_TextureSample2;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-758.5989,265.2763;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1503.9,8.900001;Inherit;True;Property;_VelocityTexture;VelocityTexture;2;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-749.4106,630.2318;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-757.736,928.3536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-577.4106,264.2318;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1192.9,6.900001;Inherit;True;Property;_TextureSample1;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;35;-572.736,932.3536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;29;-564.4106,634.2318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;27;-413.4106,262.2318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-327.3254,912.1218;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-319,614;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-742.9106,-42.76822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-740.4106,57.23178;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;14;-186.1274,-380.0565;Inherit;False;Property;_Textureselect;Texture select;6;1;[Enum];Create;True;5;Smoke;0;Velocity;1;Divergence;2;Pressure;3;Vorticity;4;0;False;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-212,250;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Compare;37;92.40088,578.2763;Inherit;False;0;4;0;INT;0;False;1;FLOAT;3;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1510.4,-216.1;Inherit;True;Property;_SmokeTexture;SmokeTexture;0;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SaturateNode;25;-559.4106,61.23178;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;23;-559.9106,-38.76822;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;21;331.3205,231.5304;Inherit;False;0;4;0;INT;0;False;1;FLOAT;2;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-373,-13.2;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1;-1199.4,-218.1;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;38;465.8104,-629.2653;Inherit;True;Property;_ColliderTexture;ColliderTexture;1;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;9;-228.0999,-208.2;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Compare;20;515.7816,-76.75569;Inherit;False;0;4;0;INT;0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Compare;19;717.6176,-264.885;Inherit;False;0;4;0;INT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;39;776.8104,-631.2653;Inherit;True;Property;_TextureSample5;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;41;930.3104,-823.2653;Inherit;False;Constant;_Color0;Color 0;8;0;Create;True;0;0;False;0;False;0,0.5551643,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;40;1269.31,-553.2653;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1488.736,-310.8423;Float;False;True;-1;2;ASEMaterialInspector;100;1;FluidDebug;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;7;0;8;0
WireConnection;33;0;32;0
WireConnection;5;0;6;0
WireConnection;31;0;30;0
WireConnection;31;1;5;1
WireConnection;28;0;7;1
WireConnection;34;0;33;1
WireConnection;26;0;31;0
WireConnection;4;0;3;0
WireConnection;35;0;34;0
WireConnection;29;0;28;0
WireConnection;27;0;26;0
WireConnection;36;0;35;0
WireConnection;36;1;35;0
WireConnection;36;2;35;0
WireConnection;12;0;29;0
WireConnection;12;1;29;0
WireConnection;12;2;29;0
WireConnection;22;0;4;1
WireConnection;24;0;4;2
WireConnection;11;0;27;0
WireConnection;11;1;27;0
WireConnection;11;2;27;0
WireConnection;37;0;14;0
WireConnection;37;2;12;0
WireConnection;37;3;36;0
WireConnection;25;0;24;0
WireConnection;23;0;22;0
WireConnection;21;0;14;0
WireConnection;21;2;11;0
WireConnection;21;3;37;0
WireConnection;10;0;23;0
WireConnection;10;1;25;0
WireConnection;1;0;2;0
WireConnection;9;0;1;1
WireConnection;9;1;1;1
WireConnection;9;2;1;1
WireConnection;20;0;14;0
WireConnection;20;2;10;0
WireConnection;20;3;21;0
WireConnection;19;0;14;0
WireConnection;19;2;9;0
WireConnection;19;3;20;0
WireConnection;39;0;38;0
WireConnection;40;0;19;0
WireConnection;40;1;41;0
WireConnection;40;2;39;1
WireConnection;0;0;40;0
ASEEND*/
//CHKSM=4DA1E84D192D74D0B6056F68E1FB51BCE3F7726A