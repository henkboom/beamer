local Material = require 'graphics.Material'
local Program = require 'graphics.Program'
local Shader = require 'graphics.Shader'
local gl = require 'gl'

return function ()
  local self = Material()

  local vertex = Shader(gl.GL_VERTEX_SHADER)
  assert(vertex:load_from_string(Shader.prelude, [=[
    uniform mat4 projection;
    uniform mat4 modelview;
    attribute vec3 position;
    attribute vec2 tex_coord;

    varying vec2 f_tex_coord;
     
    void main(void)
    {
    	gl_Position = projection * (modelview * vec4(position, 1));
      f_tex_coord = tex_coord;
    }
  ]=]))
  
  local fragment = Shader(gl.GL_FRAGMENT_SHADER)
  assert(fragment:load_from_string(Shader.prelude, [=[
    uniform sampler2D tex;
    uniform vec4 color;

    #ifdef GL_ES
      #ifdef GL_OES_standard_derivatives
        #extension GL_OES_standard_derivatives : enable
        #define USE_DERIVATIVE
      #endif
    #else
      #define USE_DERIVATIVE
    #endif

    varying vec2 f_tex_coord;
    
    void main(void)
    {
        vec4 c = color;
        #ifdef USE_DERIVATIVE
        float delta = fwidth(texture2D(tex, f_tex_coord).r);
        #else
        // TODO some sort of fallback calculated from the game
        delta = 0;
        #endif
        c.a *= smoothstep(0.5-delta, 0.5+delta,
          texture2D(tex, f_tex_coord).r);
        gl_FragColor = c;
    }
  ]=]))
  
  self.program = Program()
  self.program:attach_shader(vertex)
  self.program:attach_shader(fragment)
  assert(self.program:link())

  self.blend_src = 'src_alpha'
  self.blend_dst = 'one_minus_src_alpha'

  return self
end
