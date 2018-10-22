//
//  InviteBtnCell.m
//  LH2GO
//
//  Created by Linchpin on 28/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "InviteBtnCell.h"

@implementation InviteBtnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _lblArrow.font = [_lblArrow.font fontWithSize:[Common setFontSize:_lblArrow.font]];
    _lblInvite.font = [_lblInvite.font fontWithSize:[Common setFontSize:_lblInvite.font]];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
