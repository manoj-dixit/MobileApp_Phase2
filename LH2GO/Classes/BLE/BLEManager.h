//
//  BLEManager.h
//  TestBluetooth
//
//  Created by Prakash Raj on 18/09/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCentralManager.h"
#import "PPeropheralManager.h"


// device tracking
static NSString *kDeviceCountUpdate     = @"DeviceCountUpdate";
static NSString *kUpdateProgressShout     = @"kUpdateProgressShout";


@class SonarDataInfo;
@class BaseShout;
@class CBPeripheral;

@interface BLEManager : NSObject
{
   // BOOL isToHandleScan;
}


@property (nonatomic, assign)  BOOL isToHandleScan;

@property (nonatomic, assign)  BOOL isScanningFromWakeUP;

@property (nonatomic, assign)  BOOL isSuspendingByOS;

// Declare Private property
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;


@property (nonatomic, strong) NSMutableArray     *highPriorityqueue;    // to handle shouts in pipeline for next.

@property (nonatomic, strong) NSMutableDictionary     *deletePacketDictionary;    // to handle shouts in pipeline for next.

@property (nonatomic, strong) PCentralManager    *centralM; // to gather data from another
@property (nonatomic, strong) PPeropheralManager *perM;     // to send data over BLE.

@property (nonatomic, strong) NSMutableArray *pings;  // all recieved pings will be gathered here
@property (nonatomic, strong) NSMutableDictionary *sonarTrackerQue;  // all recieved pings will be gathered here
@property (nonatomic, strong) NSMutableDictionary *sonarTrackerResponseQue;  // all recieved pings will be gathered here

@property (nonatomic, strong, readonly) NSMutableDictionary *reciever;
@property (nonatomic, assign)BOOL isRefreshBLE;
@property (nonatomic,strong) NSTimer *timerForDuplicateConnection;

@property (nonatomic,strong) NSTimer *scanTimer;
@property (nonatomic,strong) NSTimer *addTimer;

@property (nonatomic,strong) NSTimer *devicePresenceTableTimer;
@property (nonatomic,strong) NSTimer *devicePresenceDeleteTableTimer;


@property (nonatomic,strong) NSOperationQueue *queueForMaster;

@property (nonatomic,strong) NSOperationQueue *queueForSlave;

// gathers all UUID along the shout for whom the shout is sent.

+ (instancetype)sharedManager;

- (void) keepAlive;
-(void)intialScan;
//manoj
-(void)autoScan;
-(void)methodToCall;
- (NSObject *)nextDataForCentral;
-(NSString *)myNextDataForCentral;
- (void)reInitialize;
- (void)removeCentral:(CBPeripheral*)per;
// check BLE is on
- (BOOL)on;
- (void)clearPeripheralOnDisconnect;
- (void)createPeripharal;
// due to network change
- (void)restart;
- (void)flush;
//- (void)startScan;
//- (void)startAd;
-(void)invalidateTimer;
-(void)startAdvertising;
-(void)startScanning;
- (void)startScanAndAdvInBackground;
- (void)startScanAndAdvInForgraound;
-(void)gapBetweenScanAndAdv;
-(void)intialAdvertise;
// quque..
- (NSObject *)nextData;
- (NSObject *)nextPingData;
- (SonarDataInfo *)nextSonarData;
- (NSObject *)myNextData ;
- (void)dequeue;
- (void)addPingSh:(BaseShout *)sh;
- (void)addSh:(BaseShout *)sh toQueueAt:(BOOL)top;
- (void)addUUID:(NSString *)uuid forShId:(NSString *)shId;
- (void)addUUIDs:(NSArray *)uuid forShId:(NSString *)shId;
- (void) addShoutObject : (BaseShout *)sh ;
- (NSInteger)inCount;
- (NSInteger)outCount;
-(void)stopADV;
- (void)brodcastSonarObject:(NSData*)sonarObjectData;
-(void)broadcastDataOverBbox:(NSString*)bleStr;
// delete packet handler
-(void)deletePacketForContent:(NSData *)data;

@end
