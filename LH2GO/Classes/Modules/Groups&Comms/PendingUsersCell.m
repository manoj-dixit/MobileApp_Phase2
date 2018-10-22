//
//  PendingUsersCell.m
//  LH2GO
//
//  Created by Linchpin on 28/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "PendingUsersCell.h"

@interface PendingUsersCell(){
     User *tempUser;
}

@end


@implementation PendingUsersCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _userImg.layer.cornerRadius =_userImg.frame.size.width/2;
    _userImg.layer.masksToBounds = YES;
    
    _usrName.textColor = [UIColor whiteColor];
    //setFontSize
     _usrName.font = [_usrName.font fontWithSize:[Common setFontSize:_usrName.font]];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displayUser:(User *)user
{
    tempUser = user;
    _usrName.text = user.user_name;
    if(!user.picUrl) {
        _userImg.backgroundColor = [UIColor yellowColor];
    }
    else{
        [_userImg sd_setImageWithURL:[NSURL URLWithString:user.picUrl]placeholderImage:[UIImage imageNamed:placeholderUser]];
    }
}

@end
