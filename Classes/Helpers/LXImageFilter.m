//
//  LXImageFilter.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/3/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXImageFilter.h"

@implementation LXImageFilter {
    GLint vignfadeUniform;
    GLint brightnessUniform;
    GLint clearnessUniform;
    GLint saturationUniform;
    GLint aspectratioUniform;
    GLint toneIntensityUniform;
    GLint blendIntensityUniform;
    
    GLint toneCurveTextureUniform;
    GLuint toneCurveTexture;
    
    GLint inputBlendTextureUniform;
    GLuint inputBlendTexture;
    
    GLfloat blendTextureCoordinates[8];
    
    GLint blendTextureCoordinateAttribute;
}

- (id)init;
{
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"latte" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    NSString *vertexShaderPathname = [[NSBundle mainBundle] pathForResource:@"lattevertex" ofType:@"fsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertexShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    _blendRotation = kGPUImageNoRotation;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        vignfadeUniform = [filterProgram uniformIndex:@"vignfade"];
        brightnessUniform = [filterProgram uniformIndex:@"brightness"];
        clearnessUniform = [filterProgram uniformIndex:@"clearness"];
        saturationUniform = [filterProgram uniformIndex:@"saturation"];
        toneIntensityUniform = [filterProgram uniformIndex:@"toneIntensity"];
        blendIntensityUniform = [filterProgram uniformIndex:@"blendIntensity"];
        aspectratioUniform = [filterProgram uniformIndex:@"aspectratio"];
        toneCurveTextureUniform = [filterProgram uniformIndex:@"toneCurveTexture"];
        inputBlendTextureUniform = [filterProgram uniformIndex:@"inputBlendTexture"];
        
        blendTextureCoordinateAttribute = [filterProgram attributeIndex:@"blendTextureCoordinate"];
        glEnableVertexAttribArray(blendTextureCoordinateAttribute);
    });
    
    self.saturation = 1.0;
    self.toneCurveIntensity = 1.0;
    self.vignfade = 1.0;
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"blendTextureCoordinate"];
}

- (void)setVignfade:(CGFloat)aVignfade
{
    [self setFloat:aVignfade forUniform:vignfadeUniform program:filterProgram];
}

- (void)setBrightness:(CGFloat)aBrightness
{
    [self setFloat:aBrightness forUniform:brightnessUniform program:filterProgram];
}

- (void)setClearness:(CGFloat)aClearness {
    [self setFloat:aClearness forUniform:clearnessUniform program:filterProgram];
}

- (void)setSaturation:(CGFloat)aSaturation {
    [self setFloat:aSaturation forUniform:saturationUniform program:filterProgram];
}

- (void)setToneCurveIntensity:(CGFloat)toneCurveIntensity {
    [self setFloat:toneCurveIntensity forUniform:toneIntensityUniform program:filterProgram];
}

- (void)setBlendIntensity:(CGFloat)blendIntensity {
    [self setFloat:blendIntensity forUniform:blendIntensityUniform program:filterProgram];
}

- (void)setToneCurve:(UIImage *)toneCurve {
    _toneCurve = toneCurve;
    
    CGFloat widthOfImage = CGImageGetWidth(_toneCurve.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(_toneCurve.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), _toneCurve.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        glActiveTexture(GL_TEXTURE3);
        glGenTextures(1, &toneCurveTexture);
        glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    });
    
    free(imageData);
}

- (void)setImageBlend:(UIImage *)imageBlend {
    if (imageBlend == nil) {
        if (inputBlendTexture)
        {
            glDeleteTextures(1, &inputBlendTexture);
            inputBlendTexture = 0;
        }
        return;
    }
    _imageBlend = imageBlend;
    CGFloat widthOfImage = CGImageGetWidth(_imageBlend.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(_imageBlend.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), _imageBlend.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        glActiveTexture(GL_TEXTURE3);
        glGenTextures(1, &inputBlendTexture);
        glBindTexture(GL_TEXTURE_2D, inputBlendTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    });
    
    free(imageData);
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    if (self.preventRendering)
    {
        return;
    }
    
    [GPUImageOpenGLESContext setActiveShaderProgram:filterProgram];
    [self setFilterFBO];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
  	glActiveTexture(GL_TEXTURE2);
  	glBindTexture(GL_TEXTURE_2D, sourceTexture);
  	glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
    glUniform1i(toneCurveTextureUniform, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, inputBlendTexture);
    glUniform1i(inputBlendTextureUniform, 4);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(blendTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, blendTextureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)dealloc
{
    if (inputBlendTexture)
    {
        glDeleteTextures(1, &inputBlendTexture);
        inputBlendTexture = 0;
    }
    
    if (toneCurveTexture)
    {
        glDeleteTextures(1, &toneCurveTexture);
        toneCurveTexture = 0;
    }
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        [self setFloat:filterFrameSize.width/filterFrameSize.height forUniform:aspectratioUniform program:filterProgram];
    }
    else
    {
        [self setFloat:filterFrameSize.height/filterFrameSize.width forUniform:aspectratioUniform program:filterProgram];
    }
}

- (void)setBlendRotation:(GPUImageRotationMode)blendRotation {
    _blendRotation = blendRotation;
    [self calculateCropTextureCoordinates];
}

- (void)setBlendRegion:(CGRect)blendRegion {
    _blendRegion = blendRegion;
    [self calculateCropTextureCoordinates];
}


- (void)calculateCropTextureCoordinates;
{
    CGFloat minX = _blendRegion.origin.x;
    CGFloat minY = _blendRegion.origin.y;
    CGFloat maxX = CGRectGetMaxX(_blendRegion);
    CGFloat maxY = CGRectGetMaxY(_blendRegion);
    
    switch(_blendRotation)
    {
        case kGPUImageNoRotation: // Works
        {
            blendTextureCoordinates[0] = minX; // 0,0
            blendTextureCoordinates[1] = minY;
            
            blendTextureCoordinates[2] = maxX; // 1,0
            blendTextureCoordinates[3] = minY;
            
            blendTextureCoordinates[4] = minX; // 0,1
            blendTextureCoordinates[5] = maxY;
            
            blendTextureCoordinates[6] = maxX; // 1,1
            blendTextureCoordinates[7] = maxY;
        }; break;
        case kGPUImageRotateLeft: // Broken
        {
            blendTextureCoordinates[0] = maxX; // 1,0
            blendTextureCoordinates[1] = minY;
            
            blendTextureCoordinates[2] = maxX; // 1,1
            blendTextureCoordinates[3] = maxY;
            
            blendTextureCoordinates[4] = minX; // 0,0
            blendTextureCoordinates[5] = minY;
            
            blendTextureCoordinates[6] = minX; // 0,1
            blendTextureCoordinates[7] = maxY;
        }; break;
        case kGPUImageRotateRight: // Fixed
        {
            blendTextureCoordinates[0] = minY; // 0,1
            blendTextureCoordinates[1] = 1.0 - minX;
            
            blendTextureCoordinates[2] = minY; // 0,0
            blendTextureCoordinates[3] = 1.0 - maxX;
            
            blendTextureCoordinates[4] = maxY; // 1,1
            blendTextureCoordinates[5] = 1.0 - minX;
            
            blendTextureCoordinates[6] = maxY; // 1,0
            blendTextureCoordinates[7] = 1.0 - maxX;
        }; break;
        case kGPUImageFlipVertical: // Broken
        {
            blendTextureCoordinates[0] = minX; // 0,1
            blendTextureCoordinates[1] = maxY;
            
            blendTextureCoordinates[2] = maxX; // 1,1
            blendTextureCoordinates[3] = maxY;
            
            blendTextureCoordinates[4] = minX; // 0,0
            blendTextureCoordinates[5] = minY;
            
            blendTextureCoordinates[6] = maxX; // 1,0
            blendTextureCoordinates[7] = minY;
        }; break;
        case kGPUImageFlipHorizonal: // Broken
        {
            blendTextureCoordinates[0] = maxX; // 1,0
            blendTextureCoordinates[1] = minY;
            
            blendTextureCoordinates[2] = minX; // 0,0
            blendTextureCoordinates[3] = minY;
            
            blendTextureCoordinates[4] = maxX; // 1,1
            blendTextureCoordinates[5] = maxY;
            
            blendTextureCoordinates[6] = minX; // 0,1
            blendTextureCoordinates[7] = maxY;
        }; break;
        case kGPUImageRotate180: // Broken
        {
            blendTextureCoordinates[0] = maxX; // 1,1
            blendTextureCoordinates[1] = maxY;
            
            blendTextureCoordinates[2] = maxX; // 1,0
            blendTextureCoordinates[3] = minY;
            
            blendTextureCoordinates[4] = minX; // 0,1
            blendTextureCoordinates[5] = maxY;
            
            blendTextureCoordinates[6] = minX; // 0,0
            blendTextureCoordinates[7] = minY;
        }; break;
        case kGPUImageRotateRightFlipVertical: // Fixed
        {
            blendTextureCoordinates[0] = minY; // 0,0
            blendTextureCoordinates[1] = 1.0 - maxX;
            
            blendTextureCoordinates[2] = minY; // 0,1
            blendTextureCoordinates[3] = 1.0 - minX;
            
            blendTextureCoordinates[4] = maxY; // 1,0
            blendTextureCoordinates[5] = 1.0 - maxX;
            
            blendTextureCoordinates[6] = maxY; // 1,1
            blendTextureCoordinates[7] = 1.0 - minX;
        }; break;
    }    
}


@end