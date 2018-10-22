//
//  ProfileViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 04/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ProfileViewController : BaseViewController

@property (nonatomic, strong) User *usr;
@property (nonatomic, assign) BarItemTag activeTag;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConst;

@end
