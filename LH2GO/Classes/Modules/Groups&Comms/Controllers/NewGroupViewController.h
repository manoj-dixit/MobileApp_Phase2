//
//  NewGroupViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 16/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CommonActions.h"
#import "BaseViewController.h"

@interface NewGroupViewController : BaseViewController<UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
UIPopoverController *popoverController;
}
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, strong) NSString *networkName; // only new network case.
@end
