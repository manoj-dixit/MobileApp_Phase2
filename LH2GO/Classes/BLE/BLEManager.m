//
//  BLEManager.m
//  TestBluetooth
//
//  Created by Prakash Raj on 18/09/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "BLEManager.h"

#import "ShoutInfo.h"
#import "ShoutManager.h"
#import "DBManager.h"
#import "ShoutManager.h"
#import "SonarRequest.h"
#import "SonarResponce.h"
#import "SonarDataInfo.h"
#import "SonarManager.h"
#import "LocationManager.h"
#import "SonarResponce.h"
#import "SonarTracker.h"
#import "NSData+Base64.h"
#import "CryptLib.h"
#import "UserLocation.h"

#import "DevicePresencePacketInfo.h"

@interface BLEManager ()
<PCentralManagerDelegate, PPeropheralManagerDelegate>{
    
}
@property (nonatomic, strong) NSMutableArray     *lowerPriorityQueue;    // to handle shouts in pipeline for next.
@property (nonatomic, strong) NSMutableArray     *myArray;    // to handle shouts in pipeline for next.
@property (nonatomic, strong) NSMutableArray     *pingQueue;    // to handle shouts in pipeline for next.
@end


@implementation BLEManager

+ (instancetype)sharedManager {
    static BLEManager *sharedManager = nil;
    @synchronized(self) {
        if(!sharedManager)
        {
            // dynamicMTUSize = 20; //shradha
            sharedManager = [[BLEManager alloc] init];
            sharedManager.pings = [NSMutableArray new];
            sharedManager.sonarTrackerQue=[[NSMutableDictionary alloc]init];
            sharedManager.sonarTrackerResponseQue=[[NSMutableDictionary alloc]init];
            sharedManager.isRefreshBLE = YES;
        }
    }
    return sharedManager;
}

- (void)removeCentral:(CBPeripheral*)per{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_perM.connectedCentrals];
    for(CBCentral *cen in tempArr){
        NSString *uuid = [cen.identifier UUIDString];
        if ([uuid isEqualToString:[per.identifier UUIDString]]||per.state != CBPeripheralStateConnected) {
            [tempArr removeObject:cen];
        }
    }
    _perM.connectedCentrals = tempArr;
}

- (void)clearPeripheralOnDisconnect{
    [self removeGarbageData];
    
    [_perM cleanupFromCentral];
}

// clean every thing
- (void)flush {
    [_perM flush];
    _centralM.delegate=nil;
    _perM = nil;
    [_centralM flush];
    _centralM.delegate=nil;
    _centralM=nil;
    [_highPriorityqueue removeAllObjects];
    _highPriorityqueue = nil;
    [_lowerPriorityQueue removeAllObjects];
    _lowerPriorityQueue = nil;
    _myArray  = nil;
    [_myArray removeAllObjects];
    [_pingQueue removeAllObjects];
    _pingQueue=nil;
    [self removeGarbageData];
}

- (void)removeGarbageData{
    [_reciever removeAllObjects];
    _reciever = nil;
    [_pings removeAllObjects];
    _pings = nil;
}

- (void) keepAlive {
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        DLog(@"Manoj");
        self.backgroundTask = UIBackgroundTaskInvalid;
        [self keepAlive];
    }];
}

- (void)startScanAndAdvInForgraound
{
    [self autoScan];
}

- (void)startScanAndAdvInBackground
{
    if ([BLEManager sharedManager].centralM.connectedDevices > 0) {
        [self gapBetweenScanAndAdv];
    }
    else
    {
        [self autoScan];
    }
}

// initialize/reinilize the components
- (void)reInitialize {
    
    if (!self.isRefreshBLE) {
        return;
    }
    self.isRefreshBLE = NO;
    _isToHandleScan = NO;
    
    //   [self flush];
    [self createPeripharal];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self createCentral];
        
    });
    
    // [self setupBackgrounding];
    _highPriorityqueue  = [NSMutableArray new];
    _lowerPriorityQueue = [NSMutableArray new];
    _myArray = [NSMutableArray new];
    _pingQueue = [NSMutableArray new];
    _reciever = [NSMutableDictionary new];
    _deletePacketDictionary = [NSMutableDictionary new];
    _pings = [NSMutableArray new];
    _timerForDuplicateConnection = [NSTimer scheduledTimerWithTimeInterval:getRandomforDiscardDuplicateConnection() target:self selector:@selector(timerToDisconnect) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer: _timerForDuplicateConnection forMode:NSDefaultRunLoopMode];
    _queueForMaster = [[NSOperationQueue alloc] init];
    _queueForSlave = [[NSOperationQueue alloc] init];
    _queueForMaster.maxConcurrentOperationCount = 1;
    _queueForSlave.maxConcurrentOperationCount = 1;
    [BLEManager sharedManager].isScanningFromWakeUP = NO;
}

- (void)createCentral
{
    _centralM = nil;
    _centralM = [[PCentralManager alloc] init];
    _centralM.delegate = self;
}

- (void)createPeripharal
{
    _perM     = nil;
    _perM = [[PPeropheralManager alloc] init];
    _perM.delegate = self;
    
    // timer for sharing the device presence table
    
    DevicePresencePacketInfo *shredIns = [DevicePresencePacketInfo sharedInstance];
    shredIns.devicePresenceFragmentCount = 0;
    
    if(!self.devicePresenceTableTimer)
    {
        [BLEManager sharedManager].devicePresenceTableTimer = [NSTimer scheduledTimerWithTimeInterval:PacketTimeInterval
                                                                                               target:[BLEManager sharedManager]
                                                                                             selector:@selector(methodToCall)
                                                                                             userInfo:nil
                                                                                              repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.devicePresenceTableTimer forMode:NSDefaultRunLoopMode];
    }
    
    
    
//    if(!self.devicePresenceDeleteTableTimer)
//    {
//        [BLEManager sharedManager].devicePresenceDeleteTableTimer = [NSTimer scheduledTimerWithTimeInterval:
//                                                                                               target:[BLEManager sharedManager]
//                                                                                             selector:@selector(methodToCheckDataPresenceEntity)
//                                                                                             userInfo:nil
//                                                                                              repeats:YES];
//
//        [[NSRunLoop mainRunLoop] addTimer:self.devicePresenceDeleteTableTimer forMode:NSDefaultRunLoopMode];
//    }
}

-(void)methodToCall
{
    DevicePresencePacketInfo *shredIns = [DevicePresencePacketInfo sharedInstance];
    shredIns.devicePresenceFragmentCount++;
    NSLog(@"Fragment Count Value is %d",shredIns.devicePresenceFragmentCount);
    
    
    int deviceRole;
    if ([_perM.connectedCentrals count] ==0 && [_centralM.connectedDevices count] >0)
    {
        deviceRole = Device_Role_Master;
    }
    // if working as Slave
    else if([_perM.connectedCentrals count] >0 && [_centralM.connectedDevices count] ==0)
    {
        deviceRole  = Device_Role_Slave;
    }
    else
    {
        deviceRole  = Device_Role_Unknown;
    }
    
    NSData *dataV =  [[DevicePresencePacketInfo sharedInstance] toGetTheDevicePresencePacketData:@"" isDeviceRole:deviceRole fragmentCount:shredIns.devicePresenceFragmentCount isNeedToUpdate:YES];
    shredIns.mySendingData = [dataV mutableCopy];
    
    // central device
    [[[BLEManager sharedManager] centralM] getNOtification];
    
    // peripheral device
    [[[BLEManager sharedManager] perM] getNOtification];
    
    [self methodToCheckDataPresenceEntity];
    
}

-(void)methodToCheckDataPresenceEntity
{
    [DisplayPresenceList checkTheListToDeleteENtry];
}

// check BLE is on
- (BOOL)on
{
    return (self.centralM.centralManager.state == CBCentralManagerStatePoweredOn || self.perM.peripheralManager.state == CBManagerStatePoweredOn);
}

// due to network change.
- (void)restart {
    if  ([self on]) {
        self.isRefreshBLE = YES;
        [self reInitialize];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceCountUpdate object:nil userInfo:nil];
        //        });
    }
}

- (void)autoAd
{
    //    [_centralM stopScanning];
    //
    //
    //
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //        [_perM advertize];
    //        [_addTimer invalidate];
    //        _addTimer = [NSTimer scheduledTimerWithTimeInterval:getRandom()
    //                                                    target:[BLEManager sharedManager]
    //                                                  selector:@selector(autoAd)
    //                                                  userInfo:nil
    //                                                   repeats:NO];
    //
    //    });
}

- (void)autoScan
{
    [self didRefreshconnectedCentral];
    // if working as Master
    if ([_perM.connectedCentrals count] ==0 && [_centralM.connectedDevices count] >0)
    {
        DLog(@"Connected Peri is %@",_centralM.connectedDevices);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
        [self startScanning];
    }
    // if working as Slave
    else if([_perM.connectedCentrals count] >0 && [_centralM.connectedDevices count] ==0)
    {
        DLog(@"Connected centrals is %@",_perM.connectedCentrals);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
        if ([_perM.connectedCentrals count]<SlaveConnection) {
            [self startAdvertising];
        }
    }
    else if([_perM.connectedCentrals count] >0 && [_centralM.connectedDevices count] >0)
    {
        // if both are connected
        if ([_perM.connectedCentrals count] > [_centralM.connectedDevices count])
        {
            [_centralM.connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CBPeripheral *peri = [obj objectForKey:Peripheral_Ref];
                
                for (CBService *service in peri.services)
                {
                    if (service.characteristics != nil) {
                        for (CBCharacteristic *characteristic in service.characteristics) {
                            
                            [peri setNotifyValue:NO forCharacteristic:characteristic];
                            
                        }
                    }
                }
                [_centralM.centralManager cancelPeripheralConnection:peri];
            }];
            
            [_centralM.connectedDevices removeAllObjects];
        }
        else if ([_perM.connectedCentrals count] == [_centralM.connectedDevices count])
        {
            // to make sure all the connection will be break
            
            BOOL isSuccess=false;
            //            do {
            
            isSuccess =  [_perM.peripheralManager updateValue:[@"02owly" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_perM.transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
            
            //  }
            //while (isSuccess);
            
            [_perM.connectedCentrals removeAllObjects];
            
        }
        else
        {
            // to make sure all the connection will be break
            BOOL isSuccess=false;
            //            do {
            
            isSuccess =  [_perM.peripheralManager updateValue:[@"02owly" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_perM.transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
            
            //            } while (isSuccess);
            
            [_perM.connectedCentrals removeAllObjects];
        }
         [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
    }
    else
    {
        DevicePresencePacketInfo *shredIns = [DevicePresencePacketInfo sharedInstance];
        shredIns.devicePresenceFragmentCount = 0;

        [_perM sendPacket];
        [_centralM sendPacket];
        
        [_centralM removeAllTheConnectedThread];
        [_perM.recieveQueue removeAllObjects];
        [_centralM.recieveQueue removeAllObjects];
        
        [_perM.connectedCentrals removeAllObjects];
        [_centralM.connectedDevices removeAllObjects];
        
        // else no one is connected yest
        if(!_isToHandleScan)
        {
            // first advertise
            [self startAdvertising];
            _isToHandleScan = YES;
        }
        else
        {
            // scan
            [self startScanning];
            _isToHandleScan = NO;
        }
    }
}

-(void)intialAdvertise
{
    if([self on])
    {
        [_perM stopAdv:^(BOOL success) {
            
            if (success) {
                
         
        [_centralM stopScanning:^(BOOL success) {
            
            if (success)
            {
            DLog(@"***********SCANNING STOPPED***************");
            
            if ([self on])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_perM advertize];
                    [_addTimer invalidate];
                    
                    _addTimer = nil;
                    _addTimer = [NSTimer scheduledTimerWithTimeInterval:getRandomForAdv()
                                                                 target:[BLEManager sharedManager]
                                                               selector:@selector(autoScan)
                                                               userInfo:nil
                                                                repeats:NO];
                    _isToHandleScan = YES;
                    [[NSRunLoop mainRunLoop] addTimer: _addTimer forMode:NSDefaultRunLoopMode];
                });
            }
            }
        }];
            }
        }];
    }
}

-(void)startAdvertising
{
    [self didRefreshconnectedCentral];
    if([self on])
    {
        [_perM stopAdv:^(BOOL success) {
            if (success) {
                
  
                DLog(@"***********ADVERTISING STOPPED***************");

        if (_centralM.centralManager.isScanning) {
            [_centralM stopScanning:^(BOOL success) {
                
                if (success)
                {
                DLog(@"***********SCANNING STOPPED***************");
                if ([self on])
                {
                    DLog(@"Manoj Dixit +++ %d",[BLEManager sharedManager].isScanningFromWakeUP);
                    if(![BLEManager sharedManager].isScanningFromWakeUP)
                    {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [_perM advertize];
                        [_addTimer invalidate];
                        _addTimer = nil;
                        _addTimer = [NSTimer scheduledTimerWithTimeInterval:getRandomForAdv()
                                                                     target:[BLEManager sharedManager]
                                                                   selector:@selector(autoScan)
                                                                   userInfo:nil
                                                                    repeats:NO];
                        _isToHandleScan = YES;
                        [[NSRunLoop mainRunLoop] addTimer: _addTimer forMode:NSDefaultRunLoopMode];
                    });
                    }
                    else
                    {
                        NSLog(@"Waking up from Background");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            _centralM.shouldExecuteDispatchBlock = YES;
                            
                            [_addTimer invalidate];
                            _addTimer = nil;
                            
                            [_scanTimer invalidate];
                            _scanTimer = nil;
                            [_centralM scan];
                            _scanTimer = [NSTimer scheduledTimerWithTimeInterval:9
                                                                          target:[BLEManager sharedManager]
                                                                        selector:@selector(intialScan)
                                                                        userInfo:nil
                                                                         repeats:NO];
                            _isToHandleScan = NO;
                            [[NSRunLoop mainRunLoop] addTimer: _scanTimer forMode:NSDefaultRunLoopMode];
                        });
                    }
                }
            }
            }];
        }
        else
        {
            if ([self on])
            {
                DLog(@"Manoj Dixit +++ %d",[BLEManager sharedManager].isScanningFromWakeUP);

                if(![BLEManager sharedManager].isScanningFromWakeUP)
                {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_perM advertize];
                    [_addTimer invalidate];
                    _addTimer = nil;
                    _addTimer = [NSTimer scheduledTimerWithTimeInterval:getRandomForAdv()
                                                                 target:[BLEManager sharedManager]
                                                               selector:@selector(autoScan)
                                                               userInfo:nil
                                                                repeats:NO];
                    _isToHandleScan = YES;
                    [[NSRunLoop mainRunLoop] addTimer: _addTimer forMode:NSDefaultRunLoopMode];
                });
                }
                else
                {
                    NSLog(@"Waking up from Background");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _centralM.shouldExecuteDispatchBlock = YES;
                        
                        [_addTimer invalidate];
                        _addTimer = nil;
                        
                        [_scanTimer invalidate];
                        _scanTimer = nil;
                        [_centralM scan];
                        _scanTimer = [NSTimer scheduledTimerWithTimeInterval:9
                                                                      target:[BLEManager sharedManager]
                                                                    selector:@selector(intialScan)
                                                                    userInfo:nil
                                                                     repeats:NO];
                        _isToHandleScan = NO;
                        [[NSRunLoop mainRunLoop] addTimer: _scanTimer forMode:NSDefaultRunLoopMode];
                         });
                }
            }
        }
            }
        }];
    }
}

-(void)gapBetweenScanAndAdv
{
    if ([self on]) {
        if ([_perM.connectedCentrals count] < 2 && [_perM.connectedCentrals count] >0)  {
            
            [self startAdvertising];
        }
        else
        {
            
            [_centralM stopScanning:^(BOOL success) {
                
                if (success) {
                    
               
            
            [_perM stopAdv:^(BOOL success) {
                
                DLog(@"***********ADD STOPPED***************");
                
                if (success) {
            
                if ([self on]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //  [_centralM isScanning];
                        _centralM.shouldExecuteDispatchBlock = YES;
                        
                        [_addTimer invalidate];
                        _addTimer = nil;
                        
                        [_scanTimer invalidate];
                        _scanTimer = nil;
                        [_centralM scan];
                        _scanTimer = [NSTimer scheduledTimerWithTimeInterval:getRandomforScan()
                                                                      target:[BLEManager sharedManager]
                                                                    selector:@selector(autoScan)
                                                                    userInfo:nil
                                                                     repeats:NO];
                        _isToHandleScan = NO;
                        [[NSRunLoop mainRunLoop] addTimer:_scanTimer forMode:NSDefaultRunLoopMode];
                    });
                }
            }
            }];
                }
                  }];
        }
    }
}

//-(void)stopADV
//{
//    if ([self on]) {
//        [_perM stopAdv:^(BOOL success) {
//
//        }];
//    }
//}

-(void)intialScan
{
    [_perM stopAdv:^(BOOL success) {
        
        if(success)
        {
            
      
        // Adv stop
        NSLog(@"************ STOP ADVERTISONG AS APP IS IN BACKGROUND AND GOING TO SUSPENDED MODE**************");
  
    
    [_centralM stopScanning:^(BOOL success) {
        
        if (success) {
            
   
    
    if ([self on])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DLog(@"Manoj kumar dixit ++++ %d",[BLEManager sharedManager].isScanningFromWakeUP);
            
            if([BLEManager sharedManager].isScanningFromWakeUP)
            {
            _centralM.shouldExecuteDispatchBlock = YES;
            
            [_addTimer invalidate];
            _addTimer = nil;
            
            [_scanTimer invalidate];
            _scanTimer = nil;
                
                [_centralM scan];
            _scanTimer = [NSTimer scheduledTimerWithTimeInterval:9
                                                          target:[BLEManager sharedManager]
                                                        selector:@selector(intialScan)
                                                        userInfo:nil
                                                         repeats:NO];
            _isToHandleScan = NO;
            [[NSRunLoop mainRunLoop] addTimer: _scanTimer forMode:NSDefaultRunLoopMode];
            }else
            {
                [self startAdvertising];
            }
        });
    }
        }
    }];
        }
    }];
}

-(void)startScanning
{
    [self didRefreshconnectedCentral];
    if ([self on])
    {
        [_centralM stopScanning:^(BOOL success) {
         
            if (success) {
                
      
        
        if ([_centralM.connectedDevices count] >0) {
            
            if (_perM.peripheralManager.isAdvertising) {
                
                [_perM stopAdv:^(BOOL success) {
                    
                    if (success) {
                        
                   
                    DLog(@"************* STOP ADVERTISING**************");
                    
                    if ([self on])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _centralM.shouldExecuteDispatchBlock = YES;
                            
                            [_scanTimer invalidate];
                            _scanTimer = nil;
                            
                            [_addTimer invalidate];
                            _addTimer = nil;
                            [_centralM scan];
                            _scanTimer = [NSTimer scheduledTimerWithTimeInterval:getRandomforScan()
                                                                          target:[BLEManager sharedManager]
                                                                        selector:@selector(autoScan)
                                                                        userInfo:nil
                                                                         repeats:NO];
                            _isToHandleScan = NO;
                            [[NSRunLoop mainRunLoop] addTimer: _scanTimer forMode:NSDefaultRunLoopMode];
                        });
                    }
                         }
                }];
            }else
            {
                if ([self on])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _centralM.shouldExecuteDispatchBlock = YES;
                        
                        [_scanTimer invalidate];
                        _scanTimer = nil;
                        
                        [_addTimer invalidate];
                        _addTimer = nil;
                        [_centralM scan];
                        _scanTimer = [NSTimer scheduledTimerWithTimeInterval:getRandomforScan()
                                                                      target:[BLEManager sharedManager]
                                                                    selector:@selector(autoScan)
                                                                    userInfo:nil
                                                                     repeats:NO];
                        _isToHandleScan = NO;
                        [[NSRunLoop mainRunLoop] addTimer: _scanTimer forMode:NSDefaultRunLoopMode];
                    });
                }
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{

            [_addTimer invalidate];
            _addTimer = nil;
            [_scanTimer invalidate];
            _scanTimer = nil;
            
            DLog(@"#########GAP#############");
            _addTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                         target:[BLEManager sharedManager]
                                                       selector:@selector(gapBetweenScanAndAdv)
                                                       userInfo:nil
                                                        repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer: _addTimer forMode:NSDefaultRunLoopMode];
                 });
        }
            }
        }];
    }
}

-(void)invalidateTimer
{
    [_scanTimer invalidate];
    _scanTimer = nil;
}

#pragma mark - Queue

- (NSObject *)nextDataForCentral
{
    if(_highPriorityqueue.count>0) {
        NSObject *shObj = [_highPriorityqueue firstObject];
        NSData *data =  nil;
        if ([shObj isKindOfClass:[ShoutInfo class]]) {
            ShoutInfo *shi = (ShoutInfo*)shObj;
            DLog(@"SHID is %@",shi.header.shoutId);
            DLog(@"vvvv is %@",_centralM.currentShId);
            
            if ([shi.header.shoutId containsString:[NSString stringWithFormat:@"%d",[AppManager convertIntFromString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID]]]]) {
                
                shi.header.shoutId =   [shi.header.shoutId stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d",[AppManager convertIntFromString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID]]] withString:@""];
                
            }
            //_centralM.currentShId = shi.header.shoutId;
            data = [ShoutManager dataFromObjectForShout:shi];
            if(_highPriorityqueue.count>0)
                [_highPriorityqueue removeObjectAtIndex:0];
            ShoutDataSender *shDataToSend = [[ShoutDataSender alloc] init];
            shDataToSend.totalShoutLength = data.length;
            shDataToSend.type = shi.header.type;
            shDataToSend.shId = shi.header.shoutId;
            shDataToSend.typeOfMsgSpecialByte =  shi.header.typeOfMsgSpecialOne;
            shDataToSend.shoutData = data;
            shDataToSend.loudHailer_Id  = shi.header.loudHailer_Id;
            shDataToSend.fragmentNO    = 0;
            return shDataToSend;
        }
        else if ([shObj isKindOfClass:[ShoutDataReceiver class]]) {
            ShoutDataReceiver *shD = (ShoutDataReceiver*)shObj;
            _centralM.currentShId = shD.header.shoutId;
            if(_highPriorityqueue.count>0)
                [_highPriorityqueue removeObjectAtIndex:0];
            return shD;
        }
    }
    else if(_lowerPriorityQueue.count>0){
        NSObject *shObj = [_lowerPriorityQueue firstObject];
        NSData *data =  nil;
        if ([shObj isKindOfClass:[ShoutInfo class]]) {
            ShoutInfo *shi = (ShoutInfo*)shObj;
            _centralM.currentShId = shi.header.shoutId;
            data = [ShoutManager dataFromObjectForShout:shi];
            if(_lowerPriorityQueue.count>0)
                [_lowerPriorityQueue removeObjectAtIndex:0];
            ShoutDataSender *shDataToSend = [[ShoutDataSender alloc] init];
            shDataToSend.totalShoutLength = data.length;
            shDataToSend.type = shi.header.type;
            shDataToSend.shId = shi.header.shoutId;
            shDataToSend.shoutData = data;
            return shDataToSend;
        }
        else if ([shObj isKindOfClass:[ShoutDataReceiver class]]) {
            ShoutDataReceiver *shD = (ShoutDataReceiver*)shObj;
            _centralM.currentShId = shD.header.shoutId;
            if(_lowerPriorityQueue.count>0)
                [_lowerPriorityQueue removeObjectAtIndex:0];
            return shD;
        }
    }
    return nil;
}

-(NSString *)myNextDataForCentral{
    if (_myArray.count > 0) {
        NSObject *shObj = [_myArray firstObject];
        NSData *data =  nil;
        if ([shObj isKindOfClass:[ShoutInfo class]]) {
            ShoutInfo *shi = (ShoutInfo*)shObj;
            _centralM.currentShId = shi.header.shoutId;
            data = [ShoutManager dataFromObjectForShout:shi];
            if(_myArray.count>0)
                [_myArray removeObjectAtIndex:0];
            ShoutDataSender *shDataToSend = [[ShoutDataSender alloc] init];
            shDataToSend.totalShoutLength = data.length;
            shDataToSend.type = shi.header.type;
            shDataToSend.shId = shi.header.shoutId;
            shDataToSend.shoutData = data;
            return shDataToSend;
        }
        else if ([shObj isKindOfClass:[ShoutDataReceiver class]]) {
            ShoutDataReceiver *shD = (ShoutDataReceiver*)shObj;
            _centralM.currentShId = shD.header.shoutId;
            if(_highPriorityqueue.count>0)
                [_myArray removeObjectAtIndex:0];
            return shD;
        }
    }
    return nil;
}

- (NSObject *)nextData {
    if(_highPriorityqueue.count>0) {
        NSObject *shObj = [_highPriorityqueue firstObject];
        NSData *data =  nil;
        if ([shObj isKindOfClass:[ShoutInfo class]]) {
            ShoutInfo *shi = (ShoutInfo*)shObj;
            // _perM.currentShId = shi.header.shoutId;
            data = [ShoutManager dataFromObjectForShout:shi];
            if(_highPriorityqueue.count>0)
                [_highPriorityqueue removeObjectAtIndex:0];
            ShoutDataSender *shDataToSend = [[ShoutDataSender alloc] init];
            shDataToSend.totalShoutLength = data.length;
            shDataToSend.typeOfMsgSpecialByte =  shi.header.typeOfMsgSpecialOne;
            shDataToSend.type = shi.header.type;
            shDataToSend.shId = shi.header.shoutId;
            shDataToSend.shoutData = data;
            shDataToSend.loudHailer_Id  = shi.header.loudHailer_Id;
            shDataToSend.fragmentNO    = 0;
            return shDataToSend;
        }
        else if ([shObj isKindOfClass:[ShoutDataReceiver class]]) {
            ShoutDataReceiver *shD = (ShoutDataReceiver*)shObj;
            _perM.currentShId = shD.header.shoutId;
            if(_highPriorityqueue.count>0)
                [_highPriorityqueue removeObjectAtIndex:0];
            return shD;
        }
    }
    else if(_lowerPriorityQueue.count>0){
        NSObject *shObj = [_lowerPriorityQueue firstObject];
        NSData *data =  nil;
        if ([shObj isKindOfClass:[ShoutInfo class]]) {
            ShoutInfo *shi = (ShoutInfo*)shObj;
            _perM.currentShId = shi.header.shoutId;
            data = [ShoutManager dataFromObjectForShout:shi];
            if(_lowerPriorityQueue.count>0)
                [_lowerPriorityQueue removeObjectAtIndex:0];
            ShoutDataSender *shDataToSend = [[ShoutDataSender alloc] init];
            shDataToSend.totalShoutLength = data.length;
            shDataToSend.type = shi.header.type;
            shDataToSend.shId = shi.header.shoutId;
            shDataToSend.shoutData = data;
            return shDataToSend;
        }
        else if ([shObj isKindOfClass:[ShoutDataReceiver class]]) {
            ShoutDataReceiver *shD = (ShoutDataReceiver*)shObj;
            _perM.currentShId = shD.header.shoutId;
            if(_lowerPriorityQueue.count>0)
                [_lowerPriorityQueue removeObjectAtIndex:0];
            return shD;
        }
    }
    return nil;
}

-(NSString *)myNextData{
    if (_myArray.count > 0) {
        NSObject *shObj = [_myArray firstObject];
        NSData *data =  nil;
        if ([shObj isKindOfClass:[ShoutInfo class]]) {
            ShoutInfo *shi = (ShoutInfo*)shObj;
            _perM.currentShId = shi.header.shoutId;
            data = [ShoutManager dataFromObjectForShout:shi];
            if(_myArray.count>0)
                [_myArray removeObjectAtIndex:0];
            ShoutDataSender *shDataToSend = [[ShoutDataSender alloc] init];
            shDataToSend.totalShoutLength = data.length;
            shDataToSend.type = shi.header.type;
            shDataToSend.shId = shi.header.shoutId;
            shDataToSend.shoutData = data;
            return shDataToSend;
        }
        else if ([shObj isKindOfClass:[ShoutDataReceiver class]]) {
            ShoutDataReceiver *shD = (ShoutDataReceiver*)shObj;
            _perM.currentShId = shD.header.shoutId;
            if(_highPriorityqueue.count>0)
                [_myArray removeObjectAtIndex:0];
            return shD;
        }
    }
    return nil;
}

- (void)dequeue {
    
}

- (void)addSh:(BaseShout *)sh toQueueAt:(BOOL)top
{
    if(!sh) return;
    
    if(top) {
        [_highPriorityqueue addObject:sh];
        DLog(@"Higher priority queue is %@",_highPriorityqueue);
        
    } else {
        [_lowerPriorityQueue addObject:sh];
    }
    
    if ([self inCount] > 0) {
        
        [_centralM checkQueue];
        
    }
    else if([self outCount] >0)
    {
        [_perM checkQueue1];
    }
}

- (void) addShoutObject : (BaseShout *)sh {
    if(!sh) return;
    
    if(_isSending)return;
    [_myArray addObject:sh];
    
    if ([self inCount] > 0) {
        
        [_centralM checkMyQueue];
        
    }
    else if([self outCount] >0)
    {
        [_perM checkMyQueue1];
    }
    
    //    [_perM checkMyQueue];
    
}

- (void)addPingSh:(BaseShout *)sh{
    [_pingQueue addObject:sh];
    [_perM checkPingQueue];
}

- (void)addSonarDataInQue:(SonarDataInfo *)sonarInfo{
    [_pingQueue addObject:sonarInfo];
    [_perM checkPingQueue];
}

- (SonarDataInfo *)nextSonarData {
    if (_pingQueue == nil) {
        return nil;
    }
    if(_pingQueue.count>0) {
        SonarDataInfo *sonarInfoObject = [_pingQueue firstObject];
        [_pingQueue removeObjectAtIndex:0];
        return sonarInfoObject;
    }
    return nil;
}


- (NSObject *)nextPingData{
    if (_pingQueue == nil) {
        return nil;
    }
    if(_pingQueue.count) {
        NSObject *shObj = [_pingQueue firstObject];
        NSData *data =  nil;
        SonarDataInfo *psh = (SonarDataInfo*)shObj;
        data = psh.sonarData;
        if(_pingQueue.count>0)
            [_pingQueue removeObjectAtIndex:0];
        return data;
    }
    return nil;
}


- (void)addShoutPacket:(ShoutDataReceiver *)pckData{
    
    if(!pckData || pckData.doNotForwadIt) return;
    
    if (![_highPriorityqueue containsObject:pckData]) {
        [_highPriorityqueue addObject:pckData];
        
        if (_centralM.connectedDevices>0) {
            
            [_centralM checkQueue];
            
        }
        else if(_perM.connectedCentrals >0)
        {
            [_perM checkQueue1];
        }
    }
}

- (void)addUUID:(NSString *)uuid forShId:(NSString *)shId {
    
    if(!uuid) return;
    
    NSMutableArray *list = [_reciever objectForKey:shId];
    if(!list)
        list = [NSMutableArray new];
    if (![list containsObject:uuid]) {
        [list addObject:uuid];
    }
    [_reciever setObject:list forKey:shId];
}

- (void)addUUIDs:(NSArray *)uuids forShId:(NSString *)shId {
    
    if(!uuids) return;
    
    for(NSString *uuid in uuids){
        [self addUUID:uuid forShId:shId];
    }
}

- (NSInteger)inCount
{
    return _centralM.connectedDevices.count;
}

- (NSInteger)outCount {
    return _perM.connectedCentrals.count;
}

-(void)broadcastDataOverBbox:(NSString*)bleStr
{
    NSMutableArray *listOfBukiBoxes = [[NSMutableArray alloc]init];
    
    if([_perM.connectedCentrals count] > 0){
        for (CBCentral *cen in _perM.connectedCentrals){
            DLog(@"name is %lu",(unsigned long)cen.maximumUpdateValueLength);
            
            if(cen.maximumUpdateValueLength == 20){
                [listOfBukiBoxes addObject:cen];
                [_perM sendEventLogToBbox:listOfBukiBoxes str:bleStr];
            }
            else{}
        }
    }
}

#pragma mark - PCentralManagerDelegate

- (void)didRecieveData:(ShoutDataReceiver *)receiver from:(NSString *)uuidV fromPeripheral:(CBPeripheral*)peripheralV forCharectorStic:(CBCharacteristic*)characteristic1
{
    ShoutDataReceiver *data  = receiver;
    [_queueForMaster addOperationWithBlock:^{
        
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"]invertedSet];
        
        if ([data.header.shoutId rangeOfCharacterFromSet:set].location != NSNotFound) {
            
            NSArray *totalShouts = [DBManager entities:@"Shout" pred:nil descr:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES] isDistinctResults:NO];
            
            if(totalShouts.count > 0){
                Shout *newSht = totalShouts[totalShouts.count - 1];
                
                data.header.shoutId = newSht.shId;
            }
        }
        
        NSMutableData *actualData = [[NSMutableData alloc] init];
        [data.packetArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if (idx != 0)
             {
                 NSData *d  = [obj objectForKey:@"Data"];
                 [actualData appendData:d];
             }
             
         }];
        // data.shoutData = nil;
        if (actualData.length==0) {
            return;
        }
        
        ShoutInfo *sh = [[ShoutInfo alloc] init];
        ShoutDetail *dt  = [[ShoutDetail alloc] init];
        sh.header.uniqueID = data.header.uniqueID;
        if (data.header.typeOfMsgSpecialOne ==72) {
            
            // CMS
            NSString *string =   [ShoutManager stringFromEncodedData:[actualData subdataWithRange:NSMakeRange(9, [actualData length]-9)]];
            
            DLog(@"SEnding Text Is %@",string);
            //        sh.shout = (ShoutDetail *)data;
            //        sh.header = data.header;
            
            dt.text  = string;
            
            dt.mediaPath  = nil;
            dt.timestamp = KAppDisplayTime;
            
            dt.content  = nil;
            dt.parent_shId = 0;
            
            sh.header = data.header;
            sh.header.isMsgFromCMS = YES;
            sh.header.cms_Id = receiver.cmsID;
            sh.type = data.header.type;
            sh.shout = dt;
            //        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CMS"];
            //        [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        else if (data.header.typeOfMsgSpecialOne ==74 || data.header.typeOfMsgSpecialOne ==73)
        {
            // CMS
            NSData *mediaData  = [ShoutManager mediaFromEncodedData:[actualData subdataWithRange:NSMakeRange(9, [actualData length]-9)]];
            
            dt.text  = nil;
            dt.mediaPath  = nil;
            dt.timestamp = KAppDisplayTime;
            
            dt.content  = mediaData;
            dt.parent_shId = 0;
            
            sh.header = data.header;
            sh.type = data.header.type;
            sh.header.isMsgFromCMS = YES;
            sh.header.cms_Id = receiver.cmsID;
            sh.shout = dt;
            //        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CMS"];
            //        [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        else if(data.header.typeOfMsgSpecialOne ==176)
        {
            // CHannel
            NSDictionary *dc  = [[NSDictionary alloc] initWithObjectsAndKeys:data.packetArrayForChannelMsg,@"Data",data.header.uniqueID,@"Key", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AA" object:nil userInfo:dc];
            
            DLog(@"CHANNEL DATA NOTIFICATION CALLED");
            
            return;
        }
        else
        {
            // IPHONE TO IPHONE
            if (actualData.length<23) {
                return;
            }
            
            DLog(@"User name data is %@",[[actualData subdataWithRange:NSMakeRange(0,kUser_Name_Length)] mutableCopy]);
            
            NSString *username = [[NSString alloc] initWithData:[actualData subdataWithRange:NSMakeRange(0,kUser_Name_Length)] encoding:NSUTF8StringEncoding];
            
            DLog(@"User name is %@",username);
            
            data.shoutData = [[actualData subdataWithRange:NSMakeRange(kReject_Length+kUser_Name_Length,[actualData length]-EOM_Length-kReject_Length-kUser_Name_Length)] mutableCopy];
            
            // Shout..
            sh.shout = (ShoutDetail *)data;
            sh.header = data.header;
            
            NSData *textdata  = [data.shoutData subdataWithRange:NSMakeRange(0,[data.shoutData length])];
            NSData *finalData = [ShoutManager decryptData:textdata];//keyy  to key
            //  NSString *headerString  = [[NSString alloc] initWithData:finalData encoding:NSUTF8StringEncoding];
            
            if (finalData.length>0 && finalData.length>finalData.length)
            {
                return;
            }
            
            NSUInteger index=0;
            
            UInt8 bytes_to_find[] = { 0x2b, 0x7c ,0x7c};
            NSData *dataToFind = [NSData dataWithBytes:bytes_to_find
                                                length:sizeof(bytes_to_find)];
            
            NSRange range = [finalData rangeOfData:dataToFind
                                           options:kNilOptions
                                             range:NSMakeRange(0u, [finalData length])];
            
            if (range.location == NSNotFound) {
                DLog(@"Bytes not found");
            }
            else {
                DLog(@"Bytes found at position %lu", (unsigned long)range.location);
                index = range.location;
            }
            
            if (index >= finalData.length) {
                return;
            }
            
            NSData *textData  = [finalData subdataWithRange:NSMakeRange(0,index)];
            NSData *mediaData = [finalData subdataWithRange:NSMakeRange(index+3,[finalData length]-index-3)];
            
            if (textData.length==0 && !mediaData) {
                return;
            }
            
            BOOL isFound = false;
            NSUInteger nextIndex = 0;
            
            if (mediaData.length>0 && mediaData.length>dataToFind.length) {
                //    UInt8 nextBytes_to_find[] = { 0x2b, 0x7c ,0x7c};
                //            NSData *nextDataToFind = [NSData dataWithBytes:bytes_to_find
                //                                                    length:sizeof(bytes_to_find)];
                
                NSRange rangeOf = [mediaData rangeOfData:dataToFind
                                                 options:kNilOptions
                                                   range:NSMakeRange(0u, [mediaData length])];
                
                if (rangeOf.location == NSNotFound) {
                    NSLog(@"Bytes not found");
                    
                }
                else {
                    DLog(@"Bytes found at position %lu", (unsigned long)rangeOf.location);
                    nextIndex = rangeOf.location;
                    isFound = YES;
                }
            }
            
            dt.text  = [[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding];//[sepratorArray objectAtIndex:0];
            dt.timestamp = 0;
            dt.parent_shId = 0;
            
            if (isFound)
            {
                dt.content = [mediaData subdataWithRange:NSMakeRange(0,nextIndex)];
                dt.mediaPath = [[NSString alloc] initWithData:[mediaData subdataWithRange:NSMakeRange(nextIndex+3,[mediaData length]-nextIndex-3)] encoding:NSUTF8StringEncoding];
            }
            else
            {
                if (mediaData.length>0) {
                    dt.content = mediaData; //subdataWithRange:NSMakeRange(0,nextIndex)];
                    dt.mediaPath = nil;
                }
                else
                {
                    dt.content = mediaData; //subdataWithRange:NSMakeRange(0,nextIndex)];
                    dt.mediaPath = nil;
                }
            }
            sh.header = data.header;
            sh.header.isMsgFromCMS = NO;
            sh.type = data.header.type;
            sh.shout = dt;
            sh.shout.userName = username;
        }
        
        if(sh.shout&&sh.header) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // check the shout duplicacy.x
                // already recieved. local use
                [[ShoutManager sharedManager] enqueueShout:sh forUpdation:YES];
            });
        }
        
        if (data.isPacketHeaderFound&&data.isLastChunk) {
            //    if (data.header.totalShoutLength <= shoutInfoData.length && baseSh == nil) {
            [[ShoutManager sharedManager] clearInProgressGarbageShoute:data.header.shoutId];
            return;
        }
    }];
}

- (void)didRecieveData:(ShoutDataReceiver *)receiver from:(NSString *)uuid fromCentral:(CBCentral*)central forCharectorStic:(CBCharacteristic*)characteristic
{
    ShoutDataReceiver *data  = receiver;
    //    CBPeripheral *peripheral   = peripheralV;
    //    NSString       * uuid            = uuidV;
    
    [_queueForSlave addOperationWithBlock:^{
        
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"]invertedSet];
        
        if ([data.header.shoutId rangeOfCharacterFromSet:set].location != NSNotFound) {
            
            NSArray *totalShouts = [DBManager entities:@"Shout" pred:nil descr:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES] isDistinctResults:NO];
            
            if(totalShouts.count > 0){
                Shout *newSht = totalShouts[totalShouts.count - 1];
                
                data.header.shoutId = newSht.shId;
            }
        }
        
        NSMutableData *actualData = [[NSMutableData alloc] init];
        [data.packetArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if (idx != 0)
             {
                 NSData *d  = [obj objectForKey:@"Data"];
                 [actualData appendData:d];
             }
         }];
        //data.shoutData = nil;
        if (actualData.length==0) {
            return;
        }
        
        ShoutInfo *sh = [[ShoutInfo alloc] init];
        ShoutDetail *dt  = [[ShoutDetail alloc] init];
        sh.header.uniqueID = data.header.uniqueID;
        if (data.header.typeOfMsgSpecialOne ==72) {
            
            
            NSString *string =   [ShoutManager stringFromEncodedData:[actualData subdataWithRange:NSMakeRange(9, [actualData length]-9)]];
            
            DLog(@"SEnding Text Is %@",string);
            //        sh.shout = (ShoutDetail *)data;
            //        sh.header = data.header;
            
            dt.text  = string;
            dt.mediaPath  = nil;
            dt.timestamp = KAppDisplayTime;
            
            dt.content  = nil;
            dt.parent_shId = 0;
            
            sh.header = data.header;
            sh.header.isMsgFromCMS = YES;
            sh.type = data.header.type;
            sh.shout = dt;
            sh.header.cms_Id = receiver.cmsID;
            //        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CMS"];
            //        [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        else if (data.header.typeOfMsgSpecialOne ==74 || data.header.typeOfMsgSpecialOne ==73)
        {
            
            NSData *mediaData  = [ShoutManager mediaFromEncodedData:[actualData subdataWithRange:NSMakeRange(9, [actualData length]-9)]];
            
            // UIImage *receiveImage  = [UIImage imageWithData:mediaData];
            //        if (receiveImage == nil) {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //
            //                [AppManager showAlertWithTitle:@"Alert!" Body:@"Not Proper Image"];
            //
            //
            //            });
            //            return;
            //        }
            
            dt.text  = nil;
            dt.mediaPath  = nil;
            dt.timestamp = KAppDisplayTime;
            
            dt.content  = mediaData;
            dt.parent_shId = 0;
            
            sh.header = data.header;
            sh.header.isMsgFromCMS = YES;
            sh.type = data.header.type;
            sh.shout = dt;
            sh.header.cms_Id = receiver.cmsID;
            //        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CMS"];
            //        [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if(data.header.typeOfMsgSpecialOne ==176)
        {
            // CHannel
            NSDictionary *dc  = [[NSDictionary alloc] initWithObjectsAndKeys:data.packetArrayForChannelMsg,@"Data",data.header.uniqueID,@"Key", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AA" object:nil userInfo:dc];
            DLog(@"CHANNEL DATA RECEIVED");
            
            return;
        }
        else
        {
            // IPHONE TO IPHONE
            if (actualData.length<23) {
                return;
            }
            DLog(@"User name data is %@",[[actualData subdataWithRange:NSMakeRange(0,kUser_Name_Length)] mutableCopy]);
            
            NSString *username = [[NSString alloc] initWithData:[actualData subdataWithRange:NSMakeRange(0,kUser_Name_Length)] encoding:NSUTF8StringEncoding];
            
            DLog(@"User name is %@",username);
            
            data.shoutData = [[actualData subdataWithRange:NSMakeRange(kReject_Length+kUser_Name_Length,[actualData length]-EOM_Length-kReject_Length-kUser_Name_Length)] mutableCopy];
            
            //  data.shoutData = [[actualData subdataWithRange:NSMakeRange(9,[actualData length]-EOM_Length-9)] mutableCopy];
            // Shout..
            sh.shout = (ShoutDetail *)data;
            sh.header = data.header;
            
            NSData *textdata  = [data.shoutData subdataWithRange:NSMakeRange(0,[data.shoutData length])];
            NSData *finalData = [ShoutManager decryptData:textdata];//keyy  to key
            //  NSString *headerString  = [[NSString alloc] initWithData:finalData encoding:NSUTF8StringEncoding];
            
            NSUInteger index=0;
            
            UInt8 bytes_to_find[] = { 0x2b, 0x7c ,0x7c};
            NSData *dataToFind = [NSData dataWithBytes:bytes_to_find
                                                length:sizeof(bytes_to_find)];
            
            NSRange range = [finalData rangeOfData:dataToFind
                                           options:kNilOptions
                                             range:NSMakeRange(0u, [finalData length])];
            
            if (range.location == NSNotFound) {
                NSLog(@"Bytes not found");
            }
            else {
                DLog(@"Bytes found at position %lu", (unsigned long)range.location);
                index = range.location;
            }
            
            if (index >= finalData.length) {
                return;
            }
            
            NSData *textData  = [finalData subdataWithRange:NSMakeRange(0,index)];
            NSData *mediaData = [finalData subdataWithRange:NSMakeRange(index+3,[finalData length]-index-3)];
            
            if (textData.length==0 && !mediaData) {
                return;
            }
            
            BOOL isFound = false;
            NSUInteger nextIndex = 0;
            
            if (mediaData.length>0) {
                //    UInt8 nextBytes_to_find[] = { 0x2b, 0x7c ,0x7c};
                //            NSData *nextDataToFind = [NSData dataWithBytes:bytes_to_find
                //                                                    length:sizeof(bytes_to_find)];
                
                NSRange rangeOf = [mediaData rangeOfData:dataToFind
                                                 options:kNilOptions
                                                   range:NSMakeRange(0u, [mediaData length])];
                
                if (rangeOf.location == NSNotFound) {
                    DLog(@"Bytes not found");
                    
                }
                else {
                    DLog(@"Bytes found at position %lu", (unsigned long)rangeOf.location);
                    nextIndex = rangeOf.location;
                    isFound = YES;
                }
            }
            
            dt.text  = [[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding];//[sepratorArray objectAtIndex:0];
            dt.timestamp = 0;
            dt.parent_shId = 0;
            
            
            if (isFound)
            {
                dt.content = [mediaData subdataWithRange:NSMakeRange(0,nextIndex)];
                dt.mediaPath = [[NSString alloc] initWithData:[mediaData subdataWithRange:NSMakeRange(nextIndex+3,[mediaData length]-nextIndex-3)] encoding:NSUTF8StringEncoding];
            }
            else
            {
                if (mediaData.length>0) {
                    dt.content = mediaData; //subdataWithRange:NSMakeRange(0,nextIndex)];
                    dt.mediaPath = nil;
                }
                else
                {
                    dt.content = mediaData; //subdataWithRange:NSMakeRange(0,nextIndex)];
                    dt.mediaPath = nil;
                }
            }
            sh.header = data.header;
            sh.header.isMsgFromCMS = NO;
            sh.type = data.header.type;
            sh.shout = dt;
            sh.shout.userName = username;
        }
        //    if(sh.shout == nil){
        //        NSLog(@"text msg is################ %@",sh.shout.text);
        //        [[ShoutManager sharedManager] clearInProgressGarbageShoute:data.header.shoutId];
        //    }
        
        if(sh.shout&&sh.header) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // check the shout duplicacy.
                // already recieved. local use
                [[ShoutManager sharedManager] enqueueShout:sh forUpdation:YES];
                //            if (!data.doNotForwadIt) {
                //                [self addShoutPacket:data];
                //            }
            });
        }
        
        if (data.isPacketHeaderFound&&data.isLastChunk) {
            //    if (data.header.totalShoutLength <= shoutInfoData.length && baseSh == nil) {
            [[ShoutManager sharedManager] clearInProgressGarbageShoute:data.header.shoutId];
            return;
            //        }
        }
        //  }
    }];
    
}

- (void)didRfreshedConnectedPeripherals {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceCountUpdate object:nil userInfo:nil];
        if (_centralM.connectedDevices.count==0){
        }
    });
}

- (void)didDisconnectCentral {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ShoutManager sharedManager] clearAllGarbageShoutes];
    });
}

#pragma mark - PPeropheralManagerDelegate
- (void)didRefreshconnectedCentral {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceCountUpdate object:nil userInfo:nil];
    });
}

- (void)didSendshWithId:(NSString *)shId ToUUIDs:(NSArray *)uuids {
    if (shId) [self addUUIDs:uuids forShId:shId];
}

#pragma mark ---- Sonar Enhancements ------

- (void)brodcastSonarObject:(NSData*)sonarObjectData{
    
    // Send this sonar data to all connected Centrals.
    
    SonarDataInfo *sonarData = [[SonarDataInfo alloc] init];
    sonarData.sonarData = sonarObjectData;
    sonarData.central = nil;
    
    [self addSonarDataInQue:sonarData];
}

- (void)sendSonarObject:(NSData*)sonarObjectData ToCentral:(CBCentral*)central{
    
    //Send this sonar data to given Central
    
    SonarDataInfo *sonarData = [[SonarDataInfo alloc] init];
    sonarData.sonarData = sonarObjectData;
    sonarData.central = central;
    
    [self addSonarDataInQue:sonarData];
}


#pragma mark - PCentralManagerDelegate

- (void)didRecieveSonarData:(ShoutDataReceiver *)data from:(NSString *)uuid fromPeripheral:(CBPeripheral*)peripheral forCharectorStic:(CBCharacteristic*)characteristic {
    
    SonarRequstType type = [SonarRequest getSonarDataType:data.shoutData];
    
    if (type == SonarTypeRequest) {
        SonarRequest *sonarRequestObject = [SonarRequest getSonarRequestObject:data.shoutData];
        DLog(@"############# Request");
        if (!([[SonarManager sharedManager].currectRequstedSonarId isEqualToString:sonarRequestObject.sonarId] || [[BLEManager sharedManager].sonarTrackerQue objectForKey:sonarRequestObject.sonarId])) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                LocationManager *manager = [LocationManager sharedManager];
                [manager startWithCompletion:^(BOOL success, NSError *error, double latetude, double longitude, double angle) {
                    SonarResponce *sonarRes = [[SonarResponce alloc] init];
                    sonarRes.requstType = SonarTypeResponce;
                    sonarRes.sonarId = sonarRequestObject.sonarId;
                    sonarRes.targetUserId = [[[[Global shared] currentUser] user_id] integerValue];
                    sonarRes.latitude = [LocationManager latitude];
                    sonarRes.longitude = [LocationManager longitude];
                    
                    CBCentral *central = [_perM getConnectedCentralFromUUID:uuid];
                    
                    [self sendSonarObject:[SonarResponce getSonarResponceData:sonarRes] ToCentral:central];
                }];
            });
            SonarTracker *trackerObject = [[SonarTracker alloc] init];
            
            trackerObject.sonarId = sonarRequestObject.sonarId;
            trackerObject.peripheralID = [peripheral.identifier.UUIDString copy];
            
            [trackerObject startSonarTracking];
            
            [self brodcastSonarObject:data.shoutData];
            /*
             add location value and current user id object
             convert into nsdata
             broadcast to indivisual
             
             broadcast the requste object to all
             */
        }
        else {
            
        }
    }
    else if (type == SonarTypeResponce) {
        //  NSLog(@"############# Response");
        
        SonarResponce *sonarResponceObject = [SonarResponce getSonarResponceObject:data.shoutData];
        //        NSLog(@"Sonar Id From Other Device -----> %@", sonarResponceObject.sonarId);
        //        NSLog(@"Sonar Id From My Device -----> %@", [SonarManager sharedManager].currectRequstedSonarId);
        
        if ([[SonarManager sharedManager].currectRequstedSonarId isEqualToString:sonarResponceObject.sonarId]) {
            [[SonarManager sharedManager].sonarUserResults addObject:sonarResponceObject];
            DLog(@"Adding into my sonar view");
        }
        else {
            SonarTracker *sonarResTracker = [[BLEManager sharedManager].sonarTrackerResponseQue objectForKey:sonarResponceObject.sonarId];
            if (sonarResTracker == nil || ![sonarResTracker.responserIdList containsObject:[NSString stringWithFormat:@"%lld",sonarResponceObject.targetUserId]]) {
                
                //                NSLog(@"sending first time response for sonarid: %@, target user id= %lld",sonarResponceObject.sonarId,sonarResponceObject.targetUserId);
                //                NSLog(@"My list of object are %@",sonarResTracker.responserIdList);
                
                if (sonarResTracker==nil) {
                    sonarResTracker = [[SonarTracker alloc] init];
                    
                    sonarResTracker.sonarId = sonarResponceObject.sonarId;
                }
                
                [sonarResTracker startSonarResponseTracking:[NSString stringWithFormat:@"%lld",sonarResponceObject.targetUserId]];
                
                SonarTracker *sonarTracker = [[BLEManager sharedManager].sonarTrackerQue objectForKey:sonarResponceObject.sonarId];
                
                if(sonarTracker != nil){
                    
                    CBCentral *central = [_perM getConnectedCentralFromUUID:sonarTracker.peripheralID];
                    if (central != nil) {
                        [self sendSonarObject:data.shoutData ToCentral:central];
                    }
                    else{
                        [self brodcastSonarObject:data.shoutData];
                    }
                }
                else {
                    //Brodcast to all
                    
                    [self brodcastSonarObject:data.shoutData];
                }
            }
        }
    }
}


- (void)didRecieveSonarData:(ShoutDataReceiver *)data from:(NSString *)uuid fromCentral:(CBCentral*)central forCharectorStic:(CBCharacteristic*)characteristic {
    
    SonarRequstType type = [SonarRequest getSonarDataType:data.shoutData];
    
    if (type == SonarTypeRequest) {
        SonarRequest *sonarRequestObject = [SonarRequest getSonarRequestObject:data.shoutData];
        DLog(@"############# Request");
        if (!([[SonarManager sharedManager].currectRequstedSonarId isEqualToString:sonarRequestObject.sonarId] || [[BLEManager sharedManager].sonarTrackerQue objectForKey:sonarRequestObject.sonarId])) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                LocationManager *manager = [LocationManager sharedManager];
                [manager startWithCompletion:^(BOOL success, NSError *error, double latetude, double longitude, double angle) {
                    SonarResponce *sonarRes = [[SonarResponce alloc] init];
                    sonarRes.requstType = SonarTypeResponce;
                    sonarRes.sonarId = sonarRequestObject.sonarId;
                    sonarRes.targetUserId = [[[[Global shared] currentUser] user_id] integerValue];
                    sonarRes.latitude = [LocationManager latitude];
                    sonarRes.longitude = [LocationManager longitude];
                    
                    CBCentral *central = [_perM getConnectedCentralFromUUID:uuid];
                    
                    [self sendSonarObject:[SonarResponce getSonarResponceData:sonarRes] ToCentral:central];
                }];
            });
            SonarTracker *trackerObject = [[SonarTracker alloc] init];
            
            trackerObject.sonarId = sonarRequestObject.sonarId;
            trackerObject.peripheralID = [central.identifier.UUIDString copy];
            
            [trackerObject startSonarTracking];
            
            [self brodcastSonarObject:data.shoutData];
            /*
             add location value and current user id object
             convert into nsdata
             broadcast to indivisual
             
             broadcast the requste object to all
             */
        }
        else {
            
        }
    }
    else if (type == SonarTypeResponce) {
        DLog(@"############# Response");
        
        SonarResponce *sonarResponceObject = [SonarResponce getSonarResponceObject:data.shoutData];
        //        NSLog(@"Sonar Id From Other Device -----> %@", sonarResponceObject.sonarId);
        //        NSLog(@"Sonar Id From My Device -----> %@", [SonarManager sharedManager].currectRequstedSonarId);
        //
        if ([[SonarManager sharedManager].currectRequstedSonarId isEqualToString:sonarResponceObject.sonarId]) {
            [[SonarManager sharedManager].sonarUserResults addObject:sonarResponceObject];
            DLog(@"Adding into my sonar view");
        }
        else {
            SonarTracker *sonarResTracker = [[BLEManager sharedManager].sonarTrackerResponseQue objectForKey:sonarResponceObject.sonarId];
            if (sonarResTracker == nil || ![sonarResTracker.responserIdList containsObject:[NSString stringWithFormat:@"%lld",sonarResponceObject.targetUserId]]) {
                
                DLog(@"sending first time response for sonarid: %@, target user id= %lld",sonarResponceObject.sonarId,sonarResponceObject.targetUserId);
                DLog(@"My list of object are %@",sonarResTracker.responserIdList);
                
                if (sonarResTracker==nil) {
                    sonarResTracker = [[SonarTracker alloc] init];
                    
                    sonarResTracker.sonarId = sonarResponceObject.sonarId;
                }
                
                [sonarResTracker startSonarResponseTracking:[NSString stringWithFormat:@"%lld",sonarResponceObject.targetUserId]];
                
                SonarTracker *sonarTracker = [[BLEManager sharedManager].sonarTrackerQue objectForKey:sonarResponceObject.sonarId];
                
                if(sonarTracker != nil){
                    
                    CBCentral *central = [_perM getConnectedCentralFromUUID:sonarTracker.peripheralID];
                    if (central != nil) {
                        [self sendSonarObject:data.shoutData ToCentral:central];
                    }
                    else{
                        [self brodcastSonarObject:data.shoutData];
                    }
                }
                else {
                    //Brodcast to all
                    
                    [self brodcastSonarObject:data.shoutData];
                }
            }
        }
    }
}

-(void)timerToDisconnect
{
    [_timerForDuplicateConnection invalidate];
    _timerForDuplicateConnection = nil;
    _timerForDuplicateConnection  = [NSTimer scheduledTimerWithTimeInterval:getRandomforDiscardDuplicateConnection() target:self selector:@selector(timerToDisconnect) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer: _timerForDuplicateConnection forMode:NSDefaultRunLoopMode];
    
    
    if(_centralM.connectedDevices.count > 1 && _perM.connectedCentrals.count==0)
    {
        NSMutableArray *duplicateEntries = [[NSMutableArray alloc] init];
        //        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        // method used to disconnect the duplicate connections
        [_centralM.connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([[obj objectForKey:Adv_Data] length]>7) {
                
                if ([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(7,1)] isEqualToString:@"B"])
                {
                    NSUInteger length  = [[obj objectForKey:Adv_Data] length];
                    DLog(@"lenth of Slave is and Name of slave is  %lu +++ %@",(unsigned long)length,[obj objectForKey:Adv_Data]);
                    NSString *key  = [[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(8,length-8)];
                    
                    // to check whether the user id exist in the advertisement data
                    if (key.length>=[[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID] length]) {
                        
                        NSRange range = [key rangeOfString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID]];
                        BOOL isFoundValue = false;
                        if (range.location == NSNotFound)
                        {
                            NSLog(@"string was not found");
                            isFoundValue = NO;
                        }
                        else
                        {
                            DLog(@"position %lu", (unsigned long)range.location);
                            isFoundValue  = YES;
                        }
                        
                        if (isFoundValue) {
                            
                            __block NSString *keyValue ;
                            if (key.length>6) {
                                
                                if (range.location ==0)
                                {
                                    keyValue = [key substringWithRange:NSMakeRange(6, [key length]-6)];
                                }
                                else
                                {
                                    keyValue = [key substringWithRange:NSMakeRange(0, 6)];
                                }
                            }
                            if (duplicateEntries.count>0) {
                                [duplicateEntries enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if (![[obj objectForKey:Adv_Data] isEqualToString:@""]) {
                                        
                                        if (key != nil && ![key isEqualToString:@""]) {
                                            
                                            @try {
                                                if (![[obj objectForKey:Adv_Data] containsString:keyValue]) {
                                                    
                                                    // duplicate entry for other
                                                }
                                            } @catch (NSException *exception) {
                                                
                                            } @finally {
                                                
                                            }
                                            
                                        }
                                    }
                                }];
                            }
                            else
                            {
                                if (obj !=nil) {
                                    if (duplicateEntries.count>0) {
                                        if (obj !=nil)
                                        {
                                            if (![duplicateEntries containsObject:obj])
                                            {
                                                [duplicateEntries addObject:obj];
                                            }
                                        }
                                    }else
                                    {
                                        if (obj !=nil) {
                                            [duplicateEntries addObject:obj];
                                        }
                                    }
                                }
                            }
                            
                            //                if (![dic objectForKey:keyValue]) {
                            //                    [dic setObject:obj forKey:keyValue];
                            //                }
                            
                            if (keyValue==nil) {
                                return;
                            }
                            
                            [_centralM.connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx1, BOOL * _Nonnull stop)
                             {
                                 if ([[object objectForKey:Adv_Data] length]>7) {
                                     
                                     
                                     if ([[[object objectForKey:Adv_Data] substringWithRange:NSMakeRange(7,1)] isEqualToString:@"B"])
                                     {
                                         if (key != nil && ![key isEqualToString:@""])
                                         {
                                             @try {
                                                 
                                                 if ([[object objectForKey:Adv_Data] containsString:keyValue])
                                                 {
                                                     if (idx1 != idx) {
                                                         
                                                         if (duplicateEntries.count>0) {
                                                             if (object !=nil) {
                                                                 
                                                                 
                                                                 if (![duplicateEntries containsObject:object])
                                                                 {
                                                                     [duplicateEntries addObject:object];
                                                                 }
                                                                 else
                                                                     DLog(@"Already There");
                                                             }
                                                             else
                                                                 [duplicateEntries addObject:object];
                                                             
                                                         }
                                                     }
                                                 }
                                                 
                                             } @catch (NSException *exception) {
                                                 
                                             } @finally {
                                                 
                                             }
                                         }
                                         else
                                         {
                                             DLog(@"Not exist in that");
                                         }
                                     }
                                     else
                                     {
                                         DLog(@"Slave");
                                     }
                                 }
                             }];
                        }
                    }
                }
                else
                {
                    DLog(@"Slave");
                    return;
                }
            }
        }];
        
        if (duplicateEntries.count>1) {
            NSLog(@" Duplicate entries are :- %@",duplicateEntries);
            // if duplicate entries are greater than 1
            [_centralM methodToDisconnectDuplicateConnection:duplicateEntries];
        }
    }
}

-(void)deletePacketForContent:(NSData *)data
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:data,kDeletePacket, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletePacketNotifocation object:nil userInfo:dic];
}


@end
