//
//  Network.m
//  LH2GO
//
//  Created by Prakash Raj on 14/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "Network.h"
#import "Group.h"
#import "User.h"
#import "BLEManager.h"
#import "CoreDataManager.h"

@implementation Network

@dynamic netCharKey;
@dynamic netId;
@dynamic netName;
@dynamic netTransKey;
@dynamic timeStamp;
@dynamic groups;
@dynamic users;
@dynamic channels;

+ (Network *)networkWithId:(NSString *)netId shouldInsert:(BOOL)insert
{
    if (!netId.length)
    {
        return nil;
    }
    Network *net = [DBManager entity:@"Network" idName:@"netId" idValue:netId];
    if(!insert) return net;
    if (!net)
    {
        net = [CoreDataManager insertObjectFor:@"Network"];
        net.netId = netId;
        [CoreDataManager saveContext];
    }
    return net;
}

+ (Network *)addNetworkWithDict:(NSDictionary *)dict
{
    if (!dict) return nil;
    NSString *nId = [AppManager sutableStrWithStr:[dict objectForKey:@"id"]];
    if (nId == nil || [nId isEqualToString:@""])
    {
        return nil;
    }
    Network *net = [Network networkWithId:nId shouldInsert:YES];
    if (!net)
    {
        net = [CoreDataManager insertObjectFor:@"Network"];
        net.netId = nId;
    }
    NSString *netCharKey = [AppManager sutableStrWithStr:[dict objectForKey:@"transfer_characteristic_uuid"]];
    NSString *netTransKey = [AppManager sutableStrWithStr:[dict objectForKey:@"transfer_service_uuid"]];
    NSString *activeNetId = [PrefManager activeNetId];
  //  BOOL refreshNetworkKeys = NO;
    if ([activeNetId isEqualToString:nId])
    {
        if (!([netCharKey isEqualToString:net.netCharKey]&&[netTransKey isEqualToString:net.netTransKey]))
        {
           // refreshNetworkKeys = YES;
        }
    }
    net.netCharKey = netCharKey;
    net.netTransKey = netTransKey;
    net.netName = [AppManager sutableStrWithStr:[dict objectForKey:@"network_name"]];
    NSInteger timeStamp = [[AppManager sutableStrWithStr:[dict objectForKey:@"timestamp"]] integerValue];
    net.timeStamp = @(timeStamp);
    
    
    
    // set owner
    User *owner = [User userWithId:[Global shared].currentUser.user_id shouldInsert:NO];
    
   // user - group
     [owner addNetworksObject:net];
     [net addUsersObject:owner];
        
    
    
    [CoreDataManager saveContext];
        

    return net;
}

@end
