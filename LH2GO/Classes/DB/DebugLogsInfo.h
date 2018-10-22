//
//  DebugLogsInfo.h
//  LH2GO
//
//  Created by Manoj Dixit on 17/07/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DebugLogsInfo : NSManagedObject

// unqiue id of the message
@property (nonatomic,retain) NSString  *msgUniqueID;
// buki-box id if connected
@property (nonatomic,retain) NSString  *bukiBoxID;
// Id Of the message
@property (nonatomic,retain) NSString *messageID;
// channel ID of the associated message if data is for the channel
@property (nonatomic,retain) NSString  *channelID;
// group id of the associate message if data is for the group
@property (nonatomic,retain) NSString  *groupID;

// type of the message
// 1. CMS Data
// 2. CHannel Data
// 3. IPhone Data
@property (nonatomic,retain) NSString  *messageType;

// type of the data
// 1. Text
// 2. Image
// 3. Gif
// 4. Text+Image
// 5. Text+Gif
@property (nonatomic,retain) NSString  *typeOfData;

// device role - In which mode device is working
// 1. Master
// 2. Slave
@property (nonatomic,retain) NSString  *deviceRole;

// ID of the first device that is connected
@property (nonatomic,retain) NSString  *deviceID1;
// ID of the second device that is connected
@property (nonatomic,retain) NSString  *deviceID2;
// ID of the third device of that is connected
@property (nonatomic,retain) NSString  *deviceID3;
// timestamp
@property (nonatomic,retain) NSNumber  *timeStamp;

// size of the data in case of
// 1. Image
// 2. Gif
@property (nonatomic,retain) NSNumber  *sizeOfData;

// Number of the packets of the message
@property (nonatomic,retain) NSNumber  *numberOfPackets;

// event of the message to explain the current status of the message
@property (nonatomic,retain) NSString  *event;

@end
