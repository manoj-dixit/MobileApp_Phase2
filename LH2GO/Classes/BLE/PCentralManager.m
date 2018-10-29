//
//  PCentralManager.m
//  TestBluetooth
//
//  Created by Prakash Raj on 19/09/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "PCentralManager.h"
#import "ShoutManager.h"
#import "BLEManager.h"
#import "DebugLogsInfo.h"
#import "DevicePresencePacketInfo.h"


//NSUInteger dynamicMTUSize = 20;//shradha
//NSUInteger currentRSSIValue = 0;

#define contentType   @"application/json"

@interface PCentralManager ()

@property (nonatomic, strong) dispatch_queue_t centralQueue;
@property (nonatomic,strong) NSString *cmsTimer;


@property (nonatomic, strong) ShoutDataSender *dataToSend;
@property (nonatomic, strong) NSData *pingDataToSend;
@property (nonatomic, strong) ShoutDataReceiver *shD;

@property (strong, nonatomic) NSMutableDictionary *transmitQueue1;
@property (strong, nonatomic) NSMutableDictionary *transmitQueue2;
@property (strong, nonatomic) NSMutableDictionary *transmitQueue3;
@property (strong, nonatomic) NSMutableDictionary *transmitQueue4;
@property (strong, nonatomic) NSMutableArray *transmitQueueArray;

@property (strong, nonatomic) NSOperationQueue *thread1;
@property (strong, nonatomic) NSOperationQueue *thread2;
@property (strong, nonatomic) NSOperationQueue *thread3;
@property (strong, nonatomic) NSOperationQueue *thread4;
@property (strong, nonatomic) NSOperationQueue *bleOperationThread;
@property (strong, nonatomic) NSOperationQueue *gettingDataThread;
// Queue to check if data is available in master array
@property (strong, nonatomic) NSOperationQueue *messageSendingQueue;

@end

BOOL _isSending ;
//int i = 1;
@implementation PCentralManager


- (id)init {
    if(self = [super init]) {
        // central.
        _centralQueue = dispatch_queue_create("com.kiwi.myCentral", DISPATCH_QUEUE_SERIAL);
        
        
        _centralManager             = [[CBCentralManager alloc] initWithDelegate:self queue:_centralQueue];
        
        //     _centralManager             = [[CBCentralManager alloc] initWithDelegate:self queue:_centralQueue options:@{CBPeripheralManagerOptionRestoreIdentifierKey:@"YourUniqueIdentifier"}];
        
        _connectedDevices         = [NSMutableArray new];
        _recieveQueue                = [NSMutableDictionary new];
        _recievePingQueue         = [NSMutableDictionary new];
        _listOfDevicesAfterScan  = [NSMutableArray new];
        _queue1                           = [NSMutableDictionary new];
        _queue2                           = [NSMutableDictionary new];
        _queue3                           = [NSMutableDictionary new];
        _queue4                           = [NSMutableDictionary new];
        _readyTosendQueue       = [NSMutableArray new];
        _dataHavingValue           = [NSMutableDictionary new];
        _dictToHaveConnectionTime = [NSMutableDictionary new];
        
        self.transmitQueueArray = [[NSMutableArray alloc] init];
        self.transmitQueue1 = [[NSMutableDictionary alloc] init];
        self.transmitQueue2 = [[NSMutableDictionary alloc] init];
        self.transmitQueue3 = [[NSMutableDictionary alloc] init];
        self.transmitQueue4 = [[NSMutableDictionary alloc] init];
        self.bleOperationThread = [[NSOperationQueue alloc] init];
        self.bleOperationThread.maxConcurrentOperationCount = 1;
        _dicToNotAllowConnectionForSomeTime = [[NSMutableDictionary alloc] init];
        self.gettingDataThread = [[NSOperationQueue alloc] init];
        self.gettingDataThread.maxConcurrentOperationCount = 1;
        self.gettingDataThread.qualityOfService = NSQualityOfServiceUtility;
        self.messageSendingQueue = [[NSOperationQueue alloc] init];
        self.messageSendingQueue.maxConcurrentOperationCount = 1;
        self.messageSendingQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        
        // used to write data on buki box
        _isWriteDataOnBukiBox = YES;
        pthread_mutex_init(&mutexForThread1, NULL);
        pthread_mutex_init(&mutexForThread2, NULL);
        pthread_mutex_init(&mutexForThread3, NULL);
        pthread_mutex_init(&mutexForWrite, NULL);
    }
    return self;
}

//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)state {
////    activePeripheral = [state[CBCentralManagerRestoredStatePeripheralsKey] firstItem];
////    activePeripheral.delegate = self;
////
////    NSString *str = [NSString stringWithFormat: @"%@ %lu", @"Device: ", activePeripheral.UUID];
////    [self sendNotification:str];
//
//    NSLog(@"Will Restoration method called");
//    [[BLEManager sharedManager] intialScan];
//}

- (void)scan
{
    dispatch_async(self.centralQueue, ^{
        
        //   [self stopScanning:^(BOOL success) {
        
        if ([self.centralManager respondsToSelector:@selector(isScanning)])
        {
            [self stopScanning:^(BOOL success) {
                [_listOfDevicesAfterScan removeAllObjects];
                if (self.centralManager.state == CBCentralManagerStatePoweredOn)
                {
                    [self.centralManager stopScan];
                    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
                    // NSLog(@"************* Scanning started *************");
                }
            }];
        }
        else {
            if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
                [self.centralManager stopScan];
                [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO}];
                // NSLog(@"************* Scanning started *************");
            }
        }
        
        NSLog(@"%s with SUUID %@","************* Scanning started *************",TRANSFER_SERVICE_UUID);
        
    });
    
    
    
    
}

-(void)stopScanning:(void (^)(BOOL success)) isComplete
{
    dispatch_async(self.centralQueue, ^{
        [_listOfDevicesAfterScan removeAllObjects];
        //_shouldExecuteDispatchBlock = YES;
        [self.centralManager stopScan];
        isComplete(YES);
    });
}

- (void)flush
{
    dispatch_async(self.centralQueue, ^{
        if (self.centralManager.state == CBCentralManagerStatePoweredOn)
            [_centralManager stopScan];
        self.centralManager.delegate=nil;
        self.centralManager=nil;
        [self.recieveQueue removeAllObjects];
        [self.recievePingQueue removeAllObjects];
        [self.connectedDevices removeAllObjects];
        self.connectedDevices = nil;
        
        //
        // [self clearTransmitQueues];
    });
}

- (void)cleanup
{
    if (self.centralManager.state == CBCentralManagerStatePoweredOn)
        [_centralManager stopScan];
    [self.recieveQueue removeAllObjects];
    [self.recievePingQueue removeAllObjects];
    [self.connectedDevices removeAllObjects];
    //
    // [self clearTransmitQueues];
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOff)
    {
        NSLog(@"Central Bluetooth turned OFF");
        [[BLEManager sharedManager].addTimer invalidate];
        [BLEManager sharedManager].addTimer = nil;
        [[BLEManager sharedManager].scanTimer invalidate];
        [BLEManager sharedManager].scanTimer = nil;
        [BLEManager sharedManager].isToHandleScan = NO;
        
        [[BLEManager sharedManager].perM stopAdv:^(BOOL success) {
        }];
        // In a real app, you'd deal with all the states correctly
        [_connectedDevices removeAllObjects];
        [_dictToHaveConnectionTime removeAllObjects];
        [self sendPacket];
        [_dicToNotAllowConnectionForSomeTime removeAllObjects];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
//        [BLEManager sharedManager].devicePresenceTableTimer =  nil;
//        [[BLEManager sharedManager].devicePresenceTableTimer invalidate];
    }
    else if (central.state == CBCentralManagerStatePoweredOn)
    {
        NSLog(@"Central Bluetooth turned ON");
        [BLEManager sharedManager].isToHandleScan = NO;
        [_dicToNotAllowConnectionForSomeTime removeAllObjects];
        [_connectedDevices removeAllObjects];
        [_recieveQueue removeAllObjects];
        [_dictToHaveConnectionTime removeAllObjects];
        [[BLEManager sharedManager].perM stopAdv:^(BOOL success) {
            
            // [[BLEManager sharedManager] autoScan];
        }];
        if (![BLEManager sharedManager].perM.peripheralManager.isAdvertising) {
            
            [[BLEManager sharedManager] autoScan];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
    }
    
    DevicePresencePacketInfo *shredIns = [DevicePresencePacketInfo sharedInstance];
    shredIns.devicePresenceFragmentCount = 0;
    
    [[BLEManager sharedManager].deletePacketDictionary removeAllObjects];
    // Clear Transmitting Queues
    [self clearTransmitQueues];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(didRfreshedConnectedPeripherals)])[_delegate didRfreshedConnectedPeripherals];
        [_delegate didRfreshedConnectedPeripherals];
    });
}

-(void)methodToReinitaiteScanning
{
    [[BLEManager sharedManager] invalidateTimer];
    
    [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
        
        if ([BLEManager sharedManager].isScanningFromWakeUP) {
            
            //[BLEManager sharedManager].isScanningFromWakeUP = NO;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [[BLEManager sharedManager] startAdvertising];
                
            });
            
        }
        else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [[BLEManager sharedManager] startScanning];
                
            });
        }
    }];
}

-(void)methodTocheckActiveConnection:(CBPeripheral *)ph
{
    DLog(@"Method called 1");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             DLog(@"Method called 2");
             
             CBPeripheral *cb = [obj objectForKey:Peripheral_Ref];
             
             DLog(@"Method reference is %@",cb);
             // If the same peripheral
             if([cb isEqual:ph])
             {
                 DLog(@"Method called 3");
                 
                 if (cb.state == CBPeripheralStateConnected) {
                     
                     DLog(@"Method called 4");
                     
                 }else{
                     
                     DLog(@"Method called 5");
                     
                     @try {
                         
                         
                         if ([_dictToHaveConnectionTime objectForKey:cb.identifier]) {
                             
                             NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
                             // if greater than 120
                             
                             NSLog(@"tiem stamp ++ current time stamp ++ Dif %lu %lu %lu",[[_dictToHaveConnectionTime objectForKey:cb.identifier] integerValue],CurrentTimeStamp,CurrentTimeStamp-[[_dictToHaveConnectionTime objectForKey:cb.identifier] integerValue] );
                             
                             if (CurrentTimeStamp-[[_dictToHaveConnectionTime objectForKey:cb.identifier] integerValue] >= 3 ) {
                                 
                                 [_dictToHaveConnectionTime removeObjectForKey:cb.identifier];
                                 NSLog(@"Peripheral Disconnecting %@ ",cb);
                                 
                                 [self.centralManager cancelPeripheralConnection:cb];
                                 [self handleTransmitThreadsOnDisconnectWithPeripheral:cb];
                                 
                                 for (CBService *service in cb.services)
                                 {
                                     if (service.characteristics != nil) {
                                         for (CBCharacteristic *characteristic in service.characteristics) {
                                             [cb setNotifyValue:NO forCharacteristic:characteristic];
                                         }
                                     }
                                 }
                                 if ([_connectedDevices containsObject:obj]) {
                                     [_connectedDevices removeObject:obj];
                                 }
                             }
                         }
                     } @catch (NSException *exception) {
                         
                     } @finally {
                         
                     }
                 }
             }
         }];
    });
}

#pragma mark Connection methods

-(void)makeConnectionWithPeripheral:(CBPeripheral *)peripheral byCentral:(CBCentralManager *)centralRe arrayOfPeri:(NSDictionary *)adv_Data
{
    if([_connectedDevices count]<MasterConnection)
    {
        if ([[adv_Data objectForKey:adv_Data] isEqualToString:@""]) {
            
            [_connectedDevices addObject:adv_Data];
            
            NSLog(@"Trying to connect with Peripheral with Adv data %@ + %@",peripheral,adv_Data);
            
            NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
            
            [_dictToHaveConnectionTime setObject:[NSNumber numberWithInteger:CurrentTimeStamp] forKey:peripheral.identifier];
            [centralRe connectPeripheral:peripheral options:nil];
            
            [self methodToReinitaiteScanning];
            
        }
        else if ([[[adv_Data objectForKey:Adv_Data] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"B"])
        {
            if([_dicToNotAllowConnectionForSomeTime objectForKey:peripheral.identifier] != nil)
            {
                NSUInteger timeStampValue = [[_dicToNotAllowConnectionForSomeTime objectForKey:peripheral.identifier] intValue];
                
                NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
                NSLog(@"tiem stamp ++ current time stamp ++ Dif %lu %lu %lu",timeStampValue,CurrentTimeStamp,CurrentTimeStamp-timeStampValue );
                // if greater than 120
                if ((CurrentTimeStamp - timeStampValue) >= kWaitingToMakeConnection)
                {
                    NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
                    
                    [_dictToHaveConnectionTime setObject:[NSNumber numberWithInteger:CurrentTimeStamp] forKey:peripheral.identifier];
                    NSLog(@"Trying to connect with Peripheral with Adv data %@ + %@",peripheral,adv_Data);
                    [_dicToNotAllowConnectionForSomeTime removeObjectForKey:peripheral.identifier];
                    // wait fro 120 seconds to connect it again
                    [_connectedDevices addObject:adv_Data];
                    [centralRe connectPeripheral:peripheral options:nil];
                    [self methodToReinitaiteScanning];
                }
            }
            else
            {
                
                NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
                
                [_dictToHaveConnectionTime setObject:[NSNumber numberWithInteger:CurrentTimeStamp] forKey:peripheral.identifier];
                NSLog(@"Trying to connect with Peripheral with Adv data %@ + %@",peripheral,adv_Data);
                [_connectedDevices addObject:adv_Data];
                [centralRe connectPeripheral:peripheral options:nil];
                
                [self methodToReinitaiteScanning];
            }
        }
        else
        {
            if([_dicToNotAllowConnectionForSomeTime objectForKey:peripheral.identifier] != nil)
            {
                NSString *timeStampValue = [_dicToNotAllowConnectionForSomeTime objectForKey:peripheral.identifier] ;
                // if greater than 120\
                
                if (([[AppManager timeStamp] integerValue] - [timeStampValue integerValue]) >= kWaitingToMakeConnection)
                {
                    
                    NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
                    
                    [_dictToHaveConnectionTime setObject:[NSNumber numberWithInteger:CurrentTimeStamp] forKey:peripheral.identifier];
                    
                    NSLog(@"Trying to connect with Peripheral with Adv data %@ + %@",peripheral,adv_Data);
                    [_dicToNotAllowConnectionForSomeTime removeObjectForKey:peripheral.identifier];
                    // wait fro 120 seconds to connect it again
                    [_connectedDevices addObject:adv_Data];
                    [centralRe connectPeripheral:peripheral options:nil];
                    [self methodToReinitaiteScanning];
                }
            }
            else
            {
                
                NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
                
                [_dictToHaveConnectionTime setObject:[NSNumber numberWithInteger:CurrentTimeStamp] forKey:peripheral.identifier];
                
                NSLog(@"Trying to connect with Peripheral with Adv data %@ + %@",peripheral,adv_Data);
                [_connectedDevices addObject:adv_Data];
                [centralRe connectPeripheral:peripheral options:nil];
                [self methodToReinitaiteScanning];
            }
        }
        [self methodTocheckActiveConnection:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral.state == CBPeripheralStateDisconnected)
    {
        
        DLog(@"Advertise data is %@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]);
        
        // Ok, it's in range - have we already seen it?
        if ([_connectedDevices isKindOfClass:[NSMutableArray class]]&&![_connectedDevices containsObject:peripheral])
        {
            
            if (self.centralManager.state == CBCentralManagerStatePoweredOn)
            {
                DLog(@"Manoj 10");
                if ([advertisementData objectForKey:@"kCBAdvDataLocalName"])
                {
                    DLog(@"Manoj 11");
                    
                    __block BOOL isAlreadyExist = false;
                    // will save the data in Array
                    if (_listOfDevicesAfterScan.count>=1)
                    {
                        // if _listOfDevicesAfterScan array count is greater or equal to zero
                        
                        [_listOfDevicesAfterScan enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheral]) {
                                isAlreadyExist = YES;
                            }
                        }];
                        
                        if (!isAlreadyExist)
                        {
                            //check the local name
                            
                            NSString *advData  = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
                            if ([advData length]>7) {
                                
                                
                                if ([[advData substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"]) {
                                    // slave
                                    if ([advData length] >5) {
                                        NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,advData,Adv_Data,@"",Ref_ID,nil];
                                        [_listOfDevicesAfterScan addObject:dataDic];
                                    }
                                    else
                                    {
                                        // free node
                                        NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,@"",Ref_ID,advData,Adv_Data,nil];
                                        [_listOfDevicesAfterScan addObject:dataDic];
                                    }
                                }else
                                {
                                    NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,@"",Ref_ID,advData,Adv_Data,nil];
                                    [_listOfDevicesAfterScan addObject:dataDic];
                                }
                            }
                        }
                        else
                        {
                            DLog(@"Already Exist in Array");
                        }
                    }
                    else
                    {
                        // Add in _listOfDevicesAfterScan array if count is zero
                        NSString *advData  = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
                        if ([advData length]>7)
                        {
                            if ([[advData substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"]) {
                                if ([advData length] >5) {
                                    NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,@"",Ref_ID,advData,Adv_Data,nil];
                                    [_listOfDevicesAfterScan addObject:dataDic];
                                }
                                else
                                {
                                    DLog(@"Wrong packet broadcast");
                                }
                            }
                            else
                            {
                                // if free node
                                NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,@"",Ref_ID,advData,Adv_Data,nil];
                                [_listOfDevicesAfterScan addObject:dataDic];
                            }
                        }
                    }
                }
                else
                {
                    DLog(@"Manoj 13");
                    
                    if ([_connectedDevices count] <MasterConnection)
                    {
                        // should be yes for sending connection request
                        if (_shouldExecuteDispatchBlock)
                        {
                            // timestamp value for Same Peripheral
                            if([_dicToNotAllowConnectionForSomeTime objectForKey:peripheral.identifier] != nil)
                            {
                                NSString *timeStampValue = [_dicToNotAllowConnectionForSomeTime objectForKey:peripheral.identifier] ;
                                // if greater than 120 sec
                                
                                if (([[AppManager timeStamp] integerValue] - [timeStampValue integerValue]) >=kWaitingToMakeConnection)
                                {
                                    NSString *advData  = @"";
                                    NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,advData,Adv_Data,@"",Ref_ID,nil];
                                    [_listOfDevicesAfterScan addObject:dataDic];
                                    
                                    CBPeripheral *ph = [[_listOfDevicesAfterScan objectAtIndex:0]objectForKey:Peripheral_Ref];
                                    DLog(@"Trying to connect with Peripheral with Adv data %@ + %@",peripheral,@"Background");
                                    
                                    [_connectedDevices addObject:[_listOfDevicesAfterScan objectAtIndex:0]];
                                    
                                    NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
                                    
                                    [_dictToHaveConnectionTime setObject:[NSNumber numberWithInteger:CurrentTimeStamp] forKey:ph.identifier];
                                    
                                    [central connectPeripheral:ph options:nil];
                                    
                                    _shouldExecuteDispatchBlock = YES;
                                    
                                    [_listOfDevicesAfterScan removeAllObjects];
                                    
                                    // stop Scanning
                                    // start after 2 sec
                                    
                                    [self methodTocheckActiveConnection:ph];
                                    
                                    [[BLEManager sharedManager] invalidateTimer];
                                    
                                    [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                                        
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            
                                            [[BLEManager sharedManager] startScanning];
                                            
                                        });
                                    }];
                                    return;
                                }
                            }
                            else
                            {
                                DLog(@"Manoj 12");
                                
                                // not connected before that
                                
                                DLog(@"Trying to connect with Peripheral with Adv data %@ + %@",peripheral,@"Background");
                                
                                NSString *advData  = @"";
                                NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,advData,Adv_Data,@"",Ref_ID,nil];
                                [_listOfDevicesAfterScan addObject:dataDic];
                                
                                CBPeripheral *ph = [[_listOfDevicesAfterScan objectAtIndex:0]objectForKey:Peripheral_Ref];
                                // NSLog(@"initiate peripheral connection == %@",ph);
                                
                                [_connectedDevices addObject:[_listOfDevicesAfterScan objectAtIndex:0]];
                                
                                NSUInteger CurrentTimeStamp = [[AppManager timeStamp] integerValue];
                                
                                [_dictToHaveConnectionTime setObject:[NSNumber numberWithInteger:CurrentTimeStamp] forKey:ph.identifier];
                                
                                [central connectPeripheral:ph options:nil];
                                
                                _shouldExecuteDispatchBlock = YES;
                                
                                [_listOfDevicesAfterScan removeAllObjects];
                                
                                // stop Scanning
                                // start after 2 sec
                                
                                [self methodTocheckActiveConnection:ph];
                                
                                [[BLEManager sharedManager] invalidateTimer];
                                
                                [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                                    
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        
                                        [[BLEManager sharedManager] startScanning];
                                        
                                    });
                                }];
                                return;
                            }
                        }
                    }
                    // due to one connection only at the time
                }
                // Will call after 2 sec
                DLog(@"Manoj 14");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    DLog(@"Manoj 14");
                    
                    if(_shouldExecuteDispatchBlock)
                    {
                        DLog(@"Manoj 16");
                        
                        // if already scanning till that time
                        if (self.centralManager.isScanning)
                        {
                            // count is greater then 1 of scanning advertise packets
                            
                            DLog(@"Manoj 17");
                            
                            if (_listOfDevicesAfterScan.count>1)
                            {
                                
                                DLog(@"Manoj 18");
                                
                                // if not connected with any devices
                                
                                // if count is zero
                                if ([_connectedDevices count] == 0)
                                {
                                    
                                    DLog(@"Manoj 19");
                                    
                                    __block  BOOL isSlave  = false;
                                    __block  NSInteger index;
                                    [_listOfDevicesAfterScan enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                        
                                        if ([[obj objectForKey:Adv_Data] length]>7) {
                                            
                                            if (![[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(7,1)] isEqualToString:@"S"])
                                            {
                                                
                                                isSlave = YES;
                                                index    = idx;
                                                if ([_listOfDevicesAfterScan count] > 0) {
                                                    
                                                    CBPeripheral *ph = [[_listOfDevicesAfterScan objectAtIndex:0]objectForKey:Peripheral_Ref];
                                                    //   NSLog(@"initiate peripheral connection == %@",ph);
                                                    
                                                    //   [_connectedDevices addObject:[_listOfDevicesAfterScan objectAtIndex:0]];
                                                    
                                                    //     [central connectPeripheral:ph options:nil];
                                                    
                                                    [self makeConnectionWithPeripheral:ph byCentral:central arrayOfPeri:[_listOfDevicesAfterScan objectAtIndex:0]];
                                                    
                                                    
                                                    _shouldExecuteDispatchBlock = YES;
                                                    [_listOfDevicesAfterScan removeAllObjects];
                                                }
                                                // stop Scanning
                                                // start after 2 sec
                                                
                                                *stop = YES;
                                            }
                                        }
                                    }];
                                    
                                    if (!isSlave)
                                    {
                                        if ([[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref] != nil)
                                        {
                                            if ([_listOfDevicesAfterScan count] >0) {
                                                
                                                CBPeripheral *ph = [[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref];
                                                // NSLog(@"initiate peripheral connection == %@",ph);
                                                
                                                //  [_connectedDevices addObject:[_listOfDevicesAfterScan objectAtIndex:0]];
                                                
                                                //  [central connectPeripheral:ph options:nil];
                                                
                                                [self makeConnectionWithPeripheral:ph byCentral:central arrayOfPeri:[_listOfDevicesAfterScan objectAtIndex:0]];
                                                
                                                [_listOfDevicesAfterScan removeAllObjects];
                                                
                                                _shouldExecuteDispatchBlock = YES;
                                            }
                                            // stop adverstisement
                                            // start after 2 sec
                                            
                                            //                                            [[BLEManager sharedManager] invalidateTimer];
                                            //
                                            //                                            [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                                            //
                                            //                                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            //
                                            //                                                    [[BLEManager sharedManager] startScanning];
                                            //
                                            //                                                });
                                            //                                            }];
                                        }
                                    }
                                }
                                else if ([_connectedDevices count] < MasterConnection)
                                {
                                    __block BOOL isThere = false;
                                    __block NSInteger indexValue;
                                    __block BOOL isFreeNode = false;
                                    __block BOOL isSlaveButNOtConnected = false;
                                    
                                    __block NSInteger freeNodeIndex;
                                    
                                    // connected devices
                                    [_listOfDevicesAfterScan enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx1, BOOL * _Nonnull stopLoop) {
                                        
                                        // scan devices
                                        [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
                                            if ([[obj objectForKey:Adv_Data] length]>7) {
                                                
                                                if ([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"])
                                                {
                                                    // if slave is there
                                                    if ([[obj objectForKey:Adv_Data] length] > 8 &&  [[object objectForKey:Adv_Data] length]>8)
                                                    {
                                                        if ([[[object objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"B"]) {
                                                            
                                                            if ([[object objectForKey:Adv_Data]  containsString:[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(8, 6)]])
                                                            {
                                                                isThere  = YES;
                                                                indexValue  = idx1;
                                                                *stop = YES;
                                                                *stopLoop = YES;
                                                            }
                                                            else
                                                            {
                                                                freeNodeIndex = idx1;
                                                                isFreeNode = YES;
                                                                isSlaveButNOtConnected = YES;
                                                                //                                                    *stop = YES;
                                                                //                                                    *stopLoop = YES;
                                                            }
                                                        }
                                                        
                                                        else
                                                        {
                                                            DLog(@"A slave node");
                                                            freeNodeIndex = idx1;
                                                            isFreeNode = YES;
                                                            isSlaveButNOtConnected = YES;
                                                        }
                                                    }
                                                    else
                                                    {
                                                        DLog(@"A slave node");
                                                        freeNodeIndex = idx1;
                                                        isFreeNode = YES;
                                                        isSlaveButNOtConnected = YES;
                                                    }
                                                }
                                                else
                                                {
                                                    // only free node there
                                                    freeNodeIndex = idx1;
                                                    isSlaveButNOtConnected = YES;
                                                    isFreeNode = YES;
                                                    *stop = YES;
                                                    *stopLoop = YES;
                                                }
                                            }
                                        }];
                                        
                                        if (!isThere && isFreeNode && isSlaveButNOtConnected) {
                                            
                                            *stopLoop = YES;
                                        }
                                    }];
                                    
                                    // if free node and slave both found
                                    // and as well as if only free node found
                                    
                                    if ((!isThere && isFreeNode && isSlaveButNOtConnected) || (!isThere && isFreeNode && isSlaveButNOtConnected))
                                    {
                                        if ([_listOfDevicesAfterScan count] >0) {
                                            
                                            // if selected free node's user id is not present there
                                            if ([[_listOfDevicesAfterScan objectAtIndex:freeNodeIndex] objectForKey:Peripheral_Ref] != nil)
                                            {
                                                //                                            if ([_listOfDevicesAfterScan count] >=freeNodeIndex-1) {
                                                DLog(@"Count is less than over all central connection time");
                                                CBPeripheral *ph = [[_listOfDevicesAfterScan objectAtIndex:freeNodeIndex] objectForKey:Peripheral_Ref];
                                                
                                                _shouldExecuteDispatchBlock = YES;
                                                
                                                [self makeConnectionWithPeripheral:ph byCentral:central arrayOfPeri:[_listOfDevicesAfterScan objectAtIndex:freeNodeIndex]];
                                                
                                                
                                                [_listOfDevicesAfterScan removeAllObjects];
                                                //                                            }
                                                // stop Scanning
                                                // start after 2 sec
                                                
                                                //                                                [[BLEManager sharedManager] invalidateTimer];
                                                //
                                                //                                                [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                                                //
                                                //                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                //
                                                //                                                        [[BLEManager sharedManager] startScanning];
                                                //
                                                //                                                    });
                                                //                                                }];
                                            }
                                        }
                                    }
                                }
                                // if already connected with 4 masters
                                else if ([_connectedDevices count] == MasterConnection)
                                {
                                    /*
                                     // if count is increased upto 4
                                     // but still scanning
                                     // got an packet of Slave
                                     __block BOOL isAvailableNOtInBridge = false;
                                     __block BOOL isPresent = false;
                                     __block int index;
                                     
                                     [_listOfDevicesAfterScan enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx1, BOOL * _Nonnull stoploop) {
                                     
                                     if ([[[_listOfDevicesAfterScan objectAtIndex:idx1] objectForKey:Adv_Data] length] >7) {
                                     
                                     // if found node is as slave
                                     if ([[[[_listOfDevicesAfterScan objectAtIndex:idx1] objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"])
                                     {
                                     index  = idx1;
                                     [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
                                     
                                     // if slave packet
                                     if ([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"])
                                     {
                                     if ([[obj objectForKey:Adv_Data] length] >8) {
                                     
                                     if ([[object objectForKey:Adv_Data]  containsString:[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(8, 6)]])
                                     {
                                     isPresent = YES;
                                     *stop         = YES; //Please comment this line.
                                     }
                                     else
                                     {
                                     isAvailableNOtInBridge  = YES;
                                     }
                                     }
                                     else
                                     {
                                     NSLog(@"Wrong packet broadcast");
                                     //                                                     isPresent = YES;
                                     }
                                     }
                                     }];
                                     
                                     __block BOOL isDelete = false;
                                     
                                     if (!isPresent || isAvailableNOtInBridge) {
                                     
                                     [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
                                     
                                     if ([[[object objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"])
                                     {
                                     CBPeripheral *ph = [object objectForKey:Peripheral_Ref];
                                     NSLog(@"Delete peripheral connection == %@",ph);
                                     
                                     [_connectedDevices removeObject:object];
                                     
                                     //                                                    _shouldExecuteDispatchBlock = YES;
                                     
                                     [central cancelPeripheralConnection:ph];
                                     for (CBService *service in ph.services)
                                     {
                                     if (service.characteristics != nil) {
                                     for (CBCharacteristic *characteristic in service.characteristics) {
                                     
                                     [ph setNotifyValue:NO forCharacteristic:characteristic];
                                     
                                     }
                                     }
                                     }
                                     isDelete  = YES;
                                     
                                     *stop  = YES;
                                     }
                                     }];
                                     if (isDelete  && [_connectedDevices count] <  MasterConnection && [_listOfDevicesAfterScan count]>0) {
                                     
                                     if ((!isPresent || isAvailableNOtInBridge))
                                     {
                                     if ([[_listOfDevicesAfterScan objectAtIndex:idx1] objectForKey:Peripheral_Ref] != nil)
                                     {
                                     if ([_listOfDevicesAfterScan count] >0) {
                                     CBPeripheral *p = [[_listOfDevicesAfterScan objectAtIndex:idx1] objectForKey:Peripheral_Ref];
                                     NSLog(@"initiate peripheral connection == %@",p);
                                     
                                     [_connectedDevices addObject:[_listOfDevicesAfterScan objectAtIndex:idx1]];
                                     
                                     _shouldExecuteDispatchBlock = YES;
                                     [central connectPeripheral:p options:nil];
                                     [_listOfDevicesAfterScan removeAllObjects];
                                     //                                                        [self stopScanning:^(BOOL success) {}];
                                     }
                                     // stop scanning
                                     // start after 2 sec
                                     
                                     [[BLEManager sharedManager] invalidateTimer];
                                     
                                     [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                                     
                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     
                                     [[BLEManager sharedManager] startScanning];
                                     
                                     });
                                     }];
                                     
                                     *stoploop  = YES;
                                     }
                                     }
                                     }
                                     }
                                     }
                                     else
                                     {
                                     // Free node
                                     // do nothing in that case
                                     NSLog(@"need not to send connection request");
                                     }
                                     }
                                     }];
                                     }
                                     */
                                }
                                else
                                {
                                    DLog(@"Manoj4");
                                }
                            }
                            // if after scanning of  2 sec , get only one advertise packet
                            
                            
                            else if ([_listOfDevicesAfterScan count] ==1)
                            {
                                // if scan count array count is 1
                                
                                if ([_connectedDevices count] == MasterConnection)
                                {
                                    /*
                                     // if count is increased upto 4
                                     // but still scanning
                                     // got an packet of Slave
                                     
                                     if (_listOfDevicesAfterScan.count > 0)
                                     {
                                     // if count is increased upto 4
                                     // but still scanning
                                     // got an packet of Slave
                                     __block BOOL isPresent = false;
                                     
                                     if ([[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] length]>7) {
                                     
                                     // if found node is as slave
                                     if ([[[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"])
                                     {
                                     //                                            index  = idx1;
                                     [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
                                     
                                     
                                     if ([[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] length] >8) {
                                     
                                     if ([[object objectForKey:Adv_Data]  containsString:[[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] substringWithRange:NSMakeRange(8, 6)]])
                                     {
                                     isPresent = YES;
                                     *stop = YES;
                                     }
                                     }
                                     else
                                     {
                                     NSLog(@"Pacekt broadcasting wrong");
                                     }
                                     }];
                                     
                                     __block BOOL isDelete = false;
                                     if (!isPresent)
                                     {
                                     [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
                                     if ([[object objectForKey:Adv_Data] length] >7) {
                                     
                                     if ([[[object objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"])
                                     {
                                     CBPeripheral *ph = [object objectForKey:Peripheral_Ref];
                                     NSLog(@"Delete peripheral connection == %@",ph);
                                     
                                     [_connectedDevices removeObject:object];
                                     
                                     [central cancelPeripheralConnection:ph];
                                     
                                     for (CBService *service in ph.services)
                                     {
                                     if (service.characteristics != nil) {
                                     for (CBCharacteristic *characteristic in service.characteristics) {
                                     
                                     [ph setNotifyValue:NO forCharacteristic:characteristic];
                                     
                                     }
                                     }
                                     }
                                     
                                     
                                     isDelete  = YES;
                                     *stop  = YES;
                                     }
                                     }
                                     }];
                                     if (isDelete && [_connectedDevices count] <  MasterConnection &&  [_listOfDevicesAfterScan count] >0) {
                                     
                                     
                                     
                                     
                                     if ([[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref] != nil)
                                     {
                                     if ([_listOfDevicesAfterScan count] >0) {
                                     
                                     if ([[[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"]) {
                                     
                                     __block BOOL isPresent = false;
                                     [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                     
                                     if ([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"])
                                     {
                                     if ([[obj objectForKey:Adv_Data] length] >8) {
                                     
                                     if ([[obj objectForKey:Adv_Data]  containsString:[[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] substringWithRange:NSMakeRange(8, 6)]])
                                     {
                                     isPresent = YES;
                                     *stop         = YES; //Please comment this line.
                                     }
                                     else
                                     {
                                     // isAvailableNOtInBridge  = YES;
                                     }
                                     }
                                     else
                                     {
                                     NSLog(@"Wrong packet broadcast");
                                     //                                                     isPresent = YES;
                                     }
                                     }
                                     }];
                                     
                                     if (!isPresent) {
                                     
                                     CBPeripheral *p = [[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref];
                                     NSLog(@"initiate peripheral connection == %@",p);
                                     
                                     [_connectedDevices addObject:[_listOfDevicesAfterScan objectAtIndex:0]];
                                     
                                     [central connectPeripheral:p options:nil];
                                     _shouldExecuteDispatchBlock = YES;
                                     [_listOfDevicesAfterScan removeAllObjects];
                                     //                                                        [self stopScanning:^(BOOL success) {}];
                                     
                                     
                                     // stop scanning
                                     // start after 2 sec
                                     
                                     [[BLEManager sharedManager] invalidateTimer];
                                     
                                     [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                                     
                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     
                                     [[BLEManager sharedManager] startScanning];
                                     
                                     });
                                     }];
                                     }
                                     }
                                     else
                                     {
                                     CBPeripheral *p = [[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref];
                                     NSLog(@"initiate peripheral connection == %@",p);
                                     
                                     [_connectedDevices addObject:[_listOfDevicesAfterScan objectAtIndex:0]];
                                     
                                     [central connectPeripheral:p options:nil];
                                     _shouldExecuteDispatchBlock = YES;
                                     [_listOfDevicesAfterScan removeAllObjects];
                                     //                                                        [self stopScanning:^(BOOL success) {}];
                                     
                                     
                                     // stop scanning
                                     // start after 2 sec
                                     
                                     [[BLEManager sharedManager] invalidateTimer];
                                     
                                     [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                                     
                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     
                                     [[BLEManager sharedManager] startScanning];
                                     
                                     });
                                     }];
                                     }
                                     }
                                     }
                                     }
                                     }
                                     else
                                     {
                                     NSLog(@"Already in same network");
                                     }
                                     }
                                     }
                                     else
                                     {
                                     // Free node
                                     // do nothing in that case
                                     // need not to send connection request
                                     NSLog(@"Free node");
                                     }
                                     }
                                     else
                                     {
                                     // Free node
                                     // do nothing
                                     }
                                     */
                                }
                                // if connected count is 0
                                else if ([_connectedDevices count] ==0)
                                {
                                    // if count is zero
                                    // send connection request
                                    if (_listOfDevicesAfterScan.count >0) {
                                        
                                        CBPeripheral *p = [[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref];
                                        // NSLog(@"initiate peripheral connection == %@",p);
                                        
                                        // add in array
                                        //  [_connectedDevices addObject:[_listOfDevicesAfterScan objectAtIndex:0]];
                                        
                                        // send connection request
                                        //   [central connectPeripheral:p options:nil];
                                        
                                        [self makeConnectionWithPeripheral:p byCentral:central arrayOfPeri:[_listOfDevicesAfterScan objectAtIndex:0]];
                                        
                                        _shouldExecuteDispatchBlock = YES;
                                        // remove all the object from scanning list array
                                        [_listOfDevicesAfterScan removeAllObjects];
                                        
                                        // stop adverstisement
                                        // start after 2 sec
                                        //     [[BLEManager sharedManager] invalidateTimer];
                                        //     [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                                        
                                        //         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        
                                        //             [[BLEManager sharedManager] startScanning];
                                        
                                        //         });
                                        //     }];
                                    }
                                }
                                // if count is more then 1 and less than over all count
                                
                                else if (_listOfDevicesAfterScan.count >0 && [_connectedDevices count] <  MasterConnection)
                                {
                                    
                                    __block BOOL isThere = false;
                                    __block NSInteger indexValue;
                                    
                                    // connected devices
                                    
                                    // scan devices
                                    [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop)
                                     {
                                         if ([_listOfDevicesAfterScan count]==0) {
                                             return ;
                                         }
                                         
                                         if ([[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] length]>7) {
                                             
                                             
                                             if ([[[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"S"])
                                             {
                                                 // if slave is there
                                                 if ([[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] length] >8)
                                                 {
                                                     if (_listOfDevicesAfterScan.count>0) {
                                                         
                                                         if ([[object objectForKey:Adv_Data]  containsString:[[[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Adv_Data] substringWithRange:NSMakeRange(8, 6)]])
                                                         {
                                                             isThere  = YES;
                                                             indexValue  = idx;
                                                             *stop = YES;
                                                         }
                                                         else
                                                         {
                                                             // *stop = YES;
                                                         }
                                                         
                                                     }
                                                 }
                                                 else
                                                 {
                                                     
                                                     //          isThere  = YES;
                                                     //          indexValue  = idx;
                                                     //          *stop = YES;
                                                 }
                                             }
                                             else
                                             {
                                                 // free node is there
                                                 if ([_listOfDevicesAfterScan count] >0) {
                                                     
                                                     if ([[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref] != nil)
                                                     {
                                                         if ([_listOfDevicesAfterScan count] >0) {
                                                             DLog(@"Count is less than over all central connection time");
                                                             
                                                             @try {
                                                                 
                                                                 CBPeripheral *ph = [[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref];
                                                                 
                                                                 _shouldExecuteDispatchBlock = YES;
                                                                 isThere  = YES;
                                                                 // stop adverstisement
                                                                 // start after 2 sec
                                                                 
                                                                 [self makeConnectionWithPeripheral:ph byCentral:central arrayOfPeri:[_listOfDevicesAfterScan objectAtIndex:0]];
                                                                 
                                                                 [_listOfDevicesAfterScan removeAllObjects];
                                                                 
                                                             } @catch (NSException *exception) {
                                                                 
                                                             } @finally {
                                                                 
                                                             }
                                                             *stop = YES;
                                                         }
                                                     }
                                                 }
                                             }
                                         }
                                     }];
                                    if (!isThere)
                                    {
                                        if ([_listOfDevicesAfterScan count] >0) {
                                            // if selected free node's user id is not present there
                                            if ([[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref] != nil)
                                            {
                                                DLog(@"Count is less than over all central connection time");
                                                if (_listOfDevicesAfterScan.count>0) {
                                                    
                                                    @try {
                                                        
                                                        CBPeripheral *ph = [[_listOfDevicesAfterScan objectAtIndex:0] objectForKey:Peripheral_Ref];
                                                        
                                                        [self makeConnectionWithPeripheral:ph byCentral:central arrayOfPeri:[_listOfDevicesAfterScan objectAtIndex:0]];
                                                        
                                                        [_listOfDevicesAfterScan removeAllObjects];
                                                        
                                                        isThere  = YES;
                                                        
                                                    } @catch (NSException *exception) {
                                                        
                                                    } @finally {
                                                        
                                                    }
                                                }
                                                // stop adverstisement
                                                // start after 2 sec
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                DLog(@"Manoj3");
                            }
                        }else
                        {
                            DLog(@"Manoj3");
                        }
                    }else
                    {
                        DLog(@"Manoj2");
                    }
                });
            }
        }else{
            
            DLog(@"Manoj7");
            //  NSLog(@"Reconnect peripheral if already in que and disconnected== %@",peripheral);
            // [self.centralManager connectPeripheral:peripheral options:nil];
        }
    }
    else{
        // [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearPeripheralQue) object:nil];
        // [self performSelector:@selector(clearPeripheralQue) withObject:nil afterDelay:10.0];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    DLog(@"Peripheral Did fail to connect %@",peripheral.name);
    
    // if Peripheral is not connected and peripheral services are finding out
    if (peripheral.state != CBPeripheralStateConnected && peripheral.services.count>0) {
        
        [self handleTransmitThreadsOnDisconnectWithPeripheral:peripheral];
    }
    
    if([_connectedDevices isKindOfClass:[NSMutableArray class]])
    {
        @try {
            [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CBPeripheral *cb = [obj objectForKey:Peripheral_Ref];
                if ([cb isEqual:peripheral]) {
                    [_connectedDevices removeObject:obj];
                    
                    //
                    NSUInteger objectIndex = [self.transmitQueueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                        BOOL found = [[item objectForKey:Peripheral_Ref] isEqual:cb];
                        return found;
                    }];
                    
                    if (objectIndex != NSNotFound) {
                        
                        // Matching item found
                        if((objectIndex > 0 || objectIndex == 0) && objectIndex < self.transmitQueueArray.count) {
                            [self.transmitQueueArray removeObjectAtIndex:objectIndex];
                            DLog(@" the array is 1 : %@", self.transmitQueueArray);
                        } else {
                            DLog(@"error 1");
                        }
                    } else {
                        // No matching item found.
                    }
                }
            }];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
    if (_connectedDevices.count < 4 && _connectedDevices.count !=0) {
        //        [[BLEManager sharedManager] startScanning];
    }else if(_connectedDevices.count ==0)
    {
        [BLEManager sharedManager].isToHandleScan = NO;
        [[BLEManager sharedManager] startAdvertising];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(didRfreshedConnectedPeripherals)])
            [_delegate didRfreshedConnectedPeripherals];
    });
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([[BLEManager sharedManager].perM.connectedCentrals count] > 0) {
        
        BOOL isSuccess=false;
        do {
            if([BLEManager sharedManager].perM.transferCharacteristicForShoutsUPDATE != nil)
            {
                BOOL  isSuccess =  [[BLEManager sharedManager].perM.peripheralManager updateValue:[@"02owly" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:[BLEManager sharedManager].perM.transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
                NSLog(@"Success is %d",isSuccess);
            }
        }
        while (isSuccess);
        
        [[BLEManager sharedManager].perM.connectedCentrals removeAllObjects];
        DLog(@"Removed connected Central devices");
    }
    
    NSLog(@"Peripheral Connected %@",peripheral);
    peripheral.delegate = self; //Sonal 20 feb
    
    __block NSString *advData;
    if([_connectedDevices isKindOfClass:[NSMutableArray class]]) {
        
        [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CBPeripheral *cb = [obj objectForKey:Peripheral_Ref];
            if ([cb isEqual:peripheral]) {
                NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,[obj objectForKey:Ref_ID],Ref_ID,[obj objectForKey:Adv_Data],Adv_Data,nil];
                [_connectedDevices removeObject:obj];
                
                //
                NSUInteger objectIndex = [self.transmitQueueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                    BOOL found = [[item objectForKey:Peripheral_Ref] isEqual:cb];
                    return found;
                }];
                
                if (objectIndex != NSNotFound) {
                    // Matching item found
                    if((objectIndex > 0 || objectIndex == 0) && objectIndex < self.transmitQueueArray.count) {
                        [self.transmitQueueArray removeObjectAtIndex:objectIndex];
                    } else {
                        DLog(@"Out of bounds 2");
                    }
                } else {
                    // No matching item found.
                }
                [_connectedDevices addObject:dataDic];
                
                advData  = [obj objectForKey:Adv_Data];
                //  else if(![_transmitQueue4 allKeys].count)
                //      self.transmitQueue4 = transmitDictionary;
                // [self.transmitQueueArray addObject:transmitDictionary];
                
                DLog(@" the array is 3 : %@", self.transmitQueueArray);
                *stop = YES;
            }
        }];
    }
    
    //  NSString *uuid = [peripheral.identifier UUIDString];
    if([_connectedDevices isKindOfClass:[NSMutableArray class]])
    {
        // [self addPeripheral:peripheral];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_delegate && [_delegate respondsToSelector:@selector(didRfreshedConnectedPeripherals)])
                [_delegate didRfreshedConnectedPeripherals];
        });
    }
    // Make sure we get the discovery callbacks
    if(peripheral.services)
    {
        //  [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
        
        // [peripheral discoverServices:nil];
        NSLog(@"Manoj 1 already getting services request");
        [self peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
    }
    else
    {
        DLog(@"Manoj 2  services request");
        DLog(@"service UUID is %@",[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]);
        // Search only for services that match our UUID
        // [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
        [peripheral discoverServices:nil];
    }
    
    NSMutableDictionary *transmitDictionary = [[NSMutableDictionary alloc] init];
    [transmitDictionary setObject:peripheral forKey:Peripheral_Ref];
    if ([advData isKindOfClass:[NSNull class]] || advData == nil) {
        advData = @"";
    }
    [transmitDictionary setObject:advData forKey:Adv_Data];
    [transmitDictionary setObject:[[NSMutableArray alloc] init] forKey:DATA];
    
    if(![self.transmitQueue1 allKeys].count)
    {
        self.transmitQueue1 = transmitDictionary;
        NSLog(@"Assigned Peripheral to Queue 1");
        pthread_mutex_unlock(&mutexForThread1);
    }
    else  {
        pthread_mutex_unlock(&mutexForThread1);
        pthread_mutex_lock(&mutexForThread2);
        
        if(![_transmitQueue2 allKeys].count)
        {
            self.transmitQueue2 = transmitDictionary;
            NSLog(@"Assigned Peripheral to Queue 2");
            pthread_mutex_unlock(&mutexForThread2);
        }
        else  {
            pthread_mutex_unlock(&mutexForThread2);
            pthread_mutex_lock(&mutexForThread3);
            
            if(![_transmitQueue3 allKeys].count)
            {
                self.transmitQueue3 = transmitDictionary;
                pthread_mutex_unlock(&mutexForThread3);
                NSLog(@"Assigned Peripheral to Queue 3");
            } else {
                pthread_mutex_unlock(&mutexForThread3);
            }
            
        }
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
    
    DLog(@" the array is 2 : %@",self.transmitQueueArray);
    [self handleTransmitThreadsOnConnectWithPeripheral:peripheral];
}


/**
 @brief Method is called to check whether We got the services of the Peripheral or not
 
 @param per
 */
-(void)checkPeripheralStatusAfter3Seconds:(CBPeripheral *)per
{
    if (per.state == CBPeripheralStateConnected && per.services.count>0 ) {
        
        // connected and also we got the services of the Peripheral
        
        
    }else
    {
        [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             @try {
                 CBPeripheral *cb = [obj objectForKey:Peripheral_Ref];
                 if ([cb isEqual:per]) {
                     
                     if ([[obj objectForKey:Adv_Data] isEqualToString:@""]) {
                         // iPhone device is in Background
                     }else if ([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"B"])
                     {
                         // Buki box connection
                         // Add in dictionay to did not make connection till 2 minutes
                         [_dicToNotAllowConnectionForSomeTime setObject:[AppManager timeStamp]  forKey:per.identifier];
                     }
                     else
                     {
                         // iPhone to iPhone connection
                     }
                     [_connectedDevices removeObject:obj];
                     
                     [self handleTransmitThreadsOnDisconnectWithPeripheral:per];
                     
                     // Connected but did not got the services
                     [self.centralManager cancelPeripheralConnection:per];
                     
                     *stop = YES;
                 }
             } @catch (NSException *exception) {
                 
             } @finally {
                 
             }
         }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected %@ and error is %@",peripheral.name,error);
    if([_connectedDevices isKindOfClass:[NSMutableArray class]]) {
        
        [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @try {
                CBPeripheral *cb = [obj objectForKey:Peripheral_Ref];
                if ([cb isEqual:peripheral]) {
                    if (obj) {
                        [_connectedDevices removeObject:obj];
                        [self handleTransmitThreadsOnDisconnectWithPeripheral:peripheral];
                        *stop = YES;
                    }
                }
            } @catch (NSException *exception) {
            } @finally {
            }
        }];
    }
    
    if (_connectedDevices.count < 4 && _connectedDevices.count !=0) {
        //        [_centralM stopScanning:^(BOOL success) {
        //
        //        }];
        //        [[BLEManager sharedManager] startScanning];
    }else if(_connectedDevices.count ==0)
    {
        [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
            
        }];
        
        [[BLEManager sharedManager].perM.recieveQueue removeAllObjects];
        [[BLEManager sharedManager].centralM.recieveQueue removeAllObjects];
        
        [BLEManager sharedManager].isToHandleScan = NO;
        [[BLEManager sharedManager] startAdvertising];
    }
    
    if([_connectedDevices isKindOfClass:[NSMutableArray class]])
    {
        // [self addPeripheral:peripheral];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_delegate && [_delegate respondsToSelector:@selector(didRfreshedConnectedPeripherals)])
                [_delegate didRfreshedConnectedPeripherals];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(didRfreshedConnectedPeripherals)])
            [_delegate didRfreshedConnectedPeripherals];
    });
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
}

- (void)removePeripheral:(CBPeripheral *)peripheral{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_connectedDevices];
    for(CBPeripheral *per in tempArr){
        NSString *uuid = [per.identifier UUIDString];
        if ([uuid isEqualToString:[peripheral.identifier UUIDString]]||per.state != CBPeripheralStateConnected) {
            if(_connectedDevices&&_connectedDevices.count>0){
                [_connectedDevices removeObject:per];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_delegate && [_delegate respondsToSelector:@selector(didRfreshedConnectedPeripherals)])[_delegate didRfreshedConnectedPeripherals];
                });
            }
        }
    }
    tempArr = nil;
}

- (CBPeripheral*)getExistingPeripheralFromUUID:(NSString*)currentUUID{
    DLog(@"currentUUID == %@",currentUUID);
    CBPeripheral *peripheral;
    for(CBPeripheral *per in self.connectedDevices){
        NSString *uuid = [per.identifier UUIDString];
        DLog(@"UUID == %@",uuid);
        if ([uuid isEqualToString:currentUUID]) {
            peripheral = per;
            break;
        }
    }
    return peripheral;
}

- (void)addPeripheral:(CBPeripheral *)peripheral{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_connectedDevices];
    for(CBPeripheral *per in tempArr){
        NSString *uuid = [per.identifier UUIDString];
        if ([uuid isEqualToString:[peripheral.identifier UUIDString]]){//||per.state != CBPeripheralStateConnected) {
            if(_connectedDevices&&_connectedDevices.count>0)
                [_connectedDevices removeObject:per];
        }
    }
    tempArr = nil;
    //if(peripheral.state == CBPeripheralStateConnected){
    [_connectedDevices addObject:peripheral];
    //}
    
}

- (void)clearPeripheralQue{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_connectedDevices];
    for(CBPeripheral *per in tempArr){
        if (per.state == CBPeripheralStateDisconnected || per.state == CBPeripheralStateDisconnecting || per.name == nil) {
            [_connectedDevices removeObject:per];
        }
    }
    tempArr = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(didRfreshedConnectedPeripherals)])[_delegate didRfreshedConnectedPeripherals];
    });
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        //    [self cleanup];
        return;
    }
    
    DLog(@"services received ---- %@", peripheral.services);
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    
    // if([peripheral.services count] >= 1){
    
    for (CBService *service in peripheral.services) {
        if(service.characteristics)
        {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UPDATE_UUID],[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID],[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_SONAR_UUID]] forService:service];
            
            // [self peripheral:peripheral didDiscoverCharacteristicsForService:service error:nil]; //already discovered characteristic before, DO NOT do it again
            //  [peripheral discoverCharacteristics:nil forService:service];
            //  [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UPDATE_UUID],[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] forService:service];
        }
        else
        {
            
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UPDATE_UUID],[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID],[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_SONAR_UUID]] forService:service];
            
            // [peripheral discoverCharacteristics:nil forService:service];
        }
    }
    //}
    //    else{
    //        NSLog(@"is come sin else");
    //        [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
    //
    //    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
    DLog(@"Array is %@",invalidatedServices);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error)
    {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //  [self cleanup];
        return;
    }
    
    DLog(@"characteristics in services received ---- %@", service.characteristics);
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UPDATE_UUID]])
        {
            //   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        // And check if it's the right one
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] )
        {
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
//            NSString *startingOfPAcket = @"#1";
//            NSString *master_id  = [[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID];
//            NSString *packet   = [NSString stringWithFormat:@"%@%@",startingOfPAcket,master_id];
//            int fragmentNo = 0;
//            
//            NSString *userName = [[Global shared] currentUser].user_name;
//            NSString *userNameLength = userName;
//            if (userName.length<10) {
//                for (int i = userName.length;i < 10; i++) {
//                    userNameLength = [userNameLength stringByAppendingString:@"$"];
//                }
//            }
//            
//            NSLog(@"User Name length is %@",userNameLength);
//            NSData *fragmentNoData =  [NSData dataWithBytes: &fragmentNo length:1];
//            
//            NSMutableData *sendingData = [[NSMutableData alloc] init];
//            [sendingData appendData:[startingOfPAcket dataUsingEncoding:NSUTF8StringEncoding]];
//            [sendingData appendData:[AppManager dataFromHexString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID] ]];
//            [sendingData appendData:fragmentNoData];
//            [sendingData appendData:[AppManager dataFromHexString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID] ]];
//            [sendingData appendData:[userNameLength dataUsingEncoding:NSUTF8StringEncoding]];
//
//            [sendingData appendData:[@"$" dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSString *startingOfPAcket = @"01";
            NSString *master_id  = [[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID];
            NSString *packet   = [NSString stringWithFormat:@"%@%@",startingOfPAcket,master_id];
            
            DLog(@"++ %lu",(unsigned long)characteristic.properties);
            
            NSMutableData *sendingData = [[NSMutableData alloc] init];
            [sendingData appendData:[packet dataUsingEncoding:NSUTF8StringEncoding]];
            
            DLog(@"++ %lu",(unsigned long)characteristic.properties);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheral]) {
                        
                        if ([[obj objectForKey:Adv_Data] isEqualToString:@""]) {
                            
                            //[peripheral writeValue:[packet dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                            [peripheral writeValue:sendingData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                            
                        }else if([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(0,1)] isEqualToString:@"B"])
                        {
                            //[peripheral writeValue:[packet dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                            [peripheral writeValue:sendingData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];

                        }
                        else
                        {
                            [peripheral writeValue:sendingData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                            //[peripheral writeValue:[packet dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                        }
                    }
                }];
                
                // disconnect the peripheral to chck
                
                //            [_dicToNotAllowConnectionForSomeTime setObject:peripheral.identifier forKey:[AppManager timeStamp]];
            });
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_SONAR_UUID]])
        {
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)clearShoutDataWithUUID:(NSString*)uuid{
    ShoutDataReceiver *shR = [self.recieveQueue objectForKey:uuid];
    DLog(@"shout received ----- %@",shR);
    if (shR.header) {
        NSString *shoutId = [shR.header.shoutId copy];
        if (shoutId.length>0) {
            Shout *sht = [Shout shoutWithId:shoutId shouldInsert:NO];
            if(![sht.isShoutRecieved boolValue])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sht removeGarbageShout];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateProgressShout object:[NSNumber numberWithBool:NO] userInfo:nil];
                });
            }
        }
    }
}

- (void)clearDataQueForDisconnectedDevices
{
    NSMutableDictionary *tempRecievePingQueue = [[NSMutableDictionary alloc]
                                                 init];
    NSMutableDictionary *tempRecieveQueue = [[NSMutableDictionary alloc]
                                             init];
    
    [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CBCentral *connectedCen = [obj objectForKey:Peripheral_Ref];
        NSString *uuid = [connectedCen.identifier UUIDString];
        
        ShoutDataReceiver *recObj = [self.recieveQueue objectForKey:uuid];
        if (recObj) {
            [tempRecieveQueue setObject:recObj forKey:uuid];
            [self.recieveQueue removeObjectForKey:uuid];
        }
        
        ShoutDataReceiver *pingObj = [self.recievePingQueue objectForKey:uuid];
        if (pingObj) {
            [tempRecievePingQueue setObject:pingObj forKey:uuid];
            [self.recievePingQueue removeObjectForKey:uuid];
        }
    }];
    
    
    for(NSString *key in self.recieveQueue.allKeys){
        [self clearShoutDataWithUUID:key];
    }
    
    self.recieveQueue = tempRecieveQueue;
    self.recievePingQueue = tempRecievePingQueue;
}

- (void)updateRecievedShoutData:(CBPeripheral *)peripheral Characteristic:(CBCharacteristic *)characteristic value:(NSData *)data Completion:(void(^)(int value, ShoutDataReceiver *receive)) handler
{
    NSMutableData *myData = [data mutableCopy];
    if (myData.length <=6) {
        handler(4,nil);
        return;
    }
    
    NSLog(@"mydat ### %@",myData);
    
    // check first 3 bytes
    NSString  *user_Id;
    NSData   *user_Id_Data;
    NSString *shout_ID;
    NSData   *shout_ID_Data;
    NSData   *specailFlagData;
    
    NSData    *user_data;
    NSString *dataValue;
    NSData *fragmentData;
    NSString *fragmentString;
    NSString *group_Id;
    NSString *network_Id;
    NSData   *contentLengthData;
    NSString *content_Length;
    NSString *specailFlagSTr;
    NSData   *owner_data;
    NSString *owner_Id;
    NSString  *spclByte4SchduleStr;
    
    NSData   *cmsData;
    NSString *cmsIDValue;
    
    NSString *bom;
    if ([myData length]>3)
    {
        dataValue = [[NSString alloc] initWithData:[myData subdataWithRange:NSMakeRange(0, 3)] encoding:NSUTF8StringEncoding];
        DLog(@"Dta Value is %@",dataValue);
        NSString *bom;
        if (myData.length>3)
        {
            bom = [[NSString alloc] initWithData:[myData subdataWithRange:NSMakeRange(0, 3)] encoding:NSUTF8StringEncoding];
        }
    }
    else
    {
        handler(4,nil);
        return;
    }
    
    ShoutDataReceiver *pckData = nil;
    ShoutHeader          *header  = [[ShoutHeader alloc] init];
    BOOL isFirstPacket = NO;
    int initialSTrtingByteNo;
    int specialByteForiPhone;
    NSData *spclByteForiPhone;
    if ([bom isEqualToString:BOM] || [dataValue isEqualToString:BOM])
    {
        isFirstPacket = YES;
        initialSTrtingByteNo = BOM_Length+KSPCL_Length_Schdule_ID_Length;
        
        spclByte4SchduleStr  = [[[NSString stringWithFormat:@"%@",[myData subdataWithRange:NSMakeRange(BOM_Length,KSPCL_Length_Schdule_ID_Length-1)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        
        cmsIDValue  = [[[NSString stringWithFormat:@"%@",[myData subdataWithRange:NSMakeRange(6,3)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        
        group_Id  = [[[NSString stringWithFormat:@"%@",[myData subdataWithRange:NSMakeRange(HeaderLength+BOM_Length+KSPCL_Length_Schdule_ID_Length,KGroup_ID_Length)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        network_Id  = [[[NSString stringWithFormat:@"%@",[myData subdataWithRange:NSMakeRange(HeaderLength+KGroup_ID_Length+BOM_Length+KSPCL_Length_Schdule_ID_Length,KNetwork_ID_Length)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    }
    else
    {
        isFirstPacket = NO;
        initialSTrtingByteNo = 0;
        cmsIDValue  = [[[NSString stringWithFormat:@"%@",[myData subdataWithRange:NSMakeRange(0,3)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    }
    if(myData.length==7)
    {
        user_data = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+HeaderLength-1, [myData length]-(HeaderLength-1+initialSTrtingByteNo))];
    }else
    {
        user_data = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+HeaderLength, [myData length]-(HeaderLength+initialSTrtingByteNo))];
    }
    user_Id_Data     = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo,KLoud_Hailer_ID_Length)];
    shout_ID_Data   = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length,KShout_ID_Length)];
    
    spclByteForiPhone  = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH-2,1)];
    
    BOOL isFromiPhoneOrCMSMsg = NO;
    specialByteForiPhone = [[NSString stringWithFormat:@"%d",[AppManager convertIntFromString:[[[NSString stringWithFormat:@"%@",spclByteForiPhone] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""]]] intValue];
    
    // hex of 80
    if (specialByteForiPhone != 128) {
        isFromiPhoneOrCMSMsg = YES;
    }
    
    //  if(isFirstPacket)
    //  {
    if (!isFromiPhoneOrCMSMsg) {
        specailFlagData = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH-2,1)];
        
        fragmentData = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length-2,FRAGMENT_LENGTH)];
    }else
    {
        specailFlagData = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH,1)];
        fragmentData = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length,FRAGMENT_LENGTH)];
    }
    
    user_Id   =  [[[NSString stringWithFormat:@"%@",user_Id_Data] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    shout_ID =  [[[NSString stringWithFormat:@"%@",shout_ID_Data] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    fragmentString =  [[[NSString stringWithFormat:@"%@",fragmentData] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    specailFlagSTr =  [[[NSString stringWithFormat:@"%@",specailFlagData] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    DLog(@"LoudHailer_Id is  and User Id is  and Shout ID is %@ %@ %@",shout_ID, [[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],user_Id);
    
    //Here:   NSData * fileData;
    // reduce 4096
    // int number   = [AppManager convertIntFromString:fragmentString]-k_ReduceFragment_No;
    int number;
    if (!isFromiPhoneOrCMSMsg) {
        number   = [AppManager convertIntFromString:fragmentString];
    }else
    {
        number   = [AppManager convertIntFromString:fragmentString] - k_ReduceFragment_No;;
    }
    
    DLog(@"Number is %d",number);
    
    if (number ==2 || number == 1) {
        
        if (myData.length==20) {
            
            content_Length  = [[[NSString stringWithFormat:@"%@",[myData subdataWithRange:NSMakeRange(HeaderLength,KContent_Data_Length)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            contentLengthData = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH+KSpecial_Byte_ID_Length,KContent_Data_Length)];
            
            owner_data  = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH+KSpecial_Byte_ID_Length+KAppDisplayTime_length+KContent_Data_Length,KOwner_Id_Length)];
            
            owner_Id =  [[[NSString stringWithFormat:@"%@",owner_data] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            int owner_ID = [AppManager convertIntFromString:[[[NSString stringWithFormat:@"%@",owner_Id] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""]];
            
            owner_Id = [NSString stringWithFormat:@"%d",owner_ID];
        }
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID] isEqualToString:user_Id])
    {
        // return a call back
        // duplicate packet
        handler(1,pckData);
        return;
    }
    
    //pckData = [_recieveQueue objectForKey:user_Id];
    if (isFromiPhoneOrCMSMsg) {
        pckData = [_recieveQueue objectForKey:[NSString stringWithFormat:@"%@_%@",user_Id,shout_ID]];
        pckData.header.uniqueID = [NSString stringWithFormat:@"%@_%@",user_Id,shout_ID];
        
    }else
    {
        pckData = [_recieveQueue objectForKey:[NSString stringWithFormat:@"%@",user_Id]];
        pckData.header.uniqueID = [NSString stringWithFormat:@"%@",user_Id];
    }
    
    if (isFirstPacket) {
        
        if (!pckData.firsTnumberTime) {
            pckData.firsTnumberTime = [AppManager convertIntFromString:spclByte4SchduleStr];
        }else
        {
            pckData.secondNumberTime = pckData.firsTnumberTime;
            pckData.firsTnumberTime = [AppManager convertIntFromString:spclByte4SchduleStr];
        }
    }
    
    if (fragmentString==nil || [fragmentString isEqual:[NSNull null]]) {
        return;
    }
    
    __block BOOL isDuplicate = false;
    __block BOOL isDuplicateLastChunk =false;
    if (pckData) {
        
        [pckData.packetArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSUInteger lastIndex = [[obj objectForKey:@"Frag_No"] integerValue];
            if ([[obj objectForKey:@"Frag_No"] integerValue] == number )
            {
                // duplicate packets
                if (pckData.isLastChunk && pckData.isPacketHeaderFound && (lastIndex == number) && pckData.packetArray.count-1 == lastIndex) {
                    
                    isDuplicateLastChunk = YES;
                    return;
                }
                else
                {
                    isDuplicate = YES;
                    return;
                }
                //  *stop = YES;
            }
        }];
    }
    
    if (isDuplicateLastChunk) {
        
        if (pckData.isLastChunk && pckData.isPacketHeaderFound && (pckData.firsTnumberTime != 12336) && (pckData.secondNumberTime !=12336) && (pckData.firsTnumberTime != pckData.secondNumberTime)) {
            if(isFirstPacket)
            {
                // save logs into the database
                [self saveDebugLogsInDataBase:pckData isFirstPacket:YES];
            }
            // just forward to others
            DLog(@"Just forward to others +++");
            handler(5,pckData);
            return;
            
        }
        else
        {
            if(isFirstPacket)
            {
                // save logs into the database
                [self saveDebugLogsInDataBase:pckData isFirstPacket:YES];
            }
            handler(1,pckData);
            DLog(@"Duplicate packets");
            return;
        }
    }
    
    if (isDuplicate) {
        if (pckData.isLastChunk && pckData.isPacketHeaderFound && (pckData.firsTnumberTime != 12336 ) && (pckData.secondNumberTime !=12336) && (pckData.firsTnumberTime != pckData.secondNumberTime)) {
            if(isFirstPacket)
            {
                // save logs into the database
                [self saveDebugLogsInDataBase:pckData isFirstPacket:YES];
            }
            // just forward to others
            DLog(@"Just forward to others +++");
            if(isFirstPacket)
            {
                // save logs into the database
                [self saveDebugLogsInDataBase:pckData isFirstPacket:YES];
            }
            handler(5,pckData);
            return;
            
        }
        else
        {
            if(isFirstPacket)
            {
                // save logs into the database
                [self saveDebugLogsInDataBase:pckData isFirstPacket:YES];
            }
            handler(4,pckData);
            DLog(@"Duplicate packets");
            return;
        }
    }
    
    
    if(!pckData)
    {
        pckData = [[ShoutDataReceiver alloc] init];
        pckData.shoutData = [NSMutableData new];
        pckData.packetArray = [[NSMutableArray alloc] init];
        pckData.packetArrayForChannelMsg = [[NSMutableArray alloc] init];
        header.loudHailer_Id = user_Id;
        DLog(@"Content length is %@",content_Length);
        if (content_Length.length>0 && ![content_Length isEqual:[NSNull null]]) {
            header.totalShoutLength =[[NSString stringWithFormat:@"%d",[AppManager convertIntFromString:content_Length]] intValue]; // [content_Length intValue];
        }
        
        if (number ==1) {
            
            header.ownerId = owner_Id;
        }
        
        header.network_ID  = network_Id;
        header.shoutId         = [NSString stringWithFormat:@"%d%d",[AppManager convertIntFromString:shout_ID],[AppManager convertIntFromString:user_Id]];
        
        pckData.header = header;
        pckData.cmsID = cmsIDValue;
        pckData.header.typeOfMsgSpecialOne  = [[NSString stringWithFormat:@"%d",[AppManager convertIntFromString:specailFlagSTr]] intValue];
        
        if (isFirstPacket) {
            pckData.isPacketHeaderFound = YES;
        }
        BOOL isFound = false;
        
        if (pckData.header.typeOfMsgSpecialOne == 5 || pckData.header.typeOfMsgSpecialOne == 1) {
            // text
            pckData.isFromCMS = NO;
            if(pckData.header.typeOfMsgSpecialOne == 1)
            {
                pckData.header.isP2pMsg = YES;
            }else
            {
                pckData.header.isP2pMsg = NO;
            }
            pckData.header.type = 0;
            isFound = YES;
        }
        else if (pckData.header.typeOfMsgSpecialOne ==29 || pckData.header.typeOfMsgSpecialOne == 9)
        {
            // Image
            pckData.isFromCMS = NO;
            if(pckData.header.typeOfMsgSpecialOne == 1)
            {
                pckData.header.isP2pMsg = YES;
            }else
            {
                pckData.header.isP2pMsg = NO;
            }
                pckData.header.type = 1;
            isFound = YES;
        }
        else if(pckData.header.typeOfMsgSpecialOne == 25 || pckData.header.typeOfMsgSpecialOne == 21)
        {
            // Gif From iPhone
            pckData.isFromCMS = NO;
            if(pckData.header.typeOfMsgSpecialOne == 1)
            {
                pckData.header.isP2pMsg = YES;
            }else
            {
                pckData.header.isP2pMsg = NO;
            }
            pckData.header.type = 6;
    
            isFound = YES;
        }
        else if(pckData.header.typeOfMsgSpecialOne == 21)
        {
            // Audio
            pckData.isFromCMS = NO;
            pckData.header.type = 2;
            isFound = YES;
        }
        else if(pckData.header.typeOfMsgSpecialOne == 13)
        {
            // Video
            pckData.isFromCMS = NO;
            pckData.header.type = 3;
            isFound = YES;
        }
        else if (pckData.header.typeOfMsgSpecialOne == 74)
        {
            // Image from CMS
            pckData.isFromCMS = YES;
            
            pckData.header.type = 1;
            isFound = YES;
        }
        else if (pckData.header.typeOfMsgSpecialOne == 73)
        {
            // gif from CMS
            pckData.isFromCMS = YES;
            pckData.header.type = 6;
            isFound = YES;
            
        }
        if (!isFound) {
            
            NSString *string = @"" ;
            NSUInteger x = pckData.header.typeOfMsgSpecialOne;
            
            while (x>0) {
                string = [[NSString stringWithFormat: @"%lu", x&1] stringByAppendingString:string];
                x = x >> 1;
            }
            
            if ([string isEqual:[NSNull null]] || [string isEqualToString:@""] || [string isEqualToString:@"0"]) {
                return;
            }
            
            if (string.length<4) {
                return;
            }
            
            if ([[string substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"1000"]) {
                
                pckData.isFromCMS = YES;
                pckData.header.typeOfMsgSpecialOne = 176;
                isFound = YES;
            }
        }
        if (pckData.header.typeOfMsgSpecialOne == 72 && !isFound)
        {
            // text from CMS
            pckData.isFromCMS = YES;
            pckData.header.type = 0;
            isFound = YES;
        }
        
        if (group_Id.length>0 && ![group_Id isEqual:[NSNull null]])
        {
            if (pckData.isFromCMS) {
                header.groupId = [NSString stringWithFormat:@"%d",[group_Id intValue]];//[AppManager convertIntFromString:group_Id]];
            }else
            {
                header.groupId = [NSString stringWithFormat:@"%d",[AppManager convertIntFromString:group_Id]];
            }
        }
        
        if(isFirstPacket)
        {
            pckData.firsTnumberTime = [AppManager convertIntFromString:spclByte4SchduleStr];
        }
        
        if (isFromiPhoneOrCMSMsg) {
            [_recieveQueue setObject:pckData forKey:[NSString stringWithFormat:@"%@_%@",user_Id,shout_ID]];
            pckData.header.uniqueID = [NSString stringWithFormat:@"%@_%@",user_Id,shout_ID];
        }else
        {
            [_recieveQueue setObject:pckData forKey:[NSString stringWithFormat:@"%@",user_Id]];
            pckData.header.uniqueID = [NSString stringWithFormat:@"%@",user_Id];
        }
        
        // save logs into the database
        [self saveDebugLogsInDataBase:pckData isFirstPacket:NO];
        //pckData.header.userID =
    }
    else if ((pckData && number ==2 && !pckData.isFromCMS) || (pckData.isFromCMS && number ==1))
    {
        if (pckData && pckData.isFromCMS) {
            if (pckData.header == nil) {
                header.ownerId = owner_Id;
                pckData.header = header;
                pckData.cmsID = cmsIDValue;
            }
            else
            {
                pckData.header.ownerId = owner_Id;
                pckData.cmsID = cmsIDValue;
            }
            
        }
        else if (number ==2) {
            if (pckData.header == nil) {
                header.ownerId = owner_Id;
                pckData.header = header;
                pckData.cmsID = cmsIDValue;
            }
            else
            {
                pckData.header.ownerId = owner_Id;
                pckData.cmsID = cmsIDValue;
            }
        }
    }
    else if (pckData && isFirstPacket && number == 0) {
        if (group_Id.length>0 && ![group_Id isEqual:[NSNull null]])
        {
            pckData.header.groupId = [NSString stringWithFormat:@"%d",[AppManager convertIntFromString:group_Id]];
        }
        
        pckData.firsTnumberTime = [AppManager convertIntFromString:spclByte4SchduleStr];
        pckData.cmsID = cmsIDValue;
        pckData.header.network_ID  = network_Id;
    }
    
    if (myData) {
        if (isFirstPacket) {
            number = 0;
            NSDictionary *dic  = [[NSDictionary alloc] initWithObjectsAndKeys:myData,@"Data",[NSNumber numberWithInt:number],@"Frag_No",nil];
            [pckData.packetArray addObject:dic];
            [pckData.packetArrayForChannelMsg addObject:dic];
            pckData.isPacketHeaderFound = YES;
            [pckData.shoutData appendData:myData];
        }
        else
        {
            NSDictionary *dic;
            NSDictionary *dicForChannelMsg;
            if (number == 1) {
                dicForChannelMsg  = [[NSDictionary alloc] initWithObjectsAndKeys:myData,@"Data",[NSNumber numberWithInt:number],@"Frag_No",nil];
                dic  = [[NSDictionary alloc] initWithObjectsAndKeys:[myData subdataWithRange:NSMakeRange(HeaderLength, [myData length]-HeaderLength)],@"Data",[NSNumber numberWithInt:number],@"Frag_No",nil];
            }
            else
            {
                dicForChannelMsg  = [[NSDictionary alloc] initWithObjectsAndKeys:myData,@"Data",[NSNumber numberWithInt:number],@"Frag_No",nil];
                if(myData.length==7)
                {
                    dic  = [[NSDictionary alloc] initWithObjectsAndKeys:[myData subdataWithRange:NSMakeRange(HeaderLength-2, [myData length]-(HeaderLength-2))],@"Data",[NSNumber numberWithInt:number],@"Frag_No",nil];
                }else if(myData.length==8)
                    {
                        dic  = [[NSDictionary alloc] initWithObjectsAndKeys:[myData subdataWithRange:NSMakeRange(HeaderLength-2, [myData length]-(HeaderLength-2))],@"Data",[NSNumber numberWithInt:number],@"Frag_No",nil];
                    }
                else
                {
                    dic  = [[NSDictionary alloc] initWithObjectsAndKeys:[myData subdataWithRange:NSMakeRange(HeaderLength, [myData length]-HeaderLength)],@"Data",[NSNumber numberWithInt:number],@"Frag_No",nil];
                }
            }
            [pckData.packetArray addObject:dic];
            [pckData.shoutData appendData:myData];
            [pckData.packetArrayForChannelMsg addObject:dicForChannelMsg];
        }
        
        NSSortDescriptor * brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Frag_No" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
        NSArray *sortedArray = [pckData.packetArray sortedArrayUsingDescriptors:sortDescriptors];
        
        [pckData.packetArray  removeAllObjects];
        pckData.packetArray  = [sortedArray mutableCopy];
        
        if (pckData.isPacketHeaderFound && pckData.isGotLastPacket)
        {
            int lastIndex   = [[[pckData.packetArray lastObject] objectForKey:@"Frag_No"] intValue];
            if (pckData.packetArray.count-1 == lastIndex && !pckData.isGotPerfectImage)
            {
                pckData.isLastChunk = YES;
                pckData.isGotPerfectImage = YES;
                // return a call back
                handler(3,pckData);
                [self saveDebugLogsInDataBase:pckData isFirstPacket:NO];
                return;
            }
            else if ((pckData.packetArray.count-1 - lastIndex) <=8 && !pckData.isGotPerfectImage)
            {
                pckData.isLastChunk = YES;
                // return a call back
                handler(3,pckData);
                [self saveDebugLogsInDataBase:pckData isFirstPacket:NO];
                return;
            }
        }
        NSString *eom;
        unsigned long length;
        int headerLength;
        if (!isFromiPhoneOrCMSMsg) {
            length = [myData length]-HeaderLength+2;
            headerLength = 6;
        }else
        {
            length = [myData length]-HeaderLength;
            headerLength = 8;
        }
//        if ([myData length] < headerLength+EOM_Length) {
//            return;
//        }
        
        if (length>EOM_Length) {
            eom = [[NSString alloc] initWithData:[myData subdataWithRange:NSMakeRange([myData length]-EOM_Length, EOM_Length)] encoding:NSUTF8StringEncoding];
        }
        else if (length==EOM_Length) {
            
            eom = [[NSString alloc] initWithData:[myData subdataWithRange:NSMakeRange(headerLength,EOM_Length)]encoding:NSUTF8StringEncoding];
        }
        else if (length ==2)
        {
            eom = [[NSString alloc] initWithData:[myData subdataWithRange:NSMakeRange(headerLength, EOM_Length-1)]encoding:NSUTF8StringEncoding];
        }
        else if (length ==1)
        {
            eom = [[NSString alloc] initWithData:[myData subdataWithRange:NSMakeRange(headerLength,EOM_Length-2)]encoding:NSUTF8StringEncoding];
        }
        DLog(@"end of msg is last 3 digit %@",eom);
        DLog(@"end of msg is last 2 digit %@",eom);
        DLog(@"end of msg is last 1 digit %@",eom);
        
        if ([eom isEqualToString:EOM] || [eom isEqualToString:@"OM"] || [eom isEqualToString:@"M"])
        {
            if ([eom isEqualToString:@"OM"])
            {
                // last packet k last byte
                if (pckData.packetArray.count>2) {
                    
                    NSData *data =  [[pckData.packetArray objectAtIndex:[pckData.packetArray count]-2] objectForKey:@"Data"];
                    NSString *str = [[NSString alloc] initWithData:[data  subdataWithRange:NSMakeRange([data length]-1, 1)]encoding:NSUTF8StringEncoding];
                    if ([str isEqualToString:@"E"]) {
                        
                    }else
                    {
                        handler(2,pckData);
                        return;
                    }
                }
                else
                {
                    handler(2,pckData);
                    return;
                }
            }
            else if ([eom isEqualToString:@"M"])
            {
                if (pckData.packetArray.count>2) {
                    
                    NSData *data =  [[pckData.packetArray objectAtIndex:[pckData.packetArray count]-2] objectForKey:@"Data"];
                    NSString *str = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange([data length] -2, 2)]encoding:NSUTF8StringEncoding];
                    if ([str isEqualToString:@"EO"]) {
                        
                    }else
                    {
                        handler(2,pckData);
                        return;
                    }
                }else
                {
                    handler(2,pckData);
                    return;
                }
            }
            
            if (pckData)
            {
                [pckData.packetArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([[obj objectForKey:@"Frag_No"] intValue] == number) {
                        // duplicate packets
                        if (pckData.isPacketHeaderFound && pckData.isLastChunk) {
                            handler(1,pckData);
                            return;
                        }
                    }
                }];
            }
            
            pckData.isChecked    = YES;
            // return a call back
            
            pckData.isGotLastPacket = YES;
            
            if (pckData.isPacketHeaderFound) {
                
                int lastIndex   = [[[pckData.packetArray lastObject] objectForKey:@"Frag_No"] intValue];
                
                NSLog(@"Last Packet is :%@ SHout Id is %@ Type Of Data is %d Last index : %d Total data : %lu", myData,shout_ID, pckData.header.typeOfMsgSpecialOne, lastIndex, (unsigned long)pckData.packetArray.count);
                
                if (pckData.packetArray.count-1 == lastIndex || (lastIndex-(pckData.packetArray.count-1)) <=8)
                {
                    if (pckData.packetArray.count-1 == lastIndex) {
                        pckData.isGotPerfectImage = YES;
                    }else
                        pckData.isGotPerfectImage     = NO;
                    
                    DLog(@"Got the All packets of Message having shout Id : %@",shout_ID);
                    pckData.isLastChunk = YES;
                    // return a call back
                    handler(3,pckData);
                    [self saveDebugLogsInDataBase:pckData isFirstPacket:NO];
                    return;
                }
                else
                {
                    handler(2,pckData);
                    return;
                }
            }
        }
        else
        {
            handler(2,pckData);
            return;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheralP didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"BH into didupdate");
    
    NSLog(@"Dataggggg %@",[characteristic value]);
    CBCharacteristic *characterSt ;
    
    NSString *uuid = characteristic.UUID.UUIDString;
    NSData   *data = [[characteristic value] copy];
    CBPeripheral *ph = [peripheralP copy];
    [self.gettingDataThread addOperationWithBlock:^{
        
        
        DLog(@"Manoj %@",data);
        
        if (error||characteristic.value==0) {
            NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_delegate && [_delegate respondsToSelector:@selector(didRecieveError:)]) {
                    [_delegate didRecieveError:error];
                }
            });
            return;
        }
        if ([uuid isEqualToString:TRANSFER_CHARACTERISTIC_UPDATE_UUID]) {
            
            NSString *stringValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DLog(@"String value is %@",stringValue);
            
            NSString *stringReceived1 = [[NSString alloc]initWithData:[data subdataWithRange:NSMakeRange(0, 2)] encoding:NSUTF8StringEncoding];

            // for the ping request (Device presence Ping packet)
            if ([[stringReceived1 substringWithRange:NSMakeRange(0,2)] isEqualToString:UniqueIdentifierString])
            {
                
                NSData *forwardData =  [[DevicePresencePacketInfo sharedInstance] updateTheHopeCount:[data  mutableCopy] isFromCentral:nil isFromPeripheralDevice:peripheralP];
                
                NSLog(@"Received Device Presence Packet and new packet is %@ ++ %@",data,forwardData);
                
                if(forwardData==nil)
                {
                    return;
                }
                
                pthread_mutex_lock(&mutexForThread1);
                
                if (_transmitQueue1)
                {
                    if (![[_transmitQueue1 objectForKey:Peripheral_Ref] isEqual:peripheralP])
                    {
                        [[self.transmitQueue1 objectForKey:DATA] addObject:[forwardData mutableCopy]];
                        pthread_mutex_unlock(&mutexForThread1);
                        
                    }else
                    {
                        pthread_mutex_unlock(&mutexForThread1);
                    }
                }
                else
                    pthread_mutex_unlock(&mutexForThread1);
                
                
                pthread_mutex_lock(&mutexForThread2);
                
                if (_transmitQueue2) {
                    
                    if (![[_transmitQueue2 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                        
                        [[self.transmitQueue2 objectForKey:DATA] addObject:[forwardData mutableCopy]];
                        pthread_mutex_unlock(&mutexForThread2);
                    }else
                    {
                        pthread_mutex_unlock(&mutexForThread2);
                    }
                }else
                    pthread_mutex_unlock(&mutexForThread2);
                
                pthread_mutex_lock(&mutexForThread3);
                
                if (_transmitQueue3) {
                    
                    if (![[_transmitQueue3 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                        
                        [[self.transmitQueue3 objectForKey:DATA] addObject:[forwardData mutableCopy]];
                        pthread_mutex_unlock(&mutexForThread3);
                    }else
                    {
                        pthread_mutex_unlock(&mutexForThread3);
                    }
                }else
                {
                    pthread_mutex_unlock(&mutexForThread3);
                }
            }
            
            else if ([[stringValue substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"02"])
            {
                DLog(@"BH 02");
                
                if ([[stringValue substringWithRange:NSMakeRange(2, stringValue.length-2)] isEqualToString:@"owly"]) {
                    
                    [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                            
                            for (CBService *service in peripheralP.services)
                            {
                                if (service.characteristics != nil) {
                                    for (CBCharacteristic *characteristic in service.characteristics) {
                                        
                                        [peripheralP setNotifyValue:NO forCharacteristic:characteristic];
                                    }
                                }
                            }
                            NSLog(@"Peripheral Disconnecting %@ ",peripheralP);
                            
                            [_centralManager cancelPeripheralConnection:peripheralP];
                            [self handleTransmitThreadsOnDisconnectWithPeripheral:peripheralP];
                            
                            [_connectedDevices removeObject:obj];
                            // *stop = YES;
                            return;
                        }
                    }];
                }
                else
                {
                    DLog(@"BH 02 else");
                    [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                            
                            
                            DLog(@"Value updated in Master 1 from central for Central %@ ++ %@",peripheralP,obj);
                            
                            DLog(@"%@",[stringValue substringWithRange:NSMakeRange(8, stringValue.length-8)]);
                            NSString *idOf   = [stringValue substringWithRange:NSMakeRange(2, 6)];
                            NSDictionary *dic  = [[NSDictionary alloc] initWithObjectsAndKeys:peripheralP,Peripheral_Ref,idOf,Ref_ID,[stringValue substringWithRange:NSMakeRange(8, stringValue.length-8)],Adv_Data,nil];
                            
                            [_connectedDevices replaceObjectAtIndex:idx withObject:dic];
                            
                            DLog(@" the array is 5 : %@",self.transmitQueueArray);
                            
                            NSMutableArray *arr   = [[NSMutableArray alloc] init];
                            [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                
                                NSMutableDictionary *dic   = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[obj objectForKey:Adv_Data],[obj objectForKey:Ref_ID], nil];
                                [arr addObject:dic];
                            }];
                            *stop = YES;
                            return;
                        }
                    }];
                }
                return;
            }
            else if ([[stringValue substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"PB"])
            {
                if ([[stringValue substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"F"])
                {
                    // force disconnection due to
                    // disconnection
                    // disconnect
                    [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                            
                            CBPeripheral *ph = [obj objectForKey:Peripheral_Ref];
                            for (CBService *service in ph.services)
                            {
                                if (service.characteristics != nil)
                                {
                                    for (CBCharacteristic *characteristic in service.characteristics) {
                                        
                                        [ph setNotifyValue:NO forCharacteristic:characteristic];
                                        
                                    }
                                }
                            }
                            NSLog(@"Disconnecting the Central based on nomal ping packet");
                            [_dicToNotAllowConnectionForSomeTime setObject:[AppManager timeStamp]  forKey:ph.identifier];
                            
                            NSLog(@"Peripheral Disconnecting %@ ",ph);
                            
                            [_centralManager cancelPeripheralConnection:ph];
                            [_connectedDevices removeObject:obj];
                            
                            if ([_connectedDevices count] > 1) {
                                
                            }else
                            {
                                [[BLEManager sharedManager] invalidateTimer];
                                
                                [BLEManager sharedManager].isToHandleScan = NO;
                                [[BLEManager sharedManager] startAdvertising];
                            }
                            [self handleTransmitThreadsOnDisconnectWithPeripheral:ph];
                            *stop = YES;
                            
                            return;
                        }
                    }];
                }
                else if ([[stringValue substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"N"])
                {
                    // disconnection due to normal packet
                    if ([_connectedDevices count] ==1)
                    {
                        // disconnect
                        NSLog(@"Disconnecting the Central based on nomal ping packet");
                        CBPeripheral *ph = [[_connectedDevices objectAtIndex:0] objectForKey:Peripheral_Ref];
                        for (CBService *service in ph.services)
                        {
                            if (service.characteristics != nil) {
                                for (CBCharacteristic *characteristic in service.characteristics) {
                                    [ph setNotifyValue:NO forCharacteristic:characteristic];
                                }
                            }
                        }
                        
                        NSLog(@"Peripheral Disconnecting %@ ",ph);
                        
                        [_centralManager cancelPeripheralConnection:ph];
                        [_dicToNotAllowConnectionForSomeTime setObject:[AppManager timeStamp]  forKey:ph.identifier];
                        [_connectedDevices removeAllObjects];
                        
                        [[BLEManager sharedManager] invalidateTimer];
                        
                        [BLEManager sharedManager].isToHandleScan = NO;
                        [[BLEManager sharedManager] startAdvertising];
                        
                        [self handleTransmitThreadsOnDisconnectWithPeripheral:ph];
                    }
                    else
                        NSLog(@"Can't disconnect the Central based on nomal ping packet");
                }
                else
                {
                    // Ping packet from CMS side
                    // PB100147:261032111PE
                    
                    // if packet is coming from Buki Box send it to the queue
                    
                    // if packet is coming from iPhone write it to the buki box
                    
                    __block BOOL isPacketFromBukiBox = false;
                    __block BOOL isPacketFromiPhone   = false;
                    
                    [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                            
                            if ([[obj objectForKey:Adv_Data] isEqualToString:@""]) {
                                
                                isPacketFromiPhone = YES;
                            }
                            else if ([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"B"])
                            {
                                isPacketFromBukiBox = YES;
                            }else
                            {
                                isPacketFromiPhone = YES;
                            }
                        }
                    }];
                    
                    if (isPacketFromBukiBox && !isPacketFromiPhone) {
                        
                        pthread_mutex_lock(&mutexForThread1);
                        
                        if (_transmitQueue1)
                        {
                            if (![[_transmitQueue1 objectForKey:Peripheral_Ref] isEqual:peripheralP])
                            {
                                [[self.transmitQueue1 objectForKey:DATA] addObject:[data mutableCopy]];
                                pthread_mutex_unlock(&mutexForThread1);
                                
                            }else
                            {
                                pthread_mutex_unlock(&mutexForThread1);
                            }
                        }
                        else
                            pthread_mutex_unlock(&mutexForThread1);
                        
                        
                        pthread_mutex_lock(&mutexForThread2);
                        
                        if (_transmitQueue2) {
                            
                            if (![[_transmitQueue2 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                                
                                [[self.transmitQueue2 objectForKey:DATA] addObject:[data mutableCopy]];
                                pthread_mutex_unlock(&mutexForThread2);
                            }else
                            {
                                pthread_mutex_unlock(&mutexForThread2);
                            }
                        }else
                            pthread_mutex_unlock(&mutexForThread2);
                        
                        pthread_mutex_lock(&mutexForThread3);
                        
                        if (_transmitQueue3) {
                            
                            if (![[_transmitQueue3 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                                
                                [[self.transmitQueue3 objectForKey:DATA] addObject:[data mutableCopy]];
                                pthread_mutex_unlock(&mutexForThread3);
                            }else
                            {
                                pthread_mutex_unlock(&mutexForThread3);
                            }
                        }else
                        {
                            pthread_mutex_unlock(&mutexForThread3);
                        }
                    }
                    else if(!isPacketFromBukiBox && isPacketFromiPhone)
                    {
                        [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            //   if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                            
                            if ([[obj objectForKey:Adv_Data] isEqualToString:@""]) {
                                
                            }
                            else if ([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"B"])
                            {
                                CBPeripheral *cb = [obj objectForKey:Peripheral_Ref];
                                for (CBService *service in cb.services) {
                                    if (service.characteristics != nil) {
                                        for (CBCharacteristic *characteristic1 in service.characteristics) {
                                            
                                            if([characteristic1.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] )
                                            {
                                                if ([characteristic value]>0) {
                                                    
                                                    [cb writeValue:data forCharacteristic:characteristic1 type:CBCharacteristicWriteWithResponse];
                                                    DLog(@"Ping packet to buki box forwarded to %@ with packet %@",[obj objectForKey:Peripheral_Ref],data);
                                                    *stop = YES;
                                                    return;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                            }
                            //   }
                        }];
                    }
                }
                return;
            }
            else if(data.length>=8 && [[stringValue substringWithRange:NSMakeRange(0, 8)] isEqualToString:kStringOfDeletedPacket])
            {
                NSString *contentID = [stringValue substringWithRange:NSMakeRange(9,6)] ;
                if ([contentID isKindOfClass:(id)[NSNull null]]) {
                    return;
                }
                if ([[BLEManager sharedManager].deletePacketDictionary objectForKey:contentID]) {
                    return;
                }else
                {
                    [[[BLEManager sharedManager] deletePacketDictionary] setObject:stringValue forKey:contentID];
                }
                // packet for delete the content
                // #!DELETE-000011!#
                pthread_mutex_lock(&mutexForThread1);
                
                if (_transmitQueue1)
                {
                    if (![[_transmitQueue1 objectForKey:Peripheral_Ref] isEqual:peripheralP])
                    {
                        [[self.transmitQueue1 objectForKey:DATA] addObject:[data mutableCopy]];
                        pthread_mutex_unlock(&mutexForThread1);
                        
                    }else
                    {
                        pthread_mutex_unlock(&mutexForThread1);
                    }
                }
                else
                    pthread_mutex_unlock(&mutexForThread1);
                
                
                pthread_mutex_lock(&mutexForThread2);
                
                if (_transmitQueue2) {
                    
                    if (![[_transmitQueue2 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                        
                        [[self.transmitQueue2 objectForKey:DATA] addObject:[data mutableCopy]];
                        pthread_mutex_unlock(&mutexForThread2);
                    }else
                    {
                        pthread_mutex_unlock(&mutexForThread2);
                    }
                }else
                    pthread_mutex_unlock(&mutexForThread2);
                
                pthread_mutex_lock(&mutexForThread3);
                
                if (_transmitQueue3) {
                    
                    if (![[_transmitQueue3 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                        
                        [[self.transmitQueue3 objectForKey:DATA] addObject:[data mutableCopy]];
                        pthread_mutex_unlock(&mutexForThread3);
                    }else
                    {
                        pthread_mutex_unlock(&mutexForThread3);
                    }
                }else
                {
                    pthread_mutex_unlock(&mutexForThread3);
                }
                
                if(_delegate && [_delegate respondsToSelector:@selector(deletePacketForContent:)]) {
                    DLog(@"peripheral __* %@",peripheralP);
                    DLog(@"characteristic __*%@",characteristic);
                    
                    [_delegate deletePacketForContent:[data mutableCopy]];
                }
                
                
                return;
            }
            
            // broadcast the msg whatever user got it
            NSString *uuid = [ph.identifier UUIDString];
            NSData *d = [data copy];
            
            DLog(@"Manoj dixit   %@",d);
            
            [self updateRecievedShoutData:ph Characteristic:characterSt value:data Completion:^(int value, ShoutDataReceiver *receive)
             {
                 if (value ==1)
                 {
                     if ([self.connectedDevices count] ==1) {
                         
                         DLog(@"BH Discarded message due to duplicate message packet %@",d);
                         
                         return;
                     }
                     
                     return;
                     
                     // duplicate message
                     // also call to disconnect user
                     // no need to broadcast
                     [self.connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                         if ([[obj objectForKey:Peripheral_Ref] isEqual:ph])
                         {
                             if (![[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"B"]) {
                                 
                                 if ([[[obj objectForKey:Adv_Data] substringWithRange:NSMakeRange(7,1)] isEqualToString:@"B"])
                                 {
                                     
                                     //                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     
                                     for (CBService *service in peripheralP.services)
                                     {
                                         if (service.characteristics != nil) {
                                             for (CBCharacteristic *characteristic in service.characteristics) {
                                                 
                                                 [peripheralP setNotifyValue:NO forCharacteristic:characteristic];
                                                 
                                             }
                                         }
                                     }
                                     
                                     NSLog(@"Peripheral Disconnecting %@ ",ph);
                                     
                                     [self.centralManager cancelPeripheralConnection:ph];
                                     [self handleTransmitThreadsOnDisconnectWithPeripheral:ph];
                                     //                                 [self.connectedDevices removeObject:obj];
                                     
                                     DLog(@"Disconnect peripheral for duplicate packet %@ packet %@",peripheralP,d);
                                     
                                     // if exist in the database
                                     // remove the reference
                                     //break the loop
                                     //                             });
                                     *stop  = YES;
                                 }
                             }
                             return ;
                         }
                     }];
                     return;
                 }
                 else if (value ==2)
                 {
                     // forward the message
                     
                     //                 if ([_connectedDevices count] ==1) {
                     //                     return;
                     //                 }
                     
                     DLog(@"pckData __*%@",receive);
                     DLog(@"peripheral __* %@",peripheralP);
                     DLog(@"characteristic __*%@",characteristic);
                     DLog(@"Data to forward is %@",[characteristic value]);
                     //    NSLog(@"Connected Centrals are %@",_connectedDevices);
                     
                     DLog(@"BH didupdatevalue forward the message");
                     
                     DLog(@"Before Lock for thread 1 \n");
                     pthread_mutex_lock(&mutexForThread1);
                     DLog(@"After Lock for thread 1 \n");
                     
                     if (_transmitQueue1)
                     {
                         if (![[_transmitQueue1 objectForKey:Peripheral_Ref] isEqual:peripheralP])
                         {
                             [[self.transmitQueue1 objectForKey:DATA] addObject:[d mutableCopy]];
                             
                             pthread_mutex_unlock(&mutexForThread1);
                             DLog(@"Un Lock for thread 1 place 1 \n");
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread1);
                             DLog(@"Un Lock for thread 1 place 2 \n");
                         }
                     }
                     else
                     {
                         pthread_mutex_unlock(&mutexForThread1);
                         DLog(@"Un Lock for thread 1 place 1 \n");
                     }
                     
                     
                     DLog(@"Lock for thread 2 place 1 \n");
                     
                     pthread_mutex_lock(&mutexForThread2);
                     
                     if (_transmitQueue2) {
                         
                         if (![[_transmitQueue2 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                             
                             [[self.transmitQueue2 objectForKey:DATA] addObject:[d mutableCopy]];
                             pthread_mutex_unlock(&mutexForThread2);
                             DLog(@"Un Lock for thread 2 place 1 \n");
                             
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread2);
                             DLog(@"Un Lock for thread 2 place 1 \n");
                         }
                     }else
                     {
                         pthread_mutex_unlock(&mutexForThread2);
                         DLog(@"Un Lock for thread 2 place 1 \n");
                     }
                     
                     DLog(@"Lock for thread 3 place 1 \n");
                     
                     pthread_mutex_lock(&mutexForThread3);
                     
                     if (_transmitQueue3) {
                         
                         if (![[_transmitQueue3 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                             
                             [[self.transmitQueue3 objectForKey:DATA] addObject:[d mutableCopy]];
                             pthread_mutex_unlock(&mutexForThread3);
                             DLog(@"Un Lock for thread 3 place 1 \n");
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread3);
                             DLog(@"Un Lock for thread 3 place 1 \n");
                         }
                     }else
                     {
                         pthread_mutex_unlock(&mutexForThread3);
                         DLog(@"Un Lock for thread 3 place 1 \n");
                     }
                     
                     
                     DLog(@"Done with lock and unlock");
                     
                     return;
                 }
                 else if (value == 3)
                 {
                     DLog(@"BH didupdatevalue EOM");
                     
                     
                     DLog(@"Before Lock for thread 1 \n");
                     pthread_mutex_lock(&mutexForThread1);
                     DLog(@"After Lock for thread 1 \n");
                     
                     if (_transmitQueue1)
                     {
                         if (![[_transmitQueue1 objectForKey:Peripheral_Ref] isEqual:peripheralP])
                         {
                             [[self.transmitQueue1 objectForKey:DATA] addObject:[d mutableCopy]];
                             
                             pthread_mutex_unlock(&mutexForThread1);
                             DLog(@"Un Lock for thread 1 place 1 \n");
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread1);
                             DLog(@"Un Lock for thread 1 place 2 \n");
                         }
                     }
                     else
                     {
                         pthread_mutex_unlock(&mutexForThread1);
                         DLog(@"Un Lock for thread 1 place 1 \n");
                     }
                     
                     
                     DLog(@"Lock for thread 2 place 1 \n");
                     
                     pthread_mutex_lock(&mutexForThread2);
                     
                     if (_transmitQueue2) {
                         
                         if (![[_transmitQueue2 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                             
                             [[self.transmitQueue2 objectForKey:DATA] addObject:[d mutableCopy]];
                             pthread_mutex_unlock(&mutexForThread2);
                             DLog(@"Un Lock for thread 2 place 1 \n");
                             
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread2);
                             DLog(@"Un Lock for thread 2 place 1 \n");
                         }
                     }else
                     {
                         pthread_mutex_unlock(&mutexForThread2);
                         DLog(@"Un Lock for thread 2 place 1 \n");
                     }
                     
                     DLog(@"Lock for thread 3 place 1 \n");
                     
                     pthread_mutex_lock(&mutexForThread3);
                     
                     if (_transmitQueue3) {
                         
                         if (![[_transmitQueue3 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                             
                             [[self.transmitQueue3 objectForKey:DATA] addObject:[d mutableCopy]];
                             pthread_mutex_unlock(&mutexForThread3);
                             DLog(@"Un Lock for thread 3 place 1 \n");
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread3);
                             DLog(@"Un Lock for thread 3 place 1 \n");
                         }
                     }else
                     {
                         pthread_mutex_unlock(&mutexForThread3);
                         DLog(@"Un Lock for thread 3 place 1 \n");
                     }
                     
                     
                     DLog(@"Done with lock and unlock");
                     // success message
                     if(_delegate && [_delegate respondsToSelector:@selector(didRecieveData:from:fromCentral:forCharectorStic:)]) {
                         DLog(@"peripheral __* %@",peripheralP);
                         DLog(@"characteristic __*%@",characteristic);
                         
                         [_delegate didRecieveData:receive from:uuid fromPeripheral:ph forCharectorStic:characteristic];
                     }
                 }
                 else if (value ==4)
                 {
                     DLog(@"BH Discard Packet as not a Last packet");
                     // just return
                     // no need to do anything
                 }
                 else if (value ==5)
                 {
                     DLog(@"BH Forwarding Bosss");
                     // just return
                     
                     pthread_mutex_lock(&mutexForThread1);
                     
                     if (_transmitQueue1)
                     {
                         if (![[_transmitQueue1 objectForKey:Peripheral_Ref] isEqual:peripheralP])
                         {
                             [[self.transmitQueue1 objectForKey:DATA] addObject:[d mutableCopy]];
                             pthread_mutex_unlock(&mutexForThread1);
                             
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread1);
                         }
                     }
                     else
                         pthread_mutex_unlock(&mutexForThread1);
                     
                     
                     pthread_mutex_lock(&mutexForThread2);
                     
                     if (_transmitQueue2) {
                         
                         if (![[_transmitQueue2 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                             
                             [[self.transmitQueue2 objectForKey:DATA] addObject:[d mutableCopy]];
                             pthread_mutex_unlock(&mutexForThread2);
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread2);
                         }
                     }else
                         pthread_mutex_unlock(&mutexForThread2);
                     
                     pthread_mutex_lock(&mutexForThread3);
                     
                     if (_transmitQueue3) {
                         
                         if (![[_transmitQueue3 objectForKey:Peripheral_Ref] isEqual:peripheralP]) {
                             
                             [[self.transmitQueue3 objectForKey:DATA] addObject:[d mutableCopy]];
                             pthread_mutex_unlock(&mutexForThread3);
                         }else
                         {
                             pthread_mutex_unlock(&mutexForThread3);
                         }
                     }else
                     {
                         pthread_mutex_unlock(&mutexForThread3);
                     }
                 }
             }];
        }
    }];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"BT SERVER DOWN");
    
    if (error) {
        NSLog(@"Error!!!! didWriteValueForCharacteristic in cenral manager %@",error.localizedDescription);
        return;
    }
}

- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral is %@",peripheral);
    DLog(@"Method is called If peripheral is ready ++ %@",peripheral);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UPDATE_UUID]] || [characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] ||[characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_SONAR_UUID]]) {
        // Notification has started
        if (characteristic.isNotifying) {
            DLog(@"Notification began on %@", characteristic);
        }
        // Notification has stopped
        else {
            if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
                // so disconnect from the peripheral
                DLog(@"Notification stopped on %@.  Disconnecting", characteristic);
                NSLog(@"Peripheral Disconnecting %@ ",peripheral);
                [self.centralManager cancelPeripheralConnection:peripheral];
                [self handleTransmitThreadsOnDisconnectWithPeripheral:peripheral];
                
                for (CBService *service in peripheral.services)
                {
                    if (service.characteristics != nil) {
                        for (CBCharacteristic *characteristic in service.characteristics) {
                            
                            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - Private methods

- (void)checkQueue
{
    //    _isSending = NO;
    //    _dataToSend = nil;
    [self.messageSendingQueue addOperationWithBlock:^{
        
        if(_isSending) return;
        if (_dataToSend) return;
        if (_shD) {
            NSLog(@"Stop sending");
            [self updateIntermediatProgress:YES];
            [self sendPacket];
            return;
        }
        NSObject *data = [[BLEManager sharedManager] nextDataForCentral];
        if ([data isKindOfClass:[ShoutDataSender class]]) {
            _dataToSend = nil;
            _dataToSend = (ShoutDataSender*)data;
            if(_dataToSend){
                self.connectedInProcessPeripherals = [NSMutableArray arrayWithArray:self.connectedDevices];
                [self send];
            }
        }
        else if([data isKindOfClass:[ShoutDataReceiver class]]){
            _shD = (ShoutDataReceiver*)data;
            if(_shD){
                [self updateIntermediatProgress:YES];
                self.connectedInProcessPeripherals = [NSMutableArray arrayWithArray:self.connectedDevices];
                //  [self sendPacket];
                if ([[BLEManager sharedManager].highPriorityqueue count]>1) {
                    DLog(@"send pls");
                    [self sendPacket];
                    [self checkQueue];
                }else
                {
                    DLog(@"do not send higher queue is %@",[BLEManager sharedManager].highPriorityqueue);
                    
                    [self sendPacket];
                }
            }
        }
    }];
}

- (void)updateIntermediatProgress:(BOOL)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateProgressShout object:[NSNumber numberWithBool:status] userInfo:nil];
    });
}

- (void)sendPacket{
    
    //LHRU_MESH :  first two line Change done for testing, it is not included in actual code.
    _isSending = NO;
    _shD = nil;
    _dataToSend = nil;
}

-(void)getNOtification
{
    if(self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
    DevicePresencePacketInfo *shredIns = [DevicePresencePacketInfo sharedInstance];
    NSData *dddd = shredIns.mySendingData;
        
    pthread_mutex_lock(&mutexForThread1);
    
    if(self.transmitQueue1)
    {
        [[self.transmitQueue1 objectForKey:DATA] addObject:dddd];
        pthread_mutex_unlock(&mutexForThread1);
    }
    else
    {
        pthread_mutex_unlock(&mutexForThread1);
    }
    
    pthread_mutex_lock(&mutexForThread2);
    if(self.transmitQueue2)
    {
        [[self.transmitQueue2 objectForKey:DATA] addObject:dddd];
        pthread_mutex_unlock(&mutexForThread2);
    }else
    {
        pthread_mutex_unlock(&mutexForThread2);
    }
    
    pthread_mutex_lock(&mutexForThread3);
    
    if(self.transmitQueue3)
    {
        [[self.transmitQueue3 objectForKey:DATA] addObject:dddd];
        pthread_mutex_unlock(&mutexForThread3);
    }else
    {
        pthread_mutex_unlock(&mutexForThread3);
    }
        
        [self isEnableRelayFunctionalityOfForBukiBox:dddd];
}
    

    
}


-(void)send
{
    if(!self.connectedInProcessPeripherals.count) {
        _isSending = NO;
        _dataToSend = nil;
        return;
    }
    
    // Added Check To handle the crash
    if (_dataToSend.shoutData == nil) {
        return;
    }
    
    _isSending = YES;
    
    // Show initial state
    // Work out how big it should be
    NSInteger amountToSend = _dataToSend.shoutData.length;
    
    BOOL isFirstPacket      = NO;
    int frageMentOfPacket  = _dataToSend.fragmentNO+k_ReduceFragment_No;
    
    if (amountToSend == _dataToSend.totalShoutLength) {
        isFirstPacket     = YES;
        amountToSend = dynamicMTUSize-BOM_Length-KSPCL_Length_Schdule_ID_Length;
    }
    else if(amountToSend > dynamicMTUSize)
    {
        if (amountToSend+(dynamicMTUSize-BOM_Length) == _dataToSend.totalShoutLength) {
            
            isFirstPacket   = NO;
            amountToSend = dynamicMTUSize;
        }
        else
        {
            isFirstPacket   = NO;
            amountToSend = dynamicMTUSize;
        }
    }
    else
    {
        isFirstPacket   = NO;
        amountToSend = _dataToSend.shoutData.length;
    }
    
    int spcl = _dataToSend.typeOfMsgSpecialByte;
    NSData *specialCh =  [NSData dataWithBytes: &spcl length:1];
    
    // Copy out the data we want
    
    NSMutableData *dataToSend   =[[NSMutableData alloc] init];
    
    if (_dataToSend==nil) {
        return;
    }
    
    NSData *chunk = [NSData dataWithBytes:_dataToSend.shoutData.bytes length:amountToSend];
    
    if (isFirstPacket)
    {
        [dataToSend appendData:BOMData()];
        NSString *str = @"000";
        [dataToSend appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [dataToSend appendData:[AppManager dataFromHexString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID] ]];
    DLog(@"Shout ID %@",_dataToSend.shId);
    
    [dataToSend appendData:[AppManager dataFromHexString:[AppManager ConvertNumberTOHexString:[NSString stringWithFormat:@"%@",_dataToSend.shId]]]];
    
    DLog(@"fragment byets %d",frageMentOfPacket);
    NSData *fragmentBytes  = [AppManager dataFromHexString:[AppManager ConvertNumberTOHexString:[NSString stringWithFormat:@"%d",frageMentOfPacket]]];
    [dataToSend appendData:fragmentBytes];
    [dataToSend appendData:specialCh];
    [dataToSend appendData:chunk];
    
    pthread_mutex_lock(&mutexForThread1);
    
    if(self.transmitQueue1)
    {
        [[self.transmitQueue1 objectForKey:DATA] addObject:dataToSend];
        pthread_mutex_unlock(&mutexForThread1);
    }
    else
    {
        pthread_mutex_unlock(&mutexForThread1);
    }
    
    pthread_mutex_lock(&mutexForThread2);
    if(self.transmitQueue2)
    {
        [[self.transmitQueue2 objectForKey:DATA] addObject:dataToSend];
        pthread_mutex_unlock(&mutexForThread2);
    }else
    {
        pthread_mutex_unlock(&mutexForThread2);
    }
    
    pthread_mutex_lock(&mutexForThread3);
    
    if(self.transmitQueue3)
    {
        [[self.transmitQueue3 objectForKey:DATA] addObject:dataToSend];
        pthread_mutex_unlock(&mutexForThread3);
    }else
    {
        pthread_mutex_unlock(&mutexForThread3);
    }
    
    BOOL didSend = YES;
    
    //        // If it didn't work, drop out and wait for the callback
    if (didSend&&_dataToSend!=nil) {
        // update data to send next time.
        BOOL lastPacket = false;
        if (_dataToSend.shoutData.length <12) {
            amountToSend  = _dataToSend.shoutData.length;
            lastPacket = YES;
        }
        @try {
            _dataToSend.shoutData = [[NSData dataWithBytes:_dataToSend.shoutData.bytes + amountToSend length:_dataToSend.shoutData.length - amountToSend] mutableCopy];
            _dataToSend.fragmentNO = _dataToSend.fragmentNO+1;
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        if (lastPacket) {
            _dataToSend = nil;
            _dataToSend.fragmentNO = 0;
        }
        didSend = NO;
    }
    
    // Was it the last one?
    if (!_dataToSend.shoutData.length) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ShoutDataSender *shDS = [[ShoutDataSender alloc] init];
            shDS.totalShoutLength = 0;
            shDS.shId = _dataToSend.shId;
            shDS.type = _dataToSend.type;
            shDS.shoutData = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kShoutProgressUpdate object:shDS userInfo:nil];
        });
        _isSending = NO;
        //    i = 1;
        _dataToSend = nil;
        [self performSelectorInBackground:@selector(checkQueue) withObject:nil];
        return;
        //            break;
    }
    else {
        if (_dataToSend.totalShoutLength>=0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ShoutDataSender *shDS = [[ShoutDataSender alloc] init];
                @try
                {
                    if(_dataToSend.shoutData != nil){
                        shDS.totalShoutLength = _dataToSend.totalShoutLength;
                        shDS.shId = _dataToSend.shId;
                        shDS.type = _dataToSend.type;
                        shDS.shoutData = _dataToSend.shoutData;
                    }
                } @catch (NSException *exception) {
                    NSLog(@"error");
                    
                } @finally {
                    
                }
                // NSLog(@"shout data sender ----- %@",shDS);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShoutProgressUpdate object:shDS userInfo:nil];
            });
        }
    }
    //    }
    //    while(didSend);
    
    [self sendMsg];
}

-(void)sendMsg
{
    if(_dataToSend)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self send];
            
        });
    }
    else if (_shD)  {
        [self sendPacket];
    }
}

-(void)checkMyQueue{
    dispatch_async(self.centralQueue, ^{
        
        NSObject *data = [[BLEManager sharedManager] myNextDataForCentral];
        DLog(@"checkMyQueue %@",data);
        if ([data isKindOfClass:[ShoutDataSender class]]) {
            _dataToSend = nil;
            _dataToSend = (ShoutDataSender*)data;
            if(_dataToSend){
                self.connectedInProcessPeripherals = [NSMutableArray arrayWithArray:self.connectedDevices];
                [self send];
            }
        }
        
        else if([data isKindOfClass:[ShoutDataReceiver class]]){
            _shD = (ShoutDataReceiver*)data;
            if(_shD){
                [self updateIntermediatProgress:YES];
                self.connectedInProcessPeripherals = [NSMutableArray arrayWithArray:self.connectedDevices];
                if ([[BLEManager sharedManager].highPriorityqueue count]>1) {
                    DLog(@"send now pls");
                    [self checkQueue];
                }else
                {
                    DLog(@"do not send higher queue is %@",[BLEManager sharedManager].highPriorityqueue);
                    
                    [self sendPacket];
                }
            }
        }
    });
}

- (NSArray*)getValidCentral:(NSString*)currentId{
    // There's data left, so send until the callback fails, or we're done.
    NSMutableArray *arr = [NSMutableArray new];
    
    NSMutableArray *allConnectedCentrals = nil;
    allConnectedCentrals = [NSMutableArray arrayWithArray:self.connectedInProcessPeripherals];
    
    NSArray *uuids = [[[BLEManager sharedManager] reciever] objectForKey:currentId];
    
    if(!uuids || uuids.count == 0) {
        [arr addObjectsFromArray:allConnectedCentrals];
    } else {
        
        [allConnectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CBPeripheral *cen = [obj objectForKey:Peripheral_Ref];
            NSString *uuid1 = [cen.identifier UUIDString];
            
            BOOL found = NO;
            for(NSString *uuid in uuids) {
                if ([uuid isEqualToString:uuid1]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [arr addObject:cen];
            }
        }];
    }
    return arr;
}

-(void)sendData:(int)indexV
{
    NSString *str ;
    NSData *dataToSend;
    if (indexV == 1) {
        str = [[_queue1 allKeys] objectAtIndex:0];
        dataToSend = [_queue1 objectForKey:str];
    }else  if (indexV == 2) {
        str = [[_queue2 allKeys] objectAtIndex:0];
        dataToSend = [_queue2 objectForKey:str];
    }else if (indexV == 3) {
        str = [[_queue3 allKeys] objectAtIndex:0];
        dataToSend = [_queue3 objectForKey:str];
    }else if (indexV == 4) {
        str = [[_queue4 allKeys] objectAtIndex:0];
        dataToSend = [_queue4 objectForKey:str];
    }
    
    
    //    NSData *dataToSend  = [[_queue1 objectForKey:str] bytes];
    //    int i=0;
    //    NSData *chunk = [NSData dataWithBytes:[[_queue1 objectForKey:str] bytes] length:20];
    
    
    NSMutableArray *arra  = [[NSMutableArray alloc] init];
    NSUInteger length = [dataToSend length]; // total size of data
    NSUInteger chunkSize = 20; // divide data into 10 mb
    NSUInteger offset = 0;
    do {
        // get the chunk location
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        // get the chunk
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[dataToSend bytes] + offset length:thisChunkSize freeWhenDone:NO];
        
        
        if (_centralManager.state == CBCentralManagerStatePoweredOn) {
            //didSend = [self.peripheralManager updateValue:chunk forCharacteristic:_transferCharacteristicForShouts onSubscribedCentrals:nil];
            
            [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CBPeripheral *ph  = [obj objectForKey:Peripheral_Ref];
                
                if (![ph.identifier.UUIDString isEqualToString:str]) {
                    
                    
                    
                    for (CBService *service in ph.services) {
                        if (service.characteristics != nil) {
                            for (CBCharacteristic *characteristic in service.characteristics) {
                                
                                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] )
                                {
                                    [ph writeValue:chunk forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                                    sleep(100);
                                }
                            }
                        }
                    }
                }
            }];
        }
        
        if (indexV == 1) {
            [_queue1 removeAllObjects];
        }else  if (indexV == 2) {
            [_queue2 removeAllObjects];
        }else if (indexV == 3) {
            [_queue3 removeAllObjects];
        }else if (indexV == 4) {
            [_queue4 removeAllObjects];
        }
        [arra addObject:chunk];
        // update the offset
        offset += thisChunkSize;
    } while (offset < length);
}

-(void)getAPIToKnowAboutFirmwareVersionOnCloud:(NSString *)url sendingDic:(NSDictionary *)dataDictionary file:(NSString *)dataFilePath completion:(void(^) (NSMutableDictionary * dataDic,  NSError *error))responseDic
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url1 = [NSURL URLWithString:url];
        NSError *error;
        
        NSData *jsonData;
        if (dataDictionary)
            jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:kNilOptions error:&error];
        
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
        [req setURL:url1];
        [req setHTTPMethod:@"POST"];
        
        [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        [req setHTTPBody:jsonData];
        [req setTimeoutInterval:30];
        
        NSError *error1;
        NSURLResponse *response;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error1];
        
        if (!error && response)
        {
            //Receiving String Data from server
            // NSString *result = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            
            //Converting the string data to mutable dictionary and returning it into the block
            responseDic([NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil],error);
            
            // responseDic([self formatWSJSON:result],error);
        }
        else
        {
            DLog(@"Error is %@",error);
            responseDic(nil,error);
        }
    });
}

-(void)saveData:(NSString *)uuid dataV:(NSData *)data
{
    if ([[_dataHavingValue allKeys] containsObject:uuid])
    {
        NSMutableData *dataV  =   [[_dataHavingValue objectForKey:uuid] mutableCopy];
        [dataV appendData:[data mutableCopy]];
        [_dataHavingValue removeAllObjects];
        [_dataHavingValue setObject:dataV forKey:uuid];
        DLog(@"Data Value is %@",_dataHavingValue);
    }
    else
    {
        [_dataHavingValue setObject:[data mutableCopy] forKey:uuid];
        DLog(@"Data Value is %@",_dataHavingValue);
    }
}

-(void)methodToDisconnectDuplicateConnection:(NSMutableArray *)value
{
    DLog(@"Count of Array is %lu and Data values are : %@",(unsigned long)value.count,value);
    // do action if count is greater than 1 else neglect
    if (value.count>1)
    {
        // enumerate the array having duplicate connections
        [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj objectForKey:Peripheral_Ref] !=nil) {
                [[obj objectForKey:Peripheral_Ref] readRSSI];
            }
        }];
    }else
        return;
    
    __block NSMutableArray * array=[[NSMutableArray alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // enumerate the value to get the latest rssi value of peripheral
        [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CBPeripheral *ph = [obj objectForKey:Peripheral_Ref];
            // add in array
            if (ph.RSSI) {
                [array addObject:ph.RSSI];
            }
        }];
        
        
        // finding the greater value in All RSSI values
        DLog(@"Array:%@",array);
        int maxValue= -125;
        int Index = -1;
        for (NSString * strMaxi in array) {
            int currentValue=[strMaxi intValue];
            if (currentValue > maxValue) {
                maxValue=currentValue;
                Index = Index+1;
                DLog(@"Max value%d",maxValue);
                DLog(@" Index %d",Index);
            }
        }
        
        // now enumerate the value (duplicate entries array)
        [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stoploop) {
            // if index is not the same as the index, peripheral having good strength value
            if (idx != Index) {
                
                // reference of the peripheral
                CBPeripheral *cbp = [obj objectForKey:Peripheral_Ref];
                [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([[obj objectForKey:Peripheral_Ref] isEqual:cbp]) {
                        
                        CBPeripheral *phh   =  [obj objectForKey:Peripheral_Ref];
                        //                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        for (CBService *service in phh.services)
                        {
                            if (service.characteristics != nil) {
                                for (CBCharacteristic *characteristic in service.characteristics)
                                {
                                    [phh setNotifyValue:NO forCharacteristic:characteristic];
                                }
                            }
                        }
                        
                        [_dicToNotAllowConnectionForSomeTime setObject:[AppManager timeStamp]  forKey:cbp.identifier];
                        
                        NSLog(@"Peripheral Disconnecting %@ ",cbp);
                        
                        [_centralManager cancelPeripheralConnection:cbp];
                        NSLog(@"Calling Forcely Disconnection to Peripheral %@",cbp);
                        [self handleTransmitThreadsOnDisconnectWithPeripheral:cbp];
                        [_connectedDevices removeObject:obj];
                        //      });
                        // disconnect only one at the time
                        *stop = YES;
                        return;
                    }
                }];
                
                [[BLEManager sharedManager] invalidateTimer];
                
                [[BLEManager sharedManager].centralM stopScanning:^(BOOL success) {
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [[BLEManager sharedManager] startScanning];
                        
                    });
                }];
                *stoploop = YES;
                return;
            }
        }];
        return;
    });
}

// @method to get the current rssi value of the peripheral
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    // enumrate the device list to replace with the current rssi value
    [_connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // to check the on what index that peripheral exist
        if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheral])
        {
            NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,Peripheral_Ref,[obj objectForKey:Ref_ID],Ref_ID,[obj objectForKey:Adv_Data],Adv_Data,nil];
            // replace the object
            if (_connectedDevices.count>idx)
            {
                [_connectedDevices replaceObjectAtIndex:idx withObject:dataDic];
            }
        }
    }];
}

#pragma mark - TRANSMIT METHODS

- (void) clearTransmitQueues {
    DLog (@" in Clear Transmit Queues");
    [self.transmitQueueArray removeAllObjects];
    if (_thread1) {
        DLog(@" clear thread 1");
        [_thread1 cancelAllOperations];
        [_thread1 setSuspended:YES];
        _thread1 = nil;
    }
    if (_thread2) {
        DLog(@" clear thread 2");
        [_thread2 cancelAllOperations];
        [_thread2 setSuspended:YES];
        _thread2 = nil;
    }
    if (_thread3) {
        DLog(@" clear thread 3");
        [_thread3 cancelAllOperations];
        [_thread3 setSuspended:YES];
        _thread3 = nil;
    }
    if (_thread4) {
        DLog(@" clear thread 4");
        [_thread4 cancelAllOperations];
        [_thread4 setSuspended:YES];
        _thread4 = nil;
    }
    
}

-(BOOL)isEnableRelayFunctionalityOfForBukiBox:(NSData *)value
{
    BOOL isEnable =false;
    NSString *bom;
    if (value.length>3)
    {
        bom = [[NSString alloc] initWithData:[value subdataWithRange:NSMakeRange(0, 3)] encoding:NSUTF8StringEncoding];
    }
    int initialSTrtingByteNo = 0;
    NSString *stringValue;
    NSString *stringValueF;

    BOOL isFirstPacket = NO;
    if ([bom isEqualToString:BOM])
    {
        initialSTrtingByteNo = BOM_Length+KSPCL_Length_Schdule_ID_Length;
        if (value.length>14) {
            
            stringValue =  [[[NSString stringWithFormat:@"%@",[value subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH,1)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
            isFirstPacket = YES;
            
        }
    }
    else
    {
        if (value.length>8)
        {
            stringValue =  [[[NSString stringWithFormat:@"%@",[value subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH,1)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            stringValueF =  [[[NSString stringWithFormat:@"%@",[value subdataWithRange:NSMakeRange(initialSTrtingByteNo,2)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
        }
    }
    
    if (stringValue == nil) {
        return isEnable = NO;
    }
    int specialValueForText  = [[NSString stringWithFormat:@"%d",[AppManager convertIntFromString:stringValue]] intValue];
    
    // if value is the same for text so enable it n send this value
    if (specialValueForText == 5 || [stringValueF isEqualToString:@"4450"] || specialValueForText == 1) {
        
        isEnable = YES;
    }else
        isEnable   = NO;
    
    return isEnable;
}

- (void) handleTransmitThreadsOnConnectWithPeripheral :(CBPeripheral *) peripheral {
    
    DLog(@" in handleTransmitThreadsOnConnectWithPeripheral %@",self.transmitQueueArray);
    
    if (self.transmitQueue1 || self.transmitQueue2 ||self.transmitQueue3) {
        
        // Matching item found
        DLog(@" item Found");
        
        if (!_thread1)
        {
            // Thread 1 would work to traverse this object
            DLog(@" Thread 1 available");
            [self.transmitQueue1 setObject:@"com.queue.thread1" forKey:THREAD_NAME];
            
            _thread1 = [[NSOperationQueue alloc] init];
            __block NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
                
                DLog(@" inside thread 1");
                
                while (true) {
                    // DLog(@" inside thread 1 while 1");
                    
                    if (!blockOp.isCancelled) {
                        
                        if (self.transmitQueue1) {
                            
                            while ([[self.transmitQueue1 objectForKey:DATA] count] > 0)
                            {
                                pthread_mutex_lock(&mutexForThread1);
                                DLog(@" inside thread 1 while 2 == %lu",[[self.transmitQueue1 objectForKey:DATA] count]);
                                
                               // NSLog(@"Peripheral Device acceptance value for Thread 1 %@ ++ Number of Packets left %lu",[NSNumber numberWithBool:peripheral.canSendWriteWithoutResponse],[[self.transmitQueue1 objectForKey:DATA] count]);

                                if (!blockOp.isCancelled) {
                                   // if((peripheral.services == nil || [peripheral.services count]==0) && peripheral.canSendWriteWithoutResponse) {
                                        if((peripheral.services == nil || [peripheral.services count]==0)) {

                                        NSLog(@"Services Are nil");
                                        pthread_mutex_unlock(&mutexForThread1);
                                        usleep(kTimeIntervalBetweenPackets);
                                        continue;
                                    }
                                    
                                    BOOL isGotRightOne = NO;
                                    for (CBService *service in peripheral.services) {
                                        
                                        if ([service.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]) {
                                            
                                            isGotRightOne  = YES;
                                            break;
                                        }
                                    }
                                    
                                    if (!isGotRightOne) {
                                        
                                        NSLog(@" Lock Inside thread 1");
                                        pthread_mutex_unlock(&mutexForThread1);
                                        //continue;
                                    }
                                    
                                    DLog(@"Services are not nil");
                                    // Continue sending data
                                    for (CBService *service in peripheral.services) {
                                        
                                        if (service !=nil)
                                        {
                                            if (service.characteristics != nil) {
                                                
                                                for (CBCharacteristic *characteristic1 in service.characteristics)
                                                {
                                                    DLog(@"Services charcterstics are not nil");
                                                    
                                                    if([characteristic1.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] )
                                                    {
                                                        DLog(@"Services Charcterstics are right one");
                                                        
                                                        if(self.transmitQueue1) {
                                                            
                                                            NSArray *arrayOfThread1 = [self.transmitQueue1 objectForKey:DATA];
                                                            
                                                            if (arrayOfThread1.count==0) {
                                                                return;
                                                            }
                                                            
                                                            id dataToSendCopy = [arrayOfThread1 objectAtIndex:0] ;
                                                            id dataToSend = [dataToSendCopy copy];
                                                            NSString *targetPeripheralType = [self.transmitQueue1 objectForKey:Adv_Data];
                                                            
                                                            [self.bleOperationThread addOperationWithBlock:^{
                                                                
                                                                [self isEnableRelayFunctionalityOfForBukiBox:dataToSend];

                                                                if (dataToSend !=nil) {
                                                                    // Background work
                                                                    if ([targetPeripheralType isEqualToString:@""])
                                                                    {
                                                                        // pthread_mutex_lock(&mutexForWrite);
                                                                        DLog(@"Message forwarded to queue 1  WIth iPhone %@ with packet %@ ",peripheral,dataToSend);
                                                                        [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithoutResponse];
                                                                        // pthread_mutex_unlock(&mutexForWrite);
                                                                    }
                                                                    else if ([[targetPeripheralType substringWithRange:NSMakeRange(0, 1) ] isEqualToString:@"B"]) {
                                                                        if(_isWriteDataOnBukiBox)
                                                                        {
                                                                            if ([self isEnableRelayFunctionalityOfForBukiBox:dataToSend])
                                                                            {
                                                                                DLog(@"Do forward to data to Buki box as it was text");
                                                                                [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithResponse];
                                                                            }
                                                                        }
                                                                    }else
                                                                    {
                                                                        // pthread_mutex_lock(&mutexForWrite);
                                                                        [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithoutResponse];
                                                                        DLog(@"Message forwarded to queue 1 %@ with packet %@ ",peripheral,dataToSend);
                                                                        // pthread_mutex_unlock(&mutexForWrite);
                                                                    }
                                                                }
                                                                usleep(kTimeIntervalBetweenPackets);
                                                            }];
                                                            // Flush the data
                                                            
                                                            if ([[self.transmitQueue1 objectForKey:DATA] count] >0)
                                                            {
                                                                DLog(@"Remove queue 1  %lu",[[self.transmitQueue1 objectForKey:DATA] count]);
                                                                [[self.transmitQueue1 objectForKey:DATA] removeObjectAtIndex:0];
                                                            }
                                                            
                                                            DLog(@" Unlock Inside thread 1");
                                                            
                                                            pthread_mutex_unlock(&mutexForThread1);
                                                            
                                                        } else {
                                                            pthread_mutex_unlock(&mutexForThread1);
                                                            DLog(@"Out of bounds 5");
                                                        }
                                                        break ;
                                                    }
                                                }
                                                
                                                if (!isGotRightOne) {
                                                    
                                                    NSLog(@" UN Lock Inside thread 1");
                                                    pthread_mutex_unlock(&mutexForThread1);
                                                    
                                                }
                                            }
                                            else
                                            {
                                                pthread_mutex_unlock(&mutexForThread1);
                                                usleep(kTimeIntervalBetweenPackets);
                                                continue;
                                            }
                                        } else {
                                            NSLog(@"No service found in thread 1");
                                            pthread_mutex_unlock(&mutexForThread1);
                                            usleep(kTimeIntervalBetweenPackets);
                                            continue;
                                        }
                                        
                                    }
                                    usleep(kTimeIntervalBetweenPackets);
                                } else {
                                    pthread_mutex_unlock(&mutexForThread1);
                                    DLog(@" return 1");
                                    return ;
                                }
                            }
                            pthread_mutex_unlock(&mutexForThread1);
                        }
                        else{
                            pthread_mutex_unlock(&mutexForThread1);
                        }
                        usleep(50000);
                    } else {
                        pthread_mutex_unlock(&mutexForThread1);
                        DLog(@" return 2");
                        return ;
                    }
                }
            }];
            
            [_thread1 addOperation:blockOp];
            
        }
        else if (!_thread2) {
            DLog(@" Thread 2 available");
            [self.transmitQueue2 setObject:@"com.queue.thread2" forKey:THREAD_NAME];
            // Thread 2 would work to traverse this object
            _thread2 = [[NSOperationQueue alloc] init];
            __block NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
                
                //    NSUInteger thread2ObjectIndex = objectIndex;
                
                DLog(@" inside thread 2");
                
                while (true) {
                    //  DLog(@" inside thread 2 while 1");
                    
                    if (!blockOp.isCancelled) {
                        
                        if (self.transmitQueue2) {
                            
                            while ([[self.transmitQueue2 objectForKey:DATA] count] > 0) {
                                pthread_mutex_lock(&mutexForThread2);
                                
                                // Continue sending data
                                DLog(@" inside thread 2 while 2 == %lu",[[self.transmitQueue2 objectForKey:DATA] count]);
                                
                               // NSLog(@"Peripheral Device acceptance value for Thread 2 %@ ++ Number of Packets left %lu",[NSNumber numberWithBool:peripheral.canSendWriteWithoutResponse],[[self.transmitQueue2 objectForKey:DATA] count]);
                                
                                if (!blockOp.isCancelled)
                                {
                                    if((peripheral.services == nil || [peripheral.services count]==0))
                                    {
                                        NSLog(@"Services Are nil");
                                        pthread_mutex_unlock(&mutexForThread2);
                                        usleep(kTimeIntervalBetweenPackets);
                                        continue;
                                    }
                                    
                                    DLog(@"Services are not nil");
                                    BOOL isGotRightOne = NO;
                                    for (CBService *service in peripheral.services) {
                                        
                                        if ([service.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]) {
                                            
                                            isGotRightOne  = YES;
                                            break;
                                        }
                                    }
                                    
                                    if (!isGotRightOne) {
                                        
                                        NSLog(@" Lock Inside thread 2");
                                        pthread_mutex_unlock(&mutexForThread2);
                                        //continue;
                                    }
                                    
                                    
                                    for (CBService *service in peripheral.services)
                                    {
                                        if (service != nil) {
                                            
                                            DLog(@"Services are not nil");
                                            
                                            if (service.characteristics != nil)
                                            {
                                                DLog(@"Services Charcterstics are not nil");
                                                
                                                for (CBCharacteristic *characteristic1 in service.characteristics) {
                                                    
                                                    if([characteristic1.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] )
                                                    {
                                                        DLog(@"Services Charcterstics are right one");
                                                        
                                                        if(self.transmitQueue2) {
                                                            
                                                            NSArray *arrayOfThread2 = [self.transmitQueue2 objectForKey:DATA];
                                                            
                                                            if (arrayOfThread2.count==0) {
                                                                return;
                                                            }
                                                            
                                                            id dataToSendCopy = [arrayOfThread2 objectAtIndex:0] ;
                                                            id dataToSend = [dataToSendCopy copy];
                                                            NSString *targetPeripheralType = [self.transmitQueue2 objectForKey:Adv_Data];
                                                            
                                                            // id dataToSend = [[[self.transmitQueue2 objectForKey:DATA] objectAtIndex:0] copy];
                                                            [self.bleOperationThread addOperationWithBlock:^{
                                                                
                                                                if (dataToSend !=nil) {
                                                                    if ([targetPeripheralType isEqualToString:@""])
                                                                    {
                                                                        // pthread_mutex_lock(&mutexForWrite);
                                                                        DLog(@"Message forwarded to queue 2 %@ with packet %@ ",peripheral,dataToSend);
                                                                        [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithoutResponse];
                                                                        // pthread_mutex_unlock(&mutexForWrite);
                                                                    }
                                                                    else if ([[targetPeripheralType substringWithRange:NSMakeRange(0, 1) ] isEqualToString:@"B"]) {
                                                                        if(_isWriteDataOnBukiBox)
                                                                        {
                                                                            DLog(@"Message forwarded to queue 2  WIth BUKI BOX %@ with packet %@ ",peripheral,dataToSend);
                                                                            if ([self isEnableRelayFunctionalityOfForBukiBox:dataToSend])
                                                                            {
                                                                                DLog(@"Do forward to data to Buki box as it was text");
                                                                                [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithResponse];
                                                                            }
                                                                        }
                                                                    }else
                                                                    {
                                                                        // pthread_mutex_lock(&mutexForWrite);
                                                                        [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithoutResponse];
                                                                        DLog(@"Message forwarded to queue 2 %@ with packet %@ ",peripheral,dataToSend);
                                                                        // pthread_mutex_unlock(&mutexForWrite);
                                                                    }
                                                                }
                                                                
                                                                usleep(kTimeIntervalBetweenPackets);
                                                                // Flush the data
                                                            }];
                                                            if ([[self.transmitQueue2 objectForKey:DATA] count] >0)
                                                            {
                                                                DLog(@"Remove queue 2  %lu",[[self.transmitQueue2 objectForKey:DATA] count]);
                                                                [[self.transmitQueue2 objectForKey:DATA] removeObjectAtIndex:0];
                                                            }
                                                            
                                                            pthread_mutex_unlock(&mutexForThread2);
                                                            
                                                        } else {
                                                            pthread_mutex_unlock(&mutexForThread2);
                                                            DLog(@"Out of bounds 6");
                                                        }
                                                        break;
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                pthread_mutex_unlock(&mutexForThread2);
                                                usleep(kTimeIntervalBetweenPackets);
                                                continue;
                                            }
                                        }
                                        else {
                                            NSLog(@"No service found in thread 2");
                                            pthread_mutex_unlock(&mutexForThread2);
                                            usleep(kTimeIntervalBetweenPackets);
                                            continue;
                                        }
                                    }
                                    usleep(kTimeIntervalBetweenPackets);
                                } else {
                                    pthread_mutex_unlock(&mutexForThread2);
                                    DLog(@" return 3");
                                    return ;
                                }
                            }
                            pthread_mutex_unlock(&mutexForThread2);
                        }else
                        {
                            pthread_mutex_unlock(&mutexForThread2);
                        }
                        usleep(50000);
                    } else {
                        pthread_mutex_unlock(&mutexForThread2);
                        DLog(@" return 4");
                        return ;
                    }
                }
                
            }];
            
            [_thread2 addOperation:blockOp];
            
        } else if (!_thread3) {
            DLog(@" Thread 3 available");
            [self.transmitQueue3 setObject:@"com.queue.thread3" forKey:THREAD_NAME];
            
            // Thread 3 would work to traverse this object
            _thread3 = [[NSOperationQueue alloc] init];
            __block NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
                
                //NSUInteger thread3ObjectIndex = objectIndex;
                
                DLog(@" inside thread 3");
                
                while (true) {
                    //   DLog(@" inside thread 3 while 1");
                    
                    if (!blockOp.isCancelled) {
                        
                        
                        if (self.transmitQueue3) {
                            while ([[self.transmitQueue3 objectForKey:DATA] count] > 0) {
                                // Continue sending data
                                pthread_mutex_lock(&mutexForThread3);
                                
                                DLog(@" inside thread 3 while 2 == %lu",[[self.transmitQueue3 objectForKey:DATA] count]);
                                
                               // NSLog(@"Peripheral Device acceptance value for Thread 3 %@ ++ Number of Packets left %lu",[NSNumber numberWithBool:peripheral.canSendWriteWithoutResponse],[[self.transmitQueue3 objectForKey:DATA] count]);

                                if (!blockOp.isCancelled)
                                {
//                                    if((peripheral.services == nil || [peripheral.services count]==0) && peripheral.canSendWriteWithoutResponse)
                                    if((peripheral.services == nil || [peripheral.services count]==0))
                                    {
                                        NSLog(@"Services Are nil");
                                        pthread_mutex_unlock(&mutexForThread3);
                                        usleep(kTimeIntervalBetweenPackets);
                                        continue;
                                    }
                                    
                                    BOOL isGotRightOne = NO;
                                    for (CBService *service in peripheral.services) {
                                        
                                        if ([service.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]) {
                                            
                                            isGotRightOne  = YES;
                                            break;
                                        }
                                    }
                                    
                                    if (!isGotRightOne) {
                                        
                                        NSLog(@" Lock Inside thread 3");
                                        pthread_mutex_unlock(&mutexForThread3);
                                        //continue;
                                    }
                                    
                                    DLog(@"Services are not nil");
                                    for (CBService *service in peripheral.services) {
                                        
                                        if (service != nil) {
                                            
                                            if (service.characteristics != nil) {
                                                
                                                DLog(@"Services  characterstics are not nil");
                                                
                                                
                                                for (CBCharacteristic *characteristic1 in service.characteristics) {
                                                    
                                                    if([characteristic1.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] )
                                                    {
                                                        DLog(@"Services Charcterstics are right one");
                                                        
                                                        if(self.transmitQueue3) {
                                                            DLog(@"Main queue data is %@", self.transmitQueueArray);
                                                            
                                                            // id dataToSend = [[[self.transmitQueue3 objectForKey:DATA] objectAtIndex:0] copy];
                                                            NSArray *arrayOfThread3 = [self.transmitQueue3 objectForKey:DATA];
                                                            
                                                            if (arrayOfThread3.count==0) {
                                                                return;
                                                            }
                                                            
                                                            id dataToSendCopy = [arrayOfThread3 objectAtIndex:0] ;
                                                            id dataToSend = [dataToSendCopy copy];
                                                            NSString *targetPeripheralType = [self.transmitQueue3 objectForKey:Adv_Data];
                                                            
                                                            [self.bleOperationThread addOperationWithBlock:^{
                                                                
                                                                if (dataToSend !=nil) {
                                                                    
                                                                    
                                                                    if ([targetPeripheralType isEqualToString:@""])
                                                                    {
                                                                        // pthread_mutex_lock(&mutexForWrite);
                                                                        DLog(@"Message forwarded to queue 1 %@ with packet %@ ",peripheral,dataToSend);
                                                                        [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithoutResponse];
                                                                        usleep(kTimeIntervalBetweenPackets);
                                                                        // pthread_mutex_unlock(&mutexForWrite);
                                                                    }
                                                                    else if ([[targetPeripheralType substringWithRange:NSMakeRange(0, 1) ] isEqualToString:@"B"]) {
                                                                        if(_isWriteDataOnBukiBox)
                                                                        {
                                                                            DLog(@"Message forwarded to queue 1  WIth BUKI BOX %@ with packet %@ ",peripheral,dataToSend);
                                                                            if ([self isEnableRelayFunctionalityOfForBukiBox:dataToSend])
                                                                            {
                                                                                DLog(@"Do forward to data to Buki box as it was text");
                                                                                [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithResponse];
                                                                            }
                                                                            usleep(kTimeIntervalBetweenPackets);
                                                                        }
                                                                    }else
                                                                    {
                                                                        // pthread_mutex_lock(&mutexForWrite);
                                                                        [peripheral writeValue:dataToSend forCharacteristic:characteristic1 type:CBCharacteristicWriteWithoutResponse];
                                                                        DLog(@"Message forwarded to queue 1 %@ with packet %@ ",peripheral,dataToSend);
                                                                        usleep(kTimeIntervalBetweenPackets);
                                                                        // pthread_mutex_unlock(&mutexForWrite);
                                                                    }
                                                                }
                                                            }];
                                                            if ([[self.transmitQueue3 objectForKey:DATA] count] >0)
                                                            {
                                                                DLog(@"Remove queue 3  %lu",[[self.transmitQueue3 objectForKey:DATA] count]);
                                                                [[self.transmitQueue3 objectForKey:DATA] removeObjectAtIndex:0];
                                                            }
                                                            
                                                            pthread_mutex_unlock(&mutexForThread3);
                                                            
                                                            
                                                        } else {
                                                            DLog(@"Out of bounds 7");
                                                            pthread_mutex_unlock(&mutexForThread3);
                                                        }
                                                        break;
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                pthread_mutex_unlock(&mutexForThread3);
                                                usleep(kTimeIntervalBetweenPackets);
                                                continue;
                                            }
                                        }
                                        else {
                                            NSLog(@"No service found in thread 3");
                                            pthread_mutex_unlock(&mutexForThread3);
                                            usleep(kTimeIntervalBetweenPackets);
                                            continue;
                                        }
                                    }
                                    usleep(kTimeIntervalBetweenPackets);
                                } else {
                                    pthread_mutex_unlock(&mutexForThread3);
                                    
                                    DLog(@" return 5");
                                    return ;
                                }
                            }
                            pthread_mutex_unlock(&mutexForThread3);
                        }
                        else
                        {
                            pthread_mutex_unlock(&mutexForThread3);
                        }
                        usleep(50000);
                    } else {
                        pthread_mutex_unlock(&mutexForThread3);
                        
                        DLog(@" return 6");
                        return ;
                    }
                }
                
            }];
            
            [_thread3 addOperation:blockOp];
        }
    }else {
        // No matching item found.
        DLog(@"No matching items found");
    }
}

- (void) handleTransmitThreadsOnDisconnectWithPeripheral : (CBPeripheral *) peripheral {
    
    NSLog(@" handleTransmitThreadsOnDisconnectWithPeripheral %@", self.transmitQueueArray);
    
    if (self.transmitQueue1 || self.transmitQueue2 ||self.transmitQueue3) {
        NSString *threadName;
        if([[self.transmitQueue1 objectForKey:Peripheral_Ref] isEqual:peripheral])
        {
            DLog(@"Peripheral Deleted Queue 1 %@",self.transmitQueue1);
            threadName = [self.transmitQueue1 objectForKey:THREAD_NAME];
        }
        else if([[self.transmitQueue2 objectForKey:Peripheral_Ref] isEqual:peripheral])
        {
            DLog(@"Peripheral Deleted Queue 2 %@",self.transmitQueue2);
            threadName = [self.transmitQueue2 objectForKey:THREAD_NAME];
        }
        else if([[self.transmitQueue3 objectForKey:Peripheral_Ref] isEqual:peripheral])
        {
            DLog(@"Peripheral Deleted Queue 3 %@",self.transmitQueue3);
            
            threadName = [self.transmitQueue3 objectForKey:THREAD_NAME];
        }
        //else if([[self.transmitQueue4 objectForKey:Peripheral_Ref] isEqual:peripheral])
        //    threadName = [self.transmitQueue4 objectForKey:THREAD_NAME];
        DLog(@" index found 1");
        
        if(threadName) {
            // NSString *threadName = [[self.transmitQueueArray objectAtIndex:objectIndex] objectForKey:THREAD_NAME];
            
            if ([threadName isEqualToString:@"com.queue.thread1"]) {
                DLog(@" Disconnect thread 1");
                if (_thread1) {
                    NSLog(@" Disconnect clear thread 1");
                    [_thread1 cancelAllOperations];
                    [_thread1 setSuspended:YES];
                    _thread1 = nil;
                    pthread_mutex_lock(&mutexForThread1);
                    self.transmitQueue1 = nil;
                    pthread_mutex_unlock(&mutexForThread1);
                }
                
            } else if ([threadName isEqualToString:@"com.queue.thread2"]) {
                DLog(@" Disconnect thread 2");
                if (_thread2) {
                    NSLog(@" Disconnect clear thread 2");
                    [_thread2 cancelAllOperations];
                    [_thread2 setSuspended:YES];
                    _thread2 = nil;
                    pthread_mutex_lock(&mutexForThread2);
                    self.transmitQueue2 = nil;
                    pthread_mutex_unlock(&mutexForThread2);
                }
                
            } else if ([threadName isEqualToString:@"com.queue.thread3"]) {
                DLog(@" Disconnect thread 3");
                if (_thread3) {
                    NSLog(@" Disconnect clear thread 3");
                    [_thread3 cancelAllOperations];
                    [_thread3 setSuspended:YES];
                    _thread3 = nil;
                    pthread_mutex_lock(&mutexForThread3);
                    self.transmitQueue3 = nil;
                    pthread_mutex_unlock(&mutexForThread3);
                }
            }
            /*
             else if ([threadName isEqualToString:@"com.queue.thread4"]) {
             NSLog(@" Disconnect thread 4");
             if (_thread4) {
             NSLog(@" Disconnect clear thread 4");
             [_thread4 cancelAllOperations];
             [_thread4 setSuspended:YES];
             _thread4 = nil;
             self.transmitQueue4 = nil;
             }
             
             }*/
            
            else {
                DLog(@"No Name Found");
            }
            
        } else {
            DLog(@"Out of bounds 9");
        }
    } else {
        DLog(@"DO NOTHING **");
    }
}

// Removed all the connected threads
-(void)removeAllTheConnectedThread
{
    [_thread1 cancelAllOperations];
    [_thread1 setSuspended:YES];
    _thread1 = nil;
    self.transmitQueue1 = nil;
    [_thread2 cancelAllOperations];
    [_thread2 setSuspended:YES];
    _thread2 = nil;
    self.transmitQueue2 = nil;
    [_thread3 cancelAllOperations];
    [_thread3 setSuspended:YES];
    _thread3 = nil;
    self.transmitQueue3 = nil;
    [_thread4 cancelAllOperations];
    [_thread4 setSuspended:YES];
    _thread4 = nil;
    self.transmitQueue4 = nil;
}

-(void)saveDebugLogsInDataBase:(ShoutDataReceiver *)pckData isFirstPacket:(BOOL)isFirstpacketAgain
{
    DebugLogsInfo *object;// = [[DebugLogsInfo alloc] init];
    
    if(YES)
    {
        object =  [NSEntityDescription insertNewObjectForEntityForName:@"DubugLogs" inManagedObjectContext:[App_delegate xyz]];
    }
    object.messageType = @"CMS";
    // dataType
    
    if (pckData.header.type == ShoutTypeTextMsg)
    {
        object.typeOfData = @"Text";
    }
    else if (pckData.header.type == ShoutTypeImage)
    {
        object.typeOfData = @"Image";
    }
    else if (pckData.header.type == ShoutTypeAudio)
    {
        object.typeOfData = @"Audio";
    }
    else if (pckData.header.type == ShoutTypeVideo)
    {
        object.typeOfData = @"Video";
    }
    else if (pckData.header.type == ShoutTypeGif)
    {
        object.typeOfData = @"Gif";
    }
    
    if(pckData.header.typeOfMsgSpecialOne == 176)
    {
        object.typeOfData = @"Channel Data";
    }
    
    NSString *msg;
    BOOL isFound =  NO;
    if (pckData.header.typeOfMsgSpecialOne == 5)
    {
        // text from iPhone
        object.messageType = @"iPhone to iPhone Text Message";
        isFound = YES;
        msg = @"Text";
    }
    else if (pckData.header.typeOfMsgSpecialOne ==29)
    {
        // Image from iPhone
        object.messageType = @"iPhone to iPhone Image Message";
        isFound = YES;
        msg = @"Image";
    }
    else if(pckData.header.typeOfMsgSpecialOne == 21)
    {
        // Audio from iPhone
        object.messageType = @"iPhone to iPhone Audio Message";
        isFound = YES;
        msg = @"Audio";
    }
    else if(pckData.header.typeOfMsgSpecialOne == 13)
    {
        // Video
        object.messageType = @"iPhone to iPhone Video Message";
        isFound = YES;
        msg = @"Video";
    }
    
    else if(pckData.header.typeOfMsgSpecialOne == 25)
    {
        // Gif From iPhone
        object.messageType = @"iPhone to iPhone Gif Message";
        isFound = YES;
        msg = @"Gif";
    }
    
    else if (pckData.header.typeOfMsgSpecialOne == 74)
    {
        // Image from CMS
        object.messageType = @"CMS Image Message";
        isFound = YES;
        msg =  @"Image";
    }
    else if (pckData.header.typeOfMsgSpecialOne == 73)
    {
        // gif from CMS
        object.messageType = @"CMS Gif Message";
        isFound = YES;
        msg =  @"Gif";
    }
    if (!isFound) {
        
        NSString *string = @"" ;
        NSUInteger x = pckData.header.typeOfMsgSpecialOne;
        
        while (x>0) {
            string = [[NSString stringWithFormat: @"%lu", x&1] stringByAppendingString:string];
            x = x >> 1;
        }
        
        if ([string isEqual:[NSNull null]] || [string isEqualToString:@""] || [string isEqualToString:@"0"]) {
            return;
        }
        
        if (string.length<4) {
            return;
        }
        
       // if ([[string substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"1000"]) {
            
            // CMS Channel data
        if(!object.typeOfData)
        {
            object.messageType = @"CMS Channel Data";
            msg =  @"Channel Data";
            isFound = YES;
        }
       // }
    }
    if (pckData.header.typeOfMsgSpecialOne == 72 && !isFound)
    {
        // text from CMS
        object.messageType = @"CMS Text Message";
        isFound = YES;
        msg =  @"Text";
    }
    NSString *receiveStatus;
    if (pckData.isPacketHeaderFound && pckData.isGotLastPacket && !isFirstpacketAgain)
    {
        int lastIndex   = [[[pckData.packetArray lastObject] objectForKey:@"Frag_No"] intValue];
        if (pckData.packetArray.count-1 == lastIndex && pckData.isGotPerfectImage)
        {
            receiveStatus =  @"Received";
            object.numberOfPackets =  [NSNumber numberWithInt:pckData.packetArray.count+1];
            //object.sizeOfData     = object
        }
        else if ((pckData.packetArray.count-1 - lastIndex) <=8 && !pckData.isGotPerfectImage)
        {
            receiveStatus =  @"Received";
            object.numberOfPackets = [NSNumber numberWithInt:pckData.packetArray.count+1];
            //object.sizeOfData     = object
        }
    }
    else if(!isFirstpacketAgain)
    {
        receiveStatus = @"Receiving";
    }
    else
    {
        receiveStatus = @"Forwarding...";
    }
    if(!msg)
    {
    object.event = [NSString stringWithFormat:@"%@ %@",receiveStatus,@"Channel data"];
    }else
    {
    object.event = [NSString stringWithFormat:@"%@ %@",receiveStatus,msg];
    }
    // utc timestamp
    object.timeStamp =  [NSNumber numberWithInteger:[[AppManager timeStamp] integerValue]];
    // shout id of the message
    object.messageID =  pckData.header.shoutId;
    // group id of the message
    object.groupID   =  pckData.header.groupId;
    
    // channel id of the message
    object.channelID =  @"";
  
    NSMutableDictionary *deviceDict = [self deviceIdOfDevices];
    
    if([deviceDict objectForKey:@"Device1"])
    {
        object.deviceID1 = [deviceDict objectForKey:@"Device1"];
    }else
    {
        object.deviceID1 = @"";
    }
    
    if([deviceDict objectForKey:@"Device2"])
    {
        object.deviceID2 = [deviceDict objectForKey:@"Device2"];
    }else
    {
        object.deviceID2 = @"";
    }
    
    if([deviceDict objectForKey:@"Device3"])
    {
        object.deviceID3 = [deviceDict objectForKey:@"Device3"];
    }else
    {
        object.deviceID3 = @"";
    }
    
    if([deviceDict objectForKey:@"BukiBox"])
    {
        object.bukiBoxID = [deviceDict objectForKey:@"BukiBox"];
    }else
    {
        object.bukiBoxID = @"";
    }
    
    if([deviceDict objectForKey:@"Mode"])
    {
        if([[deviceDict objectForKey:@"Mode"] intValue] == 0)
        {
            object.deviceRole = @"Master";
        }else
        {
            object.deviceRole = @"Slave";
        }
    }
    else
    {
        object.deviceRole = @"";
    }
    
    // save the data base
    object.msgUniqueID =  pckData.header.uniqueID;
    
    if(pckData.header.typeOfMsgSpecialOne ==128 && pckData.packetArray.count>2)
    {
        
    }else
    {
    //to save the data
    [DBManager save];
    }
}

-(NSMutableDictionary *)deviceIdOfDevices
{
    NSMutableArray *centralDevices    = [[NSMutableArray alloc] init];
    NSMutableArray *periPheralDevices = [[NSMutableArray alloc] init];
    NSMutableDictionary *deviceDictionary       = [[NSMutableDictionary alloc] init];
    centralDevices = [[BLEManager sharedManager].centralM.connectedDevices copy];
    
    periPheralDevices =  [[BLEManager sharedManager].perM.connectedCentrals copy];
    
    if(periPheralDevices != nil && (centralDevices != nil))
    {
        if([periPheralDevices count] > 0 && [centralDevices count] ==0)
        {
            
            [periPheralDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CBCentral *central = [obj objectForKey:Central_Ref];
               // DLog(@"Central Name %@",central.name);
                
                if([obj objectForKey:@"ID"])
                {
                    NSString *str = [NSString stringWithFormat:@"%@%lu",@"Device",(unsigned long)idx+1];
                    [deviceDictionary setObject:[obj objectForKey:@"ID"] forKey:str];
                }
            }];
            [deviceDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Mode"];
        }
        else if([periPheralDevices count] == 0 && [centralDevices count] >0)
        {
            
            [centralDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CBPeripheral *peri = [obj objectForKey:Peripheral_Ref];
                DLog(@"Peripheral Name %@",peri.name);
                
                if(([peri.name hasPrefix:@"iP"] || ([peri.name hasPrefix:@"M0000"])) && (peri.state == 2)) {
                    
                    if([obj objectForKey:@"Adv_Data"])
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%lu",@"Device",(unsigned long)idx+1];
                        [deviceDictionary setObject:[obj objectForKey:@"Adv_Data"] forKey:str];
                    }
                }
                else
                {
                    if([obj objectForKey:@"Adv_Data"])
                    {
                        if([[obj objectForKey:@"Adv_Data"] hasPrefix:@"B000"])
                        {
                            [deviceDictionary setObject:[obj objectForKey:@"Adv_Data"] forKey:@"BukiBox"];
                        }
                    }
                }
            }];
            [deviceDictionary setObject:[NSNumber numberWithInt:0] forKey:@"Mode"];
        }
    }
    return deviceDictionary;
}

@end
