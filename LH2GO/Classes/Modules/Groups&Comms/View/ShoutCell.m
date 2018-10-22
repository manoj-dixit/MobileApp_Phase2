//
//  ShoutCell.m
//  LH2GO
//
//  Created by Linchpin on 11/8/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "ShoutCell.h"
#import "UIView+Extra.h"
#import "UILabel+Extra.h"
#import "NSString+Extra.h"
#import "TimeConverter.h"
#import "LHAudioPlayerView.h"
#import "UIView+position.h"
#import "UIImage+GIF.h"
#import "FLAnimatedImage.h"
#import "ShoutInfo.h"
#import "CryptLib.h"
#import "NSData+Base64.h"
#import "SharedUtils.h"
#import "EventLog.h"
#import "ShoutManager.h"


#define kReplyCellMargin 40
#define k_AlphaReduceVal .2

@interface ShoutCell ()<UIAlertViewDelegate,UITextViewDelegate,APICallProtocolDelegate> {
    
    __weak IBOutlet UIButton *_profileImgBtn;
    __weak IBOutlet UILabel *usrNmLbl;
    __weak IBOutlet UILabel *dtLbl;
    __weak IBOutlet UILabel *shTextLbl;
    __weak IBOutlet UILabel *_lblProgress;
    __weak IBOutlet UIProgressView *progressVW;
    __weak IBOutlet UIImageView *_imgbtnPlayVideo;
    IBOutlet UIImageView *_imgView;
    
    __weak IBOutlet NSLayoutConstraint *dtLblconstraint;
    __weak IBOutlet NSLayoutConstraint *usrNmLblTrailing;
    __weak IBOutlet UIView *lineView;
    __weak IBOutlet UIView *buttonsView;
    
    __weak IBOutlet UIButton *_btnReplyShouts;
    __weak IBOutlet UIButton *_btnRebroadcast;
    __weak IBOutlet UIButton *_btnReplyShoutsArrow;
    __weak IBOutlet UIButton *_btnFaverate;
    
    __weak IBOutlet NSLayoutConstraint *textViewImgHeightconstraint;
    __weak IBOutlet NSLayoutConstraint *textViewHeightConstarint;
    
   LHAudioPlayerView *player;
    SharedUtils *sharedUtils;
    
    __weak IBOutlet UITextView *textViewImg;
    __weak IBOutlet UITextView *textView;
    Shout *_shoutObj;
    BOOL shouldFade;
    // by nim chat#11
    
    __weak IBOutlet UIImageView *img_tail;
    __weak IBOutlet UIButton *_profileImgBtn1;
}

@end



@implementation ShoutCell


+ (instancetype)cellWithType:(ShoutType)type shouldFade:(BOOL)shouldFade{
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ShoutCell" owner:self options:nil];
    ShoutCell *cell = [objects objectAtIndex:type];
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
 
    CGSize sizeThatShouldFitTheContent = [textView sizeThatFits:textView.frame.size];
   textViewHeightConstarint.constant = sizeThatShouldFitTheContent.height;
    textViewImgHeightconstraint.constant = sizeThatShouldFitTheContent.height;

    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textViewImg.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if(IS_IPHONE_4_OR_LESS)
    {
        DLog(@"IS_IPHONE_4_OR_LESS");
    }
    if(IS_IPHONE_5)
    {
//        CGRect favframe = _btnFaverate.frame;
//        NSLog (@"%f",favframe.origin.x);
//        
//        
//        CGRect replyShoutsArrFr = _btnReplyShoutsArrow.frame;
//        CGRect replyShoutsFr = _btnReplyShouts.frame;
//        
//        favframe.origin.x = favframe.origin.x - 50;
//        replyShoutsArrFr.origin.x = favframe.origin.x -40;
//        replyShoutsFr.origin.x = replyShoutsArrFr.origin.x - 50;
//        _btnFaverate.frame =  favframe;
//        _btnReplyShoutsArrow.frame = replyShoutsArrFr;
//        _btnReplyShouts.frame = replyShoutsFr;

    }
    if(IS_IPHONE_6 )
    {
        CGRect favframe = _btnFaverate.frame;
        CGRect btnBroadcast = _btnRebroadcast.frame;
        DLog (@"%f",favframe.origin.x);
        
        
        CGRect replyShoutsArrFr = _btnReplyShoutsArrow.frame;
        CGRect replyShoutsFr = _btnReplyShouts.frame;
        
        favframe.origin.x = favframe.origin.x + 40;
        btnBroadcast.origin.x = favframe.origin.x -35;
        replyShoutsArrFr.origin.x = btnBroadcast.origin.x -35;
        replyShoutsFr.origin.x = replyShoutsArrFr.origin.x - 65;
        
//        favframe.origin.y = favframe.origin.y - 4;
//        btnBroadcast.origin.y = btnBroadcast.origin.y -4;
//        replyShoutsArrFr.origin.y = replyShoutsArrFr.origin.y -4;
//        replyShoutsFr.origin.y = replyShoutsFr.origin.y - 4;
        
        _btnFaverate.frame =  favframe;
        _btnReplyShoutsArrow.frame = replyShoutsArrFr;
        _btnReplyShouts.frame = replyShoutsFr;
        _btnRebroadcast.frame = btnBroadcast;
                
    }
    if(IS_IPHONE_6P)
    {
        CGRect favframe = _btnFaverate.frame;
        CGRect btnBroadcast = _btnRebroadcast.frame;
        DLog (@"%f",favframe.origin.x);
        
        CGRect replyShoutsArrFr = _btnReplyShoutsArrow.frame;
        CGRect replyShoutsFr = _btnReplyShouts.frame;
        
        favframe.origin.x = favframe.origin.x + 40;
        btnBroadcast.origin.x = favframe.origin.x -35;
        replyShoutsArrFr.origin.x = btnBroadcast.origin.x -35;
        replyShoutsFr.origin.x = replyShoutsArrFr.origin.x - 65;
       
//        btnBroadcast.origin.y = btnBroadcast.origin.y - 10;
//        favframe.origin.y = favframe.origin.y - 10;
//        replyShoutsFr.origin.y = replyShoutsFr.origin.y - 10;
//        replyShoutsArrFr.origin.y = replyShoutsArrFr.origin.y -10;
        _btnFaverate.frame =  favframe;
        _btnReplyShoutsArrow.frame = replyShoutsArrFr;
        _btnReplyShouts.frame = replyShoutsFr;
        _btnRebroadcast.frame = btnBroadcast;
        
    }
    textView.textContainerInset = UIEdgeInsetsMake(8,8,8,0);
    [_profileImgBtn roundCorner:4 border:0 borderColor:nil];
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc]init];
    sharedUtils.delegate = self;

    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [dtLbl layoutIfNeeded];
    });
}
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    
//    CGRect rect = textView.frame;
//    rect.origin.y = 47;
//    rect.origin.x = 18;
//    rect.size.width = self.frame.size.width - rect.origin.x*2;
//    textView.frame = rect;
//    
//    if (_imgView) {
//        rect = _imgView.frame;
//        rect.origin.y = textView.frame.origin.y+textView.frame.size.height + 10;
//        _imgView.frame = rect;
//        rect = _imgbtnPlayVideo.frame;
//        rect.origin.x = _imgView.frame.origin.x+(_imgView.frame.size.width-rect.size.width)/2;
//        rect.origin.y = _imgView.frame.origin.y+(_imgView.frame.size.height-rect.size.height)/2;
//        _imgbtnPlayVideo.frame = rect;
//    }
//    else if(self._imgViewYGF)
//    {
//        rect = self._imgViewYGF.frame;
//        rect.origin.y = textView.frame.origin.y+textView.frame.size.height + 10;
//        self._imgViewYGF.frame = rect;
//    }
//    
//    if (player) {
//        rect = player.frame;
//        rect.origin.y = textView.frame.origin.y+textView.frame.size.height + 10;
//        rect.size.width = self.frame.size.width;
//        player.frame = rect;
//    }
//    
//    rect = lineView.frame;
//    rect.origin.y = self.frame.size.height-1;
//    lineView.frame = rect;
//    
//    [self updateFrameForReplyCell];
//}
//
//- (void)updateFrameForReplyCell
//{
//    CGRect rect = _profileImgBtn.frame;
//    rect.origin.x = 18;
//    _profileImgBtn.frame = rect;
//    rect = usrNmLbl.frame;
//    rect.origin.x = 56;
//    rect.size.width = 120;
//    usrNmLbl.frame = rect;
//    rect = dtLbl.frame;
//    rect.origin.x = 56;
//    rect.size.width = 120;
//    dtLbl.frame = rect;
//    if (_shoutObj.parent_shout) {
//        rect = textView.frame;
//        rect.origin.x += kReplyCellMargin;
//        rect.size.width -= kReplyCellMargin;
//        textView.frame = rect;
//        rect = _profileImgBtn.frame;
//        rect.origin.x += kReplyCellMargin;
//        _profileImgBtn.frame = rect;
//        rect = usrNmLbl.frame;
//        rect.origin.x += kReplyCellMargin;
//        usrNmLbl.frame = rect;
//        rect = dtLbl.frame;
//        rect.origin.x += kReplyCellMargin;
//        dtLbl.frame = rect;
//    }
//}


#pragma mark - Public methods
-(void)setDateLabelForSessionInfo:(NSString *)str{
    dtLblconstraint.constant = 40;
    usrNmLblTrailing.constant = 50;

    dtLbl.text = str;
}



- (void)showShout:(Shout *)sh forChieldCell:(BOOL)isChield{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger isSaved = [defaults integerForKey:@"Saved"];
   
    
    textViewImg.hidden = NO;
    _shoutObj = sh;
    
    NSString *imageURL = [sh.owner.picUrl copy];
    [_profileImgBtn setImage:[UIImage imageNamed:placeholderUser] forState:UIControlStateNormal];
    [_profileImgBtn.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:_profileImgBtn.imageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image){
            
        [_profileImgBtn setImage:image forState:UIControlStateNormal];
        [_profileImgBtn1 setImage:image forState:UIControlStateNormal];
        }
    
    }];
    
    //only first name
    NSArray *myArray = [sh.owner.user_name componentsSeparatedByString:@" "];
    if (myArray != nil) {
        if (myArray.count>0) {
            
            if ([[myArray objectAtIndex:0] isEqualToString:@""]) {
                usrNmLbl.text = @"Unknown";
            }
            else
            {
                usrNmLbl.text = [myArray objectAtIndex:0];// sh.owner.user_name;
                
            }
        }else
        {
            usrNmLbl.text = [myArray objectAtIndex:0];// sh.owner.user_name;
        }
    }else
        usrNmLbl.text = @"Unknown";

       _profileImgBtn.layer.cornerRadius = _profileImgBtn.frame.size.width / 2;
    _profileImgBtn.clipsToBounds = YES;
    _profileImgBtn1.layer.cornerRadius = _profileImgBtn1.frame.size.width / 2;
    _profileImgBtn1.clipsToBounds = YES;
    
    textView.layer.cornerRadius = 10;
    textView.clipsToBounds = YES;
    
    textViewImg.layer.cornerRadius = 10;
    textViewImg.clipsToBounds = YES;
    
    _imgView.layer.cornerRadius = 10;
    _imgView.clipsToBounds = YES;
    
    
    __imgViewYGF.layer.cornerRadius = 10;
    __imgViewYGF.clipsToBounds = YES;
    
    _imgbtnPlayVideo.layer.cornerRadius = 10;
    _imgbtnPlayVideo.clipsToBounds = YES;
    
    
    if(isSaved){
        NSDate *dt = [TimeConverter dateFromTimestamp:sh.timestamp.integerValue];
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"hh:mm a"];
        NSString *str = [formatter stringFromDate:dt];
        dtLblconstraint.constant = 40;
        usrNmLblTrailing.constant = 50;
        dtLbl.text = str;
    }
    else{
        NSDate *dt = [TimeConverter dateFromTimestamp:sh.timestamp.integerValue];
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM/dd/YYYY-hh:mm a"];
        NSString *str = [formatter stringFromDate:dt];
        dtLblconstraint.constant = 80;
        dtLbl.text = str;
    }
    DLog(@"%@", sh.text);
    
        
        //textView.text = [sh.text withoutWhiteSpaceString];
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
        textViewHeightConstarint.constant = sizeThatShouldFitTheContent.height;

        textView.scrollEnabled = NO; //YES;  //by nim chat#14
        textViewImg.scrollEnabled = NO; //YES;  //by nim chat#14
        shTextLbl.userInteractionEnabled = YES;
        
        
        if (sh.text != nil){
            //formatting: urls & phonenumber in bold
            NSMutableAttributedString *attributedTxt1 = [Common getAttributedString:sh.text withFontSize:textViewImg.font.pointSize];
            textViewImg.attributedText = attributedTxt1;
        }else{
            textViewImg.text = [sh.text withoutWhiteSpaceString];
        }
        textViewImg.tintColor = [UIColor whiteColor];
        textViewImg.textColor = [UIColor whiteColor];
        textViewImg.dataDetectorTypes = UIDataDetectorTypeAll;
        textView.delegate = self;
        textViewImg.selectable = YES;
        textViewImg.editable = NO;
        
//  //  [shTextLbl setFrameAsTextStickToWidth:shTextLbl.frame.size.width];
//   // [player stopAudio];
//   // player.hidden=YES;
    
    if (sh.type.integerValue == ShoutTypeImage) {
        
        if([textViewImg.text isEqualToString:@""]|| textViewImg.text == nil){
            textViewImg.hidden = YES;
            img_tail.hidden =  YES; // by nim chat#11
            _profileImgBtn1.hidden =  YES; // by nim chat#11
        }
        else{
            textViewImg.hidden = NO;
        }
             //  if (sh.isShoutRecieved.boolValue == YES) {
                   
                   DLog(@"%@", sh.contentUrl);
                   
            [_imgView sd_setImageWithURL:[NSURL URLWithString:URLForShoutContent(sh.shId, @"png")] placeholderImage:[UIImage imageNamed:@"UserIcon"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
                [_imgView setImage:image];
                
            }];
//        }
//        else{
//            _imgView.image = nil;
//        }
    } else if(sh.type.integerValue==ShoutTypeVideo){
        if([textViewImg.text isEqualToString:@"" ]|| textViewImg.text == nil){
            textViewImg.hidden = YES;
            img_tail.hidden =  YES; // by nim chat#11
            _profileImgBtn1.hidden =  YES; // by nim chat#11
        }
        else{
            textViewImg.hidden = NO;
        }
        
      //  if (sh.isShoutRecieved.boolValue == YES) {
          dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                UIImage *img = [self getImageFromContentURL:sh.contentUrl];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_imgView setImage:img];
                });
            });
            
            //            [_imgView sd_setImageWithURL:[NSURL URLWithString:URLForShoutContent(sh.shId, @"png")] placeholderImage:_imgView.image completed:^(UIImage image, NSError error, SDImageCacheType cacheType, NSURL *imageURL)
            //            {
            //
            //            }];
            
//        }        else{
//            _imgView.image = nil;
//        }
    }
    else if(sh.type.integerValue == ShoutTypeAudio){
        if([textViewImg.text isEqualToString:@"" ]|| textViewImg.text == nil){
            textViewImg.hidden = YES;
            img_tail.hidden =  YES; // by nim chat#13
            _profileImgBtn1.hidden =  YES; // by nim chat#13
        }
        else{
            textViewImg.hidden = NO;
        }
        
        if (sh.isShoutRecieved.boolValue == YES) {
            NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sh.contentUrl];
            [self addPlayer:[NSURL URLWithString:path]];
        }
    }
    else if(sh.type.integerValue == ShoutTypeGif){
        if([textViewImg.text isEqualToString:@"" ]|| textViewImg.text == nil){
            textViewImg.hidden = YES;
            
            img_tail.hidden =  YES; // by nim chat#18
            _profileImgBtn1.hidden =  YES; // by nim chat#18
        }
        else{
            textViewImg.hidden = NO;
        }
        
        
      //  if (sh.isShoutRecieved.boolValue == YES) {
            NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sh.contentUrl];
            NSData *pngData = [NSData dataWithContentsOfFile:path];
            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:pngData];
            self._imgViewYGF.animatedImage = image;
            pngData = nil;
            path = nil;
//        }
//        else{
//            self._imgViewYGF.animatedImage = nil;
//        }
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
    //_btnRebroadcast.hidden = YES;
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

- (void)addPlayer:(NSURL*)url{
    if(player == nil){
        player = [LHAudioPlayerView playerView];
        
        
        CGRect rect = textView.frame;
        rect.origin.y = 47;
        rect.origin.x = 18;
        rect.size.width = self.frame.size.width - rect.origin.x*2;
        
        
        if (player) {
            rect = player.frame;

            rect.origin.y = _profileImgBtn.frame.origin.y + 10;//_btnFaverate.frame.origin.y+textView.frame.size.height + 80;
            rect.size.width = self.frame.size.width-117;
            
            // by nim chat#13
            
            CGRect rect1;
            if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5){
                //rect1 = CGRectMake(buttonsView.frame.origin.x + buttonsView.frame.size.width-25, buttonsView.frame.origin.y , self.frame.size.width/2, 50);
                rect1 = CGRectMake(_profileImgBtn.frame.origin.x + _profileImgBtn.frame.size.width-20, buttonsView.frame.origin.y , self.frame.size.width/2, 50);
            }else{
            
           rect1 = CGRectMake(_profileImgBtn.frame.origin.x + _profileImgBtn.frame.size.width, buttonsView.frame.origin.y , self.frame.size.width/2 + 10, 50);
            }
            player.frame = rect1; //rect   // by nim chat#13
        }

        
        [self addSubview:player];
    }
    
    player.hidden = NO;
    
    [player setupAudioPlayer:url];
}

#pragma mark - IBAction

- (IBAction)allReplClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
        [_delegate didClickButtonWithTag:CellButtonTag_Reply ForObject:_shoutObj];
}

- (IBAction)replyClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
        [_delegate didClickButtonWithTag:CellButtonTag_Reply ForObject:_shoutObj];
}

- (IBAction)favClicked:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
    {
        [_delegate didClickButtonWithTag:CellButtonTag_Fav ForObject:_shoutObj];
        [self updateFavUIFlag];
    }
}

- (IBAction)profileClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
        [_delegate didClickButtonWithTag:CellButtonTag_Profile ForObject:_shoutObj];
}

- (IBAction)saveVideoPressed:(id)sender{
    
}

- (IBAction)vidoClicked:(id)sender {
    
}

- (IBAction)imageClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
        [_delegate didClickButtonWithTag:CellButtonTag_Image ForObject:_shoutObj];
}

- (IBAction)audioClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
        [_delegate didClickButtonWithTag:CellButtonTag_Audio ForObject:_shoutObj];
}

- (IBAction)rebroadcastClicked:(id)sender {
    //animation stuff
    [_btnRebroadcast setImage:[UIImage imageNamed:@"icon_broadcastgreen"] forState:UIControlStateNormal];
    [self animateButtonInProgress];
    [self performSelector:@selector(removeAllAnimationFromButton) withObject:nil afterDelay:2];
    //animation stuff
    
    if(_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
        [_delegate didClickButtonWithTag:CellButtonTag_All ForObject:_shoutObj];
}
- (IBAction)reportBtnClicked:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(showAlertForReport:)])
        [_delegate showAlertForReport:_shoutObj];
}

-(void)removeAllAnimationFromButton
{
    [_btnRebroadcast.layer removeAllAnimations];
    [_btnRebroadcast setImage:[UIImage imageNamed:@"Image_rebroadcast"] forState:UIControlStateNormal];
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
    if([_shoutObj.reportedShout integerValue] == 1)
    {
        [__btnReport setImage:[UIImage imageNamed:@"ReportIcon_Red"] forState:UIControlStateNormal];
    }
    
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
        else{
          visibility = 1.0 - (float)(secs)*0.5/KCellFadeOutDuration;
        }
        if (visibility<0.4) {
            visibility=0.4;
        }
        
        if (visibility == 0.0)
        {
            DLog(@"Removed key for Path %@",sh.contentUrl);
            [[SDImageCache sharedImageCache] removeImageForKey:sh.contentUrl];
        }
        
        [UIView animateWithDuration:.2 animations:^{
            self.contentView.alpha = visibility;
        }];
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

- (void)updateReportIcon{
    if([_shoutObj.reportedShout integerValue] == 0)
    {
        [__btnReport setImage:[UIImage imageNamed:@"ReportIcon_Red"] forState:UIControlStateNormal];
         self.contentView.alpha = 0.4;
        [_shoutObj setReportedShout:[NSNumber numberWithInteger:1]];
        _profileImgBtn.userInteractionEnabled = NO;
        _btnFaverate.userInteractionEnabled = NO;
        _btnRebroadcast.userInteractionEnabled = NO;
        _btnReplyShouts.userInteractionEnabled = NO;
        _btnReplyShoutsArrow.userInteractionEnabled = NO;
        [DBManager save];

    }


}

-(void)changeTheReportIcon{
    [__btnReport setImage:[UIImage imageNamed:@"ReportIcon_White"] forState:UIControlStateNormal];

}
-(void)hideRebroadCastAndReply{
    
//    CGRect replyShoutsFr = _btnReplyShouts.frame;
//    
//    replyShoutsFr.origin.x = replyShoutsFr.origin.x - 70;
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

-(void)hideFavIcon{
    
    [_btnFaverate setHidden:YES];
    [_btnRebroadcast setHidden:NO];
    [_btnReplyShouts setHidden:NO];
    [_btnReplyShoutsArrow setHidden:NO];
}

-(void)hideAllButtons{
    [_btnFaverate setHidden:YES];
    [_btnRebroadcast setHidden:YES];
    [_btnReplyShouts setHidden:YES];
    [_btnReplyShoutsArrow setHidden:YES];
    [__btnReport setHidden:YES];
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
    if(_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
        [_delegate didClickButtonWithTag:CellButtonTag_Video_Export ForObject:_shoutObj];
}

- (void)singleTapPlayVideo{
    if(_shoutObj.contentUrl&&_delegate && [_delegate respondsToSelector:@selector(didClickButtonWithTag:ForObject:)])
        [_delegate didClickButtonWithTag:CellButtonTag_Video ForObject:_shoutObj];
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
    else if([urlString hasPrefix:@"telprompt:"] || [urlString hasPrefix:@"tel:"])
    {
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:_shoutObj.shId,@"shoutId",_shoutObj.group.grId,@"groupId",temp,@"text",nil];

        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_click_phone_number",@"log_sub_category",_shoutObj.group.grId,@"groupId",_shoutObj.shId,@"shoutId",temp,@"text",detaildict,@"details",nil];
        
        [[NSUserDefaults standardUserDefaults]setObject:urlString forKey:k_phNumberShoutCell];

    }
    
    
    [AppManager saveEventLogInArray:postDictionary];

//    [EventLog addEventWithDict:postDictionary];
// 
//    NSNumber *count = [Global shared].currentUser.eventCount;
//    int value = [count intValue];
//    count = [NSNumber numberWithInt:value + 1];
//    [[Global shared].currentUser setEventCount:count];
//    [DBManager save];
//    
//    
//    if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0)){          //show loader...
//        // [LoaderView addLoaderToView:self.view];
//        [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//    }

    
    return YES;
}

@end
