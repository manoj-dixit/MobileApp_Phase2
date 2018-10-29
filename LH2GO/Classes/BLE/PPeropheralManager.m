//
//  PPeropheralManager.m
//  TestBluetooth
//
//  Created by Prakash Raj on 19/09/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "PPeropheralManager.h"
#import "BLEManager.h"
#import "ShoutInfo.h"
#import "ShoutManager.h"
#import "SonarDataInfo.h"
#import "DebugLogsInfo.h"
#import "DevicePresencePacketInfo.h"

#define kPacketSendDelay 0.1 //Sec

//NSUInteger dynamicMTUSize = 14;//20;//shradha
NSUInteger currentRSSIValue = 0;

@interface PPeropheralManager () {
    
    BOOL _isPingSending;
}
@property (strong, nonatomic) dispatch_queue_t peripheralQueue;
@property (nonatomic,strong)CBMutableService *transferService;


//@property (strong, nonatomic) NSString *currentShId;
//@property (strong, nonatomic) NSString *currentPingShId;


@property (nonatomic, strong) ShoutDataSender *dataToSend;
@property (nonatomic, strong) NSData *pingDataToSend;
@property (nonatomic, strong) ShoutDataReceiver *shD;
@property (nonatomic,strong) NSString *cmsTimer;
@property (nonatomic,assign) BOOL isRequestingUserInfo;
@property (nonatomic,strong) NSOperationQueue *forwardingQueue;
@property (nonatomic,strong) NSOperationQueue *gettingDataQueue;
// Queue to check if data is available in master array
@property (strong, nonatomic) NSOperationQueue *messageSendingQueue;

@property (nonatomic, strong) NSMutableArray *failureStack;
@property (assign) BOOL isReadyToSend;
@end

BOOL _isSending ;
@implementation PPeropheralManager

- (id)init {
    if(self = [super init]) {
        _peripheralQueue = dispatch_queue_create("com.kiwi.myPeripheral", DISPATCH_QUEUE_SERIAL);
        // central.
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_peripheralQueue];
        _connectedCentrals = [NSMutableArray new];
        _recieveQueue = [NSMutableDictionary new];
        _recievePingQueue = [NSMutableDictionary new];
        _forwardingQueue = [[NSOperationQueue alloc] init];
        _forwardingQueue.maxConcurrentOperationCount = 1;
        _failureStack = [[NSMutableArray alloc] init];
        _gettingDataQueue = [[NSOperationQueue alloc] init];
        _gettingDataQueue.maxConcurrentOperationCount = 1;
        _gettingDataQueue.qualityOfService = NSQualityOfServiceUtility;
        self.messageSendingQueue = [[NSOperationQueue alloc] init];
        self.messageSendingQueue.maxConcurrentOperationCount = 1;
        self.messageSendingQueue.qualityOfService = NSQualityOfServiceUserInitiated;

        // intilalize with the empty value
        _master_Id1=@"";
        _master_Id2=@"";
        _keyToShowSlaveOrFreeNode = @"F";
    }
    return self;
}

- (void)advertize {
    dispatch_async(self.peripheralQueue, ^{
        if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn)
        {
            DLog(@"Advertise with Name %@ with Service UUID %@",[NSString stringWithFormat:@"M%@%@%@",[[NSUserDefaults standardUserDefaults]objectForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1],TRANSFER_SERVICE_UUID);
            [self.peripheralManager stopAdvertising];
            [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]],CBAdvertisementDataLocalNameKey:[NSString stringWithFormat:@"M%@%@%@",[[NSUserDefaults standardUserDefaults]objectForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1]}];
            NSLog(@"************* Add started *************");
        }
    });
}

-(void)stopAdv:(void(^)(BOOL success)) isFinish
{
    dispatch_async(self.peripheralQueue, ^{
        [self.peripheralManager stopAdvertising];
        isFinish(YES);
    });
}

#pragma mark - Private methods

- (void)checkQueue1
{
    [self.messageSendingQueue addOperationWithBlock:^{
        if(_isSending) return;
        if (_dataToSend) return;
        if (_shD) {
            [self updateIntermediatProgress:YES];
            [self sendPacket];
            return;
        }
        NSObject *data = [[BLEManager sharedManager] nextData];
        if ([data isKindOfClass:[ShoutDataSender class]]) {
            _dataToSend = nil;
            _dataToSend = (ShoutDataSender*)data;
            if(_dataToSend){
                self.connectedInProcessCentrals = [NSMutableArray arrayWithArray:self.connectedCentrals];
                [self send];
            }
        }
        else if([data isKindOfClass:[ShoutDataReceiver class]]) {
            _shD = (ShoutDataReceiver*)data;
            if(_shD){
                [self updateIntermediatProgress:YES];
                self.connectedInProcessCentrals = [NSMutableArray arrayWithArray:self.connectedCentrals];
                if ([[BLEManager sharedManager].highPriorityqueue count]>1) {
                    DLog(@"send pls");
                    [self sendPacket];
                    [self checkQueue1];
                }else
                {
                    DLog(@"do not send higher queue is %@",[BLEManager sharedManager].highPriorityqueue);
                    [self sendPacket];
                }
            }
        }
    }];
}

- (void)checkPingQueue {
    dispatch_async(self.peripheralQueue, ^{
        if(_isPingSending) return;
        if (_pingDataToSend!=nil)return;
        SonarDataInfo *sonarInfo = [[BLEManager sharedManager] nextSonarData];
        NSObject *data = sonarInfo.sonarData;
        if (data&&[data isKindOfClass:[NSData class]]) {
            _pingDataToSend = nil;
            _pingDataToSend = (NSData*)data;
            if(_pingDataToSend){
                if (sonarInfo.central!=nil) {
                    if ([self.connectedCentrals containsObject:sonarInfo.central]){
                        self.connectedInProcessCentrals = [[NSMutableArray alloc] initWithObjects:sonarInfo.central, nil];
                    }
                    else{
                        self.connectedInProcessCentrals = [NSMutableArray arrayWithArray:self.connectedCentrals];
                    }
                }
                else {
                    self.connectedInProcessCentrals = [NSMutableArray arrayWithArray:self.connectedCentrals];
                }
                [self sendPing];
            }
        }
        else{
            if(_isSending) {
                DLog(@"BH send");
                [self send];
            }
            else
                [self checkQueue1];
        }
    });
}

-(void)checkMyQueue1{
    dispatch_async(self.peripheralQueue, ^{
        
        NSObject *data = [[BLEManager sharedManager] myNextData];
        DLog(@"checkMyQueue %@",data);
        if ([data isKindOfClass:[ShoutDataSender class]]) {
            _dataToSend = nil;
            _dataToSend = (ShoutDataSender*)data;
            if(_dataToSend){
                self.connectedInProcessCentrals = [NSMutableArray arrayWithArray:self.connectedCentrals];
                [self send];
            }
        }
        
        else if([data isKindOfClass:[ShoutDataReceiver class]]){
            _shD = (ShoutDataReceiver*)data;
            if(_shD){
                [self updateIntermediatProgress:YES];
                self.connectedInProcessCentrals = [NSMutableArray arrayWithArray:self.connectedCentrals];
                [self sendPacket];
            }
        }
    });
}

- (NSArray*)getValidCentral:(NSString*)currentId{
    // There's data left, so send until the callback fails, or we're done.
    NSMutableArray *centrals = [NSMutableArray new];
    
    NSMutableArray *allConnectedCentrals = nil;
    allConnectedCentrals = [NSMutableArray arrayWithArray:self.connectedInProcessCentrals];
    
    NSArray *uuids = [[[BLEManager sharedManager] reciever] objectForKey:currentId];
    
    if(!uuids || uuids.count == 0) {
        [centrals addObjectsFromArray:allConnectedCentrals];
    } else {
        
        [allConnectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CBCentral *cen = [obj objectForKey:Central_Ref];
            NSString *uuid1 = [cen.identifier UUIDString];
            
            BOOL found = NO;
            for(NSString *uuid in uuids) {
                if ([uuid isEqualToString:uuid1]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [centrals addObject:cen];
            }
        }];
    }
    return centrals;
}

int i = 1;


-(void)sendEventLogToBbox:(NSArray<CBCentral *>*)centrals str:(NSString*)bleStr
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
            NSString *varyingString1 = @"LOG";
            NSString *varyingString2 = @"LOG";
            NSString *str = [NSString stringWithFormat: @"%@%@%@", varyingString1,bleStr,varyingString2];
            NSData *chunk = [str dataUsingEncoding:NSUTF8StringEncoding];
            [self.peripheralManager updateValue:chunk forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:centrals];
        }
    });
    
}

- (void)send
{
    if(!self.connectedInProcessCentrals.count) {
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
    DLog(@"amountToSend --- %lu",(long)amountToSend);
    
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
            //  frageMentOfPacket  = (_dataToSend.totalShoutLength - _dataToSend.shoutData.length)/(dynamicMTUSize-BOM_Length);
        }
        else
        {
            isFirstPacket   = NO;
            amountToSend = dynamicMTUSize;
            // frageMentOfPacket  = (_dataToSend.totalShoutLength - _dataToSend.shoutData.length)/dynamicMTUSize;
        }
    }
    else
    {
        isFirstPacket   = NO;
        amountToSend = _dataToSend.shoutData.length;
        // frageMentOfPacket  = (_dataToSend.totalShoutLength - _dataToSend.shoutData.length)/dynamicMTUSize;
    }
    
//    NSData *loudHailerData  = [AppManager dataFromHexString:_dataToSend.loudHailer_Id];
//    
//    NSData *shoutData   = [AppManager dataFromHexString:[AppManager ConvertMsgIdNumberTOHexString:[NSString stringWithFormat:@"%@",_dataToSend.shId]]];
    
    int spcl = _dataToSend.typeOfMsgSpecialByte;
    NSData *specialCh =  [NSData dataWithBytes: &spcl length:1];
    
    // Copy out the data we want
    
    NSMutableData *dataToSend   =[[NSMutableData alloc] init];
    NSData *chunk = [NSData dataWithBytes:_dataToSend.shoutData.bytes length:amountToSend];
    
    if (isFirstPacket)
    {
        [dataToSend appendData:BOMData()];
        NSString *str = @"000";
        [dataToSend appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [dataToSend appendData:[AppManager dataFromHexString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID] ]];
    [dataToSend appendData:[AppManager dataFromHexString:[AppManager ConvertNumberTOHexString:[NSString stringWithFormat:@"%@",_dataToSend.shId]]]];
    
    NSData *fragmentBytes  = [AppManager dataFromHexString:[AppManager ConvertNumberTOHexString:[NSString stringWithFormat:@"%d",frageMentOfPacket]]];
    [dataToSend appendData:fragmentBytes];
    [dataToSend appendData:specialCh];
    [dataToSend appendData:chunk];
    
    DLog(@"chunk is --- %@",chunk);
    DLog(@"Data to send chunk is --- %@",dataToSend);
    
    if(chunk.length==0)
    {
        _dataToSend = nil;
        _isSending = NO;
        return;
    }
    
    NSArray *centrals = [self getValidCentral:self.currentShId];
    
    if(!centrals.count||!self.connectedInProcessCentrals.count) {
        _isSending = NO;
        _dataToSend = nil;
        return;
    }
    
    if (_dataToSend==nil) {
        return;
    }
    
    BOOL didSend = NO;
    do {
        @try {
            if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
                
                didSend =  [self.peripheralManager updateValue:dataToSend forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
            }
            else{
                _isSending = NO;
                _dataToSend = nil;
                break;
            }
        }
        @catch (NSException *exception)
        {
            DLog(@"Exception in send %@ %@",exception,exception.description);
            _isSending = NO;
            _dataToSend = nil;
            [self performSelectorInBackground:@selector(checkMyQueue1) withObject:nil];
            
            break;
        }
        
        // If it didn't work, drop out and wait for the callback
        if (didSend&&_dataToSend!=nil) {
            // update data to send next time.
            @try {
                _dataToSend.shoutData = [[NSData dataWithBytes:_dataToSend.shoutData.bytes + amountToSend length:_dataToSend.shoutData.length - amountToSend] mutableCopy];
                _dataToSend.fragmentNO = _dataToSend.fragmentNO+1;
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
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
            i = 1;
            _dataToSend = nil;
            [self performSelectorInBackground:@selector(checkQueue1) withObject:nil];
            break;
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
                        DLog(@"error");
                        
                    } @finally {
                        
                    }
                    DLog(@"shout data sender ----- %@",shDS);
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShoutProgressUpdate object:shDS userInfo:nil];
                });
            }
        }
    }
    while(didSend);
    
    // [self performSelector:@selector(sendMsg) withObject:nil afterDelay:0.01];
    //  [self sendMsg];
}

-(void)sendMsg
{
    if(_dataToSend)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DLog(@"BH send 1");
            [self send];
            
        });
    }
    else if (_shD)  {
        [self sendPacket];
    }
}


- (void)sendPing {
    
    if(!self.connectedInProcessCentrals.count) {
        _isPingSending = NO;
        _pingDataToSend = nil;
        return;
    }
    
    _isPingSending = YES;
    
    // Work out how big it should be
    NSInteger amountToSend = self.pingDataToSend.length;
    
    // Can't be longer than 50 bytes
    if (amountToSend > dynamicMTUSize) amountToSend = dynamicMTUSize;
    
    // Copy out the data we want
    NSData *chunk = [NSData dataWithBytes:self.pingDataToSend.bytes length:amountToSend];
    
    NSArray *centrals = [self getValidCentral:self.currentPingShId];
    
    if(!centrals.count||!self.connectedInProcessCentrals.count) {
        _isPingSending = NO;
        _pingDataToSend = nil;
        return;
    }
    
    BOOL didSend = NO;
    do{
        @try {
            if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
                didSend = [self.peripheralManager updateValue:chunk forCharacteristic:_transferCharacteristicForSonar onSubscribedCentrals:centrals];
            }
            else{
                _isPingSending = NO;
                _pingDataToSend = nil;
                break;
            }
        }
        @catch (NSException *exception) {
            _isPingSending = NO;
            _pingDataToSend = nil;
            [self performSelectorInBackground:@selector(checkPingQueue) withObject:nil];
            break;
        }
        
        // If it didn't work, drop out and wait for the callback
        if (didSend&&_pingDataToSend!=nil) {
            // update data to send next time.
            _pingDataToSend = [[NSData dataWithBytes:_pingDataToSend.bytes + amountToSend length:_pingDataToSend.length - amountToSend] mutableCopy];
        }
        
        // Was it the last one?
        if (!self.pingDataToSend.length) {
            _isPingSending = NO;
            _pingDataToSend = nil;
            [self performSelectorInBackground:@selector(checkPingQueue) withObject:nil];
            break;
        }
    }
    while(didSend);
}

- (void)updateIntermediatProgress:(BOOL)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateProgressShout object:[NSNumber numberWithBool:status] userInfo:nil];
    });
}

- (void)sendPacket{
    
    //LHRU_MESH :  first two line Change done for testing, it is not included in actual code.
    _isSending = NO;
    _shD = nil;
    _dataToSend = nil;
    
    //    if(!self.connectedInProcessCentrals.count||_shD.doNotForwadIt) {
    //        _shD.doNotForwadIt = YES;
    //        _isSending = NO;
    //        _shD = nil;
    //        [self updateIntermediatProgress:NO];
    //        return;
    //    }
    //
    //    _isSending = YES;
    //
    //    NSArray *centrals = [self getValidCentral:self.currentShId];
    //
    //    if(!centrals.count||!self.connectedInProcessCentrals.count) {
    //        _shD.doNotForwadIt = YES;
    //        _isSending = NO;
    //        _shD = nil;
    //        [self updateIntermediatProgress:NO];
    //        return;
    //    }
    //
    //    BOOL didSend;
    //
    //    do{
    //        didSend = NO;
    //
    //        if (_shD.packetArray.count>0&&!_shD.isAlreadyExist) {
    //
    //            NSData *chunk = [_shD.packetArray objectAtIndex:0];
    //
    //            @try {
    //                if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
    //                    didSend = [self.peripheralManager updateValue:chunk forCharacteristic:_transferCharacteristicForShouts onSubscribedCentrals:centrals];
    //                }
    //                else{
    //                    _shD.doNotForwadIt = YES;
    //                    _isSending = NO;
    //                    _shD = nil;
    //                    didSend=NO;
    //                    [self updateIntermediatProgress:NO];
    //                }
    //            }
    //            @catch (NSException *exception) {
    //                _shD.doNotForwadIt = YES;
    //                _isSending = NO;
    //                _shD = nil;
    //                [self updateIntermediatProgress:NO];
    //                [self performSelectorInBackground:@selector(checkQueue) withObject:nil];
    //                didSend=NO;
    //            }
    //
    //            // If it didn't work, drop out and wait for the callback
    //            if (didSend&&_shD!=nil&&_shD.packetArray.count>0) {
    //                [_shD.packetArray removeObjectAtIndex:0];
    //            }
    //        }
    //
    //        if (_shD.isAlreadyExist || (_shD.packetArray.count==0)) {
    //            [self updateIntermediatProgress:NO];
    //            _isSending = NO;
    //            _shD=nil;
    //            [self performSelectorInBackground:@selector(checkQueue) withObject:nil];
    //            didSend=NO;
    //        }
    //    }
    //    while(didSend);
}

- (void)cleanupFromCentral{
    dispatch_async(self.peripheralQueue, ^{
        // [self cleanup];
    });
}

- (void)cleanup{
    if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self.peripheralManager stopAdvertising];
        [self.peripheralManager removeAllServices];
    }
    //  [self.peripheralManager removeAllServices];_TR
    [self.connectedCentrals removeAllObjects];
    [self.connectedInProcessCentrals removeAllObjects];
    _isPingSending = NO;
    _isSending = NO;
    self.shD = nil;
    self.pingDataToSend = nil;
    _dataToSend = nil;
    _transferCharacteristicForShoutsWRITE    =nil;
    _transferCharacteristicForShoutsUPDATE =nil;
    _transferCharacteristicForSonar = nil;
}

- (void)flush{
    dispatch_async(self.peripheralQueue, ^{
        [self cleanup];
        self.peripheralManager.delegate=nil;
        self.peripheralManager=nil;
        self.connectedCentrals=nil;
        self.connectedInProcessCentrals = nil;
        self.currentShId=nil;
        self.currentPingShId = nil;
    });
}

//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
//{
//    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
//
//    NSLog(@"Read Request ***** %@",request);
//}

- (void)peripheralManager:(CBPeripheralManager*)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    //[peripheral respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorSuccess];
    
    NSArray *requestArray = [requests copy];
    CBATTRequest *req = (CBATTRequest*) [requestArray objectAtIndex:0] ;
    NSString *uuidString = req.characteristic.UUID.UUIDString;
    
    NSLog(@"Dataggggg %@",[req value]);

    [_gettingDataQueue addOperationWithBlock:^{
        
    DLog(@"Getting request and Requests %@ %@",req,requests);
    
    if ([uuidString isEqualToString:TRANSFER_CHARACTERISTIC_WRITE_UUID])
    {
        if (requests.count>0)
        {
            if(req.value.length>4){
                NSString *stringReceived = [[NSString alloc]initWithData:req.value encoding:NSUTF8StringEncoding];
                
                NSString *stringReceived1 = [[NSString alloc]initWithData:[req.value subdataWithRange:NSMakeRange(0, 2)] encoding:NSUTF8StringEncoding];

                // for the ping request (Device presence Ping packet)
                if ([[stringReceived1 substringWithRange:NSMakeRange(0,2)] isEqualToString:UniqueIdentifierString])
                {
                   NSData *forwardData =  [[DevicePresencePacketInfo sharedInstance] updateTheHopeCount:[[req value] mutableCopy] isFromCentral:req.central isFromPeripheralDevice:nil];
                    
                    NSLog(@"Received Device Presence Packet and new packet is %@ ++ %@",req.value,forwardData);

                    if(forwardData==nil)
                    {
                        return;
                    }
                    
                    [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        // if not current central
                        CBCentral *cb1  =  [obj objectForKey:Central_Ref];
                        if (![req.central isEqual:cb1])
                        {
                            [self.forwardingQueue addOperationWithBlock:^{
                                BOOL success;
                                do {
                                    success = [self.peripheralManager updateValue:forwardData forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[cb1]];
                                    DLog(@"Forwarding Ping packets ++++");
                                    if(!success) {
                                        while (!_isReadyToSend) {
                                            usleep(1000);
                                        }
                                        _isReadyToSend = NO;
                                    }
                                } while(!success);
                                
                            }];
                            
                        }
                    }];
        
                }
                
                // if staring of the packet from 01 that is for master id packet
               else if ([[stringReceived substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"])
                {
                    if (stringReceived.length > 5) {
                        
                        if ([_connectedCentrals count] ==1) {
                            // slave
                            _master_Id1     =  [stringReceived substringWithRange:NSMakeRange(2, stringReceived.length -2)];
                            _keyToShowSlaveOrFreeNode = @"S";
                            
                            
                            [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                
                                if ([[obj objectForKey:Central_Ref] isEqual:req.central]) {
                                    
                                    NSDictionary *dic  = [[NSDictionary alloc] initWithObjectsAndKeys:req.central,Central_Ref,_master_Id1,Ref_ID, nil];
                                    [_connectedCentrals replaceObjectAtIndex:idx withObject:dic];
                                }
                            }];
                            
                            DLog(@"Master write with master id 1 and connected centrals %@ %@",_master_Id1,_connectedCentrals);
                            
                            NSString *startMsg   = @"02";
                            // to update reference in master
                            [peripheral updateValue:[[NSString stringWithFormat:@"%@%@M%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[req.central]];
                            
                            NSLog(@"Update value for Master 1  %@",[NSString stringWithFormat:@"%@%@M%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1]);
                            
                           
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(_delegate && [_delegate respondsToSelector:@selector(didRefreshconnectedCentral)])
                                    [_delegate didRefreshconnectedCentral];
                            });
                            
                            
                            
                            
                            return;
                        }
                        else if ([_connectedCentrals count] ==SlaveConnection)
                        {
                            __block BOOL isFirstMaster = false;
                            [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                
                                if ([[obj objectForKey:Central_Ref] isEqual:req.central])
                                {
                                    
                                    if (idx == 0)
                                    {
                                        _master_Id1     =  [stringReceived substringWithRange:NSMakeRange(2, stringReceived.length -2)];
                                        
                                        NSDictionary *dic  = [[NSDictionary alloc] initWithObjectsAndKeys:req.central,Central_Ref,_master_Id1,Ref_ID, nil];
                                                [_connectedCentrals replaceObjectAtIndex:idx withObject:dic];
                                        
                                        DLog(@"Master write with master id 1 and connected centrals %@ %@",_master_Id1,_connectedCentrals);
                                        
                                        isFirstMaster = YES;
                                        NSString *startMsg   = @"02";
                                        
                                        if ([_master_Id2 isEqualToString:@""]) {
                                            _keyToShowSlaveOrFreeNode = @"S";
                                            
                                            // to update reference in master
                                            [peripheral updateValue:[[NSString stringWithFormat:@"%@%@M%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[req.central]];
                                            NSLog(@"Update value for Master 1  %@",[NSString stringWithFormat:@"%@%@M%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1]);
                                        }
                                        else
                                        {
                                            _keyToShowSlaveOrFreeNode = @"B";
                                                 [peripheral updateValue:[[NSString stringWithFormat:@"%@%@M%@%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1,_master_Id2] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
                                            NSLog(@"Update value for Master 1  %@",[NSString stringWithFormat:@"%@%@M%@%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1,_master_Id2]);
                                        }
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if(_delegate && [_delegate respondsToSelector:@selector(didRefreshconnectedCentral)])
                                                [_delegate didRefreshconnectedCentral];
                                        });
                                    }
                                }
                            }];
                            
                            if (isFirstMaster) {
                                return;
                            }
                            
                            // slave bridge
                            if ([_master_Id2 isEqualToString:@""])
                            {
                                _master_Id2     =  [stringReceived substringWithRange:NSMakeRange(2, stringReceived.length -2)];
                                _keyToShowSlaveOrFreeNode = @"B";
                                
                                [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idxx, BOOL * _Nonnull stop) {
                                    
                                    if ([[obj objectForKey:Central_Ref] isEqual:req.central] && req.central!=nil) {
                                        
                                        NSDictionary *dic  = [[NSDictionary alloc] initWithObjectsAndKeys:req.central,Central_Ref,_master_Id2,Ref_ID, nil];
                                        [_connectedCentrals replaceObjectAtIndex:idxx withObject:dic];
                                        DLog(@"Value successfully replaced %@",[_connectedCentrals objectAtIndex:idxx]);
                                        *stop = YES;
                                    }
                                }];
                                
                                NSString *startMsg   = @"02";
                                // to update reference in master if it became as slave
                                [peripheral updateValue:[[NSString stringWithFormat:@"%@%@M%@%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1,_master_Id2] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
                                
                                NSLog(@"Update value for Master 1  %@",[NSString stringWithFormat:@"%@%@M%@%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1,_master_Id2]);
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if(_delegate && [_delegate respondsToSelector:@selector(didRefreshconnectedCentral)])
                                        [_delegate didRefreshconnectedCentral];
                                });
                                
                                [self stopAdv:^(BOOL success) {
                                }];
                                [self.peripheralManager stopAdvertising];
                                
                            }
                            return;
                        }
                        else
                            return;
                    }
                    else
                        return;
                }
                else if ([[stringReceived substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"PB"])
                {
                    // Ping packet from CMS side
                    // PB100147:261032111PE
                    [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        // if not current central
                        CBCentral *cb1  =  [obj objectForKey:Central_Ref];
                        if (![req.central isEqual:cb1])
                        {
                            [self.forwardingQueue addOperationWithBlock:^{
                                BOOL success;
                                do {
                                    success = [self.peripheralManager updateValue:req.value forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[cb1]];
                                    DLog(@"Forwarding Ping packets ++++");
                                    if(!success) {
                                        while (!_isReadyToSend) {
                                            usleep(1000);
                                        }
                                        _isReadyToSend = NO;
                                    }
                                } while(!success);
                                
                            }];
                            
                        }
                    }];
                    return;
                }
                else if([[stringReceived substringWithRange:NSMakeRange(0, 8)] isEqualToString:kStringOfDeletedPacket])
                {
                    // #!DELETE-000011!#
                    
                    NSString *contentID = [stringReceived substringWithRange:NSMakeRange(9,6)] ;
                    if ([contentID isKindOfClass:(id)[NSNull null]]) {
                        return;
                    }
                    if ([[BLEManager sharedManager].deletePacketDictionary objectForKey:contentID]) {
                        return;
                    }else
                    {
                        [[[BLEManager sharedManager] deletePacketDictionary] setObject:stringReceived forKey:contentID];
                    }

                    
                    if(_delegate && [_delegate respondsToSelector:@selector(deletePacketForContent:)])
                    {
                        [_delegate deletePacketForContent:req.value];
                    }
                    
                    [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        // if not current central
                        CBCentral *cb1  =  [obj objectForKey:Central_Ref];
                        if (![req.central isEqual:cb1])
                        {
                            [self.forwardingQueue addOperationWithBlock:^{
                                BOOL success;
                                do {
                                    success = [self.peripheralManager updateValue:req.value forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[cb1]];
                                    DLog(@"Forwarding delete content packets ++++");
                                    if(!success) {
                                        while (!_isReadyToSend) {
                                            usleep(1000);
                                        }
                                        _isReadyToSend = NO;
                                    }
                                } while(!success);
                                
                            }];
                        }
                    }];
                    return;
                }
            }
        }
        else
            return;
        
        DLog(@"Got packt is %@",[req value]);
        
      //  NSString *uuid = [[req central].identifier UUIDString];
        NSData *d  = [req value];
        [self updateRecievedShoutData:req.central Characteristic:req.characteristic value:d Completion:^(int value, ShoutDataReceiver *receive)
         {
             
             [self getCentral:req.central charcter:req.characteristic value:d ReceiveQu:receive value:value];
             
         }];
    }
        else if ([uuidString isEqualToString:TRANSFER_CHARACTERISTIC_READ_PERIPHERAL_ID])
        {
            NSString *stringValue = [[NSString alloc] initWithData:[req value] encoding:NSUTF8StringEncoding];
            DLog(@"didReceiveWriteRequests 7D5996A2-71B1-47D9-8450-48119463C7E7 %@",stringValue);
        }
        else if ([uuidString isEqualToString:TRANSFER_CHARACTERISTIC_READ_UPDATE_CONNECTED_IDS])
        {
            NSString *stringValue = [[NSString alloc] initWithData:[req value] encoding:NSUTF8StringEncoding];
            DLog(@"didReceiveWriteRequests 4A8CC23A-C13B-11E7-ABC4-CEC278B6B50A %@",stringValue);
        }
        else  if ([uuidString isEqualToString:TRANSFER_CHARACTERISTIC_WRITE_ID])
        {
            NSString *stringValue = [[NSString alloc] initWithData:[req value] encoding:NSUTF8StringEncoding];
            DLog(@"didReceiveWriteRequests 727925A6-7396-42AD-AE08-8929CAFC9D76 %@",stringValue);
            //FOR ANdroid
            // if ([_connectedCentrals count] ==1)
            {
                // slave
                _master_Id1     =  stringValue;
                _keyToShowSlaveOrFreeNode = @"S";
                
                
                [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([[obj objectForKey:Central_Ref] isEqual:req.central]) {
                        
                        NSDictionary *dic  = [[NSDictionary alloc] initWithObjectsAndKeys:req.central,Central_Ref,_master_Id1,Ref_ID, nil];
                        [_connectedCentrals replaceObjectAtIndex:idx withObject:dic];
                    }
                }];
                
                DLog(@"Master write with master id 1 and connected centrals %@ %@",_master_Id1,_connectedCentrals);
                
                
                NSString *connectedCentralStringIS = @"";
                for(NSMutableArray *arr in self.connectedCentrals)
                {
                    connectedCentralStringIS =  [connectedCentralStringIS stringByAppendingString:[arr valueForKey:@"ID"]];
                }
                NSLog(@"Conncetd Central in didReceiveReadRequest %@",connectedCentralStringIS);
                if(![connectedCentralStringIS isEqualToString:@""])
                {
                    NSLog(@"upadting value to Android %@ %@ %@ %@",connectedCentralStringIS, [connectedCentralStringIS dataUsingEncoding:NSUTF8StringEncoding], self.connectedCentrals ,@[req.central]);
                    
                    [peripheral updateValue:[connectedCentralStringIS dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristicReadUpdate onSubscribedCentrals:@[req.central]];
                    NSLog(@"upadted value to Android %@",self.connectedCentrals);
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_delegate && [_delegate respondsToSelector:@selector(didRefreshconnectedCentral)])
                        [_delegate didRefreshconnectedCentral];
                });
                
                return;
            }
        }
        else  if ([uuidString isEqualToString:TRANSFER_CHARACTERISTIC_UPDATE_UUID])
        {
            NSString *stringValue = [[NSString alloc] initWithData:[req value] encoding:NSUTF8StringEncoding];
            DLog(@"didReceiveWriteRequests 18591F7E-DB16-467E-8758-72F6FAEB03D8 %@",stringValue);
        }
    }];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    NSString *uuidString = request.characteristic.UUID.UUIDString;
    NSString *loudHailerId = [[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID];
    
    NSString *stringValue = [[NSString alloc] initWithData:[request value] encoding:NSUTF8StringEncoding];
    
    NSLog(@"Loud Hailer iD in didReceiveReadRequest %@ %@",loudHailerId, stringValue);
    
    if ([uuidString caseInsensitiveCompare:TRANSFER_CHARACTERISTIC_READ_UPDATE_CONNECTED_IDS] == NSOrderedSame) {
        // share the connected ceperintral id here
        
        NSLog(@"Conncetd Central in didReceiveReadRequest %@",self.connectedCentrals);
        
        NSString *connectedCentralStringIS = @"";
        for(NSMutableArray *arr in self.connectedCentrals)
        {
            connectedCentralStringIS =  [connectedCentralStringIS stringByAppendingString:[arr valueForKey:@"ID"]];
        }
        NSLog(@"Conncetd Central in didReceiveReadRequest %@",connectedCentralStringIS);
        //        if(![connectedCentralStringIS isEqualToString:@""])
        //        [self.peripheralManager updateValue:[connectedCentralStringIS dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristicReadUpdate onSubscribedCentrals:self.connectedCentrals];
    }
    else if ([uuidString caseInsensitiveCompare:TRANSFER_CHARACTERISTIC_UPDATE_UUID] == NSOrderedSame)
    {
        //DOnt Write to the one whom i am connected
        NSMutableArray *centralArray = [[NSMutableArray alloc]init];
        //        if(![self.textView.text isEqualToString:@""])
        //        {
        //            for(CBCentral *cen in self.connectedCentrals)
        //            {
        //                if(![cen isEqual:request.central]) {
        //                    if(![cen isEqual:request.central])
        //                    {
        //                        [centralArray addObject:cen];
        //                        [self.peripheralManager updateValue:[self.textView.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristicUpdate onSubscribedCentrals:centralArray];
        //                    }
        //                }
        //            }
    }
//    else if ([uuidString caseInsensitiveCompare:TRANSFER_CHARACTERISTIC_READ_PERIPHERAL_ID] == NSOrderedSame) {
//        // share the  peripheral id here
//        NSLog(@"Conncetd Central in didReceiveReadRequest TRANSFER_CHARACTERISTIC_READ_PERIPHERAL_ID %@",loudHailerId);
//        [self.peripheralManager updateValue:[loudHailerId dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristicRead onSubscribedCentrals:@[request.central]];
//    }
    
    // }
}

-(void)getCentral:(CBCentral *)cb charcter:(CBCharacteristic *)ch value:(NSData *)d ReceiveQu:(ShoutDataReceiver *)receive value:(int)value
{
    if (value ==1)
    {
        // duplicate message
        // No need to forward n no need to save  the data
        NSLog(@"BH Discarded message due to duplicate message");
        return ;
    }
    else if (value ==2)
    {
        // forward the message
        // if connected devices are only one
        // no need to forward it
        //                 if (_connectedCentrals.count==1) {
        //                     return;
        //                 }
        // if count is greater than 1.
        // find out the other connected device to forward the data
        [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // if not current central
            CBCentral *cb1  =  [obj objectForKey:Central_Ref];
            if (![cb isEqual:cb1])
            {
                [self.forwardingQueue addOperationWithBlock:^{
                    BOOL success;
                    do {
                        success = [self.peripheralManager updateValue:d forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[cb1]];
                        if(!success) {
                            while (!_isReadyToSend) {
                                usleep(1000);
                            }
                            _isReadyToSend = NO;
                        }
                    } while(!success);
                    
                    DLog(@"BH Message forwarded to %@ with packet %@",cb,d);
                    
                }];
                
            }
        }];
    }
    else if (value == 3)
    {
        //                 if (_connectedCentrals.count==1) {
        //                     //return;
        //                 }else
        //                 {
        // if count is greater than 1.
        // find out the other connected device to forward the data
        [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // if not current central
            CBCentral *cb1  =  [obj objectForKey:Central_Ref];
            if (![cb isEqual:cb1])
            {
                [self.forwardingQueue addOperationWithBlock:^{
                    BOOL success;
                    do {
                        success = [self.peripheralManager updateValue:d forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[cb1]];
                        if(!success) {
                            while (!_isReadyToSend) {
                                usleep(1000);
                            }
                            _isReadyToSend = NO;
                        }
                    } while(!success);
                    
                    DLog(@"BH Message forwarded EOM %@ with packet %@",cb,d);
                    
                }];
            }
        }];
        //       }
        // success message
        if(_delegate && [_delegate respondsToSelector:@selector(didRecieveData:from:fromCentral:forCharectorStic:)]) {
            [_delegate didRecieveData:receive from:@"122222" fromCentral:cb forCharectorStic:ch];
        }
    }
    else if (value ==4)
    {
        // just return
        // no need to do anything
        DLog(@"BH Invalid packet");
    }
    else if (value ==5)
    {
        DLog(@"BH Forwarding Bosss");
        // just return
        
        [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // if not current central
            CBCentral *cb1  =  [obj objectForKey:Central_Ref];
            if (![cb isEqual:cb1])
            {
                [self.forwardingQueue addOperationWithBlock:^{
                    BOOL success;
                    do {
                        success = [self.peripheralManager updateValue:d forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[cb1]];
                        if(!success) {
                            while (!_isReadyToSend) {
                                usleep(1000);
                            }
                            _isReadyToSend = NO;
                        }
                    } while(!success);
                    
                    DLog(@"BH Message forwarded EOM %@ with packet %@",cb,d);
                }];
            }
        }];
    }
    
}

- (void)createServiceAndCharectorstics
{
    [_peripheralManager removeAllServices];
    
    _transferCharacteristicForSonar = nil;
    _transferCharacteristicForShoutsWRITE = nil;
    _transferCharacteristicForShoutsUPDATE = nil;
    
    _transferService = nil;
    
    NSString *loudHailerId = [[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID];
    
    self.transferCharacteristicReadUpdate = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_READ_UPDATE_CONNECTED_IDS]
                                                                               properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify
                                                                                    value:nil
                                                                              permissions:CBAttributePermissionsReadable];
    
    self.transferCharacteristicRead = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_READ_PERIPHERAL_ID]
                                                                         properties: CBCharacteristicPropertyRead
                                                                              value:[loudHailerId dataUsingEncoding:NSUTF8StringEncoding]
                                                                        permissions:CBAttributePermissionsReadable ];

    self.transferCharacteristicWriteId = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_ID]
                                                                            properties: CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead
                                                                                 value:nil
                                                                           permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];

    
    _transferCharacteristicForShoutsWRITE = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead|CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    _transferCharacteristicForShoutsUPDATE = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UPDATE_UUID] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead|CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    _transferCharacteristicForSonar = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_SONAR_UUID] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead | CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    _transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
    
   // _transferService.characteristics = @[_transferCharacteristicForShoutsWRITE,_transferCharacteristicForShoutsUPDATE,_transferCharacteristicForSonar];
    
 _transferService.characteristics = @[self.transferCharacteristicRead,self.transferCharacteristicReadUpdate,self.transferCharacteristicForSonar,self.transferCharacteristicForShoutsWRITE,self.transferCharacteristicForShoutsUPDATE,self.transferCharacteristicWriteId];
    [_peripheralManager addService:_transferService];
    
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        NSLog(@"Peripheral Bluetooth turned ON");

        //  [self cleanup]; //Clear garbage data
        [_recieveQueue removeAllObjects];
        [_connectedCentrals removeAllObjects];
        [self createServiceAndCharectorstics];
        
//        if(![BLEManager sharedManager].devicePresenceTableTimer)
//        {
//            [BLEManager sharedManager].devicePresenceTableTimer = [NSTimer scheduledTimerWithTimeInterval:10
//                                                                                                   target:[BLEManager sharedManager]
//                                                                                                 selector:@selector(methodToCall)
//                                                                                                 userInfo:nil
//                                                                                                  repeats:YES];
//            
//            [[NSRunLoop mainRunLoop] addTimer:[BLEManager sharedManager].devicePresenceTableTimer forMode:NSDefaultRunLoopMode];
//        }
        
//        [[BLEManager sharedManager] methodToCall];
        
    }
    else if(peripheral.state == CBPeripheralManagerStatePoweredOff) {
        //  [self cleanup];
        NSLog(@"Peripheral Bluetooth turned OFF");
        [self sendPacket];
        [_connectedCentrals removeAllObjects];
        
        [[BLEManager sharedManager].addTimer invalidate];
        [BLEManager sharedManager].addTimer = nil;
        [[BLEManager sharedManager].scanTimer invalidate];
        [BLEManager sharedManager].scanTimer = nil;
        [BLEManager sharedManager].isToHandleScan = NO;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
        
//        [BLEManager sharedManager].devicePresenceTableTimer =  nil;
//        [[BLEManager sharedManager].devicePresenceTableTimer invalidate];
        
        
    }
    
    DevicePresencePacketInfo *shredIns = [DevicePresencePacketInfo sharedInstance];
    shredIns.devicePresenceFragmentCount = 0;
    
    [[BLEManager sharedManager].deletePacketDictionary removeAllObjects];

    [[BLEManager sharedManager].centralM clearTransmitQueues];

        if(_delegate && [_delegate respondsToSelector:@selector(didRefreshconnectedCentral)])
            [_delegate didRefreshconnectedCentral];

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    
    if ([[BLEManager sharedManager].centralM.connectedDevices count] > 0)
    {
        [[BLEManager sharedManager].centralM.connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CBPeripheral *peri = [obj objectForKey:Peripheral_Ref];
            
            [[BLEManager sharedManager].centralM.centralManager cancelPeripheralConnection:peri];
            
            for (CBService *service in peri.services)
            {
                if (service.characteristics != nil) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        
                        [peri setNotifyValue:NO forCharacteristic:characteristic];
                        
                    }
                }
            }
        }];
        
        [[BLEManager sharedManager].centralM.connectedDevices removeAllObjects];
        
        DLog(@"Removed connected Peripheral devices");
    }
    
    NSLog(@"Cental Connected ##################################### %@",central.description);
    
    __block BOOL isAlreadyExist =false;
    __block NSUInteger atIndex;
    // enumerate connected centrals to know central already exist in array or not
    [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // if already exist in the Array
        if ([[obj objectForKey:Central_Ref] isEqual:central])
        {
            NSDictionary *centralDic   = [[NSDictionary alloc] initWithObjectsAndKeys:central,Central_Ref,@"",Ref_ID,nil];
            isAlreadyExist = YES;
            atIndex           =   idx;
            [_connectedCentrals replaceObjectAtIndex:idx withObject:centralDic];
            [_peripheralManager setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatencyLow) forCentral:central];
            *stop  = YES;
        }
    }];
    
    if (!isAlreadyExist || [_connectedCentrals count]>SlaveConnection) {
        
        if ([_connectedCentrals count] == SlaveConnection) {
            
            [self stopAdv:^(BOOL success) {
                
            }];
            [self.peripheralManager stopAdvertising];
            
            //        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]]) {
            
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //                [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //
            //                    // if already exist in the Array
            //                    if ([[obj objectForKey:Central_Ref] isEqual:central])
            //                    {
            [peripheral updateValue:[@"02owly" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[central]];
            //                        [_connectedCentrals removeObject:obj];
            //                    }
            //                }];
            //            });
        }
        
        else  if (_connectedCentrals.count < SlaveConnection) {
            
            NSDictionary *centralDic   = [[NSDictionary alloc] initWithObjectsAndKeys:central,Central_Ref,@"",Ref_ID,nil];
            [_connectedCentrals addObject:centralDic];
            
            [_peripheralManager setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatencyLow) forCentral:central];
        }
    }
    
    if ([_connectedCentrals count] ==SlaveConnection-1)
    {
        _keyToShowSlaveOrFreeNode = @"S";
    }
    else  if ([_connectedCentrals count] == SlaveConnection)
    {
        [self stopAdv:^(BOOL success) {
            
            
        }];
        _keyToShowSlaveOrFreeNode = @"B";
        [self.peripheralManager stopAdvertising];
        //        [[BLEManager sharedManager] stopADV];
        
    }
    // Ask central to disconnect the Connection
    else if ([_connectedCentrals count] > SlaveConnection)
    {
        _keyToShowSlaveOrFreeNode = @"B";
        [self stopAdv:^(BOOL success) {
            
        }];
        [self.peripheralManager stopAdvertising];
        
        [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // if already exist in the Array
            if ([[obj objectForKey:Central_Ref] isEqual:central])
            {
                [peripheral updateValue:[@"02owly" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:@[central]];
                [_connectedCentrals removeObject:obj];
            }
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(didRefreshconnectedCentral)])
            [_delegate didRefreshconnectedCentral];
    });
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
    DLog(@"BH Disconnected by central %@",central);
    if ([_connectedCentrals count] ==1)
    {
        __block BOOL isExist = false;
        [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:Central_Ref] isEqual:central]) {
                isExist = YES;
            }
        }];
        if (isExist) {
            [_connectedCentrals removeObjectAtIndex:0];
            _master_Id1 = @"";
            _master_Id2 = @"";
            _keyToShowSlaveOrFreeNode = @"F";
            
            [BLEManager sharedManager].isToHandleScan = NO;
            [[BLEManager sharedManager] startAdvertising];
        }
    }
    else if ([_connectedCentrals count] ==2)
    {
        __block BOOL isDelete = false;
        __block NSInteger index;
        [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // if already exist in the Array
            if ([[obj objectForKey:Central_Ref] isEqual:central])
            {
                index  = idx;
                isDelete = YES;
                *stop  = YES;
            }
        }];
        
        if (isDelete)
        {
            [_connectedCentrals removeObjectAtIndex:index];
            if (index == 0)
            {
                _master_Id1 = _master_Id2;
                _master_Id2 = @"";
                _keyToShowSlaveOrFreeNode = @"S";
                
                NSString *startMsg   = @"02";
                
                // to update reference in master
                [peripheral updateValue:[[NSString stringWithFormat:@"%@%@M%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
                DLog(@"Update value for Master 1  %@",[NSString stringWithFormat:@"%@%@M%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1]);
            }
            else
            {
                _master_Id2 = @"";
                _keyToShowSlaveOrFreeNode = @"S";
                NSString *startMsg   = @"02";
                // to update reference in master
                [peripheral updateValue:[[NSString stringWithFormat:@"%@%@M%@%@%@",startMsg,[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID],[[NSUserDefaults standardUserDefaults] valueForKey:Network_Id],_keyToShowSlaveOrFreeNode,_master_Id1] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
                DLog(@"Update value for Master 1 and Master 2");
            }
            
            [self stopAdv:^(BOOL success)
             {
                 [BLEManager sharedManager].isToHandleScan = NO;
                 [[BLEManager sharedManager] startAdvertising];
                 
             }];
        }
    }
    
    if ([_connectedCentrals count] == 0)
    {
        _master_Id1 = @"";
        _master_Id2 = @"";
        _keyToShowSlaveOrFreeNode = @"F";
        
        [self stopAdv:^(BOOL success)
         {
             [[BLEManager sharedManager].perM.recieveQueue removeAllObjects];
             [[BLEManager sharedManager].centralM.recieveQueue removeAllObjects];

             [BLEManager sharedManager].isToHandleScan = NO;

             [[BLEManager sharedManager] startAdvertising];
         }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(didRefreshconnectedCentral)])
            [_delegate didRefreshconnectedCentral];
    });
    
    
    if([BLEManager sharedManager].isSuspendingByOS)
    {
        if ([BLEManager sharedManager].perM.connectedCentrals.count==0)
        {
            [BLEManager sharedManager].isScanningFromWakeUP = YES;
          [[BLEManager sharedManager] intialScan];
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    _isReadyToSend = YES;
    if (peripheral.state == CBPeripheralManagerStatePoweredOn){
        if (_pingDataToSend) {
            [self sendPing];
        }
        if(_dataToSend) {
            [self send];
        }
        else if (_shD)  {
            [self sendPacket];
        }
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if(error){
        NSLog(@"Error!!!! peripheralManagerDidStartAdvertising");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error!!!! didWriteValueForCharacteristic in pperipheral manager %@",error.localizedDescription);
    }
}

- (CBCentral*)getConnectedCentralFromUUID:(NSString*)uuid{
    CBCentral *currentCentral = nil;
    if (uuid != nil) {
        for(CBCentral *central in self.connectedCentrals){
            if ([central.identifier.UUIDString isEqualToString:uuid]) {
                currentCentral = central;
                break;
            }
        }
    }
    return currentCentral;
}

- (void)updateRecievedShoutData:(CBCentral *)central Characteristic:(CBCharacteristic *)characteristic value:(NSData *)data Completion:(void(^)(int value, ShoutDataReceiver *receive)) handler
{
    NSMutableData *myData = [data mutableCopy];
    if (myData.length <=6) {
        handler(4,nil);
        return;
    }
    
    NSLog(@"mydat ### %@",myData);
    
    //return;
    // check first 3 bytes
    NSString  *user_Id;
    NSData   *user_Id_Data;
    NSString *shout_ID;
    NSData   *shout_ID_Data;
    NSData   *specailFlagData;
    //  NSData   *spclByte4SchduleData;
    
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
    

    //   }else
    //   {
    //       specailFlagData = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH-2,1)];
    //  }
    
    //specailFlagData = [myData subdataWithRange:NSMakeRange(initialSTrtingByteNo+KLoud_Hailer_ID_Length+KShout_ID_Length+FRAGMENT_LENGTH-1,1)];
    
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

    }else
    {
    pckData = [_recieveQueue objectForKey:[NSString stringWithFormat:@"%@",user_Id]];
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
            
            // just forward to others
            if(isFirstPacket)
            {
                // save logs into the database
                [self saveDebugLogsInDataBase:pckData isFirstPacket:YES];
            }
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
            pckData.header.uniqueID = [NSString stringWithFormat:@"%@_%@",user_Id,shout_ID];
            [_recieveQueue setObject:pckData forKey:[NSString stringWithFormat:@"%@_%@",user_Id,shout_ID]];
        }else
        {
            pckData.header.uniqueID = [NSString stringWithFormat:@"%@",user_Id];
            [_recieveQueue setObject:pckData forKey:[NSString stringWithFormat:@"%@",user_Id]];
        }
        
        // save logs into the database
        [self saveDebugLogsInDataBase:pckData isFirstPacket:NO];
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
                    dic  = [[NSDictionary alloc] initWithObjectsAndKeys:[myData subdataWithRange:NSMakeRange(HeaderLength-1, [myData length]-HeaderLength-1)],@"Data",[NSNumber numberWithInt:number],@"Frag_No",nil];
                }else
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
                [self saveDebugLogsInDataBase:pckData isFirstPacket:NO];
                // return a call back
                handler(3,pckData);
                return;
            }else if ((pckData.packetArray.count-1 - lastIndex) <=8 && !pckData.isGotPerfectImage)
            {
                pckData.isLastChunk = YES;
                // return a call back
                [self saveDebugLogsInDataBase:pckData isFirstPacket:NO];
                handler(3,pckData);
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
                
        if (length>EOM_Length) {
            
            eom = [[NSString alloc] initWithData:[myData subdataWithRange:NSMakeRange([myData length]-EOM_Length, EOM_Length)]encoding:NSUTF8StringEncoding];
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
            // NSData *user_data = [myData subdataWithRange:NSMakeRange(2, 3)];
            //           ShoutDataReceiver *rc = (ShoutDataReceiver *)[_recieveQueue objectForKey:user_data];
            
            if ([eom isEqualToString:@"OM"]) {
                
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
                
                //  pckData.isGotLastPacket = YES;
                
                int lastIndex   = [[[pckData.packetArray lastObject] objectForKey:@"Frag_No"] intValue];
                
                NSLog(@"Last Packet is :%@ SHout Id is %@ Type Of Data is %d Last index : %d Total data : %lu", myData,shout_ID, pckData.header.typeOfMsgSpecialOne, lastIndex, (unsigned long)pckData.packetArray.count);
                
                if (pckData.packetArray.count-1 == lastIndex || (lastIndex-(pckData.packetArray.count-1)) <=8)
                {
                    if (pckData.packetArray.count-1 == lastIndex) {
                        pckData.isGotPerfectImage = YES;
                    }else
                        pckData.isGotPerfectImage     = NO;
                    
                    DLog(@"Got the All packets of Message having shout Id : %@",shout_ID);
                    [self saveDebugLogsInDataBase:pckData isFirstPacket:NO];
                    pckData.isLastChunk = YES;
                    // return a call back
                    handler(3,pckData);
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


- (void)clearDataQueForDisconnectedDevices{
    
    NSMutableDictionary *tempRecievePingQueue = [[NSMutableDictionary alloc]
                                                 init];
    NSMutableDictionary *tempRecieveQueue = [[NSMutableDictionary alloc]
                                             init];
    [_connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CBPeripheral *connectedPer = [obj objectForKey:Central_Ref];
        NSString *uuid = [connectedPer.identifier UUIDString];
        
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

-(void)saveDebugLogsInDataBase:(ShoutDataReceiver *)pckData isFirstPacket:(BOOL)isFirstpacketAgain
{
    DebugLogsInfo *object;
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
        
        // CMS Channel data
        if(!object.typeOfData)
        {
            object.messageType = @"CMS Channel Data";
            msg =  @"Channel Data";
            isFound = YES;
        }
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
            object.numberOfPackets =  [NSNumber numberWithInt:pckData.packetArray.count + 1];
            //object.sizeOfData     = object
        }
        else if ((pckData.packetArray.count-1 - lastIndex) <=8 && !pckData.isGotPerfectImage)
        {
            receiveStatus =  @"Received";
            object.numberOfPackets = [NSNumber numberWithInt:pckData.packetArray.count + 1];
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
    
    if(pckData.header.typeOfMsgSpecialOne == 128 && pckData.packetArray.count>2)
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

-(void)getNOtification
{
    if(self.peripheralManager.state == CBPeripheralManagerStatePoweredOn)
    {
    DevicePresencePacketInfo *shredIns = [DevicePresencePacketInfo sharedInstance];
    NSData *dddd = shredIns.mySendingData;
    BOOL success;
    do {
        success = [self.peripheralManager updateValue:dddd forCharacteristic:_transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
        if(!success) {
            while (!_isReadyToSend) {
                usleep(1000);
            }
            _isReadyToSend = NO;
        }
    } while(!success);
    }
    
}

@end
