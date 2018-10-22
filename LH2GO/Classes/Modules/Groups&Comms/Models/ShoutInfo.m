//
//  ShoutInfo.m
//  LH2GO
//
//  Created by Prakash Raj on 17/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "ShoutInfo.h"
#import "BSONIdGenerator.h"
#import "TimeConverter.h"
#import "LocationManager.h"
#import "BLEManager.h"

#pragma mark - ShoutDataReceiver

// Text for p2p   -  1
// Image for p2p  -  9
// Gif for p2p    -  21


@implementation ShoutDataReceiver

@end

#pragma mark - ShoutDataReceiver

@implementation ShoutDataSender

@end

#pragma mark - BaseShout

@implementation ShoutHeader

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject : self.shoutId forKey : @"kShoutId"];
    [coder encodeObject : self.ownerId forKey : @"kOwnerId"];
    [coder encodeObject : self.groupId forKey : @"kGroupId"];
    [coder encodeInteger : self.type forKey : @"kType"];
    [coder encodeInteger: self.totalShoutLength forKey:@"kTotalShoutLength"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.shoutId = [decoder decodeObjectForKey  : @"kShoutId"];
    self.ownerId = [decoder decodeObjectForKey  : @"kOwnerId"];
    self.groupId = [decoder decodeObjectForKey  : @"kGroupId"];
    self.type  = [decoder decodeIntegerForKey : @"kType"];
    self.totalShoutLength = [decoder decodeIntegerForKey : @"kTotalShoutLength"];
    return self;
}

@end

#pragma mark - BaseShout

@implementation BaseShout

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger : self.type forKey : @"kType"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.type  = [decoder decodeIntegerForKey : @"kType"];
    return self;
}

@end

#pragma mark - ShoutInfo

@implementation ShoutDetail


- (void)encodeWithCoder:(NSCoder *)coder {
    // [super encodeWithCoder:coder];
    [coder encodeObject  : self.text          forKey : @"kText"];
    [coder encodeObject  : self.content       forKey : @"kContent"];
    [coder encodeInteger : self.timestamp     forKey : @"kTimestamp"];
    [coder encodeObject  : self.parent_shId   forKey : @"kParentShId"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.text        = [decoder decodeObjectForKey  : @"kText"];
        self.content     = [decoder decodeObjectForKey  : @"kContent"];
        self.timestamp   = [decoder decodeIntegerForKey : @"kTimestamp"];
        self.parent_shId = [decoder decodeObjectForKey  : @"kParentShId"];
    }
    return self;
}

@end

#pragma mark - ShoutInfo

@implementation ShoutInfo


- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject  : self.header       forKey : @"kShoutHeader"];
    [coder encodeObject  : self.shout       forKey : @"kShoutObject"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.header     = [decoder decodeObjectForKey  : @"kShoutHeader"];
        self.header     = [decoder decodeObjectForKey  : @"kShoutObject"];
    }
    return self;
}

+ (ShoutInfo *)shoutFrom:(Shout *)sh binaryData:(NSData *)binary {
    ShoutInfo *info = [ShoutInfo new];
    info.type       = (ShoutType) sh.type;
    info.header.type = info.type;
    info.header.shoutId    = sh.shId;
    info.shout.text       = sh.text;
    info.shout.content    = binary;
    info.header.groupId = sh.groupId;
    info.header.ownerId    = sh.owner.user_id;
    info.shout.timestamp  = sh.original_timestamp.integerValue;
    info.shout.parent_shId = (sh.parent_shout) ? sh.parent_shout.shId : nil;
    return info;
}

// my shout
+ (ShoutInfo *)composeText: (NSString *)text
                      type: (ShoutType)type
                   content: (NSData *)content
                   groupId: (NSString *)gId
                parentShId: (NSString *)pShId
                   p2pChat: (BOOL)isP2p
{
    ShoutInfo *sh  = [[ShoutInfo alloc] init];
    sh.header = [[ShoutHeader alloc] init];
    sh.shout = [[ShoutDetail alloc] init];
    sh.header.shoutId     =   [AppManager shoutId];//[BSONIdGenerator generate] ;
    sh.header.ownerId     =  [[NSUserDefaults standardUserDefaults] objectForKey:KOWNER_ID];//[[Global shared] currentUser].user_id;
    sh.shout.type        = type;
    sh.type              = type;
    sh.header.type       = sh.type;
    sh.header.groupId     = gId;
    sh.shout.text        = text;
    sh.shout.timestamp   = [TimeConverter timeStamp];
    sh.shout.parent_shId = pShId;
    sh.shout.content     = content;
    if (sh.shout.type == 0) {
        // text
        if(isP2p)
            sh.header.typeOfMsgSpecialOne = 1;
          else
            sh.header.typeOfMsgSpecialOne = 5;
    }else if (sh.shout.type ==1)
    {
        // Image
        if(isP2p)
            sh.header.typeOfMsgSpecialOne = 9;
        else
            sh.header.typeOfMsgSpecialOne = 29;
    }
    else if(sh.shout.type == 2)
    {
        // Audio
        sh.header.typeOfMsgSpecialOne = 21;
    }
    else if(sh.shout.type == 3)
    {
        // Video
        sh.header.typeOfMsgSpecialOne = 13;
    }
    else if (sh.shout.type ==6)
    {
        // gif
        if(isP2p)
            sh.header.typeOfMsgSpecialOne = 21;
        else
            sh.header.typeOfMsgSpecialOne = 25;
    }
    
    sh.header.loudHailer_Id = [[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID];
    
    return sh;
}

// my old shout
+ (ShoutInfo *)composeExistingText: (NSString *)text
                              type: (ShoutType)type
                           content: (NSData *)content
                           groupId: (NSString *)gId
                        parentShId: (NSString *)pShId
                           shoutId: (NSString *)shId{
    
    ShoutInfo *sh  = [[ShoutInfo alloc] init];
    sh.header = [[ShoutHeader alloc] init];
    sh.shout = [[ShoutDetail alloc] init];
    sh.header.shoutId     = shId;
    sh.header.ownerId     = [[Global shared] currentUser].user_id;
    sh.header.type       = sh.type;
    sh.shout.type        = type;
    sh.type              = type;
    sh.header.groupId     = gId;
    sh.header.type       = type;
    sh.shout.text        = text;
    sh.shout.timestamp   = [TimeConverter timeStamp];
    sh.shout.parent_shId = pShId;
    sh.shout.content     = content;
    return sh;
}

- (void)autoBroadcast
{
    //    [[BLEManager sharedManager] addSh:self toQueueAt:NO];
    //    [[BLEManager sharedManager] addShoutObject:self];
}

@end



#pragma mark - Ping Def
@implementation Ping

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject : self.shoutId        forKey : @"kShoutId"];
    [coder encodeObject : self.ownerId       forKey : @"kOwnerId"];
    [coder encodeObject : self.targetPingId  forKey : @"kTargetPingId"];
    [coder encodeObject : self.responderId   forKey : @"kResponderId"];
    [coder encodeDouble : self.lat           forKey : @"kLatitude"];
    [coder encodeDouble : self.lan           forKey : @"kLangitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ([super initWithCoder:decoder]) {
        self.shoutId       = [decoder decodeObjectForKey : @"kShoutId"];
        self.ownerId      = [decoder decodeObjectForKey : @"kOwnerId"];
        self.targetPingId = [decoder decodeObjectForKey : @"kTargetPingId"];
        self.responderId  = [decoder decodeObjectForKey : @"kResponderId"];
        self.lat          = [decoder decodeDoubleForKey : @"kLatitude"];
        self.lan          = [decoder decodeDoubleForKey : @"kLangitude"];
    }
    return self;
}

+ (Ping *)pingReq {
    
    Ping *req  = [Ping new];
    req.type   = ShoutTypePingReq;
    req.shoutId = [BSONIdGenerator generate];
    req.ownerId = [[[Global shared] currentUser] user_id];
    return req;
}

+ (Ping *)responseFor: (NSString *)userId andPindId:(NSString *)pingId {
    
    Ping *res  = [Ping new];
    res.type   = ShoutTypePingRes;
    res.shoutId = [BSONIdGenerator generate];
    res.ownerId = userId;
    res.responderId = [[[Global shared] currentUser] user_id];
    res.targetPingId = pingId;
    
    // user's location..
    res.lat = [LocationManager latitude];
    res.lan = [LocationManager longitude];
    return res;
}
@end

