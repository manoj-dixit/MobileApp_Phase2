//
//  GroupsViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 20/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CommonActions.h"
#import "BaseViewController.h"

@interface GroupsViewController : BaseViewController

+ (void)checkNotificationBadge;
+ (void)refreshGroups;

@property (weak, nonatomic) IBOutlet UITableView *tableMessage;

// on logout..
- (void)refreshStateOnLogout;
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict;
@end
