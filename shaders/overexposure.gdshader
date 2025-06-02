shader_type canvas_item;
render_mode unshaded; // 不需要光照計算

// Uniforms (可在編輯器中調整的參數)
uniform float exposure : hint_range(1.0, 10.0) = 1.5; // 控制過曝強度 (1.0 = 無效果)
uniform float threshold : hint_range(0.0, 1.0) = 0.8; // 控制哪些亮度以上的像素會受影響

void fragment() {
    // 取得目前像素的顏色
    vec4 color = texture(TEXTURE, UV);

    // 計算像素的感知亮度 (Luminance)
    // 使用標準的亮度權重 (NTSC/Rec.709)
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    // 使用 smoothstep 讓效果在接近 threshold 時平滑過渡
    // 當 luminance <= threshold 時，multiplier = 1.0 (無變化)
    // 當 luminance 接近 1.0 (或HDR更高) 時，multiplier 接近 exposure
    float multiplier = mix(1.0, exposure, smoothstep(threshold, 1.0, luminance));

    // 將原始顏色乘以計算出的係數
    vec3 final_rgb = color.rgb * multiplier;

    // 輸出最終顏色。 Godot 的渲染管線會自動處理最終的顏色箝位 (Clamping) 到 0-1 範圍 (在 LDR 環境下)
    // 或由 Tonemapping 處理 (在 HDR 環境下)。
    // 因此我們不需要手動 clamp(final_rgb, 0.0, 1.0); 除非有特殊需求。
    COLOR = vec4(final_rgb, color.a); // 保留原始的 alpha 值
}