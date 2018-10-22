//
//  ForgetPassViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 06/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPassViewController : UIViewController

- (void)forgetPassforEmail:(NSString *)email completion:(void (^)(BOOL success, NSError *error))block;
@property (weak, nonatomic) IBOutlet UIView *top_logo_view;
@property (weak, nonatomic) IBOutlet UIView *poweredby_view;
@property BOOL comeBeforeLogin;
- (IBAction)backClicked:(id)sender;
- (IBAction)backToSignupView:(id)sender;
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict;

@end
