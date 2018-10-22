//
//  CustomDropDownView.h
//  LH2GO
//
//  Created by VVDN on 01/11/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDropDown_Cell.h"

@protocol DropDownDelegate <NSObject>
@optional
-(void)didCancelView;
//-(void)relaySelectedWithMacId : (NSMutableArray *)macIds;
-(void)optionSelectedwithIndex : (NSIndexPath *)indexPath;
@end

@interface CustomDropDownView : UIView
@property (weak, nonatomic) IBOutlet UITableView *tblOptions;
@property (nonatomic, strong) NSMutableArray *optionList;
- (void)reload;
@property (nonatomic, weak) id <DropDownDelegate> dropdown_delegate;
@end
