//
//  RelayObject.h
//  LH2GO
//
//  Created by Himani Bathla on 14/07/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RelayObject : NSObject
@property (strong, nonatomic) NSString * relayMacId;
@property (strong, nonatomic) NSString * relayName;
@property (strong, nonatomic) NSString * geolocation;
@property (strong, nonatomic) NSString * Status;
@property (strong, nonatomic) NSString * bboxType;

- (id) initRelayObjectWithDic : (NSMutableDictionary *)dic;
@end
