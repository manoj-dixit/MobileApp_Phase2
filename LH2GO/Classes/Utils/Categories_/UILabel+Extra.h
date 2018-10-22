//
//  UILabel+Extra.h
//  Test
//
//  Created by Prakash Raj on 30/01/14.
//  Copyright (c) 2014 Raj. All rights reserved.
//
//  - A category class is responsible to set frame of label according to font & text.

#import <UIKit/UIKit.h>

@interface UILabel (Extra)

// @method : to set frame according to text & font.
// pass your desired width.
- (void)setFrameAsTextStickToWidth:(CGFloat)sWidth;

// @method : to set frame according to text & font.
// pass your desired width.
- (void)setFrameAsTextStickToHeight:(CGFloat)sHeight;

// @method : to set frame according to text & font.
// pass you max width & height.
- (void)setFrameAsTextStickToWidth:(CGFloat)sWidth andHeight:(CGFloat)sHeight;

// @method : to bold specific text(substring).
// pass you substring.
- (void) boldSubstring:(NSString *)substring;

// @method : to bold specific text(substring) on provided range.
// pass you range of text.
- (void) boldRange:(NSRange)range;

@end
