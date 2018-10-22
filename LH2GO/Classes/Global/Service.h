
//
//  Constant.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#ifndef LH2GO_Constant_h
#define LH2GO_Constant_h

#import "Global.h"
#import "PrefManager.h"
#import "AppManager.h"

#define NSLog if(0)NSLog

#define DATA             @"Data"
#define THREAD_NAME      @"Thread_Name"

#define kColor(_r_, _g_, _b_, _a_) [UIColor colorWithRed:_r_/255.0 green:_g_/255.0 blue:_b_/255.0 alpha:_a_]
#define kTokenExpCode 403
#define kShoutTextFontSize 14.0
#define k_MAX_SHOUT_LENGTH 250
#define k_TrackTime             180  // 180 sec
#define KCellFadeOutDuration    900  // 900 sec
#define kVideoRecordingMaxTime  10.0
#define kAudioRecordingMaxTime  10.0
#define kImageLimit 5*1024
#define kGifLimit 100
#define k_MAX_WAIT_TIME 15 //SONAR REFRESH TIME
#define k_CoreptedShoutInterval    600 //Sec
#define k_AutoBroadCastInterval    60.0  // 60
#define k_AutoBroadCastDeadTime    10*k_AutoBroadCastInterval
#define k_DBCleanUpTime            24*60*60 // 2*60*60
#define k_DBCleanDays 2
#define k_permissionAlertSaved @"You have no permission to view Backup session."
#define k_permissionAlertSonar @"Your user has no access to Sonar view. Please contact support@loud-hailer.com for additional information."
#define k_exportVideoAlert @"Do you want to export this video to Photo Library."
#define k_GotuserSettings @"k_GotuserSettings"
#define k_presentScheduler @"k_presentScheduler"
#define k_MediaFileReceived @"Media file received."
#define k_timeOut 1800
#define k_SonarDistanceFilter 5//location update will be called after 10 meter
#define k_actionableNotify  @"passednotifycount"
#define k_EnableVideoRecording 1 // TO Enable video recording feature make it 1
#define k_DeviceToken @"DEVICE_TOEKN"
#define k_ReduceFragment_No   4096

 //LH Account Id is @"1011"
#define k_LHAccountId @"1011"
//LH Default Network Id is 1
#define k_LHNetworkId 1
#define kReplyCellMargin 40
#define k_AlphaReduceVal .2
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)
#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define IS_IPAD_PRO_1366 (IPAD && MAX(SCREEN_WIDTH,SCREEN_HEIGHT) == 1366.0)
#define IS_IPAD_PRO_1024 (IPAD && MAX(SCREEN_WIDTH,SCREEN_HEIGHT) == 1024.0)
#define kRatio1 [[UIScreen mainScreen] bounds].size.width / [[UIScreen mainScreen] bounds].size.height

//MARK:- To make UI device specific
#define IPhone7_Height 667
#define IPhone7_Width 375
#define kRatio [[UIScreen mainScreen] bounds].size.height / IPhone7_Height
#define kRatioWidth [[UIScreen mainScreen] bounds].size.width / IPhone7_Width

#define KNOFIFICATION_IF_CANCELLED   @"KNOFIFICATION_IF_CANCELLED"
#define kReadNotificationsTime     @"ReadNotificationsTime"
#define k_MAX_BACKUPNAME_LENGTH 31
#define KOWNER_ID    @"KOWNER_ID"
#define USERLOGGEDOUT @"UserLoggedOut"
//#define kEnableRange 0 // 1 to enable the min range to test the A->B->C
//int val = [RSSI intValue];
//if (abs(val)>35&&kEnableRange==1)
//return;


BOOL isLoggedIn;

//Dev URL
//https://cms.loud-hailer.com/dev/cms/"
//https://cms.loud-hailer.com/dev/channel/
//static NSString * const AFAppDotNetAPIBaseURLString = @"https://cms.loud-hailer.com/dev/api/index.php/";

//Testing URL
//https://cms.loud-hailer.com/testing/cms/
//https://cms.loud-hailer.com/testing/channel/
static NSString * const AFAppDotNetAPIBaseURLString = @"https://cms.loud-hailer.com/testing/api/index.php/";


//Production url
//https://cms.loud-hailer.com/cms
//https://cms.loud-hailer.com/channel
//static NSString * const AFAppDotNetAPIBaseURLString = @"https://cms.loud-hailer.com/api/index.php/";

#define DEBUGGING       0

static NSString * const ShoutContentBaseURLString = @"https://s3.amazonaws.com/lh2go-qa/shout_files/";
static NSString * const kTokenKey = @"token";
static NSString * const RegistrationPath       = @"users/register";
static NSString * const LoginPath              = @"users/login";
static NSString * const VerificationPath       = @"users/verify";
static NSString * const EditProfilePath        = @"users/editprofile";
static NSString * const ChangePassPath         = @"users/changepassword";
static NSString * const LogoutPath             = @"users/logout";
static NSString * const UserListPath           = @"users/userslist";
static NSString * const ForgetPassPath         = @"users/forgetpassword";
static NSString * const UserSettingsPath       = @"users/settings";
static NSString * const AddGroupPath           = @"groups/add";
static NSString * const EditGroupPath          = @"groups/edit";
static NSString * const DeleteGroupPath        = @"groups/delete";
static NSString * const AddNetPath             = @"networks/add";
static NSString * const QuitGroupPath          = @"groups/quitgroup";
static NSString * const InviteGroupPath        = @"groups/send_invites";
static NSString *const uploadMedia             = @"relay/upload_media";
static NSString * const NotificationPath       = @"notifications";
static NSString * const NotificationAcceptPath = @"groups/grouprequest";
static NSString * const NotificationAdminApprovalPath = @"groups/admingrouprequest";
static NSString * const ShoutsFavourites       = @"shouts/shouts_to_favorites";
static NSString * const ShoutsBackup           = @"shouts/shout_backup";
static NSString * const editBackup           = @"shouts/edit_backup";
static NSString * const AddShoutsOnAServer     = @"shouts/addshouts";
static NSString * const shoudBackUpDownloadPath = @"shouts/backup_download";
static NSString * const shoudBackUpDataDownloadPath = @"shouts/backup_data";
static NSString * const favShoutDownloadPath = @"shouts/favorite_download";

static NSString *kStatusBarWillChange = @"kStatusBarWillChange";
static NSString *kStatusBarDidChange = @"kStatusBarDidChange";


////Dev
//static NSString * const profileUpdate =        @"https://cms.loud-hailer.com/dev/api/index.php/users/editprofile";
//static NSString * const deleteNotification =   @"https://cms.loud-hailer.com/dev/api/index.php/notifications/delete";
//static NSString * const topologyConnection =   @"https://cms.loud-hailer.com/dev/api/index.php/topology/connection";
//
////DEV Server
//#define GET_LIST_OF_RELAYS_URL      @"https://cms.loud-hailer.com/dev/cms/relay/getConnectedRelays"
//#define DOWNLOAD_SECURITY_KEYS      @"https://cms.loud-hailer.com/dev/api/index.php/relay/message_auth"
//#define  EVENT_LOG                  @"https://cms.loud-hailer.com/dev/api/index.php/relay/event_log"
//#define REPORT_USER                 @"https://cms.loud-hailer.com/dev/api/index.php/users/report_user"
//#define VALIDATE_USER               @"https://cms.loud-hailer.com/dev/api/index.php/users/validate_user"
//#define SEND_DATA_TO_CLOUD_URL      @"https://cms.loud-hailer.com/dev/api/index.php/relay/send_message"
//#define VERIFYUSER                  @"https://cms.loud-hailer.com/dev/api/index.php/users/verify"
//#define EDITPROFILE                 @"https://cms.loud-hailer.com/dev/api/index.php/users/editprofile"
//#define SENDMEDIAMSG                @"relay/send_media_message"
//#define SENDVIASCHEDULER            @"https://cms.loud-hailer.com/dev/api/index.php/relay/send_message1"
//#define DOESUSEREXISTS              @"https://cms.loud-hailer.com/dev/api/index.php/users/user_exist"
//#define GET_PRIVATE_CHANNEL_CONTENT @"https://cms.loud-hailer.com/dev/api/index.php/channel/getPrivateChannel"
//#define RESENDVERCODE               @"https://cms.loud-hailer.com/dev/api/index.php/users/resend_passcode"
//#define TOPOLOGY_LOGS               @"https://cms.loud-hailer.com/dev/api/index.php/topology/logs"
//#define SUBSCRIPTIONOFCHANNELS      @"https://cms.loud-hailer.com/dev/api/index.php/channel/channel_subs_unsubs"
//#define REPORT_CHANNEL_CONTENT      @"https://cms.loud-hailer.com/dev/api/index.php/channel/channelContentReport"
//#define REPORT_MESSAGE_CONTENT      @"https://cms.loud-hailer.com/dev/api/index.php/shouts/messageReport"
#define GETUSERIMAGE                @"https://cms.loud-hailer.com/dev/api/index.php/user/get_profile_pic"

//Testing Server
static NSString * const profileUpdate =        @"https://cms.loud-hailer.com/testing/api/index.php/users/editprofile";
static NSString * const deleteNotification =   @"https://cms.loud-hailer.com/testing/api/index.php/notifications/delete";
static NSString * const topologyConnection =   @"https://cms.loud-hailer.com/testing/api/index.php/topology/connection";

#define GET_LIST_OF_RELAYS_URL      @"https://cms.loud-hailer.com/testing/cms/relay/getConnectedRelays"
#define DOWNLOAD_SECURITY_KEYS      @"https://cms.loud-hailer.com/testing/api/index.php/relay/message_auth"
#define  EVENT_LOG                  @"https://cms.loud-hailer.com/testing/api/index.php/relay/event_log"
#define REPORT_USER                 @"https://cms.loud-hailer.com/testing/api/index.php/users/report_user"
#define VALIDATE_USER               @"https://cms.loud-hailer.com/testing/api/index.php/users/validate_user"
#define SEND_DATA_TO_CLOUD_URL      @"https://cms.loud-hailer.com/testing/api/index.php/relay/send_message"
#define VERIFYUSER                  @"https://cms.loud-hailer.com/testing/api/index.php/users/verify"
#define EDITPROFILE                 @"https://cms.loud-hailer.com/testing/api/index.php/users/editprofile"
#define SENDMEDIAMSG                @"relay/send_media_message"
#define SENDVIASCHEDULER            @"https://cms.loud-hailer.com/testing/api/index.php/relay/send_message1"
#define DOESUSEREXISTS              @"https://cms.loud-hailer.com/testing/api/index.php/users/user_exist"
#define GET_PRIVATE_CHANNEL_CONTENT         @"https://cms.loud-hailer.com/testing/api/index.php/channel/getPrivateChannel"
#define RESENDVERCODE               @"https://cms.loud-hailer.com/testing/api/index.php/users/resend_passcode"
#define TOPOLOGY_LOGS               @"https://cms.loud-hailer.com/testing/api/index.php/topology/logs"
#define SUBSCRIPTIONOFCHANNELS      @"https://cms.loud-hailer.com/testing/api/index.php/channel/channel_subs_unsubs"
#define REPORT_CHANNEL_CONTENT      @"https://cms.loud-hailer.com/testing/api/index.php/channel/channelContentReport"
#define REPORT_MESSAGE_CONTENT      @"https://cms.loud-hailer.com/testing/api/index.php/shouts/messageReport"

//Production Server

//static NSString * const profileUpdate =        @"https://cms.loud-hailer.com/api/index.php/users/editprofile";
//static NSString * const deleteNotification =   @"https://cms.loud-hailer.com/api/index.php/notifications/delete";
//static NSString * const topologyConnection =   @"https://cms.loud-hailer.com/api/index.php/topology/connection";
//#define GET_LIST_OF_RELAYS_URL      @"https://cms.loud-hailer.com/cms/relay/getConnectedRelays"
//#define DOWNLOAD_SECURITY_KEYS      @"https://cms.loud-hailer.com/api/index.php/relay/message_auth"
//#define  EVENT_LOG                  @"https://cms.loud-hailer.com/api/index.php/relay/event_log"
//#define REPORT_USER                 @"https://cms.loud-hailer.com/api/index.php/users/report_user"
//#define VALIDATE_USER               @"https://cms.loud-hailer.com/api/index.php/users/validate_user"
//#define SEND_DATA_TO_CLOUD_URL      @"https://cms.loud-hailer.com/api/index.php/relay/send_message"
//#define VERIFYUSER                  @"https://cms.loud-hailer.com/api/index.php/users/verify"
//#define EDITPROFILE                 @"https://cms.loud-hailer.com/api/index.php/users/editprofile"
//#define SENDMEDIAMSG                @"relay/send_media_message"
//#define SENDVIASCHEDULER            @"https://cms.loud-hailer.com/api/index.php/relay/send_message1"
//#define DOESUSEREXISTS              @"https://cms.loud-hailer.com/api/index.php/users/user_exist"
//#define GET_PRIVATE_CHANNEL_CONTENT @"https://cms.loud-hailer.com/api/index.php/channel/getPrivateChannel"
//#define RESENDVERCODE               @"https://cms.loud-hailer.com/api/index.php/users/resend_passcode"
//#define TOPOLOGY_LOGS               @"https://cms.loud-hailer.com/api/index.php/topology/logs"
//#define SUBSCRIPTIONOFCHANNELS      @"https://cms.loud-hailer.com/api/index.php/channel/channel_subs_unsubs"
//
//#define REPORT_CHANNEL_CONTENT      @"https://cms.loud-hailer.com/api/index.php/channel/channelContentReport"
//#define REPORT_MESSAGE_CONTENT      @"https://cms.loud-hailer.com/api/index.php/shouts/messageReport"
//#define GETUSERIMAGE                @"https://cms.loud-hailer.com/api/index.php/user/get_profile_pic"

static inline double degreeToRaian(double degrees) { return degrees * (M_PI / 180); }
static inline NSString * URLForShoutContent(NSString *shId, NSString *ext) { return [NSString stringWithFormat:@"%@%@.%@", ShoutContentBaseURLString, shId, ext]; }
static inline NSString * URLForShoutAudioAndVideo(NSString *shId, NSString *ext) { return [NSString stringWithFormat:@"%@.%@",shId, ext]; }

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


//Colors Hex Strings
#define TopBarTitlecolor @"fbae26"
#define TopBarColor @"242426"
#define MorebuttonColor @"ffd84f"
#define SideMenuUpperViewcolor @"3b3c40"
#define tabBarSelectedcolor @"4e4f54"
#define tabBarUnSelectedcolor @"3b3c40"
#define themeColor @"1B3665"

//placeholder ImageNames
#define placeholderUser   @"UserIcon"
#define placeholderGroup @"GroupUserIcon"

#define SlaveConnection    2
#define MasterConnection  1

// saved constant
#define LoudHailer_ID    @"loudhailer_id"
#define Central_Ref        @"Central_Ref"
#define Peripheral_Ref   @"Peripheral_Ref"
#define Ref_ID                 @"ID"
#define Adv_Data            @"Adv_Data"
#define Network_Id          @"Network_Id"

#define SHout_ID_Length                     14
#define USer_ID_Length                       3
#define EOM_Length                             3
#define BOM_Length                            3
#define FRAGMENT_LENGTH                      2
#define  dynamicMTUSize                     12
#define HeaderLength                         8
#define KLoud_Hailer_ID_Length               3
#define KShout_ID_Length                     2
#define KSpecial_Byte_ID_Length              1
#define KAppDisplayTime_Length              4
#define KGroup_ID_Length                     3
#define KSPCL_Length_Schdule_ID_Length                     3

#define KNetwork_ID_Length                   3
#define KContent_Data_Length                 3
#define KAppDisplayTime_length               3
#define KOwner_Id_Length                        3

#define  kUser_Name_Length                      12
#define  kReject_Length                                9

// in Minutes
#define KAppDisplayTime                            900

// in Seconds
#define KAppDisplayTime                            900   // 15 minutes

#define kWaitingToMakeConnection            120  // 120 sec or 2 minute

#endif
