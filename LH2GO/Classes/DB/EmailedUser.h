//
//  EmailedUser.h
//  LH2GO
//
//  Created by Sumit Kumar on 15/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EmailedUser : NSManagedObject

@property (nonatomic, retain) NSString * emailId;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * user_id;
+ (EmailedUser *)emailUserWithEmailId:(NSString *)emailId shouldInsert:(BOOL)insert;
+ (void)deleteEmailUserWithEmailId:(NSString *)emailId;
@end
