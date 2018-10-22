//
//  HeaderCollectionView.m
//  LH2GO
//
//  Created by Prakash Raj on 16/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "HeaderCollectionView.h"

@interface HeaderCollectionView () {
    __weak IBOutlet UILabel *_ttLbl;
    
}
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@end


@implementation HeaderCollectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HeaderCollectionView" owner:self options:nil];
        UIView *vv = [topLevelObjects objectAtIndex:0];
        vv.backgroundColor = [UIColor clearColor];
        vv.frame = self.bounds;
        [self addSubview:vv];        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setTitle:(NSString *)ttl {
    _ttLbl.text = ttl;
}

@end
