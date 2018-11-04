//
//  ChannelDetailCell.h
//  LH2GO
//
//  Created by Parul Mankotia on 02/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChannelDetailCellDelegate<NSObject>
-(void)refreshData;
-(void)chanelImageTappedOnCell:(ChannelDetail*)channelDetail;
-(void)saveTappedForChannelImageOnCell:(ChannelDetail*)channelDetail;

@end

@interface ChannelDetailCell : UITableViewCell<APICallProtocolDelegate>{
    SharedUtils *sharedUtils;
}
@property(nonatomic, weak) IBOutlet UIImageView *channelIconImageView;
@property(nonatomic, weak) IBOutlet UILabel *channelNameLabel;
@property(nonatomic,weak) IBOutlet UITextView *channelDescriptionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightContraint;
@property(weak, nonatomic) IBOutlet UILabel *dateTextLabel;
@property(weak, nonatomic) IBOutlet UIButton *reportButton;
@property(weak, nonatomic) IBOutlet UIImageView *channelFeedImageView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *channelFeedAnimatedImageView;
@property(weak, nonatomic) IBOutlet UILabel *coolColorLabel;
@property(weak, nonatomic) IBOutlet UILabel *coolNumberLabel;
@property(weak, nonatomic) IBOutlet UIView *coolView;
@property(weak, nonatomic) IBOutlet UILabel *contactColorLabel;
@property(weak, nonatomic) IBOutlet UILabel *contactNumberLabel;
@property(weak, nonatomic) IBOutlet UIView *contactView;
@property(weak, nonatomic) ChannelDetail *channelDetail;
@property(weak, nonatomic) IBOutlet UILabel *scheduledLabel;



-(IBAction)reportAbuseButton:(UIButton*)sender;

+ (instancetype)cellAtIndex:(NSInteger)index;

@property (weak,nonatomic) id<ChannelDetailCellDelegate>delegate;

@end
