//
//  AppManager.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "AppManager.h"
#import "InternetCheck.h"
#import "AFAppDotNetAPIClient.h"
#import "BaseViewController.h"
#import "LoaderView.h"
#import "NotificationViewController.h"
#import "NotificationInfo.h"
#import <AVFoundation/AVFoundation.h>
#import "DBManager.h"
#import "Reachability.h"
#import "TimeConverter.h"
#import "LHAutoSyncing.h"
#import "Shout.h"
#import "BackUpManager.h"
#import "ImagePickManager.h"
#import "GroupsViewController.h"
#import "ShoutManager.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#import <REFrostedViewController.h> // by nim
#import "BLEManager.h"
#import "CoreDataManager.h"
#import "Channels.h"

UIAlertView *alert;
@implementation AppManager

/*! @method : Get appdel instance.  */
+ (AppDelegate *)appDelegate
{
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

/*! @method : Some stuff on ap launch.  */
+ (void)initialStuff
{
    [PrefManager setShouldOpenSaved:YES];
    [PrefManager setShouldOpenSonar:YES];
    isLoggedIn = [PrefManager login];
    if (isLoggedIn)
    {
        App_delegate.cloudDebugStatus = [[[NSUserDefaults standardUserDefaults] objectForKey:Debug_Mode] boolValue];
        [[Global shared] setCurrentUser:[User userWithId:[PrefManager userId] shouldInsert:YES]];
        [BackUpManager createAutoBackUp];
        [AppManager startTimerForDbClean];
        [DBManager cleanShouts];
        [self downloadSecurityKeys];
    }
    
    // start network check.
    if([AppManager isInternetShouldAlert:NO])
        DLog(@"network connected");
    [[ShoutManager sharedManager] clearAllGarbageShoutes];
}

+(void)startTimerForDbClean
{
    [NSTimer scheduledTimerWithTimeInterval:(k_DBCleanUpTime + 1)target:self selector:@selector(scheduleDBClean)userInfo:nil repeats:YES];
}

+(void)scheduleDBClean
{
    [DBManager cleanShouts];
}

+ (void) configureAVAudioSession
{
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    //set the audioSession category.
    //Needs to be Record or PlayAndRecord to use audioRouteOverride:
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success)  NSLog(@"AVAudioSession error setting category:%@",error);
    //set the audioSession override
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (!success)  NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success)
    {
        NSLog(@"AVAudioSession error activating: %@",error);
    }
    else NSLog(@"audioSession active");
}

+ (void)downloadUsers
{
    if (!isLoggedIn) return;
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    // make a param..
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser];
    [param setObject : user.user_id  forKey : @"user_id"];
    [client GET:UserListPath parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject ) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            [DBManager clearMyDataOnBackgroundRefresh];
            NSDictionary *data = [response objectForKey:@"userData"];
            // networks...
            NSArray *nets = [data objectForKey:@"Networks"];
            for (NSDictionary *nd in nets)
            {
                [Network addNetworkWithDict:nd];
                // groups...
                NSArray *groups = [nd objectForKey: @"Groups"];
                for (NSDictionary *gd in groups)
                {
                    Group *grp = [Group addGroupWithDict:gd forUsers:nil pic:nil pending:NO];
                    // users...
                    NSArray *users = [gd objectForKey: @"Users"];
                    for (NSDictionary *ud in users)
                    {
                        if ( [user.user_id isEqualToString:[ud objectForKey:@"id"]])
                        {
                            NSString *deleted = [ud objectForKey:@"deleted"];
                            NSNumber *isActive = [ud objectForKey:@"status"];
                            NSString *message;
                            if (isActive.integerValue == 0)
                            {
                                message = @"Your user has been deactivated. Please contact your admin or Loud-Hailer support team. For additional info please visit http://www.loud-hailer.com";
                            }
                            else if ([deleted isEqualToString:@"deleted"])
                            {
                                message = @"Your user has been removed. Please contact your admin or Loud-Hailer support team. For additional info please visit http://www.loud-hailer.com";
                            }
                            if (message.length > 0)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    DLog(@"dict is %@", ud);
                                    //session expired
                                    [AppManager showAlertWithTitle:nil Body:message];
                                    [PrefManager setLoggedIn:NO];
                                    [BaseViewController showLogin];
                                });
                                return;
                            }
                        }
                        User *usr = [User addUserWithDict:ud pic:nil];
                        // user - group
                        if(usr&&grp)
                        {
                            [grp addUsersObject:usr];
                            [usr addGroupsObject:grp];
                        }
                        // network - user
                        if (grp.network) [usr addNetworksObject:grp.network];
                        if (grp.network) [grp.network addUsersObject:usr];
                    }
                    //invited users
                    NSArray *invitedUsers = [gd objectForKey: @"InvitedUsers"];
                    for (NSDictionary *ud in invitedUsers)
                    {
                        User *usr = [User addUserWithDict:ud pic:nil];
                        // user - group
                        if(usr&&grp)
                        {
                            [grp addPendingUsersObject:usr];
                            [usr addPendingGroupsObject:grp];
                        }
                    }
                }
            }
            // set active networks
            NSString *nId = [[PrefManager activeNetId] copy];
            if (nId == nil)
            {
                Network *net = [[[[[Global shared] currentUser] networks] allObjects] firstObject];
                [PrefManager setActiveNetId:[net.netId copy]];
            }
            // [AppManager updateGroupUI];
        }
        else
        {
            //[AppManager updateGroupUI];
        }
    }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // [AppManager updateGroupUI];
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:NO];
    }];
}

+ (NSString *) md5HashFromString:(NSString *)source
{
    const char *cStr = [source UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(void)downloadSecurityKeys
{
    if (!isLoggedIn) return;
    // add token..
    NSString *token = [PrefManager token];
    NSLog(@"user id %@",[Global shared].currentUser.user_id);
    NSString *mdTokenString = [self md5HashFromString:[Global shared].currentUser.user_id];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,DOWNLOAD_SECURITY_KEYS];
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:mdTokenString,@"token",nil];
    NSData *myData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:myData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:token forHTTPHeaderField:@"token"];
    __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                              {
                                                  DLog(@"Response:%@ %@\n", response, error);
                                                  if(error == nil)
                                                  {
                                                      NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                      DLog(@"responseDict is --- %@",dict);
                                                      if(dict != NULL)
                                                      {
                                                          BOOL status = [[dict objectForKey:@"status"] boolValue];
                                                          NSString *msgStr= [dict objectForKey:@"status"];
                                                          if (status || [msgStr isEqualToString:@"Success"])
                                                          {
                                                              NSDictionary *keys = [dict objectForKey:@"data"];
                                                              NSString *iv = [keys objectForKey:@"iv"];
                                                              [PrefManager storeIv:iv];
                                                              NSLog(@"iv is %@",iv);
                                                              NSString *key = [keys objectForKey:@"key"];
                                                              [PrefManager storeKey:key];
                                                              NSLog(@"key is %@",key);
                                                      }
                                                      else{}
                                                      }
                                                  }
                                                  
                                                  else{
                                                      [LoaderView removeLoader];
                                                  }
                                              }];
    [dataTask resume];
    [defaultSession finishTasksAndInvalidate];
}

+ (void)updateGroupUI
{
    [Global shared].isReadyToStartBLE = YES;
    // update...
    UINavigationController *navC = (UINavigationController *) [[[AppManager appDelegate] window] rootViewController];
    BaseViewController *vc = (BaseViewController *) [[navC viewControllers] firstObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc updateMe];
    });
}

+ (void)downloadActivity
{
    if (!isLoggedIn) return;
    [Global shared].isNotiLoading = YES;
    __block __unsafe_unretained NotificationViewController *nVc  = nil;
    UINavigationController *nvc = (UINavigationController *)[[[AppManager appDelegate] window] rootViewController];
    
    // by nim
    //    UIViewController *vc;
    //    if ([nvc isKindOfClass:[REFrostedViewController class]]){
    //        REFrostedViewController *nvc = (REFrostedViewController *)[[[AppManager appDelegate] window] rootViewController];
    //        vc = (REFrostedViewController *) [nvc contentViewController];
    //    }else{
    //        vc = (UIViewController *) [nvc topViewController];
    //    }
    //
    
    UIViewController *vc = [AppManager getTopviewController:nvc];
    // UIViewController *vc = (UIViewController *) [nvc topViewController];
    if ([vc isKindOfClass:[NotificationViewController class]])
    {
        [LoaderView addLoaderToView:vc.view];
        nVc = (NotificationViewController*)vc;
        [nVc refreshUI];
    }
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    // make a param..
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser];
    [param setObject : user.user_id  forKey : @"user_id"];
    [client POST:NotificationPath parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         if(response != NULL)
         {
         BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
         if(status)
         {
             [NotificationInfo parseResponse:response];
             [self checkNotifications];
             
         }
         else{
             // [GroupsViewController checkNotificationBadge];  // by nim
         }
         
         UINavigationController *nvc = (UINavigationController *)[[[AppManager appDelegate] window] rootViewController];
         // UIViewController *vc = (UIViewController *) [nvc topViewController];
         UIViewController *vc = [AppManager getTopviewController:nvc];
         if ([vc isKindOfClass:[NotificationViewController class]])
         {
             [LoaderView addLoaderToView:vc.view];
             nVc = (NotificationViewController*)vc;
         }
         if (nVc)
         {
             [LoaderView removeLoader];
             // [nVc refreshNotiifcations];
         }
         [Global shared].isNotiLoading = NO;
     }
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (nVc)
         {
             [LoaderView removeLoader];
         }
         [Global shared].isNotiLoading = NO;
     }];
}

+(void)checkNotifications{
    
    NSInteger countActonableNotif = [DBManager getArrayOfActionableNotifications].count;
    //Comparing countActonableNotif not equal to saved count of NSUserDefaults
    if ([[NSUserDefaults standardUserDefaults] valueForKey:k_actionableNotify]==nil || [[[NSUserDefaults standardUserDefaults] valueForKey:k_actionableNotify] integerValue] != countActonableNotif)
    {
        if (countActonableNotif==1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"You have %ld pending notification for Approval.", (long)countActonableNotif] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            if (alert.visible==FALSE)
            {
                [alert show];
            }
        }
        else if (countActonableNotif>1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"You have %ld pending notifications for Approval.", (long)countActonableNotif] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            if (alert.visible==FALSE)
            {
                [alert show];
            }
        }
    }
    [self savingdbnotifycount:countActonableNotif];
}

+(void)savingdbnotifycount:(NSInteger)passedactionableNotifycount
{
    //saving saved count in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:passedactionableNotifycount] forKey:k_actionableNotify];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)downloadActivityOnView:(UIView *)view WithCompletion:(void (^)(BOOL finished,NSString * messsge))completion
{
    if (!isLoggedIn) return;
    if ([AppManager isInternetShouldAlert:NO] == NO)
    {
        completion(YES,@"No internet connection");
        return;
    }
    // add token..
    // [LoaderView addLoaderToView:view];
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // make a param..
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser];
    [param setObject : user.user_id  forKey : @"user_id"];
    
    [client POST:NotificationPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            [NotificationInfo parseResponse:response];
            completion(YES,@"");
        }else{
            completion(NO,[response objectForKey:@"message"]);
        }
    }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
        completion(NO,@"");
    }];
}


+ (void)parseUsersettingResponce:(NSDictionary*)response
{
    NSDictionary *dicUserSetting = [response objectForKey:@"UserSetting"];
    NSNumber *shouldShowPhoneBkUp = [dicUserSetting valueForKey:@"phone_backup"];
    [PrefManager setShouldOpenSaved:shouldShowPhoneBkUp.boolValue];
    NSNumber *shouldShowsonar = [dicUserSetting valueForKey:@"sonar"];
    [PrefManager setShouldOpenSonar:shouldShowsonar.boolValue];
    NSString *defaultNetId = [dicUserSetting valueForKey:@"default_network_id"];
    // set active networks
    NSString *nId = [[PrefManager activeNetId] copy];
    if (nId == nil && defaultNetId != nil && defaultNetId.length>0)
    {
        [PrefManager setActiveNetId:[defaultNetId copy]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:k_GotuserSettings object:nil userInfo:nil];
    if (shouldShowPhoneBkUp.boolValue==NO)
    {
        NSArray *arrOfShoutsPreparedForBkUp = [DBManager getAllShoutsForBackup:YES];
        [Shout updateShoutForNoBackupPermissionAndSynced:arrOfShoutsPreparedForBkUp];
    }
}

+ (void)downloadUserSettingsAfterLogin:(void (^)(BOOL finished))completion
{
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    // make a param..
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser];
    [param setObject : user.user_id  forKey : @"user_id"];
    [client GET:UserSettingsPath parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject )
     {
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         if(response != NULL)
         {
         BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
         if(status)
         {
             [AppManager parseUsersettingResponce:response];
             if (completion) {
                 completion(YES);
             }
         }
         else
         {
             if (completion)
             {
                 completion(NO);
             }
         }
     }
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (completion) {
             completion(NO);
         }
     }];
}

+ (void)downloadUserSettings
{
    if (!isLoggedIn) return;
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    // make a param..
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser];
    [param setObject : user.user_id  forKey : @"user_id"];
    [client GET:UserSettingsPath parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject )
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            [AppManager parseUsersettingResponce:response];
        }
    }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

/*! @method : Get Unique Id.  */
+ (NSString *)uuid
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    return uuidString;
}

/*! @method : Check internet connectivity.  */
+ (BOOL)isInternetShouldAlert:(BOOL)alert
{
    BOOL isConnected = [[InternetCheck sharedInstance] internetWorking];
    if(alert && !isConnected)
    {
        [AppManager showAlertWithTitle:@"Error!" Body:@"Your Internet is not working, Please connect to Internet.!!"];
    }
    return isConnected;
}

/*! @method : get sutable (non null, nil) string.  */
+ (NSString *)sutableStrWithStr:(NSString *)str
{
    NSString *str1 = [NSString stringWithFormat:@"%@", str];
    if([[str1 class]isSubclassOfClass:NSClassFromString(@"NSNull")]) return @"";
    if(!str1) return @"";
    return (![str1 isEqualToString:@"<null>"] && ![str1 isEqualToString:@"(null)"]) ? str1 : @"";
}

/*! @method : show alert with their title and body.  */
+ (void)showAlertWithTitle: (NSString *)titleMsg Body:(NSString *)body
{
    __block NSString *title = titleMsg;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!title) title = @"";
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:title message:body delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

/*! @method : hide alert.  */
+ (void)hideAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

/*! @method : logout me.  */
+ (void)logOut
{
    [PrefManager removeActiveNetId];
    [DBManager clearMyData];
    [PrefManager setLoggedIn:NO];
    [PrefManager storeUserId:nil];
    [PrefManager storeToken:nil];
    [PrefManager clearReadNotfIds];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];// on logout there should be no badge
    [Global shared].isReadyToStartBLE = NO;
    [Global shared].isMessageForwarding = NO;
    [Global shared].activities = nil;
    
}

+ (void)handleError:(NSError *)error withOpCode:(NSInteger)code showMessageStatus:(BOOL)isShowAlert
{
    [LoaderView removeLoader];
    if (code == kTokenExpCode)
    {
        [AppManager handleSessionExpiration];
    }
    else if(isShowAlert)
    {
        [AppManager showAlertWithTitle:nil Body:error.localizedDescription];
    }
}

+ (void)handleSessionExpiration
{
    // [AppManager showAlertWithTitle:nil Body:@"Session expired!"];
    UIAlertController *alert = nil;
    alert = [UIAlertController alertControllerWithTitle:@"" message:@"Session expired!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   [PrefManager setLoggedIn:NO];
                                   
                               }];
    
    [alert addAction:okAction];
    UIWindow *keyWindow = [[UIApplication sharedApplication]keyWindow];
    UIViewController *mainController = [keyWindow rootViewController];
    if(![self doesAlertViewExist])
    [mainController presentViewController:alert animated:YES completion:nil];
    [PrefManager setLoggedIn:NO];
    [BaseViewController showLogin];
}

+ (BOOL) doesAlertViewExist {
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0) {
            
            BOOL alert = [[subviews objectAtIndex:0] isKindOfClass:[UIAlertController class]];
            BOOL action = [[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]];
            
            if (alert || action)
                return YES;
        }
    }
    return NO;
}
+ (UIImage*)getPreViewImg:(NSURL *)url
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return img;
}

+ (void)favouriteCall:(Shout*)shot withFavFlag:(BOOL)isFavBool
{
    Shout *sht = (Shout *)shot;
    BOOL isFav  = isFavBool;
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        
        // add loader..
        if ([Global shared].currentUser.user_id==nil)
        {
            return;
        }
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
        DLog(@"Param to update for book marking : %@",param);
        AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
        NSString *token = [PrefManager token];
        [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
        
        [client POST:ShoutsFavourites parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
             if(response != NULL)
             {
             DLog(@"Response is  : %@",response);
             BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
             if(status)
             {
                 [sht setFavorite:[NSNumber numberWithInt:2]];
                 
                // dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [DBManager save];
                     
              //   });
             }
             else{
                 
                 [sht setFavorite:[NSNumber numberWithInt:isFav]];
                 [DBManager save];
                 
                 //   [AppManager showAlertWithTitle:@"Alert!" Body:@"This message is bookmarked locally. You may not view them after re-login"];
                 
             }
         }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             //             [sht setFavorite:[NSNumber numberWithInt:isFav]];
             //             [DBManager save];
             
             NSLog(@"ERROR in selecting message as favourite %@",error.localizedDescription);
             
             // If Internet is not present.
             [App_delegate.cachedShoutDetails  addObject:param];
             
         }];
        
    }];
    
    [sht setFavorite:[NSNumber numberWithInt:isFav]];
    [DBManager save];
    
}
//Shout Tupe

+ (NSString*)getStrFromShoutType:(NSNumber*)type{
    
    if (type.integerValue==ShoutTypeTextMsg)
    {
        return @"text";
    }
    else if (type.integerValue==ShoutTypeImage)
    {
        return @"image";
    }
    else if (type.integerValue==ShoutTypeAudio)
    {
        return @"audio";
    }
    else if (type.integerValue==ShoutTypeVideo)
    {
        return @"video";
    }
    else if (type.integerValue==ShoutTypeGif)
    {
        return @"gif";
    }
    return nil;
}

+ (NSNumber *)getShoutTypeFromString:(NSString*)type{
    
    if ([type isEqualToString:@"text"])
    {
        return [NSNumber numberWithInteger:ShoutTypeTextMsg];
    }
    else if ([type isEqualToString:@"image"])
    {
        return [NSNumber numberWithInteger:ShoutTypeImage];
    }
    else if ([type isEqualToString:@"audio"])
    {
        return [NSNumber numberWithInteger:ShoutTypeAudio];
    }
    else if ([type isEqualToString:@"video"])
    {
        return [NSNumber numberWithInteger:ShoutTypeVideo];
    }
    else if ([type isEqualToString:@"gif"])
    {
        return [NSNumber numberWithInteger:ShoutTypeGif];
    }
    return nil;
}

//Adding TextType Shout On Server
+ (void)addShoutsOnServer:(NSArray*)shtArr
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
    }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        for(Shout *sht in shtArr){
            sht.synced=[NSNumber numberWithInt:0];
        }
        [DBManager save];
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:NO];
    }];
}

//Adding MediaType Shout On Server
+ (void)addMediaShoutsOnServer:(NSArray*)shtArr
{
    for(Shout *sht in shtArr)
    {
        [AppManager addMediaShoutOnServer:sht];
    }
}

+ (void)addMediaShoutOnServer:(Shout*)sht
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *parDict = [[NSMutableDictionary alloc] init];
    NSDictionary *dict = [Shout getParamsFrom:sht];
    [parDict setObject:dict forKey:@"0"];
    [param setObject:parDict forKey:@"addshouts"];
    // add token..
    NSString *token = [PrefManager token];
    sht.synced=[NSNumber numberWithInt:1];
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
                    DLog(@"addMediaShoutOnServer data %@", data);
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
                //shradha
                //  sht.synced=[NSNumber numberWithInt:0];
                
                sht.synced=[NSNumber numberWithInt:2];
                [DBManager save];
            }
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
        }
    }];
    [uploadTask resume];
    /*api end*/
}

+(NSInteger)getUnreadNotification
{
    NSArray *lastNotfIds = [PrefManager ReadNotfids];
    return lastNotfIds.count;
    //    int countRead = 0;
    //    NSArray *list = [[Global shared] activities];
    //    for (NotificationInfo *inf in list)
    //    {
    //        if ([lastNotfIds containsObject:inf.notfId])
    //        {
    //            countRead ++;
    //        }
    //    }
    //    return [list count]-countRead;
}

+(UIViewController*)getTopviewController:(UINavigationController *)nav{
    
    UIViewController *vc;
    if ([nav isKindOfClass:[REFrostedViewController class]]){
        REFrostedViewController *nvc = (REFrostedViewController *)[[[AppManager appDelegate] window] rootViewController];
        vc = (REFrostedViewController *) [nvc contentViewController];
    }else{
        vc = (UIViewController *) [nav topViewController];
    }
    return vc;
}

+ (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message firstButtonMsg:(NSString *)msg1 andSecondBtnMsg:(NSString *)msg2 andVC:(UIViewController *)viewC noOfBtn:(int)btn completion:(void (^)(BOOL isOkButton))completionBlock
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    if (btn == 1) {
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:msg1
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                completionBlock(YES);
                                                            }];
        [controller addAction:alertAction];
    }
    else if (btn == 2)
    {
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:msg2
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                completionBlock(NO);
                                                            }];
        
        UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:msg1
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  completionBlock(YES);
                                                              }];
        [controller addAction:alertAction];
        [controller addAction:okAlertAction];
    }
    
    if (IPAD)
    {
        // In case of IPAD;
        UIPopoverPresentationController *popover = [controller popoverPresentationController];
        if (popover) {
            popover.sourceView = viewC.view;
            popover.sourceRect = viewC.view.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
        }
    }
    [viewC presentViewController:controller animated:YES completion:nil];
}

// method to convert string into hex string
// eg :-  AAAAAA having 6 byte
//  now it is like AAAAAA
//  but having 3 bytes
+ (NSData *)dataFromHexString:(NSString *)string {
    const char *chars = [string UTF8String];
    int str_lenght = (int)string.length;
    int i = 0, len = str_lenght;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

//+(NSString *)dataStringFromdata:(NSData *)data
//{
//uint8_t *bytes = (uint8_t*)data.bytes;
//NSMutableString *bytesStr= [NSMutableString stringWithCapacity:sizeof(bytes)*1];
//for(int i=0;i<sizeof(bytes);i++){
//
//    NSLog(@"%hhu",bytes[i]);
//
//    NSString *resultString =[NSString stringWithFormat:@"%lu",(unsigned long)bytes[i]];
//    [bytesStr appendString:resultString];
//}
//    return bytesStr;
//}

+ (NSString *)stringFromHex:(NSString *)str
{
    NSMutableData *stringData = [[NSMutableData alloc] init] ;
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [str length] / 2; i++) {
        byte_chars[0] = [str characterAtIndex:i*2];
        byte_chars[1] = [str characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    
    return [[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] ;
}

// method to convert number into hex string
// if no is like 345 it will convert like 0159
// if no is like 12222 is like 2FBE
+(NSString *)ConvertNumberTOHexString:(NSString *)numberSTr
{
    NSString *hexStr = [NSString stringWithFormat:@"%lX",
                        (unsigned long)[numberSTr integerValue]];
    NSString *sh = hexStr;
    int hex_str_lenght = (int)hexStr.length;
    for (int i = hex_str_lenght; i<4; i++)
    {
        sh = [@"0" stringByAppendingString:sh];
    }
    
    DLog(@"%@", sh);
    return sh;
}

+(NSString *)ConvertMsgIdNumberTOHexString:(NSString *)shout_Id
{
    NSString *hexStr = [NSString stringWithFormat:@"%lX",
                        (unsigned long)[shout_Id integerValue]];
    NSString *sh = hexStr;
    int shid_length = (int)shout_Id.length;
    for (int i = shid_length; i<6; i++) {
        
        sh = [@"0" stringByAppendingString:sh];
    }
    
    DLog(@"%@", sh);
    return sh;
}

+(NSString *)convertAStringIntoHexString:(NSString *)string
{
    
    NSString * hexStr = [NSString stringWithFormat:@"%@",
                         [NSData dataWithBytes:[string cStringUsingEncoding:NSUTF8StringEncoding]
                                        length:strlen([string cStringUsingEncoding:NSUTF8StringEncoding])]];
    
    for(NSString * toRemove in [NSArray arrayWithObjects:@"<", @">", @" ", nil])
        hexStr = [hexStr stringByReplacingOccurrencesOfString:toRemove withString:@""];
    
    DLog(@"%@", hexStr);
    
    return hexStr;
    
    
}

+(NSString*) NSDataToHex:(NSData*)data
{
    const unsigned char *dbytes = [data bytes];
    NSMutableString *hexStr =
    [NSMutableString stringWithCapacity:[data length]*2];
    int i;
    for (i = 0; i < [data length]; i++) {
        [hexStr appendFormat:@"%02x ", dbytes[i]];
    }
    
    
    
    return [NSString stringWithString: hexStr];
}

+(NSString *)convertAStringIntoStringWithSixDigit:(NSString *)string
{
    NSString *str = string;
    int str_lenght = (int)string.length;
    
    for (int i = str_lenght; i < 6; i++) {
        
        str  = [@"0" stringByAppendingString:str];
    }
    return str;
}

+(int)convertIntFromString:(NSString *)hexString
{
    int  length = (int)strtoull([hexString UTF8String], NULL, 16);

    DLog(@"The required Length %d %d", length);
    return length;
}

+(NSString *)decToBinary:(NSUInteger)decInt
{
    NSString *string = @"" ;
    NSUInteger x = decInt;
    
    while (x>0) {
        string = [[NSString stringWithFormat: @"%lu", x&1] stringByAppendingString:string];
        x = x >> 1;
    }
    return string;
}

+(NSString *)timeStamp
{
    NSString *timeStamp;
    timeStamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    return timeStamp;
}


+(NSString *)shoutId
{
    NSString *shoutid = nil;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:k_ShoutID] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:k_ShoutID];
        shoutid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:k_ShoutID]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[shoutid intValue]+1] forKey:k_ShoutID];
    }
    else
    {
        shoutid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:k_ShoutID]];
        if ([shoutid intValue] == 65536) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:k_ShoutID];
        }else
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[shoutid intValue]+1] forKey:k_ShoutID];
    }
    DLog(@"Shout ID for the content is %@",shoutid);
    return shoutid;
}

+ (BOOL)isInternetShouldAlertwithOutMessage:(BOOL)alert
{
    BOOL isConnected = [[InternetCheck sharedInstance] internetWorking];
    
    return isConnected;
}

+ (void)saveLogWithString:(NSString *)logText andType:(NSInteger)logType {
    DLog(@"%@", logText);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-YYYY HH:mm:ss"];
    NSDate *date = [NSDate date];
    
    // Write it to the string
    if(App_delegate.tempApplicationLogs.length)
        App_delegate.tempApplicationLogs = [App_delegate.tempApplicationLogs stringByAppendingString:[NSString stringWithFormat:@"%@ : %@\n", [formatter stringFromDate:date], logText]];
    else
        App_delegate.tempApplicationLogs = [NSString stringWithFormat:@"%@ : %@\n", [formatter stringFromDate:date], logText];
}

+ (void)decideLogFileCreationAndTopologyUpload {
    // Get current time stamp
    NSInteger currentTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if(currentTimestamp % kTopologyUpgradeInterval == 0) {
        [AppManager cacheUpdatedTopologyForTimestamp:currentTimestamp];
    }
    NSString *currentTime = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    
    if([currentTime isEqualToString:@"12:00:00 AM"]) {
        [App_delegate redirectConsoleLogToDocumentFolder];
    }
}

+ (void)startLogfileTimer {
    if(App_delegate.logFileCreationTimer) {
        [App_delegate.logFileCreationTimer invalidate];
        App_delegate.logFileCreationTimer = nil;
    }
    // Start log file creation timer and put it on run loop for background compaitibility
    App_delegate.logFileCreationTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(decideLogFileCreationAndTopologyUpload) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:App_delegate.logFileCreationTimer forMode:NSRunLoopCommonModes];
}

+ (void)stopLogfileTimer {
    if(App_delegate.logFileCreationTimer) {
        [App_delegate.logFileCreationTimer invalidate];
        App_delegate.logFileCreationTimer = nil;
        App_delegate.cachedConnectionHistory = nil;
    }
}

+ (void)cacheUpdatedTopologyForTimestamp:(NSUInteger)timestamp
{
    if(!App_delegate.cachedConnectionHistory)
        App_delegate.cachedConnectionHistory = [[NSMutableArray alloc] init];
    
    //    if ([AppManager isInternetShouldAlert:NO]) {
    //        [App_delegate redirectConsoleLogToDocumentFolder];
    //    }
    
    // Create array with cached topology
    if([[[BLEManager sharedManager].perM connectedCentrals] count] > 0 && [[[BLEManager sharedManager].centralM connectedDevices]count] == 0){
        // master
        NSMutableArray        *sendingArr = [[NSMutableArray alloc] init];
        [[[BLEManager sharedManager].perM connectedCentrals] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [sendingArr addObject:[obj objectForKey:@"ID"]];
        }];
        
        NSDictionary *dataDictionary1  = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (unsigned long)timestamp],@"timestamp",sendingArr,@"destination", nil];
        
        [App_delegate.cachedConnectionHistory addObject:dataDictionary1];
    }
    else if([[[BLEManager sharedManager].perM connectedCentrals] count] == 0 && [[[BLEManager sharedManager].centralM connectedDevices] count] > 0)
    {
        // slave
        NSMutableArray        *sendingArr = [[NSMutableArray alloc] init];
        [[[BLEManager sharedManager].centralM connectedDevices] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([[obj objectForKey:@"ID"] isEqual:[NSNull null]] || [[obj objectForKey:@"ID"] isEqualToString:@""])
            {
                if([obj objectForKey:@"Adv_Data"])
                {
                    NSString *advData  = [obj objectForKey:@"Adv_Data"];
                    NSUInteger advDataLength = advData.length;
                    if(advDataLength>4)
                    {
                        [sendingArr addObject:[[obj objectForKey:@"Adv_Data"] substringFromIndex:advDataLength-4]];
                    }else
                    {
                        [sendingArr addObject:[obj objectForKey:@"ID"]];
                    }
                }
                else
                {
                    [sendingArr addObject:[obj objectForKey:@"ID"]];
                }
            }else
            {
            [sendingArr addObject:[obj objectForKey:@"ID"]];
            }
        }];
        
        NSDictionary *dataDictionary1  = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (unsigned long)timestamp],@"timestamp",sendingArr,@"destination", nil];
        
        [App_delegate.cachedConnectionHistory addObject:dataDictionary1];
    }
    
    // Check if topology upload is required
    if(timestamp % kTopologyUploadInterval == 0) {
        NSDictionary *sendingdic   = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID] ,@"source",[App_delegate.cachedConnectionHistory copy],@"data", nil];
        
        // Hit API if only the Any master or slave is connected to the devices.
        
        if ([AppManager isInternetShouldAlert:NO]) {
            
            if ([App_delegate.cachedShoutDetails count]>0) {
                
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    
                    // upload bookmark data
                    @try {
                        
                        [App_delegate.cachedShoutDetails  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
                            NSString *token = [PrefManager token];
                            [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
                            
                            [client POST:ShoutsFavourites parameters:obj success:^(AFHTTPRequestOperation *operation, id responseObject)
                             {
                                 NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                 if(response != NULL)
                                 {
                                 DLog(@"Response is  : %@",response);
                                 BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
                                 
                                 // remove the object if bookmarked or unbookmarked
                                 [App_delegate.cachedShoutDetails removeObject:obj];
                                 if(status)
                                 {
                                     DLog(@"Successfully BookMark");
                                 }
                                 else{
                                     DLog(@"Successfully Un-BookMark");
                                 }
                             }
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 
                                 //             [sht setFavorite:[NSNumber numberWithInt:isFav]];
                                 //             [DBManager save];
                                 
                                 NSLog(@"ERROR in uploading bookmarked data %@",error.localizedDescription);
                             }];
                            
                        }];
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
                }];
            }
        }
        
        if (([BLEManager sharedManager].centralM.connectedDevices.count>0 || [BLEManager sharedManager].perM.connectedCentrals.count>0) && [AppManager isInternetShouldAlert:NO])
        {
            // Remove elements from cached topology array, as they are already getting sent ot cloud
            [App_delegate.cachedConnectionHistory removeAllObjects];
            DLog(@"%@",sendingdic);
            
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSString *urlString =[NSString stringWithFormat:@"%@%@",BASE_API_URL,kConnetionAPI];
                [AppManager getAPIToKnowAboutFirmwareVersionOnCloud:urlString sendingDic:sendingdic completion:^(NSMutableDictionary *dataDic, NSError *error) {
                    if (!error) {
                        DLog(@"Logs uploaded with status %@",[dataDic objectForKey:@"status"]);
                    } else {
                        
                        NSLog(@"Logs upload failed with error %@", error.localizedDescription);
                    }
                }];
            });
        }
        
        // if having internet connection
        if ([AppManager isInternetShouldAlert:NO]) {
            
          //  NSLog(@"Last updated time is %@\n Current Time is %f\n Difference between them are%f",[PrefManager valueOfChannelRefreshTime],[[NSDate date] timeIntervalSince1970],[[NSDate date] timeIntervalSince1970]  - [[PrefManager valueOfChannelRefreshTime] integerValue]);
            

            if ([[NSDate date] timeIntervalSince1970]  - [[PrefManager valueOfChannelRefreshTime] integerValue] >= k_OneHourInSeconds) {
                // send the get channel request to update the channel list
               // [AppManager sendRequestToGetChannelList];
            }
        }
    }
}

+ (void)getAPIToKnowAboutFirmwareVersionOnCloud:(NSString *)url sendingDic:(NSDictionary *)dataDictionary completion:(void(^) (NSMutableDictionary  *dataDic,  NSError *error))responseDic
{
    NSURL *url1 = [NSURL URLWithString:url];
    NSError *error;
    
    NSData *jsonData;
    if (dataDictionary)
        jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:kNilOptions error:&error];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:url1];
    [req setHTTPMethod:@"POST"];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *token = [PrefManager token];
    [req setValue:token forHTTPHeaderField:kTokenKey];
    
    [req setHTTPBody:jsonData];
    [req setTimeoutInterval:30];
    
    NSError *error1;
    NSURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error1];
    
    if (!error && response)
    {
        //Receiving String Data from serve
        //Converting the string data to mutable dictionary and returning it into the block
        responseDic([NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil],error);
    }
    else
    {
        // if response
        if(response != nil)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            if ((long)[httpResponse statusCode] == kTokenExpCode)
            {
                [AppManager handleSessionExpiration];
            }
        }
    }
}

+(void)toCheckDuplicateContent:(NSString *)shout_Id EntityName:(NSString *)entity_Key Attribute_key_Id:(NSString *)attributeNameKey CompletionBlock:(void(^)(BOOL success)) isFinish
{
    @synchronized (self) {
        
        NSManagedObjectContext *mContext = [App_delegate xyz];
        
        DLog(@"Shout DI is %@",shout_Id);
        objc_sync_enter(mContext);
        
        __block NSEntityDescription *entity;
        __block NSSortDescriptor *sortDescriptor;
        __block NSFetchRequest *request;
        __block NSMutableArray *mutableFetchResultsV;
        __block NSError *Fetcherror;
        // mContext = [[CoreDataManager sharedManager] privateObjectContext];
        
        [mContext performBlockAndWait:^{
            
            entity = [NSEntityDescription entityForName:entity_Key
                                 inManagedObjectContext:mContext];
            request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            [request setReturnsObjectsAsFaults:NO];
        
            NSLog(@"Shout Id is %@",shout_Id);
            
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attributeNameKey
                                                         ascending:NO];
            
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor,nil];
            
            [request setSortDescriptors:sortDescriptors];
            
            NSMutableArray *mutableFetchResults = [mutableFetchResultsV copy];
            // create a fetch request
            mutableFetchResults = [[mContext executeFetchRequest:request error:&Fetcherror] mutableCopy];
            
           // NSLog(@"Shout Id is count %@",mutableFetchResults);

            if (!mutableFetchResults || Fetcherror!= nil) {
                // error handling code.
                NSLog(@"No data exist or Error is %@",[Fetcherror localizedDescription]);
                isFinish(NO);
                objc_sync_exit(mContext);
                return;
            }
            
            if ([[mutableFetchResults valueForKey:attributeNameKey] containsObject:shout_Id])
            {
                DLog(@"Duplicate Channel data as Data already Exist in DataBase");
                //notify duplicates
                // Duplicate Data
                isFinish(YES);
                objc_sync_exit(mContext);
                return;
            }
            else
            {
                NSLog(@"New Channel Data as data is not existed in DataBase in AppManager");
                //write your code to add data
                isFinish(NO);
                objc_sync_exit(mContext);
                return;
            }
        }];
    }
}

+(void)getAPIToKnowAboutUpdateFileOnCloud:(NSString *)url  file:(NSString *)dataFilePath completion:(void(^) (NSMutableDictionary * dataDic,  NSError *error))responseDic
{
    NSMutableURLRequest  *request= [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    //    NSString *token = [PrefManager token];
    //    [request setValue:token forHTTPHeaderField:kTokenKey];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // id parameter and value is email-id
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"id\"\r\n\r\n%@",[[Global shared] currentUser].email] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *currentDate;
    @try {
        
        currentDate = [[[[[dataFilePath lastPathComponent] componentsSeparatedByString:@"_"] lastObject] componentsSeparatedByString:@"."] objectAtIndex:0];
        
        DLog(@"Current date is %@",currentDate);
        
        
    } @catch (NSException *exception) {
        NSLog(@"Exception for File update %@",exception);
    } @finally {
        
    }
    // calculate the date of the file
    if ([currentDate isEqual:[NSNull null]] || [currentDate isEqualToString:@""]) {
        // No need to send the date parameter
    }else
    {
        // date parameter and value is current date
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"date\"\r\n\r\n%@",currentDate] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // log parameter and value is file
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"log\"; filename=\"%@.txt\"\r\n",@"logFile"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:[NSData dataWithContentsOfFile:dataFilePath]]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    NSError *error;
    NSURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    DLog(@"%@", returnString);
    
    if (!error && response)
    {
        //Receiving String Data from server
        NSString *result = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        //Converting the string data to mutable dictionary and returning it into the block
        responseDic([NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil],error);
    }
    else
    {
        NSLog(@"Error is %@",error.localizedDescription);
        responseDic(nil,error);
    }
}

+(void)saveEventLogInArray:(NSMutableDictionary *)dataDictionary
{
    [[App_delegate.arrayOfEventLog mutableCopy] removeAllObjects];
    App_delegate.arrayOfEventLog = [[[NSUserDefaults standardUserDefaults] objectForKey:kEventLOG] mutableCopy];
    
    if (dataDictionary)
        [App_delegate.arrayOfEventLog addObject:dataDictionary];
        
    if (App_delegate.arrayOfEventLog)
    {
        [[NSUserDefaults standardUserDefaults] setObject:App_delegate.arrayOfEventLog forKey:kEventLOG];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH a";
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    DLog(@"The Current Time is %@",[dateFormatter stringFromDate:now]);
    
    @try {
        
        if([[[[dateFormatter stringFromDate:now] componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"AM"])
        {
            if ([[[[dateFormatter stringFromDate:now] componentsSeparatedByString:@" "] objectAtIndex:0] intValue] >=0 && [[[[dateFormatter stringFromDate:now] componentsSeparatedByString:@" "] objectAtIndex:0] intValue] < 2)
            {
                NSLog(@"Value is %@",App_delegate.arrayOfEventLog);
                // [LoaderView addLoaderToView:self.view];
                NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,TOPOLOGY_LOGS];
                [SharedUtils makeEventLogAPICall:urlString];
            }
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    if ([AppManager isInternetShouldAlert:NO] && ([App_delegate.arrayOfEventLog count] %10 == 0))
    {
        NSLog(@"Value is %@",App_delegate.arrayOfEventLog);
        // [LoaderView addLoaderToView:self.view];
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,TOPOLOGY_LOGS];
        [SharedUtils makeEventLogAPICall:urlString];
    }
}

// Reverted For Cool Contact count issue
+(void)saveSoftKeyActionInDictionary:(NSMutableDictionary *)dataDictionary
{
    if (dataDictionary)
        [App_delegate.softKeyActionArray addObject:dataDictionary];
    if (App_delegate.softKeyActionArray)
    {
        [[NSUserDefaults standardUserDefaults] setObject:App_delegate.softKeyActionArray forKey:kSoftKeyAction];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(BOOL)updateUserSavedFileOnCloud
{
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                     NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSError *error;
NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"LogFolder"] error:&error];

// If more than one log file exists
    for(NSString *fileName in directoryContent) {
        // Don't delete file for current date
//        if([fileName isEqualToString:[NSString stringWithFormat:@"LoudHailer_Logs_%@.txt", currentDate]])
//            continue;
        
        // If already Logged In
        if (isLoggedIn) {
            
            // Delete log file for previous date
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"LogFolder/%@", fileName]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //                        [[[NSOperationQueue alloc] init] addOperations:
                //                                                     waitUntilFinished:YES];
                NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,kLogFileUploadAPI];

                [AppManager getAPIToKnowAboutUpdateFileOnCloud:urlString file:filePath completion:^(NSMutableDictionary *dataDic, NSError *error) {
                    if (error) {
                        // in case of error
                        NSLog(@"Error for uploading file on  server is %@",error.localizedDescription);
                    }
                    else
                    {
                        NSError *error;
                        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
                        if (success) {
                            // Delete the file from the File Path
                            NSLog(@"Delete the file from the File Path %@",filePath);
                        }
                        else
                        {
                            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                            
                        }
                    }
                }];
            });
        }
    }
    return YES;
}

+(void)sendRequestToGetChannelList
{
    //call the channel list API
    [self channelListAPI];
}

+ (void)getAPIToKnowAboutChannelList:(NSString *)url sendingDic:(NSMutableDictionary *)dataDictionary completion:(void(^) (NSMutableDictionary  *dataDic,  NSError *error))responseDic
{
    NSURL *url1 = [NSURL URLWithString:url];
    NSError *error;
    
    NSData *jsonData;
    if (dataDictionary)
        jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:kNilOptions error:&error];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:url1];
    [req setHTTPMethod:@"POST"];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *token = [PrefManager token];
    [req setValue:token forHTTPHeaderField:kTokenKey];
    
    [req setHTTPBody:jsonData];
    [req setTimeoutInterval:30];
    
    NSError *error1;
    NSURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error1];
    
    if (!error && response)
    {
        //Receiving String Data from serve
        //Converting the string data to mutable dictionary and returning it into the block
        responseDic([NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil],error);
    }
    else
    {
        // if response
        if(response != nil)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            if ((long)[httpResponse statusCode] == kTokenExpCode)
            {
                [AppManager handleSessionExpiration];
            }
        }
    }
}

+(void)channelListAPI
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    //[eventLogArr removeAllObjects];
    
    NSString *tempString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,kChannelListAPI];
    NSURL * url = [NSURL URLWithString:tempString];
    
    NSMutableDictionary *param  = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:currentApplicationId],@"application_id",[Global shared].currentUser.user_id,@"user_id",nil];
    
    NSString *logStrInHexFormat = nil;
    NSString *bleStr = [[NSString alloc]init];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    logStrInHexFormat = [AppManager convertAStringIntoHexString:aStr];
    bleStr = [bleStr stringByAppendingString:logStrInHexFormat];
    
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
        
        NSData *myData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:myData];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *token = [PrefManager token];
        [urlRequest setValue:token forHTTPHeaderField:@"token"];
        
        
        __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                       DLog(@"Response:%@ %@\n", response, error);
                                                                       if(error == nil)
                                                                       {
                                                                           NSDictionary*dataDic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                                           if(dataDic != NULL)
                                                                           {
                                                                               if([[dataDic objectForKey:@"status"] boolValue] || [[dataDic objectForKey:@"status"] isEqualToString:@"Success"])
                                                                               {
                                                                                   {
                                                                                       @try
                                                                                       {
                                                                                           DLog(@"Channel r %@",dataDic);
                                                                                           
                                                                                           NSDictionary *channels  = [[dataDic objectForKey:@"data"] objectForKey:@"Channel"];
                                                                                           
                                                                                           NSDictionary *cityData  = [[dataDic objectForKey:@"data"] objectForKey:@"City"];

                                                                                          if([cityData objectForKey:@"city_name"])
                                                                                          {
                                                                                              [PrefManager setDefaultCity:[cityData objectForKey:@"city_name"]];
                                                                                          }
                                                                                           
                                                                                           if([cityData objectForKey:@"cityid"])
                                                                                           {
                                                                                               [PrefManager setDefaultCityId:[cityData objectForKey:@"cityid"]];
                                                                                           }
                                                                                           
                                                                                           NSArray *pvtChannel = [channels objectForKey:@"default"];
                                                                                           for (NSDictionary *ch in pvtChannel)
                                                                                           {
                                                                                               
                                                                                               [Channels addChannelWithDict:ch forUsers:@[[[[Global shared] currentUser] user_id]] pic:nil isSubscribed:[ch objectForKey:@"subscribe"] channelType:[cityData objectForKey:@"cityid"]];
                                                                                           }
                                                                                                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"SetChannel" object:nil];
                                                                                           NSArray *publicChannel = [channels objectForKey:@"normal"];
                                                                                           for (NSDictionary *ch in publicChannel)
                                                                                           {
                                                                                               [Channels addChannelWithDict:ch forUsers:@[[[[Global shared] currentUser] user_id]] pic:nil isSubscribed:[ch objectForKey:@"subscribe"] channelType:[cityData objectForKey:@"cityid"]];
                                                                                           }
                                                                                           
                                                                                           
                                                                                           NSString *activeNetId = [PrefManager activeNetId];
                                                                                           Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                                                                                           
                                                                                           NSArray  *channel  = [DBManager getChannelsForNetwork:net];
                                                                                           NSMutableArray *nets = [NSMutableArray new];
                                                                                           NSArray *channelsArray;
                                                                                           NSArray *_dataarray;
                                                                                           
                                                                                           if(channel.count > 0)
                                                                                           {                                                                                               
                                                                                               NSDictionary *d = @{ @"network" : net,
                                                                                                                    @"channels"  : channel
                                                                                                                    };
                                                                                               [nets addObject:d];
                                                                                               _dataarray = nets;
                                                                                               NSDictionary *dict = [_dataarray objectAtIndex:0];
                                                                                               channelsArray = [dict objectForKey:@"channels"];
                                                                                               
                                                                                               NSMutableArray *arr1 = [NSMutableArray new];
                                                                                               NSMutableArray *arr2 = [NSMutableArray new];
                                                                                               
                                                                                               for (ChannelDetail *c  in channelsArray)
                                                                                               {
                                                                                                   [arr1 addObject:c.channelId];
                                                                                               }
                                                                                               
                                                                                               for (NSDictionary *ch  in pvtChannel)
                                                                                               {
                                                                                                   [arr2 addObject:[ch objectForKey:@"id"]];
                                                                                               }
                                                                                               
                                                                                               for (NSDictionary *ch  in publicChannel)
                                                                                               {
                                                                                                   [arr2 addObject:[ch objectForKey:@"id"]];
                                                                                               }
                                                                                               NSMutableSet *set1 = [NSMutableSet setWithArray: arr1];
                                                                                               NSSet *set2 = [NSSet setWithArray: arr2];
                                                                                               [set1 minusSet: set2];
                                                                                               NSArray *resultArray = [set1 allObjects];
                                                                                               
                                                                                               NSLog(@"Result Array %@",resultArray);
                                                                                               
                                                                                               [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                                                                   
                                                                                                   Channels *channeld = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:obj];
                                                                                                   
                                                                                                   if (channeld) {
                                                                                                       [DBManager deleteOb:channeld];
                                                                                                   }
                                                                                               }];
                                                                                            
                                                                                           }
                                                                                       } @catch (NSException *exception) {
                                                                                           
                                                                                       } @finally {
                                                                                       }
                                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"channelUpdateRequest" object:nil];
                                                                                   }
                                                                               }
                                                                           }
                                                                       }
                                                                       else
                                                                       {
                                                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;

                                                                           if([httpResponse statusCode] == kTokenExpCode){
                                                                               // disconnect all the peripheral and master connections
                                                                               [PrefManager setLoggedIn:NO];
                                                                               [BaseViewController showLogin];
                                                                           }else{
                                                                               [AppManager handleError:error withOpCode:[httpResponse statusCode] showMessageStatus:NO];
                                                                           }
                                                                       }
                                                                   }];
        [dataTask resume];
        [defaultSession finishTasksAndInvalidate];
}


@end
