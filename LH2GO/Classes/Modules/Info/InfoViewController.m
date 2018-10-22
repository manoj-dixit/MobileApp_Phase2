//
//  InfoViewController.m
//  LH2GO
//
//  Created by Parul Mankotia on 14/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "InfoViewController.h"
#import "SERVICES.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.rightBarButtonItem = nil;
    
    [_versionView.layer setShadowColor:[UIColor blackColor].CGColor];
    [_versionView.layer setShadowOpacity:0.6];
    [_versionView.layer setShadowRadius:4.0];
    [_versionView.layer setShadowOffset:CGSizeMake(0, 3.0)];
    [_versionView.layer setMasksToBounds:NO];
    
    NSString *version = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    if(App_delegate.toShowDebug)
        [_versionLabel setText:[NSString stringWithFormat:@"Version Number : %@ %@", version, TRANSFER_SERVICE_UUID]];
    else
        [_versionLabel setText:[NSString stringWithFormat:@"Version Number : %@", version]];

    [self addNavigationBarViewComponents];
    [self addTabbarWithTag : BarItemTag_Setting];
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Info";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)didReceiveMemoryWarning {
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
