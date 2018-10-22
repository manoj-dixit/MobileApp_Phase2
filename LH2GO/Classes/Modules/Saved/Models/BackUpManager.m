//
//  BackUpManager.m
//  LH2GO
//
//  Created by Alok Deepti on 26/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "BackUpManager.h"
#import "LoaderView.h"
#import "TimeConverter.h"
#import "AFAppDotNetAPIClient.h"
#import "FavoriteDownloadManager.h"
#import <AFURLSessionManager.h>
@implementation BackUpManager


+(void)updateShoutForNoMoreBackUp:(NSArray *)shtArr
{
    for (Shout *sht in shtArr)
    {
        @autoreleasepool
        {
            [sht setIsBackup:[NSNumber numberWithBool:NO]];
            [DBManager save];
        }
    }
}

+ (void)ShoutsBackup:(NSArray*)shtArr backup:(ShoutBackup*)shout_bk onView:(UIView*)view isAdding:(BOOL)isAdding andAutobackup:(BOOL)autoBackup completion:(void (^)(BOOL status))completion
{
    [self updateShoutForNoMoreBackUp:shtArr];//must update shout for no more back up, at this stage it right place to mark shout no more back up, it helps in fix shout mix issue.
    NSMutableDictionary *shtParam = [[NSMutableDictionary alloc] init];
    NSString *addEditPath = ShoutsBackup;
    if (isAdding==NO)//must change
    {
        addEditPath = editBackup;
        [shtParam setObject:shout_bk.backupId forKey:@"bkup_id"];
        if (shout_bk.backupName!=nil)
        {
            [shtParam setObject:shout_bk.backupName forKey:@"bk_name"];
        }
        if (shout_bk.backupNote!=nil)
        {
            [shtParam setObject:shout_bk.backupNote forKey:@"bk_note"];
        }
    }
    else
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(Shout *sht in shtArr)
        {
            @autoreleasepool
            {
                NSString *newOutput = [NSString stringWithFormat:@"%@", sht.shId]; //[NSString stringWithFormat:@"\"%@\"", sht.shId];
                DLog(@"newwwwop %@",newOutput);
                [arr addObject:newOutput];
            }
        }
        [shtParam setObject:arr forKey:@"shout_id"];
        if (shout_bk.backupName!=nil)
        {
            [shtParam setObject:shout_bk.backupName forKey:@"bk_name"];
        }
        if (shout_bk.backupNote!=nil)
        {
            [shtParam setObject:shout_bk.backupNote forKey:@"bk_note"];
        }
        else if (shout_bk.backupNote==nil)
        {
            [shtParam setObject:@"" forKey:@"bk_note"];
        }
        [shtParam setObject:[Global shared].currentUser.user_id forKey:@"backup_by"];
        int timeStamp = (int)[TimeConverter timeStamp];
        [shtParam setObject:[NSString stringWithFormat:@"%d", timeStamp] forKey:@"backup_date"];
        
        [App_delegate.cachedBackUpDetails addObject:shtParam];
        DLog(@"Data is %@",App_delegate.cachedBackUpDetails);
        
        if ([AppManager isInternetShouldAlert:NO] == NO)
        {
            completion(NO);
            return;
        }
    }
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client POST:addEditPath parameters:shtParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"shtparam%@",shtParam);
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            if (App_delegate.cachedBackUpDetails.count>0) {
                [App_delegate.cachedBackUpDetails removeObject:shtParam];
                DLog(@"Data is %@",App_delegate.cachedBackUpDetails);
            }
            DLog(@"Response is %@",response);
            //update shoutBackUp ID
            shout_bk.synced = [NSNumber numberWithBool:YES];
            if (isAdding)
            {
                NSInteger bkId = [[response valueForKey:@"backup_id"] integerValue];
                shout_bk.backupId = [NSString stringWithFormat:@"%ld", (long)bkId];
                NSArray *arrayUnsyncedShout = [response objectForKey:@"Shouts"];
                if (arrayUnsyncedShout.count==0)
                {
                    [Shout updateShoutForAlreadyBackupAndSynced:shtArr];
                }
                else
                {
                    [self updateShoutNeedBackUpAndNeedSync:arrayUnsyncedShout originalArray:shtArr];
                }
            }
            [DBManager save];
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            if (!autoBackup)
            [AppManager showAlertWithTitle:nil Body:str];
        }
        else if (status == NO)
        {
           // NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            if (!autoBackup)
            [AppManager showAlertWithTitle:nil Body:@"Something went wrong, please try again later"];
        }
        completion(status);
    }
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!autoBackup)
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:NO];
        completion(NO);
    }];

}

+ (void)ShoutsBackupFromServerOnView:(UIView*)view completion:(void (^)(BOOL finished))completion
{
    if ([PrefManager isAlreadyDownloadedServerData])
    {
        completion(YES);
        return;
    }
    NSMutableDictionary *shtParam = [[NSMutableDictionary alloc] init];
    [shtParam setObject:[Global shared].currentUser.user_id forKey:@"user_id"];
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client POST:shoudBackUpDownloadPath parameters:shtParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            [PrefManager setAlreadyDownloadedServerData:YES];
            [self parseResponseForBackUps:response];
        }
            completion(YES);
    }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:NO];
            completion(YES);
    }];
}

//download shout associated with shout back up
+ (void)ShoutsDataBackupwithBackUpId:(NSInteger )backup_id shoutBackUp:(ShoutBackup *)shoutBackup FromServerOnView:(UIView *)view completion:(void (^)(BOOL))completion
{
    // add loader..
    //    [LoaderView addLoaderToView:view];
    NSMutableDictionary *shtParam = [[NSMutableDictionary alloc] init];
    [shtParam setObject:[NSNumber numberWithInteger:backup_id] forKey:@"backup_id"];
    NSString *token = [PrefManager token];
    [[Global shared] setIsServerDownloadInProgress:YES];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",AFAppDotNetAPIBaseURLString, shoudBackUpDataDownloadPath]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setValue:token forHTTPHeaderField:kTokenKey];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:shtParam options:NSJSONWritingPrettyPrinted  error:&error]; // Pass 0 if you don't care about the readability of the generated string
    NSString *jasonReq;
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }
    else
    {
        jasonReq = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *req = [NSString stringWithFormat:@"%@=%ld", @"backup_id",(long)backup_id];
    [request setHTTPBody:[req dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:k_timeOut];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
        {
            NSLog(@"Error: %@", error);
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            [AppManager handleError:error withOpCode:httpResponse.statusCode showMessageStatus:NO];
            //        [LoaderView removeLoader];
            completion(YES);
            [[Global shared] setIsServerDownloadInProgress:NO];
        }
        else
        {
            NSDictionary *response = responseObject;
            DLog(@"Response of API shout backup %@", response);
            BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
            if(status)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self parseResponseForBackUpData:response shoutBackUp:shoutBackup completion:^(BOOL finished) {
                        shoutBackup.downloaded = [NSNumber numberWithBool:YES];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [DBManager save];
                            //            [LoaderView removeLoader];
                            completion(YES);
                            [[Global shared] setIsServerDownloadInProgress:NO];
                        });
                    }];
                });
            }
            else
            {
                //            [LoaderView removeLoader];
                completion(YES);
                [[Global shared] setIsServerDownloadInProgress:NO];
            }
        }
    }];
    [dataTask resume];
}


+ (void)parseResponseForBackUpData:(NSDictionary *)resp shoutBackUp:(ShoutBackup *)shoutBackup completion:(void (^)(BOOL finished))completion
{
    NSArray *list = [resp objectForKey:@"Shouts"];
    NSMutableArray *arraySht = [NSMutableArray array];
    __block NSInteger count=0;
    for (NSDictionary *dict in list)
    {
        @autoreleasepool
        {
            Shout *sht = [Shout inserServerShoutInDbWithDict:dict completion:^(BOOL finished) {
            count++;
            if (count==[list count])
            {
                    completion(YES);
            }
            }];
            [arraySht addObject:sht];
        }
    }
    @try
    {
        if(shoutBackup != nil)
        {
            [shoutBackup addBackupShouts:[NSSet setWithArray:arraySht]];
            [DBManager save];
        }
        else
        {
            NSLog(@"Shout backup is nil");
        }
    } @catch (NSException *exception)
    {
        NSLog(@"Exception %@",exception.description);
    } @finally {}
}

+ (void)parseResponseForBackUps:(NSDictionary *)resp
{
    NSArray *list = [resp objectForKey:@"ShoutsBackup"];
    for (NSDictionary *dict in list)
    {
        @autoreleasepool
        {
            [ShoutBackup addShoutBackupWithDict:dict];
        }
    }
}

+(void)updateShoutNeedBackUpAndNeedSync:(NSArray *)arrayServerResponse originalArray:(NSArray *)originalArray
{
    [Shout updateShoutNeedBackUpAndNeedSync:arrayServerResponse originalArray:originalArray];
}

+ (void)createAutoBackUp
{
    if ([PrefManager userId].length == 0)
        return;
    if ([PrefManager shouldOpenSaved] == NO)
        return;
    if ([PrefManager isBackUpAlreadyInProcess])
    {
        NSArray *arrBackUp;
        arrBackUp = [DBManager getAllShoutsForBackup:YES];
        if (arrBackUp.count>0)
        {
            NSInteger bkId = [[NSDate date] timeIntervalSinceReferenceDate];
            ShoutBackup *bck = [ShoutBackup ShoutBackupWithId:[NSString stringWithFormat:@"%ld", (long)bkId] shouldInsert:YES];
            NSSet *set;
//            NSString *addEditPath;
            set = [NSSet setWithArray:arrBackUp];
//            addEditPath = ShoutsBackup;
            bck.backUpDate = [NSDate date];
            [bck addBackupShouts:set];
            bck.backupName = [self getDefaultBackUpName];
            for (Shout *sht  in arrBackUp)
            {
                [sht setIsBackup:[NSNumber numberWithBool:NO]];
            }
            [DBManager save];
        }
        [PrefManager setBackUpStarted:NO];
    }
}

+(NSString *)getDefaultBackUpName
{
    NSDate *currentDateTime = [NSDate date];
    NSString *backUpName = @"";
    NSString *txtSesionName=@"2GO Back-Up_";
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MM/dd/YYYY-hh:mm a"];
    NSString *txtSesionDate = [dateformatter stringFromDate:currentDateTime];
    backUpName = [txtSesionName stringByAppendingString:txtSesionDate];
    return backUpName;
}

- (UIImage*)getImageFromContentURL:(NSString*)url
{
    NSString *imagePath = [NSString stringWithFormat:@"Image%@.png", [[url componentsSeparatedByString:@"."] firstObject]];
    UIImage *image = [[SDImageCache sharedImageCache] diskImageForKey:imagePath];
    if (!image)
    {
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:url];
        if (path != nil)
        {
            image = [AppManager getPreViewImg:[NSURL fileURLWithPath:path]];
            [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"Image%@.png", [[url componentsSeparatedByString:@"."] firstObject]]];
        }
    }
    return image;
}

@end
