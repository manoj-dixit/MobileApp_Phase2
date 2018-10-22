//
//  AttachmentOptionView.m
//  LH2GO
//
//  Created by Linchpin on 25/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "AttachmentOptionView.h"

@interface AttachmentOptionView ()
{
    __weak IBOutlet UIButton *_buttonItem1;
    __weak IBOutlet UIButton *_buttonItem2;
    __weak IBOutlet UIButton *_buttonItem3;
    __weak IBOutlet UIButton *_buttonItem4;
}


@end

@implementation AttachmentOptionView


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"AttachmentOptionView" owner:self options:nil];
        UIView *mainView = (UIView *)[nibs objectAtIndex:0];
        [self addSubview:mainView];
        [mainView setFrame:self.bounds];
        [self checkFrame];
        
        if (IPAD)
            [self setFontSize];
    }
    return self;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
}
-(void)setFontSize{
    if (!(IPAD)){
    _lbl_tab0.font = [_lbl_tab0.font fontWithSize:[Common setFontSize:_lbl_tab0.font]];
    _lbl_tab1.font = [_lbl_tab1.font fontWithSize:[Common setFontSize:_lbl_tab1.font]];
    _lbl_tab2.font = [_lbl_tab2.font fontWithSize:[Common setFontSize:_lbl_tab2.font]];
    _lbl_tab3.font = [_lbl_tab3.font fontWithSize:[Common setFontSize:_lbl_tab3.font]];
    }
    _lblIcon_tab0.font = [_lblIcon_tab0.font fontWithSize:_lblIcon_tab0.font.pointSize + 2];
    _lblIcon_tab1.font = [_lblIcon_tab1.font fontWithSize:_lblIcon_tab1.font.pointSize + 2];
    _lblIcon_tab2.font = [_lblIcon_tab2.font fontWithSize:_lblIcon_tab2.font.pointSize + 2];
    _lblIcon_tab3.font = [_lblIcon_tab3.font fontWithSize:_lblIcon_tab3.font.pointSize + 2];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)checkFrame
{
    if(IS_IPHONE_4_OR_LESS)
    {
        DLog(@"IS_IPHONE_4_OR_LESS");
    }
    if(IS_IPHONE_5)
    {
        DLog(@"IS_IPHONE_5");
    }
    else
    {
        //        _nsConstraint.constant = 48;
        //        _sbConstarint.constant = 55;
    }
}


+ (AttachmentOptionView *)tabbarWithFrame:(CGRect)frame {
    AttachmentOptionView *tabbar = [[AttachmentOptionView alloc] initWithFrame:frame];
    //[tabbar tabButton:tag];
    return tabbar;
}

- (void)addTarget:(id)target andSelector:(SEL)selector
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
