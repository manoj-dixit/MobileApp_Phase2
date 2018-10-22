//
//  User.m
//  LH2GO
//
//  Created by Sumit Kumar on 24/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "User.h"
#import "Group.h"
#import "Network.h"
#import "Shout.h"
#import "CoreDataManager.h"
#import "EmailedUser.h"

@implementation User

@dynamic email;
@dynamic picUrl;
@dynamic user_id;
@dynamic user_name;
@dynamic groups;
@dynamic networks;
@dynamic ownedGroups;
@dynamic ownedShouts;
@dynamic pendingGroups;
@dynamic shouts;
@dynamic parent_account_id;
@dynamic channels;
@dynamic loud_hailerid;
@dynamic eventCount;
@dynamic user_role;
@dynamic isBlocked;

- (void)getImage
{
    if (!self.picUrl.length) return;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:self.picUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // progression tracking code
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image)
        {
            // do something with image
        }
    }];
}

// get a user
+ (User *)userWithId:(NSString *)userId shouldInsert:(BOOL)insert
{
    User *aUser = [DBManager entityWithStr:@"User" idName:@"user_id" idValue:userId];
    NSInteger userIdValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"blockedUser"];
    if ([aUser.user_id integerValue] == userIdValue) {
        aUser.isBlocked = [NSNumber numberWithInteger:1];
    }
    else{
        aUser.isBlocked = [NSNumber numberWithInteger:0];
    }

    if (!insert) return aUser;
    
    if (!aUser)
    {
        aUser = [CoreDataManager insertObjectFor:@"User"];
        aUser.user_id = userId;
        aUser.email = @"";
        aUser.loud_hailerid = @"";
        aUser.picUrl = @"";
        aUser.parent_account_id = @"";
        aUser.user_name = @"";
        aUser.user_role = @"";
        aUser.isBlocked = [NSNumber numberWithInteger:0];
        [CoreDataManager saveContext];
    }
    return aUser;
}

// get a user
+ (User *)userWithId:(NSString *)userId shouldInsert:(BOOL)insert withUserName:(NSString *)userName
{
    User *aUser = [DBManager entityWithStr:@"User" idName:@"user_id" idValue:userId];
    NSInteger userIdValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"blockedUser"];
    if ([aUser.user_id integerValue] == userIdValue) {
        aUser.isBlocked = [NSNumber numberWithInteger:1];
    }
    else{
        aUser.isBlocked = [NSNumber numberWithInteger:0];
    }

    if (!insert) return aUser;
    if (!aUser)
    {
        aUser = [CoreDataManager insertObjectFor:@"User"];
        aUser.user_id = userId;
        aUser.email = @"";
        aUser.loud_hailerid = @"";
        aUser.picUrl = @"";
        aUser.parent_account_id = @"";
        aUser.user_name = userName;
        aUser.user_role = @"";
        aUser.isBlocked = [NSNumber numberWithInteger:0];
        [CoreDataManager saveContext];
    }
    return aUser;
}

// add user to DB
+ (User *)addUserWithDict:(NSDictionary *)dict pic:(UIImage *)pic
{
    if (!dict) return nil;
    NSString *uId = [AppManager sutableStrWithStr:[dict objectForKey:@"id"]];
    NSString *username = [AppManager sutableStrWithStr:[dict objectForKey:@"username"]];
    NSString *loudhailerid = [AppManager sutableStrWithStr:[dict objectForKey:@"loudhailer_id"]];

    NSString *email = [AppManager sutableStrWithStr:[dict objectForKey:@"email"]];
    NSString*parentAccountID =[AppManager sutableStrWithStr:[dict objectForKey:@"parent_account_id"]];
    NSString*userrole =[AppManager sutableStrWithStr:[dict objectForKey:@"user_role"]];
    if (uId.length>0&&username.length>0&&email.length>0)
    {
        [EmailedUser deleteEmailUserWithEmailId:email];
        User *aUser = [User userWithId:uId shouldInsert:YES];
        aUser.user_name = [AppManager sutableStrWithStr:username];
        aUser.email = [AppManager sutableStrWithStr:email];
        aUser.eventCount = [NSNumber numberWithInt:0];
        aUser.picUrl = [AppManager sutableStrWithStr:[dict objectForKey:@"profile_photo"]];
        if(![loudhailerid isEqualToString:@""]){
             aUser.loud_hailerid = loudhailerid;
        }
      
        aUser.parent_account_id =[AppManager sutableStrWithStr:parentAccountID];
        aUser.user_role =[AppManager sutableStrWithStr:userrole];
       NSInteger userIdValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"blockedUser"];
        if ([aUser.user_id integerValue] == userIdValue) {
            aUser.isBlocked = [NSNumber numberWithInteger:1];
        }
        else{
            aUser.isBlocked = [NSNumber numberWithInteger:0];
        }
        


        [CoreDataManager saveContext];
        if (pic)
        {
            [[SDImageCache sharedImageCache] storeImage:pic forKey:aUser.picUrl];
        }
        else
        {
            [aUser getImage];
        }
        return aUser;
    }
    return nil;
}

@end
