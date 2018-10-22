//
//  AdvanceSettingBottomView.m
//  LH2GO
//
//  Created by Linchpin on 06/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "AdvanceSettingBottomView.h"


@interface AdvanceSettingBottomView ()
{
    __weak IBOutlet UIButton *_button;
    __weak IBOutlet UILabel *lbl_SettingIcon;
    __weak IBOutlet UILabel *lbl_SettingText;
    
}@end

@implementation AdvanceSettingBottomView



- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"AdvanceSettingBottomView" owner:self options:nil];
        UIView *mainView = (UIView *)[nibs objectAtIndex:0];
        [self addSubview:mainView];
        [mainView setFrame:self.bounds];
        if (IPAD){
        lbl_SettingIcon.font = [lbl_SettingIcon.font fontWithSize:lbl_SettingIcon.font.pointSize + 2];
            lbl_SettingText.font = [lbl_SettingText.font fontWithSize:lbl_SettingText.font.pointSize + 2];
        }
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    // NSLog(@"%@",_buttonItem1);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    // NSLog(@"%@",_buttonItem1);
}

+ (AdvanceSettingBottomView *)tabbarWithFrame:(CGRect)frame
{
    AdvanceSettingBottomView *tabbar = [[AdvanceSettingBottomView alloc] initWithFrame:frame];
   // [tabbar tabButton:tag];
    return tabbar;
}

- (void)addTarget:(id)target andSelector:(SEL)selector
{
    [_button addTarget : target action : selector
           forControlEvents : UIControlEventTouchUpInside];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
