//
//  UIViewController+CommonActions.m
//  KLoof
//
//  Created by Prakash Raj on 26/08/13.
//  Copyright (c) 2013 LH2GO. All rights reserved.
//

#import "UIViewController+CommonActions.h"
#import "BannerAlert.h"


@implementation UIViewController (CommonActions)

#pragma mark - Private Methods -

- (IBAction)goBack:(id)sender {
    // by nim
    //[[BannerAlert sharedBaner] hideAlertByExpendingView:self.view];
    //[[BannerAlert sharedBaner] setAppeared:NO];
    [self.navigationController popViewControllerAnimated:YES];


}

- (void)setStatusBarColor:(UIColor *)color {
    UIView *statusView = [self.view viewWithTag:kSTATUS_VIEW_TAG];
    if(statusView && [self.view.subviews containsObject:statusView]) {
        [statusView setBackgroundColor:color]; return;
    }
    statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusView.tag = kSTATUS_VIEW_TAG;
    [self.view addSubview:statusView];
    [statusView setBackgroundColor:color];
}

@end
