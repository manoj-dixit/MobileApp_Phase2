//
//  PlaceListCollectionCell.h
//  LH2GO
//
//  Created by Parul Mankotia on 03/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceListCollectionCell : UICollectionViewCell

@property(nonatomic, weak) IBOutlet UILabel *cityCodeLabel;
@property(nonatomic, weak) IBOutlet UILabel *cityNameLabel;

-(void)changeCellForNewCity;

-(void)collectionCellManageData:(NSString*)cityString;

@end
