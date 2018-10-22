//
//  SonarDataInfo.h
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SonarDataInfo : NSObject
@property (nonatomic, copy)NSData *sonarData;
@property (nonatomic, copy)CBCentral *central;
@end
