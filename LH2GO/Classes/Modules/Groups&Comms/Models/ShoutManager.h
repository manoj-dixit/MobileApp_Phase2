//
//  ShoutManager.h
//  LoudHailer
//
//  Created by Prakash Raj on 11/07/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kShoutObjFromNotification     = @"ShoutObjFromNotification";
static NSString *kShouldShowBanner     = @"shouldShowBanner";//if condition: if app is in background and user is open the app by taping on app icon then it should display the badge icon on group cell UI, BUT NOT SHOW BANNERALERT >> ALOK
static NSString *kNewShoutEncounterTemp     = @"LoudNewShoutEncounterTemp";

@class ShoutInfo;

@interface ShoutManager : NSObject

//@property (nonatomic,strong) NSOperationQueue *queueToSaveSendData;
//@property (nonatomic,strong) NSOperationQueue *queueToSaveReceiveData;

+ (instancetype)sharedManager;
+ (id)obFromData:(NSData *)data;
+ (NSData *)dataFromObjectForShout:(id)obj;
+ (NSData *)dataFromObjectForPing:(id)obj;
//manoj
+(NSData *)decryptData:(NSData *)data;

+(NSString*)stringFromEncodedData:(NSData *)data;
+(NSData*)mediaFromEncodedData:(NSData *)data;

- (void)clearAllGarbageShoutes;
- (void)clearInProgressGarbageShoutes;
- (void)enqueueShout:(ShoutInfo *)sh forUpdation:(BOOL)isUpdate;
- (void)enqueueShoutForSender:(ShoutInfo *)sh forUpdation:(BOOL)isUpdate;
- (void)notifyForNewShout:(Shout *)sht;
- (void)insertShoutBasedOnHeader:(ShoutHeader*)header;
- (void)updateShoutBasedOnHeader:(ShoutDataReceiver*)header;
- (void)dequeueShout:(Shout *)sh;
- (void)clearInProgressGarbageShoute:(NSString*)shoutId;
- (void)autoRelay:(ShoutInfo*)sh;
@property (nonatomic, strong, readonly) NSMutableArray *shouts;

@end

// shout in/out ...
static NSString *kNewShoutEncounter     = @"LoudNewShoutEncounter";
static NSString *kShoutDead             = @"LoudShoutDead";
