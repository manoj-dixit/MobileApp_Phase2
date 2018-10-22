//
//  CutomPopOverView.m
//  LH2GO
//
//  Created by Parul Mankotia on 13/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "CustomPopOverView.h"

@implementation CustomPopOverView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"CustomPopOverView" owner:self options:nil] objectAtIndex:0];
        self.frame = frame;
    }
    [self initializeViews];
    return self;
}

-(void)initializeViews{
    _exitGroupLabel.layer.cornerRadius =  _exitGroupLabel.frame.size.width/2;
    _exitGroupLabel.layer.masksToBounds = YES;

    _deleteGroupLabel.layer.cornerRadius = _deleteGroupLabel.frame.size.width/2;
    _manageGroupLabel.layer.cornerRadius = _deleteGroupLabel.frame.size.width/2;
    _deleteGroupLabel.layer.masksToBounds = YES;
    _manageGroupLabel.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnViewAction:)];
    [self addGestureRecognizer:tapGesture];
}

-(IBAction)exitGroupButtonAction:(UIButton*)sender{
    if ([self delegate] && [self.delegate respondsToSelector:@selector(sendBackSelectedRowForCell:withRow:)]) {
        [self.delegate sendBackSelectedRowForCell:@"Exit" withRow:_indexPathForRow];
    }
}

-(IBAction)deleteGroupButtonAction:(UIButton*)sender{
    if ([self delegate] && [self.delegate respondsToSelector:@selector(sendBackSelectedRowForCell:withRow:)]) {
        [self.delegate sendBackSelectedRowForCell:@"Delete" withRow:_indexPathForRow];
    }
}

-(IBAction)manageGroupButtonAction:(UIButton*)sender{
    if ([self delegate] && [self.delegate respondsToSelector:@selector(sendBackSelectedRowForCell:withRow:)]) {
        [self.delegate sendBackSelectedRowForCell:@"Manage" withRow:_indexPathForRow];
    }
}

-(void)tapOnViewAction:(UITapGestureRecognizer*)tapGesture{
    [self removeFromSuperview];
}

@end
