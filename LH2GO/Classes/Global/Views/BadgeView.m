//
//  BadgeView.m
//  LH2GO
//
//  Created by Prakash Raj on 10/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "BadgeView.h"

#define k_BADGE_VIEW_TAG   299999

@interface BadgeView ()
@property (nonatomic, strong) UILabel *bLbl;

@end

@implementation BadgeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        _bLbl = [[UILabel alloc] initWithFrame:self.bounds];
        _bLbl.backgroundColor = [UIColor clearColor];
        _bLbl.text = @"";
        _bLbl.textAlignment = NSTextAlignmentCenter;
        _bLbl.textColor = [UIColor whiteColor];
        _bLbl.font = [UIFont fontWithName:@"Aileron-SemiBold" size:9];
        if (IPAD){
            _bLbl.font = [UIFont fontWithName:@"Aileron-SemiBold" size:10];
        }
        [self addSubview:_bLbl];
    }
    self.backgroundColor = [Common colorwithHexString:TopBarTitlecolor alpha:1];
    self.tag = k_BADGE_VIEW_TAG;
    self.layer.cornerRadius = frame.size.height/2.0;
    self.clipsToBounds = YES;
    //self.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.layer.borderWidth = 1;
    return self;
}


#pragma mark - Public methods

+ (void)addBadge: (NSInteger)badge toView: (UIView *)vv
        inCorner: (badgeCorner)corner
         marginX: (NSInteger)marX marginY: (NSInteger)marY
{
    if (badge == 0)
    {
        [BadgeView removeFromView:vv]; // no requirement
        return;
    }
    if ([BadgeView containedBy:vv])
    {
        BadgeView *bView = (BadgeView *) [vv viewWithTag:k_BADGE_VIEW_TAG];
        [bView updateBadge:badge];
    }
    else
    {
        CGSize sz = CGSizeMake(15, 15);
        
        if (IPAD){
            sz = CGSizeMake(18, 18);
        }
        
        CGRect fr = CGRectMake(marX, marY,  sz.width, sz.height);
        if (corner == badgeCorner_TopRight)
        {
            if (IPAD){
                fr.origin.y -=5 ;
            }
            fr.origin.x = vv.bounds.size.width - sz.width-marX;
        }else if (corner == badgeCorner_BottomLeft){
            fr.origin.y = vv.bounds.size.height - sz.height-marY;
        } else if (corner == badgeCorner_BottomRight){
            fr.origin.x = vv.bounds.size.width - sz.width-marX;
            fr.origin.y = vv.bounds.size.height - sz.height-marY;
        }
        
        BadgeView *bView = [[BadgeView alloc] initWithFrame:fr];
        [vv addSubview:bView];
        [bView updateBadge:badge];
    }
}

+ (BOOL)containedBy:(UIView *)vv
{
    return ([vv viewWithTag:k_BADGE_VIEW_TAG] != nil);
}

+ (void)removeFromView:(UIView *)vv
{
    if ([BadgeView containedBy:vv])
    {
        BadgeView *bView = (BadgeView *) [vv viewWithTag:k_BADGE_VIEW_TAG];
        [bView removeFromSuperview];
    }
}

- (void)updateBadge:(NSInteger)badge
{
    _bLbl.text = [NSString stringWithFormat:@"%li", (long)badge];
    CGRect fr = self.frame;
    NSInteger preW = fr.size.width;
    
    if (IPAD)
        fr.size.width = (badge >= 100) ? 28:18;
    else
        fr.size.width = (badge >= 100) ? 25:15;
    
    //for font
   /* CGFloat fontSize;
    if (IPAD)
        fontSize= (badge >= 100) ? 8:10;
    else
        fontSize= (badge >= 100) ? 6:8;
    _bLbl.font = [UIFont fontWithName:@"Aileron-SemiBold" size:fontSize]; */
    
    NSInteger marX = fr.size.width - preW;
    fr.origin.x -= marX;
    self.frame = fr;
    _bLbl.frame = self.bounds;
}

@end
