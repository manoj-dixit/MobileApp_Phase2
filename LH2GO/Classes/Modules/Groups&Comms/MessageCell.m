//
//  messageCell.m
//  LH2GO
//
//  Created by Linchpin on 13/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "MessageCell.h"
#import "BadgeView.h"

@interface MessageCell (){
    User *tempUser;    
}
@end
@implementation MessageCell
@synthesize img_onCell,btnCheck;
- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    //adjust UserImage /ChangeProfileImage Btn size
    CGRect frame ;
    frame = [Common adjustRoundShapeFrame:img_onCell.frame];
    _userImgHeight.constant = frame.size.height;
    _userImgWidth.constant = frame.size.width ;
    
    img_onCell.layer.cornerRadius = img_onCell.frame.size.width * kRatio/2;
    img_onCell.layer.masksToBounds = true;
    img_onCell.userInteractionEnabled = YES;

    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnGroupIcon:)];
    longPressGesture.minimumPressDuration = 1.0;
    [img_onCell addGestureRecognizer:longPressGesture];

    btnCheck.layer.cornerRadius = btnCheck.frame.size.width/2;
    btnCheck.layer.masksToBounds = true;
    btnCheck.layer.borderColor = [UIColor grayColor].CGColor;
    btnCheck.layer.borderWidth = 2.0;
    _pendingLbl.hidden = YES;
    _btn_onCell.userInteractionEnabled = NO;
    _pendingLbl.font = [_pendingLbl.font fontWithSize:[Common setFontSize:_pendingLbl.font]];
    _label_onCell.font = [_label_onCell.font fontWithSize:[Common setFontSize:_label_onCell.font]];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showGroup:(Group *)gr {
    
    DLog(@"%@",gr);
    _label_onCell.text = gr.grName;
    
    if(gr.isPending){
        _pendingLbl.hidden = NO;
        _pendingLbl.text = @"(Pending)";
        img_onCell.alpha = 0.5;
        _label_onCell.alpha = 0.5;
         }else{
        _pendingLbl.hidden = YES;
        img_onCell.alpha = 1.0;
        _label_onCell.alpha = 1.0;
    }
    
    if(gr.isP2PContact)
    {
        _isP2PChat = YES;
    }

    img_onCell.image = nil;
    if(gr.picUrl.length > 0)
    [img_onCell sd_setImageWithURL:[NSURL URLWithString:gr.picUrl]
                  placeholderImage:[UIImage imageNamed:placeholderGroup]];
    else
        img_onCell.image = [UIImage imageNamed:placeholderGroup];
    
    Global  *shared = [Global shared];
    [self updateBadgeOfCell:[DBManager getTotalReceivedShoutsFromShoutsTableForParticularGroup:gr withUser:shared.currentUser.user_id]];
}

- (void)displayUser:(User *)user
{
    tempUser = user;
    _label_onCell.text = user.user_name;
    if(!user.picUrl) {
        img_onCell.backgroundColor = [UIColor yellowColor];
    }
    else{
        [img_onCell sd_setImageWithURL:[NSURL URLWithString:user.picUrl]placeholderImage:[UIImage imageNamed:placeholderUser]];
    }
}

- (void)selectMe:(BOOL)selected
{
    _btn_onCell.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
    if(selected){
        [ _btn_onCell setTitle:@"y" forState:UIControlStateNormal];
    }
    else{
        [ _btn_onCell setTitle:@"w" forState:UIControlStateNormal];
    }
}

- (void)selectForDelete:(BOOL)selected
{
    btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
    if(selected){
        [btnCheck setTitle:@"y" forState:UIControlStateNormal];
        [btnCheck setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
         [btnCheck setTitle:@"w" forState:UIControlStateNormal];
            [btnCheck setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)updateBadgeOfCell:(NSInteger)b
{
    NSInteger marX;
    
    /*  //Don't Delete
     if (IS_IPHONE_6)
     marX = self.contentView.frame.size.width - _label_onCell.frame.origin.x + 20;
     if (IS_IPAD_PRO_1024)
     marX = self.contentView.frame.size.width - _label_onCell.frame.origin.x ;
     else if IS_IPHONE_5
     marX = self.contentView.frame.size.width - _label_onCell.frame.origin.x + 30;
     else if IS_IPHONE_6P
     marX = self.contentView.frame.size.width - _label_onCell.frame.origin.x + 12;
     else
     marX = self.contentView.frame.size.width - _label_onCell.frame.origin.x + 30;
     */
    
    marX = img_onCell.frame.origin.x *kRatioWidth + img_onCell.frame.size.width - 10 ;
    
    if IS_IPAD_PRO_1024
        [BadgeView addBadge:b toView:img_onCell.superview inCorner:badgeCorner_TopLeft marginX:121 marginY:37];
    else
        [BadgeView addBadge:b toView:img_onCell.superview inCorner:badgeCorner_TopLeft marginX:marX marginY:img_onCell.frame.origin.y+12*kRatio];
}

-(void)longPressOnGroupIcon:(UILongPressGestureRecognizer*)longPressGesture
{
    UIView *tappedView = (UIView*)[longPressGesture.view superview];
    MessageCell *messageCell =(MessageCell *)[tappedView superview];
    NSIndexPath *indexPathOfCell;
    if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))) {
        indexPathOfCell = [(UITableView *)[messageCell superview] indexPathForCell:messageCell];
    }
    else{
        indexPathOfCell = [(UITableView*)[[messageCell superview] superview] indexPathForCell:messageCell];
    }
    
//    messageCell.delegate.o
    if(messageCell.isP2PChat){
        return;
    }
    
    
    if (longPressGesture.state == UIGestureRecognizerStateEnded){
        CustomPopOverView *customPopOverView = [[CustomPopOverView alloc] initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width,self.superview.frame.size.height)];
        customPopOverView.delegate=self;
        customPopOverView.tag = 200;
        customPopOverView.indexPathForRow=indexPathOfCell;
        [self.superview.superview addSubview:customPopOverView];
    }
}

-(void)sendBackSelectedRowForCell:(NSString*)actionType withRow:(NSIndexPath*)indexPath{
    if ([self delegate] && [self.delegate respondsToSelector:@selector(sendSelectedTypeForCell:withRow:)]) {
        [self.delegate sendSelectedTypeForCell:actionType withRow:indexPath];
    }
    [[self.superview.superview viewWithTag:200] removeFromSuperview];
}

@end
