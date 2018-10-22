//
//  UITextfield+Extra.m
//  LH2GO
//
//  Created by Prakash Raj on 05/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "UITextfield+Extra.h"

@implementation UITextField (Extra)


- (void)setPlaceholderColor:(UIColor *)clr {
    [self setValue:clr forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)setMargin:(float)margin {
    UIView *padView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, margin, 20)];
    self.leftView = padView1;
    self.leftViewMode = UITextFieldViewModeAlways;
}


- (void)setClearButtonImage:(UIImage *)image {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)]; // Required for iOS7
    self.rightView = button;
    self.rightViewMode = UITextFieldViewModeWhileEditing;
}

@end
