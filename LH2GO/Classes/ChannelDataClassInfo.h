//
//  ChannelDataClassInfo.h
//  LH2GO
//
//  Created by Manoj Dixit on 17/05/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChannelDataClassInfo : NSObject

//++++++++++++++++++++++++++++++++++++++++++++
//Structure :-
//
//'00' => 'Packet_Revision',
//'01' => 'Channel_Id',
//'02' => 'Feed_Id',
//'03' => 'Push_Timestamp',
//'04' => 'App_Display_time',
//'05' => 'Account_Id',
//'06' => 'Feed_Created_Timestamp',
//'07' => 'Feed_Expired_Timestamp',
//'08' => 'Ble_Custom_Alert'
//
//+++++++++++++++++++++++++++++++++++++++++++++

@property (strong,nonatomic) NSString *packetVersion;
@property (strong,nonatomic) NSString *channelID;
@property (strong,nonatomic) NSString *feedID;
@property (strong,nonatomic) NSString *pushTimeStamp;
@property (strong,nonatomic) NSString *appDisplayTime;
@property (strong,nonatomic) NSString *account_ID;
@property (strong,nonatomic) NSString *feedCreatedTime;
@property (strong,nonatomic) NSString *feedExpiredTime;
@property (strong,nonatomic) NSString *bleCustomAlert;

@property (strong,nonatomic) NSString *textMessage;
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) NSData *imgData;
@property (strong,nonatomic) NSString *msgType;
@property (strong,nonatomic) NSString *contentID;
@property (assign) BOOL isBLEContent;
@property NSUInteger sizeOFImageData;
@property (strong,nonatomic) NSString *mediaPath;
@property (assign) BOOL isForeverFeed;

-(id)initWithChannelDataStringHavingEncryption:(NSString *)dataString withContentID:(NSString *)contentID isForOldPacketForFomat:(BOOL)isOldPacket;

@end





