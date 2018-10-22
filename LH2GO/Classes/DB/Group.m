//
//  Group.m
//  LH2GO
//
//  Created by Sumit Kumar on 24/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "Group.h"
#import "Network.h"
#import "Shout.h"
#import "User.h"
#import "CoreDataManager.h"

@implementation Group

@dynamic badge;
@dynamic grId;
@dynamic grName;
@dynamic picUrl;
@dynamic timeStamp;
@dynamic network;
@dynamic owner;
@dynamic pendingUsers;
@dynamic shouts;
@dynamic users;
@dynamic isPending;
@dynamic totShoutsReceived;

- (void)getImage {
    if (!self.picUrl.length) return;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:self.picUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // progression tracking code
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            // do something with image
        }
    }];
}
//shradha
+ (Group *)groupWithId:(NSString *)gId shouldInsert:(BOOL)insert isP2PContact:(BOOL)isP2P isPendingStatus:(BOOL)isPending{
    
    NSString *groupId = [NSString stringWithFormat:@"%d", [gId intValue]];
    Group *grp = [DBManager entityWithStr:@"Group" idName:@"grId" idValue:groupId];
    if (!insert) return grp;
    
    if (!grp) {
        grp = [CoreDataManager insertObjectFor:@"Group"];
        grp.grId = gId;
        // p2p connection
        grp.isP2PContact = isP2P;
        [CoreDataManager saveContext];
    }
    return grp;
}


+ (Group *)addGroupWithDict:(NSDictionary *)dict forUsers:(NSArray *)users
                        pic:(UIImage *)pic isPendingStatus:(BOOL)isPending{
    
    if (!dict) return nil;
    
    NSString *gId = [AppManager sutableStrWithStr:[dict objectForKey:@"id"]];
    if (gId == nil) {
        return nil;
    }
    Group *grp = [Group groupWithId: gId shouldInsert:YES isP2PContact:NO isPendingStatus:isPending];
    
    // set network
    NSString *nid = [AppManager sutableStrWithStr:[dict objectForKey:@"network_id"]];
    Network *net = [Network networkWithId:nid shouldInsert:NO];
    if(net != nil){
        grp.network = net;
        
    }
    else{
        NSArray *networks = [DBManager getNetworks];
        for(Network *net in networks){
            if([net.netId isEqualToString:@"1"]){
                grp.network = net;
                
            }
        }
    
    }
    // set owner
    NSString *uId = [AppManager sutableStrWithStr:[dict objectForKey:@"owner_id"]];
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:users];
    
    if (uId.length) {
        User *owner = [User userWithId:uId shouldInsert:YES];
        grp.owner = owner;
        
        // user - group
        [owner addOwnedGroupsObject:grp];
        [tempArr removeObject:owner];
        [grp addUsersObject:owner];
        
        // network - user
        if (grp.network) {
            [owner addNetworksObject:grp.network];
            [grp.network addUsersObject:owner];
        }
    }
    
    
    grp.grName = [AppManager sutableStrWithStr:[dict objectForKey:@"group_name"]];
    NSInteger timeStamp = [[AppManager sutableStrWithStr:[dict objectForKey:@"timestamp"]] integerValue];
    grp.timeStamp = @(timeStamp);
    
    if (users) {
        NSSet *mySet = [[NSSet alloc] initWithArray:tempArr];
        [grp addPendingUsers:mySet];
    }
    
    NSString *urlStr = [AppManager sutableStrWithStr:[dict objectForKey:@"group_photo"]];
    grp.picUrl = urlStr;
    grp.isPending = isPending;
    
    [CoreDataManager saveContext];
    
    if (pic) {
        [[SDImageCache sharedImageCache] storeImage:pic forKey:grp.picUrl];
    } else {
        [grp getImage];
    }
    
    return grp;
}

+ (Group *)addGroupWithDictForP2PContact:(NSDictionary *)dict forUsers:(NSArray *)users
                        pic:(UIImage *)pic isPendingStatus:(BOOL)isPending{
    
    if (!dict) return nil;
    
    NSString *gId = [AppManager sutableStrWithStr:[dict objectForKey:@"id"]];
    if (gId == nil) {
        return nil;
    }
    Group *grp = [Group groupWithId: gId shouldInsert:YES isP2PContact:YES isPendingStatus:YES];
    
    // set network
    NSString *nid = [AppManager sutableStrWithStr:[dict objectForKey:@"network_id"]];
    Network *net = [Network networkWithId:nid shouldInsert:YES];
    if(net != nil){
        grp.network = net;
        
    }
    else{
        NSArray *networks = [DBManager getNetworks];
        for(Network *net in networks){
            if([net.netId isEqualToString:@"1"]){
                grp.network = net;
                
            }
        }
        
    }
    // set owner
    NSString *uId = [AppManager sutableStrWithStr:[dict objectForKey:@"owner_id"]];
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:users];
    
    if (uId.length) {
        User *owner = [User userWithId:uId shouldInsert:YES];
        grp.owner = owner;
        
        // user - group
        [owner addOwnedGroupsObject:grp];
        [tempArr removeObject:owner];
        [grp addUsersObject:owner];
        
        // network - user
        if (grp.network) {
            [owner addNetworksObject:grp.network];
            [grp.network addUsersObject:owner];
        }
    }
    
    
    grp.grName = [AppManager sutableStrWithStr:[dict objectForKey:@"group_name"]];
    NSInteger timeStamp = [[AppManager sutableStrWithStr:[dict objectForKey:@"timestamp"]] integerValue];
    grp.timeStamp = @(timeStamp);
    
    if (users) {
        NSSet *mySet = [[NSSet alloc] initWithArray:tempArr];
        [grp addPendingUsers:mySet];
    }
    
    NSString *urlStr = [AppManager sutableStrWithStr:[dict objectForKey:@"group_photo"]];
    grp.picUrl = urlStr;
    grp.isPending = isPending;
    
    [CoreDataManager saveContext];
    
    if (pic) {
        [[SDImageCache sharedImageCache] storeImage:pic forKey:grp.picUrl];
    } else {
        [grp getImage];
    }
    
    return grp;
}

+ (Group *)addGroupWithDict:(NSDictionary *)dict forUsers:(NSArray *)users
                        pic:(UIImage *)pic pending:(BOOL)isPending {
    
    if (!dict) return nil;
    
    NSString *gId = [AppManager sutableStrWithStr:[dict objectForKey:@"id"]];
    if (gId == nil) {
        return nil;
    }
    Group *grp = [Group groupWithId: gId shouldInsert:YES isP2PContact:NO isPendingStatus:isPending];
    
    // set network
    NSString *nid = [AppManager sutableStrWithStr:[dict objectForKey:@"network_id"]];
    Network *net = [Network networkWithId:nid shouldInsert:NO];
    if(net != nil){
        grp.network = net;
        
    }
    else{
        NSArray *networks = [DBManager getNetworks];
        for(Network *net in networks){
            if([net.netId isEqualToString:@"1"]){
                grp.network = net;
                
            }
        }
        
    }    
    // set owner
    NSString *uId = [AppManager sutableStrWithStr:[dict objectForKey:@"owner_id"]];
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:users];
    
    if (uId.length) {
        User *owner = [User userWithId:uId shouldInsert:YES];
        grp.owner = owner;
        
        // user - group
        [owner addOwnedGroupsObject:grp];
        [tempArr removeObject:owner];
        [grp addUsersObject:owner];
        
        // network - user
        if (grp.network) {
            [owner addNetworksObject:grp.network];
            [grp.network addUsersObject:owner];
        }
    }
    
    
    grp.grName = [AppManager sutableStrWithStr:[dict objectForKey:@"group_name"]];
    NSInteger timeStamp = [[AppManager sutableStrWithStr:[dict objectForKey:@"timestamp"]] integerValue];
    grp.timeStamp = @(timeStamp);
    
    if (users) {
        NSSet *mySet = [[NSSet alloc] initWithArray:tempArr];
        [grp addPendingUsers:mySet];
    }
    
    NSString *urlStr = [AppManager sutableStrWithStr:[dict objectForKey:@"group_photo"]];
    grp.picUrl = urlStr;
    grp.isPending = isPending;
    
    [CoreDataManager saveContext];
    
    if (pic) {
        [[SDImageCache sharedImageCache] storeImage:pic forKey:grp.picUrl];
    } else {
        [grp getImage];
    }
    
    return grp;
}



- (void)upBadge {
    self.badge = @(self.badge.integerValue+1);
    [CoreDataManager saveContext];
}

- (void)clearBadge {
    self.badge = @(0);
    [CoreDataManager saveContext];
}
- (void)clearBadge:(Group*)gr {
    gr.totShoutsReceived = [NSNumber numberWithInteger:0];
    [CoreDataManager saveContext];
}
+ (void)clearGroups{
    
}

@end
