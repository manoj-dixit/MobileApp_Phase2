//
//  ShoutInfo.h
//  LH2GO
//
//  Created by Prakash Raj on 17/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shout.h"


// the enum is to identifiy type of a shout.
typedef NS_ENUM(NSInteger, ShoutType) {
    ShoutTypeTextMsg = 0,     // text message shout.
    ShoutTypeImage,               // Image shout.
    ShoutTypeAudio,                // audio shout.
    ShoutTypeVideo,                // video shout.
    ShoutTypePingReq,           // ping request.
    ShoutTypePingRes,           // ping response.
    ShoutTypeGif
};



#pragma mark - Interface HeaderShout
@interface ShoutHeader : NSObject
@property (nonatomic, strong) NSString  * shoutId;      // shout id.
@property (nonatomic, strong) NSString  * ownerId;      // composer.
@property (nonatomic, strong) NSString  * groupId;      // group.
@property (nonatomic, strong) NSNumber *cmsDuration;
@property (nonatomic, assign) NSUInteger  totalShoutLength;
@property (nonatomic, assign) ShoutType type;
@property (nonatomic, assign) int typeOfMsgSpecialOne;
@property (nonatomic,strong)  NSString *network_ID;
@property (nonatomic,strong)  NSString *loudHailer_Id;

@property (nonatomic,strong)  NSString *cms_Id;

@property (nonatomic,strong)  NSString *uniqueID;

// To know data is from CMS or iPhone to iPhone
@property (nonatomic, assign) BOOL isMsgFromCMS;
@property (nonatomic, assign) BOOL isP2pMsg;

@end


#pragma mark - Interface BaseShout
@interface BaseShout : NSObject
@property (nonatomic, assign) ShoutType type; // type of shout see the enum ShoutType.
@end

@interface ShoutDetail : BaseShout
@property (nonatomic, strong) NSString  * text;         // text.
@property (nonatomic, strong) NSData    * content;      // content (video/audio).
@property (nonatomic, assign) NSInteger   timestamp;    // originated. when user send the shout
@property (nonatomic, strong) NSString  * parent_shId;  // This id will recognize the shout is reply if id is not nil else original.

// user Name of The user
@property (nonatomic,strong) NSString   *userName;

@property (nonatomic, copy) NSString  * mediaPath;
@end

#pragma mark - Interface ShoutInfoz
@interface ShoutInfo : BaseShout
@property (nonatomic, strong) ShoutHeader *header;
@property (nonatomic, strong) ShoutDetail *shout;

/*!
 * @method : convert a shout to ShoutInfo.
 * @param : sh  - shout object to be converted.
 * @param : binary  - bimnary file for shout if video/audio is attached.
 */
+ (ShoutInfo *)shoutFrom: (Shout *)sh
              binaryData: (NSData *)binary;

/*!
 * @method : compose a shout.
 * @param : text  - text to compose.
 * @param : type  - type of shout (text/audio/video).
 * @param : gId   - group relate for this ahout.
 * @param : pShId - parent id in case it is reply shout.
 * @param : isP2p - p2p Chat  YES else NO
 */
+ (ShoutInfo *)composeText: (NSString *)text
                      type: (ShoutType)type
                   content: (NSData *)content
                   groupId: (NSString *)gId
                parentShId: (NSString *)pShId
                   p2pChat: (BOOL)isP2p;

+ (ShoutInfo *)composeExistingText: (NSString *)text
                              type: (ShoutType)type
                           content: (NSData *)content
                           groupId: (NSString *)gId
                        parentShId: (NSString *)pShId
                           shoutId: (NSString *)shId;
- (void)autoBroadcast;
@end



#pragma mark - Interface Ping
@interface Ping : BaseShout
@property (nonatomic, strong) NSString * shoutId;
@property (nonatomic, strong) NSString * ownerId;       // who requested.

// for response only
@property (nonatomic, strong) NSString * targetPingId;  // ping to be responded.
@property (nonatomic, strong) NSString * responderId;   // responded.
@property (nonatomic, assign) double lat;               // latitude.
@property (nonatomic, assign) double lan;               // longitude.

/*!
 * @method : compose a ping request.
 */
+ (Ping *)pingReq;

/*!
 * @method : compose a ping response for a request.
 * @param : userId  - who is answering.
 * @param : pingId  - for which ping (request) the answer is.
 */
+ (Ping *)responseFor: (NSString *)userId
            andPindId: (NSString *)pingId;
@end

#pragma mark - Interface HeaderShout
@interface ShoutDataReceiver : NSObject
@property (nonatomic, assign) long headerLength;
@property (nonatomic, strong) NSMutableData  * shoutData;      // shout id.
@property (nonatomic, strong) NSMutableArray *packetArray;
@property (nonatomic, strong) NSMutableArray *packetArrayForChannelMsg;
@property (nonatomic, strong) ShoutHeader  * header;
@property (nonatomic, assign) BOOL  isPacketHeaderFound;      // composer.
@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, assign) BOOL  isLastChunk;
@property (nonatomic, assign) BOOL  isAlreadyExist;
@property (nonatomic, assign) BOOL  isFromCMS;
@property (nonatomic, assign) BOOL  doNotForwadIt;
@property (nonatomic,assign)  int firsTnumberTime;
@property (nonatomic,assign)  int secondNumberTime;
@property (nonatomic, assign) BOOL  isGotLastPacket;
@property (nonatomic,assign)  BOOL  isGotPerfectImage;
@property (nonatomic,strong) NSString *cmsID;

@end

@interface ShoutDataSender : NSObject
@property (nonatomic, strong) NSString *shId;
@property (nonatomic, assign) long totalShoutLength;
@property (nonatomic, assign) ShoutType type;
@property (nonatomic, strong) NSData  *shoutData;
@property (nonatomic,assign)   int typeOfMsgSpecialByte;
@property (nonatomic,strong)  NSString *loudHailer_Id;
@property (nonatomic,assign)   int fragmentNO;
@end

