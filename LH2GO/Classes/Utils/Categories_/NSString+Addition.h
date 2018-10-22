//
//  NSString+Addition.h
//  LocktonAtlas
//
//  Created by Prakash Raj on 11/04/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@interface NSString(Addition)

// @method : to get actual size with fixed width.
// pass you max width.
- (CGSize)actualSizeWithFont:(UIFont *)font stickToWidth:(CGFloat)sWidth;

// @method : to get actual size with fixed height.
// pass you max height.
- (CGSize)actualSizeWithFont:(UIFont *)font stickToHeight:(CGFloat)sHeight;

// @method : to get actual size with fixed width & height.
// pass you max width & height.
- (CGSize)actualSizeWithFont:(UIFont *)font stickToWidth:(CGFloat)sWidth
                   andHeight:(CGFloat)sHeight;

- (NSString*)stringByDeletingWhitespace;
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

@end
