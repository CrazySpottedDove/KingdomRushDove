extern vec2 c_size;      // canvas size
extern number c_ss;      // canvas supersampling

extern int samples;
extern number shadow_width;
extern number shadow_height;
extern vec4 shadow_color;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // default values
    int _samples = 5;
    number _shadow_width = 0.5;
    number _shadow_height = 2.0;
    vec4 _shadow_color = vec4(0.0,0.0,0.0,1.0);

    if (samples       != 0  ) { _samples = samples; }
    if (shadow_width  != 0.0) { _shadow_width = shadow_width; }
    if (shadow_height != 0.0) { _shadow_height = shadow_height; } 
    if (shadow_color  != vec4(0.0,0.0,0.0,0.0)) { _shadow_color = shadow_color; }
    
    vec4 texcolor = Texel(texture,texture_coords);
    if (texcolor[3] < 1.0) {
        // vertical component
        int y_steps = int(ceil(_shadow_height * float(_samples) * c_ss));
        int x_steps = int(ceil(_shadow_width * float(_samples) * c_ss));
        int cnt = 0;
        float avg = 0.0;
        int y_start = 0;
        int y_stop = y_steps;
        if (_shadow_height > 0.0) {
            y_start = -y_steps;
            y_stop = 0;
        }
        for (int y=y_start; y<=y_stop; y++) {
            for (int x=-x_steps; x<=x_steps; x++) {
                vec2 tc = vec2(texture_coords.x + float(x)/(float(_samples) * c_size.x),
                               texture_coords.y + float(y)/(float(_samples) * c_size.y));
                vec4 c = Texel(texture,tc);
                avg = avg + c[3];
                cnt = cnt + 1;
                
            }
        }                
        float blur_alpha = sqrt(avg / float(cnt));
                
        vec4 c = texcolor[3] * texcolor + ( 1.0 - texcolor[3] ) * _shadow_color ;
        
        return vec4(c[0],c[1],c[2],blur_alpha * _shadow_color[3]);
    }            
    return texcolor * color;
}
