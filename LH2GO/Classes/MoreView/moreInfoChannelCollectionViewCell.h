//
//  moreInfoChannelCollectionViewCell.h
//  LH2GO
//
//  Created by Sonal on 06/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface moreInfoChannelCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *moreInfoChannelImage;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoChannelName;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
- (IBAction)infoButtonClicked:(id)sender;

@end
