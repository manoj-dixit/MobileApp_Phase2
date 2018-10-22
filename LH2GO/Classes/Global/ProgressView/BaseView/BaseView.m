//
//  BaseView.m
//  Sample Project
//
//  Created by Sumit Kumar on 13/06/14.
//  Copyright (c) 2014 Kiwitech. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

+(instancetype)viewFromNib
{
    NSString *className = NSStringFromClass([self class]);
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    return [xib objectAtIndex:0];
}

+(instancetype)viewFromNibAtIndex:(NSInteger)index
{
    NSString *className = NSStringFromClass([self class]);
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    return [xib objectAtIndex:index];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

-(void)setupView{}

@end
