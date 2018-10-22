//
//  FavoriteDownloadManager.m
//  LH2GO
//
//  Created by kiwi on 03/07/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "FavoriteDownloadManager.h"
#import "LoaderView.h"
#import "AFAppDotNetAPIClient.h"
#import "Shout.h"

@implementation FavoriteDownloadManager

+(void)downloadFavFromServerOnView:(UIView *)view completion:(void (^)(BOOL))completion
{
    if ([PrefManager isAlreadyDownloadedServerDataFav])
    {
        completion(YES);
        return;
    }
    // add loader..
    [LoaderView addLoaderToView:view];
    NSMutableDictionary *shtParam = [[NSMutableDictionary alloc] init];
    [shtParam setObject:[Global shared].currentUser.user_id forKey:@"user_id"];
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [[Global shared] setIsServerDownloadInProgress:YES];
    [client POST:favShoutDownloadPath parameters:shtParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
    [LoaderView removeLoader];
    if(response != NULL)
    {
    BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
    if(status)
    {
        [PrefManager setAlreadyDownloadedServerDataFav:YES];
        [FavoriteDownloadManager parseResponseOfFavShout:response completion:^(BOOL finished) {
        [LoaderView removeLoader];
        completion(YES);
        [[Global shared] setIsServerDownloadInProgress:NO];
        }];
    }
    else
    {
        [LoaderView removeLoader];
        completion(YES);
    }
    }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
            [LoaderView removeLoader];
            completion(YES);
            [[Global shared] setIsServerDownloadInProgress:NO];
    }];
}

+ (void)parseResponseOfFavShout:(NSDictionary *)resp completion:(void (^)(BOOL finished))completion
{
    NSArray *list = [resp objectForKey:@"Shouts"];
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
            sht.favorite = [NSNumber numberWithBool:YES];
        }
    }
    [DBManager save];
}

@end
