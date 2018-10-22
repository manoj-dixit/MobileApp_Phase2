//
//  PrefManager.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProfileInfo;
@interface PrefManager : NSObject


/*! @method : set login bool on/off.  */
+ (void)setLoggedIn:(BOOL)login;
+ (BOOL)login;

// loged in user id
+ (void)storeUserId:(NSString *)uId;
+ (NSString *)userId;

/*! @method : set Notification bool on/off.  */
+ (void)setNotfOn:(BOOL)on;
+ (BOOL)isNotfOn;

/*! @method : set verified bool on/off.  */
+ (void)setVarified:(BOOL)verified;
+ (BOOL)isVarified;

/*! @method : Set/Get active network.  */
+ (void)setActiveNetId:(NSString *)netId;
+ (NSString *)activeNetId;

/*! @method : remove active network.  */
+ (void)removeActiveNetId;

/*! @method : Set/Get active token.  */
+ (void)storeToken:(NSString *)token;
+ (NSString *)token;

/*! @method : Set/Get User Secure key.  */
+ (void)storeKey:(NSString *)key;
+ (NSString *)key;

/*! @method : Set/Get User Secure iv.  */
+(void)storeIv:(NSString *)iv;
+(NSString *)iv;

/*! @method : set verified bool on/off.  */
+ (void)setUserDownloaded:(BOOL)downloaded;
+ (BOOL)isUserDownloaded;

// selectedChannel
+ (void)storeChannelId:(NSString *)cId;
+ (NSString *)channelId;

/*! read notification ids. */
+ (void)storeReadNotfIds:(NSString *)nIds;
+ (void)saveReadNotfIds:(NSString *)nIds;
+ (NSArray *)ReadNotfids;
+ (NSMutableDictionary *)ReadNotificationids;
+ (void)clearReadNotfIds;
+ (void)clearReadNotificationIds;
+(void)setBackUpStarted:(BOOL)backUpStarted;
+(BOOL)isBackUpAlreadyInProcess;
+(BOOL)isAlreadyDownloadedServerData;
+(void)setAlreadyDownloadedServerData:(BOOL)isDownloaded;
+(BOOL)isAlreadyDownloadedServerDataFav;
+(void)setAlreadyDownloadedServerDataFav:(BOOL)isDownloaded;
+(void)setShouldOpenSaved:(BOOL)shouldOpen;
+(BOOL)shouldOpenSaved;
+(void)setShouldOpenSonar:(BOOL)shouldOpen;
+(BOOL)shouldOpenSonar;

+ (NSString *)valueOfChannelRefreshTime;
+ (void)setValueForChannelRefreshTime:(NSString *)time;
+ (NSString *)defaultUserSelectedCity;
+ (void)setDefaultCity:(NSString*)defaultCity;
@end
