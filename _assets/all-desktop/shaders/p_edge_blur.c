extern vec2 c_size;      // canvas size
extern number c_ss;      // canvas supersampling

extern number thickness;
extern int samples;
extern number threshold;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // default values
    number _thickness = 1.5; // pixels
    int _samples = 5;
    number _threshold = 0.6;
    
    if (thickness != 0.0) { _thickness = thickness; }
    if (samples != 0)     { _samples = samples; }
    if (threshold != 0.0) { _threshold = threshold; }    
    
    vec4 texcolor = Texel(texture,texture_coords);
    if (texcolor[3] < 1.0) {
        int steps = int(ceil(_thickness * float(_samples) * c_ss));
        int cnt = 0;
        vec4 csum = vec4(0.0,0.0,0.0,0.0);
        for (int x=-steps; x<=steps; x++) {
            for (int y=-steps; y<=steps; y++) {                        
                vec2 tc = vec2(texture_coords.x + float(x)/(float(_samples) * c_size.x),
                               texture_coords.y + float(y)/(float(_samples) * c_size.y));
                vec4 c = Texel(texture,tc);
                csum = csum + c;
                cnt = cnt + 1;
            }
        }
        vec4 cavg = csum / float(cnt);
        vec4 c = texcolor[3] * texcolor + ( 1.0 - texcolor[3] ) * cavg;
        return c;
    }            
    return texcolor * color;
}
