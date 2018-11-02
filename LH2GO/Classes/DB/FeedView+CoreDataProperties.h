//
//  FeedView+CoreDataProperties.h
//  LH2GO
//
//  Created by Sonal on 31/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//
//

#import "FeedView+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FeedView (CoreDataProperties)

+ (NSFetchRequest<FeedView *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *channelId;
@property (nullable, nonatomic, copy) NSNumber *contact;
@property (nullable, nonatomic, copy) NSNumber *contactCount;
@property (nullable, nonatomic, copy) NSString *contentId;
@property (nullable, nonatomic, copy) NSNumber *cool;
@property (nullable, nonatomic, copy) NSNumber *coolCount;
@property (nullable, nonatomic, copy) NSNumber *created_time;
@property (nullable, nonatomic, copy) NSNumber *duration;
@property (nullable, nonatomic, copy) NSNumber *feed_Type;
@property (nullable, nonatomic, copy) NSNumber *isForChannel;
@property (nullable, nonatomic, copy) NSNumber *isForeverFeed;
@property (nullable, nonatomic, copy) NSString *mediaPath;
@property (nullable, nonatomic, copy) NSString *mediaType;
@property (nullable, nonatomic, copy) NSNumber *received_timeStamp;
@property (nullable, nonatomic, copy) NSNumber *share;
@property (nullable, nonatomic, copy) NSNumber *shareCount;
@property (nullable, nonatomic, copy) NSNumber *tempId;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *timeStr;
@property (nullable, nonatomic, copy) NSNumber *toBeDisplayed;

@end

NS_ASSUME_NONNULL_END
