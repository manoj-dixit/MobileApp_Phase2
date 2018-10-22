//
//  ManageViewController.h
//  LH2GO
//
//  Created by Linchpin on 28/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupUsersCell.h"
#import "PendingUsersCell.h"
#import "InviteBtnCell.h"
#import "Common.h"
#import "GroupCollectionCell.h"
#import "InviteUserViewController.h"
#import "UITextfield+Extra.h"
@interface ManageViewController :  BaseViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,InviteUserListViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableAddGroup;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak, nonatomic) IBOutlet UIButton *btnAddEditName;
@property (weak, nonatomic) IBOutlet UITextField *txt_GroupName;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, strong) Group *myGroup;
@property (strong,nonatomic)NSMutableArray *datasource;
@property NSInteger selectedIndex;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconWidth;



@end
