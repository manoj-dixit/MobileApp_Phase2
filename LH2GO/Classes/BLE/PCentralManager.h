//
//  PCentralManager.h
//  TestBluetooth
//
//  Created by Prakash Raj on 19/09/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SERVICES.h"
#include <pthread.h>


@protocol PCentralManagerDelegate;

@interface PCentralManager : NSObject <CBCentralManagerDelegate,
CBPeripheralDelegate>
{
    pthread_mutex_t mutexForThread1;
    pthread_mutex_t mutexForThread2;
    pthread_mutex_t mutexForThread3;
    pthread_mutex_t mutexForWrite;
}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBCharacteristic *notifycharacteristic;
@property (nonatomic, strong) NSMutableDictionary *recieveQueue;
@property (nonatomic, strong) NSMutableDictionary *recievePingQueue;

-(void)getNOtification;


@property (strong, nonatomic) NSMutableArray *connectedInProcessPeripherals;

@property (strong, nonatomic) NSString *currentShId;
@property (strong, nonatomic) NSString *currentPingShId;

@property (strong, nonatomic) CBPeripheral     *discoveredPeripheralIs;
@property (strong, nonatomic) NSMutableArray   *connectedDevices;
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, assign) BOOL isCMS;
@property (nonatomic,assign) BOOL isRequestingUserInfo;

@property (strong, nonatomic) NSMutableDictionary *queue1;
@property (strong, nonatomic) NSMutableDictionary *queue2;
@property (strong, nonatomic) NSMutableDictionary *queue3;
@property (strong, nonatomic) NSMutableDictionary *queue4;
@property (strong, nonatomic) NSMutableArray *readyTosendQueue;

@property (nonatomic, assign) BOOL shouldExecuteDispatchBlock;

@property (strong, nonatomic) NSMutableDictionary   *dataHavingValue;

@property (strong, nonatomic) NSMutableDictionary   *dictToHaveConnectionTime;

@property (strong, nonatomic) NSMutableDictionary *dicToNotAllowConnectionForSomeTime;

// variable is used to write or do not write data on buki box
@property (nonatomic,assign) BOOL isWriteDataOnBukiBox;


// to save the devices for connection
@property (strong, nonatomic) NSMutableArray   *listOfDevicesAfterScan;


@property (nonatomic, assign) id <PCentralManagerDelegate> delegate;

- (void)scan;
- (void)cleanup;
-(void)stopScanning:(void (^)(BOOL success)) isComplete;
- (void)flush;
- (void)checkQueue;
-(void)checkMyQueue;
- (void)sendPacket;
-(void)sendMsg;
- (void) clearTransmitQueues;
-(void)methodToDisconnectDuplicateConnection:(NSMutableArray *)value;
-(void)removeAllTheConnectedThread;
-(void)checkPeripheralStatusAfter3Seconds:(CBPeripheral *)per;
@end


@protocol PCentralManagerDelegate <NSObject>
@optional
- (void)updateRecievedShoutData:(CBPeripheral *)peripheral Characteristic:(CBCharacteristic *)characteristic value:(NSData *)data Completion:(void(^)(int value, ShoutDataReceiver *receive)) handler;
- (void)didRecieveSonarData:(ShoutDataReceiver *)data from:(NSString *)uuid fromPeripheral:(CBPeripheral*)peripheral forCharectorStic:(CBCharacteristic*)characteristic;
- (void)didRecieveData:(ShoutDataReceiver *)data from:(NSString *)uuid fromPeripheral:(CBPeripheral*)peripheral forCharectorStic:(CBCharacteristic*)characteristic;
- (void)didRecieveError:(NSError *)error;
- (void)didRfreshedConnectedPeripherals;
- (void)didDisconnectCentral;
// delete packet handler
-(void)deletePacketForContent:(NSData *)data;
@end
