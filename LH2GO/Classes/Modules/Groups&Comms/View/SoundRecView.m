//
//  SoundRecView.m
//  LH2GO
//
//  Created by Prakash Raj on 07/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "SoundRecView.h"

@implementation SoundRecView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // add xib
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SoundRecView" owner:self options:nil];
        SoundRecView *vv = [objects objectAtIndex:0];
        vv.frame = self.bounds;
        [self addSubview:vv];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


@end
