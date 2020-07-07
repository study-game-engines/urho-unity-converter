#include "Uniforms.hlsl"
#include "Samplers.hlsl"
#include "Transform.hlsl"

#ifndef D3D11

// D3D9 uniforms
uniform float cWindHeightFactor;
uniform float cWindHeightPivot;
uniform float cWindPeriod;
uniform float2 cWindWorldSpacing;

#else

// D3D11 constant buffer
cbuffer CustomVS : register(b6)
{
    float cWindHeightFactor;
    float cWindHeightPivot;
    float cWindPeriod;
    float2 cWindWorldSpacing;
}

#endif

void VS(float4 iPos : POSITION,
    #ifdef SKINNED
        float4 iBlendWeights : BLENDWEIGHT,
        int4 iBlendIndices : BLENDINDICES,
    #endif
    #ifdef INSTANCED
        float4x3 iModelInstance : TEXCOORD4,
    #endif
    float2 iTexCoord : TEXCOORD0,
    #ifdef VSM_SHADOW
        out float4 oTexCoord : TEXCOORD0,
    #else
        out float2 oTexCoord : TEXCOORD0,
    #endif
    out float4 oPos : OUTPOSITION)
{
    float4x3 modelMatrix = iModelMatrix;
    float3 worldPos = GetWorldPos(modelMatrix);

    float3 relativePos = mul(iPos.xyz, (float3x3)modelMatrix);
    float windStrength = max(relativePos.y - cWindHeightPivot, 0.0) * cWindHeightFactor;
    float windPeriod = cElapsedTime * cWindPeriod + dot(worldPos.xz, cWindWorldSpacing);
    worldPos.x += windStrength * sin(windPeriod);
    worldPos.z -= windStrength * cos(windPeriod);

    oPos = GetClipPos(worldPos);
    #ifdef VSM_SHADOW
        oTexCoord = float4(GetTexCoord(iTexCoord), oPos.z, oPos.w);
    #else
        oTexCoord = GetTexCoord(iTexCoord);
    #endif
}