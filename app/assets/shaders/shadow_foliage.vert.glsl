// Copyright 2016 Benjamin Glatzel
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#version 450

/* __PREPROCESSOR DEFINES__ */

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

#include "lib_noise.glsl"
#include "surface_vertex.inc.glsl"

out gl_PerVertex
{
  vec4 gl_Position;
};

// Ubos
PER_INSTANCE_UBO;

// Input
INPUT();

// Output
layout (location = 0) out vec2 outUV0;

void main()
{
  vec3 localPos = inPosition.xyz;
  const vec3 worldPos = (uboPerInstance.worldMatrix 
  	* vec4(inPosition.xyz, 1.0)).xyz;
  const vec3 worldNormal = normalize((uboPerInstance.worldMatrix 
  	* vec4(inNormal.xyz, 0.0)).xyz);

  const vec2 windStrength = calcWindStrength(uboPerInstance.data0.w);
  
#if defined (GRASS)
  applyGrassWind(localPos, worldPos,
    uboPerInstance.data0.w, windStrength);
#else
  applyTreeWind(localPos, worldPos, worldNormal, inColor.r, 
    uboPerInstance.data0.w, windStrength);
#endif // GRASS

  gl_Position = uboPerInstance.worldViewProjMatrix * vec4(localPos, 1.0);

  outUV0 = inUV0; 
}
