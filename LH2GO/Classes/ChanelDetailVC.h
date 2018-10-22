//
//  ChanelDetailVC.h
//  LH2GO
//
//  Created by VVDN on 11/10/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChanelDetailCell.h"
#import "ChannelDetail.h"

@interface ChanelDetailVC : BaseViewController<UIGestureRecognizerDelegate,UITextViewDelegate>
{
    UITextView *txtvw;
    NSInteger selectedContentIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *tblContent;
@property (nonatomic,strong) NSString *mediaPath;
@property (nonatomic,strong) NSString *dateStr;
@property (nonatomic,strong) NSString *textToBeDisplayed;
@property (nonatomic,strong) NSString *timeDisplay;
@property (nonatomic,strong) Channels *currentChannel;
@property (nonatomic,strong) NSString *mediaType;
@property (nonatomic,strong) ChannelDetail *currentContentDetail;
@property  (nonatomic,strong) NSString *cID;
@property (weak, nonatomic) IBOutlet UILabel *lblFileType;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;
@property (weak, nonatomic) IBOutlet UILabel *lblFileType_Head;
@property (weak, nonatomic) IBOutlet UIView *vwFileInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblHeight;
@property (strong, nonatomic) IBOutlet UILabel *coolCount;
@property (strong, nonatomic) IBOutlet UILabel *contactCount;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UILabel *shareCount;
@property(weak,nonatomic) IBOutlet UIImageView *coolImageView;
@property  (weak, nonatomic) IBOutlet UIView  *coolUserTapView;
@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak,nonatomic) IBOutlet UIView  *contactUserTapView;
@property  (strong, nonatomic) NSNumber* coolNumber;
@property  (strong, nonatomic) NSNumber* shareNumber;
@property  (strong, nonatomic) NSNumber* contactNumber;
@property BOOL isCool;
@property BOOL isShare;
@property BOOL isContact;

@end
