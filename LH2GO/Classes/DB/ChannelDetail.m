//
//  ChannelDetail.m
//  LH2GO
//
//  Created by Linchpin on 8/2/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "ChannelDetail.h"
#import "CoreDataManager.h"
#import "TimeConverter.h"

@implementation ChannelDetail

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


- (void)getImageForChannelContent {
    if (!self.mediaPath.length) return;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:self.mediaPath] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // progression tracking code
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            // do something with image
        }
    }];
}
//shradha
+ (ChannelDetail *)channelContentWithId:(NSString *)cId shouldInsert:(BOOL)insert
{
   
    ChannelDetail *channeld = [DBManager entity:@"ChannelDetail" idName:@"contentId" idValue:[NSString stringWithFormat:@"\'%@\'", cId]];
    if (!insert) return channeld;
    
    if (!channeld) {
        channeld = [CoreDataManager insertObjectFor:@"ChannelDetail"];
        channeld.contentId = cId;
        [CoreDataManager saveContext];
    }
    return channeld;
}



+ (ChannelDetail *)addChannelContentWithDict:(NSDictionary *)dict tempId:(NSInteger)tempId
{
    
    if (!dict) return nil;
    
    NSString *cId = [AppManager sutableStrWithStr:[dict objectForKey:@"content_id"]];
    if (cId == nil) {
        return nil;
    }
    ChannelDetail *channeld = [ChannelDetail channelContentWithId:cId shouldInsert:YES];
   
    NSString *channelId = [dict objectForKey:@"channelId"];

    NSArray *arr = [DBManager entitiesToSaveChannelData:@"ChannelDetail" pred:[NSString stringWithFormat:@"contentId = \"%@\" AND channelId = \"%@\"", cId,channelId] descr:nil isDistinctResults:YES];
    
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
        
        
        if (([channeldXYZ.contactCount isEqualToNumber:[NSNumber numberWithInt:[[dict objectForKey:@"contactCount"] intValue]]] &&  [channeldXYZ.coolCount isEqualToNumber:[NSNumber numberWithInt:[[dict objectForKey:@"coolCount"] intValue]]] &&  channeldXYZ.cool ==[[dict objectForKey:@"cool"] boolValue] && channeldXYZ.contact == [[dict objectForKey:@"contact"] boolValue])  &&  channeldXYZ.share ==[[dict objectForKey:@"share"] boolValue] && [channeldXYZ.shareCount isEqualToNumber:[NSNumber numberWithInt:[[dict objectForKey:@"shareCount"] intValue]]] && [channeldXYZ.created_time isEqualToNumber:[NSNumber numberWithInteger:[[dict objectForKey:@"created_time"] integerValue]]])
        {
            NSLog(@"Manoj Return coz of no change");

            return [arr objectAtIndex:0];
        }
        else
        {
            channeldXYZ.created_time = [NSNumber numberWithInteger:[[dict objectForKey:@"created_time"] integerValue]];
            [DBManager save];
        }
        NSLog(@"Manoj Return coz of change");
        return [arr objectAtIndex:0];
    }
    
    channeld.mediaPath = [dict objectForKey:@"mediaPath"];
    if(channeld.mediaPath == nil){
        channeld.mediaPath = @"";
    }
    channeld.text = [dict objectForKey:@"text"];
    channeld.mediaType = [dict objectForKey:@"mediaType"];
    channeld.channelId = [dict objectForKey:@"channelId"];
    channeld.toBeDisplayed = YES;
    NSString *appDisplayTime = [dict objectForKey:@"duration"];
    channeld.duration = [NSNumber numberWithInteger:[appDisplayTime longLongValue]];
    channeld.tempId = [NSNumber numberWithInteger:tempId];
    channeld.timeStr = @"";
    channeld.received_timeStamp = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    if([[dict objectForKey:@"cool"]boolValue])
            channeld.cool = YES;
        else
            channeld.cool = NO;
    if([[dict objectForKey:@"share"]boolValue])
        channeld.share = YES;
    else
        channeld.share = NO;

    if([[dict objectForKey:@"contact"]boolValue])
        channeld.contact = YES;
    else
        channeld.contact = NO;
    
    channeld.isForChannel = [[dict objectForKey:@"isForChannel"] boolValue];

    channeld.coolCount = [NSNumber numberWithInteger:[[dict objectForKey:@"coolCount"] integerValue]];
    channeld.shareCount = [NSNumber numberWithInteger:[[dict objectForKey:@"shareCount"]integerValue]];
    channeld.contactCount = [NSNumber numberWithInteger:[[dict objectForKey:@"contactCount"] integerValue]];
    channeld.created_time = [NSNumber numberWithInteger:[[dict objectForKey:@"created_time"] integerValue]];
    
    channeld.isForeverFeed = [NSNumber numberWithInteger:[[dict objectForKey:@"isForeverFeed"] integerValue]];
    channeld.feed_Type       = [[dict objectForKey:@"feed_Type"] boolValue];
    
    return channeld;
}


+ (ChannelDetail *)addChannelContentWithDictForDefaultChannel:(NSDictionary *)dict tempId:(NSInteger)tempId
{
    NSString *cId = [AppManager sutableStrWithStr:[dict objectForKey:@"content_id"]];
    if (cId == nil) {
        return nil;
    }
    ChannelDetail *channeldTemp = [ChannelDetail channelContentWithId:cId shouldInsert:YES];
    NSString *channelId = [dict objectForKey:@"channelId"];
    
    if([channeldTemp.channelId isEqualToString:channelId]){
        return channeldTemp;
    }
   
    else{
        
//    NSArray *arr = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"contentId = \"%@\" AND channelId = \"%@\"", cId,channelId] descr:nil isDistinctResults:YES];
//  
//    if(arr.count==1){
//        return [arr objectAtIndex:0];
//    }
//    else{
    ChannelDetail *channeld = [CoreDataManager insertObjectFor:@"ChannelDetail"];
    
    channeld.mediaPath = [dict objectForKey:@"mediaPath"];
    if(channeld.mediaPath == nil){
        channeld.mediaPath = @"";
    }
    channeld.text = [dict objectForKey:@"text"];
    channeld.mediaType = [dict objectForKey:@"mediaType"];
    channeld.channelId = [dict objectForKey:@"channelId"];
    channeld.toBeDisplayed = YES;
    NSString *appDisplayTime = [dict objectForKey:@"duration"];
    channeld.duration = [NSNumber numberWithInteger:[appDisplayTime longLongValue]];
    channeld.tempId = [NSNumber numberWithInteger:tempId];
    channeld.timeStr = @"";
    channeld.contentId = cId;
    channeld.received_timeStamp = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    if([[dict objectForKey:@"cool"]boolValue])
            channeld.cool = YES;
    else
            channeld.cool = NO;
    if([[dict objectForKey:@"share"]boolValue])
            channeld.share = YES;
    else
        channeld.share = NO;
    if([[dict objectForKey:@"contact"]boolValue])
            channeld.contact = YES;
    else
        channeld.contact = NO;
        
    channeld.isForChannel = [[dict objectForKey:@"isForChannel"] boolValue];
        
    channeld.coolCount = [NSNumber numberWithInteger:[[dict objectForKey:@"coolCount"] integerValue]];
    channeld.shareCount = [NSNumber numberWithInteger:[[dict objectForKey:@"shareCount"]integerValue]];
    channeld.contactCount = [NSNumber numberWithInteger:[[dict objectForKey:@"contactCount"] integerValue]];
    channeld.created_time = [NSNumber numberWithInteger:[[dict objectForKey:@"created_time"] integerValue]];
    channeld.isForeverFeed = [NSNumber numberWithInteger:[[dict objectForKey:@"isForeverFeed"] integerValue]];
    channeld.feed_Type       = [[dict objectForKey:@"feed_Type"] boolValue];

    return channeld;
  }
}

@end
