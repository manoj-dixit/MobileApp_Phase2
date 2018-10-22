//
//  MoreChannelCollectionViewCell.h
//  LH2GO
//
//  Created by Sonal on 06/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreChannelCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *channelImageIcon;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;
- (IBAction)crossButtonClicked:(id)sender;

@end
