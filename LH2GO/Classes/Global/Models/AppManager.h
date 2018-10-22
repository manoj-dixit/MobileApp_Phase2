//
//  AppManager.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ShoutBackup.h"
#import "SharedUtils.h"

@interface AppManager : NSObject


/*!
 * @method : Get appdel instance.
 */
+ (AppDelegate *)appDelegate;


/*!
 * @method : Some stuff on ap launch.
 */
+ (void)initialStuff;

+ (void)downloadUsers;

+ (void)downloadActivity;

+ (void)downloadActivityOnView:(UIView *)view WithCompletion:(void (^)(BOOL finished,NSString * messsge))completion;
+ (void)downloadUserSettings;

+ (void)downloadUserSettingsAfterLogin:(void (^)(BOOL finished))completion;

+(void)downloadSecurityKeys;

+ (NSData *)dataFromHexString:(NSString *)string;
//+(NSString *)dataStringFromdata:(NSData *)data;
+(NSString *)ConvertNumberTOHexString:(NSString *)numberSTr;
+(int)convertIntFromString:(NSString *)hexString;
+(NSString *)convertAStringIntoStringWithSixDigit:(NSString *)string;
+ (NSString *)stringFromHex:(NSString *)str;
+(NSString *)convertAStringIntoHexString:(NSString *)string;
+(NSString*) NSDataToHex:(NSData*)data;

/*!
 * @method : Get Unique Id.
 */
+ (NSString *)uuid;

/*!
 * @method : Check internet connectivity.
 */
+ (BOOL)isInternetShouldAlert:(BOOL)alert;

/*!
 * @method : get sutable (non null, nil) string.
 */
+ (NSString *)sutableStrWithStr:(NSString *)str;

/*!
 * @method : show alert with their title and body.
 */
+ (void)showAlertWithTitle: (NSString *)title
                      Body:(NSString *)body;
/*!
 * @method : logout me.
 */
+ (void)logOut;


/*!
 * @method : Hide Alert.
 */
+ (void)hideAlert;

/*!
 * @method :
 */
+ (void)handleError:(NSError *)error withOpCode:(NSInteger)code showMessageStatus:(BOOL)isShowAlert;
+ (void)handleSessionExpiration;

+ (UIImage*)getPreViewImg:(NSURL *)url;
+ (void)favouriteCall:(Shout*)sht withFavFlag:(BOOL)isFav;

//Adding TextType Shout On Server
+ (void)addShoutsOnServer:(NSArray*)shtArr;

//Adding MediaType Shout On Server
+ (void)addMediaShoutOnServer:(Shout*)sht;
+ (void)addMediaShoutsOnServer:(NSArray*)shtArr;

//getArrayOfActionableNotification returns array of notification whom type we aupply
+ (NSString*)getStrFromShoutType:(NSNumber*)type;
+ (NSNumber *)getShoutTypeFromString:(NSString*)type;
+ (void) configureAVAudioSession;
+(NSInteger)getUnreadNotification;
+(UIViewController*)getTopviewController:(UINavigationController *)nav; //  by nim
+ (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message firstButtonMsg:(NSString *)msg1 andSecondBtnMsg:(NSString *)msg2 andVC:(UIViewController *)viewC noOfBtn:(int)btn completion:(void (^)(BOOL isOkButton))completionBlock;
+ (BOOL)isInternetShouldAlertwithOutMessage:(BOOL)alert;
+(NSString *)shoutId;

//manoj

+(NSString *)ConvertMsgIdNumberTOHexString:(NSString *)shout_Id;
+(NSString *)decToBinary:(NSUInteger)decInt;
+(NSString *)timeStamp;
+ (void)startLogfileTimer;
+ (void)stopLogfileTimer;
+ (void)saveLogWithString:(NSString *)logText andType:(NSInteger)logType;



/**
 @Method is used to Find out the duplicacy of the Contents(Either the channel feed or CMS messages)

 @param shout_Id  Unique key of the Content
 @param entity_Key Entity in which need to check
 @param attributeNameKey Key that need to check for the duplicacy.
 @return Yes if Data is Duplicate,  No if data is not duplicate
 */
+(void)toCheckDuplicateContent:(NSString *)shout_Id EntityName:(NSString *)entity_Key Attribute_key_Id:(NSString *)attributeNameKey CompletionBlock:(void(^)(BOOL success)) isFinish;

+(void)getAPIToKnowAboutUpdateFileOnCloud:(NSString *)url  file:(NSString *)dataFilePath completion:(void(^) (NSMutableDictionary * dataDic,  NSError *error))responseDic;


/**
 @saveEventLogInArray  : Used to save the event logs in Array

 @param dataDictionary Input event for the Evenet Logs
 */
+(void)saveEventLogInArray:(NSMutableDictionary *)dataDictionary;
+(void)saveSoftKeyActionInDictionary:(NSMutableDictionary *)dataDictionary;// Reverted For Cool Contact count issue

+(void)sendRequestToGetChannelList;
+(void)getAPIToKnowAboutChannelList:(NSString *)url sendingDic:(NSMutableDictionary *)dataDictionary completion:(void(^) (NSMutableDictionary  *dataDic,  NSError *error))responseDic;
@end
