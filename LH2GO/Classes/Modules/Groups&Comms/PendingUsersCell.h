//
//  PendingUsersCell.h
//  LH2GO
//
//  Created by Linchpin on 28/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingUsersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *usrName;

- (void)displayUser:(User *)user;

@end
