//
//  Notifications.m
//  LH2GO
//
//  Created by Arpit Toshniwal on 22/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "Notifications.h"
#import "CoreDataManager.h"

@implementation Notifications
@dynamic message;
@dynamic notId;
@dynamic timestamp;
@dynamic type;
@dynamic user;
@dynamic network;
@dynamic group;
@dynamic status;





+ (Notifications *)notificationWithId:(NSString *)nId shouldInsert:(BOOL)insert
{
    
    NSString *notId = [NSString stringWithFormat:@"%d", [nId intValue]];
    Notifications *notf = [DBManager entityWithStr:@"Notifications" idName:@"notId" idValue:notId];
    if (!insert) return notf;
    
    if (!notf) {
        notf = [CoreDataManager insertObjectFor:@"Notifications"];
        notf.notId = nId;
        [CoreDataManager saveContext];
    }
    return notf;
}


+ (Notifications *)addNotWithDict:(NSDictionary *)dict
{
    
    if (!dict) return nil;
    
    NSString *nId = [AppManager sutableStrWithStr:[dict objectForKey:@"notification_id"]];
    if (nId == nil) {
        return nil;
    }
    
    NSString *type = [AppManager sutableStrWithStr:[dict objectForKey:@"type"]];
  
     // set group
    NSDictionary *groupDict = [dict objectForKey:@"Group"];
   if(![type isEqualToString:@"4"] && ![type isEqualToString:@"7"] && ![type isEqualToString:@"3"] && ![type isEqualToString:@"2"]){
        
    Notifications *notf = [Notifications notificationWithId:nId shouldInsert:YES];
        
  
       Group *group = [Group addGroupWithDict:groupDict forUsers:nil pic:nil pending:NO];
    notf.group = group;
    
    // set user
    NSDictionary *userDict = [dict objectForKey:@"Sender"];
    User *user = [User addUserWithDict:userDict pic:nil];
    notf.user = user;
    
    // set network
    NSDictionary *netDict = [dict objectForKey:@"Network"];
    Network *net = [Network addNetworkWithDict:netDict];
    notf.network = net;
    
    notf.message = [AppManager sutableStrWithStr:[dict objectForKey:@"message"]];
    
    NSInteger timeStamp = [[AppManager sutableStrWithStr:[dict objectForKey:@"timestamp"]] integerValue];
    notf.timestamp = @(timeStamp);
    
    [CoreDataManager saveContext];
        return notf;
    }
//    else if([type isEqualToString:@"10"])
//    {
//        Notifications *notf = [Notifications notificationWithId:nId shouldInsert:YES];
//        
//
//    }
    else{
        return nil;
    }
   
    
}
@end
