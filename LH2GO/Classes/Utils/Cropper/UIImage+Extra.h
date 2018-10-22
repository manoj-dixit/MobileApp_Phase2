//
//  UIImage+Extra.h
//
//  Created by Prakash Raj on 06/09/13.
//  Copyright (c) 2013 kiwitech. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (Extra)

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage *)fixOrientation;
- (UIImage *)imageTransformedBy:(CGAffineTransform)t;

- (UIImage *)rotatebyDegree:(CGFloat)degrees;

- (NSData *)compressedData;

@end
