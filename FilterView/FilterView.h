//
//  FilterView.h
//  LH2GO
//
//  Created by Parul Mankotia on 04/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterView : UIView{
    NSMutableArray *filterDataArray;
}

@property(nonatomic, weak) IBOutlet UIScrollView *filterDataScrollView;
@property(nonatomic, weak) IBOutlet UIButton *applyButton;
@property(nonatomic, weak) IBOutlet UIButton *clearAllButton;

-(IBAction)closeButtonAction:(UIButton*)sender;
-(IBAction)applyButtonAction:(UIButton*)sender;
-(IBAction)clearAllButtonAction:(UIButton*)sender;

@end
