//
//  SonarTracker.h
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

@interface SonarTracker : NSObject
@property (nonatomic, copy)NSString *peripheralID;
@property (nonatomic, copy)NSString *sonarId;
@property(nonatomic,copy)NSMutableArray *responserIdList;

- (void)startSonarTracking;
- (void)startSonarResponseTracking:(NSString*)responderId;
@end
