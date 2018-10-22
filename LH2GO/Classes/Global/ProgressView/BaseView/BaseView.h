//
//  BaseView.h
//  Sample Project
//
//  Created by Sumit Kumar on 13/06/14.
//  Copyright (c) 2014 Kiwitech. All rights reserved.
//

//  This class will declare the basic functions of view and handle it as per requirement.

#import <UIKit/UIKit.h>

@interface BaseView : UIView
+(instancetype)viewFromNib;
+(instancetype)viewFromNibAtIndex:(NSInteger)index;
-(void)setupView;
@end
