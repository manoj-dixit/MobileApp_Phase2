//
//  SelectNetworkCell.m
//  LH2GO
//
//  Created by Linchpin on 28/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "SelectNetworkCell.h"

@implementation SelectNetworkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //setFontsize
    _lbl_network.font = [_lbl_network.font fontWithSize:[Common setFontSize:_lbl_network.font]];
    _btnCheck.titleLabel.font = [_btnCheck.titleLabel.font fontWithSize:[Common setFontSize:_btnCheck.titleLabel.font]];
    _btnCheck.userInteractionEnabled = NO;
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
