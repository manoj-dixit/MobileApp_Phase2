//
//  GroupCollectionViewCell.h
//  LH2GO
//
//  Created by Prakash Raj on 09/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCollectionViewCell : UICollectionViewCell

- (void)showGroup:(Group *)gr;
- (void)shoudAddRedView:(BOOL)add;
- (void)updateBadge:(NSInteger)b;

@end
