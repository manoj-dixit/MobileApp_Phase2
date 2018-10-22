//
//  FilterView.m
//  LH2GO
//
//  Created by Parul Mankotia on 04/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "FilterView.h"
#define kWidth 10
#define kHeight 20
#define kConstant 10

@implementation FilterView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"FilterView" owner:self options:nil] objectAtIndex:0];
        self.frame = frame;
    }
    [self initialiseDataComponents];
    [self initialiseFilterViewUI];
    return self;
}

-(void)initialiseDataComponents{
    filterDataArray = [[NSMutableArray alloc] init];// This will contain the filters to be added.
}

-(void)initialiseFilterViewUI{
    _clearAllButton.layer.borderColor = [Common colorwithHexString:@"85BD40" alpha:1.0].CGColor;
    _clearAllButton.layer.borderWidth=1.0;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTappedGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    _applyButton.layer.cornerRadius = 2;
    NSArray *dataArray = [NSArray arrayWithObjects:@"Breakfast", @"Lunch", @"Dinner", @"Bars", @"Foods", @"Others", @"Cafe", @"Wellness", @"Nearby", nil];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    CGFloat xPosition = kWidth;
    CGFloat yPosition = kHeight;
    for (NSString *tempString in dataArray) {
        UIButton *filtersButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = [[[NSAttributedString alloc] initWithString:tempString attributes:attributes] size].width + 30;
        NSInteger scrollViewWidth = self.frame.size.width - 20;
        if (xPosition + width + kConstant > scrollViewWidth) {
            _filterDataScrollView.contentSize = CGSizeMake(0, _filterDataScrollView.frame.size.height + kConstant);
            xPosition = kWidth;
            yPosition = yPosition + 40;
        }
        filtersButton.frame = CGRectMake(xPosition, yPosition, width, 30);
        filtersButton.layer.cornerRadius = 15;
        filtersButton.layer.borderWidth = 1.0f;
        filtersButton.layer.borderColor = [UIColor whiteColor].CGColor;
        xPosition = xPosition + width + kConstant;
        [filtersButton setTitle:tempString forState:UIControlStateNormal];
        [filtersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        filtersButton.titleLabel.font = font;
        [filtersButton addTarget:self action:@selector(filtersClickedAction:) forControlEvents:UIControlEventTouchUpInside];
        [_filterDataScrollView addSubview:filtersButton];
    }
}

-(void)viewTappedGesture:(UITapGestureRecognizer*)tapGesture{
    [self removeFromSuperview];
}

-(IBAction)closeButtonAction:(UIButton*)sender
{
    [self removeFromSuperview];
}

-(IBAction)applyButtonAction:(UIButton*)sender
{
    NSLog(@"%@",filterDataArray);
    [self removeFromSuperview];
}

-(void)filtersClickedAction:(UIButton*)sender{
    if (sender.selected == NO) {
        sender.selected = YES;
        [sender setBackgroundColor:[UIColor whiteColor]];
        [sender setTitleColor:[UIColor colorWithRed:(44.0f/255.0f) green:(43.0f/255.0f) blue:(48.0f/255.0f) alpha:1.0] forState:UIControlStateNormal];
        [filterDataArray addObject:sender.titleLabel.text];
    }
    else{
        sender.selected = NO;
        [sender setBackgroundColor:[UIColor colorWithRed:(44.0f/255.0f) green:(43.0f/255.0f) blue:(48.0f/255.0f) alpha:1.0]];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [filterDataArray removeObject:sender.titleLabel.text];
    }
}

-(IBAction)clearAllButtonAction:(UIButton*)sender{
    [filterDataArray removeAllObjects];
}

@end
