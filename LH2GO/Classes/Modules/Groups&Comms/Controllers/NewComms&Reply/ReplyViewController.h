//
//  ReplyViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 19/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHMessagingBaseViewController.h"
#import "RelayObject.h"

@class Shout;

@interface ReplyViewController : LHMessagingBaseViewController<RelayListDelegate>
{
    AdvanceSettingBottomView *_advanceSettingBottomView;
}
@property (nonatomic, strong) Shout *pShout;
@property (strong, nonatomic) RelayView *relayView;

-(void)recievedReplyShout:(Shout *)sh;
@end
