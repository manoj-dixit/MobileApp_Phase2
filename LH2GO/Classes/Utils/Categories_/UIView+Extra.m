//
//  UIView+Extra.m
//  LoudHailer
//
//  Created by Prakash Raj on 31/07/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "UIView+Extra.h"

@implementation UIView (extra)

- (NSMutableArray *)allSubViews {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:self];
    for (UIView *subview in self.subviews) {
        [arr addObjectsFromArray:(NSArray*)[subview allSubViews]];
    }
    return arr;
}


- (void)roundCorner:(float)radius border:(float)border
        borderColor:(UIColor *)clr {

    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
    if (clr) self.layer.borderColor = clr.CGColor;
    self.layer.borderWidth = border;
}

- (void)makeCircularWithBorder:(float)border
                   borderColor:(UIColor *)clr {
    
    [self roundCorner:self.bounds.size.height/2.0 border:border borderColor:clr];
}

@end
