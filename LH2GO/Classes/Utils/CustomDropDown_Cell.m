//
//  CustomDropDown_Cell.m
//  LH2GO
//
//  Created by VVDN on 01/11/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "CustomDropDown_Cell.h"

@implementation CustomDropDown_Cell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _lblOption.font = [_lblOption.font fontWithSize:[Common setFontSize:_lblOption.font]];
    _btnOption.titleLabel.font = [_btnOption.titleLabel.font fontWithSize:[Common setFontSize:_btnOption.titleLabel.font]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
