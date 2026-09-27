// p_dissolve_reveal
//
// Organic directional reveal for full-screen background sprites and aligned
// overlays. Reveals progressively along `dir`, with a noisy front edge and a
// bright emissive seam. Drive `threshold` 0 -> 1 to animate the sweep.
//
// Front is computed in BACKGROUND UV (REF draw space) from screen_coords after
// undoing the game view transform (view_off / view_scale). Overlays share the
// same uniforms as the BG — no per-sprite uv_rect / luv_map.

extern number threshold;      // reveal progress: 0 = nothing shown, 1 = fully shown
extern vec2   dir;            // reveal direction in bg uv space, (0,1) = top -> bottom
extern number noise_amp;      // how much the front wobbles (uv units)
extern number noise_scale;    // frequency of the front wobble
extern number edge_width;     // half-width of the glowing seam (uv units)
extern number edge_softness;  // anti-alias softness of the cut (uv units)
extern vec4   edge_color;     // seam color: rgb 0..1, a = seam opacity
extern vec4   edge_color_core; // color del centro del halo
extern number edge_core_width; // centro: fraccion del ancho del halo con color pleno (0..1); 0 = off
extern number edge_core_blend; // transicion corta centro -> edge_color (fraccion del ancho)
extern vec4   bg_rect;        // nightfall quad in REF draw space (x,y,w,h)
extern vec2   view_off;       // love translate before draw (rox, roy)
extern number view_scale;     // love scale before draw (game_scale * camera.zoom)
extern number invert;         // 0 = revelar (noche), 1 = recortar (día): visible donde el
                              // frente NO pasó, complementario exacto del reveal

// Ruido determinístico (suma de senos): estable en precisión y replicable EXACTO
// en Lua (scripts.nightfall_dissolve.front_noise). p ya viene escalado (bluv * noise_scale).
float front_noise(vec2 p) {
    return clamp(0.5
        + 0.30 * sin(p.x * 2.1 + p.y * 1.3)
        + 0.20 * sin(p.x * 1.0 - p.y * 2.6 + 1.7), 0.0, 1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords) * color;

    // bg_rect sin setear (el update del driver lo carga 1-2 ticks despues del insert):
    // sin el, bluv/prog dan NaN y el resultado depende del GPU (en algunos dibuja la
    // noche completa un par de frames). No configurado = no revelado.
    if (bg_rect.z <= 0.0 || bg_rect.w <= 0.0) {
        // recortando (invert): día pleno hasta que el driver publica su rect — devolver
        // transparente acá haría parpadear la imagen de día 1-2 ticks al cablearse
        if (invert > 0.5) {
            return tex;
        }
        return vec4(0.0);
    }

    // Undo game view transform so bluv is camera/scale-invariant (REF space)
    float vs = (view_scale > 0.0) ? view_scale : 1.0;
    vec2 ref_pos = (screen_coords - view_off) / vs;
    vec2 bluv = (ref_pos - bg_rect.xy) / bg_rect.zw;

    // progress along the reveal direction, remapped to 0..1 for any axis dir
    float prog = dot(bluv - vec2(0.5), normalize(dir)) + 0.5;

    float n = front_noise(bluv * noise_scale);

    // remap so threshold=0 hides everything and threshold=1 shows everything,
    // independent of the noise offset
    float front = threshold * (1.0 + noise_amp) - noise_amp * (1.0 - n);

    // revealed where prog is behind the front; soft edge for anti-aliasing.
    // NOTE: smoothstep requires edge0 < edge1 (edge0 > edge1 is undefined in
    // GLSL), so build the descending ramp as 1 - smoothstep(lo, hi, x).
    float reveal = 1.0 - smoothstep(front - edge_softness, front + edge_softness, prog);
    reveal = mix(reveal, 1.0 - reveal, invert);

    // glowing seam: peaks at the front line, suppressed at the very start/end.
    // Sin costura propia al recortar (invert): el fondo y la noche ya la dibujan ahí.
    float band = 1.0 - smoothstep(0.0, edge_width, abs(prog - front));
    band *= step(0.001, threshold) * step(threshold, 0.999);
    band *= 1.0 - invert;

    // Composite the purple seam OVER the revealed night, then output a straight
    // color for the alphamultiply blend. Accumulating in premultiplied space
    // keeps the seam's soft flanks the right tone/brightness even though the
    // background is baked to a premultiplied canvas in dev (image_db canvas path).
    // centro plano + transicion corta: d = distancia al frente en fracciones del halo.
    // ct = 1 dentro del centro (color pleno), degrada a 0 en el tramo de blend.
    // edge_core_width en 0 (o sin setear) = comportamiento original, un solo color.
    vec4 ec = edge_color;
    if (edge_core_width > 0.0) {
        float d  = abs(prog - front) / max(edge_width, 1e-5);
        float ct = 1.0 - smoothstep(edge_core_width,
                                    edge_core_width + max(edge_core_blend, 1e-4), d);
        ec = mix(edge_color, edge_color_core, ct);
    }
    float k  = band * ec.a * tex.a;        // seam only where night art exists (no tint on alpha 0)
    float na = tex.a * reveal;             // night coverage
    float a  = k + na * (1.0 - k);
    vec3  prem = ec.rgb * k + tex.rgb * na * (1.0 - k);

    return vec4(prem / max(a, 1e-4), a);
}
