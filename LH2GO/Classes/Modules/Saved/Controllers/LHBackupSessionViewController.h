//
//  LHBackupSessionViewController.h
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "BaseViewController.h"

@interface LHBackupSessionViewController : BaseViewController

@property(nonatomic, strong) NSArray *arrBackUp;
//- (void)goToComunicationScreenForShout:(Shout*)sht;
- (void)goToNotificationScreen:(NSDictionary*)dict isClickedOnPush:(BOOL)isPush;

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType;

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick;
-(void)moveToChannelScreen:(NSString *)channelID;
- (void)goToChannelScreen:(NSDictionary*)dict;
@end
