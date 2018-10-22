//
//  ShData.h
//  LoudHailer
//
//  Created by Prakash Raj on 22/12/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShData : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *shId;

+ (ShData *)shDataWithData:(NSData *)data andSenderUUID:(NSString *)uuid
                   shoutId:(NSString *)shId;

- (void)addUUID:(NSString *)uuid;
- (void)addRecievers:(NSArray *)list;
- (NSArray *)restCentralsFrom:(NSArray *)all;

@end
