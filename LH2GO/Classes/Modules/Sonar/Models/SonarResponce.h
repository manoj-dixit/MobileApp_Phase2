//
//  SonarResponce.h
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SonarRequest.h"

@interface SonarResponce : SonarRequest
@property (nonatomic, assign)double latitude;
@property (nonatomic, assign)double longitude;
@property (nonatomic, assign)long long targetUserId;

+ (NSData*)getSonarResponceData:(SonarResponce*)sonarRequest;
+ (SonarResponce*)getSonarResponceObject:(NSData*)sonarData;

@end
