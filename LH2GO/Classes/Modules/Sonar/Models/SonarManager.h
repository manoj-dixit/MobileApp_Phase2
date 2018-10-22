//
//  SonarManager.h
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kFinishSonarPingAllReq         = @"kFinishSonarPingAllReq";

@interface SonarManager : NSObject

@property (nonatomic, strong)NSMutableArray *sonarUserResults;
@property (nonatomic, copy)NSString *currectRequstedSonarId;
@property (nonatomic, strong) NSMutableArray *knownCurrentUsers;
@property (nonatomic, strong) NSMutableArray *unKnownCurrentUsers;
@property (nonatomic, assign)double userLatitude;
@property (nonatomic, assign)double userLongitude;

+ (instancetype)sharedManager;
- (void)filterSonarResponceUsers;
- (void)initiateSonarRequest;

@end
