//
//  ChanelTableViewCell.h
//  LH2GO
//
//  Created by Linchpin on 6/17/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"

@protocol ChanelTableCellDelegate<NSObject>
-(void)chanelImageTapped:(ChannelDetail*)chanelCell;
@end

@interface ChanelTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *chanelImage;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *img_animated;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;
@property (weak, nonatomic) IBOutlet UIButton *loadmoreBtn;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *coolLbl;
@property (strong, nonatomic) IBOutlet UILabel *contactLbl;
@property (strong, nonatomic) IBOutlet UILabel *shareLbl;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property  (weak, nonatomic) IBOutlet UIView  *coolUserTapView;
@property  (weak, nonatomic) IBOutlet UIImageView  *coolImageView;
@property (weak, nonatomic) IBOutlet UIView *contactUserTapView;
@property (weak,nonatomic) IBOutlet UIImageView *contactImageView;
@property (strong, nonatomic) ChannelDetail *currentContentDetail;
@property (weak,nonatomic) id<ChanelTableCellDelegate>delegate;

@end



