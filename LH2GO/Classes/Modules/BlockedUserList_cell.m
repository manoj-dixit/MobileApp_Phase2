//
//  BlockedUserList_cell.m
//  LH2GO
//
//  Created by Linchpin on 26/09/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "BlockedUserList_cell.h"

@implementation BlockedUserList_cell
@synthesize img_onCell;
- (void)awakeFromNib {
    [super awakeFromNib];
    
    CGRect frame ;
    frame = [Common adjustRoundShapeFrame:img_onCell.frame];
    _userImgHeight.constant = frame.size.height;
    _userImgWidth.constant = frame.size.width ;
    _btn_onCell.layer.cornerRadius = 12.0f*kRatio;

    img_onCell.layer.cornerRadius = img_onCell.frame.size.width * kRatio/2;
    img_onCell.layer.masksToBounds = true;
    _label_onCell.font = [_label_onCell.font fontWithSize:[Common setFontSize:_label_onCell.font]];
    _btn_onCell.titleLabel.font = [_btn_onCell.titleLabel.font fontWithSize:[Common setFontSize:_btn_onCell.titleLabel.font]];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
