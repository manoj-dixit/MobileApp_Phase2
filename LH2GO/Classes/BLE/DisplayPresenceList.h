//
//  DisplayPresenceList.h
//  LH2GO
//
//  Created by Manoj Dixit on 03/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DisplayPresenceList : NSManagedObject

//aging_Count       -  Count to be ecnounter the device that is already connected or got disconnected
//device_ID         - Loudhailer ID of the device
//device_Role       - Device Role of the Device, (BukiBox,IpHone master, iPhone Slave, ANdroid Master, ANdroid Slave)
//dp_Interval       - Interval of ping packet broadcasting
//hope_Count        - Hope Count value
//interface         - Interface of the Device
//seq_NO            - Fragment Number of the Packet
//timestamp         - TimeStamp of the intiate packet (Unix Timestamp)

@property (nonatomic,retain) NSString *aging_Count;
@property (nonatomic,retain) NSString *device_ID;
@property (nonatomic,retain) NSString *device_Role;
@property (nonatomic,retain) NSString *dp_Interval;
@property (nonatomic,retain) NSString *hope_Count;
@property (nonatomic,retain) NSString *interface;
@property (nonatomic,retain) NSString *seq_NO;
@property (nonatomic,retain) NSString *timestamp;

+(void)insertOrUpdateTheDevicePresenceValue:(NSMutableDictionary *)dictData;
+(void)updateTheDevicePresenceValue:(NSMutableDictionary *)dictData andArrayValue:(DisplayPresenceList *)displayPresenceList;
+(void)insertTheDevicePresenceValue:(NSMutableDictionary *)dictData;
+(void)deleteTheDevicePresenceValue:(NSMutableDictionary *)dictData;
+(void)checkTheListToDeleteENtry;
@end
