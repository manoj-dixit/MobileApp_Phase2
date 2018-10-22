//
//  AppDelegate.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "AppDelegate.h"
#import "LHAutoSyncing.h"
#import "BLEManager.h"
#import "LocationManager.h"
#import "ShoutManager.h"
#import "SonarViewController.h"
#import "GroupsViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "LoaderView.h"
#import "Common.h"
#import "MessagesViewController.h"
#import "SharedUtils.h"
#import "UIViewController+REFrostedViewController.h"
#import "SavedViewController.h"
#import "LHSavedCommsViewController.h"
#import "LHBackupSessionInfoVC.h"
#import "LHBackupSessionDetailVC.h"
#import "LHBackupSessionViewController.h"
#import "SettingsViewController.h"
#import "ForgetPassViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "NotificationInfo.h"
#import "Channels.h"
#import "CryptLib.h"
#import "NSData+Base64.h"
#import "ChannelDataClassInfo.h"

@interface AppDelegate ()<TopologyEventLogDelegate,UNUserNotificationCenterDelegate,APICallProtocolDelegate>
{
    BOOL isBackground;
    BOOL isForeground;
    BOOL none;
    UNUserNotificationCenter *center1;
    UNNotificationResponse *response1;
    FILE *consoleStream;
}
@end

@implementation AppDelegate
@synthesize background;
@synthesize sentNotification;
@synthesize expirationHandler;
@synthesize lastBatteryState;
@synthesize jobExpired;
@synthesize batteryFullNotificationDisplayed;
@synthesize userDefaults;
@synthesize sharedUtils;

#pragma mark - Application states

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (launchOptions==nil) {
        application.applicationIconBadgeNumber = 0;
    }
    // DLog(@"Manoj 18");
    if (self.isCallProgress){}
    else
        self.isCallProgress = false;
    [AppManager initialStuff];
    [LHAutoSyncing shared];
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc]init];
    sharedUtils.delegate = self;
    isBackground = NO;
    isForeground = NO;
    none = NO;
    _toKnowtheFreshStartOfApp = YES;
    // to show encrption on CMS content
    _isEncryptionOn = NO;
    [self registerForRemoteNotifications];
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:k_Media];
    [[NSUserDefaults standardUserDefaults]synchronize];
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
    [Crashlytics sharedInstance].debugMode = YES;
    [Fabric with:@[[Crashlytics class]]];
    
    if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled"))
        DLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
    
    //app quit white back up in progress
    DLog(@"app dir: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    if (isLoggedIn &&[PrefManager isVarified])
    {
        [self AddSidemenu];
    }else{
        _pushCount = 0;
        _tabCount = 0;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    //set navigation bar color
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[Common colorwithHexString:TopBarTitlecolor alpha:1],NSFontAttributeName :[UIFont fontWithName:@"Aileron-SemiBold" size:18.f ]}];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setBarTintColor: [Common colorwithHexString:@"242426" alpha:1]]; //242426
    [[UINavigationBar appearance] setTranslucent:false];
    _toShowDebug  = NO;
    _cachedShoutDetails    = [[NSMutableArray alloc] init];
    _cachedBackUpDetails    = [[NSMutableArray alloc] init];
    
    // redirect all the logs to the folder to check the issue.
    [self redirectConsoleLogToDocumentFolder];
    
    _arrayOfEventLog    = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEventLOG] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:_arrayOfEventLog forKey:kEventLOG];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    //Reverted for Cool Contact count issue
    _softKeyActionArray = [[NSMutableArray alloc]init];
 
//    if([[NSUserDefaults standardUserDefaults]objectForKey:kSoftKeyAction] == nil)
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:_softKeyActionArray forKey:kSoftKeyAction];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    else{
//        App_delegate.softKeyActionArray = [[[NSUserDefaults standardUserDefaults] objectForKey:kSoftKeyAction] mutableCopy];
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"softKeyAPICalled"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//
    if(!_downloadQueue)
    {
        DLog(@"Again alloc download queue");
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 4;
        _downloadQueue.qualityOfService = NSQualityOfServiceBackground;
    }
    
    if(!_queueToSaveReceiveData)
    {
        DLog(@"Again alloc download queue");
        _queueToSaveReceiveData = [[NSOperationQueue alloc] init];
        _queueToSaveReceiveData.maxConcurrentOperationCount = 1;
        _queueToSaveReceiveData.qualityOfService = NSQualityOfServiceBackground;
    }
    
    DLog(@"Manoj  %@",launchOptions);
    
    
    return YES;
}

- (void)redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // NSString *currentDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    // Get current date as xx-xx-xx
    currentDate = [currentDate stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *logPath;
    
    //    if(!App_delegate.currentLogFileDate || ![App_delegate.currentLogFileDate isEqualToString:currentDate]) {
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"/LogFolder"];
    
    //Create folder if not available
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    logPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"LogFolder/LoudHailer_Logs_%@.txt", currentDate]];
    App_delegate.currentLogFileDate = currentDate;
    
    // If console stream was redirected earlier already
//       if(consoleStream)
//       {
//           consoleStream = freopen([logPath fileSystemRepresentation],"a+",consoleStream);
//       }
//      else
//      {
//        consoleStream = freopen([logPath fileSystemRepresentation],"a+",stderr);
//        //[self saveLogsOnDataFile];
//      }
    
    NSError *error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"LogFolder"] error:&error];
    
    if(directoryContent.count>1)
    {
        [self saveLogsOnDataFile];
    }
    
    // If more than one log file exists
    if(directoryContent.count <= 3)
    {
        for(NSString *fileName in directoryContent) {
            // Don't delete file for current date
            if([fileName isEqualToString:[NSString stringWithFormat:@"LoudHailer_Logs_%@.txt", currentDate]])
                continue;
            
            // If already Logged In
            if (isLoggedIn) {
                
                // Delete log file for previous date
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"LogFolder/%@", fileName]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    //                        [[[NSOperationQueue alloc] init] addOperations:
                    //                                                     waitUntilFinished:YES];
                    
                    [AppManager getAPIToKnowAboutUpdateFileOnCloud:kLogFileUploadAPI file:filePath completion:^(NSMutableDictionary *dataDic, NSError *error) {
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
    }
    else if(directoryContent.count > 3)
    {
        // Delete log file for previous date
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![directoryContent objectAtIndex:0]) {
            return;
        }
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"LogFolder/%@", [directoryContent objectAtIndex:0]]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [AppManager getAPIToKnowAboutUpdateFileOnCloud:kLogFileUploadAPI file:filePath completion:^(NSMutableDictionary *dataDic, NSError *error) {
                if (error) {
                    // in case of error
                    
                    NSLog(@"Error for uploading file on  server is %@",error.localizedDescription);
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
                else
                {
                    // Delete the file from the File Path
                    NSLog(@"Delete the file from the File Path %@",filePath);
                    //  [fileManager removeItemAtPath:filePath error:&error];
                    
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

-(void)saveLogsOnDataFile
{
    NSArray *Contact = [DBManager entities:@"DubugLogs" pred:nil descr:nil isDistinctResults:NO];
    
    if (Contact.count>0)
    {
        NSMutableString *stringToWrite = [[NSMutableString alloc] init];
        [stringToWrite appendString:[NSString stringWithFormat:@"Event,Timestamp,Message ID,Channel ID,Group ID,Message Type, Device Role, Buki Box ID,Device1 ID,Device2 ID,Device3 ID,SizeOfData,Number Of Packets,Message Unique ID\n\n"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for(int i = 0 ;i<[Contact count];i++)     {
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"event"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"timeStamp"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"messageID"]]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"channelID"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"groupID"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"messageType"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact  objectAtIndex:i] valueForKey:@"deviceRole"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"bukiBoxID"] ]];
                
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"deviceID1"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"deviceID2"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"deviceID3"] ]];
                
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"sizeOfData"] ]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,",[[Contact objectAtIndex:i] valueForKey:@"numberOfPackets"]]];
                [stringToWrite appendString:[NSString stringWithFormat:@"%@,\n",[[Contact objectAtIndex:i] valueForKey:@"msgUniqueID"] ]];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                NSString *documentDirectory=[paths objectAtIndex:0];
                
                NSString *folderPath = [documentDirectory stringByAppendingPathComponent:@"/EventLogFolder"];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
                // Get current date as xx-xx-xx
                currentDate = [currentDate stringByReplacingOccurrencesOfString:@"/" withString:@"-"];

                NSString *logPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EventLogFolder/LoudHailer_Logs_%@.csv", currentDate]];

                [stringToWrite writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            });
        });
        
        for (NSManagedObject *managedObject in Contact)
        {
            [[App_delegate xyz] deleteObject:managedObject];
        }
        
        [self uploadDataFileOnToCloud];
    }
}

-(void)uploadDataFileOnToCloud
{
    // upload file on server
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    
    NSError *error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[documentDirectory stringByAppendingPathComponent:@"EventLogFolder"] error:&error];
    
    // If more than one log file exists
    if(directoryContent.count > 0)
    {
        for(NSString *fileName in directoryContent) {
            // Don't delete file for current date
            // If already Logged In
            if (isLoggedIn)
            {
                // Delete log file for previous date
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EventLogFolder/%@", fileName]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [AppManager getAPIToKnowAboutUpdateFileOnCloud:kLogFileUploadAPI file:filePath completion:^(NSMutableDictionary *dataDic, NSError *error) {
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
    }
}

- (void)registerForRemoteNotifications
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
    else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)AddSidemenu
{
    if (isLoggedIn &&[PrefManager isVarified])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ChanelViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
        detailViewController.delegate = self;
        MenuViewController *leftviewController = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        
        UINavigationController *centerNav = [[UINavigationController alloc]initWithRootViewController:detailViewController];
        self.container = [[REFrostedViewController alloc]initWithContentViewController:centerNav menuViewController:leftviewController];
        if (IPAD)
            self.container.menuViewSize = CGSizeMake((SCREEN_WIDTH/2), SCREEN_HEIGHT);
        else
            self.container.menuViewSize = CGSizeMake((SCREEN_WIDTH-100), SCREEN_HEIGHT);
        
        self.container.direction = REFrostedViewControllerDirectionLeft;
        self.container.limitMenuViewSize = YES;
        [UIApplication sharedApplication].delegate.window.rootViewController = self.container;
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[LocationManager sharedManager] stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"activeGroup" object:nil];
}



-(void)cmsNotifications:(NSDictionary*)dict isClickedOnPush:(BOOL)isClickedOnPush
{
    UIViewController *gvc = nil;
    NSArray *allVc;// = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
    
    if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
    {
        if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
        {
            if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                
                if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                    allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                    if (allVc.count>0) {
                        [NotificationInfo parseResponse:dict];
                    }else
                        return;
                }
                else
                {
                    DLog(@"Not a navigation controller");
                    return;
                }
            }else
            {
                DLog(@"If content view controller not exist");
                return;
            }
        }else{
            
            DLog(@"Root view controller is not REFrosted view controller");
            return;
        }
    }
    
    if((isForeground == YES || isForeground == NO) && isBackground == NO && none!=YES){
        
        for (UIViewController *vc in allVc) {
            
            if([vc isKindOfClass:[NotificationViewController class]]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CMSN" object:nil userInfo:dict];
                return;
            }
        }
        UIViewController *tempvc = [allVc objectAtIndex:0];
        
        if([tempvc isKindOfClass:[LHSavedCommsViewController class]])
        {
            [(LHSavedCommsViewController *)tempvc goToNotificationScreen:dict isClickedOnPush:isClickedOnPush];
        }
        
        else if([tempvc isKindOfClass:[LHBackupSessionViewController class]]){
            [(LHBackupSessionViewController *)tempvc goToNotificationScreen:dict isClickedOnPush:isClickedOnPush];
            
        }
        
        else if ([tempvc isKindOfClass:[SettingsViewController class]]){
            [(SettingsViewController *)tempvc goToNotificationScreen:dict isClickedOnPush:isClickedOnPush];
            
        }
        else if ([tempvc isKindOfClass:[ChanelViewController class]]){
            [(ChanelViewController *)tempvc goToNotificationScreen:dict isClickedOnPush:isClickedOnPush];
        }
    }
    
    else if(isForeground == YES && isBackground == YES){
        isForeground = NO;
        isBackground = NO;
        none = NO;
        for (UIViewController *vc in allVc) {
            if([vc isKindOfClass:[NotificationViewController class]])//crash fix , please dont remove this code
            {
                if (isClickedOnPush) {
                    [(BaseViewController *)vc popVC:vc];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CMSN" object:nil userInfo:dict];
                return;
            }
        }
        UIViewController *tempvc = [allVc objectAtIndex:0];
        if (isClickedOnPush) {
            gvc = [(BaseViewController *)tempvc moveToChannel:@"NotificationViewController"];
        }
        
        if(gvc == nil)
        {
            if (isClickedOnPush) {
                gvc = [(BaseViewController *)tempvc moveToChannel:@"NotificationViewController"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CMSN" object:nil userInfo:dict];
        }
        else if([gvc isKindOfClass:[NotificationViewController class]]){
            [NotificationInfo parseResponse:dict];
        }
    }
    else if(isBackground == YES)
    {
        for (UIViewController *vc in allVc) {
            if([vc isKindOfClass:[NotificationViewController class]]){
                if (isClickedOnPush) {
                    [(BaseViewController *)vc popVC:vc];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CMSN" object:nil userInfo:dict];
                return;
            }
        }
        UIViewController *tempvc = [allVc objectAtIndex:0];
        if (isClickedOnPush) {
            gvc = [(BaseViewController *)tempvc moveToChannel:@"NotificationViewController"];
        }
        if([gvc isKindOfClass:[NotificationViewController class]]){
            [NotificationInfo parseResponse:dict];
        }
    }
    else if(none == YES){
        for (UIViewController *vc in allVc) {
            if([vc isKindOfClass:[NotificationViewController class]]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CMSN" object:nil userInfo:dict];
                return;
            }
        }
        UIViewController *tempvc = [allVc objectAtIndex:0];
        
        if([tempvc isKindOfClass:[LHSavedCommsViewController class]])
        {
            [(LHSavedCommsViewController *)tempvc goToNotificationScreen:dict isClickedOnPush:isClickedOnPush];
        }
        
        else if([tempvc isKindOfClass:[LHBackupSessionViewController class]]){
            [(LHBackupSessionViewController *)tempvc goToNotificationScreen:dict isClickedOnPush:isClickedOnPush];
        }
        
        else if ([tempvc isKindOfClass:[SettingsViewController class]]){
            [(SettingsViewController *)tempvc goToNotificationScreen:dict isClickedOnPush:isClickedOnPush];
        }
        else if ([tempvc isKindOfClass:[ChanelViewController class]]){
            [(ChanelViewController *)tempvc goToNotificationScreen:dict isClickedOnPush:isClickedOnPush];
        }
    }
}

-(void)channelUpdate :(NSDictionary *)dict{
    
    if (isLoggedIn)
    {
        UIViewController *gvc = nil;
        NSMutableArray *arr;
        NSInteger index;
        arr=nil;
        arr= [[ NSMutableArray alloc]init];
        
        
        
        NSArray *allVc;// = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
        if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
        {
            if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
            {
                
                if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                    
                    if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                        
                        
                        allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                        if (allVc.count>0) {
                            
                        }else
                            return;
                    }
                    else
                    {
                        DLog(@"Not a navigation controller");
                        
                        return;
                    }
                }else
                {
                    DLog(@"If content view controller not exist");
                    
                    return;
                }
            }else{
                
                DLog(@"Root view controller is not REFrosted view controller");
                return;
            }
        }
        [arr addObjectsFromArray:allVc];
        
        for (UIViewController *vcx in arr){
            if([vcx isKindOfClass:[ChanelViewController class]]){
                index = [arr indexOfObject:vcx];
                if(index != 0)
                    [arr removeObjectAtIndex:index];
                break;
            }
            else{}
        }
        for (UIViewController *vc in arr) {
            @autoreleasepool
            {
                
                if([vc isKindOfClass:[ChanelViewController class]] || [vc isKindOfClass:[SonarViewController class]] || [vc isKindOfClass:[NotificationViewController class]] || [vc isKindOfClass:[MessagesViewController class]] || [vc isKindOfClass:[SavedViewController class]] || [vc isKindOfClass:[LHSavedCommsViewController class]] || [vc isKindOfClass:[LHBackupSessionInfoVC class]] || [vc isKindOfClass:[LHBackupSessionDetailVC class]] || [vc isKindOfClass:[LHBackupSessionViewController class]] || [vc isKindOfClass:[SettingsViewController class]]) {
                    
                    if((isForeground == YES || isForeground == NO) && isBackground == NO && none!=YES){
                        if([vc isKindOfClass:[ChanelViewController class]]){
                            [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                            NSString *cId = [dict objectForKey:@"id"];
                            NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:cId,@"id",@"NO",@"needToMove",nil];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
                            ;
                        }
                        else{
                            
                            if([vc isKindOfClass:[LHSavedCommsViewController class]])
                            {
                                [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                                
                                [(LHSavedCommsViewController *)vc goToChannelScreen:dict];
                            }
                            else if([vc isKindOfClass:[LHBackupSessionViewController class]]){
                                [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                                
                                [(LHBackupSessionViewController *)vc goToChannelScreen:dict];
                            }
                            else if ([vc isKindOfClass:[SettingsViewController class]]){
                                [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                                
                                [(SettingsViewController *)vc goToChannelScreen:dict];
                            }
                        }
                    }
                    else if(isForeground == YES && isBackground == YES){
                        isForeground = NO;
                        isBackground = NO;
                        none = NO;
                        
                        if([vc isKindOfClass:[ChanelViewController class]])//crash fix , please dont remove this code
                        {
                            [(ChanelViewController *)vc setNeedToMove:YES];
                            [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                            NSString *cId = [dict objectForKey:@"channel_id"];
                            NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:cId,@"channelId",@"YES",@"needToMove",nil];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
                            BOOL val = [(BaseViewController *)vc isAlreadyInStack:[ChanelViewController class]];
                            if(!val){
                                [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
                            }
                            else{
                                [(BaseViewController *)vc popVC:vc];
                            }
                        }
                        else{
                            gvc = [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
                            
                            if(gvc == nil)
                            {
                                [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                                
                                gvc = [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
                            }
                            else if([gvc isKindOfClass:[ChanelViewController class]]){
                                
                                [(ChanelViewController *)gvc setNeedToMove:YES];
                                [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                                NSString *cId = [dict objectForKey:@"channel_id"];
                                NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:cId,@"channelId",@"YES",@"needToMove",nil];
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
                            }
                        }
                    }
                    else if(isBackground == YES)
                    {
                        if([vc isKindOfClass:[ChanelViewController class]]){
                            [(ChanelViewController *)vc setNeedToMove:YES];
                            [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                            NSString *cId = [dict objectForKey:@"channel_id"];
                            NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:cId,@"channelId",@"YES",@"needToMove",nil];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
                            BOOL val = [(BaseViewController *)vc isAlreadyInStack:[ChanelViewController class]];
                            if(!val){
                                [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
                            }
                            else{
                                [(BaseViewController *)vc popVC:vc];
                            }
                        }
                        else{
                            [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                            gvc = [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
                            if([gvc isKindOfClass:[ChanelViewController class]]){
                                
                                [(ChanelViewController *)gvc setNeedToMove:YES];
                                [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                                NSString *cId = [dict objectForKey:@"channel_id"];
                                NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:cId,@"channelId",@"YES",@"needToMove",nil];
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
                            }
                        }
                    }
                    
                    else if(none == YES){
                        if([vc isKindOfClass:[ChanelViewController class]]){
                            [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                            NSString *cId = [dict objectForKey:@"channel_id"];
                            NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:cId,@"channelId",@"NO",@"needToMove",nil];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
                        }
                        else{
                            
                            [Channels addChannelWithDict:dict forUsers:@[[Global shared].currentUser] pic:nil isSubscribed:[dict objectForKey:@"subscribe"]];
                            
                            if([vc isKindOfClass:[LHSavedCommsViewController class]])
                            {
                                [(LHSavedCommsViewController *)vc goToChannelScreen:dict];
                            }
                            
                            else if([vc isKindOfClass:[LHBackupSessionViewController class]]){
                                [(LHBackupSessionViewController *)vc goToChannelScreen:dict];
                                
                            }
                            
                            else if ([vc isKindOfClass:[SettingsViewController class]]){
                                [(SettingsViewController *)vc goToChannelScreen:dict];
                                
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
}

-(void)channelMsgReceived: (NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount chanelID:(NSString *)channelID isClickedOnPush:(BOOL)isPush isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)isFeedType
{
    // DLog(@"Manoj 2");
    
    if (isLoggedIn)
    {
        UIViewController *gvc = nil;
        NSMutableArray *arr;
        NSInteger index;
        arr=nil;
        arr= [[ NSMutableArray alloc]init];
        
        
        NSArray *allVc ;//= [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
        if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
        {
            // DLog(@"Manoj 5");
            
            if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
            {
                
                // DLog(@"Manoj 6");
                
                if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                    
                    // DLog(@"Manoj 7");
                    
                    if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                        
                        // DLog(@"Manoj 8");
                        
                        allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                        if (allVc.count>0) {
                            // DLog(@"Manoj 9");
                            DLog(@"All VC %@",allVc);
                            
                        }else
                        {
                            // DLog(@"Manoj 1");
                            return;
                        }
                    }
                    else
                    {
                        // DLog(@"Manoj 10");
                        
                        DLog(@"Not a navigation controller");
                        
                        return;
                    }
                }else
                {
                    // DLog(@"Manoj 11");
                    
                    DLog(@"If content view controller not exist");
                    
                    return;
                }
            }else{
                
                // DLog(@"Manoj 12");
                
                DLog(@"Root view controller is not REFrosted view controller");
                return;
            }
        }
        
        // DLog(@"Manoj 13");
        
        [arr addObjectsFromArray:allVc];
        
        for (UIViewController *vcx in arr){
            // DLog(@"Manoj 14");
            if([vcx isKindOfClass:[ChanelViewController class]]){
                index = [arr indexOfObject:vcx];
                if(index != 0)
                    [arr removeObjectAtIndex:index];
                break;
            }
            else{}
        }
        for (UIViewController *vc in allVc) {
            // DLog(@"Manoj 15");
            @autoreleasepool
            {
                if([vc isKindOfClass:[ChanelViewController class]] || [vc isKindOfClass:[SonarViewController class]] || [vc isKindOfClass:[NotificationViewController class]] || [vc isKindOfClass:[MessagesViewController class]] || [vc isKindOfClass:[SavedViewController class]] || [vc isKindOfClass:[LHSavedCommsViewController class]] || [vc isKindOfClass:[LHBackupSessionInfoVC class]] || [vc isKindOfClass:[LHBackupSessionDetailVC class]] || [vc isKindOfClass:[LHBackupSessionViewController class]] || [vc isKindOfClass:[SettingsViewController class]] || [vc isKindOfClass:[CommsViewController class]]) {
                    
                    // DLog(@"Manoj 16");
                    
                    DLog(@"%@",[UIApplication sharedApplication].keyWindow.rootViewController);
                    DLog(@"%@",[UIApplication sharedApplication].keyWindow.rootViewController.presentingViewController);
                    
                    // DLog(@"Manoj 17");
                    
                    if (isPush && [[allVc lastObject] isKindOfClass:[ChanelViewController class]] && ![vc isKindOfClass:[ChanelViewController class]]) {
//                        ChanelViewController *channelCntrl = (ChanelViewController*)[allVc lastObject];
//                        [channelCntrl refreshData];
                        continue;
                    }
                    
                    if (isPush && [[allVc lastObject] isKindOfClass:[ChanelViewController class]] && [vc isKindOfClass:[ChanelViewController class]]) {
                        
                        [(ChanelViewController *)vc moveToChannelScreen:channelId];
                        
                        // DLog(@"Manoj 18");
                        // return;
                    }
                    
                    if((isForeground == YES || isForeground == NO) && isBackground == NO && none!=YES){
                        if([vc isKindOfClass:[ChanelViewController class]]){
                            
                            // DLog(@"Manoj 19");
                            
                            
                            if(isPush)
                            {
                                [(ChanelViewController *)vc setNeedToMove:NO];
                                Channels *ch = [Channels channelWithId:[NSString stringWithFormat:@"%d", [channelID intValue]] shouldInsert:NO];
                                [(ChanelViewController *)gvc setMyChannel: ch];
                            }
                            
                            // manoj dixit
                            [(ChanelViewController *)vc downloadContent:content length:length contentId:contentId cool:cool coolCount:coolCount share:share shareCount:shareCount Contact:contact contactCount:contactCount  chanelId:channelId isPush:isPush isOnSameScreenDataFetchByAPI:NO isCreatedTime:createdTime typeOfFeed:isFeedType];
                        }
                        else{
                            
                            if([vc isKindOfClass:[LHSavedCommsViewController class]])
                            {
                                // DLog(@"Manoj 20");
                                if(isPush)
                                    [(LHSavedCommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if([vc isKindOfClass:[LHBackupSessionViewController class]]){
                                // DLog(@"Manoj 21");
                                if(isPush)
                                    [(LHSavedCommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            
                            else if ([vc isKindOfClass:[SettingsViewController class]]){
                                // DLog(@"Manoj 22");
                                if(isPush)
                                    [(LHSavedCommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if([vc isKindOfClass:[CommsViewController class]]){
                                NSLog(@"goToChannelScreenForFeed isForeground == YES || isForeground == NO) && isBackground == NO && none!=YES");
                            }

                        }
                    }
                    else if(isForeground == YES && isBackground == YES){
                        
                        // DLog(@"Manoj 23");
                        
                        isForeground = NO;
                        isBackground = NO;
                        none = NO;
                        if([vc isKindOfClass:[ChanelViewController class]])//crash fix , please dont remove this code
                        {
                            Channels *ch;
                            if(isPush)
                            {
                                ch = [Channels channelWithId:[NSString stringWithFormat:@"%d", [channelID intValue]] shouldInsert:NO];
                                
                                [(ChanelViewController *)vc setNeedToMove:YES];
                                [(ChanelViewController *)gvc setMyChannel: ch];
                            }
                            [(ChanelViewController *)vc downloadContent:content length:length contentId:contentId cool:cool coolCount:coolCount share:share shareCount:shareCount Contact:contact contactCount:contactCount chanelId:channelId isPush:isPush isOnSameScreenDataFetchByAPI:NO isCreatedTime:createdTime typeOfFeed:isFeedType];
                            
                            if (isPush) {
                                
                                BOOL val = [(BaseViewController *)vc isAlreadyInStack:[ChanelViewController class]];
                                
                                if(!val){
                                    [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
                                }
                                else{
                                    if(isPush)
                                    {
                                        [(ChanelViewController *)vc setMyChannel:ch];
                                    }
                                    [(BaseViewController *)vc popVC:vc];
                                }
                            }
                        }
                        else{
                            
                            if([vc isKindOfClass:[LHSavedCommsViewController class]])
                            {
                                if(isPush)
                                    [(LHSavedCommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if([vc isKindOfClass:[LHBackupSessionViewController class]]){
                                if(isPush)
                                    [(LHBackupSessionViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if ([vc isKindOfClass:[SettingsViewController class]]){
                                if(isPush)
                                    [(SettingsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if([vc isKindOfClass:[CommsViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(CommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[SonarViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(SonarViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[MessagesViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(MessagesViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[NotificationViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(NotificationViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            
//                            if (isPush) {
//
//                                gvc = [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
//
//                                if(gvc == nil)
//                                {
//                                    gvc = [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
//                                }
//
//                                else if([gvc isKindOfClass:[ChanelViewController class]])
//                                {
//                                    if(isPush)
//                                    {
//                                        Channels *ch = [Channels channelWithId:[NSString stringWithFormat:@"%d", [channelID intValue]] shouldInsert:NO];
//                                        [(ChanelViewController *)gvc setNeedToMove:YES];
//
//                                        [(ChanelViewController *)gvc setMyChannel: ch];
//                                    }
//
//                                    [(ChanelViewController *)gvc downloadContent:content length:length contentId:contentId cool:cool coolCount:coolCount share:share shareCount:shareCount Contact:contact contactCount:contactCount chanelId:channelId isPush:isPush isOnSameScreenDataFetchByAPI:NO isCreatedTime:createdTime typeOfFeed:isFeedType];
//                                }
//                            }
                        }
                    }
                    else if(isBackground == YES)
                    {
                        // DLog(@"Manoj 25");
                        Channels *ch;
                        if([vc isKindOfClass:[ChanelViewController class]]){
                            if(isPush)
                            {
                                ch = [Channels channelWithId:[NSString stringWithFormat:@"%d", [channelID intValue]] shouldInsert:NO];
                                [(ChanelViewController *)vc setNeedToMove:YES];
                                
                                [(ChanelViewController *)gvc setMyChannel: ch];
                            }
                            [(ChanelViewController *)vc downloadContent:content length:length contentId:contentId cool:cool coolCount:coolCount share:share shareCount:shareCount Contact:contact contactCount:contactCount chanelId:channelId isPush:isPush isOnSameScreenDataFetchByAPI:NO  isCreatedTime:createdTime typeOfFeed:isFeedType];
                            
                            if (isPush) {
                                
                                BOOL val = [(BaseViewController *)vc isAlreadyInStack:[ChanelViewController class]];
                                if(!val){
                                    [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
                                }
                                else{
                                    if(isPush)
                                    {
                                        [(ChanelViewController *)vc setMyChannel:ch];
                                    }
                                    [(BaseViewController *)vc popVC:vc];
                                }
                            }
                        }
                        else{
                            
                            // DLog(@"Manoj 26");
                            
                            if([vc isKindOfClass:[LHSavedCommsViewController class]])
                            {
                                if(isPush)
                                    [(LHSavedCommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if([vc isKindOfClass:[LHBackupSessionViewController class]]){
                                if(isPush)
                                    [(LHBackupSessionViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if ([vc isKindOfClass:[SettingsViewController class]]){
                                if(isPush)
                                    [(SettingsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if([vc isKindOfClass:[CommsViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(CommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[SonarViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(SonarViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[MessagesViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(MessagesViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[NotificationViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(NotificationViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }

                            
//                            gvc = [(BaseViewController *)vc moveToChannel:@"ChanelViewController"];
//                            if([gvc isKindOfClass:[ChanelViewController class]]){
//
//                                //  [(ChanelViewController *)gvc moveToChannelScreen:channelId];
//
//                                if(isPush)
//                                {
//                                    Channels *ch = [Channels channelWithId:[NSString stringWithFormat:@"%d", [channelID intValue]] shouldInsert:NO];
//                                    [(ChanelViewController *)gvc setNeedToMove:YES];
//
//                                    [(ChanelViewController *)gvc setMyChannel: ch];
//                                }
//                                [(ChanelViewController *)gvc downloadContent:content length:length contentId:contentId cool:cool coolCount:coolCount share:share shareCount:shareCount Contact:contact contactCount:contactCount chanelId:channelId isPush:isPush isOnSameScreenDataFetchByAPI:NO  isCreatedTime:createdTime typeOfFeed:isFeedType];
//
//                            }
                        }
                    }
                    
                    else if(none == YES){
                        
                        // DLog(@"Manoj 27");
                        
                        if([vc isKindOfClass:[ChanelViewController class]]){
                            if(isPush)
                            {
                                Channels *ch = [Channels channelWithId:[NSString stringWithFormat:@"%d", [channelID intValue]] shouldInsert:NO];
                                
                                [(ChanelViewController *)gvc setMyChannel: ch];
                            }
                            
                            [(ChanelViewController *)vc downloadContent:content length:length contentId:contentId cool:cool coolCount:coolCount share:share shareCount:shareCount Contact:contact contactCount:contactCount chanelId:channelId isPush:isPush isOnSameScreenDataFetchByAPI:NO  isCreatedTime:createdTime typeOfFeed:isFeedType];
                            // [(ChanelViewController *)gvc moveToChannelScreen:channelId];
                        }
                        else{
                            
                            // DLog(@"Manoj 28");
                            
                            if([vc isKindOfClass:[LHSavedCommsViewController class]])
                            {
                                if(isPush)
                                    [(LHSavedCommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if([vc isKindOfClass:[LHBackupSessionViewController class]]){
                                if(isPush)
                                    [(LHBackupSessionViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if ([vc isKindOfClass:[SettingsViewController class]]){
                                if(isPush)
                                    [(SettingsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                            else if([vc isKindOfClass:[CommsViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(CommsViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[SonarViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(SonarViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[MessagesViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(MessagesViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            } else if([vc isKindOfClass:[NotificationViewController class]]){
                                DLog(@"goToChannelScreenForFeed none == YES");
                                if(isPush)
                                    [(NotificationViewController *)vc goToChannelScreenForFeed:content length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount channelID:channelId isClickOnPush:isPush isCreatedTime:createdTime typeOfFeed:isFeedType];
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void) backgroundCallback:(id)info
{
    NSLog(@"###### BG TASK RUNNING");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // remove all shout and fade process.
    if (isLoggedIn) {
        //      NSInteger countNotif = [AppManager getUnreadNotification];
        Global *shared = [Global shared];
        NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
        NSInteger unreadContentCount = [DBManager getUnreadChannelContentCount];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount +_pushCount+_tabCount+unreadContentCount)];
        // [[BLEManager sharedManager] startScanAndAdvInBackground];
    }
    [self keepAlive];
}

- (void) keepAlive
{
    taskidentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background task ended");
        if ([[BLEManager sharedManager].centralM.connectedDevices count]>=0 && [[BLEManager sharedManager].perM.connectedCentrals count] ==0) {
            
            [BLEManager sharedManager].isScanningFromWakeUP = YES;
            [[BLEManager sharedManager] intialScan];
            DLog(@"Manoj Kumar Dixit +++ %d",[BLEManager sharedManager].isScanningFromWakeUP);
        }
        
        [self performSelector:@selector(end) withObject:nil afterDelay:2];
        
        NSLog(@"Going in suspended mode 2");
    }];
}

-(void)end
{
    if([[BLEManager sharedManager].perM.connectedCentrals count] ==0)
    {
    [BLEManager sharedManager].isScanningFromWakeUP = YES;
    }
    
    [BLEManager sharedManager].isSuspendingByOS = YES;
    NSLog(@"Going in suspended mode 1");
    [[UIApplication sharedApplication] endBackgroundTask:taskidentifier];
    taskidentifier = UIBackgroundTaskInvalid;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (isLoggedIn) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        // [[BLEManager sharedManager] startScanAndAdvInForgraound];
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
                    DLog(@"Value is %@",App_delegate.arrayOfEventLog);
                    // [LoaderView addLoaderToView:self.view];
                    [SharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
                }
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    [BLEManager sharedManager].isScanningFromWakeUP = NO;
    [BLEManager sharedManager].isSuspendingByOS = NO;

    [self redirectConsoleLogToDocumentFolder];
    [self uploadDataFileOnToCloud];
    NSLog(@"Terminate the Background Task");
    [[UIApplication sharedApplication] endBackgroundTask:taskidentifier];
    taskidentifier = UIBackgroundTaskInvalid;
    DLog(@"Intiated the ble managers again 1");
    if ([[BLEManager sharedManager].centralM.connectedDevices count] >=0 && [[BLEManager sharedManager].perM.connectedCentrals count] >=0) {
        NSLog(@"Intiated the ble managers again 2");
        if(![[BLEManager sharedManager].scanTimer isValid] && ![[BLEManager sharedManager].addTimer isValid])
        {
          NSLog(@"Intiated the ble managers again 3");
          [[BLEManager sharedManager] autoScan];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)token
{
    NSString *deviceToken = [[[[token description]stringByReplacingOccurrencesOfString: @"<" withString: @""]stringByReplacingOccurrencesOfString: @">" withString: @""]stringByReplacingOccurrencesOfString: @" " withString: @""] ;
    [[NSUserDefaults standardUserDefaults]setObject:deviceToken forKey:k_DeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //Saving device token for use in register device token API
    NSLog(@"Device Token is %@",deviceToken);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    // DLog(@"Manoj 5");
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);

    return;
    isForeground = YES;
    none = NO;
    DLog(@"User Info : %@",notification.request.content.userInfo);
    
    DLog(@"%s",__PRETTY_FUNCTION__);

    
    NSDictionary *dict = [notification.request.content.userInfo
                          objectForKey:@"aps"];
    if (dict == nil) {
        
        NSString *shoutId =  [notification.request.content.userInfo
                              objectForKey:kShoutObjFromNotification];
        
        if (shoutId == nil)
        {
            BOOL isPrsent = false;
            for (UIViewController *vc in [(UINavigationController *)[((REFrostedViewController*)self.window.rootViewController)contentViewController] viewControllers]) {
                @autoreleasepool {
                    
                    if ([vc isKindOfClass:[ChanelViewController class]])
                    {
                        [(ChanelViewController *)vc goToChannelScreen:[NSDictionary dictionaryWithObjectsAndKeys:[notification.request.content.userInfo objectForKey:@"Msg"],@"Data",nil] isFromBackground:YES];
                        isPrsent = YES;
                        break;
                    }
                    DLog(@"VC name is %@",vc);
                }
            }
            if (!isPrsent) {}
            return;
        }
        else
        {
            Shout *shout = [Shout shoutWithId:shoutId shouldInsert:NO];
            for (UIViewController *vc in [(UINavigationController *)[((REFrostedViewController*)self.window.rootViewController)contentViewController] viewControllers]) {
                @autoreleasepool {
                    
                    if([vc isKindOfClass:[MessagesViewController class]]) {
                        [(MessagesViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                        break;
                    }
                }
            }
            return;
        }
    }
    
    NSString *notFor = [dict objectForKey:@"notification_type"];
    
    if([notFor isEqualToString:@"cms_notification"] || [notFor isEqualToString:@"group_notification"]){
        [self cmsNotifications:dict isClickedOnPush:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationReceivedForNotfTab" object:nil];
        completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
        
        return;
        
    }
    
    NSString *channelupdate = [dict objectForKey:@"push_type"];
    NSString *msgType = [dict objectForKey:@"message_type"];
    
    if([msgType isEqualToString:@"channel_contact_message"])
    {
        [self cmsNotifications:dict isClickedOnPush:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationReceivedForNotfTab" object:nil];
        completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
        return;
    }
    
    if([channelupdate isEqualToString:@"channel_update"] || [channelupdate isEqualToString:@"channel_add"]){
        [self channelUpdate:dict];
        completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
        return;
    }
    
    if([channelupdate isEqualToString:@"channel_delete"]){
        NSString *channelPushId = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"channel_id"] intValue]];
        Channels *channeld = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:channelPushId];
        if (channeld) {
            [DBManager deleteOb:channeld];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"channelRemoved" object:nil];
            
            return ;
        }
    }
    
    if([msgType isEqualToString:@"channel_message_softkey"]){
        NSArray *totalChannelContentTemp = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES AND contentId = \"%@\"", [dict objectForKey:@"channel_id"],[dict objectForKey:@"id"]] descr:nil  isDistinctResults:YES];
        if (totalChannelContentTemp) {
            ChannelDetail *cd = [totalChannelContentTemp objectAtIndex:0];
            cd.coolCount = [NSNumber numberWithInteger:[[dict objectForKey:@"cool_count"] integerValue]];
            cd.shareCount = [NSNumber numberWithInteger:[[dict objectForKey:@"share_count"] integerValue]];
            
            cd.contactCount = [NSNumber numberWithInteger:[[dict objectForKey:@"contact_ount"] integerValue]];
            
            [DBManager save];
            return ;
        }
        
    }
    
    //    else if ([msgType isEqualToString:@"channel_contact_message"])
    //    {
    //        // chanel contact message
    //
    //        //        aps =     {
    //        //            alert = "manoj contact you for shradha_testing1 channel";
    //        //            "channel_id" = 71;
    //        //            "content-available" = 1;
    //        //            id = 005238;
    //        //            "message_type" = "channel_contact_message";
    //        //            "network_id" = 1;
    //        //            "sender_id" = 4429;
    //        //            sound = default;
    //        //        };
    //        [self cmsNotifications:dict];
    //        [[NSNotificationCenter defaultCenter]postNotificationName:@"NotificationReceivedForNotfTab" object:nil];
    //        completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
    //    }
    
    
    NSString *contentUrl =  [dict
                             objectForKey:@"content_url"];
    NSString *length =  [dict
                         objectForKey:@"content_length"];
    NSString *contentId =  [dict
                            objectForKey:@"id"];
    NSString *channelId =  [dict
                            objectForKey:@"channel_id"];
    
    
    NSString *cool =  [dict
                       objectForKey:@"cool"];
    
    NSString *share =  [dict
                        objectForKey:@"share"];
    
    
    NSString *contact =  [dict
                          objectForKey:@"contact"];
    
    
    NSString *coolCount =  [dict
                            objectForKey:@"cool_count"];
    
    
    NSString *shareCount =  [dict
                             objectForKey:@"share_count"];
    
    
    NSString *contactCount =  [dict
                               objectForKey:@"contact_count"];
    
    
    NSInteger updatedTime;
    BOOL isFeedType = NO;
    if([[dict objectForKey:@"scheduler_type"] intValue] ==1)
    {
        isFeedType = YES;
        updatedTime = [[dict objectForKey:@"push_timestamp"] integerValue];
    }else
    {
        isFeedType = NO;
        updatedTime = [[dict objectForKey:@"created"] integerValue];
    }
    
    [self channelMsgReceived:contentUrl length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount chanelID:channelId isClickedOnPush:NO isCreatedTime:updatedTime typeOfFeed:isFeedType];
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    // DLog(@"Manoj 4");
    
    [self.container hideMenuViewController];
    isBackground = YES;
    none = NO;
    
    //  if(!isForeground){
    DLog(@"User Info : %@",response.notification.request.content.userInfo);

    DLog(@"%s",__PRETTY_FUNCTION__);

    NSDictionary *dict = [response.notification.request.content.userInfo
                          objectForKey:@"aps"];
    
    if (dict == nil) {
        
        NSString *shoutId =  [response.notification.request.content.userInfo
                              objectForKey:kShoutObjFromNotification];
        
        if (shoutId == nil) {
            
            BOOL isPrsent = false;
            UIViewController *viewVC;
            
            for (UIViewController *vc in [(UINavigationController *)[((REFrostedViewController*)self.window.rootViewController)contentViewController] viewControllers]) {
                @autoreleasepool {
                    
                    if ([vc isKindOfClass:[ChanelViewController class]])
                    {
                        [(ChanelViewController *)vc goToChannelScreen:[NSDictionary dictionaryWithObjectsAndKeys:[response.notification.request.content.userInfo objectForKey:@"Msg"],@"Data",nil] isFromBackground:YES];
                        break;
                    }
                    viewVC = vc;
                    DLog(@"VC name is %@",vc);
                }
            }
            if (!isPrsent) {
                
                if([viewVC isKindOfClass:[SettingsViewController class]])
                {
                    [(SettingsViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil] isBackGroundClick:YES];
                }
                else if([viewVC isKindOfClass:[SavedViewController class]])
                {
                    [(SavedViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil] isBackGroundClick:YES];
                }
                else if([viewVC isKindOfClass:[LHSavedCommsViewController class]])
                {
                    [(LHSavedCommsViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil] isBackGroundClick:YES];
                }
                else if([viewVC isKindOfClass:[LHBackupSessionInfoVC class]])
                {
                    [(LHBackupSessionInfoVC *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil]];
                }
                else if([viewVC isKindOfClass:[LHBackupSessionDetailVC class]])
                {
                    [(LHBackupSessionDetailVC *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil] isBackGroundClick:YES];
                }
                else if([viewVC isKindOfClass:[LHBackupSessionViewController class]])
                {
                    [(LHBackupSessionViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil] isBackGroundClick:NO];
                }
                else if([viewVC isKindOfClass:[NotificationViewController class]])
                {
                    [(NotificationViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil] isBackGroundClick:YES];
                }
                else if([viewVC isKindOfClass:[MessagesViewController class]])
                {
                    [(MessagesViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil] isBackGroundClick:YES];
                }
                else if([viewVC isKindOfClass:[SonarViewController class]])
                {
                    [(SonarViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:response.notification.request.content.body,@"Data",nil] isBackGroundClick:NO];
                }
            }
            return;
        }
        else
        {
            Shout *shout = [Shout shoutWithId:shoutId shouldInsert:NO];
            if(((REFrostedViewController*)self.window.rootViewController) == nil)
            {
                return;
            }
            
            NSArray *allVc;
            
            if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
            {
                if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
                {
                    if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                        
                        if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                            
                            allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                            if (allVc.count>0) {
                                
                            }else
                                return;
                        }
                        else
                        {
                            DLog(@"Not a navigation controller");
                            
                            return;
                        }
                    }else
                    {
                        DLog(@"If content view controller not exist");
                        
                        return;
                    }
                }else{
                    
                    DLog(@"Root view controller is not REFrosted view controller");
                    return;
                }
            }
            
            if (allVc.count>0) {
                
                for (UIViewController *vc in allVc) {
                    @autoreleasepool
                    {
                        
                        if([vc isKindOfClass:[MessagesViewController class]])
                        {
                            [(MessagesViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                            break;
                        }
                        else if([vc isKindOfClass:[ChanelViewController class]])
                        {
                            [(ChanelViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil];
                            break;
                        }
                        else if([vc isKindOfClass:[SonarViewController class]])
                        {
                            [(SonarViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                            break;
                        }
                        else if([vc isKindOfClass:[NotificationViewController class]])
                        {
                            [(NotificationViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                            break;
                        }
                        else if([vc isKindOfClass:[SettingsViewController class]])
                        {
                            [(SettingsViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                            break;
                        }
                        else if([vc isKindOfClass:[SavedViewController class]])
                        {
                            [(SavedViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                            break;
                        }
                        else if([vc isKindOfClass:[LHSavedCommsViewController class]])
                        {
                            [(LHSavedCommsViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                            break;
                        }
                        else if([vc isKindOfClass:[LHBackupSessionInfoVC class]])
                        {
                            [(LHBackupSessionInfoVC *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil];
                            break;
                        }
                        else if([vc isKindOfClass:[LHBackupSessionDetailVC class]])
                        {
                            [(LHBackupSessionDetailVC *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                            break;
                        }
                        else if([vc isKindOfClass:[LHBackupSessionViewController class]])
                        {
                            [(LHBackupSessionViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                            break;
                        }
                    }
                }
            }
        }
        return;
    }
    
    NSString *notFor = [dict objectForKey:@"notification_type"];
    
    if([notFor isEqualToString:@"cms_notification"] || [notFor isEqualToString:@"group_notification"]){
        [self cmsNotifications:dict isClickedOnPush:YES];
//        if(_tabCount>0)
//            _tabCount = _tabCount - 1;
//        else
//            _tabCount = 0;
        
        // NSInteger countNotif = [AppManager getUnreadNotification];
//        NSInteger unreadShoutsCount = [DBManager getUnresdShoutsCount];
//        NSInteger unreadContentCount = [DBManager getUnreadChannelContentCount];
//        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount)+_tabCount+_pushCount+unreadContentCount];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NotificationReceivedForNotfTab" object:nil];
        completionHandler();
        return;
    }
    
    NSString *channelupdate = [dict objectForKey:@"push_type"];
    NSString *msgType = [dict objectForKey:@"message_type"];
    
    if([msgType isEqualToString:@"channel_contact_message"])
    {
        [self cmsNotifications:dict isClickedOnPush:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationReceivedForNotfTab" object:nil];
        completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
        return;
    }
    
    if([channelupdate isEqualToString:@"channel_update"] || [channelupdate isEqualToString:@"channel_add"]){
        [self channelUpdate:dict];
        if(_pushCount>0)
            _pushCount = _pushCount - 1;
        else
            _pushCount = 0;
        Global *shared = [Global shared];
        NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
        NSInteger unreadContentCount = [DBManager getUnreadChannelContentCount];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount)+_pushCount+_tabCount+unreadContentCount];
        completionHandler();
        return;
    }
    
    if([channelupdate isEqualToString:@"channel_delete"]){
        NSString *channelPushId = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"channel_id"] intValue]];
        Channels *channeld = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:channelPushId];
        if (channeld) {
            [DBManager deleteOb:channeld];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"channelRemoved" object:nil];
            
            return ;
        }
        
    }
    
    if([msgType isEqualToString:@"channel_message_softkey"]){
        NSArray *totalChannelContentTemp = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES AND contentId = \"%@\"", [dict objectForKey:@"channel_id"],[dict objectForKey:@"id"]] descr:nil  isDistinctResults:YES];
        if (totalChannelContentTemp) {
            ChannelDetail *cd = [totalChannelContentTemp objectAtIndex:0];
            cd.coolCount = [NSNumber numberWithInteger:[[dict objectForKey:@"cool_count"] integerValue]];
            cd.shareCount = [NSNumber numberWithInteger:[[dict objectForKey:@"share_count"] integerValue]];
            
            cd.contactCount = [NSNumber numberWithInteger:[[dict objectForKey:@"contact_ount"] integerValue]];
            
            [DBManager save];
            return ;
        }
    }
    
    //    else if ([msgType isEqualToString:@"channel_contact_message"])
    //    {
    //        // chanel contact message
    //
    //        //        aps =     {
    //        //            alert = "manoj contact you for shradha_testing1 channel";
    //        //            "channel_id" = 71;
    //        //            "content-available" = 1;
    //        //            id = 005238;
    //        //            "message_type" = "channel_contact_message";
    //        //            "network_id" = 1;
    //        //            "sender_id" = 4429;
    //        //            sound = default;
    //        //        };
    //        [self cmsNotifications:dict];
    //        [[NSNotificationCenter defaultCenter]postNotificationName:@"NotificationReceivedForNotfTab" object:nil];
    //        completionHandler();
    //    }
    
    
    NSString *contentUrl =  [dict
                             objectForKey:@"content_url"];
    NSString *length =  [dict
                         objectForKey:@"content_length"];
    NSString *contentId =  [dict
                            objectForKey:@"id"];
    
    NSString *channelId =  [dict
                            objectForKey:@"channel_id"];
    
    NSString *channelPushId = [NSString stringWithFormat:@"%d",channelId.intValue];
    Channels *channeld = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:channelPushId];
    Global *shared = [Global shared];
    NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
    if(channeld.contentCount.integerValue>0){
        [channeld clearCount:channeld];
    }
    NSInteger unreadContentCount = [DBManager getUnreadChannelContentCount];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount)+_pushCount +_tabCount+unreadContentCount];
    
    //by nim [hang issue resolved]
    if ([((UIViewController*)self.window.rootViewController).presentedViewController isKindOfClass:[ImageCropViewController class]] || [((UIViewController*)self.window.rootViewController).presentedViewController isKindOfClass:[ImageOverlyViewController class]])
    {
        UIViewController *vc = ((UIViewController*)self.window.rootViewController).presentedViewController;
        [vc dismissViewControllerAnimated:false completion:nil];
        //[(ImageCropViewController*)vc goToComunicationScreenForShout:shout];
    }
    
    NSString *cool =  [dict
                       objectForKey:@"cool"];
    
    NSString *share =  [dict
                        objectForKey:@"share"];
    
    
    NSString *contact =  [dict
                          objectForKey:@"contact"];
    
    
    NSString *coolCount =  [dict
                            objectForKey:@"cool_count"];
    
    
    NSString *shareCount =  [dict
                             objectForKey:@"share_count"];
    
    
    NSString *contactCount =  [dict
                               objectForKey:@"contact_count"];
    
    // DLog(@"Manoj 3");
    
    NSInteger updatedTime;
    BOOL isFeedType = NO;
    if([[dict objectForKey:@"scheduler_type"] intValue] ==1)
    {
        isFeedType = YES;
        updatedTime = [[dict objectForKey:@"push_timestamp"] integerValue];
    }else
    {
        isFeedType = NO;
        updatedTime = [[dict objectForKey:@"created"] integerValue];
    }
    
    [self channelMsgReceived:contentUrl length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount chanelID:channelId isClickedOnPush:YES isCreatedTime:updatedTime typeOfFeed:isFeedType];
    
    DLog(@"Channel id Is %@ and chann %@",channelId ,channeld);
    
    if (!channeld || [channeld.image isEqualToString:@""])
    {
        DLog(@"Channel not exist in the data base");
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{

           // [AppManager sendRequestToGetChannelList];
        }];
    }
    completionHandler();
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self.container hideMenuViewController];
    NSString *shoutId =  [notification.userInfo
                          objectForKey:kShoutObjFromNotification];
    Shout *shout = [Shout shoutWithId:shoutId shouldInsert:NO];
    //    for (UIViewController *vc in ((UINavigationController*)self.window.rootViewController).viewControllers) {
    for (UIViewController *vc in [(UINavigationController *)[((REFrostedViewController*)self.window.rootViewController)contentViewController] viewControllers]) {
        @autoreleasepool {
            if([vc isKindOfClass:[MessagesViewController class]]) {
                [(MessagesViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
                break;
            }
        }
    }
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    DLog(@"User Info %@", userInfo);
    DLog(@"%s",__PRETTY_FUNCTION__);
    if(isLoggedIn)
    {
        none = YES;
        isBackground = NO;
        isForeground = NO;
        NSDictionary *dict = [userInfo objectForKey:@"aps"];
        
        NSString *deleteNotf = [dict objectForKey:@"method"];
        
        DLog(@"Data is %@",dict);
        
        if([deleteNotf isEqualToString:@"delete_content"]){
            
            NSString *contentId = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"content_id"] intValue]];
            
            NSString *contentID = contentId;
            int cid_lenght = (int)contentId.length;
            
            for (int i = cid_lenght; i < 6; i++) {
                
                contentID  = [@"0" stringByAppendingString:contentID];
            }
            
            NSArray *arr = [DBManager entityWithStr:@"ChannelDetail" idName:@"contentId" idValueFor:contentID];
            
            if (arr.count>0) {
                
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    ChannelDetail *channeld  = obj;
                    if (channeld) {
//                        channeld.toBeDisplayed = NO;
                        [DBManager deleteOb:obj];
                        [DBManager save];
                    }
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"channelRefresh" object:nil];
                completionHandler(UIBackgroundFetchResultNewData);
                return;
            }
            
        }
        
        NSString *notFor = [dict objectForKey:@"notification_type"];
        
        if([notFor isEqualToString:@"cms_notification"] || [notFor isEqualToString:@"group_notification"]){
            [self cmsNotifications:dict isClickedOnPush:NO];
            NSString *notId = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"notification_id"] intValue]];
            [PrefManager storeReadNotfIds:notId];
            _tabCount = _tabCount+1;
            [[NSUserDefaults standardUserDefaults]setInteger:_tabCount forKey:k_NotifTabCount];
            [[NSUserDefaults standardUserDefaults]synchronize];
            // NSInteger countNotif = [AppManager getUnreadNotification];
            Global *shared = [Global shared];
            NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
            NSInteger unreadContentCount = [DBManager getUnreadChannelContentCount];
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount )+_tabCount+_pushCount+unreadContentCount];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NotificationReceivedForNotfTab" object:nil];
            completionHandler(UIBackgroundFetchResultNewData);
            
            return;
            
        }
        
        NSString *channelupdate = [dict objectForKey:@"push_type"];
        NSString *msgType = [dict objectForKey:@"message_type"];
        
        if([msgType isEqualToString:@"channel_contact_message"])
        {
            [self cmsNotifications:dict isClickedOnPush:NO];
            NSString *notId = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"notification_id"] intValue]];
            [PrefManager storeReadNotfIds:notId];
            _tabCount = _tabCount+1;
            [[NSUserDefaults standardUserDefaults]setInteger:_tabCount forKey:k_NotifTabCount];
            [[NSUserDefaults standardUserDefaults]synchronize];
            // NSInteger countNotif = [AppManager getUnreadNotification];
            Global *shared = [Global shared];
            NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
            NSInteger unreadContentCount = [DBManager getUnreadChannelContentCount];
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount )+_tabCount+_pushCount+unreadContentCount];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationReceivedForNotfTab" object:nil];
            completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
            return;
        }
        
        if([channelupdate isEqualToString:@"channel_update"] || [channelupdate isEqualToString:@"channel_add"])
        {
            [self channelUpdate:dict];
            _pushCount = 0;//_pushCount+1; count shall not be increased when silent push is received.
            Global *shared = [Global shared];
            NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
            NSInteger unreadContentCount = [DBManager getUnreadChannelContentCount];
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount)+_pushCount +_tabCount+unreadContentCount];
            completionHandler(UIBackgroundFetchResultNewData);
            return;
        }
        
        if([channelupdate isEqualToString:@"channel_delete"]){
            NSString *channelPushId = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"channel_id"] intValue]];
            Channels *channeld = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:channelPushId];
            if (channeld) {
                [DBManager deleteOb:channeld];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"channelRemoved" object:nil];
                completionHandler(UIBackgroundFetchResultNewData);
                return ;
            }
            return ;
        }
        
        if([msgType isEqualToString:@"channel_message_softkey"]){
            NSArray *totalChannelContentTemp = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES AND contentId = \"%@\"", [dict objectForKey:@"channel_id"],[dict objectForKey:@"id"]] descr:nil  isDistinctResults:YES];
            if (totalChannelContentTemp.count>0) {
                ChannelDetail *cd = [totalChannelContentTemp objectAtIndex:0];
                cd.coolCount = [NSNumber numberWithInteger:[[dict objectForKey:@"cool_count"] integerValue]];
                cd.shareCount = [NSNumber numberWithInteger:[[dict objectForKey:@"share_count"] integerValue]];
                cd.contactCount = [NSNumber numberWithInteger:[[dict objectForKey:@"contact_count"] integerValue]];
                
                DLog(@"User id is %@",[[[Global shared] currentUser] user_id]);
                DLog(@"User id is %@",[[Global shared] currentUser]);
                
                if ([[[[Global shared] currentUser] user_id] integerValue] == [[dict objectForKey:@"sender_id"] integerValue]) {
                    
                    cd.cool = [[dict objectForKey:@"cool"] boolValue];
                    cd.share = [[dict objectForKey:@"share"] boolValue];
                    cd.contact = [[dict objectForKey:@"contact"] boolValue];
                }
                
                [DBManager save];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChannelSoftKeyUpdate" object:cd];
                completionHandler(UIBackgroundFetchResultNewData);
                
                return ;
            }
        }
        
        NSString *alertType = [dict objectForKey:@"alert"];
        if ([alertType isEqualToString:@"Received new template settings..!"]) {
            
            UserConfigurationSettings *userconfig =  [UserConfigurationSettings userWithId:[dict objectForKey:@"template_settings"] shouldInsert:YES];
            completionHandler(UIBackgroundFetchResultNewData);
            
            [DBManager save];
            return;
        }
        
        
           
        
        NSString *contentUrl =  [dict
                                 objectForKey:@"content_url"];
        NSString *length =  [dict
                             objectForKey:@"content_length"];
        NSString *contentId =  [dict
                                objectForKey:@"id"];
        NSString *channelId =  [dict
                                objectForKey:@"channel_id"];
        
        NSString *cool =  [dict
                           objectForKey:@"cool"];
        
        NSString *share =  [dict
                            objectForKey:@"share"];
        
        
        NSString *contact =  [dict
                              objectForKey:@"contact"];
        
        
        NSString *coolCount =  [dict
                                objectForKey:@"cool_count"];
        
        
        NSString *shareCount =  [dict
                                 objectForKey:@"share_count"];
        
        
        NSString *contactCount =  [dict
                                   objectForKey:@"contact_count"];
        
        NSInteger updatedTime;
        BOOL isFeedType = NO;
        if([[dict objectForKey:@"scheduler_type"] intValue] ==1)
        {
            isFeedType = YES;
            updatedTime = [[dict objectForKey:@"push_timestamp"] integerValue];
        }else
        {
            isFeedType = NO;
            updatedTime = [[dict objectForKey:@"created"] integerValue];
        }
        
        [self channelMsgReceived:contentUrl length:length contentId:contentId channelId:channelId cool:cool share:share contact:contact coolCount:coolCount shareCount:shareCount contactCount:contactCount chanelID:channelId isClickedOnPush:NO isCreatedTime:updatedTime typeOfFeed:isFeedType];
        
        NSString *channelPushId = [NSString stringWithFormat:@"%d",channelId.intValue];
        Channels *channeld = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:channelPushId];
        DLog(@"Channel id Is %@ and chann %@",channelId ,channeld);
        
        //  update the channel list if channel image is not existed or channel id not existed
        if (!channeld ||  [channeld.image isEqualToString:@""])
        {
            DLog(@"Channel not exist in the data base");
            [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                
               // [AppManager sendRequestToGetChannelList];
           }];
        }
        // manoj
        NSNumber *number = [NSNumber numberWithInteger:channeld.contentCount.integerValue];
        int value = [number intValue];
        number = [NSNumber numberWithInt:value + 1];
        channeld.contentCount = number;
        [DBManager save];
        [[NSNotificationCenter defaultCenter] postNotificationName:kchannelBadgeAdd object:nil];
        Global *shared = [Global shared];
        NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
        NSInteger unreadContentCount = [DBManager getUnreadChannelContentCount];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount)+_pushCount +_tabCount+unreadContentCount];
        completionHandler(UIBackgroundFetchResultNewData);
    }
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    DLog(@"failed to regiser %@", err);
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame{
    DLog(@"willChangeStatusBarFrame");
    if (!self.isCallProgress)
        [[NSNotificationCenter defaultCenter]postNotificationName:kStatusBarWillChange object:nil];
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame{
    DLog(@"didChangeStatusBarFrame");
    
    if (oldStatusBarFrame.size.height==20 ) {
        self.isCallProgress = true;
    }else{
        self.isCallProgress = false;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:kStatusBarWillChange object:nil];
}

#pragma mark - Private

+ (void)networkChange {
    [LoaderView addLoaderToView:[UIApplication sharedApplication].keyWindow];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // [[BLEManager sharedManager] restart];
        //code to be executed on the main queue after delay
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [LoaderView removeLoader];
        });
    });
}

- (UINavigationController *) getnavController:(UIViewController *) viewController {
    
    UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:viewController];
    return navController;
    
}

-(NSManagedObjectContext *)xyz
{
    NSManagedObjectContext *mContext;
    
    if([NSThread isMainThread])
    {
        mContext = [[CoreDataManager sharedManager] managedObjectContext];
    }
    else
    {
        mContext = [[CoreDataManager sharedManager] privateObjectContext];
    }
    return mContext;
}
#pragma mark - TopologyEventLogDelegate

- (void)hitEventLog:(NSString *)userid{
    
    if ([AppManager isInternetShouldAlert:NO])
    {
        //show loader...
        // [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
    }
}


@end
