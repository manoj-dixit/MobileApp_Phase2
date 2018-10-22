//
//  WalletViewController.m
//  LH2GO
//
//  Created by Sonal on 11/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "WalletViewController.h"

@interface WalletViewController ()

@end

@implementation WalletViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.rightBarButtonItem = nil;
    [self addTabbarWithTag : BarItemTag_Wallet];
    [self addNavigationBarViewComponents];

    // Do any additional setup after loading the view.
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Wallet";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
