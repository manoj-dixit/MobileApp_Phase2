//
//  LoaderView.h
//  SpringerLink
//
//  Created by Prakash Raj on 11/04/12.
//  Copyright (c) 2012 LH2GO. All rights reserved.
//
// A class (subclass of UIView) used to displays a simple loader view containing a progress indicator and one optional label for short message.

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class MBProgressHUD;

@interface LoaderView : UIView <MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    UIView        *_overlayView;
}

+ (instancetype)sharedLoader;

// @method : To display the HUD in loader view. 
- (void)showLoader:(NSString*)message;
+ (void)addLoaderToView:(UIView *)view withMessage:(NSString*)message;

// @method : To hide the HUD and remove loader view from superview.
- (void)hideLoader;

// @method : To reset frame.
- (void)resetFrame;

// @method : to rotate HUD forcely (required on orientation sometimes).
- (void)rotateHUDWithAngle:(short)angle;

/*
 @methods : regarding the loader on screens in case we have to block the UI.
 @discription : since we need to add/remove loader from any screen so pass the view. and call the handleFrameOnOrientation from any view at the time of device orientation.
 */

+ (void)addLoaderToView:(UIView *)view;
+ (void)addAnimatedLoaderToView:(UIView *)view;
+ (void)removeLoader;
+ (void)handleFrameOnOrientation:(UIInterfaceOrientation)orientation;
+ (void)removeAnimatedLoader;
@end
