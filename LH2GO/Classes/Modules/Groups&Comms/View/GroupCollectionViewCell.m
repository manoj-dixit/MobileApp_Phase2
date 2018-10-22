//
//  GroupCollectionViewCell.m
//  LH2GO
//
//  Created by Prakash Raj on 09/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "GroupCollectionViewCell.h"
#import "UIView+Extra.h"
#import "BadgeView.h"

@interface GroupCollectionViewCell () {
    
    __weak IBOutlet UIImageView *_imgV;
    __weak IBOutlet UILabel *_nmLbl;
}

@end


@implementation GroupCollectionViewCell

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupCollectionViewCell" owner:self options:nil];
        UIView *vv = [topLevelObjects objectAtIndex:0];
        vv.backgroundColor = [UIColor clearColor];
        vv.frame = self.bounds;
        [self.contentView addSubview:vv];
        [self updateFrame];
        [_imgV roundCorner:7 border:1 borderColor:kColor(140, 198, 63, 1.0)];
        [self shoudAddRedView:NO];
    }
    return self;
}

- (void)updateFrame{
    CGRect rect = _imgV.frame;
    rect.size.height=rect.size.width;
    _imgV.frame = rect;
    rect = _nmLbl.frame;
    rect.origin.y = _imgV.frame.size.height-1;
    _nmLbl.frame = rect;
    
    //increase 3 pix y
     //bug S5.020
    _nmLbl.frame = CGRectMake(rect.origin.x, rect.origin.y + 3, rect.size.width, rect.size.height);
}

- (void)showGroup:(Group *)gr {
    
    DLog(@"%@",gr);
    _nmLbl.text = gr.grName;
    
    _imgV.image = nil;
    
    if (gr.picUrl.length>0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imgV sd_setImageWithURL:[NSURL URLWithString:gr.picUrl]
                     placeholderImage:[UIImage imageNamed:placeholderGroup]];
        });
       
    }
    
    [self shoudAddRedView:NO];
    [self updateBadge:gr.badge.integerValue];
}
//kColor(255, 255, 255, 1);
- (void)shoudAddRedView:(BOOL)add {

    UIColor *clr = add ? [UIColor redColor] : kColor(140, 198, 63, 1.0);
    [_imgV roundCorner:7 border:1 borderColor:clr];
    
    UIColor *clrForLabel = add ? [UIColor redColor] : kColor(255, 255, 255, 1.0f);//bug S5.020
    _nmLbl.textColor = clrForLabel;////S5.020
    
    UIView *vv = [self viewWithTag:1002];
    if (vv) {
        if (add) return;
        [vv removeFromSuperview];
        
    } else {
        if (!add) return;
        CGRect fr = _imgV.bounds;
        fr.origin.x -= 1;
        fr.origin.y -= 1;
        fr.size.height += 2;
        fr.size.width += 2;
        
        vv = [[UIView alloc] initWithFrame:fr];
        vv.backgroundColor = [UIColor redColor];
        [_imgV addSubview:vv];
        vv.tag = 1002;
    }
}

- (void)updateBadge:(NSInteger)b
{
    [BadgeView addBadge:b toView:_imgV.superview inCorner:badgeCorner_TopRight marginX:-3 marginY:-3];
}

@end
