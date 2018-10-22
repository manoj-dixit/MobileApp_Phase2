//
//  AddGroupViewController.h
//  LH2GO
//
//  Created by Linchpin on 27/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InviteBtnCell.h"
#import "Common.h"
#import "InviteUserViewController.h"
#import "UITextfield+Extra.h"
#import "UIViewController+CommonActions.h"
#import "BaseViewController.h"


@interface AddGroupViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableAddGroup;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak, nonatomic) IBOutlet UITextField *txt_GroupName;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconWidth;
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict;
@end
