//
//  GroupUserListView.h
//  LH2GO
//
//  Created by Prakash Raj on 17/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Group;
@protocol GroupUserListViewDelegate;

@interface GroupUserListView : UIView
@property (nonatomic, assign) id <GroupUserListViewDelegate> delegate;
- (void)reload;
- (void)getUsersAll:(Network*)selectedNetwork;
- (void)getUsersNotInGroup:(Group*)group;
@end


@protocol GroupUserListViewDelegate <NSObject>
@optional
- (void)didCancel;
- (void)didInviteUsers:(NSArray *)users andEmails:(NSArray *)emails;
@end
