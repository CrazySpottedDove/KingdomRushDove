// dashed_path.c — fragment-only for shader_db
extern number dash_length;   // 每段虚线长度
extern number gap_length;    // 间隔长度
extern number dash_offset;   // 虚线滚动偏移

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // 将累计距离编码在 texture_coords.x
    float dist   = texture_coords.x;
    float period = dash_length + gap_length;
    float m      = mod(dist - dash_offset, period);

    if (m < dash_length) {
        return vec4(1.0, 0.0, 0.0, 0.392) * color;
    }
    else {
        // 在间隙部分透明
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
}