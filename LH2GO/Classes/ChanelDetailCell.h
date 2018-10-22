//
//  ChanelDetailCell.h
//  LH2GO
//
//  Created by VVDN on 11/10/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"

@interface ChanelDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtView_height;

@end
