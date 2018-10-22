//
//  MenuTableViewCell.m
//  LH2GO
//
//  Created by Linchpin on 6/16/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell
@synthesize contentView;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView.layer setCornerRadius:5];
    [self.contentView.layer setMasksToBounds:YES];
    
    _labelIcon.font = [_labelIcon.font fontWithSize:15];
    _labelName.font = [_labelName.font fontWithSize:15];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
