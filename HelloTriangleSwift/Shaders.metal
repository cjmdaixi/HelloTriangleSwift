//
//  Shaders.metal
//  HelloTriangleSwift
//
//  Created by 陈锦明 on 2021/2/2.
//

#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"

struct VertexOut
{
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertexShader(const uint vertexId[[vertex_id]],
                              const device float3 *position[[buffer(0)]],
                              const device float3 *color[[buffer(1)]],
                              const device float2 *viewport[[buffer(2)]]){
    VertexOut vo;
    auto c = color[vertexId];
    vo.color = float4(c, 1.0f);
    float2 viewportSize = float2(*viewport);
    
    vo.position = float4(0.0, 0.0, 0.0, 1.0);
    vo.position.xy = position[vertexId].xy / (viewportSize);
    return vo;
}

struct FragmentOut{
    float4 color;
};

fragment FragmentOut fragmentShader(const VertexOut vi[[stage_in]]){
    FragmentOut fo;
    fo.color = vi.color;
    return fo;
}
