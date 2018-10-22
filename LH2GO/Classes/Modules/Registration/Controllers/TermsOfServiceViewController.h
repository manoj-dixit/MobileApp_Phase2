//
//  TermsOfServiceViewController.h
//  LoudHailer
//
//  Created by Kiwitech on 24/09/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TOSDelegate;

@interface TermsOfServiceViewController : UIViewController
@property (nonatomic, assign) id <TOSDelegate> delegate;

@end

@protocol TOSDelegate <NSObject>
@optional
- (void)didAcceptTOS:(BOOL)accept;
@end
