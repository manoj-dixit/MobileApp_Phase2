//
//  PrefManager.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "PrefManager.h"

static NSString *kUser_Info_Key      = @"kUser_Info_Key";
static NSString *kUser_Login_Key     = @"kUser_Login_Key";
static NSString *kUser_Id_Key        = @"kUser_Id_Key";
static NSString *kChannel_Id_Key     = @"kChannel_Id_Key";
static NSString *kNot_Alert_Key      = @"kNot_Alert_Key";
static NSString *kVerified_Key       = @"kVerified_Key";
static NSString *kUser_ActiveNet_Key    = @"kUser_ActiveNet_Key";
static NSString *kUser_ActiveToken_Key  = @"kUser_ActiveToken_Key";
static NSString *kUser_Key              = @"kUser_Key";
static NSString *kUser_Iv               = @"kUser_Iv";
static NSString *kUserListDownload_Key = @"kUserListDownload_Key";
static NSString *kReadNotfId_Key       = @"kReadNotfId_Key";
static NSString *kBackUp_Key       = @"kBackUp_Key";
static NSString *kAlreadyDownloaded_key       = @"kAlreadyDownloaded_key";
static NSString *kAlreadyDownloadedFav_key       = @"kAlreadyDownloadedFav_key";
static NSString *kShouldOpenSave_key       = @"kShouldOpenSave_key";
static NSString *kShouldOpenSonar_key       = @"kShouldOpenSonar_key";
static NSString *kgroupIdInWhichBackupStarted       = @"kGroup_ID_Backup";
static NSString *kvalueOfChannelRefreshTime = @"valueOfChannelRefreshTime";
@implementation PrefManager

/*! @method : set login bool on/off.  */
+ (void)setLoggedIn:(BOOL)login
{
    isLoggedIn = login;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: isLoggedIn forKey: kUser_Login_Key];
    [defaults synchronize];
}

+ (BOOL)login
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kUser_Login_Key];
}

// loged in user id
+ (void)storeUserId:(NSString *)uId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:uId forKey: kUser_Id_Key];
    [defaults synchronize];
}

+ (NSString *)userId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kUser_Id_Key];
}


+ (void)storeChannelId:(NSString *)cId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:cId forKey: kChannel_Id_Key];
    [defaults synchronize];
}

+ (NSString *)channelId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kChannel_Id_Key];
}


/*! @method : set Notification bool on/off.  */
+ (void)setNotfOn:(BOOL)on
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: on forKey: kNot_Alert_Key];
    [defaults synchronize];
}

+ (BOOL)isNotfOn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kNot_Alert_Key];
}

/*! @method : set verified bool on/off.  */
+ (void)setVarified:(BOOL)verified
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: verified forKey: kVerified_Key];
    [defaults synchronize];
}

+ (BOOL)isVarified
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kVerified_Key];
}

+ (void)setActiveNetId:(NSString *)netId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:netId forKey: kUser_ActiveNet_Key];
    [defaults synchronize];
}

+ (void)removeActiveNetId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kUser_ActiveNet_Key];
}

+ (NSString *)activeNetId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kUser_ActiveNet_Key];
}

+ (void)storeToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey: kUser_ActiveToken_Key];
    [defaults synchronize];
}

+ (NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kUser_ActiveToken_Key];
}

+ (void)storeKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:key forKey: kUser_Key];
    [defaults synchronize];
}

+ (NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kUser_Key];
}

+ (void)storeIv:(NSString *)iv
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:iv forKey: kUser_Iv];
    [defaults synchronize];
}

+ (NSString *)iv
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kUser_Iv];
}

+ (void)setUserDownloaded:(BOOL)downloaded
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: downloaded forKey: kUserListDownload_Key];
    [defaults synchronize];
}

+ (NSString *)valueOfChannelRefreshTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kvalueOfChannelRefreshTime];
}

+ (void)setValueForChannelRefreshTime:(NSString *)time
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // time value is nil than save the current time in it
    if (time) {
        [defaults setValue:time forKey: kvalueOfChannelRefreshTime];
    }else{
        [defaults setValue:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey: kvalueOfChannelRefreshTime];
    }
    [defaults synchronize];
}


+ (BOOL)isUserDownloaded
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kUserListDownload_Key];
}

//Read Notification id's
+ (void)storeReadNotfIds:(NSString *)nIds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nIds forKey:kReadNotfId_Key];
    [defaults synchronize];
}

+ (void)clearReadNotfIds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kReadNotfId_Key];
    [defaults synchronize];
}

+ (void)clearReadNotificationIds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"DicKey"];
    [defaults synchronize];
}

//store notification ids
+ (void)saveReadNotfIds:(NSString *)nIds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = nil;
    dic = [[NSMutableDictionary  alloc] init];
    [dic setObject:nIds forKey:[[Global shared] currentUser].user_id];
    [defaults setObject:dic forKey:@"DicKey"];
    [defaults synchronize];
}

+ (NSArray *)ReadNotfids
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *str = [defaults objectForKey:kReadNotfId_Key];
    return (str) ? [str componentsSeparatedByString:@","] : nil;
}

+ (NSMutableDictionary *)ReadNotificationids
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [defaults objectForKey:@"DicKey"];
    return dict;
}

+(void)setBackUpStarted:(BOOL)backUpStarted
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: backUpStarted forKey: kBackUp_Key];
    [defaults synchronize];
}

+(BOOL)isBackUpAlreadyInProcess
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kBackUp_Key];
}


+(void)setAlreadyDownloadedServerData:(BOOL)isDownloaded
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: isDownloaded forKey: kAlreadyDownloaded_key];
    [defaults synchronize];
}

+(BOOL)isAlreadyDownloadedServerData
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kAlreadyDownloaded_key];
}

+(void)setAlreadyDownloadedServerDataFav:(BOOL)isDownloaded
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: isDownloaded forKey: kAlreadyDownloadedFav_key];
    [defaults synchronize];
}

+(BOOL)isAlreadyDownloadedServerDataFav
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kAlreadyDownloadedFav_key];
}

+(void)setShouldOpenSaved:(BOOL)shouldOpen
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: shouldOpen forKey: kShouldOpenSave_key];
    [defaults synchronize];
}

+(BOOL)shouldOpenSaved
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kShouldOpenSave_key];
}

+(void)setShouldOpenSonar:(BOOL)shouldOpen
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: shouldOpen forKey: kShouldOpenSonar_key];
    [defaults synchronize];
}

+(BOOL)shouldOpenSonar
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kShouldOpenSonar_key];
}

+ (void)setDefaultCity:(NSString*)defaultCity{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults setObject:defaultCity forKey:@"DefaultCity"];
}

+ (NSString *)defaultUserSelectedCity{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"DefaultCity"];
}


@end
