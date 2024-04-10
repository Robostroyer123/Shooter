Shader "Unlit/Anime"
{
    Properties
    {
        _Falloff_Amount("Falloff Amount", Float) = 0
        [NoScaleOffset]_BaseMap("TextureMap", 2D) = "white" {}
        [NoScaleOffset]_ShadowMap("ShadowMap", 2D) = "white" {}
        [NoScaleOffset]_DetailMap("DetailMap", 2D) = "white" {}
        _BaseColor("BaseColor", Color) = (1, 1, 1, 0)
        _ShadowColour("ShadowColour", Color) = (0.5333334, 0.5333334, 0.5333334, 1)
        [NoScaleOffset]_EmissionMap("EmissionMap", 2D) = "black" {}
        [HDR]_Emission("Emission", Color) = (2, 2, 2, 1)
        [Normal][NoScaleOffset]_BumpMap("BumpMap", 2D) = "bump" {}
        _BumpScale("BumpScale", Range(0, 1)) = 0
        [ToggleUI]_TileableTexture("TileableTexture", Float) = 0
        _Outline_Colour("Outline Colour", Color) = (0, 0, 0, 0)
        _OutlineThickness("OutlineThickness", Float) = 0.015625
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 0
        [HideInInspector]_Blend("_Blend", Float) = 2
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 1
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 1
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Falloff_Amount;
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float4 _ShadowColour;
        float4 _DetailMap_TexelSize;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        float4 _Emission;
        float4 _BumpMap_TexelSize;
        float _BumpScale;
        float _TileableTexture;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        
        // Graph Includes
        #include "Assets/shaders/Lighting.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        struct Bindings_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float
        {
        float3 WorldSpaceNormal;
        };
        
        void SG_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float(float _BumpScale, UnityTexture2D _BumpMap, float2 _UV, Bindings_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_0651d1d4c972486292e8d2c55487c2bf_Out_0_Texture2D = _BumpMap;
        float2 _Property_df98ab5b327f41849623711d2a0f4cea_Out_0_Vector2 = _UV;
        float4 _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0651d1d4c972486292e8d2c55487c2bf_Out_0_Texture2D.tex, _Property_0651d1d4c972486292e8d2c55487c2bf_Out_0_Texture2D.samplerstate, _Property_0651d1d4c972486292e8d2c55487c2bf_Out_0_Texture2D.GetTransformedUV(_Property_df98ab5b327f41849623711d2a0f4cea_Out_0_Vector2) );
        _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4);
        float _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_R_4_Float = _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.r;
        float _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_G_5_Float = _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.g;
        float _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_B_6_Float = _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.b;
        float _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_A_7_Float = _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.a;
        float _Property_2ba39de417f247b0948982d96407451b_Out_0_Float = _BumpScale;
        float3 _NormalStrength_d101e6ab6a7042ff962bc8505054c2b9_Out_2_Vector3;
        Unity_NormalStrength_float((_SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.xyz), _Property_2ba39de417f247b0948982d96407451b_Out_0_Float, _NormalStrength_d101e6ab6a7042ff962bc8505054c2b9_Out_2_Vector3);
        float3 _NormalBlend_176b682914694ee8a0263ba05fcf016e_Out_2_Vector3;
        Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_d101e6ab6a7042ff962bc8505054c2b9_Out_2_Vector3, _NormalBlend_176b682914694ee8a0263ba05fcf016e_Out_2_Vector3);
        OutVector3_1 = _NormalBlend_176b682914694ee8a0263ba05fcf016e_Out_2_Vector3;
        }
        
        struct Bindings_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half
        {
        float3 AbsoluteWorldSpacePosition;
        };
        
        void SG_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half(Bindings_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half IN, out half3 Direction_1, out half3 Color_2, out half DistanceAtten_3, out half ShadowAtten_4)
        {
        half3 _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Direction_1_Vector3;
        half3 _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Color_2_Vector3;
        half _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_DistanceAtten_3_Float;
        half _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_ShadowAtten_4_Float;
        MainLight_half(IN.AbsoluteWorldSpacePosition, _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Direction_1_Vector3, _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Color_2_Vector3, _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_DistanceAtten_3_Float, _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_ShadowAtten_4_Float);
        Direction_1 = _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Direction_1_Vector3;
        Color_2 = _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Color_2_Vector3;
        DistanceAtten_3 = _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_DistanceAtten_3_Float;
        ShadowAtten_4 = _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_ShadowAtten_4_Float;
        }
        
        void Unity_Normalize_half3(half3 In, out half3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_ColorMask_float(float3 In, float3 MaskColor, float Range, out float Out, float Fuzziness)
        {
            float Distance = distance(MaskColor, In);
            Out = saturate(1 - (Distance - Range) / max(Fuzziness, 1e-5));
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e1161674d21445da80a94687d98739f4_Out_0_Vector4 = _ShadowColour;
            UnityTexture2D _Property_dd7f4a6742ac47d98f89f8a26d6220ef_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float _Property_a9141355fdb34bec95b894e4d8018ed4_Out_0_Boolean = _TileableTexture;
            float _Split_c683bce1946f4280b73440235e358c65_R_1_Float = (SHADERGRAPH_RENDERER_BOUNDS_MAX - SHADERGRAPH_RENDERER_BOUNDS_MIN)[0];
            float _Split_c683bce1946f4280b73440235e358c65_G_2_Float = (SHADERGRAPH_RENDERER_BOUNDS_MAX - SHADERGRAPH_RENDERER_BOUNDS_MIN)[1];
            float _Split_c683bce1946f4280b73440235e358c65_B_3_Float = (SHADERGRAPH_RENDERER_BOUNDS_MAX - SHADERGRAPH_RENDERER_BOUNDS_MIN)[2];
            float _Split_c683bce1946f4280b73440235e358c65_A_4_Float = 0;
            float2 _Vector2_55298d2e21e74f65bd91483b1980c02f_Out_0_Vector2 = float2(_Split_c683bce1946f4280b73440235e358c65_R_1_Float, _Split_c683bce1946f4280b73440235e358c65_B_3_Float);
            float2 _Branch_83fbacdfe98d4fddb4feb1c4b06e37eb_Out_3_Vector2;
            Unity_Branch_float2(_Property_a9141355fdb34bec95b894e4d8018ed4_Out_0_Boolean, _Vector2_55298d2e21e74f65bd91483b1980c02f_Out_0_Vector2, float2(1, 1), _Branch_83fbacdfe98d4fddb4feb1c4b06e37eb_Out_3_Vector2);
            float2 _TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Branch_83fbacdfe98d4fddb4feb1c4b06e37eb_Out_3_Vector2, float2 (0, 0), _TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2);
            float4 _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_dd7f4a6742ac47d98f89f8a26d6220ef_Out_0_Texture2D.tex, _Property_dd7f4a6742ac47d98f89f8a26d6220ef_Out_0_Texture2D.samplerstate, _Property_dd7f4a6742ac47d98f89f8a26d6220ef_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2) );
            float _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_R_4_Float = _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4.r;
            float _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_G_5_Float = _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4.g;
            float _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_B_6_Float = _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4.b;
            float _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_A_7_Float = _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4.a;
            float4 Color_9e86cbdbc1be45109aa1cdddb29a660a = IsGammaSpace() ? float4(1, 1, 1, 1) : float4(SRGBToLinear(float3(1, 1, 1)), 1);
            float _Comparison_04622d25d50d4a2686463e0eecd65b7e_Out_2_Boolean;
            Unity_Comparison_Equal_float((_SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4).x, (Color_9e86cbdbc1be45109aa1cdddb29a660a).x, _Comparison_04622d25d50d4a2686463e0eecd65b7e_Out_2_Boolean);
            UnityTexture2D _Property_4231ef4a9cb44eceb042efdaafe2689c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4231ef4a9cb44eceb042efdaafe2689c_Out_0_Texture2D.tex, _Property_4231ef4a9cb44eceb042efdaafe2689c_Out_0_Texture2D.samplerstate, _Property_4231ef4a9cb44eceb042efdaafe2689c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2) );
            float _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_R_4_Float = _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_G_5_Float = _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_B_6_Float = _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_A_7_Float = _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4.a;
            float4 _Branch_083517aa6629498aa03bc96051568fc8_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_04622d25d50d4a2686463e0eecd65b7e_Out_2_Boolean, _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4, _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4, _Branch_083517aa6629498aa03bc96051568fc8_Out_3_Vector4);
            float4 _Multiply_cff6d0bf6dc741a5a6e259632d7da70f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_e1161674d21445da80a94687d98739f4_Out_0_Vector4, _Branch_083517aa6629498aa03bc96051568fc8_Out_3_Vector4, _Multiply_cff6d0bf6dc741a5a6e259632d7da70f_Out_2_Vector4);
            float4 _Divide_55f437e500eb4ea4aa6f3700d9a9fed4_Out_2_Vector4;
            Unity_Divide_float4(_Multiply_cff6d0bf6dc741a5a6e259632d7da70f_Out_2_Vector4, _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4, _Divide_55f437e500eb4ea4aa6f3700d9a9fed4_Out_2_Vector4);
            float4 Color_e974d416c1dd4a5fa773108e877a61d6 = IsGammaSpace() ? float4(1, 1, 1, 1) : float4(SRGBToLinear(float3(1, 1, 1)), 1);
            float _Split_3534ac8fba06471b8c868f49f8af3dcc_R_1_Float = IN.VertexColor[0];
            float _Split_3534ac8fba06471b8c868f49f8af3dcc_G_2_Float = IN.VertexColor[1];
            float _Split_3534ac8fba06471b8c868f49f8af3dcc_B_3_Float = IN.VertexColor[2];
            float _Split_3534ac8fba06471b8c868f49f8af3dcc_A_4_Float = IN.VertexColor[3];
            float _OneMinus_8e1ea8e98c2049ccaeffc0d153961b95_Out_1_Float;
            Unity_OneMinus_float(_Split_3534ac8fba06471b8c868f49f8af3dcc_R_1_Float, _OneMinus_8e1ea8e98c2049ccaeffc0d153961b95_Out_1_Float);
            float _Property_c112c94881204477833c37fca0f56e28_Out_0_Float = _Falloff_Amount;
            float _Multiply_b0a2a514ae5641228cc8bd45a6353057_Out_2_Float;
            Unity_Multiply_float_float(-1, _Property_c112c94881204477833c37fca0f56e28_Out_0_Float, _Multiply_b0a2a514ae5641228cc8bd45a6353057_Out_2_Float);
            float _Subtract_2e41457bc6ba4235b345dd74ecec60a9_Out_2_Float;
            Unity_Subtract_float(_OneMinus_8e1ea8e98c2049ccaeffc0d153961b95_Out_1_Float, _Multiply_b0a2a514ae5641228cc8bd45a6353057_Out_2_Float, _Subtract_2e41457bc6ba4235b345dd74ecec60a9_Out_2_Float);
            float _Property_0576665307b745fa9087dad740d66048_Out_0_Float = _BumpScale;
            UnityTexture2D _Property_18db013475824cdf908febb8e5a55760_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BumpMap);
            Bindings_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float _NormalsWithNormalMap_1c717af811364118811418afd43d1ded;
            _NormalsWithNormalMap_1c717af811364118811418afd43d1ded.WorldSpaceNormal = IN.WorldSpaceNormal;
            float3 _NormalsWithNormalMap_1c717af811364118811418afd43d1ded_OutVector3_1_Vector3;
            SG_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float(_Property_0576665307b745fa9087dad740d66048_Out_0_Float, _Property_18db013475824cdf908febb8e5a55760_Out_0_Texture2D, _TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2, _NormalsWithNormalMap_1c717af811364118811418afd43d1ded, _NormalsWithNormalMap_1c717af811364118811418afd43d1ded_OutVector3_1_Vector3);
            Bindings_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half _GetMainLight_c415046b46b1405b89882a5dcb35bd3c;
            _GetMainLight_c415046b46b1405b89882a5dcb35bd3c.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Direction_1_Vector3;
            half3 _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Color_2_Vector3;
            half _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_DistanceAtten_3_Float;
            half _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_ShadowAtten_4_Float;
            SG_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half(_GetMainLight_c415046b46b1405b89882a5dcb35bd3c, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Direction_1_Vector3, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Color_2_Vector3, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_DistanceAtten_3_Float, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_ShadowAtten_4_Float);
            half3 _Normalize_fa91bca7108244ba8a2e0d6f3c5b63ed_Out_1_Vector3;
            Unity_Normalize_half3(_GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Direction_1_Vector3, _Normalize_fa91bca7108244ba8a2e0d6f3c5b63ed_Out_1_Vector3);
            float _DotProduct_096dfc928d3842d0ae6619bbae9b7eee_Out_2_Float;
            Unity_DotProduct_float3(_NormalsWithNormalMap_1c717af811364118811418afd43d1ded_OutVector3_1_Vector3, _Normalize_fa91bca7108244ba8a2e0d6f3c5b63ed_Out_1_Vector3, _DotProduct_096dfc928d3842d0ae6619bbae9b7eee_Out_2_Float);
            float _Step_7aae93943d4f4c1e917042e241dbb1fd_Out_2_Float;
            Unity_Step_float(_Subtract_2e41457bc6ba4235b345dd74ecec60a9_Out_2_Float, _DotProduct_096dfc928d3842d0ae6619bbae9b7eee_Out_2_Float, _Step_7aae93943d4f4c1e917042e241dbb1fd_Out_2_Float);
            half _Multiply_6529366b67194a7683c9babe15e024bb_Out_2_Float;
            Unity_Multiply_half_half(_GetMainLight_c415046b46b1405b89882a5dcb35bd3c_DistanceAtten_3_Float, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_ShadowAtten_4_Float, _Multiply_6529366b67194a7683c9babe15e024bb_Out_2_Float);
            float _Multiply_4d2cf18f92ec4ef48490e75ae6e7d718_Out_2_Float;
            Unity_Multiply_float_float(_Step_7aae93943d4f4c1e917042e241dbb1fd_Out_2_Float, _Multiply_6529366b67194a7683c9babe15e024bb_Out_2_Float, _Multiply_4d2cf18f92ec4ef48490e75ae6e7d718_Out_2_Float);
            float4 _Lerp_16ebefcf70bd4274ac29f558bb8b8edd_Out_3_Vector4;
            Unity_Lerp_float4(_Divide_55f437e500eb4ea4aa6f3700d9a9fed4_Out_2_Vector4, Color_e974d416c1dd4a5fa773108e877a61d6, (_Multiply_4d2cf18f92ec4ef48490e75ae6e7d718_Out_2_Float.xxxx), _Lerp_16ebefcf70bd4274ac29f558bb8b8edd_Out_3_Vector4);
            float4 _Property_5d32e96fad2342f59819be5a66902198_Out_0_Vector4 = _BaseColor;
            float4 _Multiply_b61d9b67585d43f4aeff8c7139c82707_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4, _Property_5d32e96fad2342f59819be5a66902198_Out_0_Vector4, _Multiply_b61d9b67585d43f4aeff8c7139c82707_Out_2_Vector4);
            float4 _Multiply_669960a70b714115997afe26c98d46fb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Lerp_16ebefcf70bd4274ac29f558bb8b8edd_Out_3_Vector4, _Multiply_b61d9b67585d43f4aeff8c7139c82707_Out_2_Vector4, _Multiply_669960a70b714115997afe26c98d46fb_Out_2_Vector4);
            UnityTexture2D _Property_d32ac20567a14f7cbef95bed5b24602d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            float4 _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d32ac20567a14f7cbef95bed5b24602d_Out_0_Texture2D.tex, _Property_d32ac20567a14f7cbef95bed5b24602d_Out_0_Texture2D.samplerstate, _Property_d32ac20567a14f7cbef95bed5b24602d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2) );
            float _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_R_4_Float = _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4.r;
            float _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_G_5_Float = _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4.g;
            float _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_B_6_Float = _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4.b;
            float _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_A_7_Float = _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4.a;
            float4 _Multiply_3f5187371efa4c309ce253c19be6b91a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_669960a70b714115997afe26c98d46fb_Out_2_Vector4, _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4, _Multiply_3f5187371efa4c309ce253c19be6b91a_Out_2_Vector4);
            UnityTexture2D _Property_33fbd3c76e544f0cb820b9c7e9528e81_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_33fbd3c76e544f0cb820b9c7e9528e81_Out_0_Texture2D.tex, _Property_33fbd3c76e544f0cb820b9c7e9528e81_Out_0_Texture2D.samplerstate, _Property_33fbd3c76e544f0cb820b9c7e9528e81_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2) );
            float _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_R_4_Float = _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4.r;
            float _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_G_5_Float = _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4.g;
            float _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_B_6_Float = _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4.b;
            float _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_A_7_Float = _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4.a;
            float4 _Property_e55d724b329d41da99bba5f3675593ba_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Emission) : _Emission;
            float4 _Multiply_75cc17e6a7dd4f7dae35ba302c8fef8d_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4, _Property_e55d724b329d41da99bba5f3675593ba_Out_0_Vector4, _Multiply_75cc17e6a7dd4f7dae35ba302c8fef8d_Out_2_Vector4);
            float _ColorMask_74add8159864422b938c2b5816689c49_Out_3_Float;
            Unity_ColorMask_float((_Multiply_75cc17e6a7dd4f7dae35ba302c8fef8d_Out_2_Vector4.xyz), IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0)), 1, _ColorMask_74add8159864422b938c2b5816689c49_Out_3_Float, 0);
            float _OneMinus_e5094d91ff69434892b7b92767cc83f5_Out_1_Float;
            Unity_OneMinus_float(_ColorMask_74add8159864422b938c2b5816689c49_Out_3_Float, _OneMinus_e5094d91ff69434892b7b92767cc83f5_Out_1_Float);
            float4 _Blend_fef4764d9fa944a7b392609d355d7daa_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_3f5187371efa4c309ce253c19be6b91a_Out_2_Vector4, _Multiply_75cc17e6a7dd4f7dae35ba302c8fef8d_Out_2_Vector4, _Blend_fef4764d9fa944a7b392609d355d7daa_Out_2_Vector4, _OneMinus_e5094d91ff69434892b7b92767cc83f5_Out_1_Float);
            surface.BaseColor = (_Blend_fef4764d9fa944a7b392609d355d7daa_Out_2_Vector4.xyz);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }Pass
        {
            Name "OutlineOne"
            Tags
            {
                "LightMode" = "OutlineOne"
            }
        
        // Render State
        Cull Front
        Blend One Zero
        ZTest LEqual
        ZWrite On
        AlphaToMask On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Outline_Colour;
        float _OutlineThickness;
        float4 _BaseMap_TexelSize;
        float4 _Texture2D_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Texture2D);
        SAMPLER(sampler_Texture2D);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Normalize_e8a8237bb8a6429ca86e459810919d0d_Out_1_Vector3;
            Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_e8a8237bb8a6429ca86e459810919d0d_Out_1_Vector3);
            float _Property_db1e0df0045a488c87aa88e7ad384f14_Out_0_Float = _OutlineThickness;
            float3 _Multiply_9651404a64634e67bd1fe0d2f1b70325_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Normalize_e8a8237bb8a6429ca86e459810919d0d_Out_1_Vector3, (_Property_db1e0df0045a488c87aa88e7ad384f14_Out_0_Float.xxx), _Multiply_9651404a64634e67bd1fe0d2f1b70325_Out_2_Vector3);
            float3 _Add_516b1d9e64bf481c9294bc922bee6282_Out_2_Vector3;
            Unity_Add_float3(_Multiply_9651404a64634e67bd1fe0d2f1b70325_Out_2_Vector3, IN.ObjectSpacePosition, _Add_516b1d9e64bf481c9294bc922bee6282_Out_2_Vector3);
            description.Position = _Add_516b1d9e64bf481c9294bc922bee6282_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5b13d384736a4d0b8cdf8d0dffe22bf0_Out_0_Vector4 = _Outline_Colour;
            UnityTexture2D _Property_3be9859724bc4bfe85c080178b9f1daf_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_3be9859724bc4bfe85c080178b9f1daf_Out_0_Texture2D.tex, _Property_3be9859724bc4bfe85c080178b9f1daf_Out_0_Texture2D.samplerstate, _Property_3be9859724bc4bfe85c080178b9f1daf_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_R_4_Float = _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_RGBA_0_Vector4.r;
            float _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_G_5_Float = _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_RGBA_0_Vector4.g;
            float _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_B_6_Float = _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_RGBA_0_Vector4.b;
            float _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_A_7_Float = _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_RGBA_0_Vector4.a;
            float4 _Multiply_da144d37bb9b476792a38e2fab2aba3f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_5b13d384736a4d0b8cdf8d0dffe22bf0_Out_0_Vector4, _SampleTexture2D_52f1a1cbed374b14b9356f9e86f9d3ff_RGBA_0_Vector4, _Multiply_da144d37bb9b476792a38e2fab2aba3f_Out_2_Vector4);
            surface.BaseColor = (_Multiply_da144d37bb9b476792a38e2fab2aba3f_Out_2_Vector4.xyz);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Falloff_Amount;
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float4 _ShadowColour;
        float4 _DetailMap_TexelSize;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        float4 _Emission;
        float4 _BumpMap_TexelSize;
        float _BumpScale;
        float _TileableTexture;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Falloff_Amount;
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float4 _ShadowColour;
        float4 _DetailMap_TexelSize;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        float4 _Emission;
        float4 _BumpMap_TexelSize;
        float _BumpScale;
        float _TileableTexture;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Falloff_Amount;
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float4 _ShadowColour;
        float4 _DetailMap_TexelSize;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        float4 _Emission;
        float4 _BumpMap_TexelSize;
        float _BumpScale;
        float _TileableTexture;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 color;
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP0;
            #endif
             float4 texCoord0 : INTERP1;
             float4 color : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Falloff_Amount;
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float4 _ShadowColour;
        float4 _DetailMap_TexelSize;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        float4 _Emission;
        float4 _BumpMap_TexelSize;
        float _BumpScale;
        float _TileableTexture;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        
        // Graph Includes
        #include "Assets/shaders/Lighting.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        struct Bindings_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float
        {
        float3 WorldSpaceNormal;
        };
        
        void SG_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float(float _BumpScale, UnityTexture2D _BumpMap, float2 _UV, Bindings_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_0651d1d4c972486292e8d2c55487c2bf_Out_0_Texture2D = _BumpMap;
        float2 _Property_df98ab5b327f41849623711d2a0f4cea_Out_0_Vector2 = _UV;
        float4 _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0651d1d4c972486292e8d2c55487c2bf_Out_0_Texture2D.tex, _Property_0651d1d4c972486292e8d2c55487c2bf_Out_0_Texture2D.samplerstate, _Property_0651d1d4c972486292e8d2c55487c2bf_Out_0_Texture2D.GetTransformedUV(_Property_df98ab5b327f41849623711d2a0f4cea_Out_0_Vector2) );
        _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4);
        float _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_R_4_Float = _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.r;
        float _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_G_5_Float = _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.g;
        float _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_B_6_Float = _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.b;
        float _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_A_7_Float = _SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.a;
        float _Property_2ba39de417f247b0948982d96407451b_Out_0_Float = _BumpScale;
        float3 _NormalStrength_d101e6ab6a7042ff962bc8505054c2b9_Out_2_Vector3;
        Unity_NormalStrength_float((_SampleTexture2D_c5d1308cc686492aa7caabc39cabd19a_RGBA_0_Vector4.xyz), _Property_2ba39de417f247b0948982d96407451b_Out_0_Float, _NormalStrength_d101e6ab6a7042ff962bc8505054c2b9_Out_2_Vector3);
        float3 _NormalBlend_176b682914694ee8a0263ba05fcf016e_Out_2_Vector3;
        Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_d101e6ab6a7042ff962bc8505054c2b9_Out_2_Vector3, _NormalBlend_176b682914694ee8a0263ba05fcf016e_Out_2_Vector3);
        OutVector3_1 = _NormalBlend_176b682914694ee8a0263ba05fcf016e_Out_2_Vector3;
        }
        
        struct Bindings_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half
        {
        float3 AbsoluteWorldSpacePosition;
        };
        
        void SG_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half(Bindings_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half IN, out half3 Direction_1, out half3 Color_2, out half DistanceAtten_3, out half ShadowAtten_4)
        {
        half3 _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Direction_1_Vector3;
        half3 _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Color_2_Vector3;
        half _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_DistanceAtten_3_Float;
        half _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_ShadowAtten_4_Float;
        MainLight_half(IN.AbsoluteWorldSpacePosition, _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Direction_1_Vector3, _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Color_2_Vector3, _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_DistanceAtten_3_Float, _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_ShadowAtten_4_Float);
        Direction_1 = _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Direction_1_Vector3;
        Color_2 = _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_Color_2_Vector3;
        DistanceAtten_3 = _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_DistanceAtten_3_Float;
        ShadowAtten_4 = _MainLightCustomFunction_9157a6676a1f0984ae7f66422026d957_ShadowAtten_4_Float;
        }
        
        void Unity_Normalize_half3(half3 In, out half3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_ColorMask_float(float3 In, float3 MaskColor, float Range, out float Out, float Fuzziness)
        {
            float Distance = distance(MaskColor, In);
            Out = saturate(1 - (Distance - Range) / max(Fuzziness, 1e-5));
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e1161674d21445da80a94687d98739f4_Out_0_Vector4 = _ShadowColour;
            UnityTexture2D _Property_dd7f4a6742ac47d98f89f8a26d6220ef_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float _Property_a9141355fdb34bec95b894e4d8018ed4_Out_0_Boolean = _TileableTexture;
            float _Split_c683bce1946f4280b73440235e358c65_R_1_Float = (SHADERGRAPH_RENDERER_BOUNDS_MAX - SHADERGRAPH_RENDERER_BOUNDS_MIN)[0];
            float _Split_c683bce1946f4280b73440235e358c65_G_2_Float = (SHADERGRAPH_RENDERER_BOUNDS_MAX - SHADERGRAPH_RENDERER_BOUNDS_MIN)[1];
            float _Split_c683bce1946f4280b73440235e358c65_B_3_Float = (SHADERGRAPH_RENDERER_BOUNDS_MAX - SHADERGRAPH_RENDERER_BOUNDS_MIN)[2];
            float _Split_c683bce1946f4280b73440235e358c65_A_4_Float = 0;
            float2 _Vector2_55298d2e21e74f65bd91483b1980c02f_Out_0_Vector2 = float2(_Split_c683bce1946f4280b73440235e358c65_R_1_Float, _Split_c683bce1946f4280b73440235e358c65_B_3_Float);
            float2 _Branch_83fbacdfe98d4fddb4feb1c4b06e37eb_Out_3_Vector2;
            Unity_Branch_float2(_Property_a9141355fdb34bec95b894e4d8018ed4_Out_0_Boolean, _Vector2_55298d2e21e74f65bd91483b1980c02f_Out_0_Vector2, float2(1, 1), _Branch_83fbacdfe98d4fddb4feb1c4b06e37eb_Out_3_Vector2);
            float2 _TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Branch_83fbacdfe98d4fddb4feb1c4b06e37eb_Out_3_Vector2, float2 (0, 0), _TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2);
            float4 _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_dd7f4a6742ac47d98f89f8a26d6220ef_Out_0_Texture2D.tex, _Property_dd7f4a6742ac47d98f89f8a26d6220ef_Out_0_Texture2D.samplerstate, _Property_dd7f4a6742ac47d98f89f8a26d6220ef_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2) );
            float _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_R_4_Float = _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4.r;
            float _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_G_5_Float = _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4.g;
            float _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_B_6_Float = _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4.b;
            float _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_A_7_Float = _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4.a;
            float4 Color_9e86cbdbc1be45109aa1cdddb29a660a = IsGammaSpace() ? float4(1, 1, 1, 1) : float4(SRGBToLinear(float3(1, 1, 1)), 1);
            float _Comparison_04622d25d50d4a2686463e0eecd65b7e_Out_2_Boolean;
            Unity_Comparison_Equal_float((_SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4).x, (Color_9e86cbdbc1be45109aa1cdddb29a660a).x, _Comparison_04622d25d50d4a2686463e0eecd65b7e_Out_2_Boolean);
            UnityTexture2D _Property_4231ef4a9cb44eceb042efdaafe2689c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4231ef4a9cb44eceb042efdaafe2689c_Out_0_Texture2D.tex, _Property_4231ef4a9cb44eceb042efdaafe2689c_Out_0_Texture2D.samplerstate, _Property_4231ef4a9cb44eceb042efdaafe2689c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2) );
            float _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_R_4_Float = _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_G_5_Float = _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_B_6_Float = _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_A_7_Float = _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4.a;
            float4 _Branch_083517aa6629498aa03bc96051568fc8_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_04622d25d50d4a2686463e0eecd65b7e_Out_2_Boolean, _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4, _SampleTexture2D_1c8e87e94a2848e2a1e557e907f7aaa5_RGBA_0_Vector4, _Branch_083517aa6629498aa03bc96051568fc8_Out_3_Vector4);
            float4 _Multiply_cff6d0bf6dc741a5a6e259632d7da70f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_e1161674d21445da80a94687d98739f4_Out_0_Vector4, _Branch_083517aa6629498aa03bc96051568fc8_Out_3_Vector4, _Multiply_cff6d0bf6dc741a5a6e259632d7da70f_Out_2_Vector4);
            float4 _Divide_55f437e500eb4ea4aa6f3700d9a9fed4_Out_2_Vector4;
            Unity_Divide_float4(_Multiply_cff6d0bf6dc741a5a6e259632d7da70f_Out_2_Vector4, _SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4, _Divide_55f437e500eb4ea4aa6f3700d9a9fed4_Out_2_Vector4);
            float4 Color_e974d416c1dd4a5fa773108e877a61d6 = IsGammaSpace() ? float4(1, 1, 1, 1) : float4(SRGBToLinear(float3(1, 1, 1)), 1);
            float _Split_3534ac8fba06471b8c868f49f8af3dcc_R_1_Float = IN.VertexColor[0];
            float _Split_3534ac8fba06471b8c868f49f8af3dcc_G_2_Float = IN.VertexColor[1];
            float _Split_3534ac8fba06471b8c868f49f8af3dcc_B_3_Float = IN.VertexColor[2];
            float _Split_3534ac8fba06471b8c868f49f8af3dcc_A_4_Float = IN.VertexColor[3];
            float _OneMinus_8e1ea8e98c2049ccaeffc0d153961b95_Out_1_Float;
            Unity_OneMinus_float(_Split_3534ac8fba06471b8c868f49f8af3dcc_R_1_Float, _OneMinus_8e1ea8e98c2049ccaeffc0d153961b95_Out_1_Float);
            float _Property_c112c94881204477833c37fca0f56e28_Out_0_Float = _Falloff_Amount;
            float _Multiply_b0a2a514ae5641228cc8bd45a6353057_Out_2_Float;
            Unity_Multiply_float_float(-1, _Property_c112c94881204477833c37fca0f56e28_Out_0_Float, _Multiply_b0a2a514ae5641228cc8bd45a6353057_Out_2_Float);
            float _Subtract_2e41457bc6ba4235b345dd74ecec60a9_Out_2_Float;
            Unity_Subtract_float(_OneMinus_8e1ea8e98c2049ccaeffc0d153961b95_Out_1_Float, _Multiply_b0a2a514ae5641228cc8bd45a6353057_Out_2_Float, _Subtract_2e41457bc6ba4235b345dd74ecec60a9_Out_2_Float);
            float _Property_0576665307b745fa9087dad740d66048_Out_0_Float = _BumpScale;
            UnityTexture2D _Property_18db013475824cdf908febb8e5a55760_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BumpMap);
            Bindings_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float _NormalsWithNormalMap_1c717af811364118811418afd43d1ded;
            _NormalsWithNormalMap_1c717af811364118811418afd43d1ded.WorldSpaceNormal = IN.WorldSpaceNormal;
            float3 _NormalsWithNormalMap_1c717af811364118811418afd43d1ded_OutVector3_1_Vector3;
            SG_NormalsWithNormalMap_c74b7548c3364bb4e83c796ef9a61f5a_float(_Property_0576665307b745fa9087dad740d66048_Out_0_Float, _Property_18db013475824cdf908febb8e5a55760_Out_0_Texture2D, _TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2, _NormalsWithNormalMap_1c717af811364118811418afd43d1ded, _NormalsWithNormalMap_1c717af811364118811418afd43d1ded_OutVector3_1_Vector3);
            Bindings_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half _GetMainLight_c415046b46b1405b89882a5dcb35bd3c;
            _GetMainLight_c415046b46b1405b89882a5dcb35bd3c.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Direction_1_Vector3;
            half3 _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Color_2_Vector3;
            half _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_DistanceAtten_3_Float;
            half _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_ShadowAtten_4_Float;
            SG_GetMainLight_bf0598fe778624e4cbe47b8dc2e94161_half(_GetMainLight_c415046b46b1405b89882a5dcb35bd3c, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Direction_1_Vector3, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Color_2_Vector3, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_DistanceAtten_3_Float, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_ShadowAtten_4_Float);
            half3 _Normalize_fa91bca7108244ba8a2e0d6f3c5b63ed_Out_1_Vector3;
            Unity_Normalize_half3(_GetMainLight_c415046b46b1405b89882a5dcb35bd3c_Direction_1_Vector3, _Normalize_fa91bca7108244ba8a2e0d6f3c5b63ed_Out_1_Vector3);
            float _DotProduct_096dfc928d3842d0ae6619bbae9b7eee_Out_2_Float;
            Unity_DotProduct_float3(_NormalsWithNormalMap_1c717af811364118811418afd43d1ded_OutVector3_1_Vector3, _Normalize_fa91bca7108244ba8a2e0d6f3c5b63ed_Out_1_Vector3, _DotProduct_096dfc928d3842d0ae6619bbae9b7eee_Out_2_Float);
            float _Step_7aae93943d4f4c1e917042e241dbb1fd_Out_2_Float;
            Unity_Step_float(_Subtract_2e41457bc6ba4235b345dd74ecec60a9_Out_2_Float, _DotProduct_096dfc928d3842d0ae6619bbae9b7eee_Out_2_Float, _Step_7aae93943d4f4c1e917042e241dbb1fd_Out_2_Float);
            half _Multiply_6529366b67194a7683c9babe15e024bb_Out_2_Float;
            Unity_Multiply_half_half(_GetMainLight_c415046b46b1405b89882a5dcb35bd3c_DistanceAtten_3_Float, _GetMainLight_c415046b46b1405b89882a5dcb35bd3c_ShadowAtten_4_Float, _Multiply_6529366b67194a7683c9babe15e024bb_Out_2_Float);
            float _Multiply_4d2cf18f92ec4ef48490e75ae6e7d718_Out_2_Float;
            Unity_Multiply_float_float(_Step_7aae93943d4f4c1e917042e241dbb1fd_Out_2_Float, _Multiply_6529366b67194a7683c9babe15e024bb_Out_2_Float, _Multiply_4d2cf18f92ec4ef48490e75ae6e7d718_Out_2_Float);
            float4 _Lerp_16ebefcf70bd4274ac29f558bb8b8edd_Out_3_Vector4;
            Unity_Lerp_float4(_Divide_55f437e500eb4ea4aa6f3700d9a9fed4_Out_2_Vector4, Color_e974d416c1dd4a5fa773108e877a61d6, (_Multiply_4d2cf18f92ec4ef48490e75ae6e7d718_Out_2_Float.xxxx), _Lerp_16ebefcf70bd4274ac29f558bb8b8edd_Out_3_Vector4);
            float4 _Property_5d32e96fad2342f59819be5a66902198_Out_0_Vector4 = _BaseColor;
            float4 _Multiply_b61d9b67585d43f4aeff8c7139c82707_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_d84d26fcc8fc4784b5e2cb0cf83fb1ce_RGBA_0_Vector4, _Property_5d32e96fad2342f59819be5a66902198_Out_0_Vector4, _Multiply_b61d9b67585d43f4aeff8c7139c82707_Out_2_Vector4);
            float4 _Multiply_669960a70b714115997afe26c98d46fb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Lerp_16ebefcf70bd4274ac29f558bb8b8edd_Out_3_Vector4, _Multiply_b61d9b67585d43f4aeff8c7139c82707_Out_2_Vector4, _Multiply_669960a70b714115997afe26c98d46fb_Out_2_Vector4);
            UnityTexture2D _Property_d32ac20567a14f7cbef95bed5b24602d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            float4 _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d32ac20567a14f7cbef95bed5b24602d_Out_0_Texture2D.tex, _Property_d32ac20567a14f7cbef95bed5b24602d_Out_0_Texture2D.samplerstate, _Property_d32ac20567a14f7cbef95bed5b24602d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2) );
            float _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_R_4_Float = _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4.r;
            float _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_G_5_Float = _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4.g;
            float _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_B_6_Float = _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4.b;
            float _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_A_7_Float = _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4.a;
            float4 _Multiply_3f5187371efa4c309ce253c19be6b91a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_669960a70b714115997afe26c98d46fb_Out_2_Vector4, _SampleTexture2D_76ba5cb604374b2c83aa8894f3b457f8_RGBA_0_Vector4, _Multiply_3f5187371efa4c309ce253c19be6b91a_Out_2_Vector4);
            UnityTexture2D _Property_33fbd3c76e544f0cb820b9c7e9528e81_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_33fbd3c76e544f0cb820b9c7e9528e81_Out_0_Texture2D.tex, _Property_33fbd3c76e544f0cb820b9c7e9528e81_Out_0_Texture2D.samplerstate, _Property_33fbd3c76e544f0cb820b9c7e9528e81_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1abc2d20417c4993aecc2ba964288e6a_Out_3_Vector2) );
            float _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_R_4_Float = _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4.r;
            float _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_G_5_Float = _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4.g;
            float _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_B_6_Float = _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4.b;
            float _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_A_7_Float = _SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4.a;
            float4 _Property_e55d724b329d41da99bba5f3675593ba_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Emission) : _Emission;
            float4 _Multiply_75cc17e6a7dd4f7dae35ba302c8fef8d_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f3e95659e9514567a242a7b33c6c9989_RGBA_0_Vector4, _Property_e55d724b329d41da99bba5f3675593ba_Out_0_Vector4, _Multiply_75cc17e6a7dd4f7dae35ba302c8fef8d_Out_2_Vector4);
            float _ColorMask_74add8159864422b938c2b5816689c49_Out_3_Float;
            Unity_ColorMask_float((_Multiply_75cc17e6a7dd4f7dae35ba302c8fef8d_Out_2_Vector4.xyz), IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0)), 1, _ColorMask_74add8159864422b938c2b5816689c49_Out_3_Float, 0);
            float _OneMinus_e5094d91ff69434892b7b92767cc83f5_Out_1_Float;
            Unity_OneMinus_float(_ColorMask_74add8159864422b938c2b5816689c49_Out_3_Float, _OneMinus_e5094d91ff69434892b7b92767cc83f5_Out_1_Float);
            float4 _Blend_fef4764d9fa944a7b392609d355d7daa_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_3f5187371efa4c309ce253c19be6b91a_Out_2_Vector4, _Multiply_75cc17e6a7dd4f7dae35ba302c8fef8d_Out_2_Vector4, _Blend_fef4764d9fa944a7b392609d355d7daa_Out_2_Vector4, _OneMinus_e5094d91ff69434892b7b92767cc83f5_Out_1_Float);
            surface.BaseColor = (_Blend_fef4764d9fa944a7b392609d355d7daa_Out_2_Vector4.xyz);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Falloff_Amount;
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float4 _ShadowColour;
        float4 _DetailMap_TexelSize;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        float4 _Emission;
        float4 _BumpMap_TexelSize;
        float _BumpScale;
        float _TileableTexture;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Falloff_Amount;
        float4 _BaseMap_TexelSize;
        float4 _BaseColor;
        float4 _ShadowColour;
        float4 _DetailMap_TexelSize;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        float4 _Emission;
        float4 _BumpMap_TexelSize;
        float _BumpScale;
        float _TileableTexture;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}
