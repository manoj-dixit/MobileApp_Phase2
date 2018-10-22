//
//  CreateChannelFeedVC.h
//  LH2GO
//
//  Created by VVDN on 30/10/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDropDownView.h"

@interface CreateChannelFeedVC : UIViewController<DropDownDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblFeed;
@property(strong,nonatomic)CustomDropDownView *dropDown;

@end
