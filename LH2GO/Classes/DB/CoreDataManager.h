//
//  CoreDataManager.h
//  Test
//
//  Created by Prakash Raj on 17/02/14.
//  Copyright (c) 2014 Raj. All rights reserved.
//
//

/*
 * A class is written to support Core data process. all the requred element related to core data are defined here. so that we recieve a neet and clean code.
 * help link -
  http://www.codigator.com/tutorials/ios-core-data-tutorial-with-example/
  http://code.tutsplus.com/tutorials/core-data-from-scratch-relationships-and-more-fetching--cms-21505
 */


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSManagedObjectContext *privateObjectContext;


/*! 
 @method : to return singlton instance.
 @return : required instance.
 */
+ (CoreDataManager *)sharedManager;

/*!
 @method : to save context.
 @abstract : call when you do any operation/transaction with DB.
 @return : YES/NO as a result.
 */
//+ (BOOL)saveContext;

+(BOOL) saveContext;
/*!
 @method : to get an instance of an entity to perform operation.
 @param : className - pass class name to get their instance.
 */
+ (id)insertObjectFor:(NSString *)className;

@end
