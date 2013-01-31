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
    varying vec4 color;
     
    void main(void)
    {
    	gl_Position = projection * (modelview * vec4(position, 1));
      f_tex_coord = tex_coord;
    }
  ]=]))
  
  local fragment = Shader(gl.GL_FRAGMENT_SHADER)
  assert(fragment:load_from_string(Shader.prelude, [=[
    uniform sampler2D tex;
    
    void main(void)
    {
        gl_FragColor = texture2D(tex, f_tex_coord);
    }
  ]=]))
  
  self.program = Program()
  self.program:attach_shader(vertex)
  self.program:attach_shader(fragment)
  assert(self.program:link())

  return self
end
