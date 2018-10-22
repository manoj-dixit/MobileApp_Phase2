//
//  SearchTableViewCell.m
//  LH2GO
//
//  Created by Sonal on 07/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _searchedImageView.layer.cornerRadius= _searchedImageView.frame.size.width /2;
    _searchedImageView.layer.masksToBounds =  YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
