//
//  UserCell.h
//  LH2GO
//
//  Created by Prakash Raj on 18/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserCellDelegate;
@interface UserCell : UITableViewCell

@property (nonatomic, assign)id <UserCellDelegate> delegate;

+ (instancetype)cellWithGesture:(BOOL)add;
- (void)displayUser:(User *)user;
- (void)selectMe:(BOOL)selected;
- (void)inviteMe:(BOOL)selected;
- (void)displayEmail:(NSString *)email;
@end


@protocol UserCellDelegate <NSObject>
@optional
- (void)deleteUser:(User*)user withTableCell:(UserCell*)cell;
@end