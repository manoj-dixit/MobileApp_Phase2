//
//  SonarResponce.m
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "SonarResponce.h"


@implementation SonarResponce


+ (NSData*)getSonarResponceData:(SonarResponce*)sonarRequest
{
    NSMutableData *sonarData = [[NSMutableData alloc] init];
    [sonarData appendData:BOMData()];
    int type = sonarRequest.requstType;
    NSData* data = [NSData dataWithBytes:&type length:sizeof(type)];
    [sonarData appendData:data];
    double latitude = sonarRequest.latitude;
    data = [NSData dataWithBytes:&latitude length:sizeof(latitude)];
    [sonarData appendData:data];
    double longitude = sonarRequest.longitude;
    data = [NSData dataWithBytes:&longitude length:sizeof(longitude)];
    [sonarData appendData:data];
    long long targetUserId = sonarRequest.targetUserId;
    data = [NSData dataWithBytes:&targetUserId length:sizeof(targetUserId)];
    [sonarData appendData:data];
    data = [sonarRequest.sonarId dataUsingEncoding:NSUTF8StringEncoding];
    [sonarData appendData:data];
    [sonarData appendData:EOMData()];
    DLog(@"#*****#> %@",sonarRequest);
    DLog(@"getSonarResponceData Sonar ID %@", sonarRequest.sonarId);
    return sonarData;
}

+ (SonarResponce*)getSonarResponceObject:(NSData*)sonarData
{
    SonarResponce *sonarResponceObject = [[SonarResponce alloc] init];
    int type = 0;
    if (sizeof(type)<sonarData.length)
    {
        NSData *typeData = [NSData dataWithBytes:sonarData.bytes length:sizeof(type)];
        [typeData getBytes:&type length:sizeof(type)];
    }
    sonarData = [NSData dataWithBytes:sonarData.bytes+sizeof(type) length:sonarData.length-sizeof(type)];
    sonarResponceObject.requstType = type;
    double latitude = 0.0;
    if (sizeof(latitude)<sonarData.length)
    {
        NSData *typeData = [NSData dataWithBytes:sonarData.bytes length:sizeof(latitude)];
        [typeData getBytes:&latitude length:sizeof(latitude)];
    }
    sonarData = [NSData dataWithBytes:sonarData.bytes+sizeof(latitude) length:sonarData.length-sizeof(latitude)];
    sonarResponceObject.latitude = latitude;
    double longitude = 0.0;
    if (sizeof(longitude)<sonarData.length)
    {
        NSData *typeData = [NSData dataWithBytes:sonarData.bytes length:sizeof(longitude)];
        [typeData getBytes:&longitude length:sizeof(longitude)];
    }
    sonarData = [NSData dataWithBytes:sonarData.bytes+sizeof(longitude) length:sonarData.length-sizeof(longitude)];
    sonarResponceObject.longitude = longitude;
    long long targetUserId = 0;
    if (sizeof(targetUserId)<sonarData.length)
    {
        NSData *typeData = [NSData dataWithBytes:sonarData.bytes length:sizeof(targetUserId)];
        [typeData getBytes:&targetUserId length:sizeof(targetUserId)];
    }
    sonarData = [NSData dataWithBytes:sonarData.bytes+sizeof(targetUserId) length:sonarData.length-sizeof(targetUserId)];
    sonarResponceObject.targetUserId = targetUserId;
    if (sonarData.length-EOMLength()>0)
    {
        NSData *sonarIdData = [NSData dataWithBytes:sonarData.bytes length:sonarData.length-EOMLength()];
        sonarResponceObject.sonarId = [[NSString alloc] initWithData:sonarIdData encoding:NSUTF8StringEncoding];
    }
    DLog(@"getSonarResponceObject Sonar ID %@", sonarResponceObject.sonarId);
    return sonarResponceObject;
}

@end
