extern vec2 c_size;      // canvas size
extern number c_ss;  // canvas supersampling

#ifdef GL_ES
extern number thickness;
extern vec4 outline_color;
extern int samples;
extern number threshold;
#else
// Linux Mesa Intel compiler optimizes the outline_color if not defined
extern number thickness = 1.5;
extern vec4 outline_color = vec4(1.0,1.0,0.0,0.5);
extern int samples = 5;
extern number threshold = 0.6;
#endif

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // defaults
    number _thickness = 1.5; // pixels
    vec4 _outline_color = vec4(1.0,1.0,0.0,0.5);
    int _samples = 5;
    number _threshold = 0.6;
    
    if (thickness != 0.0) { _thickness = thickness; }
    if (outline_color != vec4(0.0,0.0,0.0,0.0)) { _outline_color = outline_color; }    
    if (samples != 0)     { _samples = samples; }
    if (threshold != 0.0) { _threshold = threshold; } 

    vec4 texcolor = Texel(texture,texture_coords);
    if (texcolor[3] < 1.0) {
        int steps = int(ceil(_thickness * float(_samples) * c_ss));
        for (int x=-steps; x<=steps; x++) {
            for (int y=-steps; y<=steps; y++) {
                vec2 tc = vec2(texture_coords.x + float(x)/(float(_samples) * c_size.x),
                               texture_coords.y + float(y)/(float(_samples) * c_size.y));
                vec4 c = Texel(texture,tc);
                if ( c[3] > _threshold ) {
                    vec4 oc = texcolor[3] * texcolor + ( 1.0 - texcolor[3] ) * _outline_color;
                    return vec4(oc[0],oc[1],oc[2],_outline_color[3]) * color;
                }
            }
        }
    }            
    return texcolor * color;
}
