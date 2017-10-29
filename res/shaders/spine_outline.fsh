varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

uniform vec4 u_outlineColor;
void main()
{
    vec4 accum = vec4(0.0);
    vec4 normal = vec4(0.0);
    //normal = texture2D(CC_Texture0, vec2(v_texCoord.x, v_texCoord.y));
    vec4 col = texture2D(CC_Texture0, v_texCoord);
    //gl_FragColor = u_outlineColor * col.a;
    gl_FragColor = vec4(0,0,0,1) * col.a;
    //vec4 col = texture2D(CC_Texture0, v_texCoord);
    //float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    //gl_FragColor = vec4(grey, grey, grey, col.a);
}