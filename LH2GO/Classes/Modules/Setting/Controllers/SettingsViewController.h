//
//  SettingsViewController.h
//  LH2GO
//
//  Created by Linchpin on 6/28/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ShoutManager.h"
#import "BannerAlert.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"

@interface SettingsViewController : BaseViewController<UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    __weak IBOutlet UIButton *changeProfIconBtn;
    __weak IBOutlet UIImageView *usrImg;
    __weak IBOutlet UITextField *usrName;
    __weak IBOutlet UILabel *usrEmail;
    __weak IBOutlet UILabel *versionNumber;
    __weak IBOutlet UISwitch *notfSwitch;
    __weak IBOutlet UIButton *reportUsrBtn;
    __weak IBOutlet UIButton *reportBugBtn;
    __weak IBOutlet UILabel *lbl_chngPswd;
    __weak IBOutlet UILabel *lbl_arrow;
    __weak IBOutlet UILabel *lbl_receive;
    __weak IBOutlet UILabel *lbl_blockedUser;
    __weak IBOutlet UILabel *lbl_arrow1;
    NSString *reportEmailIs;

}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconWidth;

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick;
- (void)goToNotificationScreen:(NSDictionary*)dict isClickedOnPush:(BOOL)isPush;

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType;

- (void)goToChannelScreen:(NSDictionary*)dict;

-(void)moveToChannelScreen:(NSString *)channelID;
-(void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground;
@end
