//
//  SecondTabBar.h
//  LH2GO
//
//  Created by Techbirds on 11/12/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

// Enum (globaly used).
typedef enum {
    BarItem_None = 5,
    BarItem_Notification,
    BarItem_AddGroup,
    BarItem_DeleteGroup,
    BarItem_ManageGroup
} BarItem;

@interface SecondTabBar : UIView

+ (SecondTabBar *)secondTabbarWithFrame:(CGRect)frame andSelectedTag:(BarItem)tag;
- (void)addSecondTabTarget:(id)target andSelector:(SEL)selector;
- (void)secondtabButton:(BarItem)selectedItemTag;
- (void)setLineColor:(NSInteger)selectedItemTag;
- (void)checkSecondTabBadges;



@end
