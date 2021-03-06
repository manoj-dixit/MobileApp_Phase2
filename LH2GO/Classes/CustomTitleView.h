//
//  CustomTitleView.h
//  LH2GO
//
//  Created by Parul Mankotia on 02/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectPlaceView.h"
#import "SharedUtils.h"
#import "PlaceListCollectionCell.h"

@protocol CustomViewDelegate<NSObject>
-(void)redirectToChannelScreen;
@end

@interface CustomTitleView : UIView <UICollectionViewDelegate,UICollectionViewDataSource,SelectedCityDelegate,APICallProtocolDelegate,PlaceCellDelegate>
{
    SelectPlaceView *selectPlaceView;
    BOOL fromSignUp;
    BOOL isSelected;
    NSIndexPath *selectedIndexPath;
}

@property (weak, nonatomic) IBOutlet UICollectionView *placeListingCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) NSMutableArray *collectionDataArray;

-(void)showHideNextButton:(BOOL)isFromChannelScreen;
-(void)userSelectedCityList:(NSArray*)selectedArray;

@property (weak,nonatomic) id<CustomViewDelegate>delegate;
-(void) initializeData;
-(void)crossButtonTappedOnCell:(UIButton*)buttonTapped withAccessibilityHint:(NSString*)hintStirng;

@end

