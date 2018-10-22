//
//  MoreView.h
//  LH2GO
//
//  Created by Sonal on 05/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreViewDelegate<NSObject>
-(void) cancelButtonAction;
-(void) doneButtonAction;
@end

@interface MoreView : UIView <UICollectionViewDelegate,UICollectionViewDataSource>

- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *moreChannelCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *moreInfoChannelCollectionView;
@property (weak,nonatomic) id<MoreViewDelegate>delegate;

@end
