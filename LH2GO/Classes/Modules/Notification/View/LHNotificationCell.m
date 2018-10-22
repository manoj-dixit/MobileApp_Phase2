//
//  LHNotificationCell.m
//  LH2GO
//
//  Created by Sumit Kumar on 01/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHNotificationCell.h"
#import "NotificationInfo.h"
#import "UILabel+Extra.h"
#import "TimeConverter.h"
#import "EventLog.h"

@interface LHNotificationCell ()<UITextViewDelegate,APICallProtocolDelegate>{
    NotificationInfo *notiObj;
  __weak IBOutlet NSLayoutConstraint *vw_HeightConstraint;
}
@end

@implementation LHNotificationCell

+ (instancetype)cellAtIndex:(NSInteger)index
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LHNotificationCell" owner:self options:nil];
    LHNotificationCell *cell = [objects objectAtIndex:index];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    //Font would be set for UI Elements
    [self setfontSize];
    
    _labelMsg.delegate = self;
    
    //Adjust userimage size
    CGRect frame = [Common adjustRoundShapeFrame:_imgView.frame];
    _userImgHeight.constant = frame.size.height;
    _userImgWidth.constant = frame.size.width ;
    _imgView.contentMode =  UIViewContentModeScaleAspectFill;
    _imgView.layer.cornerRadius = _imgView.frame.size.width*kRatio/2;
    _imgView.layer.masksToBounds = true;
    _btnAccept.layer.cornerRadius = 12.0f*kRatio;
    _btnDecline.layer.cornerRadius = 12.0f*kRatio;
    vw_HeightConstraint.constant = vw_HeightConstraint.constant *kRatio;
    newNotifbackgroundLabel.layer.cornerRadius = 12.0f;
    newNotifbackgroundLabel.layer.masksToBounds = YES;
    _labelMsg.autocorrectionType = UITextAutocorrectionTypeNo;
    [_labelMsg sizeToFit];
}

-(void)setfontSize{
    _labelMsg.font = [_labelMsg.font fontWithSize:[Common setFontSize:_labelMsg.font]];
    _lblDateTime.font = [_lblDateTime.font fontWithSize:[Common setFontSize:_lblDateTime.font]];
    _lblUserName.font = [_lblUserName.font fontWithSize:[Common setFontSize:_lblUserName.font]];
    _btnAccept.titleLabel.font = [_btnAccept.titleLabel.font fontWithSize:[Common setFontSize:_btnAccept.titleLabel.font]];
    _btnDecline.titleLabel.font = [_btnDecline.titleLabel.font fontWithSize:[Common setFontSize:_btnDecline.titleLabel.font]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)displayNotification:(NotificationInfo *)info
{
    notiObj = info;
    if (info.sender.user_name.length>0)
    {
        _lblUserName.text = info.sender.user_name;
        [_imgView sd_setImageWithURL:[NSURL URLWithString:info.sender.picUrl] placeholderImage:[UIImage imageNamed:placeholderUser]];
    }
    else{
        if(info.type ==1){
            @try {
                NSString *msg = info.message;
                msg  = [[msg componentsSeparatedByString:@"/"] objectAtIndex:0];
                msg = [msg stringByReplacingOccurrencesOfString:@"<h>" withString:@""];
                msg = [msg stringByReplacingOccurrencesOfString:@"<" withString:@""];
                _lblUserName.text = msg;
                
            } @catch (NSException *exception) {
            } @finally {
            }
            _imgView.image = [UIImage imageNamed:placeholderUser];
        }
        else if (info.type == 20)
        {
            _lblUserName.text = info.tempGrName;
            if(!([info.tempGrpPic isKindOfClass:[NSNull null]] || info.tempGrpPic))
            {
            [_imgView sd_setImageWithURL:[NSURL URLWithString:info.tempGrpPic] placeholderImage:[UIImage imageNamed:placeholderUser]];
            }else
            {
                _imgView.image = [UIImage imageNamed:placeholderUser];
            }
        }
        else{
            _lblUserName.text = @"Administrator";
            _imgView.image = [UIImage imageNamed:@"icon_speaker_notification"];
        }
    }
    int timeSt = [[[NSUserDefaults standardUserDefaults] objectForKey:kReadNotificationsTime] intValue];
    if (info.timeStamp > timeSt){
        [newNotifbackgroundLabel setHidden:NO];
    }
    else{
        [newNotifbackgroundLabel setHidden:YES];
    }
    NSDate *date = [TimeConverter dateFromTimestamp:info.timeStamp];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    if ([now isEqualToDate:date]){
    [formatter setDateFormat:@"hh:mm a"];
    }else{
     [formatter setDateFormat:@"d MMM, hh:mm a"];
    }
     NSString *str = [formatter stringFromDate:date];
    _lblDateTime.text = str;
    
    NSString *msg = info.message;
    msg = [msg stringByReplacingOccurrencesOfString:@"<h>" withString:@""];
    msg = [msg stringByReplacingOccurrencesOfString:@"</h>" withString:@""];
    NSMutableAttributedString *attributedTxt = [Common getAttributedString:msg withFontSize:_labelMsg.font.pointSize];
    [_labelMsg setAttributedText: attributedTxt];
    _labelMsg.tintColor = [UIColor whiteColor];
    _labelMsg.textColor = [UIColor whiteColor];
    _labelMsg.dataDetectorTypes = UIDataDetectorTypeAll;

    _btnAccept.hidden = NO;
    _btnDecline.hidden = NO;
    if (info.type == NotfType_groupInvite){
        if (info.status == NotfStatusAccepted){
            _btnDecline.hidden = YES;
            _btnAccept.userInteractionEnabled = NO;
            [_btnAccept setTitle:@"Accepted" forState:UIControlStateNormal];
        }
        else if (info.status == NotfStatusRejected){
            _btnAccept.hidden = YES;
            _btnDecline.userInteractionEnabled = NO;
            [_btnDecline setTitle:@"Rejected" forState:UIControlStateNormal];
        }
        else{
            _btnAccept.userInteractionEnabled = YES;
            _btnDecline.userInteractionEnabled = YES;
            [_btnAccept setTitle:@"Accept" forState:UIControlStateNormal];
            [_btnDecline setTitle:@"Reject" forState:UIControlStateNormal];
        }
    }
    else if (info.type == NotfType_nonAdmingroupInvite){
        if (info.status == NotfStatusAccepted){
            _btnDecline.hidden = YES;
            _btnAccept.userInteractionEnabled = NO;
            [_btnAccept setTitle:@"approved" forState:UIControlStateNormal];
        }
        else if (info.status == NotfStatusRejected){
            _btnAccept.hidden = YES;
            _btnDecline.userInteractionEnabled = NO;
            [_btnDecline setTitle:@"disapproved" forState:UIControlStateNormal];
        }
        else{
            _btnAccept.userInteractionEnabled = YES;
            _btnDecline.userInteractionEnabled = YES;
            [_btnAccept setTitle:@"approve" forState:UIControlStateNormal];
            [_btnDecline setTitle:@"disapprove" forState:UIControlStateNormal];
        }
    } else if (info.type == 20){
        if (info.status == NotfStatusAccepted){
            _btnDecline.hidden = YES;
            _btnAccept.userInteractionEnabled = NO;
            [_btnAccept setTitle:@"Accepted" forState:UIControlStateNormal];
        }
        else if (info.status == NotfStatusRejected){
            _btnAccept.hidden = YES;
            _btnDecline.userInteractionEnabled = NO;
            [_btnDecline setTitle:@"Rejected" forState:UIControlStateNormal];
        }
        else{
            _btnAccept.userInteractionEnabled = YES;
            _btnDecline.userInteractionEnabled = YES;
            [_btnAccept setTitle:@"Accept" forState:UIControlStateNormal];
            [_btnDecline setTitle:@"Reject" forState:UIControlStateNormal];
        }
    }
}

- (void)displayNotificationOffline:(Notifications *)info{
    if (info.user.user_name.length>0){
        _lblUserName.text = info.user.user_name;
        [_imgView sd_setImageWithURL:[NSURL URLWithString:info.user.picUrl] placeholderImage:[UIImage imageNamed:placeholderUser]];
    }
    else{
        _lblUserName.text = @"Administrator";
        _imgView.image = [UIImage imageNamed:@"icon_speaker_notification"];
    }
    int timeSt = [[[NSUserDefaults standardUserDefaults] objectForKey:kReadNotificationsTime] intValue];
    int timestamp = [info.timestamp intValue];
    if (timestamp > timeSt) {
        [newNotifbackgroundLabel setHidden:NO];
    }
    else{
        [newNotifbackgroundLabel setHidden:YES];
    }    NSDate *dt = [TimeConverter dateFromTimestamp:timestamp];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    if ([now isEqualToDate:dt]){
        [formatter setDateFormat:@"hh:mm a"];
    }else{
        [formatter setDateFormat:@"d MMM, hh:mm a"];
    }
    
    NSString *str = [formatter stringFromDate:dt];
    _lblDateTime.text = str;
    NSString *msg = info.message;
    msg = [msg stringByReplacingOccurrencesOfString:@"<h>" withString:@""];
    msg = [msg stringByReplacingOccurrencesOfString:@"</h>" withString:@""];
    
    NSMutableAttributedString *attributedTxt = [Common getAttributedString:msg withFontSize:_labelMsg.font.pointSize];
    [_labelMsg setAttributedText: attributedTxt];
    _labelMsg.tintColor = [UIColor whiteColor];
    _labelMsg.textColor = [UIColor whiteColor];
    _labelMsg.dataDetectorTypes = UIDataDetectorTypeAll;

    _btnAccept.hidden = NO;
    _btnDecline.hidden = NO;
    
    NSInteger value = [info.type integerValue];
    NSInteger status = [info.status integerValue];
    if (value == 4){
        if (status == 1){
            _btnDecline.hidden = YES;
            _btnAccept.userInteractionEnabled = NO;
            [_btnAccept setTitle:@"Accepted" forState:UIControlStateNormal];
        }
        else if (status == 2){
            _btnAccept.hidden = YES;
            _btnDecline.userInteractionEnabled = NO;
            [_btnDecline setTitle:@"Rejected" forState:UIControlStateNormal];
        }
        else{
            _btnAccept.userInteractionEnabled = YES;
            _btnDecline.userInteractionEnabled = YES;
            [_btnAccept setTitle:@"Accept" forState:UIControlStateNormal];
            [_btnDecline setTitle:@"Reject" forState:UIControlStateNormal];
        }
    }
    else if (value == 7){
        if (status == 1){
            _btnDecline.hidden = YES;
            _btnAccept.userInteractionEnabled = NO;
            [_btnDecline setTitle:@"Accepted" forState:UIControlStateNormal];
        }
        else if (status == 2){
            _btnAccept.hidden = YES;
            _btnDecline.userInteractionEnabled = NO;
            [_btnDecline setTitle:@"Rejected" forState:UIControlStateNormal];
        }
        else{
            _btnAccept.userInteractionEnabled = YES;
            _btnDecline.userInteractionEnabled = YES;
            [_btnAccept setTitle:@"approve" forState:UIControlStateNormal];
            [_btnDecline setTitle:@"Reject" forState:UIControlStateNormal];
        }
    }    else if (value == 20){
        if (status == 1){
            _btnDecline.hidden = YES;
            _btnAccept.userInteractionEnabled = NO;
            [_btnDecline setTitle:@"Accepted" forState:UIControlStateNormal];
        }
        else if (status == 2){
            _btnAccept.hidden = YES;
            _btnDecline.userInteractionEnabled = NO;
            [_btnDecline setTitle:@"Rejected" forState:UIControlStateNormal];
        }
        else{
            _btnAccept.userInteractionEnabled = YES;
            _btnDecline.userInteractionEnabled = YES;
            [_btnAccept setTitle:@"approve" forState:UIControlStateNormal];
            [_btnDecline setTitle:@"Reject" forState:UIControlStateNormal];
        }
    }

}

#pragma mark -
#pragma mark - IBOutlets
- (IBAction)declineButtonClicked:(id)sender{
    if(![AppManager isInternetShouldAlert:NO]){
        [AppManager showAlertWithTitle:@"Alert!" Body:@"Please check your internet connection to perform this operation"];
    }
    else{
    if (_delegate && [_delegate respondsToSelector:@selector(didAccept:onIndex:)])
        [_delegate didAccept:NO onIndex:self.tag];
    }
}

- (IBAction)acceptButtonClicked:(id)sender{
    if(![AppManager isInternetShouldAlert:NO]){
        [AppManager showAlertWithTitle:@"Alert!" Body:@"Please check your internet connection to perform this operation"];
    }
    else{
        if (_delegate && [_delegate respondsToSelector:@selector(didAccept:onIndex:)])
            [_delegate didAccept:YES onIndex:self.tag];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    NSString *temp = _labelMsg.text;
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSString *urlString = [NSString stringWithFormat:@"%@",URL];
    NSMutableDictionary *postDictionary;
    NSMutableDictionary *detaildict;

    if([urlString hasPrefix:@"https://"] || ([urlString hasPrefix:@"http://"])){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:temp,@"text",nil];

        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"",@"category_id",@"Notification",@"log_category",@"on_click_url",@"log_sub_category",temp,@"text",detaildict,@"details",nil];
        
    }
    else if([urlString hasPrefix:@"telprompt:"] || ([urlString hasPrefix:@"tel:"])){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:temp,@"text",nil];

        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_click_phone_number",@"log_sub_category",temp,@"text",detaildict,@"details",nil];
    }
    
    [AppManager saveEventLogInArray:postDictionary];
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    [super canPerformAction:action withSender:sender];
    if (action == @selector(copy:))
        return YES;
    if (action == @selector(paste:))
        return YES;
    if (action == @selector(select:))
        return YES;
    return [super canPerformAction:action withSender:sender];
}


-(void)paste:(id)sender{
    DLog(@"pasted");
}

-(void)select:(id)sender{
    DLog(@"selected");
    
}
-(void)copy:(id)sender{
}

@end
