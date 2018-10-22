//
//  AdvanceSettingBottomView.h
//  LH2GO
//
//  Created by Linchpin on 06/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvanceSettingBottomView : UIView
+ (AdvanceSettingBottomView *)tabbarWithFrame:(CGRect)frame;
- (void)addTarget:(id)target andSelector:(SEL)selector;
@end
