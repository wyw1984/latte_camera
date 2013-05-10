 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 blendTextureCoordinate;
 attribute vec4 filmTextureCoordinate;
 
 varying vec2 textureCoordinate;
 varying vec2 blendCoordinate;
 varying vec2 filmCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     blendCoordinate = blendTextureCoordinate.xy;
     filmCoordinate = filmTextureCoordinate.xy;
 }
