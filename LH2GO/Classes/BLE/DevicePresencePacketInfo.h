//
//  DevicePresencePacketInfo.h
//  LH2GO
//
//  Created by Manoj Dixit on 27/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEManager.h"
#import "DisplayPresenceList.h"

@interface DevicePresencePacketInfo : NSObject

+(id)sharedInstance;

@property (nonatomic,strong) NSTimer *intiateTimer;
@property (nonatomic,strong) NSMutableData *returnData;
@property int devicePresenceFragmentCount;

@property (nonatomic,strong) NSMutableData *mySendingData;


-(NSData *)toGetTheDevicePresencePacketData:(NSData *)dataValue isDeviceRole:(int)deviceRoleV fragmentCount:(int)fragmentCountV isNeedToUpdate:(BOOL)isValue;
//-(NSData *)updateTheHopeCount:(NSMutableData *)data;
- (NSData *) reversedData:(NSData *)data;
-(BOOL)calculateCRCvalue:(NSData *)dataValue;
-(unsigned char)CRC8:(unsigned char *)ptr length:(unsigned char)len key:(unsigned char)key;
-(void)timerXYZ;
-(NSData *)updateTheFragmentNumber:(NSData *)data;
-(NSData *)updateTheHopeCount:(NSMutableData *)data isFromCentral:(CBCentral *)centralDevice isFromPeripheralDevice:(CBPeripheral *)peripheralDevice;
@end
