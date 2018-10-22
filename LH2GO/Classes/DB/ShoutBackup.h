//
//  ShoutBackup.h
//  LH2GO
//
//  Created by Sumit Kumar on 24/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shout;

@interface ShoutBackup : NSManagedObject

@property (nonatomic, retain) NSDate * backUpDate;
@property (nonatomic, retain) NSString * backupId;
@property (nonatomic, retain) NSString * backupName;
@property (nonatomic, retain) NSString * backupNote;
@property (nonatomic, retain) NSNumber * synced;
@property (nonatomic, retain) NSNumber * edited;
@property (nonatomic, retain) NSSet *backupShouts;
@property (nonatomic, retain) NSNumber *downloaded;

+ (ShoutBackup *)addUserWithDict:(NSDictionary *)dict;
+ (ShoutBackup *)ShoutBackupWithId:(NSString *)backupId shouldInsert:(BOOL)insert;
+ (void)addShoutBackupWithDict:(NSDictionary *)dict;
+ (ShoutBackup *)isAlreadyShoutBackupWithName:(NSString *)backupName;

@end

@interface ShoutBackup (CoreDataGeneratedAccessors)

- (void)addBackupShoutsObject:(Shout *)value;
- (void)removeBackupShoutsObject:(Shout *)value;
- (void)addBackupShouts:(NSSet *)values;
- (void)removeBackupShouts:(NSSet *)values;

@end
