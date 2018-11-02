//
//  FeedView+CoreDataProperties.m
//  LH2GO
//
//  Created by Sonal on 31/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//
//

#import "FeedView+CoreDataProperties.h"

@implementation FeedView (CoreDataProperties)

+ (NSFetchRequest<FeedView *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"FeedView"];
}

@dynamic channelId;
@dynamic contact;
@dynamic contactCount;
@dynamic contentId;
@dynamic cool;
@dynamic coolCount;
@dynamic created_time;
@dynamic duration;
@dynamic feed_Type;
@dynamic isForChannel;
@dynamic isForeverFeed;
@dynamic mediaPath;
@dynamic mediaType;
@dynamic received_timeStamp;
@dynamic share;
@dynamic shareCount;
@dynamic tempId;
@dynamic text;
@dynamic timeStr;
@dynamic toBeDisplayed;

@end
