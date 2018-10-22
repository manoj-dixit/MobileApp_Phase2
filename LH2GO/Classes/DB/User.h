//
//  User.h
//  LH2GO
//
//  Created by Sumit Kumar on 24/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class Group,Network,Shout,Channels;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * picUrl;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * parent_account_id;
@property (nonatomic, retain) NSString * user_role;
@property (nonatomic,retain) NSString *loud_hailerid;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *networks;
@property (nonatomic, retain) NSSet *ownedGroups;
@property (nonatomic, retain) NSSet *ownedShouts;
@property (nonatomic, retain) NSSet *pendingGroups;
@property (nonatomic, retain) NSSet *shouts;
@property (nonatomic, retain) NSSet *channels;
@property (nonatomic,retain) NSNumber *eventCount;
@property (nonatomic, retain) NSNumber * isBlocked;


- (void)getImage;

/*! @method : get a User with id */
+ (User *)userWithId:(NSString *)userId shouldInsert:(BOOL)insert;

/*! @method : to insert a User to DB. */
+ (User *)addUserWithDict:(NSDictionary *)dict pic:(UIImage *)pic;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addNetworksObject:(Network *)value;
- (void)removeNetworksObject:(Network *)value;
- (void)addNetworks:(NSSet *)values;
- (void)removeNetworks:(NSSet *)values;

- (void)addOwnedGroupsObject:(Group *)value;
- (void)removeOwnedGroupsObject:(Group *)value;
- (void)addOwnedGroups:(NSSet *)values;
- (void)removeOwnedGroups:(NSSet *)values;

- (void)addOwnedShoutsObject:(Shout *)value;
- (void)removeOwnedShoutsObject:(Shout *)value;
- (void)addOwnedShouts:(NSSet *)values;
- (void)removeOwnedShouts:(NSSet *)values;

- (void)addPendingGroupsObject:(Group *)value;
- (void)removePendingGroupsObject:(Group *)value;
- (void)addPendingGroups:(NSSet *)values;
- (void)removePendingGroups:(NSSet *)values;

- (void)addShoutsObject:(Shout *)value;
- (void)removeShoutsObject:(Shout *)value;
- (void)addShouts:(NSSet *)values;
- (void)removeShouts:(NSSet *)values;


- (void)addChannelsObject:(Channels *)value;
- (void)removeChannelsObject:(Channels *)value;
- (void)addChannels:(NSSet *)values;
- (void)removeChannels:(NSSet *)values;
+ (User *)userWithId:(NSString *)userId shouldInsert:(BOOL)insert withUserName:(NSString *)userName;
@end
