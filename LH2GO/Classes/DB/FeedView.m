//
//  AllFeeds.m
//  LH2GO
//
//  Created by Sonal on 31/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "FeedView.h"

@implementation FeedView

@dynamic channelId;
@dynamic contentId;
@dynamic mediaPath;
@dynamic text;
@dynamic mediaType;
@dynamic duration;
@dynamic toBeDisplayed;
@dynamic tempId;
@dynamic timeStr;
@dynamic received_timeStamp;
@dynamic cool;
@dynamic coolCount;
@dynamic share;
@dynamic shareCount;
@dynamic contact;
@dynamic contactCount;
@dynamic created_time;
@dynamic isForeverFeed;
@dynamic isForChannel;
@dynamic feed_Type;

/*! @method : get a Channel with id */
+ (FeedView *)chanelContentWithID:(NSString *)contentId shouldInsert:(BOOL)insert
{
    FeedView *channeld = [DBManager entity:@"FeedView" idName:@"contentId" idValue:[NSString stringWithFormat:@"\'%@\'", contentId]];
    if (!insert) return channeld;
    
    if (!channeld) {
        channeld = [CoreDataManager insertObjectFor:@"FeedView"];
        channeld.contentId = contentId;
        [CoreDataManager saveContext];
    }
    return channeld;
}

/*! @method : to insert a Group to DB. */
+ (FeedView *)addChannelContentWithDict:(NSDictionary *)feedDict tempId:(NSInteger)tempId
{
    
    if (!feedDict) return nil;
    
    NSString *contentId = [AppManager sutableStrWithStr:[feedDict objectForKey:@"content_id"]];
    if (contentId == nil) {
        return nil;
    }
    FeedView *channeld = [FeedView chanelContentWithID: contentId shouldInsert:YES];
    
    NSString *channelId = [feedDict objectForKey:@"channelId"];
    
    NSArray *arr = [DBManager entitiesToSaveChannelData:@"FeedView" pred:[NSString stringWithFormat:@"contentId = \"%@\" AND channelId = \"%@\"", contentId,channelId] descr:nil isDistinctResults:YES];
    
    if(arr.count==1){
        
        ChannelDetail *channeldXYZ = arr[0];
        
        //        channelId = 71;
        //        contact = 0;
        //        contactCount = 1;
        //        "content_id" = 000033;
        //        cool = 0;
        //        coolCount = 1;
        //        duration = 999999;
        //        mediaType = TXXX;
        //        share = 0;
        //        shareCount = 0;
        //        text = huhuuhbb;
        
        
        if (([channeldXYZ.contactCount isEqualToNumber:[NSNumber numberWithInt:[[feedDict objectForKey:@"contactCount"] intValue]]] &&  [channeldXYZ.coolCount isEqualToNumber:[NSNumber numberWithInt:[[feedDict objectForKey:@"coolCount"] intValue]]] &&  channeldXYZ.cool ==[[feedDict objectForKey:@"cool"] boolValue] && channeldXYZ.contact == [[feedDict objectForKey:@"contact"] boolValue])  &&  channeldXYZ.share ==[[feedDict objectForKey:@"share"] boolValue] && [channeldXYZ.shareCount isEqualToNumber:[NSNumber numberWithInt:[[feedDict objectForKey:@"shareCount"] intValue]]] && [channeldXYZ.created_time isEqualToNumber:[NSNumber numberWithInteger:[[feedDict objectForKey:@"created_time"] integerValue]]])
        {
            return [arr objectAtIndex:0];
        }
        else
        {
            channeldXYZ.created_time = [NSNumber numberWithInteger:[[feedDict objectForKey:@"created_time"] integerValue]];
            [DBManager save];
        }
        NSLog(@"Manoj Return coz of change");
        return [arr objectAtIndex:0];
    }
    
    channeld.mediaPath = [feedDict objectForKey:@"mediaPath"];
    if(channeld.mediaPath == nil){
        channeld.mediaPath = @"";
    }
    channeld.text = [feedDict objectForKey:@"text"];
    channeld.mediaType = [feedDict objectForKey:@"mediaType"];
    channeld.channelId = [feedDict objectForKey:@"channelId"];
    NSString *appDisplayTime = [feedDict objectForKey:@"duration"];
    channeld.duration = [NSNumber numberWithInteger:[appDisplayTime longLongValue]];
    channeld.tempId = [NSNumber numberWithInteger:tempId];
    channeld.timeStr = @"";
    channeld.received_timeStamp = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];

    if([[feedDict objectForKey:@"cool"]boolValue])
        channeld.cool = YES;
    else
        channeld.cool = NO;
    if([[feedDict objectForKey:@"share"]boolValue])
        channeld.share = YES;
    else
        channeld.share = NO;
    
    if([[feedDict objectForKey:@"contact"]boolValue])
        channeld.contact = YES;
    else
        channeld.contact = NO;
    
    channeld.coolCount = [NSNumber numberWithInteger:[[feedDict objectForKey:@"coolCount"] integerValue]];
    channeld.shareCount = [NSNumber numberWithInteger:[[feedDict objectForKey:@"shareCount"]integerValue]];
    channeld.contactCount = [NSNumber numberWithInteger:[[feedDict objectForKey:@"contactCount"] integerValue]];
    channeld.created_time = [NSNumber numberWithInteger:[[feedDict objectForKey:@"created_time"] integerValue]];
    
    if([[feedDict objectForKey:@"isForeverFeed"]boolValue])
    {
        channeld.isForeverFeed = YES;
    }
    else{
        channeld.isForeverFeed = NO;
    }
    channeld.feed_Type       = [[feedDict objectForKey:@"feed_Type"] boolValue];
    channeld.toBeDisplayed = YES;
    channeld.isForChannel = [[feedDict objectForKey:@"isForChannel"] boolValue];
    return channeld;
}

+(NSArray *)getAllFeedsForFeedView
{
    NSSortDescriptor *sortDescToSortDataArray1 = [[NSSortDescriptor alloc] initWithKey:@"contentId" ascending:NO];
    NSSortDescriptor *sortDescToSortDataArray2 = [[NSSortDescriptor alloc] initWithKey:@"created_time" ascending:NO];
    
    NSArray *descArray = @[[sortDescToSortDataArray2 copy],[sortDescToSortDataArray1 copy]];

   // NSArray *allFeedsArray =  [DBManager entitiesByArrayDesc:@"FeedView" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", [Global shared].currentChannel.channelId] arrayOfDesc:descArray isDistinctResults:YES];
    
    NSArray *allFeedsArray =  [DBManager entitiesByArrayDesc:@"FeedView" pred:[NSString stringWithFormat:@"toBeDisplayed = YES"] arrayOfDesc:descArray isDistinctResults:YES];

    return allFeedsArray;
}


@end
