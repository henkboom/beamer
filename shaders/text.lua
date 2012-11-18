local Program = require 'graphics.Program'
local Shader = require 'graphics.Shader'
local gl = require 'gl'

return function ()
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
    uniform float inner_threshold;
    uniform float outer_threshold;

    varying vec2 f_tex_coord;
    
    void main(void)
    {
        vec4 c = color;
        c.a *= smoothstep(outer_threshold, inner_threshold,
          texture2D(tex, f_tex_coord).r);
        gl_FragColor = c;
    }
  ]=]))
  
  local program = Program()
  program:attach_shader(vertex)
  program:attach_shader(fragment)
  assert(program:link())
  
  return program
end
