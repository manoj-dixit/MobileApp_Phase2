//
//  UIViewController+CommonActions.h
//  KLoof
//
//  Created by Prakash Raj on 26/08/13.
//  Copyright (c) 2013 LH2GO. All rights reserved.
//
//  UIViewController : Category  class created to add some common private methods.

#import <UIKit/UIKit.h>

#define kSTATUS_VIEW_TAG 10000

@interface UIViewController (CommonActions)

- (IBAction)goBack:(id)sender;
- (void)setStatusBarColor:(UIColor *)color;
@end
