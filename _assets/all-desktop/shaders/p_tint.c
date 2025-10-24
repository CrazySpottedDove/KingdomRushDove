extern vec4 tint_color;
extern number tint_factor;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // default values
    vec4 _tint_color = vec4(1.0,1.0,1.0,1.0);
    number _tint_factor = 0.5;    
    if (tint_color != vec4(0.0,0.0,0.0,0.0)) { _tint_color = tint_color; }
    if (tint_factor != 0.0) { _tint_factor = tint_factor; }

    vec4 texcolor = Texel(texture,texture_coords);

    vec4 c = mix(texcolor, _tint_color, vec4(vec3(_tint_factor), 0.0));
    c[3] = texcolor[3];

    return c;    
}
