//
//  SonarRequest.h
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SERVICES.h"


typedef enum {
    SonarTypeNone,
    SonarTypeRequest,
    SonarTypeResponce
}SonarRequstType;

@interface SonarRequest : NSObject
@property (nonatomic,assign)SonarRequstType requstType;
@property (nonatomic, copy)NSString *sonarId;

+ (SonarRequstType)getSonarDataType:(NSData*)sonarData;
+ (NSData*)getSonarRequestData:(SonarRequest*)sonarRequest;
+ (SonarRequest*)getSonarRequestObject:(NSData*)sonarData;

@end
