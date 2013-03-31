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
    attribute vec4 color;

    varying vec4 f_color;
     
    void main(void)
    {
    	gl_Position = projection * (modelview * vec4(position, 1));
      f_color = color;
    }
  ]=]))
  
  local fragment = Shader(gl.GL_FRAGMENT_SHADER)
  assert(fragment:load_from_string(Shader.prelude, [=[
    varying vec4 f_color;
    
    void main(void)
    {
        gl_FragColor = f_color;
    }
  ]=]))
  
  self.program = Program()
  self.program:attach_shader(vertex)
  self.program:attach_shader(fragment)
  assert(self.program:link())

  self.uniforms.color = {1, 1, 1, 1}
  self.depth_func = 'lequal'

  return self
end
