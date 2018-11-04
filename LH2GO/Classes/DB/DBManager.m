//
//  DBManager.m
//  LoudHailer
//
//  Created by Prakash Raj on 18/08/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "DBManager.h"
#import "CoreDataManager.h"
#import "TimeConverter.h"
#import "SDImageCache.h"
#import "User.h"
#import "NotificationInfo.h"
#import "EmailedUser.h"
#import "Common.h"
#import "ShoutManager.h"

@implementation DBManager

+ (id)entity:(NSString *)entityName idName:(NSString *)idName idValue:(NSString *)idValue
{
    NSString *predStr = [NSString stringWithFormat:@"%@=%@", idName, idValue];
    NSArray *records = [DBManager entities:entityName pred:predStr descr:nil isDistinctResults:NO];
    if (records.count) return [records firstObject];
    return nil;
}

+ (id)entityWithStr:(NSString *)entityName idName:(NSString *)idName idValue:(NSString *)idValue
{
    NSString *predStr = [NSString stringWithFormat:@"%@=\"%@\"", idName, idValue];
    NSArray *records = [DBManager entities:entityName pred:predStr descr:nil isDistinctResults:NO];
    if (records.count) return [records firstObject];
    return nil;
}

+ (id)entityWithStr:(NSString *)entityName idName:(NSString *)idName idList:(NSArray*)list
{
    NSString *predStr = [NSString stringWithFormat:@"countryName=\"%@\"", idName];
    NSArray *records = [DBManager entities:entityName pred:predStr descr:nil isDistinctResults:NO];
    if (records.count) return [records firstObject];
    return nil;
}

+ (NSArray *)entityWithStr:(NSString *)entityName idName:(NSString *)idName idValueFor:(NSString *)idValue
{
    NSString *predStr = [NSString stringWithFormat:@"%@=\"%@\"", idName, idValue];
    NSArray *records = [DBManager entities:entityName pred:predStr descr:nil isDistinctResults:NO];
    if (records.count) return records;
    return nil;
}

+ (id)entityWithPredicate:(NSString *)entityName idName:(NSString *)idName idValue:(NSString *)idValue
{
    NSString *predStr = [NSString stringWithFormat:@"%@ CONTAINS[c] '%@'", idName, idValue];
    NSArray *records = [DBManager entities:entityName pred:predStr descr:nil isDistinctResults:NO];
    if (records.count) return [records firstObject];
    return nil;
}

+ (NSArray *)entities: (NSString *)entityName1 pred: (NSString *)pred1 descr: (NSSortDescriptor *)desc isDistinctResults:(BOOL)distinct
{
    NSString *pred = [pred1 copy];
    NSString *entityName = [entityName1 copy];
    
    @synchronized (self)
    {
        NSManagedObjectContext *mContext = [App_delegate xyz];
        
        objc_sync_enter(mContext);

        __block NSArray *recordsV;
        __block NSArray *recordsUpdate;

        __block BOOL isOnMainThread = NO;

        [mContext performBlockAndWait:^{
            
                NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init]; // fetchRequest
                fetchReq.returnsDistinctResults = distinct;
                [fetchReq setReturnsObjectsAsFaults:NO];
                // Setting Entity to be Queried
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mContext];
                [fetchReq setEntity:entity];
                if (pred)
                {
                    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"]invertedSet];
                    //NSLog(@"pred%@",pred);
                    if ([pred rangeOfCharacterFromSet:set].location == NSNotFound) {
                        DLog(@"coming in this area");
                    }
            
                    @try {
            
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:pred];
                        [fetchReq setPredicate:predicate];
            
                    } @catch (NSException *exception) {
            
                        NSLog(@"Exception is %@",exception);
            
                    } @finally {
            
                    }

                }
                if (desc)
                {
                    NSArray *sortDescriptors = @[[desc copy]];
                    [fetchReq setSortDescriptors:sortDescriptors];
                }
                // Query on managedObjectContext With Generated fetchRequest
                 NSError* error;
                 
                @try
                {
                    @synchronized (self)
                    {
                        NSArray *records = [recordsV copy];
//                        if([mContext executeFetchRequest:fetchReq error:&error] != nil)
                        records = [mContext executeFetchRequest:fetchReq error:&error];
                        recordsUpdate =  [records copy];
                        objc_sync_exit(mContext);
                        }
                }
                @catch (NSException *exception) {
                    objc_sync_exit(mContext);
                }
                @finally {
                }
        }];
        return recordsUpdate;
    }
    return nil;
}

+ (NSArray *)entitiesToSaveChannelData: (NSString *)entityName1 pred: (NSString *)pred1 descr: (NSSortDescriptor *)desc isDistinctResults:(BOOL)distinct
{
    NSString *pred = [pred1 copy];
    NSString *entityName = [entityName1 copy];
    
    @synchronized (self)
    {
        NSManagedObjectContext *mContext = [App_delegate xyz];
        
        objc_sync_enter(mContext);
        
        __block NSArray *recordsV;
        __block NSArray *recordsUpdate;
        
        __block BOOL isOnMainThread = NO;
        
        [mContext performBlockAndWait:^{
            
            NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init]; // fetchRequest
            fetchReq.returnsDistinctResults = distinct;
            [fetchReq setReturnsObjectsAsFaults:NO];
            // Setting Entity to be Queried
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mContext];
            [fetchReq setEntity:entity];
            if (pred)
            {
                NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"]invertedSet];
                //NSLog(@"pred%@",pred);
                if ([pred rangeOfCharacterFromSet:set].location == NSNotFound) {
                    DLog(@"coming in this area");
                }
                
                @try {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:pred];
                    [fetchReq setPredicate:predicate];
                    
                } @catch (NSException *exception) {
                    
                    NSLog(@"Exception is %@",exception);
                    
                } @finally {
                    
                }
                
            }
            if (desc)
            {
                NSArray *sortDescriptors = @[[desc copy]];
                [fetchReq setSortDescriptors:sortDescriptors];
            }
            // Query on managedObjectContext With Generated fetchRequest
            NSError* error;
            
            @try
            {
                @synchronized (self)
                {
                    NSArray *records = [recordsV copy];
                    //                        if([mContext executeFetchRequest:fetchReq error:&error] != nil)
                    records = [mContext executeFetchRequest:fetchReq error:&error];
                    recordsUpdate =  [records copy];
                    objc_sync_exit(mContext);
                }
            }
            @catch (NSException *exception) {
                objc_sync_exit(mContext);
            }
            @finally {
            }
        }];
        return recordsUpdate;
    }
    return nil;
}

+(NSArray *)entitiesForScheduled: (NSString *)entityName1 pred: (NSString *)pred1 descr: (NSSortDescriptor *)desc isDistinctResults:(BOOL)distinct
{
    NSString *pred = [pred1 copy];
    NSString *entityName = [entityName1 copy];
    
    @synchronized (self)
    {
        NSManagedObjectContext *mContext = [App_delegate xyz];
        
        objc_sync_enter(mContext);
        
        __block NSArray *recordsV;
        __block NSArray *recordsUpdate;
        
        __block BOOL isOnMainThread = NO;
        
        [mContext performBlockAndWait:^{
            
            NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init]; // fetchRequest
            fetchReq.returnsDistinctResults = distinct;
            [fetchReq setReturnsObjectsAsFaults:NO];
            // Setting Entity to be Queried
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mContext];
            [fetchReq setEntity:entity];
            if (pred)
            {
                NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"]invertedSet];
                //NSLog(@"pred%@",pred);
                if ([pred rangeOfCharacterFromSet:set].location == NSNotFound) {
                    DLog(@"coming in this area");
                }
                
                @try {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:pred];
                    [fetchReq setPredicate:predicate];
                    
                } @catch (NSException *exception) {
                    
                    NSLog(@"Exception is %@",exception);
                    
                } @finally {
                    
                }
                
            }
            if (desc)
            {
                NSArray *sortDescriptors = @[[desc copy]];
                [fetchReq setSortDescriptors:sortDescriptors];
            }
            // Query on managedObjectContext With Generated fetchRequest
            NSError* error;
            
            @try
            {
                @synchronized (self)
                {
                    NSArray *records = [recordsV copy];
                    //                        if([mContext executeFetchRequest:fetchReq error:&error] != nil)
                    records = [mContext executeFetchRequest:fetchReq error:&error];
                    recordsUpdate =  [records copy];
                    objc_sync_exit(mContext);
                }
            }
            @catch (NSException *exception) {
                objc_sync_exit(mContext);
            }
            @finally {
            }
        }];
        return recordsUpdate;
    }
    return nil;
}

+ (NSArray *)entitiesByArrayDesc: (NSString *)entityName1 pred: (NSString *)pred1 arrayOfDesc: (NSArray *)descArr isDistinctResults:(BOOL)distinct
{
    NSString *pred = [pred1 copy];
    NSString *entityName = [entityName1 copy];
    
    @synchronized (self)
    {
        NSManagedObjectContext *mContext = [App_delegate xyz];
        
        objc_sync_enter(mContext);
        //NSLog(@"Manoj DIxit ++ Lock");
        
        __block NSArray *recordsV;
        __block NSArray *recordsUpdate;
        
        __block BOOL isOnMainThread = NO;
        
        [mContext performBlockAndWait:^{
            
            NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init]; // fetchRequest
            fetchReq.returnsDistinctResults = distinct;
            [fetchReq setReturnsObjectsAsFaults:NO];
            // Setting Entity to be Queried
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mContext];
            [fetchReq setEntity:entity];
            if (pred)
            {
                NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"]invertedSet];
                //NSLog(@"pred%@",pred);
                if ([pred rangeOfCharacterFromSet:set].location == NSNotFound) {
                    DLog(@"coming in this area");
                }
                
                @try {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:pred];
                    [fetchReq setPredicate:predicate];
                    
                } @catch (NSException *exception) {
                    
                    NSLog(@"Exception is %@",exception);
                    
                } @finally {
                    
                }
                
            }
            if (descArr)
            {
                //NSArray *sortDescriptors = @[[desc copy]];
                [fetchReq setSortDescriptors:descArr];
            }
            // Query on managedObjectContext With Generated fetchRequest
            NSError* error;
            
            @try
            {
                @synchronized (self)
                {
                    NSArray *records = [recordsV copy];
                    //                        if([mContext executeFetchRequest:fetchReq error:&error] != nil)
                    records = [mContext executeFetchRequest:fetchReq error:&error];
                    recordsUpdate =  [records copy];
                    objc_sync_exit(mContext);
                }
            }
            @catch (NSException *exception) {
                objc_sync_exit(mContext);
            }
            @finally {
            }
        }];
        return recordsUpdate;
    }
    return nil;
}



+ (void)deleteOb:(NSManagedObject *)obj
{
    NSManagedObjectContext *mContext;
    if([NSThread isMainThread])
    {
        mContext = [[CoreDataManager sharedManager] managedObjectContext];
        [mContext deleteObject:obj];
        [CoreDataManager saveContext];
    }
    else
    {
        mContext = [[CoreDataManager sharedManager] privateObjectContext];
        [mContext deleteObject:obj];
        [CoreDataManager saveContext];
    }
 }

#pragma mark - get objects

+ (NSArray *)usersSorted:(BOOL)sorted
{
    NSArray *list = [DBManager entities:@"User" pred:nil descr:nil isDistinctResults:NO];
    if (!sorted) return list;
    list = [list sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_name" ascending:YES]]];
    return list;
}

+ (NSArray *)usersSorted:(BOOL)sorted notInGroup:(Group*)group
{
    NSArray *list = [DBManager entities:@"User" pred:nil descr:nil isDistinctResults:YES];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"NOT SELF.groups contains[cd] %@", group];
    list = [list filteredArrayUsingPredicate:bPredicate];
    bPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", group.pendingUsers];
    list = [list filteredArrayUsingPredicate:bPredicate];
    list = [list sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_name" ascending:YES]]];
    return list;
}

+ (NSArray *)usersSortedInForLH2GONetwork:(BOOL)sorted notInGroup:(Group*)group
{
    NSArray *list = group.network.users.allObjects;
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"NOT SELF.groups contains[cd] %@", group];
    list = [list filteredArrayUsingPredicate:bPredicate];
    bPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", group.pendingUsers];
    list = [list filteredArrayUsingPredicate:bPredicate];
    list = [list sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_name" ascending:YES]]];
    return list;
}

+ (NSArray *)getAllFavouriteShouts
{
    NSArray *favlist = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.favorite>=1"];
    favlist = [favlist filteredArrayUsingPredicate:bPredicate];
    favlist = [favlist sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"original_timestamp" ascending:NO]]];
    return favlist;
}

+ (NSArray *)getAllFavouriteChieldShouts:(Shout*)shout
{
    NSArray *childlist = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.parent_shout=%@", shout];
    childlist = [childlist filteredArrayUsingPredicate:bPredicate];
    return childlist;
}

+ (void)save
{
    [CoreDataManager saveContext];
}

+ (void)deleteUsers:(NSArray *)array fromGroup:(Group *)group
{
   __block NSError *error = nil;
    NSManagedObjectContext *context;
    if([NSThread isMainThread])
    {
        context = [[CoreDataManager sharedManager] managedObjectContext];
        NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: context]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id IN %@", array];
        [fetch setPredicate:predicate];
        
        NSArray * records = [context executeFetchRequest:fetch error:&error];
        
        for (NSManagedObject * record in records)
        {
            User *usr = (User *)record;
            [usr removeGroupsObject:group];
        }
        [group removeUsers:[NSSet setWithArray:records]];
        [CoreDataManager saveContext];
    }
    else
    {
        context = [[CoreDataManager sharedManager] privateObjectContext];
        
        [context performBlockAndWait:^{
            
            NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
            [fetch setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: context]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id IN %@", array];
            [fetch setPredicate:predicate];
            
            
            
            NSArray * records = [context executeFetchRequest:fetch error:&error];
            
            for (NSManagedObject * record in records)
            {
                User *usr = (User *)record;
                [usr removeGroupsObject:group];
            }
            [group removeUsers:[NSSet setWithArray:records]];
            [CoreDataManager saveContext];
        }];
    }
}

+ (void)addUsers:(NSArray *)users toGroup:(Group*)group
{
    for (User *usr in users)
    {
        [usr addGroupsObject:group];
    }
    [group addUsers:[NSSet setWithArray:users]];
    [CoreDataManager saveContext];
}

+ (void)addInvitedUsers:(NSArray *)users toGroup:(Group*)group
{
    [group addPendingUsers:[NSSet setWithArray:users]];
    for(User *usr in users)
    {
        [usr addPendingGroupsObject:group];
    }
    [CoreDataManager saveContext];
}

+ (void)addEmailedUsers:(NSArray *)users toGroup:(Group*)group
{
    for(NSString *email in users)
    {
        EmailedUser *emailUser = [EmailedUser emailUserWithEmailId:email shouldInsert:YES];
        emailUser.groupId = group.grId;
        emailUser.user_id = [Global shared].currentUser.user_id;
    }
    [CoreDataManager saveContext];
}

+ (void)clearMyData
{
    [DBManager deleteAllFromEntity:@"Network"];
    [DBManager deleteAllFromEntity:@"Group"];
    [DBManager deleteAllFromEntity:@"Notifications"];
    [DBManager deleteAllFromEntity:@"User"];
    [DBManager deleteAllFromEntity:@"EmailedUser"];
    [DBManager deleteAllFromEntity:@"Shout"];
    [DBManager deleteAllFromEntity:@"ShoutBackup"];
    [DBManager deleteAllFromEntity:@"Channels"];
    [DBManager deleteAllFromEntity:@"ChannelDetail"];
    [DBManager deleteAllFromEntity:@"EventLog"];

    [PrefManager setAlreadyDownloadedServerData:NO];
    [PrefManager setAlreadyDownloadedServerDataFav:NO];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    
    // method is used to delete the previous stored Image
    [self deletetheStoreImage];
}

+(void)deletetheStoreImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
    NSArray *directoryContent;
    directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory  error:&error];
    
    DLog(@"Count of Array before Deletion %lu",(unsigned long)directoryContent.count);
    
    [directoryContent enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        DLog(@" Value + %@",obj);
        NSString *statatusss = obj;
        NSString *extensionOfFile = [[statatusss componentsSeparatedByString:@"."] lastObject];
        DLog(@" Value + %@",[[statatusss componentsSeparatedByString:@"."] lastObject]);
        
        if ([extensionOfFile isEqualToString:@"png"] || [extensionOfFile isEqualToString:@"gif"])
        {
            @try {
                // Delete log file for previous date
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", statatusss]];
                NSError *error;
                BOOL isSucees = [fileManager removeItemAtPath:filePath error:&error];
                if (isSucees){
                    DLog(@"Sucessfully deleted data file");
                    //*stop = YES;
                }else{
                    DLog(@"Failed to delete data file due to error %@",error.localizedDescription);
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }];
}

+ (void)clearMyDataOnBackgroundRefresh
{
    [DBManager clearGroupsReleations];
    [DBManager clearUserReleations];
}

+ (void)clearGroupsReleations
{
    NSArray *groups = [DBManager entities:@"Group" pred:nil descr:nil isDistinctResults:NO];
    for(Group *grp in groups)
    {
        [grp setPendingUsers:[NSSet new]];
        [grp setUsers:[NSSet new]];
    }
    [DBManager save];
}


+ (void)clearUserReleations
{
    NSArray *users = [DBManager entities:@"User" pred:nil descr:nil isDistinctResults:NO];
    for(User *usr in users)
    {
        [usr setGroups:[NSSet new]];
        [usr setPendingGroups:[NSSet new]];
        [usr setOwnedGroups:[NSSet new]];
        [usr setNetworks:[NSSet new]];
    }
    [DBManager save];
}

+ (void) deleteAllFromEntity:(NSString *)entityName
{
    NSManagedObjectContext *managedObjectContext;
    if([NSThread isMainThread])
    {
        managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
        NSFetchRequest * allRecords = [[NSFetchRequest alloc] init];
        [allRecords setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
        [allRecords setIncludesPropertyValues:NO];
        NSError * error = nil;
        NSArray * result = [managedObjectContext executeFetchRequest:allRecords error:&error];
        for (NSManagedObject * profile in result)
        {
            [managedObjectContext deleteObject:profile];
        }
        NSError *saveError = nil;
        [managedObjectContext save:&saveError];
    }
    else
    {
        managedObjectContext = [[CoreDataManager sharedManager] privateObjectContext];
        [managedObjectContext performBlockAndWait:^{
            
            NSFetchRequest * allRecords = [[NSFetchRequest alloc] init];
            [allRecords setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
            [allRecords setIncludesPropertyValues:NO];
            NSError * error = nil;
            NSArray * result = [managedObjectContext executeFetchRequest:allRecords error:&error];
            for (NSManagedObject * profile in result)
            {
                [managedObjectContext deleteObject:profile];
            }
            NSError *saveError = nil;
            [managedObjectContext save:&saveError];
        }];
    }
}

+ (NSArray *)getNetworks
{
    User *user = [[Global shared] currentUser];
    NSArray *nets = user.networks.allObjects;
    nets = [nets sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]]];
    return nets;
}

// release me all latest shout, their lifeline left.
+ (NSArray *)latestShouts
{
    __block NSArray *records;
    NSManagedObjectContext *mContext;
    if([NSThread isMainThread])
    {
        mContext = [[CoreDataManager sharedManager] managedObjectContext];
        // initializing NSFetchRequest
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        //Setting Entity to be Queried
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shout" inManagedObjectContext:mContext];
        [fetchReq setEntity:entity];
        // set condition (predicate).
        int currentTimeStamp = (int) [TimeConverter timeStamp]-k_TrackTime*5;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"time_stamp > %d", currentTimeStamp]];
        [fetchReq setPredicate:predicate];
        // [fetchReq setFetchLimit:1];
        /* -----Not required for now.
         // sorting (by originated time)
         NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"original_timestamp" ascending:YES];
         NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByTime, nil];
         [fetchReq setSortDescriptors:sortDescriptors];
         */
        NSError* error;
        // Query on managedObjectContext With Generated fetchRequest
        records = [mContext executeFetchRequest:fetchReq error:&error];
}
    else
    {
        mContext = [[CoreDataManager sharedManager] privateObjectContext];
        [mContext performBlockAndWait:^{
            
            // initializing NSFetchRequest
            NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
            //Setting Entity to be Queried
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shout" inManagedObjectContext:mContext];
            [fetchReq setEntity:entity];
            // set condition (predicate).
            int currentTimeStamp = (int) [TimeConverter timeStamp]-k_TrackTime*5;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"time_stamp > %d", currentTimeStamp]];
            [fetchReq setPredicate:predicate];
            // [fetchReq setFetchLimit:1];
            /* -----Not required for now.
             // sorting (by originated time)
             NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"original_timestamp" ascending:YES];
             NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByTime, nil];
             [fetchReq setSortDescriptors:sortDescriptors];
             */
            NSError* error;
            // Query on managedObjectContext With Generated fetchRequest
            records = [mContext executeFetchRequest:fetchReq error:&error];
        }];
    }
  
    return records;
}

//get all notification whose type is NotfType_nonAdmingroupInvite or NotfType_groupInvite
+(NSArray *)getArrayOfActionableNotifications
{
    NSArray *arrActivity = [[Global shared] activities];
    arrActivity = [arrActivity filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"_type = %d OR _type = %d", NotfType_nonAdmingroupInvite, NotfType_groupInvite]];//NotfType_groupInvite
    return arrActivity;
}

+ (NSArray *)getShortedGroupsForNetwork:(Network*)net
{
    NSArray *groups = [DBManager entities:@"Group" pred:nil descr:nil isDistinctResults:YES];
    NSArray *records = [groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.network = %@", net]];
    records = [records sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]]];
    return records;
}

+ (NSArray *)getAllNotifications
{
    NSArray *groups = [DBManager entities:@"Notifications" pred:nil descr:nil isDistinctResults:YES];
    NSArray *records = [groups sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    return records;
}

+ (NSArray *)getChannelsForNetwork:(Network*)net{
    
    NSArray *channels = [DBManager entities:@"Channels" pred:nil descr:nil isDistinctResults:YES];
    NSArray *records;
    if(channels.count > 0)
    {
        records = [channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.network = %@ && SELF.type = %@", net,[PrefManager defaultUserSelectedCityId]]];
    }
    return records;
    
}

+(NSArray *)getChannelDataFromNameAndId:(NSString *)nameOrId isName:(BOOL)name Network:(Network*)net
{
    NSArray *channels = [DBManager entities:@"Channels" pred:nil descr:nil isDistinctResults:YES];
    NSArray *records;
    if (name) {
        // if query if for getting the name
    if(channels.count > 0)
    {
        records = [channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.network = %@ && SELF.channelId = %@", net,nameOrId]];
    }
        else
        {
            DLog(@"No data found for that Channel id");
        }
    }
    else
    {
        // if query is for getting the channel id
        if(channels.count > 0)
        {
            records = [channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.network = %@ && SELF.name = %@", net,nameOrId]];
        }
        else
        {
            DLog(@"No data found for that Channel id");
        }
    }
    return records;
}

+(NSArray *)getChannelDataFromFromContentID:(NSString *)contentID Network:(Network*)net
{
    NSArray *channels = [DBManager entities:@"ChannelDetail" pred:nil descr:nil isDistinctResults:YES];
    NSArray *records;
        // if query if for getting the name
        if(channels.count > 0)
        {
            records = [channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.contentId = %@",contentID]];
        }
        else
        {
            DLog(@"No data found for that Channel id");
        }
    return records;
}


+ (BOOL)isGroupsExistForGroupId:(NSString*)groupId
{
    NSArray *groups = [DBManager entities:@"Group" pred:nil descr:nil isDistinctResults:NO];
    NSArray *records =[groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.grId=%@", groupId]];
    return (records.count>0);
}

+ (NSArray*)getPendingEmailUsers:(Group*)group
{
    NSArray *emailUsers = [DBManager entities:@"EmailedUser" pred:[NSString stringWithFormat:@"groupId='%@' AND user_id='%@'", group.grId, [Global shared].currentUser.user_id] descr:nil isDistinctResults:NO];
    return emailUsers;
}

//This function giving all backups non synced
+ (NSArray *)getUnSyncedBackUps
{
    NSArray *list = [DBManager entities:@"ShoutBackup" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.synced=NO"];
    list = [list filteredArrayUsingPredicate:bPredicate];
    return list;
}

//This function giving all backups non synced
+ (NSArray *)getUnSyncedFavShouts
{
    NSArray *list = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.synced!=2"];
    list = [list filteredArrayUsingPredicate:bPredicate];
    return list;
}

//This function giving all backups which are synced
+ (NSArray *)getSyncedBackUps
{
    NSArray *list = [self getAllBackUps];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.synced=YES"];
    list = [list filteredArrayUsingPredicate:bPredicate];
    return list;
}

//This function giving all backups
+(NSArray *)getAllBackUps
{
    NSArray *list = [DBManager entities:@"ShoutBackup" pred:nil descr:[NSSortDescriptor sortDescriptorWithKey:@"backUpDate" ascending:NO] isDistinctResults:NO];
    return list;
}

//This function giving all shouts marked back ups(Not For Specific Group)
+ (NSArray *)getAllShoutsForBackup:(BOOL)sorted
{
    NSArray *list = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    if (!sorted) return list;
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.isBackup=YES"];
    list = [list filteredArrayUsingPredicate:bPredicate];
    list = [list sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"shId" ascending:YES]]];
    return list;
}

+(BOOL)isSyncedShouts
{
    BOOL isSyncedShouts = YES;
    NSArray *listUnSyncedShouts =[self getUnsyncedShouts];
    NSPredicate *bPredicate =[NSPredicate predicateWithFormat:@"SELF.synced!=2"];
    listUnSyncedShouts = [listUnSyncedShouts filteredArrayUsingPredicate:bPredicate];
    if (listUnSyncedShouts.count>0)
    {
        isSyncedShouts = NO;
    }else
        isSyncedShouts = YES;

    return isSyncedShouts;
}

+(BOOL)isSyncedShoutsBackUp
{
    BOOL isSyncedbackUp = YES;
    NSArray *listUnsyncedbackUp =[self getUnSyncedBackUps];
    NSPredicate *bPredicate =[NSPredicate predicateWithFormat:@"SELF.synced == 0"];
    listUnsyncedbackUp = [listUnsyncedbackUp filteredArrayUsingPredicate:bPredicate];
    if (listUnsyncedbackUp.count>0)
    {
        isSyncedbackUp = NO;
    }else
        isSyncedbackUp = YES;

    return isSyncedbackUp;
}

+(BOOL)isSyncedShoutsAndShoutsBackUp
{
    if ([self isSyncedShouts] && [self isSyncedShoutsBackUp] == YES)
    {
        return YES;
    }
    return NO;
}

+(NSArray *)getUnsyncedShouts
{
    NSArray *list = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.synced!=2"];
    list = [list filteredArrayUsingPredicate:bPredicate];
    return list;
}

//call it from getAllBackUps
+ (void)cleanBkUps
{
    NSManagedObjectContext *mContext;
    if([NSThread isMainThread])
    {
        mContext = [[CoreDataManager sharedManager] managedObjectContext];
        
        // initializing NSFetchRequest
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        //Setting Entity to be Queried
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShoutBackup" inManagedObjectContext:mContext];
        [fetchReq setEntity:entity];
        // set condition (predicate).
        //you will get records upto date current date -  2 days.If you have records for 10 july and 15 july.And current date is 17.Then you will get two records here
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.synced=YES && SELF.backUpDate <= %@",[Common getPreviousDateOlderForDays:k_DBCleanDays]];
        [fetchReq setPredicate:predicate];
        NSError* error;
        // Query on managedObjectContext With Generated fetchRequest
        NSArray *records = [mContext executeFetchRequest:fetchReq error:&error];
        if (error) return;
        for(ShoutBackup *shBk in records)
        {
            [mContext deleteObject:shBk];
        }
        [CoreDataManager saveContext];
    }
    else
    {
        mContext = [[CoreDataManager sharedManager] privateObjectContext];
        [mContext performBlockAndWait:^{
            
            // initializing NSFetchRequest
            NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
            //Setting Entity to be Queried
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShoutBackup" inManagedObjectContext:mContext];
            [fetchReq setEntity:entity];
            // set condition (predicate).
            //you will get records upto date current date -  2 days.If you have records for 10 july and 15 july.And current date is 17.Then you will get two records here
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.synced=YES && SELF.backUpDate <= %@",[Common getPreviousDateOlderForDays:k_DBCleanDays]];
            [fetchReq setPredicate:predicate];
            NSError* error;
            // Query on managedObjectContext With Generated fetchRequest
            NSArray *records = [mContext executeFetchRequest:fetchReq error:&error];
            if (error) return;
            for(ShoutBackup *shBk in records)
            {
                [mContext deleteObject:shBk];
            }
            [CoreDataManager saveContext];
            
        }];
    }
}

+ (void)cleanShouts
{
    if ([Global shared].currentUser.user_id == nil) return;
    NSManagedObjectContext *mContext;
    if([NSThread isMainThread])
    {
        mContext = [[CoreDataManager sharedManager] managedObjectContext];
        // initializing NSFetchRequest
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        //Setting Entity to be Queried
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shout" inManagedObjectContext:mContext];
        [fetchReq setEntity:entity];
        // set condition (predicate).
        int currentTimeStamp = (int) [TimeConverter timeStamp]-k_DBCleanUpTime;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.synced==0 && SELF.isBackup==0) && original_timestamp < %d",currentTimeStamp];
        [fetchReq setPredicate:predicate];
        NSError* error;
        // Query on managedObjectContext With Generated fetchRequest
        NSArray *records = [mContext executeFetchRequest:fetchReq error:&error];
        if (error) return;
        //check for these shout (shout object in record array) are not part of back up
        NSArray *arrALlBackUps = [DBManager getAllBackUps];
        NSMutableArray *arrRecordsToBeDeleted = [NSMutableArray array];
        for (ShoutBackup *shtBkUp in arrALlBackUps)
        {
            @autoreleasepool
            {
                NSArray *shtArrayFromBkUp = shtBkUp.backupShouts.allObjects;
                for (Shout *sht in records)
                {
                    @autoreleasepool
                    {
                        if (![shtArrayFromBkUp containsObject:sht])
                        {
                            [arrRecordsToBeDeleted addObject:sht];
                        }
                        else
                        {
                            DLog(@"this shout is part o baackup");
                        }
                    }
                }
            }
        }
        DLog(@"shouts to be deleted are ++++>>>>++++ %@", arrRecordsToBeDeleted);
        for(Shout *shout in arrRecordsToBeDeleted)
        {
            @autoreleasepool
            {
                if (shout.contentUrl)
                {
                    [[SDImageCache sharedImageCache] removeImageForKey:shout.contentUrl fromDisk:YES];
                }
                [[ShoutManager sharedManager] dequeueShout:shout];
                DLog(@"deleted shouts %@ >>>>>>>>", shout.shId);
                [mContext deleteObject:shout];
            }
        }
        [CoreDataManager saveContext];
    }
    else
    {
        mContext = [[CoreDataManager sharedManager] privateObjectContext];
        
        [mContext performBlockAndWait:^{
            
            // initializing NSFetchRequest
            NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
            //Setting Entity to be Queried
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shout" inManagedObjectContext:mContext];
            [fetchReq setEntity:entity];
            // set condition (predicate).
            int currentTimeStamp = (int) [TimeConverter timeStamp]-k_DBCleanUpTime;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.synced==0 && SELF.isBackup==0) && original_timestamp < %d",currentTimeStamp];
            [fetchReq setPredicate:predicate];
            NSError* error;
            // Query on managedObjectContext With Generated fetchRequest
            NSArray *records = [mContext executeFetchRequest:fetchReq error:&error];
            if (error) return;
            //check for these shout (shout object in record array) are not part of back up
            NSArray *arrALlBackUps = [DBManager getAllBackUps];
            NSMutableArray *arrRecordsToBeDeleted = [NSMutableArray array];
            for (ShoutBackup *shtBkUp in arrALlBackUps)
            {
                @autoreleasepool
                {
                    NSArray *shtArrayFromBkUp = shtBkUp.backupShouts.allObjects;
                    for (Shout *sht in records)
                    {
                        @autoreleasepool
                        {
                            if (![shtArrayFromBkUp containsObject:sht])
                            {
                                [arrRecordsToBeDeleted addObject:sht];
                            }
                            else
                            {
                                DLog(@"this shout is part o baackup");
                            }
                        }
                    }
                }
            }
            DLog(@"shouts to be deleted are ++++>>>>++++ %@", arrRecordsToBeDeleted);
            for(Shout *shout in arrRecordsToBeDeleted)
            {
                @autoreleasepool
                {
                    if (shout.contentUrl)
                    {
                        [[SDImageCache sharedImageCache] removeImageForKey:shout.contentUrl fromDisk:YES];
                    }
                    [[ShoutManager sharedManager] dequeueShout:shout];
                    DLog(@"deleted shouts %@ >>>>>>>>", shout.shId);
                    [mContext deleteObject:shout];
                }
            }
            [CoreDataManager saveContext];
            
        }];
    }
    
  }

+(NSInteger)getUnresdShoutsCount
{
    NSArray *list = [DBManager entities:@"Group" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.totShoutsReceived > 0"];
    list = [list filteredArrayUsingPredicate:bPredicate];
    NSNumber *totalCount = [list valueForKeyPath:@"@sum.totShoutsReceived"];
    return totalCount.integerValue;
}

+(NSInteger)getUnreadChannelContentCount
{
    NSArray *list = [DBManager entities:@"Channels" pred:nil descr:nil isDistinctResults:NO];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.contentCount > 0"];
    list = [list filteredArrayUsingPredicate:bPredicate];
    NSNumber *totalCount = [list valueForKeyPath:@"@sum.contentCount"];
    return totalCount.integerValue;
}

// badge Count Fix

+(NSMutableArray*)currentUserShoutsArray:(NSArray*)allShouts forUserId:(NSString*)userID{
    NSArray *userList = [DBManager entities:@"User" pred:nil descr:nil isDistinctResults:YES];
    NSString *tempString_1 = [NSString stringWithFormat:@"SELF.user_id='%@'",userID];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:tempString_1];
    userList =  [userList filteredArrayUsingPredicate:pred];
    
    User *user = [userList lastObject];
    
    NSMutableArray *shoutArray = [[NSMutableArray alloc] init];
    for (Shout *shout in allShouts) {
        if ([shout.reciever isEqual:user])
            [shoutArray addObject:shout];
    }
    return shoutArray;
}

+(NSInteger)getTotalReceivedShoutsFromShoutsTable:(NSString*)userID{
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970]-KCellFadeOutDuration;
    NSInteger time = round(timeInMiliseconds);
    NSArray *list = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSString *tempString = [NSString stringWithFormat:@"SELF.isShoutRecieved==1 && timestamp>%ld",time];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:tempString];
    NSMutableArray *shoutArray = [self currentUserShoutsArray:list forUserId:userID];
    NSArray *newArray = [shoutArray filteredArrayUsingPredicate:bPredicate];
    return newArray.count;
}


+(NSInteger)getTotalReceivedShoutsFromShoutsTableForParticularGroup:(Group*)group withUser:(NSString*)userID{
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970]-KCellFadeOutDuration;
    NSInteger time = round(timeInMiliseconds);
    NSArray *list = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSString *tempString = [NSString stringWithFormat:@"groupId='%@' && (SELF.isShoutRecieved==1 && timestamp>%ld)", group.grId,time];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:tempString];
    NSMutableArray *shoutArray = [self currentUserShoutsArray:list forUserId:userID];
    NSArray *newArray = [shoutArray filteredArrayUsingPredicate:bPredicate];
    return newArray.count;
}

+(void)updateShoutsIsReadOnClickingMessages:(NSString*)groupID withUserID:(NSString*)userID
{
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970]-KCellFadeOutDuration;
    NSInteger time = round(timeInMiliseconds);
    NSArray *list = [DBManager entities:@"Shout" pred:nil descr:nil isDistinctResults:NO];
    NSString *tempString = [NSString stringWithFormat:@"groupId='%@' && timestamp>%ld", groupID,time];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:tempString];
    NSMutableArray *shoutArray = [self currentUserShoutsArray:list forUserId:userID];
    NSArray *newArray = [shoutArray filteredArrayUsingPredicate:bPredicate];
    for (Shout *shout in newArray)
    {
        @try
        {
        NSManagedObject* favoritsGrabbed = shout;
        NSNumber *newValue = [NSNumber numberWithBool:NO];
        [favoritsGrabbed setValue:newValue forKey:@"isShoutRecieved"];
        }@catch (NSException *exception) {
        } @finally {}
    }
    [self save];
}

+(NSArray*) searchKeywordinChannelsForText:(NSString*)searchText{
    NSArray *list = [DBManager entities:@"Channels" pred:nil descr:nil isDistinctResults:NO];
    NSString *tempString = [NSString stringWithFormat:@"name contains[c] '%@'",searchText];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:tempString];
    NSArray *searchArray = [list filteredArrayUsingPredicate:bPredicate];
    return searchArray;
}

+(NSArray*) searchKeywordinChannelFeedForText:(NSString*)searchText{
    NSArray *list = [DBManager entities:@"ChannelDetail" pred:nil descr:nil isDistinctResults:NO];
    NSString *tempString = [NSString stringWithFormat:@"text contains[c] '%@' && toBeDisplayed = YES",searchText];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:tempString];
    NSArray *searchArray = [list filteredArrayUsingPredicate:bPredicate];
    return searchArray;
}

+(NSArray*)feedsFromBukiBox{
    NSArray *list = [DBManager entities:@"ChannelDetail" pred:nil descr:nil isDistinctResults:NO];
    NSString *tempString = [NSString stringWithFormat:@"feed_Type = YES AND toBeDisplayed = YES"];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:tempString];
    NSArray *feedArray = [list filteredArrayUsingPredicate:bPredicate];
    return feedArray;
}

+(NSArray*)channelFeedsForSelectedChannelIdWithSortDescriptor:(NSArray*)descArray{
    NSArray *list = [DBManager entitiesByArrayDesc:@"ChannelDetail" pred:nil arrayOfDesc:descArray isDistinctResults:YES];
    NSString *tempString = [NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES",[Global shared].currentChannel.channelId];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:tempString];
    NSArray *feedArray = [list filteredArrayUsingPredicate:bPredicate];
    return feedArray;
}

@end
