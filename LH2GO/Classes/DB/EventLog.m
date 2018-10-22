//
//  EventLog.m
//  LH2GO
//
//  Created by Linchpin on 8/21/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "EventLog.h"
#import "CoreDataManager.h"

@implementation EventLog

@dynamic logCat;
@dynamic logSubCat;
@dynamic timeStamp;
@dynamic groupId;
@dynamic channelId;
@dynamic channelContentId;
@dynamic text;
@dynamic shoutId;


+ (EventLog *)addEventWithDict:(NSDictionary *)dict{
    
    if (!dict) return nil;
    EventLog *log=  [CoreDataManager insertObjectFor:@"EventLog"];
    log.channelContentId = [dict objectForKey:@"channelContentId"];
    log.channelId = [dict objectForKey:@"channelId"];
    log.groupId = [dict objectForKey:@"groupId"];
    log.shoutId = [dict objectForKey:@"shoutId"];
    log.timeStamp = [dict objectForKey:@"timeStamp"];
    log.logCat = [dict objectForKey:@"logCat"];
    log.logSubCat = [dict objectForKey:@"logSubCat"];
    log.text = [dict objectForKey:@"text"];
    [CoreDataManager saveContext];
    return log;
   

    
}

@end
