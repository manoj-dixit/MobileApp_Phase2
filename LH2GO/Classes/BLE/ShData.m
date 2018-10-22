//
//  ShData.m
//  LoudHailer
//
//  Created by Prakash Raj on 22/12/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "ShData.h"

@interface ShData ()
@property (nonatomic, strong) NSMutableArray *gatheredUUIDS;
@end

@implementation ShData

+ (ShData *)shDataWithData:(NSData *)data andSenderUUID:(NSString *)uuid
                   shoutId:(NSString *)shId {
    ShData *shD = [ShData new];
    shD.shId = shId;
    shD.data = data;
    [shD addUUID:uuid];
    return shD;
}

- (void)addUUID:(NSString *)uuid {
    if (!_gatheredUUIDS)
        _gatheredUUIDS = [NSMutableArray new];
    if (uuid) [_gatheredUUIDS addObject:uuid];
}

- (void)addRecievers:(NSArray *)list {
    
}

- (NSArray *)restCentralsFrom:(NSArray *)all {
    return nil;
}

@end
