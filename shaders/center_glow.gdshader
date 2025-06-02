shader_type canvas_item;

// 發光顏色 (RGBA)，Alpha 通道影響基礎強度
uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.0, 0.75);
// 發光半徑 (0.0 表示無發光，0.5 表示發光到邊緣中心，約 0.707 表示發光到角落)
uniform float glow_radius : hint_range(0.0, 1.0) = 0.5;
// 發光強度倍增器
uniform float glow_intensity : hint_range(0.0, 10.0) = 1.5;
// 中心點 (通常是 0.5, 0.5)
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    // 獲取原始紋理顏色
    vec4 tex_color = texture(TEXTURE, UV);

    // 計算當前像素 UV 到中心點的距離
    // 紋理座標 UV 範圍是 0.0 到 1.0
    // 中心點是 vec2(0.5, 0.5)
    // 最大距離是從中心到角落，即 distance(vec2(0.5), vec2(0.0)) = sqrt(0.5^2 + 0.5^2) = sqrt(0.5) ≈ 0.707
    float dist = distance(UV, center);

    // 計算發光因子 (Glow Factor)
    // 使用 smoothstep 產生平滑的過渡效果
    // smoothstep(edge0, edge1, x): 如果 x <= edge0，返回 0；如果 x >= edge1，返回 1；在 edge0 和 edge1 之間平滑插值。
    // 我們需要反過來：距離為 0 時因子為 1，距離為 glow_radius 時因子為 0。
    // 因此使用 1.0 - smoothstep(...)
    // 將 glow_radius 映射到實際距離範圍 (可選，如果希望 radius=1.0 精確對應到角落)
    // float effective_radius = glow_radius * 0.7071; // 可選的映射
    // float glow_factor = 1.0 - smoothstep(0.0, effective_radius, dist); // 使用映射的半徑
    float glow_factor = 1.0 - smoothstep(0.0, glow_radius, dist); // 使用 0-1 範圍的半徑

    // 應用強度倍增器和發光顏色的 Alpha
    glow_factor *= glow_intensity * glow_color.a;

    // 將發光顏色 (RGB) 疊加到原始紋理顏色上
    // 只在原始紋理有顏色的地方疊加（保留原始 Alpha）
    vec3 final_rgb = tex_color.rgb + glow_color.rgb * glow_factor;

    // 設置最終顏色
    // COLOR 是內建的輸出變數
    COLOR = vec4(final_rgb, tex_color.a);

    // --- 可選：如果你希望發光效果也影響 Alpha 通道 (讓發光區域變得更不透明) ---
    // final_color.a = max(tex_color.a, glow_color.a * glow_factor); // 取較大的 Alpha 值
    // final_color.a = clamp(tex_color.a + glow_color.a * glow_factor, 0.0, 1.0); // 疊加 Alpha 值並限制在 0-1
    // COLOR = vec4(final_rgb, final_alpha);
    // ---

    // --- 可選：如果你想讓發光是純粹疊加而不考慮原始紋理顏色 ---
    // COLOR = tex_color + vec4(glow_color.rgb * glow_factor * glow_intensity, 0.0);
    // ---
}