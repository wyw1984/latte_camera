//
//  FilterManager.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "FilterManager.h"

@implementation FilterManager

static GPUImagePicture *texture;

- (id)init {
    self = [super init];
    if (self != nil) {
        brightness = [[GPUImageBrightnessFilter alloc] init];
        distord = [[GPUImagePinchDistortionFilter alloc]init];
        tiltShift = [[GPUImageTiltShiftFilter alloc]init];
        sharpen = [[GPUImageSharpenFilter alloc] init];
        vignette = [[GPUImageVignetteFilter alloc] init];
        tonecurve = [[GPUImageToneCurveFilter alloc] init];
        exposure = [[GPUImageExposureFilter alloc] init];
        rgb = [[GPUImageRGBFilter alloc] init];
        crop = [[GPUImageCropFilter alloc] init];
        crop2 = [[GPUImageCropFilter alloc] init];
        contrast = [[GPUImageContrastFilter alloc] init];
        mono = [[GPUImageGrayscaleFilter alloc] init];
        sepia = [[GPUImageMonochromeFilter alloc]init];
        blur = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
        
        grain = [[GPUImageOverlayBlendFilter alloc] init];

    }
    return self;
}

- (void)changeFiltertoLens:(NSInteger)aLens andEffect:(NSInteger)aEffect input:(GPUImageOutput *)aInput output:(GPUImageView *)aOutput isPicture:(BOOL)isPicture {
    [aInput removeAllTargets];
    [self clearTargetWithCamera:nil andPicture:nil];
    
    switch (aLens) {
        case 0:
            [self lensNormal];
            break;
        case 1:
            [self lensTilt];
            break;
        case 2:
            [self lensFish];
            break;
    }
    
    switch (aEffect) {
        case 0:
            [self effect0];
            break;
        case 1:
            [self tmpEffect1];
            break;
        case 2:
            [self tmpEffect2];
            break;
        case 3:
            [self tmpEffect3];
            break;
        case 4:
            [self tmpEffect4];
            break;
        case 5:
            [self tmpEffect5];
            break;
        case 6:
            [self tmpEffect6];
            break;
        case 7:
            [self tmpEffect2];
            break;
        case 8:
            [self tmpEffect3];
            break;
        case 9:
            [self tmpEffect4];
            break;
        case 10:
            [self tmpEffect5];
            break;
    }
    
    
    if (lensIn == nil && effectIn == nil) {
        if (isPicture) {
            [aInput addTarget:aOutput];
        } else {
            [aInput addTarget:crop];
            [crop addTarget:aOutput];
            
            lastFilter = crop;
        }
    } else if (lensIn == nil) {
        if (isPicture) {
            [aInput addTarget:effectIn];
            [effectOut addTarget:aOutput];
        } else {
            [aInput addTarget:crop];
            [crop addTarget:effectIn];
            [effectOut addTarget:aOutput];
        }
        lastFilter = effectOut;
    } else if (effectIn == nil) {
        if (isPicture) {
            [aInput addTarget:lensIn];
            [lensOut addTarget:aOutput];
        } else {
            [aInput addTarget:crop];
            [crop addTarget:lensIn];
            [lensOut addTarget:aOutput];
        }
        lastFilter = lensOut;
    }
    else {
        if (isPicture) {
            [aInput addTarget:effectIn];
            [effectOut addTarget:lensIn];
            [lensOut addTarget:aOutput];
        } else {
            [aInput addTarget:crop];
            [crop addTarget:effectIn];
            [effectOut addTarget:lensIn];
            [lensOut addTarget:aOutput];
        }
        lastFilter = lensOut;
    }
//    [effectOut addTarget:aOutput];
    if (isPicture) {
        [lensOut prepareForImageCapture];
    }
}

- (GPUImageFilterGroup *)lensNormal {
    [crop2 setCropRegion: CGRectMake(0, 0, 1, 1)];
    
    lensIn = crop2;
    lensOut = crop2;
    return nil;
    // GPUImageSharpenFilter *sharpen = [[GPUImageSharpenFilter alloc] init];
    // sharpen.sharpness = 0.5f;
    // return (id)sharpen;
}

- (GPUImageFilterGroup *)lensTilt {
    tiltShift.blurSize = 2;
    
    [distord setScale:0.1f];
    [distord addTarget: tiltShift];
    
    lensIn = distord;
    lensOut = tiltShift;
    return nil;
}

- (GPUImageFilterGroup *)lensFish {
    [crop2 setCropRegion: CGRectMake(0.05, 0.05, 0.9, 0.9)];
    [distord setScale:-0.2f];
    [distord setRadius:0.75f];
    
    [distord addTarget: crop2];
    
    lensIn = distord;
    lensOut = crop2;
    return nil;
}

- (void)effect0 {
    effectIn = nil;
    effectOut = nil;
}


- (GPUImageFilterGroup *)effect1 {
    exposure = [[GPUImageExposureFilter alloc] init]; //hack

    exposure.exposure = 0.1;
    vignette.vignetteStart = 0.55;
    vignette.vignetteEnd = 0.90;
    [tonecurve setRedControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(102.0f/255.0f, 90.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(111.0f/255.0f, 108.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                    nil]];
    [tonecurve setGreenControlPoints:[NSArray arrayWithObjects:
                                      [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(83.0f/255.0f, 73.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(93.0f/255.0f, 90.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                      nil]];
    
    [tonecurve setBlueControlPoints:[NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(86.0f/255.0f, 100.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(121.0f/255.0f, 118.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                     nil]];

    
  
    
    [exposure addTarget:vignette];
    [vignette addTarget:tonecurve];
    
    effectIn = exposure;
    effectOut = tonecurve;
    return nil;
}

- (GPUImageFilterGroup *)effect2 {
    exposure = [[GPUImageExposureFilter alloc] init]; //hack
    
    exposure.exposure = 0.1;
    vignette.vignetteStart = 0.55;
    vignette.vignetteEnd = 0.85;
    
    float curve[16][3] = {
        {23,20,60},
        {32,37,78},
        {43,54,95},
        {55,73,110},
        {68,91,124},
        {83,111,136},
        {98,130,148},
        {114,149,159},
        {130,167,168},
        {146,182,178},
        {161,198,187},
        {176,212,196},
        {191,224,204},
        {206,233,212},
        {222,241,220},
        {238,248,229}
     };
    
    [tonecurve setRedControlPoints:[self curveWithPoint:curve atIndex:0]];
    [tonecurve setGreenControlPoints:[self curveWithPoint:curve atIndex:1]];
    [tonecurve setBlueControlPoints:[self curveWithPoint:curve atIndex:2]];
    
    [exposure addTarget:vignette];
    [vignette addTarget:tonecurve];
    
    effectIn = exposure;
    effectOut = tonecurve;
    return nil;
}

- (GPUImageFilterGroup *)effect3 {
    UIImage *image = [UIImage imageNamed:@"grain.jpg"];
    texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    rgb.red = 1.36;
    rgb.green = 1.36;
    rgb.blue = 1.28;

    exposure.exposure = 0.2;
    vignette.vignetteStart = 0.4;
    vignette.vignetteEnd = 1.0;
    contrast.contrast = 1.1;
    brightness.brightness = -0.05;
    
    [rgb addTarget:exposure];
    [exposure addTarget:vignette];
    [vignette addTarget:grain];
    
    [texture processImage];
    [texture addTarget:grain];
    [grain addTarget:mono];
    
    [mono addTarget:contrast];
    [contrast addTarget:brightness];

    effectIn = rgb;
    effectOut = brightness;
    return nil;
}


- (GPUImageFilterGroup *)effect4 {    
    vignette.vignetteStart = 0.5;
    vignette.vignetteEnd = 0.90;
    contrast.contrast = 1.85;
    brightness.brightness = 10.0/255.0;
    sepia.intensity = 0.55;
    blur.excludeCircleRadius = 220.0/320.0;
    
    [contrast addTarget:brightness];
    [brightness addTarget:blur];
    [blur addTarget:vignette];
    [vignette addTarget:sepia];
    
    effectIn = contrast;
    effectOut = sepia;
    
    return nil;
}

- (GPUImageFilterGroup *)effect5 {
    UIImage *image = [UIImage imageNamed:@"grain.jpg"];
    texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    vignette.vignetteStart = 0.5;
    vignette.vignetteEnd = 1.1;
    
    float curve[16][3] = {
        {19.0, 0.0, 0.0},
        {31.0, 9.0, 0.0},
        {41.0, 24.0, 1.0},
        {53.0, 39.0, 2.0},
        {65.0, 55.0, 25.0},
        {79.0, 72.0, 46.0},
        {93.0, 89.0, 70.0},
        {109.0, 108.0, 95.0},
        {124.0, 127.0, 122.0},
        {139.0, 146.0, 148.0},
        {154.0, 165.0, 174.0},
        {169.0, 182.0, 197.0},
        {183.0, 199.0, 219.0},
        {195.0, 215.0, 242.0},
        {207.0, 229.0, 254.0},
        {218.0, 244.0, 255.0}
    };
    contrast.contrast = 1.3;
    
    [tonecurve setRedControlPoints:[self curveWithPoint:curve atIndex:0]];
    [tonecurve setGreenControlPoints:[self curveWithPoint:curve atIndex:1]];
    [tonecurve setBlueControlPoints:[self curveWithPoint:curve atIndex:2]];
    
    [vignette addTarget:contrast];
    [contrast addTarget:grain];
    [texture addTarget:grain];
    [texture processImage];
    [grain addTarget:tonecurve];
    
    effectIn = vignette;
    effectOut = tonecurve;
    
    return nil;
}

- (void)tmpEffect1 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"crossprocess"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect2 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"02"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect3 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"17"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect4 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"aqua"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect5 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"yellow-red"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect6 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"06"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect7 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"purple-green"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)clearTargetWithCamera:(GPUImageStillCamera *)camera andPicture:(GPUImagePicture *)picture {
    if (camera != nil) {
        [camera removeAllTargets];
    }
    if (picture != nil) {
        [picture removeAllTargets];
    }
    
    [brightness removeAllTargets];
    [distord removeAllTargets];
    [tiltShift removeAllTargets];
    [sharpen removeAllTargets];
    [vignette removeAllTargets];
    [tonecurve removeAllTargets];
    [rgb removeAllTargets];
    [exposure removeAllTargets];
    [crop removeAllTargets];
    [crop2 removeAllTargets];
    [contrast removeAllTargets];
    [mono removeAllTargets];
    [sepia removeAllTargets];
    [blur removeAllTargets];
    [grain removeAllTargets];
//    brightness = [[GPUImageBrightnessFilter alloc] init];
//    distord = [[GPUImagePinchDistortionFilter alloc]init];
//    tiltShift = [[GPUImageTiltShiftFilter alloc]init];
//    sharpen = [[GPUImageSharpenFilter alloc] init];
//    vignette = [[GPUImageVignetteFilter alloc] init];
//    tonecurve = [[GPUImageToneCurveFilter alloc] init];
//    exposure = [[GPUImageExposureFilter alloc] init];
//    rgb = [[GPUImageRGBFilter alloc] init];
//    crop = [[GPUImageCropFilter alloc] init];
//    contrast = [[GPUImageContrastFilter alloc] init];
//    mono = [[GPUImageGrayscaleFilter alloc] init];
//    sepia = [[GPUImageMonochromeFilter alloc]init];
//    blur = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
//    grain = [[GPUImageOverlayBlendFilter alloc] init];
}

- (GPUImageCropFilter*) getCrop {
    return crop;
}

- (NSArray *)curveWithPoint:(float[16][3])points atIndex:(int)idx {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 16; i++) {
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(16.0*i/240.0, points[i][idx]/255.0)]];
    }
    return array;
}

- (void)saveImage:(NSDictionary *)location orientation:(UIImageOrientation)imageOrientation withMeta:(NSMutableDictionary *)imageMeta onComplete:(void(^)(ALAsset *asset))block {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (imageMeta == nil) {
        imageMeta = [[NSMutableDictionary alloc] init];
    }
    
    [imageMeta removeObjectForKey:(NSString *)kCGImagePropertyOrientation];
    [imageMeta removeObjectForKey:(NSString *)kCGImagePropertyTIFFOrientation];
    
    // Add GPS
    if (location != nil) {
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    // Add App Info
    [imageMeta setObject:@"Latte" forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    
    if (lastFilter == nil) {
        lastFilter = [[GPUImageBrightnessFilter alloc] init];
    }
    UIImage *imageTmp = [lastFilter imageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
    
    NSData *imageData = UIImageJPEGRepresentation(imageTmp, 0.9);
    [library writeImageDataToSavedPhotosAlbum:imageData metadata:imageMeta completionBlock:^(NSURL *assetURL, NSError *error) {
        [library assetForURL:assetURL
                 resultBlock:block
                failureBlock:nil];
    }];
}

@end
