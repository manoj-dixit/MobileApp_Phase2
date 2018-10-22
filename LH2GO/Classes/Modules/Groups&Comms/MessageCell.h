//
//  messageCell.h
//  LH2GO
//
//  Created by Linchpin on 13/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageCellDelegate<NSObject>
-(void)sendSelectedTypeForCell:(NSString*)actionType withRow:(NSIndexPath*)indexPath;
@end

@interface MessageCell : UITableViewCell<CustomPopOverViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *img_onCell;
@property (weak, nonatomic) IBOutlet UILabel *label_onCell;
@property (weak, nonatomic) IBOutlet UIButton *btn_onCell;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UILabel *pendingLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgWidth;

@property BOOL isP2PChat;


@property (weak,nonatomic) id<MessageCellDelegate>delegate;

- (void)showGroup:(Group *)gr ;
- (void)displayUser:(User *)user;
- (void)selectMe:(BOOL)selected;
- (void)selectForDelete:(BOOL)selected;
- (void)updateBadgeOfCell:(NSInteger)b;

-(void)sendBackSelectedRowForCell:(NSString*)actionType withRow:(NSIndexPath*)indexPath;

@end
