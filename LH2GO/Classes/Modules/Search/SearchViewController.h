//
//  SearchViewController.h
//  LH2GO
//
//  Created by Sonal on 04/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UILabel *foundResultLabel;

@end
