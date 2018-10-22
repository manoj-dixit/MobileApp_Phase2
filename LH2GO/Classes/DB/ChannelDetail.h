//
//  ChannelDetail.h
//  LH2GO
//
//  Created by Linchpin on 8/2/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ChannelDetail : NSManagedObject

@property (nonatomic, retain) NSString * channelId;
@property (nonatomic,retain) NSString *contentId;
@property (nonatomic,retain) NSString *mediaPath;
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *mediaType;
@property (nonatomic,retain) NSNumber *duration;
@property (nonatomic,retain) NSNumber *tempId;
@property (nonatomic,retain) NSString *timeStr;
@property (nonatomic,retain) NSNumber *received_timeStamp;
@property (nonatomic,retain) NSNumber *coolCount;
@property (nonatomic,retain) NSNumber *shareCount;
@property (nonatomic,retain) NSNumber *contactCount;
@property (nonatomic,retain) NSNumber *created_time;


@property  BOOL isForeverFeed;

@property  BOOL toBeDisplayed;
@property  BOOL isForChannel;
@property  BOOL cool;
@property  BOOL share;
@property  BOOL contact;
@property  BOOL feed_Type;

- (void)getImageForChannelContent;

/*! @method : get a Channel with id */
+ (ChannelDetail *)channelContentWithId:(NSString *)cId shouldInsert:(BOOL)insert;

/*! @method : to insert a Group to DB. */
+ (ChannelDetail *)addChannelContentWithDict:(NSDictionary *)dict tempId:(NSInteger)tempId;


+ (ChannelDetail *)addChannelContentWithDictForDefaultChannel:(NSDictionary *)dict tempId:(NSInteger)tempId;


@end
