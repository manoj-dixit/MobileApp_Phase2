//
//  MoreChannelCollectionViewCell.m
//  LH2GO
//
//  Created by Sonal on 06/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "MoreChannelCollectionViewCell.h"

@implementation MoreChannelCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _channelImageIcon.layer.cornerRadius= _channelImageIcon.frame.size.width/2;
    _channelImageIcon.layer.masksToBounds =  YES;
    
    _crossButton.layer.cornerRadius= _crossButton.frame.size.width/2;
    _crossButton.layer.masksToBounds =  YES;
}

- (IBAction)crossButtonClicked:(id)sender
{
    
}
@end
