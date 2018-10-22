//
//  CommsViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 20/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHMessagingBaseViewController.h"
#import "RelayView.h"
#import "RelayObject.h"
//#import "AdvanceSettingsViewController.h"

@interface CommsViewController : LHMessagingBaseViewController<RelayListDelegate,UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
UIPopoverController *popoverController;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (strong, nonatomic) RelayView *relayView;

@property BOOL isBackFromComms;
@property (weak, nonatomic) IBOutlet UILabel *firstIndexLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLabelIndex;

@property (weak, nonatomic) IBOutlet UILabel *masterOrSlaveCount;
@property (weak, nonatomic) IBOutlet UILabel *user_IdLabel;
@property (nonatomic,strong)UIButton *btnBackupforAnimate;

-(void)backUp;
-(void)closebackupButton;
- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType;

@end
