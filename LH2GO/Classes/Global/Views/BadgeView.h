//
//  BadgeView.h
//  LH2GO
//
//  Created by Prakash Raj on 10/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

// Enum (globaly used).
typedef enum {
    badgeCorner_TopLeft = 0,
    badgeCorner_TopRight,
    badgeCorner_BottomLeft,
    badgeCorner_BottomRight,
    badgeCorner_TopDefault = badgeCorner_TopRight
} badgeCorner;

@interface BadgeView : UIView

+ (void)addBadge: (NSInteger)badge toView: (UIView *)vv
        inCorner: (badgeCorner)corner
         marginX: (NSInteger)marX marginY: (NSInteger)marY;

+ (BOOL)containedBy: (UIView *)vv;
- (void)updateBadge: (NSInteger)badge;

@end
