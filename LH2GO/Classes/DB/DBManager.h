//
//  DBManager.h
//  LoudHailer
//
//  Created by Prakash Raj on 18/08/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

/*
 * A class is written to support in DB (Core data) process - insert/delete/update.
 */

#import <Foundation/Foundation.h>

#import "ShoutInfo.h"
#import "Shout.h"
#import "User.h"
#import "Network.h"
#import "Group.h"
#import "Channels.h"
#import "Notifications.h"
#include <pthread.h>
#import <objc/objc-sync.h>



typedef NS_ENUM(NSInteger, SyncType) {
    SyncTypeUnknown = 0,
    SyncTypeSynced,
    SyncTypeUnsynced
};

@interface DBManager : NSObject

/*!
 @method : to get a entity from DB.
 @abstract : call when you broadcast/recieve a shout.
 @param : entityName - pass table name
 @param : idName,idValue - pass identity name & value like username = raj.
 */
+ (id)entity: (NSString *)entityName
      idName: (NSString *)idName
     idValue: (NSString *)idValue;

//for email
+ (id)entityWithPredicate:(NSString *)entityName idName:(NSString *)idName
                  idValue:(NSString *)idValue;
+ (id)entityWithStr:(NSString *)entityName idName:(NSString *)idName
            idValue:(NSString *)idValue;
/*! @method : to delete an Object from DB. */
+ (void)deleteOb:(NSManagedObject *)obj;
+ (NSArray *)usersSorted:(BOOL)sorted;
+ (NSArray *)usersSorted:(BOOL)sorted notInGroup:(Group*)group;
+ (NSArray *)usersSortedInForLH2GONetwork:(BOOL)sorted notInGroup:(Group*)group;
/*! @method : to save context(State). */
+ (void)save;
+ (NSArray *)entities: (NSString *)entityName pred: (NSString *)pred descr: (NSSortDescriptor *)desc isDistinctResults:(BOOL)distinct;

// users deletion from group
+ (void)deleteUsers:(NSArray*)array fromGroup:(Group *)group;
// add users in to existing group
+ (void)addUsers:(NSArray *)users toGroup:(Group *)group;
+ (void)addInvitedUsers:(NSArray *)users toGroup:(Group *)group;
// add emailed users in to existing group
+ (void)addEmailedUsers:(NSArray *)users toGroup:(Group*)group;
+ (NSArray*)getPendingEmailUsers:(Group*)group;
+ (NSArray*)getNetworks;
+ (NSArray *)getAllFavouriteShouts;
+ (NSArray *)getAllNotifications;
+ (NSArray *)getAllFavouriteChieldShouts:(Shout*)shout;
+ (void)clearMyData;
+ (void)clearMyDataOnBackgroundRefresh;
+ (NSArray *)latestShouts;
+ (NSArray *)getAllShoutsForBackup:(BOOL)sorted;
+ (BOOL)isGroupsExistForGroupId:(NSString*)groupId;
//get all notification whose type is NotfType_nonAdmingroupInvite or NotfType_groupInvite
+(NSArray *)getArrayOfActionableNotifications;
+ (NSArray *)getShortedGroupsForNetwork:(Network*)net;
+ (NSArray *)getChannelsForNetwork:(Network*)net;

//get unsynced backups
+(NSArray *)getUnSyncedBackUps;
//get all back ups
+(NSArray *)getAllBackUps;
//This function giving all backups which are synced
+ (NSArray *)getSyncedBackUps;
+ (NSArray *)getUnSyncedFavShouts;
+ (NSArray *)getUnsyncedShouts;
+ (BOOL)isSyncedShoutsAndShoutsBackUp;
+ (void)cleanBkUps;
+ (void)cleanShouts;
+ (void) deleteAllFromEntity:(NSString *)entityName;

+ (NSArray *)entityWithStr:(NSString *)entityName idName:(NSString *)idName idValueFor:(NSString *)idValue;
// fetch the channel using the content id
+(NSArray *)getChannelDataFromFromContentID:(NSString *)contentID Network:(Network*)net;

+(NSArray *)getChannelDataFromNameAndId:(NSString *)nameOrId isName:(BOOL)name Network:(Network*)net;
//+(void)deleteShoutsMarkBackUp;//based on permission
//+(void)deleteBackUp;////based on permission
+(NSInteger)getUnresdShoutsCount;
+(NSInteger)getUnreadChannelContentCount;


+ (NSArray *)entities: (NSString *)entityName1 pred: (NSString *)pred1 descr: (NSSortDescriptor *)desc isDistinctResultss:(BOOL)distinct;


/**
 @brief Method is used to delete the previous stored Image. It will be deleted if different user will do login.
 */
+(void)deletetheStoreImage;

//Badge count Fix

+(NSInteger)getTotalReceivedShoutsFromShoutsTableForParticularGroup:(Group*)group withUser:(NSString*)userID;
+(void)updateShoutsIsReadOnClickingMessages:(NSString*)groupID withUserID:(NSString*)userID;
+(NSInteger)getTotalReceivedShoutsFromShoutsTable:(NSString*)userID;

+ (NSArray *)entitiesByArrayDesc: (NSString *)entityName1 pred: (NSString *)pred1 arrayOfDesc: (NSArray *)descArr isDistinctResults:(BOOL)distinct;
+(NSArray *)entitiesForScheduled: (NSString *)entityName1 pred: (NSString *)pred1 descr: (NSSortDescriptor *)desc isDistinctResults:(BOOL)distinct;
+ (NSArray *)entitiesToSaveChannelData: (NSString *)entityName1 pred: (NSString *)pred1 descr: (NSSortDescriptor *)desc isDistinctResults:(BOOL)distinct;
+(NSArray*)searchKeywordinChannelsForText:(NSString*)searchText;
+(NSArray*) searchKeywordinChannelFeedForText:(NSString*)searchText;
@end
