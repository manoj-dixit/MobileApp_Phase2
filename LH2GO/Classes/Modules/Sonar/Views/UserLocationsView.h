//
//  MyView.h
//  test
//
//  Created by Kiwitech on 30/10/14.
//  Copyright (c) 2014 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserLocation.h"

@protocol  UserLocationsViewDelegate;
@interface UserLocationsView : UIView
@property (nonatomic, assign) id <UserLocationsViewDelegate> delegate;

- (void)refreshUsers;
@end


@protocol UserLocationsViewDelegate <NSObject>
- (void)didSelectUser:(UserLocation *)user;
-(void)meClickedDelegate:(UIButton *)btn;
@end
