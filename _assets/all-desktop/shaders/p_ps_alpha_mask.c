// p_ps_alpha_mask
//
// Draw the particle (batch texture) normally; multiply alpha by a mask sprite
// placed once in REF space. Optional second quad (same atlas Image) for
// disjoint halves — ma = max(a1, a2). Outside both quads -> alpha 0.

extern Image mask;
extern vec4  mask_uv_rect;   // atlas uv of mask sprite 1 (x, y, w, h)
extern vec4  mask_rect;      // sprite 1 quad in REF draw space (x, y, w, h)
extern vec4  mask_uv_rect_2; // atlas uv of mask sprite 2 (w<=0 disables)
extern vec4  mask_rect_2;    // sprite 2 quad in REF draw space
extern vec2  view_off;       // love translate before draw (rox, roy)
extern number view_scale;    // love scale before draw (game_scale * camera.zoom)

float mask_a(vec2 ref_pos, vec4 rect, vec4 uv_rect) {
    if (rect.z <= 0.0 || rect.w <= 0.0) {
        return 0.0;
    }
    vec2 bluv = (ref_pos - rect.xy) / rect.zw;
    float inside = step(0.0, bluv.x) * step(bluv.x, 1.0)
                 * step(0.0, bluv.y) * step(bluv.y, 1.0);
    vec2 muv = uv_rect.xy + bluv * uv_rect.zw;
    return Texel(mask, muv).a * inside;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords) * color;

    float vs = (view_scale > 0.0) ? view_scale : 1.0;
    vec2 ref_pos = (screen_coords - view_off) / vs;

    float ma = mask_a(ref_pos, mask_rect, mask_uv_rect);
    if (mask_rect_2.z > 0.0 && mask_rect_2.w > 0.0) {
        ma = max(ma, mask_a(ref_pos, mask_rect_2, mask_uv_rect_2));
    }

    tex.a *= ma;
    return tex;
}
