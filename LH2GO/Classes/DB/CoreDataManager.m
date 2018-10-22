//
//  CoreDataManager.m
//  Test
//
//  Created by Prakash Raj on 17/02/14.
//  Copyright (c) 2014 Raj. All rights reserved.
//

#import "CoreDataManager.h"

#define kDBName @"QA_Database.db"
#define KDocDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize privateObjectContext = _privateObjectContext;

#pragma mark - Public methods (getter).

- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
//    if ([NSThread isMainThread]) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]; //SOnal Sept 18
//        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
//        [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
//        [_managedObjectContext setRetainsRegisteredObjects:YES];
//
//    }else
//    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]; //SOnal Sept 18
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_managedObjectContext setRetainsRegisteredObjects:YES];
//    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [KDocDir stringByAppendingPathComponent:kDBName]];
    NSError *error = nil;
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
    {
        // Error for store creation should be handled in here
    }
    return _persistentStoreCoordinator;
}


#pragma mark - Class methods

// @method : to return shared instance.
+ (CoreDataManager *)sharedManager
{
    static CoreDataManager *aCoreDataManager = nil;
    @synchronized (aCoreDataManager)
    {
        if (!aCoreDataManager)
        {
            aCoreDataManager = [[CoreDataManager alloc] init];
        }
    }
    return aCoreDataManager;
}

- (NSManagedObjectContext *)privateObjectContext {
    NSThread *currentQueue = [NSThread currentThread];
    if([[currentQueue threadDictionary] objectForKey:@"privateQueue"])
        return [[currentQueue threadDictionary] objectForKey:@"privateQueue"];
    else
        _privateObjectContext = [CoreDataManager childContextWithParent:_managedObjectContext];
    
    
    [[currentQueue threadDictionary] setObject:_privateObjectContext forKey:@"privateQueue"];
    
    return _privateObjectContext;
}

+ (NSManagedObjectContext *) childContextWithParent:(NSManagedObjectContext *)parent {
    NSManagedObjectContext  *result = nil;
    
    result = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [result setParentContext:parent];
    
    return result;
}

// @method : to save context.
+ (BOOL)saveContext
{
    __block BOOL isSaved = false;
    @try
    {
       // NSError *error;
        NSManagedObjectContext *mContext = [App_delegate xyz];
        if(!mContext) return NO;
        @synchronized (self) {

                NSError *error;
                isSaved = [mContext save:&error];
                if (!isSaved)
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                //                }];
        //    }
            return isSaved;
        }
    }
    @catch (NSException *exception) {}
    @finally {}
}

//Sonal Sept 18
//+(BOOL) saveContext
//{
//    NSManagedObjectContext *mContext = [[CoreDataManager sharedManager] managedObjectContext];
//   // [mContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
//    __block BOOL isSaved = false;
//    if (mContext != nil) {
//        
//        [mContext performBlock:^{
//            NSError *error = nil;
//            if ([mContext hasChanges] && ![mContext save:&error]) {
//                NSLog(@"BG CONTEXT Unresolved error %@, %@", error, [error userInfo]);
//            }else{
//                NSLog(@"Context Saved");
//                isSaved = YES;
//            }
//        }];
//    }
//    return isSaved;
//}

// @method : to get an instance of an entity to perform operation.
+ (id)insertObjectFor:(NSString *)className
{
    __block id result;
    NSManagedObjectContext *mContext = [[CoreDataManager sharedManager] managedObjectContext];
    if([NSThread isMainThread])
        return [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:mContext];
    else
    {
        [mContext performBlockAndWait:^{
            result = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[CoreDataManager sharedManager] privateObjectContext]];
        }];
    }
    return result;
}

//SOnal Sept 18, 2017
//+(id) insertObjectFor:(NSString *)className
//{
//    __block NSManagedObject *entity;
//    NSManagedObjectContext *mContext = [[CoreDataManager sharedManager] managedObjectContext];
//    [mContext performBlock:^{
//    NSError *error = nil;
//    // Create a new managed object
//   entity = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:mContext];
//    
//    // Save the object to persistent store
//    if ([mContext hasChanges] && ![mContext save:&error]) {
//        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//    }else{
//        NSLog(@"Saved");
//    }
//    
//    if (error) {
//        // handle the error.
//        NSLog(@"ERRRR %@", error.localizedDescription);
//    }
//    }];
//    return entity;
//}

@end
