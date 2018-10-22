//
//  MenuTableViewCell.h
//  LH2GO
//
//  Created by Linchpin on 6/16/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
@interface MenuTableViewCell : UITableViewCell

    @property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelIcon;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end
