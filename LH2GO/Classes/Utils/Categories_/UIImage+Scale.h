//
//  UIImage+Scale.h
//  LoudHailer
//
//  Created by Prakash Raj on 11/08/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)

- (UIImage *)squareImage;

- (UIImage *)imageByScalingToSize:(CGSize)sz;

- (UIImage *)fixOrientation;
- (UIImage *)imageTransformedBy:(CGAffineTransform)t;

@end
