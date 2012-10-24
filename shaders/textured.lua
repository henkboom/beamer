local Program = require 'Program'
local Shader = require 'Shader'
local gl = require 'gl'

return function ()
  local vertex = Shader(gl.GL_VERTEX_SHADER)
  assert(vertex:load_from_string([=[
  #version 100
   
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
  assert(fragment:load_from_string([=[
  #version 100
  precision lowp float;

  uniform sampler2D tex;

  varying vec2 f_tex_coord;
  
  void main(void)
  {
      gl_FragColor = texture2D(tex, f_tex_coord);
  }
  ]=]))
  
  local program = Program()
  program:attach_shader(vertex)
  program:attach_shader(fragment)
  assert(program:link())
  
  return program
end
