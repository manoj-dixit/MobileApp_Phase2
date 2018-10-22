//
//  ShoutBackup.m
//  LH2GO
//
//  Created by Sumit Kumar on 24/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "ShoutBackup.h"
#import "Shout.h"
#import "CoreDataManager.h"
#import "TimeConverter.h"
#import "Common.h"

@implementation ShoutBackup

@dynamic backUpDate;
@dynamic backupId;
@dynamic backupName;
@dynamic backupNote;
@dynamic synced;
@dynamic backupShouts;
@dynamic edited;
@dynamic downloaded;
+ (ShoutBackup *)addUserWithDict:(NSDictionary *)dict
{
    ShoutBackup*bck;
  //  NSString*aStr;
    //aStr = [dict objectForKey:@"bk_name"];
   // aStr = [dict objectForKey:@"bk_note"];
    return bck;
}

+ (ShoutBackup *)isAlreadyShoutBackupWithName:(NSString *)backupName
{
    NSString *predStr = [NSString stringWithFormat:@"ANY backupName LIKE[c] \'%@\'", backupName];
    NSArray *records = [DBManager entities:@"ShoutBackup" pred:predStr descr:nil isDistinctResults:NO];
    if (records.count) return [records firstObject];
    return nil;
}

// get ShoutBackup
+ (ShoutBackup *)ShoutBackupWithId:(NSString *)backupId shouldInsert:(BOOL)insert
{
    //  NSString *myString = [backup_Id stringValue];
    ShoutBackup *ShtBackup = [DBManager entity:@"ShoutBackup" idName:@"backupId" idValue:backupId];
    if (!insert) return ShtBackup;
    if (!ShtBackup)
    {
        ShtBackup = [CoreDataManager insertObjectFor:@"ShoutBackup"];
        ShtBackup.synced = [NSNumber numberWithBool:NO];
        ShtBackup.backupId = backupId;
        [CoreDataManager saveContext];
    }
    return ShtBackup;
}

+ (void)addShoutBackupWithDict:(NSDictionary *)dict
{
    NSString *bkId = [dict valueForKey:@"id"];
    NSString *bkName = [dict valueForKey:@"backup_name"];
    NSString *bkNote = [dict valueForKey:@"backup_note"];
    NSString *dateFromServer = [dict valueForKey:@"backup_date"];
    if ([dateFromServer isEqual:[NSNull null]])//in case server is returning null show current date
    {
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        dateFromServer = [NSString stringWithFormat:@"%f", timeInMiliseconds];
    }
    NSTimeInterval timestamp = dateFromServer.doubleValue ;
    NSDate* dateLocal = [Common localDateFromTimeStamp:timestamp];
    ShoutBackup *bck = [ShoutBackup ShoutBackupWithId:bkId shouldInsert:YES];
    bck.backUpDate = dateLocal;
    bck.backupName = bkName;
    if ([bkNote isEqual:[NSNull null]] == FALSE && bkNote.length > 0)
    {
        bck.backupNote = bkNote;
    }
    else
    {
        bck.backupNote = @"";
    }
    bck.synced = [NSNumber numberWithBool:YES];
    [DBManager save];
}

@end
