//
//  Shout.h
//  LH2GO
//
//  Created by Sumit Kumar on 24/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

static NSString *kShoutLifeLineUpdate = @"LoudShoutLifeLineUpdate";
static NSString *kShoutProgressUpdate = @"LoudShoutProgressUpdate";

@class Group, Shout, ShoutBackup, User, ShoutInfo;

@interface Shout : NSManagedObject

@property (nonatomic, retain) NSString * contentUrl;
@property (nonatomic, retain) NSString *cmsID;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSNumber * isBackup;
@property (nonatomic, retain) NSNumber * life;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * original_timestamp;
@property (nonatomic, retain) NSString * shId;
@property (nonatomic, retain) NSNumber * synced;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic,retain) NSNumber *cmsTime;
@property (nonatomic) BOOL isFromCMS;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * isShoutRecieved;
@property (nonatomic, retain) NSString * pShId;
@property (nonatomic, retain) NSSet *chield_shouts;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) Shout *parent_shout;
@property (nonatomic, retain) User *reciever;
@property (nonatomic, retain) ShoutBackup *backup;
@property (nonatomic,retain) NSNumber *reportedShout;

+ (BOOL)isExistShoutId:(NSString *)sId;
+ (Shout *)shoutWithId:(NSString *)sId shouldInsert:(BOOL)insert;
+ (Shout *)insertShoutInfo:(ShoutInfo *)sh isSender:(BOOL)Sender;
+(Shout *)inserServerShoutInDbWithDict:(NSDictionary *)dict completion:(void (^)(BOOL finished))completion;
- (void)removeGarbageShout;
// release me all latest shout, their lifeline left.
+ (NSArray *)latestShoutsForGroup:(Group *)group;
+(void)updateShoutNeedBackUpAndNeedSync:(NSArray *)arrayServerResponse originalArray:(NSArray *)originalArray;
+(void)updateShoutForNoBackupPermissionAndSynced:(NSArray *)shtArr;//permission case
+(void)updateShoutForAlreadyBackupAndSynced:(NSArray *)shtArr;
+ (NSDictionary*)getParamsFrom:(Shout*)sht;
- (void)trackMe:(Shout*)sh;
- (void)updateChieldShouts;
- (void )updateAllUnlinkChieldShouts;

@end

@interface Shout (CoreDataGeneratedAccessors)

- (void)addChield_shoutsObject:(Shout *)value;
- (void)removeChield_shoutsObject:(Shout *)value;
- (void)addChield_shouts:(NSSet *)values;
- (void)removeChield_shouts:(NSSet *)values;

@end
