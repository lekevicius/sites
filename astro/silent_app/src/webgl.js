import { fragmentShaderSource, vertexShaderSource } from "./shader.js";

function compileShader(gl, type, source) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    const info = gl.getShaderInfoLog(shader);
    gl.deleteShader(shader);
    throw new Error(info || "Shader compile failed");
  }
  return shader;
}

function makeProgram(gl, vsSource, fsSource) {
  const program = gl.createProgram();
  const vs = compileShader(gl, gl.VERTEX_SHADER, vsSource);
  const fs = compileShader(gl, gl.FRAGMENT_SHADER, fsSource);
  gl.attachShader(program, vs);
  gl.attachShader(program, fs);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    const info = gl.getProgramInfoLog(program);
    gl.deleteProgram(program);
    throw new Error(info || "Program link failed");
  }
  gl.deleteShader(vs);
  gl.deleteShader(fs);
  return program;
}

export function initShaderBackground(canvas) {
  const gl = canvas.getContext("webgl2", { antialias: false, depth: false, stencil: false });
  if (!gl) {
    document.body.style.background = "#0a0d13";
    return;
  }

  const program = makeProgram(gl, vertexShaderSource, fragmentShaderSource);
  const posLoc = gl.getAttribLocation(program, "a_pos");
  const uResLoc = gl.getUniformLocation(program, "u_res");
  const uTimeLoc = gl.getUniformLocation(program, "u_time");
  const uDprLoc = gl.getUniformLocation(program, "u_dpr");

  const quad = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, quad);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1, 1,-1, -1,1, -1,1, 1,-1, 1,1]), gl.STATIC_DRAW);

  let dpr = 1, raf = 0;
  const start = performance.now();

  function resize() {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    const w = Math.floor(window.innerWidth * dpr);
    const h = Math.floor(window.innerHeight * dpr);
    if (canvas.width !== w || canvas.height !== h) {
      canvas.width = w;
      canvas.height = h;
    }
    gl.viewport(0, 0, canvas.width, canvas.height);
  }

  function frame(now) {
    resize();
    gl.useProgram(program);
    gl.bindBuffer(gl.ARRAY_BUFFER, quad);
    gl.enableVertexAttribArray(posLoc);
    gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);
    gl.uniform2f(uResLoc, canvas.width, canvas.height);
    gl.uniform1f(uTimeLoc, (now - start) * 0.001);
    gl.uniform1f(uDprLoc, dpr);
    gl.drawArrays(gl.TRIANGLES, 0, 6);
    raf = requestAnimationFrame(frame);
  }

  window.addEventListener("resize", resize, { passive: true });
  raf = requestAnimationFrame(frame);

  return () => {
    cancelAnimationFrame(raf);
    window.removeEventListener("resize", resize);
  };
}
