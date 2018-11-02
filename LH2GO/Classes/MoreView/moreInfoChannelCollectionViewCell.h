//
//  moreInfoChannelCollectionViewCell.h
//  LH2GO
//
//  Created by Sonal on 06/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AllChannelsCellDelegate<NSObject>
-(void)crossButtonTappedOnAllChannelsCell:(UIButton*)buttonTapped withAccessibilityHint:(NSString*)hintStirng ;
@end


@interface moreInfoChannelCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *moreInfoChannelImage;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoChannelName;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
- (IBAction)infoButtonClicked:(id)sender;

@property (weak,nonatomic) id<AllChannelsCellDelegate>delegate;

@end
