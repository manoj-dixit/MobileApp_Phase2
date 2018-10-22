//
//  UIView+Extra.h
//  LoudHailer
//
//  Created by Prakash Raj on 31/07/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@interface UIView (extra)

- (NSMutableArray *)allSubViews;

- (void)roundCorner:(float)radius border:(float)border
        borderColor:(UIColor *)clr;

- (void)makeCircularWithBorder:(float)border
                   borderColor:(UIColor *)clr;
@end
