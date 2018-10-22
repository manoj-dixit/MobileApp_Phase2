//
//  EmailedUser.m
//  LH2GO
//
//  Created by Sumit Kumar on 15/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "EmailedUser.h"
#import "CoreDataManager.h"


@implementation EmailedUser

@dynamic emailId;
@dynamic groupId;
@dynamic user_id;

+ (EmailedUser *)emailUserWithEmailId:(NSString *)emailId shouldInsert:(BOOL)insert
{
    EmailedUser *emailedUser = [DBManager entityWithPredicate:@"EmailedUser" idName:@"emailId" idValue:emailId];
    if (!insert) return emailedUser;
    if (!emailedUser)
    {
        emailedUser = [CoreDataManager insertObjectFor:@"EmailedUser"];
        emailedUser.emailId = emailId;
    }
    return emailedUser;
}

+ (void)deleteEmailUserWithEmailId:(NSString *)emailId
{
    EmailedUser *emailedUser = [DBManager entityWithPredicate:@"EmailedUser" idName:@"emailId" idValue:emailId];
    if (emailedUser)
    {
        [DBManager deleteOb:emailedUser];
    }
}

@end
