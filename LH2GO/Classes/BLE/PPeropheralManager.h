//
//  PPeropheralManager.h
//  TestBluetooth
//
//  Created by Prakash Raj on 19/09/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SERVICES.h"

extern BOOL _isSending;
@protocol PPeropheralManagerDelegate;
@interface PPeropheralManager : NSObject <CBPeripheralManagerDelegate>

//Manoj
// S for Slave
// F for Free Node
@property (nonatomic,strong) NSString *keyToShowSlaveOrFreeNode;
@property (nonatomic,strong) NSString *master_Id1;
@property (nonatomic,strong) NSString *master_Id2;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@property (nonatomic, strong) NSMutableDictionary *recieveQueue;
@property (nonatomic, strong) NSMutableDictionary *recievePingQueue;

@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristicForShoutsWRITE;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristicForSonar;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristicForShoutsUPDATE;


@property (strong, nonatomic) NSMutableArray *connectedCentrals;
@property (strong, nonatomic) NSMutableArray *connectedInProcessCentrals;
@property (nonatomic, assign) id <PPeropheralManagerDelegate> delegate;
@property (strong, nonatomic) NSString *currentShId;
@property (strong, nonatomic) NSString *currentPingShId;
@property (nonatomic, assign) BOOL isCMS;

- (void)advertize;
-(void)stopAdv:(void(^)(BOOL success)) isFinish;
- (void)checkQueue1;
- (void)checkPingQueue;
- (void)cleanupFromCentral;
- (void)flush;
- (void)sendPacket;
-(void)checkMyQueue1;
-(void)sendEventLogToBbox:(NSArray<CBCentral *>*)centrals str:(NSString*)bleStr;
- (CBCentral*)getConnectedCentralFromUUID:(NSString*)uuid;
-(void)getNOtification;

@end



@protocol PPeropheralManagerDelegate <NSObject>
@optional
- (void)didRefreshconnectedCentral;
- (void)didSendshWithId:(NSString *)shId ToUUIDs:(NSArray *)uuids;
- (void)didRecieveSonarData:(ShoutDataReceiver *)data from:(NSString *)uuid fromCentral:(CBCentral*)central forCharectorStic:(CBCharacteristic*)characteristic;
- (void)didRecieveData:(ShoutDataReceiver *)data from:(NSString *)uuid fromCentral:(CBCentral*)central forCharectorStic:(CBCharacteristic*)characteristic;
// delete packet handler
-(void)deletePacketForContent:(NSData *)data;
@end
