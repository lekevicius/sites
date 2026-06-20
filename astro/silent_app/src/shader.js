export const vertexShaderSource = `#version 300 es
in vec2 a_pos;
void main() {
  gl_Position = vec4(a_pos, 0.0, 1.0);
}
`;

export const fragmentShaderSource = `#version 300 es
precision highp float;
out vec4 outColor;

uniform vec2 u_res;
uniform float u_time;
uniform float u_dpr;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 345.45));
  p += dot(p, p + 34.345);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0, a = 0.5;
  mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
  for (int i = 0; i < 5; i++) { v += a * noise(p); p = m * p; a *= 0.52; }
  return v;
}

void main() {
  float t = u_time * 0.56;
  float blockSize = 26.0 * u_dpr;
  vec2 cell = floor(gl_FragCoord.xy / blockSize);
  vec2 p = ((cell + 0.5) * blockSize / u_res - 0.5) * vec2(u_res.x / u_res.y, 1.0);

  vec2 dir = normalize(vec2(-1.0, -0.36));
  float along = dot(p, dir);
  float across = dot(p, vec2(dir.y, -dir.x));

  float bend = fbm(vec2(along * 2.2 + t * 0.5, across * 1.35 - t * 0.24));
  bend += 0.33 * fbm(vec2(along * 4.8 - t * 1.25, across * 2.1 + t * 0.35));

  float distA = abs(across - 0.19 * sin(along * 4.1 + t * 1.2 + bend * 3.0));
  float distB = abs(across + 0.14 - 0.16 * sin(along * 5.6 - t * 1.35 - bend * 2.1));
  float distC = abs(across - 0.11 - 0.12 * sin(along * 7.3 + t * 1.7 + bend * 1.8));

  float strandWide = smoothstep(0.71, 0.077, distA) * 0.72 +
                     smoothstep(0.63, 0.068, distB) * 0.60 +
                     smoothstep(0.51, 0.054, distC) * 0.48;

  float coreSharp = exp(-distA * 56.0) * (0.55 + 0.45 * smoothstep(0.65, 1.0, noise(vec2(along * 8.2 + t * 2.8, distA * 18.0)))) +
                    exp(-distB * 61.0) * (0.50 + 0.40 * smoothstep(0.70, 1.0, noise(vec2(along * 10.4 - t * 3.1, distB * 22.0)))) +
                    exp(-distC * 66.0) * (0.45 + 0.35 * smoothstep(0.68, 1.0, noise(vec2(along * 11.9 + t * 2.4, distC * 27.0))));

  float strandPixels = smoothstep(0.10, 1.0, floor(clamp(strandWide * 0.76 + coreSharp * 0.98, 0.0, 2.2) * 7.0) / 7.0);

  float row = cell.y;
  float sliceGlitch = smoothstep(0.88, 1.0, noise(vec2(row * 0.09, t * 4.2))) *
                      smoothstep(0.82, 1.0, noise(vec2(cell.x * 0.025 + t * 8.2, row * 0.27))) *
                      pow(0.5 + 0.5 * sin(t * 42.0 + row * 0.9), 3.0) * 0.85;

  float screenNoise = (hash(gl_FragCoord.xy + vec2(t * 680.0, -t * 540.0)) * 0.5 +
                       hash(gl_FragCoord.xy * vec2(1.37, 0.93) + vec2(-t * 430.0, t * 720.0)) * 0.3 +
                       hash(vec2(gl_FragCoord.y * 0.75 + floor(t * 120.0), gl_FragCoord.x)) * 0.2 - 0.5) * 0.2;

  float coreBright = clamp(coreSharp, 0.0, 2.2) * 0.65;
  float tonal = 0.06 + 0.03 * smoothstep(1.2, 0.2, length(p * vec2(0.9, 0.74))) +
                strandWide * 0.06 + strandPixels * 0.08 + coreBright + sliceGlitch;

  vec3 col = vec3(0.03, 0.038, 0.055) +
             vec3(0.48, 0.54, 0.65) * tonal +
             vec3(0.22, 0.26, 0.32) * clamp(coreBright, 0.0, 1.0) +
             vec3(0.22, 0.30, 0.42) * sliceGlitch * 0.9 +
             vec3(0.10, 0.12, 0.16) * screenNoise;

  col *= (0.75 + 0.25 * sin(gl_FragCoord.x * 3.14159265)) * (0.55 + 0.45 * step(0.5, fract(gl_FragCoord.x * 0.5)));

  outColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
`;
