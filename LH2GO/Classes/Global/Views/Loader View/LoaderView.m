//
//  LoaderView.m
//  SpringerLink
//
//  Created by Prakash Raj on 11/04/12.
//  Copyright (c) 2012 LH2GO. All rights reserved.
//

#import "LoaderView.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface LoaderView()

@property (nonatomic, strong)FLAnimatedImageView *gifView;
@end

@implementation LoaderView

+ (instancetype)sharedLoader
{
    static LoaderView *_sharedLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLoader = [[LoaderView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    return _sharedLoader;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAlpha:1.0];
        _overlayView = [[UIView alloc] initWithFrame:self.bounds];
        [_overlayView setBackgroundColor:[UIColor grayColor]];
        [_overlayView setAlpha:.5];
    }
    return self;
}

#pragma mark - Private Methods -

// @method : To display the HUD in loader view. 
- (void)showLoader:(NSString*)message
{
   // [KLAPPManager appDelegate].window.userInteractionEnabled = NO;
    if(!HUD)
        HUD = [[MBProgressHUD alloc] initWithView:self]; //creat MBProgressHUD object
    [self addSubview:_overlayView];
    [self addSubview:HUD];
    HUD.delegate = self;
    if (message)
        HUD.labelText = message;
    else
        HUD.labelText = @"Loading";
    [HUD show:YES];  // show  HUD in loder view.
}

// @method : To hide the HUD and remove loader view from superview .
- (void)hideLoader
{
   // [KLAPPManager appDelegate].window.userInteractionEnabled = YES;
    [HUD hide:YES];  // hide the HUD from loder view.
    [[_overlayView layer] removeAllAnimations];
    [_overlayView removeFromSuperview];
    [[self layer] removeAllAnimations];
    [self removeFromSuperview];
}

// @method : To reset frame.
- (void)resetFrame
{
    _overlayView.frame = self.bounds;
}

// @method : to rotate HUD forcely (required on orientation sometimes).
- (void)rotateHUDWithAngle:(short)angle
{
    HUD.transform = CGAffineTransformIdentity;
    HUD.transform = CGAffineTransformMakeRotation(degreeToRaian(angle));
    [HUD layoutSubviews];
}

#pragma mark - class methods

/*
 @methods : regarding the loader on screens in case we have to block the UI.
 @discription : since we need to add/remove loader from any screen so pass the view. and call the handleFrameOnOrientation from any view at the time of device orientation.
 */

+ (void)addLoaderToView:(UIView *)view
{
    [LoaderView addLoaderToView:view withMessage:nil];
}

+ (void)addLoaderToView:(UIView *)view withMessage:(NSString*)message
{
    LoaderView *loader = [LoaderView sharedLoader];
    // check if loader is already in desired view.
    if([view.subviews containsObject:loader]) return;
    // remove if loader is anywhere added.
    [loader removeFromSuperview];
    // add loader.
    [view addSubview:loader];
    [loader showLoader:message];
}

+ (void)addAnimatedLoaderToView:(UIView *)view
{
    LoaderView *loader = [LoaderView sharedLoader];
    // check if loader is already in desired view.
    if([view.subviews containsObject:loader.gifView]) return;
    NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loading_image.gif" ofType:nil]];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:gifData];
    CGRect bnd = view.bounds;
    loader.gifView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(bnd.size.width/2-60, bnd.size.height/2-60, 60, 60)];
   // loader.gifView.backgroundColor = [UIColor clearColor];
    loader.gifView.animatedImage = image;
    [view addSubview:loader];
    [view addSubview:loader.gifView];
    
    // notice: before start, content is nil. You can set image for yourself
}

+ (void)removeAnimatedLoader
{
    LoaderView *loader = [LoaderView sharedLoader];
    [loader hideLoader];
    [loader.gifView removeFromSuperview];
    loader.gifView = nil;
    [loader removeFromSuperview];
    loader = nil;
}

+ (void)removeLoader
{
    LoaderView *loader = [LoaderView sharedLoader];
    [loader hideLoader];
    [loader removeFromSuperview];
}

+ (void)handleFrameOnOrientation:(UIInterfaceOrientation)orientation
{
    LoaderView *loader = [LoaderView sharedLoader];
    [loader resetFrame];
}

@end
