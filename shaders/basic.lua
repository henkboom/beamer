local Program = require 'Program'
local Shader = require 'Shader'
local gl = require 'gl'

return function ()
  local vertex = Shader(gl.GL_VERTEX_SHADER)
  assert(vertex:load_from_string([=[
  #version 120
   
  uniform mat4 projection;
  uniform mat4 modelview;
  
  attribute vec3 position;
  varying vec4 color;
   
  void main(void)
  {
  	gl_Position = projection * (modelview * vec4(position, 1));
    color = vec4(1, 1, 1, 1);
  }
  ]=]))
  
  local fragment = Shader(gl.GL_FRAGMENT_SHADER)
  assert(fragment:load_from_string([=[
  #version 120
  
  varying vec4 color;
  
  void main(void)
  {
      gl_FragColor = color;
  }
  ]=]))
  
  local program = Program()
  program:attach_shader(vertex)
  program:attach_shader(fragment)
  assert(program:link())
  
  return program
end
