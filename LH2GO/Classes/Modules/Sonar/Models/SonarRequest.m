//
//  SonarRequest.m
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "SonarRequest.h"

@implementation SonarRequest


+ (SonarRequstType)getSonarDataType:(NSData*)sonarData
{
    int type = 0;
    NSData *typeData;
    if (sizeof(type)<sonarData.length)
    {
       typeData  = [NSData dataWithBytes:sonarData.bytes length:sizeof(type)];
        [typeData getBytes:&type length:sizeof(type)];
    }
    
    NSString *test = [[NSString alloc] initWithData:typeData encoding:NSUTF8StringEncoding];
    DLog(@"test is %@",test);
    return (SonarRequstType)type;
}

+ (NSData*)getSonarRequestData:(SonarRequest*)sonarRequest
{
    DLog(@"Sonar ID %@", sonarRequest.sonarId);
    NSMutableData *sonarData = [[NSMutableData alloc] init];
    [sonarData appendData:BOMData()];
    int type = sonarRequest.requstType;
    NSData* data = [NSData dataWithBytes:&type length:sizeof(type)];
    [sonarData appendData:data];
    data = [sonarRequest.sonarId dataUsingEncoding:NSUTF8StringEncoding];
    [sonarData appendData:data];
     [sonarData appendData:EOMData()];
    return sonarData;
}

+ (SonarRequest*)getSonarRequestObject:(NSData*)sonarData
{
    SonarRequest *sonarRequestObject = [[SonarRequest alloc] init];
    int type = 0;
    if (sizeof(type)<sonarData.length)
    {
        NSData *typeData = [NSData dataWithBytes:sonarData.bytes length:sizeof(type)];
        [typeData getBytes:&type length:sizeof(type)];
    }
    sonarRequestObject.requstType = type;
    sonarData = [NSData dataWithBytes:sonarData.bytes+sizeof(type) length:sonarData.length-sizeof(type)];
    if (sonarData.length-EOMLength()>0)
    {
        NSData *sonarIdData = [NSData dataWithBytes:sonarData.bytes length:sonarData.length-EOMLength()];
        sonarRequestObject.sonarId = [[NSString alloc] initWithData:sonarIdData encoding:NSUTF8StringEncoding];
    }
    return sonarRequestObject;
}

@end
