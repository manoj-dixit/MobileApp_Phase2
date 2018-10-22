//
//  GroupCollectionCell.h
//  LH2GO
//
//  Created by Linchpin on 29/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
@property (weak, nonatomic) IBOutlet UIImageView *imageUser;
@property (weak, nonatomic) IBOutlet UILabel *UserName;
@property (weak, nonatomic) IBOutlet UILabel *indicatorLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconWidth;
- (void)displayUser:(User *)user;
- (void)showGroup:(Group *)gr;
- (void)showChannel:(Channels *)ch;
-(void)adjustCellAccordingToDevice;
- (void)updateBadgeOfCell:(NSInteger )badge;
@end
