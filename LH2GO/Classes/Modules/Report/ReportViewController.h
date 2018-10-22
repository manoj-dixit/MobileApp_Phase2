//
//  ReportViewController.h
//  LH2GO
//
//  Created by Parul Mankotia on 17/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : BaseViewController
{
    __weak IBOutlet UITextField *usrName;
    NSString *reportEmailIs;
}

@property(nonatomic, weak) IBOutlet UIView *selectOptionView;

-(IBAction)reportBugAction:(UIButton*)sender;
-(IBAction)reportUserAction:(UIButton*)sender;

@end
