//
//  ManageGroupListController.h
//  LH2GO
//
//  Created by Linchpin on 30/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messageCell.h"
#import "LGPlusButtonsView.h"
#import "Common.h"
#import "ManageViewController.h"

@interface ManageGroupListController : BaseViewController{
    
}
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UIView *view_bottom;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property BOOL isSelected;
@property (weak, nonatomic) NSString *comingFor;
@property (weak, nonatomic) IBOutlet UITableView *tableMessage;
@property (strong,nonatomic)NSMutableArray *datasource;
@end
