//
//  LHManegGroupViewController.h
//  LH2GO
//
//  Created by Sumit Kumar on 05/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LHManegGroupViewController : BaseViewController<UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIPopoverController *popoverController;

}
@property (nonatomic, strong) Group *myGroup;
@property (nonatomic, assign) BOOL isNonAdmin;
@property (nonatomic, retain) UIPopoverController *popoverController;

- (void)inviteGroup;
@end
