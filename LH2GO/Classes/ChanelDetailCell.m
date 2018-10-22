//
//  ChanelDetailCell.m
//  LH2GO
//
//  Created by VVDN on 11/10/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "ChanelDetailCell.h"

@implementation ChanelDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _txtView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    _lblText.font = [_lblText.font fontWithSize:[Common setFontSize:_lblText.font]];
    _dateLabel.font = [_dateLabel.font fontWithSize:[Common setFontSize:_dateLabel.font]];
    
    _txtView.font = [_txtView.font fontWithSize:[Common setFontSize:_txtView.font]];
   // _reportBtn.titleLabel.font = [_reportBtn.titleLabel.font fontWithSize:[Common setFontSize:_reportBtn.titleLabel.font]];
    
    _txtView.textContainerInset = UIEdgeInsetsMake(0, 5, 0, 5); //(top,left, bottom, right) /
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
