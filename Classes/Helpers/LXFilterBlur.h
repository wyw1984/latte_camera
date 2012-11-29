//
//  LXFilterBlur.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/13.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface LXFilterBlur : GPUImageTwoInputFilter {
    GLint depthTextureUniform;
    GLint widthUniform;
    GLint heightUniform;
    GLint maxblurUniform;
    GLint focalDepthUniform;
    GLint autofocusUniform;
    GLint focusUniform;
    GLint gainUniform;
    GLint thresholdUniform;
    GLint ringsUniform;
    GLint samplesUniform;
    
    GLuint depthTexture;
    GLubyte *depthMapByteArray;
    
    CGPoint focus;
    CGFloat maxblur;
    CGFloat focalDepth;
    CGFloat gain;
    BOOL autofocus;
    CGFloat threshold;
}

@property(readwrite, nonatomic) CGPoint focus;
@property(readwrite, nonatomic) CGFloat maxblur;
@property(readwrite, nonatomic) CGFloat focalDepth;
@property(readwrite, nonatomic) CGFloat gain;
@property(readwrite, nonatomic) BOOL autofocus;
@property(readwrite, nonatomic) CGFloat threshold;

@property(readwrite, nonatomic) CGSize frameSize;

@end
