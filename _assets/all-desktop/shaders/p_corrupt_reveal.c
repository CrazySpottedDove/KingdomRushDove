// p_corrupt_reveal
//
// Radial corner reveal for the stage 16 corruption masks. Reveals the sprite
// progressively from `origin` (a corner, in mask uv) outwards, with a noisy
// front and a pale mist band riding the advancing edge (the corruption fog),
// instead of p_dissolve_reveal's directional sweep + emissive seam.
// Drive `threshold` 0 -> 1 over time to animate the spread.
//
// Front is computed in MASK UV (REF draw space) from screen_coords after undoing
// the game view transform. Overlays share the same uniforms as their source mask.

extern number threshold;      // reveal progress: 0 = nothing shown, 1 = fully shown
extern vec2   origin;         // corner the corruption spreads from, in mask uv (e.g. (0,1))
extern vec2   dist_scale;     // aspect/reach correction: prog = length((bluv-origin)*dist_scale).
                              // Set from Lua so prog hits exactly 1.0 at the opposite corner.
extern number noise_amp;      // how much the front wobbles (uv units)
extern number noise_scale;    // frequency of the front wobble
extern number edge_width;     // half-width of the mist band (uv units)
extern number edge_softness;  // anti-alias softness of the cut (uv units)
extern vec4   edge_color;     // mist color: rgb 0..1, a = mist opacity
extern vec4   mask_rect;      // source mask quad in REF draw space (x,y,w,h)
extern vec2   view_off;       // love translate before draw (rox, roy)
extern number view_scale;     // love scale before draw (game_scale * camera.zoom)
extern number invert;         // 0 = revelar (máscara nueva), 1 = recortar (máscara vieja):
                              // visible donde el frente NO pasó, complementario exacto del reveal

// Ruido determinístico (suma de senos), idéntico al de p_dissolve_reveal: estable
// en precisión en cualquier GPU.
float front_noise(vec2 p) {
    return clamp(0.5
        + 0.30 * sin(p.x * 2.1 + p.y * 1.3)
        + 0.20 * sin(p.x * 1.0 - p.y * 2.6 + 1.7), 0.0, 1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords) * color;

    // mask_rect sin setear (el update del decal lo carga 1-2 ticks despues del insert):
    // sin el, bluv/prog dan NaN y el resultado depende del GPU. No configurado = no revelado.
    if (mask_rect.z <= 0.0 || mask_rect.w <= 0.0) {
        return vec4(0.0);
    }

    float vs = (view_scale > 0.0) ? view_scale : 1.0;
    vec2 ref_pos = (screen_coords - view_off) / vs;
    vec2 bluv = (ref_pos - mask_rect.xy) / mask_rect.zw;

    // frente radial: distancia (corregida por aspecto) a la esquina de origen, 0..1
    float prog = length((bluv - origin) * dist_scale);

    // ruido del frente (ondula el borde de avance)
    float n = front_noise(bluv * noise_scale);

    // remap so threshold=0 hides everything and threshold=1 shows everything,
    // independent of the noise offset
    float front = threshold * (1.0 + noise_amp) - noise_amp * (1.0 - n);

    // revealed where prog is behind the front; soft edge for anti-aliasing.
    // NOTE: smoothstep requires edge0 < edge1, so build the descending ramp
    // as 1 - smoothstep(lo, hi, x).
    float reveal = 1.0 - smoothstep(front - edge_softness, front + edge_softness, prog);
    reveal *= step(0.001, threshold);
    reveal = max(reveal, step(0.9999, threshold));
    reveal = mix(reveal, 1.0 - reveal, invert);

    // banda de niebla sobre el frente. La cobertura se modula con un segundo
    // muestreo de ruido desfasado con el avance -> jirones que se mueven con él.
    float band = 1.0 - smoothstep(0.0, edge_width, abs(prog - front));
    band *= 0.45 + 0.55 * front_noise(bluv * noise_scale * 2.7
                                      + vec2(threshold * 5.0, -threshold * 3.0));
    band *= step(0.001, threshold) * step(threshold, 0.999);
    // sin niebla propia al recortar: el fondo y la máscara nueva ya la dibujan sobre
    // el mismo frente (sumarla acá la haría más densa donde se superponen)
    band *= 1.0 - invert;

    // Composite the mist OVER the revealed mask, then output a straight color for
    // the alphamultiply blend. Accumulating in premultiplied space keeps the mist's
    // soft flanks the right tone/brightness even though the background is baked to
    // a premultiplied canvas in dev (image_db canvas path).
    float k  = band * edge_color.a * tex.a;   // mist coverage, solo donde la máscara tiene imagen
    float na = tex.a * reveal;             // mask coverage
    float a  = k + na * (1.0 - k);
    vec3  prem = edge_color.rgb * k + tex.rgb * na * (1.0 - k);

    return vec4(prem / max(a, 1e-4), a);
}
