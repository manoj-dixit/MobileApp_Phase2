//
//  PlotUserView.m
//  LH2GO
//
//  Created by Prakash Raj on 03/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "PlotUserView.h"
#import "User.h"
#import "UIView+Extra.h"


@interface PlotUserView ()
{
    __weak IBOutlet UIImageView *_imgView;
    __weak IBOutlet UILabel *_nmLbl;
}
@end

@implementation PlotUserView

-(void)baseInit
{
    // add xib
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PlotUserView" owner:self options:nil];
    PlotUserView *vv = [topLevelObjects objectAtIndex:0];
    vv.frame = self.bounds;
    [self addSubview:vv];
    [_imgView roundCorner:5 border:0 borderColor:[UIColor lightGrayColor]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder]))
    {
        [self baseInit];
    }
    return self;
}

- (void)showUserLoc:(User *)user uId:(NSString *)uId
{
    _userId = uId;
    if (user)
    {
        _nmLbl.text = (user.user_name.length) ? user.user_name : @"Unknown";
        [_imgView sd_setImageWithURL:[NSURL URLWithString:user.picUrl]placeholderImage:_imgView.image];
    }
    else
    {
         _nmLbl.text = @"Unknown";
    }
}

- (void)showName:(NSString *)name
{
    _nmLbl.text = name;
}

#pragma mark - Touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectUserWithId:)])
        [_delegate didSelectUserWithId:self.userId];
}

@end
