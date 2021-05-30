// Upgrade NOTE: upgraded instancing buffer 'Nenuphar' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nenuphar"
{
	Properties
	{
		_MainColor("MainColor", Color) = (0.06723652,0.3207547,0.02874688,0)
		_ParticleTextureSize("ParticleTextureSize", Int) = 0
		_PondScale("PondScale", Float) = 0
		[Header(Vertex Offset)][Space(5)][Toggle]_VertexOffset("Vertex Offset?", Float) = 1
		_HeightAmplitude("HeightAmplitude", Range( 0 , 1)) = 0
		_SmallVerticalOffset("SmallVerticalOffset", Range( 0 , 1)) = 0.001
		_WaterSize("WaterSize", Range( 0 , 1)) = 0
		_RippleSize("RippleSize", Range( 0 , 1)) = 0
		_Sampling("Sampling", Range( 0 , 20)) = 0
		[PerRendererData]_Rotation("Rotation", Float) = 0
		[PerRendererData]_Id("Id", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#pragma target 4.5
		#pragma multi_compile_instancing
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform float _VertexOffset;
		uniform sampler2D particleTexture;
		uniform int _ParticleTextureSize;
		uniform float2 particleInvTextureSize;
		uniform float _PondScale;
		uniform sampler2D _SmokeTexture;
		uniform float _WaterSize;
		uniform sampler2D WaterRipples;
		uniform float InjectionForce;
		uniform float _RippleSize;
		uniform float _Sampling;
		uniform float _SmallVerticalOffset;
		uniform float _HeightAmplitude;
		uniform float4 _MainColor;

		UNITY_INSTANCING_BUFFER_START(Nenuphar)
			UNITY_DEFINE_INSTANCED_PROP(float, _Rotation)
#define _Rotation_arr Nenuphar
			UNITY_DEFINE_INSTANCED_PROP(float, _Id)
#define _Id_arr Nenuphar
		UNITY_INSTANCING_BUFFER_END(Nenuphar)


		float3x3 MyCustomExpression143( float value )
		{
			 float c = cos(value);
			float s = sin(value);
			float3x3 mat = float3x3(c, 0.0, s, 0.0, 1.0, 0.0, -s, 0.0, c);
			return mat;
		}


		float RippleSampling113( sampler2D waterTex, sampler2D rippleTex, float2 uv, float2 nenupharOffset, float waterSize, float rippleSize, int sampling, float injectionForce )
		{
			float maxVal = 0.0;
			for(float i = -sampling; i <= sampling; i++)
			{
			    for(float j = -sampling; j <= sampling; j++)
			    {
			        if(i != 0.0 && j != 0.0)
			        {
			            float water = tex2Dlod(waterTex, float4(uv + nenupharOffset * (abs(i) * (1 / sampling)) * normalize(float2(i, j)), 0.0, 0.0) ).r;
			            float ripple = tex2Dlod(rippleTex, float4(uv + nenupharOffset * (abs(i) * (1 / sampling)) * normalize(float2(i, j)), 0.0, 0.0)  ).r;
			            water *= waterSize;
			            ripple /=  injectionForce;
			            ripple *= rippleSize;
			            maxVal = max(maxVal, ripple + water);
			        }        
			    }
			}
			return maxVal;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float _Rotation_Instance = UNITY_ACCESS_INSTANCED_PROP(_Rotation_arr, _Rotation);
			float value143 = _Rotation_Instance;
			float3x3 localMyCustomExpression143 = MyCustomExpression143( value143 );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 RotatedPos144 = mul( localMyCustomExpression143, ase_vertex3Pos );
			float _Id_Instance = UNITY_ACCESS_INSTANCED_PROP(_Id_arr, _Id);
			float2 appendResult12 = (float2(fmod( _Id_Instance , (float)(float)_ParticleTextureSize ) , floor( ( _Id_Instance / _ParticleTextureSize ) )));
			float2 ParticleID57 = ( ( appendResult12 / _ParticleTextureSize ) - ( particleInvTextureSize * float2( 0.5,0.5 ) ) );
			float4 tex2DNode3 = tex2Dlod( particleTexture, float4( ParticleID57, 0, 0.0) );
			float4 break32 = ( 1.0 - tex2DNode3 );
			float3 appendResult33 = (float3(break32.r , 0.0 , break32.g));
			float4 break39 = tex2DNode3;
			float2 appendResult30 = (float2(break39.r , break39.g));
			float2 UVs127 = appendResult30;
			float WaterSize111 = _WaterSize;
			float InjectionForce135 = ( max( InjectionForce , 0.001 ) * 2.0 );
			float RippleSize123 = _RippleSize;
			sampler2D waterTex113 = _SmokeTexture;
			sampler2D rippleTex113 = WaterRipples;
			float2 uv113 = UVs127;
			float NenupharRadius45 = tex2DNode3.b;
			float2 NenupharOffset119 = ( particleInvTextureSize * NenupharRadius45 );
			float2 nenupharOffset113 = NenupharOffset119;
			float waterSize113 = WaterSize111;
			float rippleSize113 = RippleSize123;
			int sampling113 = (int)_Sampling;
			float injectionForce113 = InjectionForce135;
			float localRippleSampling113 = RippleSampling113( waterTex113 , rippleTex113 , uv113 , nenupharOffset113 , waterSize113 , rippleSize113 , sampling113 , injectionForce113 );
			float3 Displacement9 = ( ( appendResult33 * _PondScale ) + RotatedPos144 + ( ( max( ( ( tex2Dlod( _SmokeTexture, float4( UVs127, 0, 0.0) ).r * WaterSize111 ) + ( ( tex2Dlod( WaterRipples, float4( UVs127, 0, 0.0) ).r / InjectionForce135 ) * RippleSize123 ) ) , localRippleSampling113 ) + _SmallVerticalOffset ) * _HeightAmplitude * float3(0,1,0) ) );
			v.vertex.xyz = (( _VertexOffset )?( Displacement9 ):( RotatedPos144 ));
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = _MainColor.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
0;73;2560;928;2398.787;837.931;1.644357;False;False
Node;AmplifyShaderEditor.IntNode;7;-4736.354,989.0318;Inherit;False;Property;_ParticleTextureSize;ParticleTextureSize;5;0;Create;True;0;0;False;0;False;0;64;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-4716.992,542.9016;Inherit;False;InstancedProperty;_Id;Id;16;1;[PerRendererData];Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-4402.955,915.4312;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;13;-4266.963,915.4314;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;10;-4402.955,797.4311;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;34;-4313.054,1157.399;Inherit;False;Global;particleInvTextureSize;particleInvTextureSize;8;0;Create;True;0;0;False;0;False;0,0;0.015625,0.015625;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;12;-4114.064,816.0312;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-3950.06,1108.399;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-3946.966,963.4316;Inherit;False;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-3792.52,1043.106;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-3659.325,1048.815;Inherit;False;ParticleID;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-3478.879,51.73388;Inherit;True;Global;particleTexture;particleTexture;4;0;Create;False;0;0;False;0;False;None;;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;59;-3430.546,260.0686;Inherit;False;57;ParticleID;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;3;-3182.95,151.8328;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;39;-2852.919,192.632;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;30;-2570.047,291.5493;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-3166.253,853.0573;Inherit;False;Global;InjectionForce;InjectionForce;14;0;Create;True;0;0;False;0;False;1;209.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-2837.546,340.0686;Inherit;False;NenupharRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;134;-2959.253,855.0573;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-2398.71,299.9337;Inherit;False;UVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-3094.535,758.5741;Inherit;False;127;UVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-2805.275,858.8716;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;89;-3155.526,559.872;Inherit;True;Global;WaterRipples;WaterRipples;10;0;Create;True;0;0;False;0;False;None;;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;46;-4282.975,1306.508;Inherit;False;45;NenupharRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-4051.976,1243.508;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;23;-2424.532,88.26547;Inherit;True;Global;_SmokeTexture;_SmokeTexture;2;0;Create;True;0;0;False;0;False;None;;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-2657.099,860.4636;Inherit;False;InjectionForce;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2355.425,460.595;Inherit;False;Property;_WaterSize;WaterSize;11;0;Create;True;0;0;False;0;False;0;0.33;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2390.74,899.4009;Inherit;False;Property;_RippleSize;RippleSize;12;0;Create;True;0;0;False;0;False;0;0.025;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;91;-2814.783,627.3356;Inherit;True;Property;_TextureSample11;Texture Sample 11;12;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;130;-2415.078,727.5035;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;-2177.233,245.8655;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-2167.032,100.8881;Inherit;False;SmokeTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-2815.684,522.7357;Inherit;False;WaterRipplesTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-2074.537,471.2472;Inherit;False;WaterSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-3911.412,1248.055;Inherit;False;NenupharOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-2112.187,900.5284;Inherit;False;RippleSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-2528.67,1194.085;Inherit;False;64;SmokeTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-2619.263,1729.703;Inherit;False;Property;_Sampling;Sampling;13;0;Create;True;0;0;False;0;False;0;12;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-2497.853,1541.504;Inherit;False;111;WaterSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-4976.565,47.5898;Inherit;False;InstancedProperty;_Rotation;Rotation;14;1;[PerRendererData];Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-2498.853,1627.504;Inherit;False;123;RippleSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-1869.425,353.595;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;-2495.99,1371.346;Inherit;False;127;UVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1887.753,793.5165;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-2533.055,1448.716;Inherit;False;119;NenupharOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-2560.688,1289.13;Inherit;False;90;WaterRipplesTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-2507.173,1875.804;Inherit;False;135;InjectionForce;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;143;-4719.868,40.18973;Inherit;False; float c = cos(value)@$float s = sin(value)@$float3x3 mat = float3x3(c, 0.0, s, 0.0, 1.0, 0.0, -s, 0.0, c)@$return mat@;5;False;1;True;value;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;1;0;FLOAT;0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.PosVertexDataNode;140;-4715.868,145.1899;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;113;-2231.941,1317.832;Inherit;False;float maxVal = 0.0@$for(float i = -sampling@ i <= sampling@ i++)${$    for(float j = -sampling@ j <= sampling@ j++)$    {$        if(i != 0.0 && j != 0.0)$        {$            float water = tex2Dlod(waterTex, float4(uv + nenupharOffset * (abs(i) * (1 / sampling)) * normalize(float2(i, j)), 0.0, 0.0) ).r@$            float ripple = tex2Dlod(rippleTex, float4(uv + nenupharOffset * (abs(i) * (1 / sampling)) * normalize(float2(i, j)), 0.0, 0.0)  ).r@$$            water *= waterSize@$$            ripple /=  injectionForce@$            ripple *= rippleSize@$$            maxVal = max(maxVal, ripple + water)@$        }        $    }$}$return maxVal@;1;False;8;True;waterTex;SAMPLER2D;;In;;Inherit;False;True;rippleTex;SAMPLER2D;;In;;Inherit;False;True;uv;FLOAT2;0,0;In;;Inherit;False;True;nenupharOffset;FLOAT2;0,0;In;;Inherit;False;True;waterSize;FLOAT;0;In;;Inherit;False;True;rippleSize;FLOAT;0;In;;Inherit;False;True;sampling;INT;0;In;;Inherit;False;True;injectionForce;FLOAT;0;In;;Inherit;False;Ripple Sampling;True;False;0;8;0;SAMPLER2D;;False;1;SAMPLER2D;;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;INT;0;False;7;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;-2623.386,-184.5632;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-1732.608,462.6467;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1622.436,705.8444;Inherit;False;Property;_SmallVerticalOffset;SmallVerticalOffset;9;0;Create;True;0;0;False;0;False;0.001;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;72;-1605.694,572.8022;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-4484.868,82.18987;Inherit;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;32;-2454.779,-186.4017;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;33;-2164.078,-202.5018;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1371.247,339.5493;Inherit;False;Property;_PondScale;PondScale;6;0;Create;True;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1321.135,614.4443;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-4334.39,87.02467;Inherit;False;RotatedPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;28;-1503.645,929.3478;Inherit;False;Constant;_Up;Up;7;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;26;-1600.696,809.9689;Inherit;False;Property;_HeightAmplitude;HeightAmplitude;8;0;Create;True;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1443.736,444.2852;Inherit;False;144;RotatedPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1141.896,662.5681;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1160.286,272.0648;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-962.4363,409.9679;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-809.6201,414.5558;Inherit;False;Displacement;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;-474.9999,332.0187;Inherit;False;9;Displacement;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-462.7363,248.2852;Inherit;False;144;RotatedPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PiNode;148;-4992.96,373.8656;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-229.265,-290.914;Inherit;False;144;RotatedPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;165;-620.5933,81.53091;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;162;-462.9104,-31.46154;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-681.7709,-70.40047;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-5083.662,257.1223;Inherit;False;Property;_Float0;Float 0;15;0;Create;True;0;0;False;0;False;0;6.28;0;6.28;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;42;-243.6172,275.0596;Inherit;False;Property;_VertexOffset;Vertex Offset?;7;0;Create;True;0;0;False;2;Header(Vertex Offset);Space(5);False;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;6;-4723.35,622.7303;Inherit;False;InstancedProperty;_Id2;Id2;3;1;[PerRendererData];Create;True;0;0;False;0;False;0;36;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-4479.68,625.3333;Inherit;False;Constant;_ActiveParticleCount;ActiveParticleCount;16;0;Create;True;0;0;False;0;False;4096;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-313.6276,147.1702;Inherit;False;Property;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;False;0.71;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-218.2565,-198.932;Inherit;False;57;ParticleID;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;153;-4242.114,549.9353;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-258.693,-94.67972;Inherit;False;Property;_MainColor;MainColor;0;0;Create;True;0;0;False;0;False;0.06723652,0.3207547,0.02874688,0;0.02012577,0.1509434,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;160;-930.9599,70.39133;Inherit;False;159;myVarName;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;-4107.292,442.895;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;164;-4243.711,443.5334;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;163;-4488.211,438.0335;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;64;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;147;-4756.96,303.8656;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;5;ASEMaterialInspector;0;0;Unlit;Nenuphar;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;166;0
WireConnection;14;1;7;0
WireConnection;13;0;14;0
WireConnection;10;0;166;0
WireConnection;10;1;7;0
WireConnection;12;0;10;0
WireConnection;12;1;13;0
WireConnection;35;0;34;0
WireConnection;15;0;12;0
WireConnection;15;1;7;0
WireConnection;36;0;15;0
WireConnection;36;1;35;0
WireConnection;57;0;36;0
WireConnection;3;0;4;0
WireConnection;3;1;59;0
WireConnection;39;0;3;0
WireConnection;30;0;39;0
WireConnection;30;1;39;1
WireConnection;45;0;3;3
WireConnection;134;0;132;0
WireConnection;127;0;30;0
WireConnection;138;0;134;0
WireConnection;44;0;34;0
WireConnection;44;1;46;0
WireConnection;135;0;138;0
WireConnection;91;0;89;0
WireConnection;91;1;129;0
WireConnection;130;0;91;1
WireConnection;130;1;135;0
WireConnection;22;0;23;0
WireConnection;22;1;127;0
WireConnection;64;0;23;0
WireConnection;90;0;89;0
WireConnection;111;0;102;0
WireConnection;119;0;44;0
WireConnection;123;0;103;0
WireConnection;105;0;22;1
WireConnection;105;1;111;0
WireConnection;104;0;130;0
WireConnection;104;1;123;0
WireConnection;143;0;139;0
WireConnection;113;0;116;0
WireConnection;113;1;117;0
WireConnection;113;2;128;0
WireConnection;113;3;120;0
WireConnection;113;4;121;0
WireConnection;113;5;122;0
WireConnection;113;6;125;0
WireConnection;113;7;137;0
WireConnection;31;0;3;0
WireConnection;92;0;105;0
WireConnection;92;1;104;0
WireConnection;72;0;92;0
WireConnection;72;1;113;0
WireConnection;141;0;143;0
WireConnection;141;1;140;0
WireConnection;32;0;31;0
WireConnection;33;0;32;0
WireConnection;33;2;32;1
WireConnection;41;0;72;0
WireConnection;41;1;40;0
WireConnection;144;0;141;0
WireConnection;24;0;41;0
WireConnection;24;1;26;0
WireConnection;24;2;28;0
WireConnection;29;0;33;0
WireConnection;29;1;27;0
WireConnection;20;0;29;0
WireConnection;20;1;145;0
WireConnection;20;2;24;0
WireConnection;9;0;20;0
WireConnection;165;0;160;0
WireConnection;165;1;160;0
WireConnection;165;2;160;0
WireConnection;162;0;161;0
WireConnection;161;0;160;0
WireConnection;42;0;146;0
WireConnection;42;1;8;0
WireConnection;153;0;166;0
WireConnection;153;1;152;0
WireConnection;159;0;164;0
WireConnection;164;0;163;0
WireConnection;163;0;166;0
WireConnection;147;0;149;0
WireConnection;147;1;148;0
WireConnection;0;2;1;0
WireConnection;0;11;42;0
ASEEND*/
//CHKSM=714ECB5E89CF380D1952D97D8FD058CE6DF76DDA