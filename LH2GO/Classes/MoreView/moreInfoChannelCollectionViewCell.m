//
//  moreInfoChannelCollectionViewCell.m
//  LH2GO
//
//  Created by Sonal on 06/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "moreInfoChannelCollectionViewCell.h"

@implementation moreInfoChannelCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _moreInfoChannelImage.layer.cornerRadius= _moreInfoChannelImage.frame.size.width/2;
    _moreInfoChannelImage.layer.masksToBounds =  YES;
    _infoButton.layer.cornerRadius= _infoButton.frame.size.width/2;
    _infoButton.layer.masksToBounds =  YES;
    _infoButton.hidden = YES;

}

- (IBAction)infoButtonClicked:(UIButton *)sender
{
    if ([self delegate] && [self.delegate respondsToSelector:@selector(crossButtonTappedOnAllChannelsCell:withAccessibilityHint:)])
    {
        [self.delegate crossButtonTappedOnAllChannelsCell:sender withAccessibilityHint:sender.accessibilityHint];
    }

}
@end
