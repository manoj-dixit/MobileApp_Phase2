//
//  AppDelegate.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "MenuViewController.h"
#import "ChanelViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "SharedUtils.h"
#import "Constant.h"
#import "CoreDataManager.h"

#define App_delegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
   
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIBackgroundTaskIdentifier taskidentifier;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) REFrostedViewController *container;
+ (void)networkChange;
- (void)AddSidemenu;
- (void)redirectConsoleLogToDocumentFolder;

@property (nonatomic,strong) NSOperationQueue *downloadQueue;
@property (nonatomic,strong) NSOperationQueue *queueToSaveReceiveData;


@property (nonatomic,strong) NSMutableArray *arrayOfEventLog;
@property (nonatomic, strong) NSMutableArray *softKeyActionArray;

@property (strong, nonatomic) SharedUtils *sharedUtils;
@property (assign, nonatomic) BOOL background;
@property (assign, nonatomic) BOOL toShowDebug;

@property (assign, nonatomic) BOOL toKnowtheFreshStartOfApp;

@property (assign, nonatomic) BOOL sentNotification;
@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) UIDeviceBatteryState lastBatteryState;
@property (assign, nonatomic) BOOL jobExpired;
@property (assign, nonatomic) BOOL batteryFullNotificationDisplayed;
@property (strong, nonatomic) NSUserDefaults* userDefaults;
@property (assign, nonatomic) BOOL isCallProgress;
@property (nonatomic) NSInteger pushCount;
@property (nonatomic) NSInteger tabCount;

@property (assign, nonatomic) BOOL isappLaunched;

// bool for encryption in CMS Content
@property (assign, nonatomic) BOOL isEncryptionOn;
@property (strong, nonatomic) NSString *tempApplicationLogs;
@property (strong, nonatomic) NSTimer *logFileCreationTimer;
@property (strong, nonatomic) NSMutableArray *cachedConnectionHistory;
@property (strong, nonatomic) NSMutableArray *cachedShoutDetails;
@property (strong, nonatomic) NSMutableArray *cachedBackUpDetails;

@property (assign) BOOL cloudDebugStatus;
@property (strong, nonatomic) NSString *currentLogFileDate;

- (void)registerForRemoteNotifications;
-(NSManagedObjectContext *)xyz;
@end

