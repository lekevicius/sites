import "./styles.css";
import { initShaderBackground } from "./webgl.js";

const canvas = document.getElementById("shader");
if (canvas instanceof HTMLCanvasElement) {
  initShaderBackground(canvas);
}
