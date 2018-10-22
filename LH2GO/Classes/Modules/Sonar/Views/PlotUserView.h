//
//  PlotUserView.h
//  LH2GO
//
//  Created by Prakash Raj on 03/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@protocol PlotUserViewDelegate;

@interface PlotUserView : UIView
@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, assign) id <PlotUserViewDelegate> delegate;

- (void)showUserLoc:(User *)user uId:(NSString *)uId;
- (void)showName:(NSString *)name;

@end


@protocol PlotUserViewDelegate <NSObject>
@optional
- (void)didSelectUserWithId:(NSString *)uId;

@end
