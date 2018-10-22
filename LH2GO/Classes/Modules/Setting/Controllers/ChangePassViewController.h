//
//  ChangePassViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 06/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ChangePassViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPswd;
- (IBAction)btnAction_ForgotPassword:(id)sender;

@end
