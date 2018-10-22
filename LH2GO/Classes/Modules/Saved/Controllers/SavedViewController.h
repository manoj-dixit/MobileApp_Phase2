//
//  SavedViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 05/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SavedViewController : BaseViewController
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick;
@end
