//
//  Network.h
//  LH2GO
//
//  Created by Prakash Raj on 14/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, User,Channels;

@interface Network : NSManagedObject

@property (nonatomic, retain) NSString * netCharKey;
@property (nonatomic, retain) NSString * netId;
@property (nonatomic, retain) NSString * netName;
@property (nonatomic, retain) NSString * netTransKey;
@property (nonatomic, retain) NSNumber * timeStamp;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSSet *channels;


/*! @method : get a Network with id */
+ (Network *)networkWithId:(NSString *)netId shouldInsert:(BOOL)insert;

/*! @method : to insert a Network to DB. */
+ (Network *)addNetworkWithDict:(NSDictionary *)dict;

@end

@interface Network (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

- (void)addChannelsObject:(Channels *)value;
- (void)removeChannelsObject:(Channels *)value;
- (void)addChannels:(NSSet *)values;
- (void)removeChannels:(NSSet *)values;

@end
