//
//  RelayObject.m
//  LH2GO
//
//  Created by Himani Bathla on 14/07/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "RelayObject.h"

@implementation RelayObject
static RelayObject *instance = nil;
//
//+(id)sharedInstance
//{
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{
//        instance = nil;
//        instance = [[RelayObject alloc]init];
//        // instance.delegate = self;
//    });
//    
//    return instance;
//}
- (id) initRelayObjectWithDic : (NSMutableDictionary *)dic {
    self = [super init];
    
    if (self) {
        
        DLog(@"............ is %@",dic);
        self.relayMacId = [dic objectForKey:@"ble_mac"];
        self.relayName = [dic objectForKey:@"relay_name"];
        self.geolocation = [dic objectForKey:@"geo_location"];
        self.bboxType = [dic objectForKey:@"bboxType"];
        DLog(@"*** relay mac id  %@",_relayMacId);
        DLog(@"*** relayName %@",_relayName);
       
    
    }
    
    return self;
}
@end
