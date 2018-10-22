
//
//  GroupCollectionCell.m
//  LH2GO
//
//  Created by Linchpin on 29/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "GroupCollectionCell.h"
#import "Channels.h"
#import "BadgeView.h"

@interface GroupCollectionCell(){
    User *tempUser;
}
@end

@implementation GroupCollectionCell


-(void)awakeFromNib{
    [super awakeFromNib];
   // [self adjustCellAccordingToDevice];
    _imageUser.layer.cornerRadius= _imageUser.frame.size.width/2;
    _imageUser.layer.masksToBounds =  YES;
    _btnRemove.layer.cornerRadius= _btnRemove.frame.size.width/2;
    _btnRemove.layer.masksToBounds =  YES;
    _btnRemove.layer.borderWidth = 1.2f;
    _btnRemove.layer.borderColor = [UIColor whiteColor].CGColor;
    
}
- (void)displayUser:(User *)user
{
    tempUser = user;
    _UserName.text = user.user_name;
    if(!user.picUrl) {
        _imageUser.backgroundColor = [UIColor yellowColor];
    }
    else{
        [_imageUser sd_setImageWithURL:[NSURL URLWithString:user.picUrl]placeholderImage:[UIImage imageNamed:placeholderUser]];
    }
}

- (void)showGroup:(Group *)gr {
    
    DLog(@"%@",gr);
    _UserName.text = gr.grName;
    
    _imageUser.image = nil;
    
    if (gr.picUrl.length>0) {
            [_imageUser sd_setImageWithURL:[NSURL URLWithString:gr.picUrl]
                          placeholderImage:[UIImage imageNamed:placeholderGroup]];
        
    }else{
        _imageUser.image = [UIImage imageNamed:placeholderGroup];
    }
    Global  *shared = [Global shared];
    [self updateBadgeOfCell:[DBManager getTotalReceivedShoutsFromShoutsTableForParticularGroup:gr withUser:shared.currentUser.user_id]];
}


- (void)showChannel:(Channels *)ch {
    
    //DLog(@"%@",ch);
    _UserName.text = ch.name;
    
    _imageUser.image = nil;
    
    if([ch.isSubscribed isEqualToNumber:[NSNumber numberWithInteger:0]]){
        
        self.contentView.alpha = 0.4;
    }
    else{
        self.contentView.alpha = 1.0;
    }
    //if (ch.image.length>0) {
            [_imageUser sd_setImageWithURL:[NSURL URLWithString:ch.image]
                          placeholderImage:[UIImage imageNamed:placeholderGroup]];
   // }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateBadgeOfCell:ch.contentCount.integerValue];
    });
    

}

-(void)adjustCellAccordingToDevice{
    //set image size
    CGRect frame ;
    frame = [Common adjustRoundShapeFrame:_imageUser.frame];
    _userImgHeight.constant = frame.size.height;
    _userImgWidth.constant = frame.size.width ;
    
    frame = [Common adjustRoundShapeFrame:_btnRemove.frame];
    _btnIconHeight.constant = frame.size.height;
    _btnIconWidth.constant = frame.size.width ;
    
    //set font size
        _UserName.font = [_UserName.font fontWithSize:[Common setFontSize:_UserName.font]];
}

//OLD method
- (void)updateBadgeOfCell1:(NSInteger )badge
{
    
    NSInteger marX;
    
      //Don't delete
     if (IS_IPAD_PRO_1024)
     marX = -28;
     else if IS_IPHONE_5
     marX = 28;
     else if IS_IPHONE_6
     marX = 18;
     else if IS_IPHONE_6P
     marX = 5; 
    
   // marX = (self.contentView.frame.size.width/2+_imageUser.frame.size.width/2)*kRatio;
    [BadgeView addBadge:badge toView:_imageUser.superview inCorner:badgeCorner_TopLeft marginX:marX marginY:_imageUser.frame.origin.y+12*kRatio];
}

//PRESENT method
- (void)updateBadgeOfCell:(NSInteger )badge
{
    NSInteger marX;
    
     /***** EITHER ****/
    
    //Don't delete
    if (IS_IPAD_PRO_1024)
        marX = 48;   //working f9 for topright
    else if IS_IPHONE_5
        marX = 28;   //working f9 for topright
    else if IS_IPHONE_6
        marX = 18;
    else if IS_IPHONE_6P
        marX = 35;   //working f9 for topright
    
    // [BadgeView addBadge:badge toView:_imageUser.superview inCorner:badgeCorner_TopRight marginX:marX marginY:_imageUser.frame.origin.y+12*kRatio];
    
    
    /***** OR ****/
    
    if (IPAD)
        marX = (self.contentView.frame.size.width/2+_imageUser.frame.size.width/2 - 18/2);  //for ipad , badge h/w = 18
    else
        marX = (self.contentView.frame.size.width/2+_imageUser.frame.size.width/2 - 15/2);  //for iphone ,badge h/w = 15
    [BadgeView addBadge:badge toView:_imageUser.superview inCorner:badgeCorner_TopLeft marginX:marX marginY:_imageUser.frame.origin.y+12*kRatio];
    
    
}

@end
