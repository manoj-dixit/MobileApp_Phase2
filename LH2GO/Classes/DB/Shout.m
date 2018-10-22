//
//  Shout.m
//  LH2GO
//
//  Created by Sumit Kumar on 24/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "Shout.h"
#import "Group.h"
#import "Shout.h"
#import "ShoutBackup.h"
#import "User.h"
#import "CoreDataManager.h"
#import "TimeConverter.h"
#import "LocationManager.h"
#import "ShoutManager.h"
#import "ShoutCell.h"
#import "ImagePickManager.h"
#import "NSData+Base64.h"
#import "CryptLib.h"

@implementation Shout

@dynamic contentUrl;
@dynamic favorite;
@dynamic groupId;
@dynamic isBackup;
@dynamic life;
@dynamic location;
@dynamic original_timestamp;
@dynamic shId;
@dynamic synced;
@dynamic text;
@dynamic timestamp;
@dynamic type;
@dynamic isShoutRecieved;
@dynamic pShId;
@dynamic chield_shouts;
@dynamic group;
@dynamic owner;
@dynamic parent_shout;
@dynamic reciever;
@dynamic backup;
@dynamic cmsTime;
@dynamic isFromCMS;
@synthesize reportedShout;

+ (BOOL)isExistShoutId:(NSString *)sId
{
    Shout *sht = [DBManager entity:@"Shout" idName:@"shId" idValue:[NSString stringWithFormat:@"\'%@\'", sId]];
    return (sht != nil);
}

static id extracted() {
    return [CoreDataManager insertObjectFor:@"Shout"];
}

+ (Shout *)shoutWithId:(NSString *)sId shouldInsert:(BOOL)insert
{
    DLog(@"sid is %@",sId);
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"]invertedSet];
    
    if ([sId rangeOfCharacterFromSet:set].location != NSNotFound) {
        
        
        NSArray *totalShouts = [DBManager entities:@"Shout" pred:nil descr:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES] isDistinctResults:NO];
        
        
        DLog(@"shouts is %@",totalShouts);
        Shout *newSht;
        if(totalShouts.count>1)
            newSht = totalShouts[totalShouts.count - 1];
        
        if (!insert) return newSht;
        if (!newSht && sId != NULL)
        {
            newSht = extracted();
            newSht.shId = sId;
        }
        
        return newSht;
        
    }
    
    else{
        Shout *sht = [DBManager entity:@"Shout" idName:@"shId" idValue:[NSString stringWithFormat:@"\'%@\'", sId]];
        if (!insert) return sht;
        if (!sht && sId != NULL)
        {
            sht = [CoreDataManager insertObjectFor:@"Shout"];
            sht.shId = sId;
        }
        return sht;
    }
    
}

+ (Shout *)insertShoutInfo:(ShoutInfo *)sh isSender:(BOOL)Sender
{
    Shout *sht = [Shout shoutWithId:sh.header.shoutId shouldInsert:YES];
    sht.original_timestamp = [NSNumber numberWithInteger:sh.shout.timestamp];
    sht.timestamp = [NSNumber numberWithInteger: [TimeConverter timeStamp]]; // time stamp at recieving end.
    NSString *str = [NSString stringWithFormat:@"%f,%f", [LocationManager latitude], [LocationManager longitude]];
    sht.location = str;
    
    sht.type = @(sh.type);
    if (sh.type == ShoutTypeImage)
    {
        NSString *ext = @"png";
        sht.contentUrl = URLForShoutContent(sh.header.shoutId, ext);
        sht.isFromCMS = NO;
        UIImage *imgae = [UIImage imageWithData:sh.shout.content];
        [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithData:sh.shout.content] forKey:sht.contentUrl];
    }
    else if (sh.type == ShoutTypeAudio)
    {
        sht.contentUrl = URLForShoutAudioAndVideo(sh.header.shoutId, @"m4a");
        sht.isFromCMS = NO;
        [[SDImageCache sharedImageCache] storeMediaData:sh.shout.content forKey:sht.contentUrl];
    }
    else if (sh.type == ShoutTypeVideo)
    {
        sht.isFromCMS = NO;
        sht.contentUrl = URLForShoutAudioAndVideo(sh.header.shoutId, @"MOV");
        [[SDImageCache sharedImageCache] storeMediaData:sh.shout.content forKey:sht.contentUrl];
    }
    else if (sh.type == ShoutTypeGif)
    {
        sht.isFromCMS = NO;
        sht.contentUrl = URLForShoutAudioAndVideo(sh.header.shoutId, @"gif");
        [[SDImageCache sharedImageCache] storeMediaData:sh.shout.content forKey:sht.contentUrl];
    }
    sht.owner = [User userWithId:sh.header.ownerId shouldInsert:YES];
    
    if (!Sender) {
        
        sht.owner.user_name =  [[sh.shout.userName componentsSeparatedByString:@"$"] objectAtIndex:0];
    }
    
//    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"CMS"];
//    
//    if(value == 1 && [sh.header.cmsDuration intValue]>0)
//    {
    
    if (sh.header.isMsgFromCMS && [sh.header.cmsDuration intValue]>0) {
        
        sht.owner.user_name = @"CMS";
        sht.owner.email = @"support@loud-hailer.com";
        sht.isFromCMS = YES;
        sht.cmsTime =sh.header.cmsDuration;
        
        sht.cmsID = sh.header.cms_Id;
        NSString *newStr = [NSString stringWithFormat:@"-----%@ seconds",sht.cmsTime];
        sht.text = [sh.shout.text stringByAppendingString:newStr];
        
        NSNumber *newTimeStamp = [NSNumber numberWithInt:([sht.cmsTime intValue] + [sht.timestamp intValue])];
        sht.timestamp = newTimeStamp;
    }
    else if(sh.header.isMsgFromCMS  && [sh.header.cmsDuration intValue] == 0){
        sht.owner.user_name = @"CMS";
        sht.owner.email = @"support@loud-hailer.com";
        sht.isFromCMS = YES;
        sht.text = sh.shout.text;
        sht.cmsID = sh.header.cms_Id;
    }
    else{
        
        sht.text = sh.shout.text;
        
        sht.isFromCMS = NO;
        
    }
    @try {
        
        sht.group = [Group groupWithId:sh.header.groupId shouldInsert:YES isP2PContact:NO isPendingStatus:NO];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
   // NSString *groupId = [NSString stringWithFormat:@"%d", [sht.group.grId intValue]];
    NSString *groupId = sht.group.grId;

    sht.groupId = groupId;
    sht.pShId = nil;
    
    if (sh.shout.parent_shId.length>0)
    {
        sht.pShId = sh.shout.parent_shId;
        Shout *psht = [Shout shoutWithId:sh.shout.parent_shId shouldInsert:NO];
        if (psht) {
            [sht setParent_shout:psht];
            [psht addChield_shoutsObject:sht];
        }
    }
    return sht;
}

// release me all latest shout, their lifeline left.
+ (NSArray *)latestShoutsForGroup:(Group *)group
{
    // set condition (predicate).
    int currentTimeStamp = (int) [TimeConverter timeStamp]-k_TrackTime*5;
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"time_stamp > %d", currentTimeStamp];
    NSArray *list = [group.shouts.allObjects filteredArrayUsingPredicate:pr];
    return list;
}

- (void)trackMe:(Shout*)sh
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(trackMe:) object:nil];
    NSDate *currentDateTime = [NSDate date];
    
    
    if(sh.isFromCMS&&[sh.cmsTime intValue]>0){
        DLog(@"the shout id is %@",sh.shId);
        
        NSDate *shoutOriginalDate = [NSDate dateWithTimeIntervalSince1970:self.timestamp.integerValue - [sh.cmsTime intValue]];
        int secs = [currentDateTime timeIntervalSinceDate:shoutOriginalDate];
        
        
        if(secs < [sh.cmsTime intValue]){
            DLog(@"this shout should be fade");
            [self performSelector:@selector(trackMe:) withObject:sh afterDelay:[sh.cmsTime intValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShoutLifeLineUpdate object:self userInfo:nil];
        }
        
        else{
            [[ShoutManager sharedManager] dequeueShout:sh];
            Group *grp = sh.group;
            if([grp.totShoutsReceived intValue] > 0)
            grp.totShoutsReceived = [NSNumber numberWithInt:([grp.totShoutsReceived intValue] - 1)];
            else
            grp.totShoutsReceived = 0;
            [DBManager save];
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            if(state == UIApplicationStateBackground || state == UIApplicationStateActive) {
                
                NSInteger unreadShoutsCount = [DBManager getUnresdShoutsCount];
                NSInteger unreadContents = [DBManager getUnreadChannelContentCount];

                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount+unreadContents)];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOFIFICATION_IF_CANCELLED object:nil];

            }
        }
    }
    else{
        
        
        NSDate *shoutOriginalDate = [NSDate dateWithTimeIntervalSince1970:self.timestamp.integerValue];
        int secs = [currentDateTime timeIntervalSinceDate:shoutOriginalDate];
        
        if (secs < KCellFadeOutDuration)
        {
            DLog(@"this shout should be fade");
            [self performSelector:@selector(trackMe:) withObject:sh afterDelay:k_TrackTime];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShoutLifeLineUpdate object:self userInfo:nil];
        }
        else
        {
            [[ShoutManager sharedManager] dequeueShout:self];
            Group *grp = sh.group;
            if([grp.totShoutsReceived intValue] > 0)
                grp.totShoutsReceived = [NSNumber numberWithInt:([grp.totShoutsReceived intValue] - 1)];
            else
                grp.totShoutsReceived = 0;
            [DBManager save];
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            if(state == UIApplicationStateBackground || state == UIApplicationStateActive) {
                
                Global *shared = [Global shared];
                NSInteger unreadContents = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
                NSInteger unreadChanelCount = [DBManager getUnreadChannelContentCount];
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadChanelCount+unreadContents)];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOFIFICATION_IF_CANCELLED object:nil];

            }
        }
    }
}

- (void)updateChieldShouts
{
    for (int i=0; i<self.chield_shouts.allObjects.count; i++)
    {
        Shout *sht = [self.chield_shouts.allObjects objectAtIndex:i];
        sht.timestamp = self.timestamp;
    }
}

- (void )updateAllUnlinkChieldShouts
{
    NSArray *childlist = [DBManager entities:@"Shout" pred:[NSString stringWithFormat:@"pShId = \"%@\" AND parent_shout = nil", self.shId] descr:nil isDistinctResults:NO];
    for(Shout *sht in childlist)
    {
        [sht setParent_shout:self];
        [self addChield_shoutsObject:sht];
    }
}

+(void)updateShoutNeedBackUpAndNeedSync:(NSArray *)arrayServerResponse originalArray:(NSArray *)originalArray
{
    for (Shout *sht  in originalArray)
    {
        for (NSString * shtId in arrayServerResponse)
        {
            if ([shtId isEqualToString:sht.shId])
            {
                [sht setIsBackup:[NSNumber numberWithBool:NO]];
                [sht setSynced:[NSNumber numberWithBool:NO]];
            }
        }
    }
    [DBManager save];
}

+(void)updateShoutForAlreadyBackupAndSynced:(NSArray *)shtArr
{
    for (Shout *sht in shtArr)
    {
        @autoreleasepool
        {
            [sht setIsBackup:[NSNumber numberWithBool:NO]];
            [sht setSynced:[NSNumber numberWithBool:YES]];
        }
    }
    [DBManager save];
}

+ (NSDictionary*)getParamsFrom:(Shout*)sht
{
    NSMutableDictionary *shtParam = [[NSMutableDictionary alloc] init];
    
    if(sht.shId!=nil){
        [shtParam setObject:sht.shId forKey:@"shout_id"];
        
    }
    
    
    if (sht.groupId!=nil)
    {
        [shtParam setObject:sht.groupId forKey:@"group_id"];
    }
    if(sht.owner.user_id)
        [shtParam setObject:sht.owner.user_id forKey:@"owner_id"];
    if (sht.reciever!=nil&&sht.reciever.user_id!=nil)
    {
        [shtParam setObject:sht.reciever.user_id forKey:@"reciever_id"];
    }
    else if([Global shared].currentUser.user_id!=nil)
    {
        [shtParam setObject:[Global shared].currentUser.user_id forKey:@"reciever_id"];
    }
    NSArray *arr = [sht.location componentsSeparatedByString:@","];
    if (arr.count==2)
    {
        NSString *str = [arr objectAtIndex:0];
        [shtParam setObject:str forKey:@"latitude"];
        str = [arr objectAtIndex:1];
        [shtParam setObject:str forKey:@"longitude"];
    }
    NSString *shoutType =[AppManager getStrFromShoutType:sht.type];
    if(shoutType)
        [shtParam setObject:shoutType forKey:@"shout_type"];
    if (sht.text)
    {
        [shtParam setObject:sht.text forKey:@"shout_text"];
        [shtParam setObject:@"" forKey:@"shout"];
    }
    if([sht.type integerValue]!=ShoutTypeTextMsg&&sht.contentUrl!=nil)
        [shtParam setObject:sht.contentUrl forKey:@"shout"];
    if (sht.parent_shout!=nil&&sht.parent_shout.shId!=nil)
    {
        [shtParam setObject:sht.parent_shout.shId forKey:@"parent_id"];
    }
    if (sht.original_timestamp!=nil)
    {
        int timeStamp = (int)[TimeConverter timeStamp];
        [shtParam setObject:[NSString stringWithFormat:@"%d", timeStamp] forKey:@"created_datetime"];
    }
    return shtParam;
}

//reuse this method fror fav download and backup shout download
+(Shout *)inserServerShoutInDbWithDict:(NSDictionary *)dict completion:(void (^)(BOOL finished))completion
{
    @autoreleasepool
    {
        NSString * contentUrl = nil;
        NSNumber * favorite = [dict objectForKey:@"favorites"];
        NSNumber * isBackup = [NSNumber numberWithBool:NO];
        NSString *str = [NSString stringWithFormat:@"%f,%f", [[dict objectForKey:@"latitude"] floatValue], [[dict objectForKey:@"longitude"] floatValue]];
        NSString * location = str;
        NSString *timeFromServer = [dict objectForKey:@"created_datetime"];
        NSTimeInterval timestamp = timeFromServer.doubleValue ;
        NSNumber * original_timestamp = [NSNumber numberWithDouble:timestamp];
        NSString * shId = [dict objectForKey:@"shout_id"];
        NSNumber * synced = [NSNumber numberWithBool:YES];
        NSString * text = nil;
        NSString *shout_type = [dict objectForKey:@"shout_type"];
        NSNumber * type = [AppManager getShoutTypeFromString:shout_type];
        NSString *groupId = [dict objectForKey:@"group_id"];
        NSString *ownerId = [dict objectForKey:@"owner_id"];
        NSString *receiverId = [dict objectForKey:@"reciever_id"];
        text = [dict objectForKey:@"shout_text"];
        if (type.integerValue != ShoutTypeTextMsg)
        {
            contentUrl = [dict objectForKey:@"shout"];
        }
        Shout *sht = [Shout shoutWithId:shId shouldInsert:YES];
        sht.contentUrl = contentUrl;
        sht.favorite = favorite;
        sht.reportedShout = [NSNumber numberWithInteger:0];
        sht.isBackup = isBackup;
        sht.location = location;
        sht.timestamp = original_timestamp;
        sht.type = type;
        sht.synced = synced;
        if ([text isKindOfClass:[NSNull class]] || [text isEqualToString:@""] || text == nil) {
              }
        else{
            sht.text = text;

        }
        sht.groupId = groupId;
        sht.owner = [User userWithId:ownerId shouldInsert:YES];
        sht.reciever = [User userWithId:receiverId shouldInsert:YES];
        sht.isShoutRecieved = [NSNumber numberWithBool:YES];
        
        
        //media stuff
        if (sht.type.integerValue == ShoutTypeImage)
        {
            [[SDWebImageDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:sht.contentUrl] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize){
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                NSData *dataImage = data;
                NSString *type = [ImagePickManager contentTypeForImageData:dataImage];
                if ([type isEqualToString:@"image/gif"])
                {
                    sht.type = [NSNumber numberWithInteger:ShoutTypeGif];
                    sht.contentUrl = URLForShoutAudioAndVideo(sht.shId, @"gif");
                    [[SDImageCache sharedImageCache] storeMediaData:dataImage forKey:sht.contentUrl];
                }
                else
                {
                    NSString *ext = @"png";
                    sht.contentUrl = URLForShoutContent(sht.shId, ext);
                    DLog(@"%@", sht.contentUrl);
                    [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithData:dataImage] forKey:sht.contentUrl];
                    dataImage = nil;
                }
                completion(YES);
            }];
        } else if (sht.type.integerValue == ShoutTypeAudio) {
            [[SDWebImageDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:sht.contentUrl] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                NSData *dataAudio = data;
                sht.contentUrl = URLForShoutAudioAndVideo(sht.shId, @"m4a");
                [[SDImageCache sharedImageCache] storeMediaData:dataAudio forKey:sht.contentUrl];
                dataAudio = nil;
                completion(YES);
            }];
        } else if (sht.type.integerValue == ShoutTypeVideo) {
            [[SDWebImageDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:sht.contentUrl] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                NSData *dataVideo = data;
                sht.contentUrl = URLForShoutAudioAndVideo(sht.shId, @"MOV");
                [[SDImageCache sharedImageCache] storeMediaData:dataVideo forKey:sht.contentUrl];
                dataVideo = nil;
                completion(YES);
            }];
        }
        else{
            completion(YES);
        }
        [DBManager save];
        return sht;
    }
}
+(void)updateShoutForNoBackupPermissionAndSynced:(NSArray *)shtArr
{
    for (Shout *sht in shtArr) {
        @autoreleasepool {
            [sht setIsBackup:[NSNumber numberWithBool:NO]];
        }
    }
    [DBManager save];
}

- (void)removeGarbageShout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeGarbageShout) object:nil];
    if ([self.isShoutRecieved boolValue] == NO) {
        [[ShoutManager sharedManager] dequeueShout:self];
        [DBManager deleteOb:self];
    }
}

@end
