//
//  BannerAlert.h
//  Kwiky
//
//  Created by Prakash Raj on 23/07/14.
//  Copyright (c) 2014 Segment Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "SavedViewController.h"
#import "LHSavedCommsViewController.h"
#import "LHBackupSessionInfoVC.h"
#import "LHBackupSessionDetailVC.h"
#import "LHBackupSessionViewController.h"
#import "ImageCropViewController.h"
#import "AddGroupViewController.h"
#import "ImageOverlyViewController.h"

#define kAlertHideInterval 5.0

// device tracking
static NSString *kBannerShown     = @"kBannerAppear";

@interface BannerAlert : UIView
@property (nonatomic, assign) BOOL appeared;
@property (nonatomic, copy) NSString *uniqueId;
@property (nonatomic,strong) NSString *bannerData;

@property (nonatomic,strong) NSString *bannerDataString;

// @method : to return shared instance.
+ (instancetype)sharedBaner;
+ (void)showOnView:(UIView *)aView byReducingView:(UIView *)rView atY:(CGFloat)yy
     withbackColor:(UIColor *)clr andMessage:(NSString *)message textColor:(UIColor *)tClr name:(NSString *)name image:(UIImage *)image sendBackToViews:(NSArray *)views shout:(Shout *)shout;
+ (void)showOnView:(UIView *)vv WithName:(NSString *)name text:(NSString *)text image:(UIImage *)image withUniqueId:(NSString*)uid shout:(Shout *)shout;
-(void)refreshBackColor:(UIColor *)clr andMessage:(NSString *)msg textColor:(UIColor *)tClr name:(NSString *)name image:(UIImage *)image shout:(Shout *)shout;
- (void)hideAlertByExpendingView:(UIView *)rView;

@end
