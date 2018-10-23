//
//  ReportViewController.h
//  LH2GO
//
//  Created by Parul Mankotia on 17/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : BaseViewController
{
    __weak IBOutlet UITextField *usrName;
    NSString *reportEmailIs;
}

@property(nonatomic, weak) IBOutlet UIView *selectOptionView;

-(IBAction)reportBugAction:(UIButton*)sender;
-(IBAction)reportUserAction:(UIButton*)sender;

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick;
- (void)goToNotificationScreen:(NSDictionary*)dict isClickedOnPush:(BOOL)isPush;

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType;

- (void)goToChannelScreen:(NSDictionary*)dict;

-(void)moveToChannelScreen:(NSString *)channelID;
-(void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground;

@end
