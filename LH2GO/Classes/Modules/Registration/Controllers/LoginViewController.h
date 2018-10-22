//
//  LoginViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForgetPassViewController.h"
#import "UserConfigurationSettings.h"
#import "CoreDataManager.h"
#import "AppDelegate.h"

/*
 * @block : to perform task on completion.
 * @arg : success - provide the result status YES/NO.
 */
typedef void (^LoginCompletionBlock)(BOOL success, NSError *error);

@interface LoginViewController : UIViewController
@property (nonatomic, copy) LoginCompletionBlock completion;
@property (weak, nonatomic) IBOutlet UIView *topDiag_View;
@property (weak, nonatomic) IBOutlet UIView *topLogo_View;

- (void)loginCompleted:(BOOL)isLoggedIn;
- (void)parseResponse:(NSDictionary *)response addImage:(UIImage *)image;
- (IBAction)forceCrash:(id)sender;

@end
