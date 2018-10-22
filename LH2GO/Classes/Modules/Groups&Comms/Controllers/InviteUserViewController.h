//
//  InviteUserViewController.h
//  LH2GO
//
//  Created by Linchpin on 29/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupCollectionCell.h"
#import "MessageCell.h"
#import "GroupUserListView.h"

@protocol InviteUserListViewDelegate;

@interface InviteUserViewController : UIViewController
{
    NSArray *filteredContentList;
     BOOL isSearching;
    Network *network;

}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionInvitee;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UISearchBar *serachBar;
@property (nonatomic, assign) id <InviteUserListViewDelegate> delegate;
@property (nonatomic,strong)  NSMutableArray *selectedUsers;
@property (nonatomic, strong) Group *groupObj;
@property (nonatomic, assign) BOOL isSingleUserInvite;

@property  BOOL showAllUsers;


@end


@protocol InviteUserListViewDelegate <NSObject>

- (void)didInviteUsers:(NSMutableArray *)users andEmails:(NSArray *)emails;
@end

