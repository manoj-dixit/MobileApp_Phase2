//
//  ShoutCellReceiverCell.m
//  LH2GO
//
//  Created by Techbirds on 11/12/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "ShoutCellReceiverCell.h"
#import "UIView+Extra.h"
#import "UILabel+Extra.h"
#import "NSString+Extra.h"
#import "TimeConverter.h"
#import "LHAudioPlayerView.h"
#import "UIView+position.h"
#import "UIImage+GIF.h"
#import "FLAnimatedImage.h"
#import "ShoutInfo.h"
#import "Constant.h"
#import "CryptLib.h"
#import "NSData+Base64.h"
#import "SharedUtils.h"
#import "EventLog.h"





@interface ShoutCellReceiverCell ()<UIAlertViewDelegate,UITextViewDelegate,APICallProtocolDelegate> {
    
    __weak IBOutlet UIButton *_profileImgBtn;
    __weak IBOutlet UILabel *usrNmLbl;
    __weak IBOutlet UILabel *dtLbl;
    __weak IBOutlet UILabel *shTextLbl;
    __weak IBOutlet UILabel *_lblProgress;
    __weak IBOutlet UIProgressView *progressVW;
    
    __weak IBOutlet UIButton *imgButton;
    __weak IBOutlet NSLayoutConstraint *txtviewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *topConstraint;
    
    __weak IBOutlet NSLayoutConstraint *btmConstraint;
    
    __weak IBOutlet NSLayoutConstraint *bottomConstraint;
    __weak IBOutlet UIButton *imgBtn;
    __weak IBOutlet UIImageView *_imgbtnPlayVideo;
    IBOutlet UIImageView *_imgView;
    
    __weak IBOutlet UIView *lineView;
    __weak IBOutlet UIView *buttonsView;
    
    __weak IBOutlet UIButton *_btnReplyShouts;
    __weak IBOutlet UIButton *_btnRebroadcast;
    __weak IBOutlet UIButton *_btnReplyShoutsArrow;
    __weak IBOutlet UIButton *_btnFaverate;
    
    
    LHAudioPlayerView *player;
    
    __weak IBOutlet NSLayoutConstraint *textViewHeightConstraint;
    __weak IBOutlet UITextView *textView;
    Shout *_shoutObj;
    BOOL shouldFade;
    SharedUtils *sharedUtils;
    
    // by nim chat#11
    
    __weak IBOutlet UIView *vw_forPlayer;
    __weak IBOutlet UIImageView *img_tail;
    __weak IBOutlet UIButton *_profileImgBtn1;
    }

@end



@implementation ShoutCellReceiverCell

+ (instancetype)cellWithType:(ShoutType)type shouldFade:(BOOL)shouldFade{
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ShoutCellReceiver" owner:self options:nil];
    ShoutCellReceiverCell *cell = [objects objectAtIndex:type];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (shouldFade) {
        // new shout notification..
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(shoutLifeLineUpdate:) name:kShoutLifeLineUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(shoutProgressUpdate:) name:kShoutProgressUpdate object:nil];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    CGSize sizeThatShouldFitTheContent = [textView sizeThatFits:textView.frame.size];
    textViewHeightConstraint.constant = sizeThatShouldFitTheContent.height;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    if(IS_IPHONE_4_OR_LESS)
    {
        DLog(@"IS_IPHONE_4_OR_LESS");
    }
    if(IS_IPHONE_5)
    {
        DLog(@"IS_IPHONE_5");
    }
    if(IS_IPHONE_6 )
    {
        CGRect favframe = _btnFaverate.frame;
        CGRect btnBroadcast = _btnRebroadcast.frame;
        CGRect replyShoutsArrFr = _btnReplyShoutsArrow.frame;
        CGRect replyShoutsFr = _btnReplyShouts.frame;
        
        favframe.origin.x = favframe.origin.x - 10;
        btnBroadcast.origin.x = favframe.origin.x - 40 ;
        replyShoutsArrFr.origin.x = btnBroadcast.origin.x - 40;
        replyShoutsFr.origin.x = replyShoutsArrFr.origin.x - 65;
        
        btnBroadcast.origin.y = btnBroadcast.origin.y + 2;
        favframe.origin.y = favframe.origin.y + 2;
        replyShoutsFr.origin.y = replyShoutsFr.origin.y + 2;
        replyShoutsArrFr.origin.y = replyShoutsArrFr.origin.y +3 ;
        
        _btnFaverate.frame =  favframe;
        _btnReplyShoutsArrow.frame = replyShoutsArrFr;
        _btnReplyShouts.frame = replyShoutsFr;
        _btnRebroadcast.frame = btnBroadcast;
    }
    if(IS_IPHONE_6P)
    {
        CGRect favframe = _btnFaverate.frame;
        CGRect btnBroadcast = _btnRebroadcast.frame;
        CGRect replyShoutsArrFr = _btnReplyShoutsArrow.frame;
        CGRect replyShoutsFr = _btnReplyShouts.frame;
        
        favframe.origin.x = favframe.origin.x - 10;
        btnBroadcast.origin.x = favframe.origin.x - 50 ;
        replyShoutsArrFr.origin.x = btnBroadcast.origin.x - 50;
        replyShoutsFr.origin.x = replyShoutsArrFr.origin.x - 75;
        
        btnBroadcast.origin.y = btnBroadcast.origin.y + 2;
        favframe.origin.y = favframe.origin.y + 2;
        replyShoutsFr.origin.y = replyShoutsFr.origin.y + 2;
        replyShoutsArrFr.origin.y = replyShoutsArrFr.origin.y +3 ;
        
        _btnFaverate.frame =  favframe;
        _btnReplyShoutsArrow.frame = replyShoutsArrFr;
        _btnReplyShouts.frame = replyShoutsFr;
        _btnRebroadcast.frame = btnBroadcast;
        
    }
    DLog(@"%f",SCREEN_MAX_LENGTH);
    textView.textContainerInset = UIEdgeInsetsMake(8,0,8,5);
    [_profileImgBtn roundCorner:4 border:0 borderColor:nil];
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc]init];
    sharedUtils.delegate = self;
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [textView layoutIfNeeded];
        [_btnFaverate layoutIfNeeded];
    });
}

#pragma mark - Public methods
-(void)setDateLabelForSessionInfo:(NSString *)str
{
    dispatch_async(dispatch_get_main_queue(), ^{
        dtLbl.text = str;
    });
}

- (void)showShout:(Shout *)sh forChieldCell:(BOOL)isChield{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        textView.hidden = NO;
        
        _shoutObj = sh;
        
        NSString *imageURL = [sh.owner.picUrl copy];
        [_profileImgBtn setImage:[UIImage imageNamed:placeholderUser] forState:UIControlStateNormal];
        [_profileImgBtn.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:_profileImgBtn.imageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [_profileImgBtn setImage:image forState:UIControlStateNormal];
                [_profileImgBtn1 setImage:image forState:UIControlStateNormal]; // by nim
                
            }
        }];
        
        //only first name
        NSArray *myArray = [sh.owner.user_name componentsSeparatedByString:@" "];
        
        if (myArray != nil) {
            usrNmLbl.text = [myArray objectAtIndex:0];// sh.owner.user_name;
        }else
            usrNmLbl.text = @"Unknown";
        
        NSDate *dt = [TimeConverter dateFromTimestamp:sh.timestamp.integerValue];
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"hh:mm a"];
        NSString *str = [formatter stringFromDate:dt];
        dtLbl.text = str;
        // voiceBtnfr.origin.x = btmVfr.size.width - voiceBtnfr.size.width - 5;
        _profileImgBtn.layer.cornerRadius = _profileImgBtn.frame.size.width / 2;
        _profileImgBtn.clipsToBounds = YES;
        _profileImgBtn1.layer.cornerRadius = _profileImgBtn1.frame.size.width / 2;
        _profileImgBtn1.clipsToBounds = YES;
        
        textView.layer.cornerRadius = 10;
        textView.clipsToBounds = YES;
      _imgView.layer.cornerRadius = 10;
        _imgView.clipsToBounds = YES;
        __imgViewYGF.layer.cornerRadius = 10;
        __imgViewYGF.clipsToBounds = YES;
        _imgbtnPlayVideo.layer.cornerRadius = 10;
        _imgbtnPlayVideo.clipsToBounds = YES;
        
        DLog(@"%@", sh.text);
        
        if (sh.text != nil){
            //formatting: urls & phonenumber in bold
            NSMutableAttributedString *attributedTxt1 = [Common getAttributedString:[sh.text withoutWhiteSpaceString] withFontSize:textView.font.pointSize];
            textView.attributedText = attributedTxt1;
        }else{
            textView.text = [sh.text withoutWhiteSpaceString];
        }
        textView.tintColor = [UIColor whiteColor];
        textView.textColor = [UIColor whiteColor];

        
        CGSize sizeThatShouldFitTheContent = [textView sizeThatFits:textView.frame.size];
        textViewHeightConstraint.constant = sizeThatShouldFitTheContent.height;
        textView.scrollEnabled = NO; //YES;  //by nim chat#14
        shTextLbl.userInteractionEnabled = YES;
        shTextLbl.text = sh.text;
        
        textView.delegate = self;
//        textView.dataDetectorTypes = UIDataDetectorTypeAll;
        // textView.backgroundColor = [UIColor clearColor];
        textView.selectable = YES;
        textView.editable = NO;
//        textView.tintColor = [UIColor blueColor];
        if (sh.type.integerValue == ShoutTypeImage)
        {
            if([textView.text isEqualToString:@"" ]|| textView.text == nil){
                textView.hidden = YES;
                img_tail.hidden =  YES; // by nim chat#11
                _profileImgBtn1.hidden =  YES; // by nim chat#11
            }
            else
            {
                textView.hidden = NO;
            }
         //   if (sh.isShoutRecieved.boolValue == YES) {
                
            [_imgView sd_setImageWithURL:[NSURL URLWithString:URLForShoutContent(sh.shId, @"png")] placeholderImage:[UIImage imageNamed:@"UserIcon"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];


                
//            }
//            else{
//                _imgView.image = nil;
//            }
        } else if(sh.type.integerValue==ShoutTypeVideo){
            if([textView.text isEqualToString:@"" ]|| textView.text == nil){
                textView.hidden = YES;
                img_tail.hidden =  YES; // by nim chat#11
                _profileImgBtn1.hidden =  YES; // by nim chat#11
            }
            else{
                textView.hidden = NO;
            }
//            if (sh.isShoutRecieved.boolValue == YES)
//            {
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(q, ^{
                    UIImage *img = [self getImageFromContentURL:sh.contentUrl];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [_imgView setImage:img];
                    });
                });
                
//            }
//            else{
//                _imgView.image = nil;
//            }
        }
        else if(sh.type.integerValue == ShoutTypeAudio){
            if([textView.text isEqualToString:@"" ]|| textView.text == nil){
                textView.hidden = YES;
                img_tail.hidden =  YES; // by nim chat#11
                _profileImgBtn1.hidden =  YES; // by nim chat#11
            }
            else{
                textView.hidden = NO;
            }
         //   if (sh.isShoutRecieved.boolValue == YES) {
                NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sh.contentUrl];
                [self addPlayer:[NSURL URLWithString:path]];
         //   }
        }
        else if(sh.type.integerValue == ShoutTypeGif){
            if([textView.text isEqualToString:@"" ]|| textView.text == nil){
                textView.hidden = YES;
                img_tail.hidden =  YES; // by nim chat#11
                _profileImgBtn1.hidden =  YES; // by nim chat#11
            }
            else{
                textView.hidden = NO;
            }
            
       //     if (sh.isShoutRecieved.boolValue == YES) {
                NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sh.contentUrl];
                NSData *pngData = [NSData dataWithContentsOfFile:path];
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:pngData];
                self._imgViewYGF.animatedImage = image;
                pngData = nil;
                path = nil;
//            }
//            else{
//                self._imgViewYGF.animatedImage = nil;
//            }
        }
        
        if (sh.isShoutRecieved.boolValue == YES) {
            
            _lblProgress.text = @"";
            _lblProgress.hidden = YES;
            self.userInteractionEnabled = YES;
        }
        else{
            self.userInteractionEnabled = YES;
        }
        
        [self updateUIforReplyCell:isChield];
        [self updateFavUIFlag];
        
    });
}

- (void)updateUIforReplyCell:(BOOL)isChield{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        buttonsView.hidden=NO;
        _btnRebroadcast.hidden = NO;
        if (_shoutObj.parent_shout&&isChield) {
            buttonsView.hidden=YES;
        }
        else if(isChield){
            _btnReplyShouts.hidden=isChield;
            _btnReplyShoutsArrow.hidden=isChield;
            _btnRebroadcast.hidden = isChield;
        }
        [_btnReplyShouts setTitle:@"" forState:UIControlStateNormal];
        _btnReplyShouts.hidden=YES;
        if (_shoutObj.chield_shouts.count&&!isChield)
        {
            if(_shoutObj.chield_shouts.count == 1)
                [_btnReplyShouts setTitle:[NSString stringWithFormat:@"%ld reply", (unsigned long)_shoutObj.chield_shouts.count] forState:UIControlStateNormal];
            else
                [_btnReplyShouts setTitle:[NSString stringWithFormat:@"%ld replies", (unsigned long)_shoutObj.chield_shouts.count] forState:UIControlStateNormal];
            _btnReplyShouts.hidden = NO;
            [_btnReplyShoutsArrow setImage:[UIImage imageNamed:@"arrow_unselect"] forState:UIControlStateNormal];
        }
        else if(!isChield){
            [_btnReplyShoutsArrow setImage:[UIImage imageNamed:@"arrow_unselect"] forState:UIControlStateNormal];
        }
    });
}

- (UIImage*)getImageFromContentURL:(NSString*)url
{
    NSString *imagePath = [NSString stringWithFormat:@"Image%@.png", [[url componentsSeparatedByString:@"."] firstObject]];
    UIImage *image = [[SDImageCache sharedImageCache] diskImageForKey:imagePath];
    if (!image) {
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:url];
        if (path != nil) {
            image = [AppManager getPreViewImg:[NSURL fileURLWithPath:path]];
            [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"Image%@.png", [[url componentsSeparatedByString:@"."] firstObject]]];
        }
    }
    return image;
}

- (void)addPlayer:(NSURL*)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if(player == nil)
    {
        player = [LHAudioPlayerView playerView];
        
        CGRect rect = textView.frame;
        rect.origin.y = 47;
        rect.origin.x = 18;
        rect.size.width = self.frame.size.width - rect.origin.x*2;
        
        
        if (player) {
            rect = player.frame;
            if(IS_IPHONE_5)
                rect.origin.x = 120;
            else if(IS_IPHONE_6)
                rect.origin.x = 180;
            else if(IS_IPHONE_6P)
                rect.origin.x = 210;
            else if(IPAD)
                rect.origin.x = 475;
            else if(IS_IPAD_PRO_1024)
                rect.origin.x = 500;
            
            rect.origin.y = _profileImgBtn.frame.origin.y + 20;//_btnFaverate.frame.origin.y+textView.frame.size.height - 50;
            rect.size.width = self.frame.size.width-117;
            
            // by nim chat#13
            CGRect rect1;
            if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5){
                rect1 = CGRectMake(buttonsView.frame.origin.x + buttonsView.frame.size.width-25, buttonsView.frame.origin.y , self.frame.size.width/2, 50);
            }else if (IS_IPAD_PRO_1024) {
                rect1 = CGRectMake(buttonsView.frame.origin.x + buttonsView.frame.size.width +300, buttonsView.frame.origin.y , self.frame.size.width/2 + 10, 50);
                
                
            }else{
                rect1 = CGRectMake(buttonsView.frame.origin.x + buttonsView.frame.size.width + 20, buttonsView.frame.origin.y , self.frame.size.width/2 + 10, 50);
                
                
            }
            // CGRect rect1 = CGRectMake(textView.frame.origin.x, _profileImgBtn.frame.origin.y + _profileImgBtn.frame.size.height+ 10, textView.frame.size.width-_profileImgBtn.frame.size.width, 50); // temp
            
            player.frame = rect1;//rect; // by nim chat#13
        }
        [self addSubview:player];
    }
    
    player.hidden = NO;
    
    [player setupAudioPlayer:url];
    });
}

#pragma mark - IBAction


- (IBAction)allReplClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_Reply ForObject:_shoutObj];
}

- (IBAction)replyClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_Reply ForObject:_shoutObj];
}

- (IBAction)favClicked:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
    {
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_Fav ForObject:_shoutObj];
        [self updateFavUIFlag];
    }
}

- (IBAction)profileClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_Profile ForObject:_shoutObj];
}

- (IBAction)saveVideoPressed:(id)sender{
    
}

- (IBAction)vidoClicked:(id)sender {
    
}

- (IBAction)imageClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_Image ForObject:_shoutObj];
}

- (IBAction)audioClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_Audio ForObject:_shoutObj];
}

- (IBAction)rebroadcastClicked:(id)sender {
    //animation stuff
    [_btnRebroadcast setImage:[UIImage imageNamed:@"icon_broadcastgreen"] forState:UIControlStateNormal];
    [self animateButtonInProgress];
    [self performSelector:@selector(removeAllAnimationFromButton) withObject:nil afterDelay:2];
    //animation stuff
    
    if(_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_All ForObject:_shoutObj];
}
-(void)removeAllAnimationFromButton
{
    [_btnRebroadcast.layer removeAllAnimations];
    dispatch_async(dispatch_get_main_queue(), ^{
    [_btnRebroadcast setImage:[UIImage imageNamed:@"Image_rebroadcast"] forState:UIControlStateNormal];
    });
}
-(void)animateButtonInProgress
{
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=2.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    [_btnRebroadcast.layer addAnimation:theAnimation forKey:@"animateOpacity"];
}

#pragma mark - Notification (kShoutLifeLineUpdate)
- (void)shoutLifeLineUpdate:(NSNotification *)notification {
    
    Shout *sh = (Shout *) [notification object];
    
    [self updateCellVisibility:sh];
}

#pragma mark - Notification (kShoutProgressUpdate)
- (void)shoutProgressUpdate:(NSNotification *)notification {
    [self updateProgress:notification];
}

- (void)updateProgress:(NSNotification *)notification{
    NSObject *data = [notification object];
    if ([data isKindOfClass:[ShoutDataReceiver class]]) {
        ShoutDataReceiver *sData = (ShoutDataReceiver*)data;
        if(sData.shoutData&&[sData.shoutData isKindOfClass:[NSData class]]&&[sData.header.shoutId isEqualToString:_shoutObj.shId])
        {
            _lblProgress.hidden = NO;
            _lblProgress.text = [NSString stringWithFormat:@"%lu\%% Received", (unsigned long)((sData.shoutData.length-sData.headerLength)*100.0/sData.header.totalShoutLength)];
        }
    }
    else if([data isKindOfClass:[ShoutDataSender class]]){
        ShoutDataSender *dataToSend = (ShoutDataSender*)data;
        if (dataToSend.totalShoutLength==0) {
            _lblProgress.hidden = YES;
            _lblProgress.text = @"";
        }
        else if (dataToSend.shoutData&&[dataToSend.shoutData isKindOfClass:[NSData class]]&&[dataToSend.shId isEqualToString:_shoutObj.shId] && (dataToSend.type == ShoutTypeImage || dataToSend.type == ShoutTypeAudio || dataToSend.type == ShoutTypeVideo || dataToSend.type == ShoutTypeGif) ) {
            _lblProgress.hidden = NO;
            _lblProgress.text = [NSString stringWithFormat:@"%lu\%% Sent", (unsigned long)((dataToSend.totalShoutLength-dataToSend.shoutData.length)*100.0/dataToSend.totalShoutLength)];
        }
    }
}

- (void)updateCellVisibility:(Shout*)sh{
    float visibility;
    if([sh.shId isEqualToString:_shoutObj.shId])
    {
        NSDate *currentDateTime = [NSDate date];
        NSDate *shoutOriginalDate = [NSDate dateWithTimeIntervalSince1970:sh.timestamp.integerValue];
        int secs = [currentDateTime timeIntervalSinceDate:shoutOriginalDate];
        if(sh.isFromCMS == YES && [sh.cmsTime intValue]>0){
            visibility = 1.0 - (float)(secs)*0.5/[sh.cmsTime intValue];
        }
        
        visibility = 1.0 - (float)(secs)*0.5/KCellFadeOutDuration;
        if (visibility<0.4) {
            visibility=0.4;
        }
        
        //        if (visibility == 0.0)
        //        {
        //            NSLog(@"Removed key for Path %@",sh.contentUrl);
        //            [[SDImageCache sharedImageCache] removeImageForKey:sh.contentUrl];
        //        }
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [UIView animateWithDuration:.2 animations:^{
                self.contentView.alpha = visibility;
            }];
            
        });
    }
}

- (void)updateFavUIFlag{
    if ([_shoutObj.favorite integerValue]>=1) {
        [_btnFaverate setImage:[UIImage imageNamed:@"star_fill"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnFaverate setImage:[UIImage imageNamed:@"star_gray"] forState:UIControlStateNormal];
    }
}

-(void)hideRebroadCastAndReply{
    
    //    CGRect replyShoutsFr = _btnReplyShouts.frame;
    //
    //    replyShoutsFr.origin.x = _btnFaverate.frame.origin.x - 70;
    //
    //
    //
    //    _btnReplyShouts.frame = replyShoutsFr;
    
    // [_btnReplyShouts setFrameX:_btnRebroadcast.frame.origin.x];
    _btnRebroadcast.hidden = YES;
    _btnReplyShoutsArrow.hidden = YES;
    if (_shoutObj.parent_shout) {
        buttonsView.hidden=YES;
    }
}

-(void)showFavOnly
{
    [_btnFaverate setHidden:NO];
    [_btnRebroadcast setHidden:YES];
    [_btnReplyShouts setHidden:YES];
    [_btnReplyShoutsArrow setHidden:YES];
}

#pragma mark --Tap Getsture--

- (IBAction)tapgestureEvent:(id)sender{
    [self performSelector:@selector(singleTapPlayVideo) withObject:nil afterDelay:0.5];
}

- (IBAction)doubleTapgestureEvent:(id)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapPlayVideo) object:nil];
    if(_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_Video_Export ForObject:_shoutObj];
}

- (void)singleTapPlayVideo{
    if(_shoutObj.contentUrl&&_delegate && [_delegate respondsToSelector:@selector(didClickReceiverButtonWithTag:ForObject:)])
        [_delegate didClickReceiverButtonWithTag:CellButtonReceiverTag_Video ForObject:_shoutObj];
}


#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    
    int timeStamp = (int)[TimeConverter timeStamp];
    NSString *temp = self->textView.text;
    
    NSString *urlString = [NSString stringWithFormat:@"%@",URL];
    NSMutableDictionary *postDictionary;
    NSMutableDictionary *detaildict;

    if([urlString hasPrefix:@"https://"] || ([urlString hasPrefix:@"http://"]))
    {
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:_shoutObj.shId,@"shoutId",_shoutObj.group.grId,@"groupId",temp,@"text",nil];
        
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_click_url",@"log_sub_category",_shoutObj.group.grId,@"category_id",_shoutObj.shId,@"shoutId",temp,@"text",detaildict,@"details",nil];
    }
    else if([urlString hasPrefix:@"telprompt:"] || [urlString hasPrefix:@"tel"])
    {
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:_shoutObj.shId,@"shoutId",_shoutObj.group.grId,@"groupId",temp,@"text",nil];
        
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_click_phone_number",@"log_sub_category",_shoutObj.group.grId,@"groupId",_shoutObj.shId,@"shoutId",temp,@"text",detaildict,@"details",nil];
        
        [[NSUserDefaults standardUserDefaults]setObject:urlString forKey:k_phNumberShoutReceiverCell];
        
        
    }
    
    
    [AppManager saveEventLogInArray:postDictionary];

    
//    [EventLog addEventWithDict:postDictionary];
//    NSNumber *count = [Global shared].currentUser.eventCount;
//    int value = [count intValue];
//    count = [NSNumber numberWithInt:value + 1];
//    [[Global shared].currentUser setEventCount:count];
//    [DBManager save];
//    
//    
//    if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0)){
//        //show loader...
//        // [LoaderView addLoaderToView:self.view];
//        [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//    }
//    
    
    return YES;
}

@end
