//
//  MenuViewController.h
//  LH2GO
//
//  Created by Linchpin on 6/16/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderView.h"
#import "UIImage+Extra.h"
#import "ImagePickManager.h"
#import "ImageCropViewController.h"
#import "UIView+Extra.h"
#import "AFAppDotNetAPIClient.h"

@interface MenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    User *user ;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userEmail;
@property (weak, nonatomic) IBOutlet UIButton *userPlusButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconWidth;

@end
