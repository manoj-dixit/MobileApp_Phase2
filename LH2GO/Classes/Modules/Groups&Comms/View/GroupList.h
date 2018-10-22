//
//  GroupList.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupListDelegate;
@interface GroupList : UIView
@property (nonatomic, assign) id <GroupListDelegate> delegate;
@property (nonatomic, assign) BOOL shouldHighlightOwn;

- (void)refreshData;
- (void)refreshList;

- (void)shouldMarkDeleteMode:(BOOL)mark AtIndex:(NSIndexPath *)indxPath;
- (void)removeGrAtIndexpath:(NSIndexPath *)indexPath;
- (NSInteger)groupsCountInSec:(NSInteger)sec;
- (Group *)groupOnIndexPath:(NSIndexPath *)indxP;
- (void)updateBadgeForGroup:(Group *)gr;




@end


@protocol GroupListDelegate <NSObject>
@optional
- (void)didSelectIndexPath:(NSIndexPath *)indxpath;
@end
