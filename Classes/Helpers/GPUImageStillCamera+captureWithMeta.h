//
//  GPUImageStillCamera+captureWithMeta.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/18.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageStillCamera.h"

@interface GPUImageStillCamera (captureWithMeta)

- (void)capturePhotoAsImageWithMeta:(void (^)(UIImage *processedImage, NSMutableDictionary *metadata, NSError *error))block;
- (void)processMyBuffer:(CMSampleBufferRef)imageSampleBuffer;

@end