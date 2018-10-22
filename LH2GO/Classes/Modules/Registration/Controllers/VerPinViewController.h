//
//  VerPinViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEManager.h"

@interface VerPinViewController : UIViewController<CustomViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topLogo_View;
@property (weak, nonatomic) IBOutlet UIView *poweredByView;
@property (weak, nonatomic) IBOutlet UIView *topDiag_View;
- (IBAction)backClicked:(id)sender;
- (IBAction)btnAction_ResendCode:(id)sender;

-(void)redirectToChannelScreen;


@end
