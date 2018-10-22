//
//  LHBackupSessionCell.h
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BackupSessionInfo;
@protocol LHBackupSessionCellDelegate;

@interface LHBackupSessionCell : UITableViewCell

@property (nonatomic, assign)id <LHBackupSessionCellDelegate> delegate;
+ (instancetype)cell;
+ (instancetype)cellAtIndex:(NSInteger)index;
- (void)displayNotification:(ShoutBackup *)shoutBackup;

@end

@protocol LHBackupSessionCellDelegate <NSObject>
@optional
- (void)showBackupsonIndex:(NSInteger)index;
- (void)editBackuponIndex:(NSInteger)index;
@end
