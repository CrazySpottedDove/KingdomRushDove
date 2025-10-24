extern vec2 c_size;      // canvas size
extern number c_ss;      // canvas supersampling

extern number thickness;
extern int samples;
extern vec4 glow_color;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // default values
    number _thickness = 1.5; // pixels
    int _samples = 5;
    vec4 _glow_color = vec4(1.0,1.0,0.0,0.5);
    
    if (thickness != 0.0) { _thickness = thickness; }
    if (samples != 0)     { _samples = samples; }
    if (glow_color != vec4(0.0,0.0,0.0,0.0)) { _glow_color = glow_color; }    
    
    vec4 texcolor = Texel(texture,texture_coords);
    if (texcolor[3] < 1.0) {
        bool inside = false;
        int steps = int(ceil(_thickness * float(_samples) * c_ss));
        int cnt = 0;
        float avg = 0.0;
        for (int x=-steps; x<=steps; x++) {
            for (int y=-steps; y<=steps; y++) {                        
                vec2 tc = vec2(texture_coords.x + float(x)/(float(_samples) * c_size.x),
                               texture_coords.y + float(y)/(float(_samples) * c_size.y));
                vec4 c = Texel(texture,tc);
                avg = avg + c[3];
                cnt = cnt + 1;
            }
        }
        float blur_alpha = sqrt(avg / float(cnt)); 
                
        vec4 c = texcolor[3] * texcolor + ( 1.0 - texcolor[3] ) * _glow_color ;
        
        return vec4(c[0],c[1],c[2],blur_alpha * _glow_color[3]);

    }            
    return texcolor * color;
}
