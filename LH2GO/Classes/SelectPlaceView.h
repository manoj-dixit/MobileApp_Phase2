//
//  SelectPlaceView.h
//  LH2GO
//
//  Created by Parul Mankotia on 04/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedCityDelegate<NSObject>
-(void)userSelectedCityList:(NSArray*)selectedArray;
@end

@interface SelectPlaceView : UIView<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, weak) IBOutlet UIView *selectionView;
@property(nonatomic, weak) IBOutlet UIButton *countryButton;
@property(nonatomic, weak) IBOutlet UILabel *countryArrowLabel;
@property(nonatomic, weak) IBOutlet UIButton *cityButton;
@property(nonatomic, weak) IBOutlet UILabel *cityArrowLabel;
@property(nonatomic, assign) BOOL isSelected;


-(IBAction)countryDropDownAction:(id)sender;
-(IBAction)cityDropDownAction:(id)sender;
-(IBAction)applyButtonAction:(id)sender;
-(IBAction)cancelButtonAction:(id)sender;

@property (weak,nonatomic) id<SelectedCityDelegate>delegate;



@end
