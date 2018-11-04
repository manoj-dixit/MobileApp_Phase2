//
//  ChannelDetailViewController.h
//  LH2GO
//
//  Created by Parul Mankotia on 28/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelDetailCell.h"

@interface ChannelDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,ChannelDetailCellDelegate>

@property(nonatomic, weak) IBOutlet UIImageView *channelImageView;
@property(nonatomic, weak) IBOutlet UILabel *channelNameLabel;
@property(nonatomic, weak) IBOutlet UIButton *channelInformationButton;
@property(nonatomic, weak) IBOutlet UILabel *favoriteChannelLabel;
@property(nonatomic, weak) IBOutlet UITableView *channelFeedTableView;
@property(nonatomic, strong) Channels *channelSelected;
@property(nonatomic, strong) ChannelDetail *channelFeedSelected;

-(void)chanelImageTappedOnCell:(ChannelDetail*)channelDetail;
-(void)saveTappedForChannelImageOnCell:(ChannelDetail*)channelDetail;
- (void)refreshData;

@end
