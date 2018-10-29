//
//  BannerAlert.m
//  Kwiky
//
//  Created by Prakash Raj on 23/07/14.
//  Copyright (c) 2014 Segment Tech. All rights reserved.
//

#import "BannerAlert.h"
#import "UIView+Extra.h"
#import "UILabel+Extra.h"
#import "GroupsViewController.h"
#import "MessagesViewController.h"
#import "CommsViewController.h"
#import "GroupList.h"
#import "UIImageView+WebCache.h"
#import "REFrostedViewController.h"
#import "SonarViewController.h"
#import "ChanelViewController.h"
#import "NotificationViewController.h"
#import "InfoViewController.h"
#import "ReportViewController.h"


@interface BannerAlert () {
    
    __weak IBOutlet UILabel *_nameLbl;
    __weak IBOutlet UIImageView *imageV;
    __weak IBOutlet UIImageView *imageVThumb;
    __weak IBOutlet UILabel *_titleLbl;
}
- (IBAction)closeClickd:(id)sender;

@end

@implementation BannerAlert

// @method : to return shared instance.
+ (instancetype)sharedBaner
{
    static BannerAlert *shBaner = nil;
    @synchronized (self)
    {
        if (!shBaner)
        {
            shBaner = [[BannerAlert alloc] initWithFrame:CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, 85)];
            shBaner.layer.cornerRadius = 30;//shBaner.frame.size.height / 2;
            shBaner.layer.masksToBounds = YES;
        }
    }
    return shBaner;
}

+ (void)showOnView:(UIView *)aView byReducingView:(UIView *)rView atY:(CGFloat)yy
     withbackColor:(UIColor *)clr andMessage:(NSString *)message textColor:(UIColor *)tClr name:(NSString *)name image:(UIImage *)image sendBackToViews:(NSArray *)views shout:(Shout *)shout
{
    [[BannerAlert sharedBaner] setAppeared:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerShown object:nil userInfo:nil];
    if (!name) name = @"";
    if (!message) message = @"";
    BannerAlert *banner = [BannerAlert sharedBaner];
    [NSObject cancelPreviousPerformRequestsWithTarget:banner];
    [banner refreshBackColor:clr andMessage:message textColor:tClr name:name image:image shout:shout];
    [banner performSelector:@selector(hideAlertByExpendingView:) withObject:rView afterDelay:kAlertHideInterval];
    // alert view is already is in same view..
    if( [banner superview] == aView) return;     // do nothing.
    
    // alert view is added anywhere else. remove it.
    if([banner superview] != nil) [banner removeFromSuperview];
    
    // add alert on desired view
    [aView addSubview:banner];
    
    for(UIView *av in views)
        [[av superview] bringSubviewToFront:av];
    //[aView sendSubviewToBack:banner];
    
    // set frame less to make animation from top.
    CGRect frame = banner.frame;
    frame.origin.y = yy - frame.size.height;
    banner.frame = frame;
    
    // set desired type, message, frame..
    frame.origin.y = yy;
    
    // reset r view frame.
    CGRect rFrame = rView.frame;
    if(rView && frame.origin.y+frame.size.height>rFrame.origin.y)
    {
        CGFloat margine = frame.size.height;
        rFrame.origin.y = frame.origin.y+frame.size.height;
        rFrame.size.height -= margine;
    }
    // set frame with animation.
    [UIView animateWithDuration:0.4 animations:^{
        CGRect fr = frame;
        if (App_delegate.isCallProgress) {
            fr.origin.y +=40;
        }else{
            if (IS_IPHONE_X) {
                fr.origin.y +=40;
            }
        }
        banner.frame = fr;
        if(rView) rView.frame = rFrame;
    } completion:nil];
}


+ (void)showOnView:(UIView *)vv WithName:(NSString *)name text:(NSString *)text image:(UIImage *)image withUniqueId:(NSString*)uid shout:(Shout *)shout
{
    NSString *userName;
    
    if ([name isKindOfClass:[NSNull class]] || [name isEqualToString:@""] || name == nil) {
        
        userName = @"Unknown";
        
    }else if([name isEqualToString:@"  "])
    {
        userName = @"";
    }else
    {
        userName = name;
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:@"UserIcon"];
    }
    
    [BannerAlert sharedBaner].uniqueId = uid;
    [BannerAlert showOnView:vv byReducingView:nil atY:0 withbackColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1] andMessage:text textColor:nil name:userName image:image sendBackToViews:nil shout:shout];
    [BannerAlert sharedBaner].bannerData = [NSString stringWithFormat:@"%@%@",text,userName];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BannerAlert" owner:self options:nil];
        UIView *tv = (UIView *)[nibs objectAtIndex:0];
        [self addSubview:tv];
        tv.center = self.center;
        tv.frame = self.bounds;
        tv.alpha = 1;
        imageV.layer.cornerRadius = imageV.frame.size.height/2.0;
        [imageV makeCircularWithBorder:1.0 borderColor:[UIColor whiteColor]];
    }
    return self;
}

-(void)refreshBackColor:(UIColor *)clr andMessage:(NSString *)msg textColor:(UIColor *)tClr name:(NSString *)name image:(UIImage *)image shout:(Shout *)shout
{
    [imageVThumb setHidden:YES];//hide for now, we are just showing text as below
    // color update.
    if(clr) self.backgroundColor = clr;
    if(tClr) _titleLbl.textColor = tClr;
    // content update.
    _nameLbl.text = name;
    imageV.image = image;
    if (msg.length==0)
    {
        if (shout.type.integerValue == ShoutTypeImage || shout.type.integerValue == ShoutTypeGif)
        {
            _titleLbl.text = k_MediaFileReceived;
        }
        else if(shout.type.integerValue==ShoutTypeVideo)
        {
            _titleLbl.text = k_MediaFileReceived;
        }
        else if(shout.type.integerValue == ShoutTypeAudio)
        {
            _titleLbl.text = k_MediaFileReceived;
        }
    }
    else
    {
        _titleLbl.text = msg;
    }
}

- (UIImage*)getImageFromContentURL:(NSString*)url
{
    NSString *imagePath = [NSString stringWithFormat:@"Image%@.png", [[url componentsSeparatedByString:@"."] firstObject]];
    UIImage *image = [[SDImageCache sharedImageCache] diskImageForKey:imagePath];
    if (!image)
    {
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:url];
        if (path != nil)
        {
            image = [AppManager getPreViewImg:[NSURL fileURLWithPath:path]];
            [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"Image%@.png", [[url componentsSeparatedByString:@"."] firstObject]]];
        }
    }
    return image;
}

- (void)hideAlertByExpendingView:(UIView *)rView
{
    // set frame less to make animation from top.
    CGRect frame = self.frame;
    frame.origin.y -= frame.size.height;
    
    // reset r view frame.
    CGRect rFrame;
    if(rView)
    {
        rFrame = rView.frame;
        CGFloat margine = frame.size.height;
        rFrame.origin.y -= margine;
        rFrame.size.height += margine;
    }
   [[BannerAlert sharedBaner] setAppeared:NO];
    // set frame with animation.
    [UIView animateWithDuration:0.4 animations:^{
        //commented by nim
        
//        self.frame = frame;
//        if(rView) rView.frame = rFrame;
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBannerShown object:nil userInfo:nil];
    }];
}

#pragma mark - IBAction

- (IBAction)closeClickd:(id)sender
{
    [self hideAlertByExpendingView:nil];
}

- (IBAction)bannerClickd:(id)sender
{
    [self hideAlertByExpendingView:nil]; // by nim
    
    if ([((UINavigationController*)self.window.rootViewController).presentedViewController isKindOfClass:[UIImagePickerController class]])
    {
        return;
    }
    NSString *shoutId =  [BannerAlert sharedBaner].uniqueId;
    
    if (shoutId == nil) {
       // NSArray *tx = [(UINavigationController *)[((REFrostedViewController*)self.window.rootViewController)contentViewController] viewControllers];
        
        BOOL isPrsent = false;
        UIViewController *viewVC;
        for (UIViewController *vc in [(UINavigationController *)[((REFrostedViewController*)self.window.rootViewController)contentViewController] viewControllers]) {
            @autoreleasepool {
                
                if ([vc isKindOfClass:[ChanelViewController class]])
                {
                    [(ChanelViewController *)vc goToChannelScreen:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil] isFromBackground:NO];
                    isPrsent = YES;
                    break;
                }
                viewVC = vc;
                DLog(@"VC name is %@",vc);
            }
        }
        if (!isPrsent) {
            
            if([viewVC isKindOfClass:[SettingsViewController class]])
            {
                [(SettingsViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil] isBackGroundClick:NO];
            }
            else if([viewVC isKindOfClass:[SavedViewController class]])
            {
                [(SavedViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil] isBackGroundClick:NO];
            }
            else if([viewVC isKindOfClass:[LHSavedCommsViewController class]])
            {
                [(LHSavedCommsViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil] isBackGroundClick:NO];
            }
            else if([viewVC isKindOfClass:[LHBackupSessionInfoVC class]])
            {
                [(LHBackupSessionInfoVC *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil]];
            }
            else if([viewVC isKindOfClass:[LHBackupSessionDetailVC class]])
            {
                [(LHBackupSessionDetailVC *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil] isBackGroundClick:NO];
            }
            else if([viewVC isKindOfClass:[LHBackupSessionViewController class]])
            {
                [(LHBackupSessionViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil] isBackGroundClick:NO];
            }
            else if([viewVC isKindOfClass:[InfoViewController class]])
            {
                [(InfoViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil] isBackGroundClick:NO];
            }
            else if([viewVC isKindOfClass:[ReportViewController class]])
            {
                [(ReportViewController *)viewVC goToComunicationScreenForShout:nil isForChannelContent:YES dataDic:[NSDictionary dictionaryWithObjectsAndKeys:[BannerAlert sharedBaner].bannerData ,@"Data",nil] isBackGroundClick:NO];
            }
        }
        return;
    }
    
    
    Shout *shout = [Shout shoutWithId:shoutId shouldInsert:NO];
    Global *shared = [Global shared];
    [DBManager updateShoutsIsReadOnClickingMessages:shout.group.grId withUserID:shared.currentUser.user_id];
    //by nim [hang issue resolved]
    if ([((UIViewController*)self.window.rootViewController).presentedViewController isKindOfClass:[ImageCropViewController class]] || [((UIViewController*)self.window.rootViewController).presentedViewController isKindOfClass:[ImageOverlyViewController class]])
    {
        UIViewController *vc = ((UIViewController*)self.window.rootViewController).presentedViewController;
        [vc dismissViewControllerAnimated:false completion:nil];
        //[(ImageCropViewController*)vc goToComunicationScreenForShout:shout];
    }
    
    
    
    for (UIViewController *vc in [(UINavigationController *)[((REFrostedViewController*)self.window.rootViewController)contentViewController] viewControllers]) {
        [(REFrostedViewController*)self.window.rootViewController hideMenuViewController];
        @autoreleasepool
        {
    // by nim
//    UINavigationController *nvc = (UINavigationController *)[((REFrostedViewController*)self.window.rootViewController)contentViewController] ;
//    UIViewController *vc = [AppManager getTopviewController:nvc];
            if([vc isKindOfClass:[MessagesViewController class]])
            {
                [(MessagesViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
            }
            else if([vc isKindOfClass:[ChanelViewController class]])
            {
                [(ChanelViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil];
            }
            else if([vc isKindOfClass:[SonarViewController class]])
            {
                [(SonarViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
            }
            else if([vc isKindOfClass:[NotificationViewController class]])
            {
                [(NotificationViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
            }
            else if([vc isKindOfClass:[SettingsViewController class]])
            {
                [(SettingsViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
            }
            else if([vc isKindOfClass:[SavedViewController class]])
            {
                [(SavedViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
            }
            else if([vc isKindOfClass:[LHSavedCommsViewController class]])
            {
                [(LHSavedCommsViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
            }
            else if([vc isKindOfClass:[LHBackupSessionInfoVC class]])
            {
                [(LHBackupSessionInfoVC *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil];
            }
            else if([vc isKindOfClass:[LHBackupSessionDetailVC class]])
            {
                [(LHBackupSessionDetailVC *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
            }
            else if([vc isKindOfClass:[LHBackupSessionViewController class]])
            {
                [(LHBackupSessionViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil isBackGroundClick:NO];
            }
            else if([vc isKindOfClass:[AddGroupViewController class]])
            {
                [(AddGroupViewController *)vc goToComunicationScreenForShout:shout isForChannelContent:NO dataDic:nil];
            }
//            else if([vc isKindOfClass:[ImageOverlyViewController class]])
//            {
//                [(ImageOverlyViewController *)vc goToComunicationScreenForShout:shout];
//            }
            
}
    }
}

@end
