//
//  NotificationViewController.h
//  LH2GO
//
//  Created by Sumit Kumar on 01/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"

extern BOOL invitationAccepted;

@protocol NotificationViewControllerDelegate;

@interface NotificationViewController : BaseViewController

@property (nonatomic, assign) id <NotificationViewControllerDelegate> delegate;

- (void)refreshNotifications;
- (void)refreshUI;

-(void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground;

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick;

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType;

@end


@protocol NotificationViewControllerDelegate <NSObject>
@optional

@end
