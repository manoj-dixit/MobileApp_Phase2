//
//  NotificationInfo.h
//  LH2GO
//
//  Created by Sumit Kumar on 01/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

// - This Model is create to store basic info of Notification to show on The UI

#import <Foundation/Foundation.h>
@import UIKit;

typedef NS_ENUM(NSInteger, NotfType) {
    NotfType_unknown = 0,
    NotfType_newMember,
    NotfType_quitMember,
    NotfType_groupDeleted,
    NotfType_groupInvite,
    NotfType_adminMessage,
    NotfType_groupUpdate,
    NotfType_nonAdmingroupInvite,
    NotfType_adminApproval,
    NotfType_UserRequest
};

typedef NS_ENUM(NSInteger, NotfStatus) {
    NotfStatusNone = 0,
    NotfStatusAccepted,
    NotfStatusRejected
};

@interface NotificationInfo : NSObject
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *notfId;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSInteger timeStamp;
@property (nonatomic,strong) NSString *tempGrId;
@property (nonatomic,strong) NSString *tempGrName;
@property (nonatomic,strong) NSString *tempNetId;
@property (nonatomic,strong) NSString *tempGrpPic;
@property (nonatomic,strong) NSString *tempniD;
@property (nonatomic, strong) User *sender;
@property (nonatomic, strong) Network *network;
@property (nonatomic, strong) Group *group;
@property (nonatomic, assign) NotfStatus status;

// token for p2p contact accept and reject
@property (nonatomic,strong) NSString *p2pToken;


- (BOOL)isActionAvailable;
+ (void)parseResponse:(NSDictionary *)resp;
+ (NotificationInfo *)notWithDict:(NSDictionary *)dict;
+ (void)clearNotifications;
- (void)addGroupIfUserAcceptRequest;

@end

