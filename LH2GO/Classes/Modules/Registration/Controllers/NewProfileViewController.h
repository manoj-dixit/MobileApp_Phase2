//
//  NewProfileViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CommonActions.h"

@interface NewProfileViewController : UIViewController<UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

{
    UIPopoverController *popoverController;
}
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (weak, nonatomic) IBOutlet UIView *topDiag_View;
@property (weak, nonatomic) IBOutlet UIView *topLogo_View;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content_ViewHgt;


@end
