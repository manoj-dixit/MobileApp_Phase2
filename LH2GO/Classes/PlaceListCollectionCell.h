//
//  PlaceListCollectionCell.h
//  LH2GO
//
//  Created by Parul Mankotia on 03/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaceCellDelegate<NSObject>
-(void)crossButtonTappedOnCell:(UIButton*)buttonTapped withAccessibilityHint:(NSString*)hintStirng ;
@end

@interface PlaceListCollectionCell : UICollectionViewCell

@property(nonatomic, weak) IBOutlet UILabel *cityCodeLabel;
@property(nonatomic, weak) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;

-(void)changeCellForNewCity;

-(void)collectionCellManageData:(NSString*)cityString;
- (IBAction)crossClicked:(id)sender;

@property (weak,nonatomic) id<PlaceCellDelegate>delegate;


@end
