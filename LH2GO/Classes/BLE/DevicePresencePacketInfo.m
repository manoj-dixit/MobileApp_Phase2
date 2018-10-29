//
//  DevicePresencePacketInfo.m
//  LH2GO
//
//  Created by Manoj Dixit on 27/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "DevicePresencePacketInfo.h"
#import "TimeConverter.h"
#import "Constant.h"


//#define UniqueIdentifierString              @"DP"
//#define PacketTimeInterval                 30


@implementation DevicePresencePacketInfo


// define the packet value

// 1 packet identier              2 Byte
// 2 source id                    4 Byte
// 3 Device Role                  1 Byte
// 4 Fragment Id                  1 Byte
// 5 Hope Count                   1 Byte pure Hex -  1 to 255
// 6 Time Stamp                   8 Byte - UTC Time
// 7 Interval                     1 Byte
// 8 CRC Value                    2 Byte


// Device Role Table
//0x01 : Buki-Box (Master : Future reserved)
//0x02 : Buki-Box (Slave)
//0x03 : iPhone (Master)
//0x04 : iPhone (Slave)
//0x05 : Android Phone (Master)
//0x06 : Android Phone (Slave)


+(id)sharedInstance
{
    static DevicePresencePacketInfo *sharedManager = nil;
    @synchronized(self) {
        if(!sharedManager)
        {
            // dynamicMTUSize = 20; //shradha
            sharedManager = [[DevicePresencePacketInfo alloc] init];
            sharedManager.devicePresenceFragmentCount = 0;
        }
    }
    return sharedManager;
}

-(NSData *)toGetTheDevicePresencePacketData:(NSData *)dataValue isDeviceRole:(int)deviceRoleV fragmentCount:(int)fragmentCountV isNeedToUpdate:(BOOL)isValue
{
    NSMutableData *data = [[NSMutableData alloc] init];
//    if(dataValue.length>20)
//    {
    // uniquness of the packet
    [data appendData:[UniqueIdentifierString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // adding extra byte coz right now loudhailer id is only 3 byte
    int extraByte = 0;
    NSData *extraByteData =  [NSData dataWithBytes: &extraByte length:1];
    [data appendData:extraByteData];
    
    // Add the loudhailer ID of the object
    [data appendData:[AppManager dataFromHexString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID] ]];
    DLog(@"Loudhailer ID %@",data);
    
    // device role value
    // should be 1 byte
    NSData *deviceRoleData =  [NSData dataWithBytes: &deviceRoleV length:1];
    [data appendData:deviceRoleData];
    
    // Fragment
    NSData *fragmentCountData =  [NSData dataWithBytes: &fragmentCountV length:1];
    [data appendData:fragmentCountData];
    
    // Hope Count
    int hopeCountValue = 1;
    NSData *hopeCountData =  [NSData dataWithBytes: &hopeCountValue length:1];
    [data appendData:hopeCountData];
    

    // timeStamp Value
    int timeStampValue = (int)[TimeConverter timeStamp];
    
    NSData *timeStampData =  [NSData dataWithBytes: &timeStampValue length:sizeof(timeStampValue)];
    // reverse the bytes
    [data appendData:timeStampData];//[self reversedData:timeStampData]];
    
    
    // reserve the bytes
    int reserveBytes = 0000;
    
    NSData *reserveBytesData =  [NSData dataWithBytes: &reserveBytes length:4];
    [data appendData:reserveBytesData];
    
    // timeInterval Value
    int timeInterval = PacketTimeInterval;
    NSData *timeIntervalData =  [NSData dataWithBytes: &timeInterval length:1];
    [data appendData:timeIntervalData];
    
    
//    [self crc16];
    
    int crcValue = 55;
    NSData *crcDataValue =  [NSData dataWithBytes: &crcDataValue length:2];
    [data appendData:crcDataValue];
    
    if (isValue)
    {
        
    }
   // }
    
    NSLog(@"data is %@",data);
    return data;
}

- (NSData *) reversedData:(NSData *)data
{
    NSData *myData = data;
    
    const char *bytes = [myData bytes];
    
    NSUInteger datalength = [myData length];
    
    char *reverseBytes = malloc(sizeof(char) * datalength);
    NSUInteger index = datalength - 1;
    
    for (int i = 0; i < datalength; i++)
    {
        reverseBytes[index--] = bytes[i];
    }
    NSData *reversedData = [NSData dataWithBytesNoCopy:reverseBytes length: datalength freeWhenDone:YES];
    
    return reversedData;
}

-(BOOL)calculateCRCvalue:(NSData *)dataValue
{
    BOOL isCRCRyt = NO;
    
    
    return isCRCRyt;
}




-(unsigned char)CRC8:(unsigned char *)ptr length:(unsigned char)len key:(unsigned char)key
{
    unsigned char i,crc=0;
    while(len--!=0)    {
        for(i=0x80; i!=0; i/=2)  {
            if((crc & 0x80) != 0) {
                crc *= 2;
                crc ^= key;
            } else
                crc *= 2;
            if((*ptr & i)!=0)
                crc ^= key;
        }
        ptr++;
    }
    return(crc);
}

uint16_t ComputeCRC(uint8_t *val, int length)
{
    int i;
    long crc = 0;
    long q;
    uint8_t c;
    
    for (i = 0; i < length; i++) {
        //      printf("val[%d] = %02x\n", i, val[i]);
        c = val[i];
        q = (crc ^ c) & 0x0f;
        crc = (crc >> 4) ^ (q * 0x1081);
        q = (crc ^ (c >> 4)) & 0xf;
        crc = (crc >> 4) ^ (q * 0x1081);
    }
    return (uint16_t)(uint8_t)crc << 8 | (uint8_t)(crc >> 8);
}

unsigned short crc16(const unsigned char *data_p, unsigned char length){
    unsigned char x;
    unsigned short crc = 0xFFFF;
    
    while (length--){
        x = crc >> 8 ^ *data_p++;
        x ^= x>>4;
        crc = (crc << 8) ^ ((unsigned short)(x << 12)) ^ ((unsigned short)(x <<5)) ^ ((unsigned short)x);
    }
    return crc;
}


static NSTimer *intiateTimer = nil;
static int number = 0;
static NSMutableData *returnData = nil;


-(NSData *)updateTheHopeCount:(NSMutableData *)data isFromCentral:(CBCentral *)centralDevice isFromPeripheralDevice:(CBPeripheral *)peripheralDevice
{
    if(returnData == nil)
    {
     returnData =  [[NSMutableData alloc] init];
    }
    
    // value will be changed
    NSString *loudHailer_Id   =  [[[NSString stringWithFormat:@"%@",[data subdataWithRange:NSMakeRange(3, 3)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    if([loudHailer_Id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID]])
    {
        // same user's ping packet so need to discard
        return nil;
    }

    if(data.length==20)
    {
        // hope count index is - 9th byte
        
        // get the hope count value first
      NSData *hopeData =   [data subdataWithRange:NSMakeRange(8,1)];
      NSString *hopeCountString =  [[[NSString stringWithFormat:@"%@",hopeData] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
      int previousHopeCount   = [AppManager convertIntFromString:hopeCountString];
        
        if(previousHopeCount==10)
        {
            // discard the data as count is already reached to 10
            return nil;
        }
        
      int newHopeCount = previousHopeCount+1;
        
        NSLog(@"Previous hope count value and New Hope Count value is %d %d",previousHopeCount,newHopeCount);
        
        NSData *firstPart = [data subdataWithRange:NSMakeRange(0, 8)];
        
        NSData *lastData  = [data subdataWithRange:NSMakeRange(9, 11)];
        
        NSData *hopeCountData =  [NSData dataWithBytes: &newHopeCount length:1];
        
        NSLog(@"Old data  is %@",returnData);
        
        returnData = nil;
        if(returnData == nil)
        {
            returnData =  [[NSMutableData alloc] init];
        }
        
        [returnData appendData:firstPart];
        [returnData appendData:hopeCountData];
        [returnData appendData:lastData];
        
        //returnData = data;
        
        NSLog(@"New data  is %@",returnData);
        
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
        // set the hope count value
        [dataDict setValue:[NSNumber numberWithInt:previousHopeCount] forKey:@"hope_Count"];
//        [dataDict setValue:[NSNumber numberWithInt:previousHopeCount] forKey:@"device_Role"];
        [dataDict setValue:loudHailer_Id forKey:@"device_ID"];

        // value will be changed
        NSString *timestamp   =  [[[NSString stringWithFormat:@"%@",[self reversedData:[data subdataWithRange:NSMakeRange(9, 4)]]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    
        int timestampValue   = [AppManager convertIntFromString:timestamp];
        
        // to discard the same packet coming again and again for the device using the same timestamp
        
        // checked if already exist the timestamp associated with the loudhailer ID
        if ([BLEManager sharedManager].dictToMaintainTheDevicePresencePacket) {
            if ([[BLEManager sharedManager].dictToMaintainTheDevicePresencePacket objectForKey:loudHailer_Id]) {
                if (timestampValue == [[[BLEManager sharedManager].dictToMaintainTheDevicePresencePacket objectForKey:loudHailer_Id] intValue]) {
                    return nil;
                }else
                {
                    // if not same update the timestamp value associate with the Loudhailer_ID
                    [[BLEManager sharedManager].dictToMaintainTheDevicePresencePacket setObject:[NSNumber numberWithInt:timestampValue] forKey:loudHailer_Id];
                }
            }else
            {
                // if not same update the timestamp value associate with the Loudhailer_ID
                [[BLEManager sharedManager].dictToMaintainTheDevicePresencePacket setObject:[NSNumber numberWithInt:timestampValue] forKey:loudHailer_Id];
            }
        }
        
        NSString *interval   =  [[[NSString stringWithFormat:@"%@",[data subdataWithRange:NSMakeRange(17, 1)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];

        int interValValue   = [AppManager convertIntFromString:interval];

        NSString *seq_NO   =  [[[NSString stringWithFormat:@"%@",[data subdataWithRange:NSMakeRange(8, 1)]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];

        int seqNO   = [AppManager convertIntFromString:seq_NO];

        [dataDict setValue:[NSNumber numberWithInt:timestampValue] forKey:@"timestamp"];
        [dataDict setValue:[NSNumber numberWithInt:interValValue] forKey:@"dp_Interval"];
        [dataDict setValue:[NSNumber numberWithInt:seqNO] forKey:@"seq_NO"];

        [dataDict setValue:[NSNumber numberWithInt:5] forKey:@"aging_Count"];
        
        if(centralDevice)
        {
            // set the device Role Value
            // 3
            [dataDict setValue:[NSNumber numberWithInt:3] forKey:@"device_Role"];
            
            [[BLEManager sharedManager].perM.connectedCentrals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                // if not current central
                CBCentral *cb1  =  [obj objectForKey:Central_Ref];
                if ([centralDevice isEqual:cb1])
                {
                    if ([obj objectForKey:@"ID"]) {
                    [dataDict setValue:[obj objectForKey:@"ID"] forKey:@"interface"];
                    *stop = YES;
                    }
                }
            }];
        }
        else if (peripheralDevice)
        {
            // set the device Role Value
            // 4
            [dataDict setValue:[NSNumber numberWithInt:4] forKey:@"device_Role"];
            
            [[BLEManager sharedManager].centralM.connectedDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([[obj objectForKey:Peripheral_Ref] isEqual:peripheralDevice]) {
                    
                    if ([obj objectForKey:@"ID"]) {
                        [dataDict setValue:[obj objectForKey:@"ID"] forKey:@"interface"];
                        *stop = YES;
                    }
                }
            }];
        }
        
        NSLog(@"XYZ %@",dataDict);
        [DisplayPresenceList insertOrUpdateTheDevicePresenceValue:dataDict];
    }
    return returnData;
}

-(NSData *)updateTheFragmentNumber:(NSData *)data
{
    NSData *returnData =  nil;
    if(data.length>20)
    {
        
    }
    return returnData;
}
@end
