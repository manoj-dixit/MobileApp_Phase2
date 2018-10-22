//
//  MsgPreviewCell.m
//  LH2GO
//
//  Created by Linchpin on 31/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "MsgPreviewCell.h"

@implementation MsgPreviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _view_msgPrev.layer.cornerRadius = 4.0;
    _view_msgPrev.layer.masksToBounds = true;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
