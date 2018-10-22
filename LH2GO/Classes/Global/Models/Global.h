//
//  Global.h
//  LH2GO
//
//  Created by Prakash Raj on 13/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
#import "UIImageView+WebCache.h"

@class ProfileInfo;
@interface Global : NSObject

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) Channels *currentChannel;
@property (nonatomic, strong) NSArray *activities;
@property(nonatomic, assign) NSInteger countNotification;
@property (nonatomic, assign) BOOL isReadyToStartBLE;
@property (nonatomic, assign) BOOL isNotiLoading;
@property (nonatomic, assign) BOOL isServerDownloadInProgress;
@property (nonatomic, assign) BOOL isMessageForwarding;

/*!
 * @method : shared instance.
 */
+ (instancetype) shared;
+ (NSString *)currentTransService_UUID;
+ (NSString *)currentCharacteristic_UUID;
+ (NSString *)apiIS :(NSString *)baseURL :(NSString *)server :(NSString *)apiName;
- (void)saveVideo:(Shout*)_shoutObj;
@end

