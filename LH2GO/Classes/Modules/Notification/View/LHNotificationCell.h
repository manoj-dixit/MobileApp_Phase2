//
//  LHNotificationCell.h
//  LH2GO
//
//  Created by Sumit Kumar on 01/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotificationInfo;

@protocol LHNotificationCellDelegate;

@interface LHNotificationCell : UITableViewCell
{
    __weak IBOutlet UIImageView *_imgView;
    __weak IBOutlet UILabel *_lblUserName;
    __weak IBOutlet UILabel *_lblDateTime;
    __weak IBOutlet UITextView *_labelMsg;
    __weak IBOutlet UIButton *_btnDecline;
    __weak IBOutlet UIButton *_btnAccept;
    __weak IBOutlet UILabel *newNotifbackgroundLabel;
}
@property (nonatomic, assign) id <LHNotificationCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgWidth;

+ (instancetype)cellAtIndex:(NSInteger)index;

- (void)displayNotification:(NotificationInfo *)info;
- (void)displayNotificationOffline:(Notifications *)info;

@end

// LHNotificationCellDelegate
@protocol LHNotificationCellDelegate <NSObject>
@optional
- (void)didAccept:(BOOL)accept onIndex:(NSInteger)index;
@end
