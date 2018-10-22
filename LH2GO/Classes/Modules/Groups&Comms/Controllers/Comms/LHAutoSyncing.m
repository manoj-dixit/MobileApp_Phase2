//
//  LHAutoSyncing.m
//  LH2GO
//
//  Created by Kiwitech on 19/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHAutoSyncing.h"
#import "AFAppDotNetAPIClient.h"
#import "DBManager.h"
#import "Reachability.h"
#import "LHAutoSyncing.h"
#import "InternetCheck.h"
#import "BaseViewController.h"
#import "BackUpManager.h"
#import "LoaderView.h"
typedef void (^AutosyncingCallBack)(BOOL success, NSError *error);


@interface LHAutoSyncing()
{
    NSMutableArray *_medaiShouts;
    NSMutableArray *arrayBackUps;
    NSMutableArray *arrayFavShouts;
    Reachability *internetReachable;
}

@property (nonatomic, copy)AutosyncingCallBack autoSyncCallback;

@end

@implementation LHAutoSyncing

+ (instancetype)shared
{
    static LHAutoSyncing *_autoGlobal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _autoGlobal = [[LHAutoSyncing alloc] init];
        [_autoGlobal addReachabilityChangedNotification];
    });
    return _autoGlobal;
}

- (void)addReachabilityChangedNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    [self checkNetworkStatus:nil];
}

-(void)checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            //Internet Off
            [InternetCheck sharedInstance].internetWorking = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            //Internet On
            [InternetCheck sharedInstance].internetWorking = YES;
            if (isLoggedIn && !self.isAutoSyncingInProgress) {
                [self autoSyncingShoutsWithcallback:^(BOOL success, NSError *error) {
                    self.isAutoSyncingInProgress=NO;
                    [LoaderView removeLoader];
                }];
            }
            break;
        }
        case ReachableViaWWAN:
        {
            //Internet On
            [InternetCheck sharedInstance].internetWorking = YES;
            if (isLoggedIn&&!self.isAutoSyncingInProgress) {
                [self autoSyncingShoutsWithcallback:^(BOOL success, NSError *error) {
                    self.isAutoSyncingInProgress=NO;
                    [LoaderView removeLoader];
                }];
            }
            break;
        }
    }
}

-(NSArray*)unsyncedTextTypeShouts
{
         NSArray *list = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
         NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.type = %d AND SELF.synced != 2", ShoutTypeTextMsg];
         list = [list filteredArrayUsingPredicate:bPredicate];
         return list;
}

-(NSArray*)unsyncMediaTypeShouts
{
    NSArray *list = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"(SELF.type = %d OR SELF.type = %d OR SELF.type = %d OR SELF.type = %d) AND (SELF.synced != 2)", ShoutTypeImage,ShoutTypeAudio,ShoutTypeVideo, ShoutTypeGif];
    list = [list filteredArrayUsingPredicate:bPredicate];
    return list;
}

-(void)autoSyncingShoutsWithcallback:(void (^)(BOOL success, NSError *error)) block
{
    self.autoSyncCallback = block;
    if (self.isAutoSyncingInProgress)
    {
        NSLog(@"isAutoSyncingInProgress");
    }
    else
    {
        self.isAutoSyncingInProgress = YES;
        NSArray *arrayText = [self unsyncedTextTypeShouts];
        NSArray *arrMedia = [self unsyncMediaTypeShouts];
        _medaiShouts = [NSMutableArray arrayWithArray:arrMedia];
        if(arrayText.count>0)
        {
            [LHAutoSyncing addShoutsOnServer:arrayText callback:^(BOOL success, NSError *error) {
                [self autoSyncingMediaShouts];
            }];
        }
        else
        {
            [self autoSyncingMediaShouts];
        }
    }
}

-(void)autoSyncingMediaShouts
{
    if (_medaiShouts.count>0)
    {
        Shout *sht = [_medaiShouts objectAtIndex:0];
        [LHAutoSyncing addMediaShoutOnServer:sht callback:^(BOOL success, NSError *error) {
            if (_medaiShouts.count>0)
                [_medaiShouts removeObjectAtIndex:0];
            [self autoSyncingMediaShouts];
        }];
    }
    else
    {
        [self startSyncingShoutBackUp];
    }
}

//Adding TextType Shout On Server
+ (void)addShoutsOnServer:(NSArray*)shtArr callback:(void (^)(BOOL success, NSError *error)) block
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *parDict = [[NSMutableDictionary alloc] init];
    unsigned long i=0;
    for(Shout *sht in shtArr)
    {
        NSDictionary *dict = [Shout getParamsFrom:sht];
        [parDict setObject:dict forKey:[NSString stringWithFormat:@"%lu", i++]];
    }
    [param setObject:parDict forKey:@"addshouts"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    [client.requestSerializer setTimeoutInterval:k_timeOut];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client POST:AddShoutsOnAServer parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            for(Shout *sht in shtArr)
            {
                sht.synced=[NSNumber numberWithInt:2];
            }
            [DBManager save];
        }
        block(status,nil);
    }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        for(Shout *sht in shtArr)
        {
            sht.synced=[NSNumber numberWithInt:0];
        }
        [DBManager save];
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:NO];
        block(NO, nil);
    }];
}

+ (void)addMediaShoutOnServer:(Shout*)sht callback:(void (^)(BOOL success, NSError *error)) block
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *parDict = [[NSMutableDictionary alloc] init];
    NSDictionary *dict = [Shout getParamsFrom:sht];
    [parDict setObject:dict forKey:@"0"];
    [param setObject:parDict forKey:@"addshouts"];
    NSString *token = [PrefManager token];
    sht.synced = [NSNumber numberWithInt:1];
    
    /*api start*/
    AFHTTPRequestSerializer *aFHTTPRequestSerializer = [AFHTTPRequestSerializer serializer];
    [aFHTTPRequestSerializer setValue:token forHTTPHeaderField:kTokenKey];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", AFAppDotNetAPIBaseURLString,AddShoutsOnAServer];
    NSMutableURLRequest *request = [aFHTTPRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (sht.type.integerValue == ShoutTypeImage)
        {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:URLForShoutContent(sht.shId, @"png")];
            NSData *data = UIImageJPEGRepresentation(image, .5);
            if (data)
            {
                [formData appendPartWithFileData:data name:@"shout" fileName:@"myimage.jpg" mimeType:@"image/jpeg"];
            }
        }
        else if(sht.type.integerValue==ShoutTypeVideo)
        {
            NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
            if (path != nil)
            {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
                if (data)
                {
                    [formData appendPartWithFileData:data name:@"shout" fileName:@"video.mov" mimeType:@"video/quicktime"];
                }
            }
        }
        else if(sht.type.integerValue == ShoutTypeAudio)
        {
            NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
            if (path != nil)
            {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
                if (data)
                {
                  //  NSLog(@"addMediaShoutOnServer data %@", data);
                    [formData appendPartWithFileData:data name:@"shout" fileName:@"audio.m4a" mimeType:@"audio/x-m4a"];
                }
            }
        }
        else if(sht.type.integerValue == ShoutTypeGif)
        {
            NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
            if (path != nil)
            {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
                if (data)
                {
                    [formData appendPartWithFileData:data name:@"shout" fileName:@"animated.gif" mimeType:@"image/gif"];
                }
            }
        }
    } error:nil];
    [request setTimeoutInterval:k_timeOut];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
        {
            if (sht)
            {// if check to save crash from logout
                sht.synced=[NSNumber numberWithInt:0];
                [DBManager save];
            }
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            NSInteger responseStatusCode = [httpResponse statusCode];
            [AppManager handleError:error withOpCode:responseStatusCode showMessageStatus:NO];
            block(NO,nil);
        }
        else
        {
            NSDictionary *response = responseObject;
            BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
            if(status)
            {
                sht.synced=[NSNumber numberWithInt:2];
                [DBManager save];
            }
            block(status,nil);
        }
    }];
    [uploadTask resume];
    /*api end*/
}

-(void)startSyncingShoutBackUp
{
    arrayBackUps = [[DBManager getUnSyncedBackUps] mutableCopy];
    if(arrayBackUps.count>0)
        [self autoSyncingShoutBackUp];
    else
    {
        if (self.autoSyncCallback)
        {
            self.autoSyncCallback(YES, nil);
            self.autoSyncCallback=nil;
        }
    }
}

- (void)autoSyncingShoutBackUp
{
    if(arrayBackUps.count>0)
    {
        ShoutBackup *shoutBackup = [arrayBackUps objectAtIndex:0];
        if (shoutBackup.backupShouts.allObjects.count>0)
        {
            BOOL isAdding = YES;
            if (shoutBackup.edited.boolValue==YES)
            {
                isAdding = NO;
            }
            [BackUpManager ShoutsBackup:shoutBackup.backupShouts.allObjects backup:shoutBackup onView:nil isAdding:isAdding andAutobackup:YES completion:^(BOOL status) {
                if (arrayBackUps.count>0)
                    [arrayBackUps removeObjectAtIndex:0];
                [self autoSyncingShoutBackUp];
            }];
        }
        else
        {
            if (arrayBackUps.count)
                [arrayBackUps removeObjectAtIndex:0];
            [self autoSyncingShoutBackUp];
        }
    }
    else
    {
        [self startFavShoutSync];
    }
}

-(void)startFavShoutSync
{
    arrayFavShouts = [[DBManager getUnSyncedFavShouts] mutableCopy];
    [self autoSyncFavShout];
    //    [self autoSyncingShoutBackUp];
}

- (void)autoSyncFavShout
{
    if(arrayFavShouts.count>0)
    {
        Shout *sht = [arrayFavShouts objectAtIndex:0];
        [self favouriteCall:sht withFavFlag:[sht.favorite boolValue] callback:^(BOOL success, NSError *error) {
            if(arrayFavShouts.count)
                [arrayFavShouts removeObject:sht];
            [self autoSyncFavShout];
        }];
    }
    else{
        if (self.autoSyncCallback) {
            self.autoSyncCallback(YES, nil);
            self.autoSyncCallback=nil;
        }
    }
}

- (void)favouriteCall:(Shout*)sht withFavFlag:(BOOL)isFav callback:(void (^)(BOOL success, NSError *error)) block
{
    if ([Global shared].currentUser.user_id==nil)
    {
         block(NO, nil);
        return;
    }
    // add loader..
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *parDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:sht.shId forKey:@"shout_id"];
    if (isFav)
        [dict setObject:@"true"forKey:@"favorite"];
    else
        [dict setObject:@"false" forKey:@"favorite"];
    if([Global shared].currentUser.user_id)
        [dict setObject : [Global shared].currentUser.user_id  forKey : @"bookmark_by"];
    [parDict setObject:dict forKey:@"0"];
    [param setObject:parDict forKey:@"shouts_to_favorites"];
    
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    
    [client POST:ShoutsFavourites parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            [sht setFavorite:[NSNumber numberWithInt:2]];
            [DBManager save];
        }
        block(YES, nil);
    }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:NO];
        block(NO, error);
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end


