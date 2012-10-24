--- gles2
--- =====
---
--- Represents the OpenGL ES 2.0 API so I can make sure I'm properly
--- compatible.

local ffi = require 'ffi'

require('reload').pin(...)

local libgl = ffi.load('GLESv2')

ffi.cdef [[
// <KHR/khrplatform.h>
typedef int32_t                 khronos_int32_t;
typedef uint32_t                khronos_uint32_t;
typedef int64_t                 khronos_int64_t;
typedef uint64_t                khronos_uint64_t;
typedef signed   char          khronos_int8_t;
typedef unsigned char          khronos_uint8_t;
typedef signed   short int     khronos_int16_t;
typedef unsigned short int     khronos_uint16_t;
typedef signed   long  int     khronos_intptr_t;
typedef unsigned long  int     khronos_uintptr_t;
typedef signed   long  int     khronos_ssize_t;
typedef unsigned long  int     khronos_usize_t;
typedef          float         khronos_float_t;
typedef khronos_uint64_t       khronos_utime_nanoseconds_t;
typedef khronos_int64_t        khronos_stime_nanoseconds_t;
static const int KHRONOS_MAX_ENUM = 0x7FFFFFFF;
typedef enum {
    KHRONOS_FALSE = 0,
    KHRONOS_TRUE  = 1,
    KHRONOS_BOOLEAN_ENUM_FORCE_SIZE = KHRONOS_MAX_ENUM
} khronos_boolean_enum_t;

// <GL/gl2.h>
typedef void             GLvoid;
typedef char             GLchar;
typedef unsigned int     GLenum;
typedef unsigned char    GLboolean;
typedef unsigned int     GLbitfield;
typedef khronos_int8_t   GLbyte;
typedef short            GLshort;
typedef int              GLint;
typedef int              GLsizei;
typedef khronos_uint8_t  GLubyte;
typedef unsigned short   GLushort;
typedef unsigned int     GLuint;
typedef khronos_float_t  GLfloat;
typedef khronos_float_t  GLclampf;
typedef khronos_int32_t  GLfixed;
typedef khronos_intptr_t GLintptr;
typedef khronos_ssize_t  GLsizeiptr;

static const int GL_ES_VERSION_2_0 =                 1;
static const int GL_DEPTH_BUFFER_BIT =               0x00000100;
static const int GL_STENCIL_BUFFER_BIT =             0x00000400;
static const int GL_COLOR_BUFFER_BIT =               0x00004000;
static const int GL_FALSE =                          0;
static const int GL_TRUE =                           1;
static const int GL_POINTS =                         0x0000;
static const int GL_LINES =                          0x0001;
static const int GL_LINE_LOOP =                      0x0002;
static const int GL_LINE_STRIP =                     0x0003;
static const int GL_TRIANGLES =                      0x0004;
static const int GL_TRIANGLE_STRIP =                 0x0005;
static const int GL_TRIANGLE_FAN =                   0x0006;
static const int GL_ZERO =                           0;
static const int GL_ONE =                            1;
static const int GL_SRC_COLOR =                      0x0300;
static const int GL_ONE_MINUS_SRC_COLOR =            0x0301;
static const int GL_SRC_ALPHA =                      0x0302;
static const int GL_ONE_MINUS_SRC_ALPHA =            0x0303;
static const int GL_DST_ALPHA =                      0x0304;
static const int GL_ONE_MINUS_DST_ALPHA =            0x0305;
static const int GL_DST_COLOR =                      0x0306;
static const int GL_ONE_MINUS_DST_COLOR =            0x0307;
static const int GL_SRC_ALPHA_SATURATE =             0x0308;
static const int GL_FUNC_ADD =                       0x8006;
static const int GL_BLEND_EQUATION =                 0x8009;
static const int GL_BLEND_EQUATION_RGB =             0x8009;
static const int GL_BLEND_EQUATION_ALPHA =           0x883D;
static const int GL_FUNC_SUBTRACT =                  0x800A;
static const int GL_FUNC_REVERSE_SUBTRACT =          0x800B;
static const int GL_BLEND_DST_RGB =                  0x80C8;
static const int GL_BLEND_SRC_RGB =                  0x80C9;
static const int GL_BLEND_DST_ALPHA =                0x80CA;
static const int GL_BLEND_SRC_ALPHA =                0x80CB;
static const int GL_CONSTANT_COLOR =                 0x8001;
static const int GL_ONE_MINUS_CONSTANT_COLOR =       0x8002;
static const int GL_CONSTANT_ALPHA =                 0x8003;
static const int GL_ONE_MINUS_CONSTANT_ALPHA =       0x8004;
static const int GL_BLEND_COLOR =                    0x8005;
static const int GL_ARRAY_BUFFER =                   0x8892;
static const int GL_ELEMENT_ARRAY_BUFFER =           0x8893;
static const int GL_ARRAY_BUFFER_BINDING =           0x8894;
static const int GL_ELEMENT_ARRAY_BUFFER_BINDING =   0x8895;
static const int GL_STREAM_DRAW =                    0x88E0;
static const int GL_STATIC_DRAW =                    0x88E4;
static const int GL_DYNAMIC_DRAW =                   0x88E8;
static const int GL_BUFFER_SIZE =                    0x8764;
static const int GL_BUFFER_USAGE =                   0x8765;
static const int GL_CURRENT_VERTEX_ATTRIB =          0x8626;
static const int GL_FRONT =                          0x0404;
static const int GL_BACK =                           0x0405;
static const int GL_FRONT_AND_BACK =                 0x0408;
static const int GL_TEXTURE_2D =                     0x0DE1;
static const int GL_CULL_FACE =                      0x0B44;
static const int GL_BLEND =                          0x0BE2;
static const int GL_DITHER =                         0x0BD0;
static const int GL_STENCIL_TEST =                   0x0B90;
static const int GL_DEPTH_TEST =                     0x0B71;
static const int GL_SCISSOR_TEST =                   0x0C11;
static const int GL_POLYGON_OFFSET_FILL =            0x8037;
static const int GL_SAMPLE_ALPHA_TO_COVERAGE =       0x809E;
static const int GL_SAMPLE_COVERAGE =                0x80A0;
static const int GL_NO_ERROR =                       0;
static const int GL_INVALID_ENUM =                   0x0500;
static const int GL_INVALID_VALUE =                  0x0501;
static const int GL_INVALID_OPERATION =              0x0502;
static const int GL_OUT_OF_MEMORY =                  0x0505;
static const int GL_CW =                             0x0900;
static const int GL_CCW =                            0x0901;
static const int GL_LINE_WIDTH =                     0x0B21;
static const int GL_ALIASED_POINT_SIZE_RANGE =       0x846D;
static const int GL_ALIASED_LINE_WIDTH_RANGE =       0x846E;
static const int GL_CULL_FACE_MODE =                 0x0B45;
static const int GL_FRONT_FACE =                     0x0B46;
static const int GL_DEPTH_RANGE =                    0x0B70;
static const int GL_DEPTH_WRITEMASK =                0x0B72;
static const int GL_DEPTH_CLEAR_VALUE =              0x0B73;
static const int GL_DEPTH_FUNC =                     0x0B74;
static const int GL_STENCIL_CLEAR_VALUE =            0x0B91;
static const int GL_STENCIL_FUNC =                   0x0B92;
static const int GL_STENCIL_FAIL =                   0x0B94;
static const int GL_STENCIL_PASS_DEPTH_FAIL =        0x0B95;
static const int GL_STENCIL_PASS_DEPTH_PASS =        0x0B96;
static const int GL_STENCIL_REF =                    0x0B97;
static const int GL_STENCIL_VALUE_MASK =             0x0B93;
static const int GL_STENCIL_WRITEMASK =              0x0B98;
static const int GL_STENCIL_BACK_FUNC =              0x8800;
static const int GL_STENCIL_BACK_FAIL =              0x8801;
static const int GL_STENCIL_BACK_PASS_DEPTH_FAIL =   0x8802;
static const int GL_STENCIL_BACK_PASS_DEPTH_PASS =   0x8803;
static const int GL_STENCIL_BACK_REF =               0x8CA3;
static const int GL_STENCIL_BACK_VALUE_MASK =        0x8CA4;
static const int GL_STENCIL_BACK_WRITEMASK =         0x8CA5;
static const int GL_VIEWPORT =                       0x0BA2;
static const int GL_SCISSOR_BOX =                    0x0C10;
static const int GL_COLOR_CLEAR_VALUE =              0x0C22;
static const int GL_COLOR_WRITEMASK =                0x0C23;
static const int GL_UNPACK_ALIGNMENT =               0x0CF5;
static const int GL_PACK_ALIGNMENT =                 0x0D05;
static const int GL_MAX_TEXTURE_SIZE =               0x0D33;
static const int GL_MAX_VIEWPORT_DIMS =              0x0D3A;
static const int GL_SUBPIXEL_BITS =                  0x0D50;
static const int GL_RED_BITS =                       0x0D52;
static const int GL_GREEN_BITS =                     0x0D53;
static const int GL_BLUE_BITS =                      0x0D54;
static const int GL_ALPHA_BITS =                     0x0D55;
static const int GL_DEPTH_BITS =                     0x0D56;
static const int GL_STENCIL_BITS =                   0x0D57;
static const int GL_POLYGON_OFFSET_UNITS =           0x2A00;
static const int GL_POLYGON_OFFSET_FACTOR =          0x8038;
static const int GL_TEXTURE_BINDING_2D =             0x8069;
static const int GL_SAMPLE_BUFFERS =                 0x80A8;
static const int GL_SAMPLES =                        0x80A9;
static const int GL_SAMPLE_COVERAGE_VALUE =          0x80AA;
static const int GL_SAMPLE_COVERAGE_INVERT =         0x80AB;
static const int GL_NUM_COMPRESSED_TEXTURE_FORMATS = 0x86A2;
static const int GL_COMPRESSED_TEXTURE_FORMATS =     0x86A3;
static const int GL_DONT_CARE =                      0x1100;
static const int GL_FASTEST =                        0x1101;
static const int GL_NICEST =                         0x1102;
static const int GL_GENERATE_MIPMAP_HINT =            0x8192;
static const int GL_BYTE =                           0x1400;
static const int GL_UNSIGNED_BYTE =                  0x1401;
static const int GL_SHORT =                          0x1402;
static const int GL_UNSIGNED_SHORT =                 0x1403;
static const int GL_INT =                            0x1404;
static const int GL_UNSIGNED_INT =                   0x1405;
static const int GL_FLOAT =                          0x1406;
static const int GL_FIXED =                          0x140C;
static const int GL_DEPTH_COMPONENT =                0x1902;
static const int GL_ALPHA =                          0x1906;
static const int GL_RGB =                            0x1907;
static const int GL_RGBA =                           0x1908;
static const int GL_LUMINANCE =                      0x1909;
static const int GL_LUMINANCE_ALPHA =                0x190A;
static const int GL_UNSIGNED_SHORT_4_4_4_4 =         0x8033;
static const int GL_UNSIGNED_SHORT_5_5_5_1 =         0x8034;
static const int GL_UNSIGNED_SHORT_5_6_5 =           0x8363;
static const int GL_FRAGMENT_SHADER =                  0x8B30;
static const int GL_VERTEX_SHADER =                    0x8B31;
static const int GL_MAX_VERTEX_ATTRIBS =               0x8869;
static const int GL_MAX_VERTEX_UNIFORM_VECTORS =       0x8DFB;
static const int GL_MAX_VARYING_VECTORS =              0x8DFC;
static const int GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = 0x8B4D;
static const int GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS =   0x8B4C;
static const int GL_MAX_TEXTURE_IMAGE_UNITS =          0x8872;
static const int GL_MAX_FRAGMENT_UNIFORM_VECTORS =     0x8DFD;
static const int GL_SHADER_TYPE =                      0x8B4F;
static const int GL_DELETE_STATUS =                    0x8B80;
static const int GL_LINK_STATUS =                      0x8B82;
static const int GL_VALIDATE_STATUS =                  0x8B83;
static const int GL_ATTACHED_SHADERS =                 0x8B85;
static const int GL_ACTIVE_UNIFORMS =                  0x8B86;
static const int GL_ACTIVE_UNIFORM_MAX_LENGTH =        0x8B87;
static const int GL_ACTIVE_ATTRIBUTES =                0x8B89;
static const int GL_ACTIVE_ATTRIBUTE_MAX_LENGTH =      0x8B8A;
static const int GL_SHADING_LANGUAGE_VERSION =         0x8B8C;
static const int GL_CURRENT_PROGRAM =                  0x8B8D;
static const int GL_NEVER =                          0x0200;
static const int GL_LESS =                           0x0201;
static const int GL_EQUAL =                          0x0202;
static const int GL_LEQUAL =                         0x0203;
static const int GL_GREATER =                        0x0204;
static const int GL_NOTEQUAL =                       0x0205;
static const int GL_GEQUAL =                         0x0206;
static const int GL_ALWAYS =                         0x0207;
static const int GL_KEEP =                           0x1E00;
static const int GL_REPLACE =                        0x1E01;
static const int GL_INCR =                           0x1E02;
static const int GL_DECR =                           0x1E03;
static const int GL_INVERT =                         0x150A;
static const int GL_INCR_WRAP =                      0x8507;
static const int GL_DECR_WRAP =                      0x8508;
static const int GL_VENDOR =                         0x1F00;
static const int GL_RENDERER =                       0x1F01;
static const int GL_VERSION =                        0x1F02;
static const int GL_EXTENSIONS =                     0x1F03;
static const int GL_NEAREST =                        0x2600;
static const int GL_LINEAR =                         0x2601;
static const int GL_NEAREST_MIPMAP_NEAREST =         0x2700;
static const int GL_LINEAR_MIPMAP_NEAREST =          0x2701;
static const int GL_NEAREST_MIPMAP_LINEAR =          0x2702;
static const int GL_LINEAR_MIPMAP_LINEAR =           0x2703;
static const int GL_TEXTURE_MAG_FILTER =             0x2800;
static const int GL_TEXTURE_MIN_FILTER =             0x2801;
static const int GL_TEXTURE_WRAP_S =                 0x2802;
static const int GL_TEXTURE_WRAP_T =                 0x2803;
static const int GL_TEXTURE =                        0x1702;
static const int GL_TEXTURE_CUBE_MAP =               0x8513;
static const int GL_TEXTURE_BINDING_CUBE_MAP =       0x8514;
static const int GL_TEXTURE_CUBE_MAP_POSITIVE_X =    0x8515;
static const int GL_TEXTURE_CUBE_MAP_NEGATIVE_X =    0x8516;
static const int GL_TEXTURE_CUBE_MAP_POSITIVE_Y =    0x8517;
static const int GL_TEXTURE_CUBE_MAP_NEGATIVE_Y =    0x8518;
static const int GL_TEXTURE_CUBE_MAP_POSITIVE_Z =    0x8519;
static const int GL_TEXTURE_CUBE_MAP_NEGATIVE_Z =    0x851A;
static const int GL_MAX_CUBE_MAP_TEXTURE_SIZE =      0x851C;
static const int GL_TEXTURE0 =                       0x84C0;
static const int GL_TEXTURE1 =                       0x84C1;
static const int GL_TEXTURE2 =                       0x84C2;
static const int GL_TEXTURE3 =                       0x84C3;
static const int GL_TEXTURE4 =                       0x84C4;
static const int GL_TEXTURE5 =                       0x84C5;
static const int GL_TEXTURE6 =                       0x84C6;
static const int GL_TEXTURE7 =                       0x84C7;
static const int GL_TEXTURE8 =                       0x84C8;
static const int GL_TEXTURE9 =                       0x84C9;
static const int GL_TEXTURE10 =                      0x84CA;
static const int GL_TEXTURE11 =                      0x84CB;
static const int GL_TEXTURE12 =                      0x84CC;
static const int GL_TEXTURE13 =                      0x84CD;
static const int GL_TEXTURE14 =                      0x84CE;
static const int GL_TEXTURE15 =                      0x84CF;
static const int GL_TEXTURE16 =                      0x84D0;
static const int GL_TEXTURE17 =                      0x84D1;
static const int GL_TEXTURE18 =                      0x84D2;
static const int GL_TEXTURE19 =                      0x84D3;
static const int GL_TEXTURE20 =                      0x84D4;
static const int GL_TEXTURE21 =                      0x84D5;
static const int GL_TEXTURE22 =                      0x84D6;
static const int GL_TEXTURE23 =                      0x84D7;
static const int GL_TEXTURE24 =                      0x84D8;
static const int GL_TEXTURE25 =                      0x84D9;
static const int GL_TEXTURE26 =                      0x84DA;
static const int GL_TEXTURE27 =                      0x84DB;
static const int GL_TEXTURE28 =                      0x84DC;
static const int GL_TEXTURE29 =                      0x84DD;
static const int GL_TEXTURE30 =                      0x84DE;
static const int GL_TEXTURE31 =                      0x84DF;
static const int GL_ACTIVE_TEXTURE =                 0x84E0;
static const int GL_REPEAT =                         0x2901;
static const int GL_CLAMP_TO_EDGE =                  0x812F;
static const int GL_MIRRORED_REPEAT =                0x8370;
static const int GL_FLOAT_VEC2 =                     0x8B50;
static const int GL_FLOAT_VEC3 =                     0x8B51;
static const int GL_FLOAT_VEC4 =                     0x8B52;
static const int GL_INT_VEC2 =                       0x8B53;
static const int GL_INT_VEC3 =                       0x8B54;
static const int GL_INT_VEC4 =                       0x8B55;
static const int GL_BOOL =                           0x8B56;
static const int GL_BOOL_VEC2 =                      0x8B57;
static const int GL_BOOL_VEC3 =                      0x8B58;
static const int GL_BOOL_VEC4 =                      0x8B59;
static const int GL_FLOAT_MAT2 =                     0x8B5A;
static const int GL_FLOAT_MAT3 =                     0x8B5B;
static const int GL_FLOAT_MAT4 =                     0x8B5C;
static const int GL_SAMPLER_2D =                     0x8B5E;
static const int GL_SAMPLER_CUBE =                   0x8B60;
static const int GL_VERTEX_ATTRIB_ARRAY_ENABLED =        0x8622;
static const int GL_VERTEX_ATTRIB_ARRAY_SIZE =           0x8623;
static const int GL_VERTEX_ATTRIB_ARRAY_STRIDE =         0x8624;
static const int GL_VERTEX_ATTRIB_ARRAY_TYPE =           0x8625;
static const int GL_VERTEX_ATTRIB_ARRAY_NORMALIZED =     0x886A;
static const int GL_VERTEX_ATTRIB_ARRAY_POINTER =        0x8645;
static const int GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F;
static const int GL_IMPLEMENTATION_COLOR_READ_TYPE =   0x8B9A;
static const int GL_IMPLEMENTATION_COLOR_READ_FORMAT = 0x8B9B;
static const int GL_COMPILE_STATUS =                 0x8B81;
static const int GL_INFO_LOG_LENGTH =                0x8B84;
static const int GL_SHADER_SOURCE_LENGTH =           0x8B88;
static const int GL_SHADER_COMPILER =                0x8DFA;
static const int GL_SHADER_BINARY_FORMATS =          0x8DF8;
static const int GL_NUM_SHADER_BINARY_FORMATS =      0x8DF9;
static const int GL_LOW_FLOAT =                      0x8DF0;
static const int GL_MEDIUM_FLOAT =                   0x8DF1;
static const int GL_HIGH_FLOAT =                     0x8DF2;
static const int GL_LOW_INT =                        0x8DF3;
static const int GL_MEDIUM_INT =                     0x8DF4;
static const int GL_HIGH_INT =                       0x8DF5;
static const int GL_FRAMEBUFFER =                    0x8D40;
static const int GL_RENDERBUFFER =                   0x8D41;
static const int GL_RGBA4 =                          0x8056;
static const int GL_RGB5_A1 =                        0x8057;
static const int GL_RGB565 =                         0x8D62;
static const int GL_DEPTH_COMPONENT16 =              0x81A5;
static const int GL_STENCIL_INDEX8 =                 0x8D48;
static const int GL_RENDERBUFFER_WIDTH =             0x8D42;
static const int GL_RENDERBUFFER_HEIGHT =            0x8D43;
static const int GL_RENDERBUFFER_INTERNAL_FORMAT =   0x8D44;
static const int GL_RENDERBUFFER_RED_SIZE =          0x8D50;
static const int GL_RENDERBUFFER_GREEN_SIZE =        0x8D51;
static const int GL_RENDERBUFFER_BLUE_SIZE =         0x8D52;
static const int GL_RENDERBUFFER_ALPHA_SIZE =        0x8D53;
static const int GL_RENDERBUFFER_DEPTH_SIZE =        0x8D54;
static const int GL_RENDERBUFFER_STENCIL_SIZE =      0x8D55;
static const int GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE =           0x8CD0;
static const int GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME =           0x8CD1;
static const int GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL =         0x8CD2;
static const int GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = 0x8CD3;
static const int GL_COLOR_ATTACHMENT0 =              0x8CE0;
static const int GL_DEPTH_ATTACHMENT =               0x8D00;
static const int GL_STENCIL_ATTACHMENT =             0x8D20;
static const int GL_NONE =                           0;
static const int GL_FRAMEBUFFER_COMPLETE =                      0x8CD5;
static const int GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT =         0x8CD6;
static const int GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = 0x8CD7;
static const int GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS =         0x8CD9;
static const int GL_FRAMEBUFFER_UNSUPPORTED =                   0x8CDD;
static const int GL_FRAMEBUFFER_BINDING =            0x8CA6;
static const int GL_RENDERBUFFER_BINDING =           0x8CA7;
static const int GL_MAX_RENDERBUFFER_SIZE =          0x84E8;
static const int GL_INVALID_FRAMEBUFFER_OPERATION =  0x0506;

void         glActiveTexture (GLenum texture);
void         glAttachShader (GLuint program, GLuint shader);
void         glBindAttribLocation (GLuint program, GLuint index, const GLchar* name);
void         glBindBuffer (GLenum target, GLuint buffer);
void         glBindFramebuffer (GLenum target, GLuint framebuffer);
void         glBindRenderbuffer (GLenum target, GLuint renderbuffer);
void         glBindTexture (GLenum target, GLuint texture);
void         glBlendColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
void         glBlendEquation ( GLenum mode );
void         glBlendEquationSeparate (GLenum modeRGB, GLenum modeAlpha);
void         glBlendFunc (GLenum sfactor, GLenum dfactor);
void         glBlendFuncSeparate (GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha);
void         glBufferData (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage);
void         glBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size, const GLvoid* data);
GLenum       glCheckFramebufferStatus (GLenum target);
void         glClear (GLbitfield mask);
void         glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
void         glClearDepthf (GLclampf depth);
void         glClearStencil (GLint s);
void         glColorMask (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);
void         glCompileShader (GLuint shader);
void         glCompressedTexImage2D (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid* data);
void         glCompressedTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const GLvoid* data);
void         glCopyTexImage2D (GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border);
void         glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height);
GLuint       glCreateProgram (void);
GLuint       glCreateShader (GLenum type);
void         glCullFace (GLenum mode);
void         glDeleteBuffers (GLsizei n, const GLuint* buffers);
void         glDeleteFramebuffers (GLsizei n, const GLuint* framebuffers);
void         glDeleteProgram (GLuint program);
void         glDeleteRenderbuffers (GLsizei n, const GLuint* renderbuffers);
void         glDeleteShader (GLuint shader);
void         glDeleteTextures (GLsizei n, const GLuint* textures);
void         glDepthFunc (GLenum func);
void         glDepthMask (GLboolean flag);
void         glDepthRangef (GLclampf zNear, GLclampf zFar);
void         glDetachShader (GLuint program, GLuint shader);
void         glDisable (GLenum cap);
void         glDisableVertexAttribArray (GLuint index);
void         glDrawArrays (GLenum mode, GLint first, GLsizei count);
void         glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices);
void         glEnable (GLenum cap);
void         glEnableVertexAttribArray (GLuint index);
void         glFinish (void);
void         glFlush (void);
void         glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);
void         glFramebufferTexture2D (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);
void         glFrontFace (GLenum mode);
void         glGenBuffers (GLsizei n, GLuint* buffers);
void         glGenerateMipmap (GLenum target);
void         glGenFramebuffers (GLsizei n, GLuint* framebuffers);
void         glGenRenderbuffers (GLsizei n, GLuint* renderbuffers);
void         glGenTextures (GLsizei n, GLuint* textures);
void         glGetActiveAttrib (GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name);
void         glGetActiveUniform (GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name);
void         glGetAttachedShaders (GLuint program, GLsizei maxcount, GLsizei* count, GLuint* shaders);
int          glGetAttribLocation (GLuint program, const GLchar* name);
void         glGetBooleanv (GLenum pname, GLboolean* params);
void         glGetBufferParameteriv (GLenum target, GLenum pname, GLint* params);
GLenum       glGetError (void);
void         glGetFloatv (GLenum pname, GLfloat* params);
void         glGetFramebufferAttachmentParameteriv (GLenum target, GLenum attachment, GLenum pname, GLint* params);
void         glGetIntegerv (GLenum pname, GLint* params);
void         glGetProgramiv (GLuint program, GLenum pname, GLint* params);
void         glGetProgramInfoLog (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);
void         glGetRenderbufferParameteriv (GLenum target, GLenum pname, GLint* params);
void         glGetShaderiv (GLuint shader, GLenum pname, GLint* params);
void         glGetShaderInfoLog (GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog);
void         glGetShaderPrecisionFormat (GLenum shadertype, GLenum precisiontype, GLint* range, GLint* precision);
void         glGetShaderSource (GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* source);
const GLubyte* glGetString (GLenum name);
void         glGetTexParameterfv (GLenum target, GLenum pname, GLfloat* params);
void         glGetTexParameteriv (GLenum target, GLenum pname, GLint* params);
void         glGetUniformfv (GLuint program, GLint location, GLfloat* params);
void         glGetUniformiv (GLuint program, GLint location, GLint* params);
int          glGetUniformLocation (GLuint program, const GLchar* name);
void         glGetVertexAttribfv (GLuint index, GLenum pname, GLfloat* params);
void         glGetVertexAttribiv (GLuint index, GLenum pname, GLint* params);
void         glGetVertexAttribPointerv (GLuint index, GLenum pname, GLvoid** pointer);
void         glHint (GLenum target, GLenum mode);
GLboolean    glIsBuffer (GLuint buffer);
GLboolean    glIsEnabled (GLenum cap);
GLboolean    glIsFramebuffer (GLuint framebuffer);
GLboolean    glIsProgram (GLuint program);
GLboolean    glIsRenderbuffer (GLuint renderbuffer);
GLboolean    glIsShader (GLuint shader);
GLboolean    glIsTexture (GLuint texture);
void         glLineWidth (GLfloat width);
void         glLinkProgram (GLuint program);
void         glPixelStorei (GLenum pname, GLint param);
void         glPolygonOffset (GLfloat factor, GLfloat units);
void         glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid* pixels);
void         glReleaseShaderCompiler (void);
void         glRenderbufferStorage (GLenum target, GLenum internalformat, GLsizei width, GLsizei height);
void         glSampleCoverage (GLclampf value, GLboolean invert);
void         glScissor (GLint x, GLint y, GLsizei width, GLsizei height);
void         glShaderBinary (GLsizei n, const GLuint* shaders, GLenum binaryformat, const GLvoid* binary, GLsizei length);
void         glShaderSource (GLuint shader, GLsizei count, const GLchar* const* string, const GLint* length);
void         glStencilFunc (GLenum func, GLint ref, GLuint mask);
void         glStencilFuncSeparate (GLenum face, GLenum func, GLint ref, GLuint mask);
void         glStencilMask (GLuint mask);
void         glStencilMaskSeparate (GLenum face, GLuint mask);
void         glStencilOp (GLenum fail, GLenum zfail, GLenum zpass);
void         glStencilOpSeparate (GLenum face, GLenum fail, GLenum zfail, GLenum zpass);
void         glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels);
void         glTexParameterf (GLenum target, GLenum pname, GLfloat param);
void         glTexParameterfv (GLenum target, GLenum pname, const GLfloat* params);
void         glTexParameteri (GLenum target, GLenum pname, GLint param);
void         glTexParameteriv (GLenum target, GLenum pname, const GLint* params);
void         glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels);
void         glUniform1f (GLint location, GLfloat x);
void         glUniform1fv (GLint location, GLsizei count, const GLfloat* v);
void         glUniform1i (GLint location, GLint x);
void         glUniform1iv (GLint location, GLsizei count, const GLint* v);
void         glUniform2f (GLint location, GLfloat x, GLfloat y);
void         glUniform2fv (GLint location, GLsizei count, const GLfloat* v);
void         glUniform2i (GLint location, GLint x, GLint y);
void         glUniform2iv (GLint location, GLsizei count, const GLint* v);
void         glUniform3f (GLint location, GLfloat x, GLfloat y, GLfloat z);
void         glUniform3fv (GLint location, GLsizei count, const GLfloat* v);
void         glUniform3i (GLint location, GLint x, GLint y, GLint z);
void         glUniform3iv (GLint location, GLsizei count, const GLint* v);
void         glUniform4f (GLint location, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void         glUniform4fv (GLint location, GLsizei count, const GLfloat* v);
void         glUniform4i (GLint location, GLint x, GLint y, GLint z, GLint w);
void         glUniform4iv (GLint location, GLsizei count, const GLint* v);
void         glUniformMatrix2fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value);
void         glUniformMatrix3fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value);
void         glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value);
void         glUseProgram (GLuint program);
void         glValidateProgram (GLuint program);
void         glVertexAttrib1f (GLuint indx, GLfloat x);
void         glVertexAttrib1fv (GLuint indx, const GLfloat* values);
void         glVertexAttrib2f (GLuint indx, GLfloat x, GLfloat y);
void         glVertexAttrib2fv (GLuint indx, const GLfloat* values);
void         glVertexAttrib3f (GLuint indx, GLfloat x, GLfloat y, GLfloat z);
void         glVertexAttrib3fv (GLuint indx, const GLfloat* values);
void         glVertexAttrib4f (GLuint indx, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void         glVertexAttrib4fv (GLuint indx, const GLfloat* values);
void         glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr);
void         glViewport (GLint x, GLint y, GLsizei width, GLsizei height);
]]

local debugging = true

local gl
gl = setmetatable({}, {
  __index = function (t, k)
    if string.byte(k) == string.byte('G') then
      t[k] = libgl[k]
      return t[k]
    else
      t[k] = libgl[k]

      if debugging and k ~= 'glGetError' then
        local fn = t[k]
        t[k] = function (...)
          local ret = fn(...)
          local err = gl.glGetError()
          if err ~= gl.GL_NO_ERROR then
            error('gl error ' .. string.format("0x%x", err))
          end
          return ret
        end
      end

      return t[k]
    end
  end
})

return gl
