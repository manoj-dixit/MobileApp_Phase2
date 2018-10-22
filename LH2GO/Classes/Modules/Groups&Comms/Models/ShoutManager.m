//
//  ShoutManager.m
//  LoudHailer
//
//  Created by Prakash Raj on 11/07/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "ShoutManager.h"
#import "ShoutInfo.h"
#import "DBManager.h"
#import "TimeConverter.h"
#import "BLEManager.h"
#import "LocationManager.h"
#import "SERVICES.h"
#import "NSData+Base64.h"
#import "CryptLib.h"
#import "CoreDataManager.h"
#import "AppDelegate.h"

@implementation ShoutManager

+ (instancetype)sharedManager {
    static ShoutManager *_shManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _shManager = [[ShoutManager alloc] init];
        
        [_shManager configure];
    });
    
    return _shManager;
}

// used to Unarchive the data by adding archive and Encryption

+ (id)obFromData:(NSData *)data
{
    NSString *iv = [PrefManager iv];
    NSString *key = [PrefManager key];
    // NSString *keyy = [[StringEncryption sharedManager]sha256:key length:32]; sonal
    NSData *finalData = [[StringEncryption sharedManager]decrypt:data key:key iv:iv];//keyy  to key
    return [NSKeyedUnarchiver unarchiveObjectWithData:finalData];
}

+(NSData *)decryptData:(NSData *)data
{
    NSString *iv = [PrefManager iv];
    NSString *key = [PrefManager key];
    NSData *finalData = [[StringEncryption sharedManager] decrypt:data key:key iv:iv];//keyy  to key
    return finalData;
}

+(NSString*)stringFromEncodedData:(NSData *)data{
    
    NSString *base64String = [[data subdataWithRange:NSMakeRange(0,data.length-3)] base64EncodedStringWithOptions:0];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    DLog(@"%@", decodedString);
    
    NSString *string;
    if (App_delegate.isEncryptionOn) {
        
        NSString *iv = @"MrbHw-zU63DzbD5G";
        NSString *key = @"029d58ed06c8a31f30458d9fb9e0aa90";
        NSString * reformedKey= [[StringEncryption alloc] md5:key];
        NSString *reformedIV = [[StringEncryption alloc] md5:iv];
        
        
        
        NSString *requiredStr= [decodedString substringToIndex:3];
        NSString *fixedStr;
        NSString *actualStr;
        if([requiredStr isEqualToString:@"000"]){
            fixedStr = [decodedString substringFromIndex:16];
            NSData *actuaData = [[NSData alloc] initWithBase64EncodedString:fixedStr options:0];
            actualStr = [[NSString alloc] initWithData:actuaData encoding:NSUTF8StringEncoding];
            DLog(@"%@", actualStr);
        }
        else{
            NSData *actuaData = [[NSData alloc] initWithBase64EncodedString:decodedString options:0];
            actualStr = [[NSString alloc] initWithData:actuaData encoding:NSUTF8StringEncoding];
            DLog(@"%@", actualStr);
        }
        
        
        NSString *str1 ;
        NSInteger i = reformedKey.length;
        NSInteger j = reformedIV.length;
        if(![actualStr isEqualToString:@""]){
            str1  = [actualStr substringFromIndex:i];
        }
        else{
            return nil;
        }
        string = [str1 substringToIndex:[str1 length] - j];
    }else
    {
        string = decodedString;
    }
    // NSString *str2 = [str1 substringFromIndex:j];
    NSData *convertedData = [[NSData alloc]initWithBase64EncodedString:string options:0];
    NSString *finaldecodedString = [[NSString alloc]initWithData:convertedData encoding:NSUTF8StringEncoding];
    
    return finaldecodedString;
}

+(NSData*)mediaFromEncodedData:(NSData *)data{
    
    NSString *base64String = [[data subdataWithRange:NSMakeRange(0, data.length-3)] base64EncodedStringWithOptions:0];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedEntireString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    NSString *string;
    NSString *str1;
    if (App_delegate.isEncryptionOn) {
        NSString *iv = @"MrbHw-zU63DzbD5G";
        NSString *key = @"029d58ed06c8a31f30458d9fb9e0aa90";
        NSString * reformedKey= [[StringEncryption alloc] md5:key];
        NSString *reformedIV = [[StringEncryption alloc]md5:iv];
        
        //    }
        //    else{
        //
        //        actualStr = decodedEntireString;
        //        NSLog(@"actualstr is %@",actualStr);
        //    }
        
        NSInteger i = reformedKey.length;
        NSInteger j = reformedIV.length;
        
        // NSString *str1 ;
        //NSString *requiredStr= [decodedEntireString substringToIndex:3];
        NSString *fixedStr;
        NSString *actualStr;
        //  if([requiredStr isEqualToString:@"CMS"]){
        fixedStr = [decodedEntireString substringFromIndex:16];
        NSData *actuaData = [[NSData alloc] initWithBase64EncodedString:decodedEntireString options:0];
        actualStr = [[NSString alloc] initWithData:actuaData encoding:NSUTF8StringEncoding];
        DLog(@"%@", actualStr);
        
        if(![actualStr isEqualToString:@""]){
            str1  = [actualStr substringFromIndex:i];
        }
        else{
            return nil;
        }
        string = [str1 substringToIndex:[str1 length] - j];
    }else
    {
        string = decodedEntireString;
    }
    
    NSData *nsdata = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *base64String1 = [nsdata base64EncodedStringWithOptions:0];
    DLog(@"base64String1 %@",base64String1);
    
    NSData *nsdataDecoded = [[NSData alloc] initWithBase64EncodedData:nsdata options:0];
    
    //  UIImage *image = [UIImage imageWithData:nsdataDecoded];
    
    return nsdataDecoded;
}

+ (NSData *)dataFromObjectForPing:(id)obj{
    NSMutableData *data = [NSMutableData dataWithData:BOMData()];
    NSData *aData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [data appendData:aData];
    [data appendData:EOMData()];
    return data;
}

// used to convert the shout into the data by adding archive and Encryption
+ (NSData *)dataFromObjectForShout:(id)obj
{
    if ([obj isKindOfClass:[ShoutInfo class]])
    {
        ShoutInfo *sh = (ShoutInfo*)obj;
        NSString *iv = [PrefManager iv];
        NSString *key = [PrefManager key];
        
        DLog(@"Shout Base Type is %ld",(long)sh.type);
        
        DLog(@"Shout text is %@",[sh shout].text);
        DLog(@"Shout content is %@",[sh shout].content);
        DLog(@"Shout timestamp is %ld",(long)[sh shout].timestamp);
        DLog(@"Shout Parent shid is %@",[sh shout].parent_shId);
        DLog(@"Shout  Media path is %@",[sh shout].mediaPath);
        
        
        DLog(@"Header SHout Id is %@",[sh header].shoutId);
        DLog(@"Header Owner Id is %@",[sh header].ownerId);
        DLog(@"Header Group Id is %@",[sh header].groupId);
        DLog(@"Header CMS duration Id is %@",[sh header].cmsDuration);
        DLog(@"Header Total Shout Length Id is %lu",(unsigned long)[sh header].totalShoutLength);
        DLog(@"Header Type Id is %ld",(long)[sh header].type);
        
        DLog(@"User Id is %@",[[Global shared] currentUser].user_id);
        
        NSString *networkId  = [[NSUserDefaults standardUserDefaults] objectForKey:Network_Id];
        
        // BOM Data
        NSMutableData *dataToBeSend  = [[NSMutableData alloc] init];
        // Add GroupId Data
        
        [dataToBeSend appendData:[AppManager dataFromHexString:[AppManager convertAStringIntoStringWithSixDigit:[AppManager ConvertMsgIdNumberTOHexString:[sh header].groupId]]]];
        
        // Add Network ID Data
        
        [dataToBeSend appendData:[AppManager dataFromHexString:networkId]];
        
        
        NSString *userName = [[[Global shared] currentUser] user_name];
        if (userName.length>12) {
            
            userName = [userName substringWithRange:NSMakeRange(0, 12)];
        }
        
        for (NSUInteger i = userName.length; i < 12 ; i++) {
            
            userName = [userName stringByAppendingString:@"$"];
        }
        
        // add user name data
        [dataToBeSend appendData:[userName dataUsingEncoding:NSUTF8StringEncoding]];
        
        // calculate ContentData Length
        
        // text data
        NSMutableData *contentData = [[NSMutableData alloc] init];
        NSData *textData  = [[NSString stringWithFormat:@"%@+||",[sh shout].text] dataUsingEncoding:NSUTF8StringEncoding];
        [contentData appendData:textData];
        
        // content data
        NSData *contentDataPart  = [sh shout].content;
        
        [contentData appendData:contentDataPart];
        
        // media path data
        if ([sh shout].mediaPath !=nil) {
            
            NSData *mediaPathData = [[NSString stringWithFormat:@"+||%@",[sh shout].mediaPath] dataUsingEncoding:NSUTF8StringEncoding];
            
            [contentData appendData:mediaPathData];
        }
        
        NSData *contentDataPartEncrypt = [[StringEncryption sharedManager]encrypt:contentData key:key iv:iv]; //keyy to key
        
        //  [dataToBeSend appendData:contentDataPartEncrypt];
        
        DLog(@"Content length is %lu",(unsigned long)[contentDataPartEncrypt length]);
        
        // Add Content Length
        [dataToBeSend appendData:[AppManager dataFromHexString:[AppManager ConvertMsgIdNumberTOHexString:[NSString stringWithFormat:@"%lu",(unsigned long)[contentDataPartEncrypt length]]]]];
        
        //        NSString *owner_Id  = [[NSUserDefaults standardUserDefaults] objectForKey:KOWNER_ID];
        
        // App DisplayTime
        int spcl = KAppDisplayTime;
        NSData *appDisplayTimeData =  [NSData dataWithBytes: &spcl length:3];
        
        [dataToBeSend appendData:appDisplayTimeData];
        
        
        [dataToBeSend appendData:[AppManager dataFromHexString:[AppManager convertAStringIntoStringWithSixDigit:[AppManager ConvertMsgIdNumberTOHexString:[sh header].ownerId]]]];
        
        
        [dataToBeSend appendData:contentDataPartEncrypt];
        
        [dataToBeSend appendData:EOMData()];
        
        return dataToBeSend;
        
        }
    return nil;
}

- (void)configure {
    _shouts = [[NSMutableArray alloc] init];
}

// due to sorting purpose.....
- (NSInteger)posToaddShout: (Shout *)newSh {
    /*
     int count = _shouts.count;
     for (int k = count-1; k>=0; k--) {
     ShoutInfo *oldSh = [_shouts objectAtIndex:k];
     if(oldSh.original_timestamp > newSh.original_timestamp) {
     [_shouts insertObject:newSh atIndex:k];
     return k;
     }
     }*/
    
    [_shouts addObject:newSh];
    return _shouts.count-1;
}
//shradha
- (void)insertShoutBasedOnHeader:(ShoutHeader*)header{
    dispatch_async(dispatch_get_main_queue(), ^{
        Shout *sht = [Shout shoutWithId:header.shoutId shouldInsert:YES];
        if (header.type == ShoutTypeImage || header.type == ShoutTypeAudio || header.type == ShoutTypeVideo || header.type == ShoutTypeGif) {
            sht.isShoutRecieved = @NO;
            {
                sht.group = [Group groupWithId:header.groupId shouldInsert:YES isP2PContact:NO isPendingStatus:NO];
                sht.groupId = sht.group.grId;
                sht.owner = [User userWithId:header.ownerId shouldInsert:YES];
                sht.type = @(header.type);
                sht.timestamp = [NSNumber numberWithInteger: [TimeConverter timeStamp]]; // time stamp at recieving end.
                sht.original_timestamp = sht.timestamp;
                NSString *str = [NSString stringWithFormat:@"%f,%f", [LocationManager latitude], [LocationManager longitude]];
                sht.location = str;
                if([sht.owner.isBlocked isEqualToNumber:[NSNumber numberWithInteger:1]]){
                    [DBManager deleteOb:sht];
                    
                }
                else{
                    [DBManager save];
                    [self notifyForNewShout:sht];
                    NSUInteger time = k_CoreptedShoutInterval;
                    if (header.type == ShoutTypeAudio) {
                        time = k_CoreptedShoutInterval/2;
                    }
                    else if (header.type == ShoutTypeGif) {
                        time = k_CoreptedShoutInterval/3;
                    }
                    else if (header.type == ShoutTypeImage) {
                        time = k_CoreptedShoutInterval/5;
                    }
                    
                    [sht performSelector:@selector(removeGarbageShout) withObject:nil afterDelay:time];
                }
                
            }
        }
        else{
            DLog(@"may bee");
            if(![sht.owner.isBlocked isEqualToNumber:[NSNumber numberWithInteger:1]]){
                [DBManager save];
            }
        }
    });
}

- (void)updateShoutBasedOnHeader:(ShoutDataReceiver*)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShoutProgressUpdate object:data userInfo:nil];
    });
}

- (void)clearInProgressGarbageShoutes{
    
    NSArray *shoutes = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970]-k_CoreptedShoutInterval;
    
    shoutes = [shoutes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.timestamp<%@ AND SELF.isShoutRecieved == 0", [NSNumber numberWithInteger:timeInMiliseconds]]];
    for(Shout *sht in shoutes){
        if(sht.isShoutRecieved.boolValue == NO && ([TimeConverter timeStamp] - [sht.timestamp integerValue])>KCellFadeOutDuration)
        {
            [sht removeGarbageShout];
        }
    }
}

- (void)clearInProgressGarbageShoute:(NSString*)shoutId{
    Shout *sht = [Shout shoutWithId:shoutId shouldInsert:NO];
    if(sht.isShoutRecieved.boolValue == NO && ([TimeConverter timeStamp] - [sht.timestamp integerValue])>KCellFadeOutDuration)
    {
        [sht removeGarbageShout];
    }
}

- (void)clearAllGarbageShoutes{
    NSArray *shoutes = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.isShoutRecieved == 0"];
    shoutes = [shoutes filteredArrayUsingPredicate:bPredicate];
    for(Shout *sht in shoutes){
        if(sht.isShoutRecieved.boolValue == NO && ([TimeConverter timeStamp] - [sht.timestamp integerValue])>KCellFadeOutDuration){
            [sht removeGarbageShout];
        }
    }
}

- (void)enqueueShout:(ShoutInfo *)sh forUpdation:(BOOL)isUpdate
{    
//    if(!App_delegate.queueToSaveReceiveData)
//    {
//        _queueToSaveReceiveData = [[NSOperationQueue alloc] init];
//        _queueToSaveReceiveData.maxConcurrentOperationCount = 1;
//        _queueToSaveReceiveData.qualityOfService = NSQualityOfServiceUtility;
//    }
    
    [App_delegate.queueToSaveReceiveData addOperationWithBlock:^{
        
        usleep(20000);
        
        if (!isUpdate&&(!isLoggedIn || [Shout isExistShoutId:sh.header.shoutId]))
            return;
        
        // check the groups in
        
        NSString *str = sh.header.groupId;
        NSString *newStr = [NSString stringWithFormat:@"%d", [str intValue]];
        DLog(@"clean value is %@",newStr);
        sh.header.groupId = newStr;
        
        if(sh.header.isP2pMsg)
        {
            int length = (UInt64)strtoull([[Global shared].currentUser.loud_hailerid UTF8String], NULL, 16);
            NSString *idd = [NSString stringWithFormat:@"%d",length];
            
            if([sh.header.groupId isEqualToString:idd])
            {
                int length = (UInt64)strtoull([sh.header.uniqueID UTF8String], NULL, 16);
                sh.header.groupId = [NSString stringWithFormat:@"%d",length];
            }
        }
        
        //sh.header.groupId = @"1";
        if (![DBManager isGroupsExistForGroupId:sh.header.groupId])
        {
            return;
        } // not for my group
        
        __block BOOL isNewContent = NO;
        
        [AppManager toCheckDuplicateContent:sh.header.shoutId EntityName:kEntityForCMSMessages Attribute_key_Id:kAttributeOfCMSMessagesForShout_Id CompletionBlock:^(BOOL success) {
            
            if (!success) {
                
                isNewContent = YES;
                
            }
        }];
        
//        if(sh.header.type ==7)
//        {
//            sh.header.type=1;
//        }else if (sh.header.type==8)
//        {
//            sh.header.type=2;
//        }else if (sh.header.type ==9)
//        {
//            sh.header.type=6;
//        }
        
        if (!isNewContent) {
            
            DLog(@"Duplicate contents");
            return;
        }
        
        if(sh == nil)
            return;
        Shout *sht = [Shout insertShoutInfo:sh isSender:NO];
        if (sht==nil) {
            return;
        }
        NSString *recId = [[[Global shared] currentUser] user_id];
        @try {
            
            sht.reciever = [User userWithId:recId shouldInsert:YES];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        //   Check if it is in backup mode
        if ([PrefManager shouldOpenSaved] == YES) {
            sht.isBackup = [NSNumber numberWithBool:[PrefManager isBackUpAlreadyInProcess]];
        }
        
        sht.synced = [NSNumber numberWithInt:0];
        
        if (sht.parent_shout) {
            sht.parent_shout.timestamp = sht.timestamp;
            [sht.parent_shout updateChieldShouts];
        }
        
        [sht updateAllUnlinkChieldShouts];
        
        sht.isShoutRecieved = @YES;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:sht selector:@selector(removeGarbageShout) object:nil];
        
        
        DLog(@"from here");
        
        if ([sht.type integerValue]==ShoutTypeTextMsg) {
            // [AppManager addShoutsOnServer:[NSArray arrayWithObject:sht]]; //sOnal 23 aug, 2017
        }
        else{
            //[AppManager addMediaShoutOnServer:sht];
        }
        // auto broadcast....
//        NSInteger userIdValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"blockedUser"];
//        if ([sht.owner.user_id integerValue] == userIdValue) {
//            sht.owner.isBlocked = [NSNumber numberWithInteger:1];
//        }
//        else{
//            sht.owner.isBlocked = [NSNumber numberWithInteger:0];
//        }

        if([sht.owner.isBlocked isEqualToNumber:[NSNumber numberWithInteger:1]]){
            [DBManager deleteOb:sht];
        }
        else{
            [DBManager save];
            [self notifyForNewShout:sht];
            [self autoRelay:sh];
        }
    }];
}

- (void)enqueueShoutForSender:(ShoutInfo *)sh forUpdation:(BOOL)isUpdate{
    
   // make a same queue for receiving and sending..
//    if(!_queueToSaveReceiveData)
//    {
//        _queueToSaveReceiveData = [[NSOperationQueue alloc] init];
//        _queueToSaveReceiveData.maxConcurrentOperationCount = 1;
//        _queueToSaveReceiveData.qualityOfService = NSQualityOfServiceUtility;
//    }
    
    [App_delegate.queueToSaveReceiveData addOperationWithBlock:^{
        
        usleep(20000);
        
        sh.header.shoutId = [NSString stringWithFormat:@"%d%d",[AppManager convertIntFromString:sh.header.shoutId],[AppManager convertIntFromString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID]]];
        DLog(@"sh.header.shoutId %@",sh.header.shoutId);
        
        if (!isUpdate&&(!isLoggedIn || [Shout isExistShoutId:sh.header.shoutId])) return;
        
        // check the groups in
        
        sh.header.ownerId = [[[Global shared] currentUser] user_id];
        
        NSString *str = sh.header.groupId;
        NSString *newStr = str;//[NSString stringWithFormat:@"%d", [str intValue]];
        
//        length = (UInt64)strtoull([hexString UTF8String], NULL, 16);
//        NSLog(@"The required Length is %d", length);

        
        DLog(@"clean value is %@",newStr);
        sh.header.groupId = newStr;
        
        //sh.header.groupId = @"1";
        if (![DBManager isGroupsExistForGroupId:sh.header.groupId])
        {
            return;
        } // not for my group
        
        
        Shout *sht = [Shout insertShoutInfo:sh isSender:YES];
        if (sht==nil) {
            return;
        }
        NSString *recId = [[[Global shared] currentUser] user_id];
        @try {
            
            sht.reciever = [User userWithId:recId shouldInsert:YES];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        //   Check if it is in backup mode
        if ([PrefManager shouldOpenSaved] == YES) {
            sht.isBackup = [NSNumber numberWithBool:[PrefManager isBackUpAlreadyInProcess]];
        }
        
        sht.synced = [NSNumber numberWithInt:0];
        
        if (sht.parent_shout) {
            sht.parent_shout.timestamp = sht.timestamp;
            [sht.parent_shout updateChieldShouts];
        }
        
        [sht updateAllUnlinkChieldShouts];
        
        sht.isShoutRecieved = @YES;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:sht selector:@selector(removeGarbageShout) object:nil];
        
        if([sht.owner.isBlocked isEqualToNumber:[NSNumber numberWithInteger:1]]){
            [DBManager deleteOb:sht];
        }
        else{
            [DBManager save];
            [self notifyForNewShout:sht];
            [self autoRelay:sh];
        }
        
        if ([sht.type integerValue]==ShoutTypeTextMsg) {
            //[AppManager addShoutsOnServer:[NSArray arrayWithObject:sht]];
        }
        else{
            [AppManager addMediaShoutOnServer:sht];
        }
      }
    ];
}


- (void)autoRelay:(ShoutInfo*)sh{
    if (sh.type == ShoutTypeTextMsg) {
        [sh performSelector:@selector(autoBroadcast) withObject:nil afterDelay:k_AutoBroadCastInterval];
    }
    else if(sh.type == ShoutTypeImage){
        [sh performSelector:@selector(autoBroadcast) withObject:nil afterDelay:k_AutoBroadCastInterval*1.25];
    }
    else if(sh.type == ShoutTypeGif){
        [sh performSelector:@selector(autoBroadcast) withObject:nil afterDelay:k_AutoBroadCastInterval*1.5];
    }
    else if(sh.type == ShoutTypeAudio){
        [sh performSelector:@selector(autoBroadcast) withObject:nil afterDelay:k_AutoBroadCastInterval*2.0];
    }
    else if(sh.type == ShoutTypeVideo){
        [sh performSelector:@selector(autoBroadcast) withObject:nil afterDelay:k_AutoBroadCastInterval*2.5];
    }
}

- (void)notifyForNewShout:(Shout *)sht
{
    DLog(@" ++ %d",(sht.parent_shout==nil&&sht.pShId.length>0));
    if (!(sht.parent_shout==nil&&sht.pShId.length>0)) {
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        
        //if app is in background and user is open the app by taping on app icon then it should display the badge icon on group cell UI, BUT NOT SHOW BANNERALERT >> ALOK
        NSDictionary* userInfo = @{kShouldShowBanner: [NSNumber numberWithBool:0]};
        
        if(state != UIApplicationStateBackground) {
            BOOL showBanner = [PrefManager isNotfOn];
            if(showBanner){
                userInfo = @{kShouldShowBanner: [NSNumber numberWithBool:1]};
                
            }
            else{
                userInfo = @{kShouldShowBanner: [NSNumber numberWithBool:0]};
                
            }
            // insert shout to DB
            dispatch_async(dispatch_get_main_queue(), ^{
                [sht trackMe:sht];
                //            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInteger:pos], @"indexPos", nil];
                //                NSLog(@"group id %@",sht.groupId);
                //                NSLog(@"text is %@",sht.text);
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewShoutEncounter object:sht userInfo:userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewShoutEncounterTemp object:sht userInfo:userInfo];
            });
        } else if([PrefManager isNotfOn]) {
            // fire local notification (log will not work).
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            NSDictionary *userDict;
            if (sht != nil) {
                userDict  = [NSDictionary dictionaryWithObject:sht.shId forKey:kShoutObjFromNotification];
                notif.userInfo = userDict;
            }
            
            notif.alertAction = @"view";
            
            NSString *msg = sht.text;
            
            NSString *userName;
            if ([sht.owner.user_name isKindOfClass:[NSNull class]] || [sht.owner.user_name isEqualToString:@""] || sht.owner.user_name == nil) {
                userName = @"Unknown";
            }else
                userName = sht.owner.user_name;
            
            if (msg.length==0) {
                if (sht.type.integerValue == ShoutTypeImage || sht.type.integerValue == ShoutTypeGif) {
                    
                    notif.alertBody = [NSString stringWithFormat:@"%@: %@", userName, k_MediaFileReceived];
                    
                } else if(sht.type.integerValue==ShoutTypeVideo){
                    notif.alertBody = [NSString stringWithFormat:@"%@: %@", userName, k_MediaFileReceived];
                }
                else if(sht.type.integerValue == ShoutTypeAudio){
                    notif.alertBody = [NSString stringWithFormat:@"%@: %@", userName, k_MediaFileReceived];
                }
            }else{
                notif.alertBody = [NSString stringWithFormat:@"%@: %@", userName, sht.text];
                
            }
            
            [sht.group upBadge];
            
            notif.soundName = UILocalNotificationDefaultSoundName;
            
            userInfo = @{kShouldShowBanner: [NSNumber numberWithBool:0]};
            dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewShoutEncounter object:sht userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewShoutEncounterTemp object:sht userInfo:userInfo];
           
            [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
            
            //NSInteger countNotif = [AppManager getUnreadNotification];
                Global *shared =[Global shared];
                NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];            NSInteger unreadContents = [DBManager getUnreadChannelContentCount];

            if(sht!=nil){
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount+unreadContents)];
                
            }
            else{
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount+unreadContents)];
            }
            });
        }
    }
}


- (void)dequeueShout:(Shout *)sh {
    // [[NSNotificationCenter defaultCenter] postNotificationName:kShoutDead object:sh userInfo:nil];
}

@end
