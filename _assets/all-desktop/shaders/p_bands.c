extern vec2 c_size;     // canvas size
extern number c_ss;     // canvas supersampling
extern vec4 c1;         // band colors
extern vec4 c2;
extern vec4 c3;
extern number p1;        // typ: 0.33
extern number p2;        // typ: 0.66
extern number margin;    // typ: 0.5
extern number sharpness; // typ: 3

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    float _sharpness = 3.0;
    if (sharpness != 0.0) { _sharpness = sharpness; }
    
    vec4 texcolor = Texel(texture,texture_coords);
    bool in_margin = false;
    float blend = 1.0;
    if (texcolor[3] > 0.0 && margin > 0.0)
    {
        float cnt = 0.0;
        float avg = 0.0;
        int _step = 5;
        int steps = int(ceil(margin * c_ss * float(_step)));
        for (int x=-steps; x<=steps; x++) {
            for (int y=-steps; y<=steps; y++) {                        
                vec2 tc = vec2(texture_coords.x + float(x)/float(c_size.x * float(_step)),
                               texture_coords.y + float(y)/float(c_size.y * float(_step)));
                vec4 c = Texel(texture,tc);
                avg = avg + c[3];
                cnt = cnt + 1.0;
            }
        }
        blend = avg / float(cnt);
        blend = pow(blend,_sharpness);
    }   
            
    vec4 o;
    if (texture_coords.y < p1)
        o = c1;
    else if (texture_coords.y < p2)
        o = c2;
    else
        o = c3;
            
    o = blend * o + (1.0-blend) * c2;

    //if (in_margin == true) { o = c2; }
    return vec4(o[0],o[1],o[2],texcolor[3]);
}
