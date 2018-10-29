//
//  Channels.h
//  LH2GO
//
//  Created by Linchpin on 7/18/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class Network,User;

@interface Channels : NSManagedObject

@property (nonatomic, retain) NSString * channelId;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic,retain)  NSString *channelPId;
@property (nonatomic, retain) Network *network;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic,retain) NSNumber *isSubscribed;
@property (nonatomic,retain) NSNumber *contentCount;

@property (nonatomic,retain)  NSString *type;



- (void)getImageForChannel;

/*! @method : get a Channel with id */
+ (Channels *)channelWithId:(NSString *)cId shouldInsert:(BOOL)insert;

/*! @method : to insert a Channel to DB. */
+ (Channels *)addChannelWithDict:(NSDictionary *)dict
                        forUsers:(NSArray *)users
                             pic:(UIImage *)pic isSubscribed:(NSString*)subscribe channelType:(NSString *)type;

- (void)clearCount:(Channels*)ch;
@end

