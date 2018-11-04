//
//  Channels.m
//  LH2GO
//
//  Created by Linchpin on 7/18/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "Channels.h"
#import "Network.h"
#import "User.h"
#import "CoreDataManager.h"

@implementation Channels

@dynamic channelId;
@dynamic image;
@dynamic name;
@dynamic channelPId;
@dynamic owner;
@dynamic network;
@dynamic users;
@dynamic isSubscribed;
@dynamic contentCount;
@dynamic type;
@dynamic isFavouriteChannel;


- (void)getImageForChannel {
    if (!self.image.length) return;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:self.image] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // progression tracking code
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            // do something with image
        }
    }];
}
//shradha
+ (Channels *)channelWithId:(NSString *)cId shouldInsert:(BOOL)insert
{

    NSString *channelId = [NSString stringWithFormat:@"%d", [cId intValue]];
    Channels *channel = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:channelId];
    if (!insert) return channel;
    
    if (!channel) {
        channel = [CoreDataManager insertObjectFor:@"Channels"];
        channel.channelId = cId;
        [CoreDataManager saveContext];
    }
    return channel;
}


+ (Channels *)addChannelWithDict:(NSDictionary *)dict
                        forUsers:(NSArray *)users
                             pic:(UIImage *)pic isSubscribed:(NSString*)subscribe channelType:(NSString *)type{
    
    if (!dict) return nil;
    
    NSString *cId = [AppManager sutableStrWithStr:[dict objectForKey:@"id"]];
    if (cId == nil) {
        cId = [AppManager sutableStrWithStr:[dict objectForKey:@"channel_id"]];
        if(cId == nil)
        return nil;
    }
    
    if([cId isEqualToString:@""]){
        cId = [AppManager sutableStrWithStr:[dict objectForKey:@"channel_id"]];
    }
    Channels *channel = [Channels channelWithId:cId shouldInsert:YES];
    
    // set network
    NSString *nid = [AppManager sutableStrWithStr:[dict objectForKey:@"network_id"]];
    Network *net = [Network networkWithId:nid shouldInsert:YES];
    if(net != nil){
        channel.network = net;

    }
    else{
        NSArray *networks = [DBManager getNetworks];
        for(Network *net in networks){
            if([net.netId isEqualToString:@"1"]){
                if ([[dict objectForKey:@"network_id"] isEqualToString:@"1"])
                    channel.network = net;

            }
            else{
                channel.network = nil;
            }
    }
    
    }
    //set channel owner id
    NSString *channelPId =[AppManager sutableStrWithStr:[dict objectForKey:@"owner_id"]];
    channel.channelPId =[AppManager sutableStrWithStr:channelPId];
    
    channel.type = [NSString stringWithFormat:@"%@",type];
    
    // set admin
    NSString *uId = [AppManager sutableStrWithStr:[dict objectForKey:@"channel_admin"]];
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:users];
    
   
    if (uId.length) {
        User *owner = [User userWithId:uId shouldInsert:NO];
        if(owner != nil)
        {
        channel.owner = owner;
        
        // user - channel
        [owner addChannelsObject:channel];
        [tempArr removeObject:owner];
        
        // network - user
        if (channel.network) {
            [owner addNetworksObject:channel.network];
            [channel.network addUsersObject:owner];
         }
        }
    }
    
    channel.name = [AppManager sutableStrWithStr:[dict objectForKey:@"channel_name"]];
    NSString *urlStr = [AppManager sutableStrWithStr:[dict objectForKey:@"channel_photo"]];
    channel.image = urlStr;
    channel.isSubscribed = [NSNumber numberWithInteger:subscribe.integerValue];
    channel.contentCount = [NSNumber numberWithInteger:0];
    channel.isFavouriteChannel = NO;

    [CoreDataManager saveContext];
    
    if (pic) {
        [[SDImageCache sharedImageCache] storeImage:pic forKey:channel.image];
    } else {
        [channel getImageForChannel];
    }
    return channel;
}

- (void)clearCount:(Channels*)ch {
    ch.contentCount = [NSNumber numberWithInteger:0];
    [CoreDataManager saveContext];
}


+(NSArray *)getAllchannelsList
{
    NSArray *allChannelsArray = [DBManager entities:@"Channels" pred:[NSString stringWithFormat:@"type = \"%@\" AND isFavouriteChannel = NO",[PrefManager defaultUserSelectedCityId]] descr:nil isDistinctResults:YES];
    return allChannelsArray;
}

+(NSArray *)getFavchannelsList
{
    NSArray *favChannelsArray = [DBManager entities:@"Channels" pred:[NSString stringWithFormat:@"type = \"%@\" AND isFavouriteChannel = YES",[PrefManager defaultUserSelectedCityId]] descr:nil isDistinctResults:YES];
    return favChannelsArray;
}

@end
