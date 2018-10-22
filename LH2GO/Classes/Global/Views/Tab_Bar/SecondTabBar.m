//
//  SecondTabBar.m
//  LH2GO
//
//  Created by Techbirds on 11/12/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "SecondTabBar.h"
#import "BadgeView.h"


@interface SecondTabBar ()
{
    __weak IBOutlet UIButton *_buttonItem1;
    __weak IBOutlet UIButton *_buttonItem2;
    __weak IBOutlet UIButton *_buttonItem3;
    __weak IBOutlet UIButton *_buttonItem4; 
    IBOutlet UIImageView *lineImg;
}

@property (nonatomic, assign) BarItem selectedItemTag;

@end

@implementation SecondTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"SecondTabBar" owner:self options:nil];
        UIView *mainView = (UIView *)[nibs objectAtIndex:0];
        [self addSubview:mainView];
        [mainView setFrame:self.bounds];
        //[self checkFrame];
    }
    return self;
}

- (void)checkFrame
{
    CGFloat ww = self.bounds.size.width/5.0;
    CGFloat hh = self.bounds.size.height;
    CGFloat xx = 0;
    _buttonItem1.frame = CGRectMake(xx, 0, ww, hh);
    xx += ww;
    _buttonItem2.frame = CGRectMake(xx, 0, ww, hh);
    xx += ww;
    _buttonItem3.frame = CGRectMake(xx, 0, ww, hh);
    xx += ww;
    _buttonItem4.frame = CGRectMake(xx, 0, ww, hh);
}

+ (SecondTabBar *)secondTabbarWithFrame:(CGRect)frame andSelectedTag:(BarItem)tag
{
    SecondTabBar *tabbar = [[SecondTabBar alloc] initWithFrame:frame];
    [tabbar secondtabButton:tag];
   // [tabbar setSelectedItemTag:tag];
    return tabbar;
}

- (void)setSelectedItemTag:(BarItem)selectedItemTag
{
    [_buttonItem1 setSelected:(selectedItemTag == BarItem_Notification)];
    [_buttonItem2 setSelected:(selectedItemTag == BarItem_AddGroup)];
    [_buttonItem3 setSelected:(selectedItemTag == BarItem_DeleteGroup)];
    [_buttonItem4 setSelected:(selectedItemTag == BarItem_ManageGroup)];
}

- (void)addSecondTabTarget:(id)target andSelector:(SEL)selector
{
    [_buttonItem1 addTarget : target action : selector
           forControlEvents : UIControlEventTouchUpInside];
    [_buttonItem2 addTarget : target action : selector
           forControlEvents : UIControlEventTouchUpInside];
    [_buttonItem3 addTarget : target action : selector
           forControlEvents : UIControlEventTouchUpInside];
    [_buttonItem4 addTarget : target action : selector
           forControlEvents : UIControlEventTouchUpInside];
}

- (void)checkSecondTabBadges
{
    //    [BadgeView addBadge:20 toView:_buttonItem1 inCorner:badgeCorner_TopDefault marginX:0 marginY:6];
}

- (void)setLineColor:(NSInteger)selectedItemTag
{
    switch (selectedItemTag)
    {
        case 5:
        {
            [lineImg setImage:[UIImage imageNamed:@"lightgreen.png"]] ;
        }break;
        case 1:
        {
            [lineImg setImage:[UIImage imageNamed:@"orangeline.png"]] ;
        } break;
        case 2:
        {
            [lineImg setImage:[UIImage imageNamed:@"yellowline.png"]];
        } break;
        case 3:
        {
            [lineImg setImage:[UIImage imageNamed:@"blueline.png"]];
        } break;
        case 4:
        {
            [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]];
        } break;
        default: break;
    }
}

- (void)secondtabButton:(BarItem)selectedItemTag
{
    // BarItemTag option = (BarItemTag)selectedItemTag;
    switch (selectedItemTag)
    {
        case BarItem_Notification:
        {
            [_buttonItem1 setImage:[UIImage imageNamed:@"notificationcolor.png"] forState:UIControlStateNormal];
            [lineImg setImage:[UIImage imageNamed:@"lightgreen.png"]] ;
        } break;
        case BarItem_AddGroup:
        {
            [_buttonItem2 setImage:[UIImage imageNamed:@"addgroupcolor.png"] forState:UIControlStateNormal];
            [lineImg setImage:[UIImage imageNamed:@"darkgreenline.png"]] ;
        } break;
        case BarItem_DeleteGroup:
        {
            [lineImg setImage:[UIImage imageNamed:@"redline.png"]];
            [_buttonItem3 setImage:[UIImage imageNamed:@"deletegroupcolor.png"] forState:UIControlStateNormal];
        } break;
        case BarItem_ManageGroup:
        {
            [lineImg setImage:[UIImage imageNamed:@"lightorange.png"]];
            [_buttonItem4 setImage:[UIImage imageNamed:@"managegroupcolor.png"] forState:UIControlStateNormal];
        } break;
        default: break;
    }
}

@end
