//
//  Constant.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#ifndef  LH2GO_Constant_h
#define  LH2GO_Constant_h

#import "Global.h"
#import "PrefManager.h"
#import "AppManager.h"
#import "ImageOverlyViewController.h"
#import "ChannelDetailViewController.h"
#import "ChannelDetailCell.h"
#import "CustomTitleView.h"
#import "PlaceListCollectionCell.h"
#import "SelectPlaceView.h"
#import "TimeConverter.h"
#import "SharedUtils.h"
#import "CustomPopOverView.h"
#import "InfoViewController.h"
#import "FLAnimatedImage.h"
#import "ReportViewController.h"
#import "InternetCheck.h"


# define Debug          1
#define DebugLog        0

//#if Debug
//#   define NSLog(fmt, ...) NSLog((@" CLASS NAME %@ METHOD NAME : %s LINE NUMBER : [Line %d] Log_Description : " fmt),  [[NSString stringWithUTF8String:__FILE__] lastPathComponent],__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#else
//#   define NSLog(...)
//#endif

#if DebugLog
#define DLog(s, ...) NSLog(s, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

typedef NS_ENUM (NSInteger,DeviceType) {
    none,
    iPhone,
    bbox,
    iPhoneAndBbox
};

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

#define DevServer               0
#define TestingServer           1
#define ProdcutionServer        2
#define ProxyServer             3
#define currentServer           1

// for providence2go App , Application Id would be 2 always
// Need to define in every single API
// for providence2go App - 2
// for columbus2go App   dev - 6
// for columbus2go App   Testing - 10
// for columbus2go App   production - 5
#define currentApplicationId    10
#define currentAppCompatibilityVersion 0

#define k_ForeverFeed_AppDisplayTime               99999999
#define k_OLD_ForeverFeed_AppDisplayTime           999999


#define DATA                        @"Data"
#define THREAD_NAME                 @"Thread_Name"

#define kColor(_r_, _g_, _b_, _a_) [UIColor colorWithRed:_r_/255.0 green:_g_/255.0 blue:_b_/255.0 alpha:_a_]
#define kTokenExpCode               403
#define kShoutTextFontSize          14.0
#define k_MAX_SHOUT_LENGTH          250
#define k_TrackTime                 180  // 180 sec
#define KCellFadeOutDuration        900  // 900 sec
#define kVideoRecordingMaxTime      10.0
#define kAudioRecordingMaxTime      10.0

#define kImageLimit                 5*1024 //  Increased image limit to 5 KB
#define kGifLimit                   10    //   Gif size upto 10 KB
#define k_MAX_WAIT_TIME             15 //SONAR REFRESH TIME
#define k_CoreptedShoutInterval     600 //Sec
#define k_AutoBroadCastInterval     60.0  // 60
#define k_AutoBroadCastDeadTime     10*k_AutoBroadCastInterval
#define k_DBCleanUpTime             24*60*60 // 2*60*60
#define k_DBCleanDays               2
#define k_timeOut                   1800
#define k_SonarDistanceFilter       5//location update will be called after 10 meter
#define k_EnableVideoRecording      1 // TO Enable video recording feature make it 1
#define k_ReduceFragment_No         4096
#define k_LHNetworkId               1
#define kReplyCellMargin            40
#define k_AlphaReduceVal            .2
#define k_MAX_BACKUPNAME_LENGTH     31
#define k_OneHourInSeconds              60*60

#define k_permissionAlertSaved @"You have no permission to view Backup session."
#define k_permissionAlertSonar @"Your user has no access to Sonar view. Please contact support@loud-hailer.com for additional information."
#define k_exportVideoAlert @"Do you want to export this video to Photo Library."
#define k_GotuserSettings @"k_GotuserSettings"
#define k_presentScheduler @"k_presentScheduler"
#define k_MediaFileReceived @"Media file received."
#define k_TextFileReceived @"Text received."
#define k_actionableNotify  @"passednotifycount"
#define k_DeviceToken @"device_token"
#define k_Media @"MEDIA"
#define k_NotifTabCount @"NotifTabCount"
#define k_PhoneNumber @"phNumber"
#define k_ShoutID @"Shout_ID"
#define k_contentId @"contentId"
#define k_GlobalValue @"globalValue"
#define k_ShoutEncountered @"shoutEn"
#define k_groupInWhichBackupStarted @"groupInWhichBackupStarted"
#define k_LoginEmail @"LoginEmail"
#define k_LoginPassword @"LoginPassword"
#define k_userShow @"userShow"
#define k_isKeyboardUp @"isUp"
#define k_phNumberShoutReceiverCell @"phNumberShoutRecCell"
#define k_phNumberShoutCell @"phNumberShoutCell"
#define k_shoutSaved @"Saved"
#define k_notification_ID @"notId"
#define k_phNumberNotf @"phNumberNotf"
#define k_LHAccountId @"1011"
#define KNOFIFICATION_IF_CANCELLED   @"KNOFIFICATION_IF_CANCELLED"
#define kReadNotificationsTime     @"ReadNotificationsTime"
#define KOWNER_ID    @"KOWNER_ID"
#define USERLOGGEDOUT @"UserLoggedOut"
#define kchannelBadgeAdd @"NotificationForAddingChannels"

#define GOTO            @"go to"

// key of feed Id

#define k_FeedID          @"content_id"

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
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

//MARK:- To make UI device specific
#define IPhone7_Height      667
#define IPhone5_Height      568
#define IPhone7_Width       375
#define IPhoneX_Height      812
#define kRatioiPhone5 [[UIScreen mainScreen] bounds].size.height / IPhone5_Height
#define kRatio [[UIScreen mainScreen] bounds].size.height / IPhone7_Height
#define kRatioWidth [[UIScreen mainScreen] bounds].size.width / IPhone7_Width
#define kRatioIPhoneX [[UIScreen mainScreen] bounds].size.height / IPhoneX_Height


BOOL isLoggedIn;

#define DEBUGGING       0

static NSString * const ShoutContentBaseURLString     = @"https://s3.amazonaws.com/lh2go-qa/shout_files/";
static NSString * const kTokenKey                     = @"token";
static NSString * const RegistrationPath              = @"users/register";
static NSString * const LoginPath                     = @"users/login";
static NSString * const VerificationPath              = @"users/verify";
static NSString * const EditProfilePath               = @"users/editprofile";
static NSString * const ChangePassPath                = @"users/changepassword";
static NSString * const LogoutPath                    = @"users/logout";
static NSString * const UserListPath                  = @"users/userslist";
static NSString * const ForgetPassPath                = @"users/forgetpassword";
static NSString * const UserSettingsPath              = @"users/settings";
static NSString * const AddGroupPath                  = @"groups/add";
static NSString * const EditGroupPath                 = @"groups/edit";
static NSString * const DeleteGroupPath               = @"groups/delete";
static NSString * const AddNetPath                    = @"networks/add";
static NSString * const QuitGroupPath                 = @"groups/quitgroup";
static NSString * const InviteGroupPath               = @"groups/send_invites";
static NSString *const uploadMedia                    = @"relay/upload_media";
static NSString * const NotificationPath              = @"notifications";
static NSString * const NotificationAcceptPath        = @"groups/grouprequest";
static NSString * const NotificationAdminApprovalPath = @"groups/admingrouprequest";
static NSString * const ShoutsFavourites              = @"shouts/shouts_to_favorites";
static NSString * const ShoutsBackup                  = @"shouts/shout_backup";
static NSString * const editBackup                    = @"shouts/edit_backup";
static NSString * const AddShoutsOnAServer            = @"shouts/addshouts";
static NSString * const shoudBackUpDownloadPath       = @"shouts/backup_download";
static NSString * const shoudBackUpDataDownloadPath   = @"shouts/backup_data";
static NSString * const favShoutDownloadPath          = @"shouts/favorite_download";
static NSString *kStatusBarWillChange                 = @"kStatusBarWillChange";
static NSString *kStatusBarDidChange                  = @"kStatusBarDidChange";

#if currentServer == 0
//Dev URL
static NSString * const AFAppDotNetAPIBaseURLString   = @"http://34.217.67.9/index.php/";
static NSString * const profileUpdate                 = @"http://34.217.67.9/index.php/users/editprofile";
static NSString * const deleteNotification            = @"http://34.217.67.9/index.php/notifications/delete";
static NSString * const topologyConnection            = @"http://34.217.67.9/index.php/topology/connection";
/*static NSString * const AFAppDotNetAPIBaseURLString   = @"https://cms.loud-hailer.com/dev/api/index.php/";
 static NSString * const profileUpdate                 = @"https://cms.loud-hailer.com/dev/api/index.php/users/editprofile";
 static NSString * const deleteNotification            = @"https://cms.loud-hailer.com/dev/api/index.php/notifications/delete";
 static NSString * const topologyConnection            = @"https://cms.loud-hailer.com/dev/api/index.php/topology/connection";*/

#define BASE_API_URL  @"http://34.217.67.9/index.php/" //For Dev


#define GET_LIST_OF_RELAYS_URL      @"http://34.217.67.9/index.php/relay/getConnectedRelays"
#define DOWNLOAD_SECURITY_KEYS      @"http://34.217.67.9/index.php/relay/message_auth"
#define  EVENT_LOG                  @"http://34.217.67.9/index.php/relay/event_log"
#define REPORT_USER                 @"users/report_user"
#define VALIDATE_USER               @"http://34.217.67.9/index.php/users/validate_user"
#define SEND_DATA_TO_CLOUD_URL      @"http://34.217.67.9/index.php/relay/send_message"
#define VERIFYUSER                  @"users/verify"
#define EDITPROFILE                 @"http://34.217.67.9/index.php/users/editprofile"
#define SENDMEDIAMSG                @"relay/send_media_message"
#define SENDVIASCHEDULER            @"http://34.217.67.9/index.php/relay/send_message1"
#define DOESUSEREXISTS              @"http://34.217.67.9/index.php/users/user_exist"
#define GET_PRIVATE_CHANNEL_CONTENT @"http://34.217.67.9/index.php/channel/getPrivateChannel"
#define RESENDVERCODE               @"http://34.217.67.9/index.php/users/resend_passcode"
#define TOPOLOGY_LOGS               @"http://34.217.67.9/index.php/topology/logs"
#define SUBSCRIPTIONOFCHANNELS      @"http://34.217.67.9/index.php/channel/channel_subs_unsubs"
#define   CHANNELCONTENTTYPE        @"http://34.217.67.9/index.php/channel/content_option"
#define REPORT_CHANNEL_CONTENT      @"http://34.217.67.9/index.php/channel/channelContentReport"
#define REPORT_MESSAGE_CONTENT      @"http://34.217.67.9/index.php/index.php/shouts/messageReport"
#define getUserImage                @"http://34.217.67.9/index.php/users/get_profile_pic"
#define   kConnetionAPI             @"http://34.217.67.9/index.php/topology/connection"
#define   kLogFileUploadAPI         @"http://34.217.67.9/index.php/topology/uploadLogs"
#define BACKWARDCOMPATIBILTY        @"http://34.217.67.9/index.php/users/backward_compatibility"
#define GETDEFAULTLOCATION          @"http://34.217.67.9/index.php/applications/getdefaultlocation"
#define GETP2PList                  @"https://cms.loud-hailer.com/dev/api/index.php/P2P/listP2p"
#define GETP2PACCEPTREQUEST         @"https://cms.loud-hailer.com/dev/api/index.php//P2P/accept/"
#define GETP2PREJECTREQUEST         @"https://cms.loud-hailer.com/dev/api/index.php//P2P/block/"
#define SENDUSERINVITE              @"https://cms.loud-hailer.com/testing/api/index.php/P2P/send_invite"
#define GETGroupList                @"http://34.217.67.9/index.php/groups/group_list"

#define kCoutryCity_List            @"City/listCity"
#define KSetUserCity_List           @"City/setUserCity"
#define kGetUserCity_List           @"City/getUserCity"
#define kChannelListAPI             @"channel/channel_list"
#define kUserChannel_List           @"channel/getFavoriteChannel"
#define kFeed_ListAPI               @"channel/feedView"

#endif

#if currentServer == 1
#define BASE_API_URL  @"http://52.11.179.66/index.php/"// For Testing
//Testing Server

static NSString * const AFAppDotNetAPIBaseURLString  = @"http://52.11.179.66/index.php/";
static NSString * const profileUpdate                = @"http://52.11.179.66/index.php/users/editprofile";
static NSString * const deleteNotification           = @"http://52.11.179.66/index.php/notifications/delete";
static NSString * const topologyConnection           = @"http://52.11.179.66/index.php/topology/connection";

#define GET_LIST_OF_RELAYS_URL      @"http://52.11.179.66/index.php/relay/getConnectedRelays"
#define DOWNLOAD_SECURITY_KEYS      @"http://52.11.179.66/index.php/relay/message_auth"
#define EVENT_LOG                   @"http://52.11.179.66/index.php/relay/event_log"
#define REPORT_USER                 @"users/report_user"
#define VALIDATE_USER               @"http://52.11.179.66/index.php/users/validate_user"
#define SEND_DATA_TO_CLOUD_URL      @"http://52.11.179.66/index.php/relay/send_message"
#define VERIFYUSER                  @"users/verify"
#define EDITPROFILE                 @"http://52.11.179.66/index.php/users/editprofile"
#define SENDMEDIAMSG                @"relay/send_media_message"
#define SENDVIASCHEDULER            @"http://52.11.179.66/index.php/relay/send_message1"
#define DOESUSEREXISTS              @"http://52.11.179.66/index.php/users/user_exist"
#define GET_PRIVATE_CHANNEL_CONTENT @"http://52.11.179.66/index.php/channel/getPrivateChannel"
#define RESENDVERCODE               @"http://52.11.179.66/index.php/users/resend_passcode"
#define TOPOLOGY_LOGS               @"http://52.11.179.66/index.php/topology/logs"
#define SUBSCRIPTIONOFCHANNELS      @"http://52.11.179.66/index.php/channel/channel_subs_unsubs"
#define REPORT_CHANNEL_CONTENT      @"http://52.11.179.66/index.php/channel/channelContentReport"
#define REPORT_MESSAGE_CONTENT      @"http://52.11.179.66/index.php/shouts/messageReport"
#define CHANNELCONTENTTYPE          @"http://52.11.179.66/index.php/channel/content_option"
#define getUserImage                @"http://52.11.179.66/index.php/users/get_profile_pic"
#define kConnetionAPI               @"http://52.11.179.66/index.php/topology/connection"
#define kLogFileUploadAPI           @"http://52.11.179.66/index.php/topology/uploadLogs"
#define BACKWARDCOMPATIBILTY        @"http://52.11.179.66/index.php/users/backward_compatibility"
#define GETDEFAULTLOCATION          @"http://52.11.179.66/index.php/applications/getdefaultlocation"
#define GETP2PList                  @"http://52.11.179.66/index.php/P2P/listP2p"
#define GETP2PACCEPTREQUEST         @"http://52.11.179.66/index.php/P2P/accept/"
#define GETP2PREJECTREQUEST         @"http://52.11.179.66/index.php/P2P/block/"
#define SENDUSERINVITE              @"http://52.11.179.66/index.php/P2P/send_invite"

#define GETGroupList                @"http://52.11.179.66/index.php/groups/group_list"
#define kCoutryCity_List            @"City/listCity"
#define KSetUserCity_List           @"City/setUserCity"
#define kGetUserCity_List           @"City/getUserCity"
#define kChannelListAPI             @"channel/channel_list"
#define kUserChannel_List           @"channel/getFavoriteChannel"
#define kFeed_ListAPI               @"channel/feedView"



/*static NSString * const AFAppDotNetAPIBaseURLString  = @"https://cms.loud-hailer.com/testing/api/index.php/";
static NSString * const profileUpdate                = @"https://cms.loud-hailer.com/testing/api/index.php/users/editprofile";
static NSString * const deleteNotification           = @"https://cms.loud-hailer.com/testing/api/index.php/notifications/delete";
static NSString * const topologyConnection           = @"https://cms.loud-hailer.com/testing/api/index.php/topology/connection";

#define GET_LIST_OF_RELAYS_URL      @"https://cms.loud-hailer.com/testing/api/index.php/relay/getConnectedRelays"
#define DOWNLOAD_SECURITY_KEYS      @"https://cms.loud-hailer.com/testing/api/index.php/relay/message_auth"
#define EVENT_LOG                   @"https://cms.loud-hailer.com/testing/api/index.php/relay/event_log"
#define REPORT_USER                 @"https://cms.loud-hailer.com/testing/api/index.php/users/report_user"
#define VALIDATE_USER               @"https://cms.loud-hailer.com/testing/api/index.php/users/validate_user"
#define SEND_DATA_TO_CLOUD_URL      @"https://cms.loud-hailer.com/testing/api/index.php/relay/send_message"
#define VERIFYUSER                  @"https://cms.loud-hailer.com/testing/api/index.php/users/verify"
#define EDITPROFILE                 @"https://cms.loud-hailer.com/testing/api/index.php/users/editprofile"
#define SENDMEDIAMSG                @"relay/send_media_message"
#define SENDVIASCHEDULER            @"https://cms.loud-hailer.com/testing/api/index.php/relay/send_message1"
#define DOESUSEREXISTS              @"https://cms.loud-hailer.com/testing/api/index.php/users/user_exist"
#define GET_PRIVATE_CHANNEL_CONTENT @"https://cms.loud-hailer.com/testing/api/index.php/channel/getPrivateChannel"
#define RESENDVERCODE               @"https://cms.loud-hailer.com/testing/api/index.php/users/resend_passcode"
#define TOPOLOGY_LOGS               @"https://cms.loud-hailer.com/testing/api/index.php/topology/logs"
#define SUBSCRIPTIONOFCHANNELS      @"https://cms.loud-hailer.com/testing/api/index.php/channel/channel_subs_unsubs"
#define REPORT_CHANNEL_CONTENT      @"https://cms.loud-hailer.com/testing/api/index.php/channel/channelContentReport"
#define REPORT_MESSAGE_CONTENT      @"https://cms.loud-hailer.com/testing/api/index.php/shouts/messageReport"
#define CHANNELCONTENTTYPE          @"https://cms.loud-hailer.com/testing/api/index.php/channel/content_option"
#define getUserImage                @"https://cms.loud-hailer.com/testing/api/index.php/users/get_profile_pic"
#define kConnetionAPI               @"https://cms.loud-hailer.com/testing/api/index.php/topology/connection"
#define kLogFileUploadAPI           @"https://cms.loud-hailer.com/testing/api/index.php/topology/uploadLogs"
#define kChannelListAPI             @"https://cms.loud-hailer.com/testing/api/index.php/channel/channel_list"
#define BACKWARDCOMPATIBILTY        @"https://cms.loud-hailer.com/testing/api/index.php/users/backward_compatibility"
#define GETDEFAULTLOCATION          @"https://cms.loud-hailer.com/testing/api/index.php/applications/getdefaultlocation"
#define GETGroupList                @"https://cms.loud-hailer.com/testing/api/index.php/groups/group_list"*/

#endif

#if currentServer == 2
//Production Server
static NSString * const AFAppDotNetAPIBaseURLString   = @"https://cms.loud-hailer.com/api/index.php/";
static NSString * const profileUpdate                 = @"https://cms.loud-hailer.com/api/index.php/users/editprofile";
static NSString * const deleteNotification            = @"https://cms.loud-hailer.com/api/index.php/notifications/delete";
static NSString * const topologyConnection            = @"https://cms.loud-hailer.com/api/index.php/topology/connection";
#define GET_LIST_OF_RELAYS_URL      @"https://cms.loud-hailer.com/api/index.php/relay/getConnectedRelays"
#define DOWNLOAD_SECURITY_KEYS      @"https://cms.loud-hailer.com/api/index.php/relay/message_auth"
#define EVENT_LOG                   @"https://cms.loud-hailer.com/api/index.php/relay/event_log"
#define REPORT_USER                 @"http://52.11.179.66/index.php/users/report_user"
#define VALIDATE_USER               @"http://52.11.179.66/index.php/users/validate_user"
#define SEND_DATA_TO_CLOUD_URL      @"http://52.11.179.66/index.php/relay/send_message"
#define VERIFYUSER                  @"http://52.11.179.66/index.php/users/verify"
#define EDITPROFILE                 @"http://52.11.179.66/index.php/users/editprofile"
#define SENDMEDIAMSG                @"relay/send_media_message"
#define SENDVIASCHEDULER            @"http://52.11.179.66/index.php/relay/send_message1"
#define DOESUSEREXISTS              @"http://52.11.179.66/index.php/users/user_exist"
#define GET_PRIVATE_CHANNEL_CONTENT @"http://52.11.179.66/index.php/channel/getPrivateChannel"
#define RESENDVERCODE               @"http://52.11.179.66/index.php/users/resend_passcode"
#define TOPOLOGY_LOGS               @"http://52.11.179.66/index.php/topology/logs"
#define SUBSCRIPTIONOFCHANNELS      @"http://52.11.179.66/index.php/channel/channel_subs_unsubs"
#define REPORT_CHANNEL_CONTENT      @"http://52.11.179.66/index.php/channel/channelContentReport"
#define REPORT_MESSAGE_CONTENT      @"http://52.11.179.66/index.php/shouts/messageReport"
#define CHANNELCONTENTTYPE          @"http://52.11.179.66/index.php/channel/content_option"
#define GETUSERIMAGE                @"http://52.11.179.66/index.php/user/get_profile_pic"
#define getUserImage                @"http://52.11.179.66/index.php/users/get_profile_pic"
#define kConnetionAPI               @"http://52.11.179.66/index.php/topology/connection"
#define kLogFileUploadAPI           @"http://52.11.179.66/index.php/topology/uploadLogs"
#define kChannelListAPI             @"http://52.11.179.66/index.php/channel/channel_list"
#define BACKWARDCOMPATIBILTY        @"http://52.11.179.66/index.php/users/backward_compatibility"
#define GETDEFAULTLOCATION          @"http://52.11.179.66/index.php/applications/getdefaultlocation"
#define GETGroupList                @"http://52.11.179.66/index.php/groups/group_list"

#endif

static inline double degreeToRaian(double degrees) { return degrees * (M_PI / 180); }
static inline NSString * URLForShoutContent(NSString *shId, NSString *ext) { return [NSString stringWithFormat:@"%@%@.%@", ShoutContentBaseURLString, shId, ext]; }
static inline NSString * URLForShoutAudioAndVideo(NSString *shId, NSString *ext) { return [NSString stringWithFormat:@"%@.%@",shId, ext]; }

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


//Colors Hex Strings
#define TopBarTitlecolor         @"EF4E2A"//@"fbae26"
#define TopBarColor              @"242426"
#define MorebuttonColor          @"ffd84f"
#define SideMenuUpperViewcolor   @"3b3c40"
#define tabBarSelectedcolor      @"333333"
#define tabBarUnSelectedcolor    @"3b3c40"
#define themeColor               @"27262b"
#define kEventLOG                @"kEventLOG"
#define kSoftKeyAction           @"softKeyAction" //Reverted for Cool Contact count issue

//placeholder ImageNames
#define placeholderUser          @"UserIcon"
#define placeholderGroup         @"GroupUserIcon"

#define SlaveConnection          2
#define MasterConnection         3

#define Debug_Mode                @"debug_mode"
#define kFileCreationInterval                   300
#define kTopologyUpgradeInterval                15
#define kTopologyUploadInterval                 60
#define kTimeIntervalBetweenPackets             15000
#define kTimeToCheckPeripheralServices          5.0
#define kLocalLogFileNameUpgrationInterval      86400

#define kEntityForChannelFeed                       @"ChannelDetail"
#define kAttributeOfChannelFeedForContent_Id        @"contentId"
#define kEntityForCMSMessages                       @"Shout"
#define kAttributeOfCMSMessagesForShout_Id          @"shId"
#define kKeyToDataFromCMS                           @"isFromCMS"
#define kKeyToShowDataInNotifForChannel             @"Data received on channel"


// saved constant
#define LoudHailer_ID      @"loudhailer_id"
#define Central_Ref        @"Central_Ref"
#define Peripheral_Ref     @"Peripheral_Ref"
#define Ref_ID             @"ID"
#define Adv_Data           @"Adv_Data"
#define Network_Id         @"Network_Id"

#define SHout_ID_Length                     14
#define USer_ID_Length                      3
#define EOM_Length                          3
#define BOM_Length                          3
#define FRAGMENT_LENGTH                     2
#define  dynamicMTUSize                     12
#define HeaderLength                        8
#define KLoud_Hailer_ID_Length              3
#define KShout_ID_Length                    2
#define KSpecial_Byte_ID_Length             1
#define KAppDisplayTime_Length              4
#define KGroup_ID_Length                    3
#define KSPCL_Length_Schdule_ID_Length      3
#define KNetwork_ID_Length                  3
#define KContent_Data_Length                3
#define KAppDisplayTime_length              3
#define KOwner_Id_Length                    3
#define kUser_Name_Length                   12
#define kReject_Length                      9

// in Minutes
#define KAppDisplayTime                     900

// in Seconds
#define KAppDisplayTim                      900   // 15 minutes

// wait to make connection again
#define kWaitingToMakeConnection            120  // 120 sec or 2 minute
#define kLengthOfDeletepacket               8
#define kStringOfDeletedPacket              @"#!DELETE"
#define kDeletePacket                       @"DeletePacket"
#define kDeletePacketNotifocation           @"DeletePacketNotifocation"
#define kRequiredChannelId                  @"152" //@"23"


// version key
#define kApp_Version                        @"app_version"

// packet Sequecne Identifier String
#define UniqueIdentifierString              @"DP"

// Ping Packet Sequence Interval - (Broadcasting Interval)
#define PacketTimeInterval                 30

#define Device_Role_Master                  3
#define Device_Role_Slave                   4
#define Device_Role_Unknown                 7


#define kResponseMessage_SetCity            @"City id updated for the user..!"
#define kResponseMessage_CityList            @"City list...!"
#define kP2PRequestSuccessResponse          @"Request sent Successfully."
#define kUserCityInformation                @"City information..!"
#define kUserCityInformationNotFound        @"City information not found..!"

#define URLEMail @"mailto:support@loud-hailer.com?subject=Buki - report a bug&body="

#define REPORT_Email_URL @"mailto:support@loud-hailer.com?subject=Buki - Report a User&body= Type any additional comment about your report ABOVE THIS LINE.\n\n\n _____________________________________"

#endif
