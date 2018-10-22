//
//  Group.h
//  LH2GO
//
//  Created by Sumit Kumar on 24/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Network, Shout, User;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * badge;
@property (nonatomic, retain) NSString * grId;
@property (nonatomic, retain) NSString * grName;
@property (nonatomic, retain) NSString * picUrl;
@property (nonatomic, retain) NSNumber * timeStamp;
@property (nonatomic, retain) Network *network;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) NSSet *pendingUsers;
@property (nonatomic, retain) NSSet *shouts;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic,retain) NSNumber *totShoutsReceived;

@property BOOL isP2PContact;
@property BOOL isPending;
@property BOOL p2pStatus;


- (void)getImage;

/*! @method : get a Group with id */

+ (Group *)groupWithId:(NSString *)gId shouldInsert:(BOOL)insert isP2PContact:(BOOL)isP2P isPendingStatus:(BOOL)isPending;


/*! @method : to insert a Pending Group to DB. */
+ (Group *)addGroupWithDict:(NSDictionary *)dict forUsers:(NSArray *)users
                        pic:(UIImage *)pic pending:(BOOL)isPending;

- (void)upBadge;
- (void)clearBadge;
- (void)clearBadge:(Group*)gr;

+ (Group *)addGroupWithDictForP2PContact:(NSDictionary *)dict forUsers:(NSArray *)users
                                     pic:(UIImage *)pic isPendingStatus:(BOOL)isPending;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addPendingUsersObject:(User *)value;
- (void)removePendingUsersObject:(User *)value;
- (void)addPendingUsers:(NSSet *)values;
- (void)removePendingUsers:(NSSet *)values;

- (void)addShoutsObject:(Shout *)value;
- (void)removeShoutsObject:(Shout *)value;
- (void)addShouts:(NSSet *)values;
- (void)removeShouts:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
