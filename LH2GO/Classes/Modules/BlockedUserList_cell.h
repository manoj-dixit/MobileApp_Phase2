//
//  BlockedUserList_cell.h
//  LH2GO
//
//  Created by Linchpin on 26/09/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockedUserList_cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_onCell;
@property (weak, nonatomic) IBOutlet UILabel *label_onCell;
@property (weak, nonatomic) IBOutlet UIButton *btn_onCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgWidth;
@end
