//
//  BaseViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//


// NOTE: Commenting Validate user API as of now

#import "BaseViewController.h"
#import "LoginViewController.h"
#import "VerPinViewController.h"
#import "BLEManager.h"
#import "BannerAlert.h"
#import "GroupsViewController.h"
#import "LocationManager.h"
#import "SonarViewController.h"
#import "ProgressView.h"
#import "ChangePassViewController.h"
#import "LoaderView.h"
#import "CommsViewController.h"
#import "MediaCommsViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import <REFrostedViewController.h>
//#import "AdvanceSettingsViewController.h"
#import "ManageGroupListController.h"


#define kProgressWidth 50
#define kProgressHeight 30
#define kIPhoneXExtraTabbarHeight 32

@interface BaseViewController ()
{
    AdvanceSettingBottomView *_advanceSettingBottomView; // by nim
    TabBar *_tabbar;
    SecondTabBar *_secondtabbar;
    ProgressView *bakMsgView;
    NSString *temp;
    BOOL isSearchBarOpen;
    UIButton *BLEConnectedorNot;
    NSMutableArray *centralDevices;
    NSMutableArray *periPheralDevices;
    UILabel *connectedBLECountLabel;

}

@property (weak, nonatomic) IBOutlet UILabel *inLabel;
@property (weak, nonatomic) IBOutlet UILabel *outLabel;
@property (assign, nonatomic) DeviceType deviceType;

@end
BOOL validateUser = NO;
@implementation BaseViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDeviceCountUpdate object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kBannerShown object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kUpdateProgressShout object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceCount) name:kDeviceCountUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkStatus) name:kBannerShown object:nil];
    if ([self isKindOfClass:[SettingsViewController class]] || [self isKindOfClass:[ChangePassViewController class]]){}
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessagePRogress:) name:kUpdateProgressShout object:nil];
        [self updateProgressUI];
    }
    [self updateDeviceCount];
    [self updateBLEConnectedIcon];
   // [self setNavBarTitle];

   // [bakMsgView setupView];
}

//-(void)navigationBarButton

- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];
   // self.navigationItem.titleView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _blockedUsers = [NSMutableArray new];
    if ([self isKindOfClass:[SettingsViewController class]] || [self isKindOfClass:[ChangePassViewController class]]) {}
    else
    {
        // [self addProgressView];
    }
    [self addRightButton];
    [self addLefttButton];
    UITapGestureRecognizer *gestureRecognizer = nil;
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    
    BLEConnectedorNot = [[UIButton alloc]initWithFrame:CGRectMake(45, 6, 25, 25)];
    BLEConnectedorNot.tag = 11;
    connectedBLECountLabel = [[UILabel alloc]initWithFrame:CGRectMake(67, 8, 12,12)];
    connectedBLECountLabel.tag = 12;
    connectedBLECountLabel.textColor = [UIColor whiteColor];
    connectedBLECountLabel.font=[UIFont fontWithName:@"Aileron-Regular"  size:12];
    
        for (UIView *bleIcon in self.navigationController.navigationBar.subviews){
            if(([bleIcon isKindOfClass:[UILabel class]] && bleIcon.tag == 12) || ([bleIcon isKindOfClass:[UIButton class]] && bleIcon.tag == 11)){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(![self.navigationController.visibleViewController isKindOfClass:[ManageGroupListController class]])
                [bleIcon removeFromSuperview];
                });
            }
        }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController.navigationBar addSubview:BLEConnectedorNot];
        [self.navigationController.navigationBar addSubview:connectedBLECountLabel];
    });
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLEConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBLEConnectedIcon) name:@"BLEConnected" object:nil];
    
    //[self.view addGestureRecognizer:gestureRecognizer];
    //self.title = @"Providence2GO";
   // [self addNavigationBarViewComponents];

}



- (void)setDeviceType:(enum DeviceType) type {
    if (_deviceType == none) {
        _deviceType = type;
    }
    else if (_deviceType != type) {
        _deviceType = iPhoneAndBbox;
    }
}


- (NSString *)connectedDeviceIconName {
    
    if (_deviceType == iPhone) {
        return @"BLEConnectedViaiPhone.png";
    }
    else if (_deviceType == bbox) {
        return @"BLEConnectedViaBBox.png";
    }
    else if (_deviceType == iPhoneAndBbox) {
        return @"BLEConnectedViaPhoneAndBBox.png";
    }
    
    return @"";
}


-(void)updateBLEConnectedIcon
{
    if (!_bleConnectionQueue) {
        _bleConnectionQueue = [[NSOperationQueue alloc] init];
        _bleConnectionQueue.maxConcurrentOperationCount = 1;
    }
    
    [_bleConnectionQueue addOperationWithBlock:^{

    centralDevices = [[BLEManager sharedManager].centralM.connectedDevices copy];
    
    periPheralDevices =  [[BLEManager sharedManager].perM.connectedCentrals copy];
    dispatch_async(dispatch_get_main_queue(),^{
        connectedBLECountLabel.text = @"";
    });
    _deviceType = none;
    
        if(periPheralDevices != nil && (centralDevices != nil))
        {
            NSInteger deviceTotal = periPheralDevices.count+centralDevices.count;
            if([periPheralDevices count] ==0 && [centralDevices count] >0)
            {
                __block typeof(self) blockSelf = self;
                
                [centralDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    CBPeripheral *peri = [obj objectForKey:Peripheral_Ref];
                    DLog(@"Peripheral Name %@",peri.name);
                    
                    if(([peri.name hasPrefix:@"iP"] || ([peri.name hasPrefix:@"M0000"])) && (peri.state == 2)) {
                    [blockSelf setDeviceType:iPhone];
                }
                else if([peri.name hasPrefix:@"B00000"] && (peri.state == 2)) {
                    [blockSelf setDeviceType:bbox];
                }
            }];
        }
        else if ([centralDevices count] ==0 && [periPheralDevices count] >0)
        {
            _deviceType = iPhone;
        }
        NSString *deviceIconName = [self connectedDeviceIconName];
        dispatch_async(dispatch_get_main_queue(),^{
            connectedBLECountLabel.text = @"";
            if(deviceTotal > 0)
                connectedBLECountLabel.text = [NSString stringWithFormat:@"%ld",deviceTotal];
            [BLEConnectedorNot setImage:[UIImage imageNamed:deviceIconName] forState:UIControlStateNormal];
        });
    }
    }];
}

-(void) hideKeyboard
{
    [searchBarGroup resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return [[BannerAlert sharedBaner] appeared];
}

#pragma mark - Public methods

+ (void)showLogin
{
    
    [[BLEManager sharedManager] flush];
    [BLEManager sharedManager].isRefreshBLE = NO;
    [[BannerAlert sharedBaner] removeFromSuperview];
   // UINavigationController *navC = (UINavigationController *) [[[AppManager appDelegate] window] rootViewController];
    
    //by nim
    //REFrostedViewController *navC = (REFrostedViewController *)[[[AppManager appDelegate] window] rootViewController];
   // BaseViewController *vc = (BaseViewController *) [[navC viewControllers] firstObject];
    
  //  Sonal Commneted
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelAllOperations" object:nil];
    
    BaseViewController *vc = [[BaseViewController alloc]init];
    
    [vc presentLoginWithCompletion:^(BOOL sucess, NSError *error)
     {
         [vc checkVarification];
         [vc updateMe];
         [(GroupsViewController *)vc refreshStateOnLogout];
     }];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];// on logout there should be no badge
   // [navC popToRootViewControllerAnimated:NO];
    REFrostedViewController *navC = (REFrostedViewController *)[[[AppManager appDelegate] window] rootViewController];
    navC = nil;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *obj = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:obj];
    [UIApplication sharedApplication].keyWindow.rootViewController =nil;
    [UIApplication sharedApplication].keyWindow.rootViewController =nav ;
    
}

#pragma mark - Private methods

- (void)addTabbarWithTag:(BarItemTag)barTag
{
    CGSize sz = self.view.bounds.size;
    CGFloat tHieght = 61.3; //47;
    CGRect frame = CGRectMake(0, sz.height-tHieght, sz.width, tHieght);
    _tabbar = [TabBar tabbarWithFrame:frame andSelectedTag:barTag];
    [self.view addSubview:_tabbar];
    [_tabbar addTarget:self andSelector:@selector(tabButtonClicked:)];
}

-(void)checkCountOfShouts{
      [_tabbar checkBadges];
}

-(void)showActionCount:(NSInteger)count{
   // [_tabbar showCount:count];
}

-(void)showCountOnNotificationsTab
{
   // [_tabbar showCountOnNotfTab];
}

-(void)showCountOnChannelTab{
   // [_tabbar showCountOnChlTab];
}

//advanceSettingBar
- (void)addAdvanceSettingView
{
    CGSize sz = self.view.bounds.size;
    CGFloat tHieght = 61.3; //47;
   // CGFloat y = sz.height - tHieght;
   // CGRect frame = CGRectMake(0, sz.height-tHieght, sz.width, tHieght);
  
    CGRect frame = CGRectMake(0, sz.height-tHieght-62, sz.width, 61.3);//y
    _advanceSettingBottomView = [AdvanceSettingBottomView tabbarWithFrame:frame];
    [self.view addSubview:_advanceSettingBottomView];
 
    // _tabbar.selectedItemTag = barTag;
  [_advanceSettingBottomView addTarget:self andSelector:@selector(advanceSettingClicked:)];
    //[advanceSettingBottomView checkBadges];
}

- (CGFloat)tabHieght
{
    return _tabbar.frame.size.height;
}

-(void)setTabOneLineColor:(BarItemTag)barTag
{
    [_tabbar setLineColor:barTag];
}

- (void)addSecondTabbarWithTag: (BarItem)barTag
{
    CGSize sz = self.view.bounds.size;
    CGFloat tHieght = 66;
    CGRect frame = CGRectMake(0, sz.height-47-tHieght, sz.width, tHieght);
    _secondtabbar = [SecondTabBar secondTabbarWithFrame:frame andSelectedTag:barTag];
    [self.view addSubview:_secondtabbar];
    // _tabbar.selectedItemTag = barTag;
    [_secondtabbar addSecondTabTarget:self andSelector:@selector(secondTabBarButtonClicked:)];
    [_secondtabbar checkSecondTabBadges];
}

- (CGFloat)secondTabHeight
{
    return _secondtabbar.frame.size.height;
}

-(void)setLineColor:(NSInteger)barTag
{
    [_secondtabbar setLineColor:barTag];
}

- (void)presentLoginWithCompletion:(void(^)(BOOL sucess, NSError *error))block
{
    LoginViewController *vc = (LoginViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    vc.completion = block;
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
    navC.navigationBarHidden = YES;
    [self presentViewController:navC animated:NO completion:nil];
}

- (BOOL)checkVarification
{
    if (![PrefManager isVarified])
    {
        VerPinViewController *vc = (VerPinViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"VerPinViewController"];
        [self.navigationController pushViewController:vc animated:NO];
        return NO;
    }
    return YES;
}

- (void)updateMe
{
    // [[LHAutoSyncing shared] autoSyncingShouts];
}

- (void)refresh {}

-(void)refreshWithDeleteView{}

-(void)refreshWithManageView{}

- (void)addProgressView
{
    bakMsgView = [ProgressView viewFromNibAtIndex:1];
    bakMsgView.frame = CGRectMake(0, 10, self.view.frame.size.width, 21);
    [self.view addSubview:bakMsgView];
    [bakMsgView setupView];
    bakMsgView.alpha = 0.0;
    [self.view sendSubviewToBack:bakMsgView];
}
- (UIViewController*)getTopVC{
    
    UIViewController *vc1 = [self.navigationController topViewController];
    return vc1;

    
}

- (void)popVC :(UIViewController*)vc{
    
   [self.navigationController popToViewController:vc animated:NO];
}

- (BOOL)isAlreadyInStack:(Class)myClass
{
    UIViewController *vc1 = [self.navigationController topViewController];
    if([vc1 isKindOfClass:myClass])
    {
        [(BaseViewController *)vc1 refresh];
        return YES;
    }
    NSArray *allVc = [self.navigationController viewControllers];
    for(UIViewController *vc in allVc)
    {
        if([vc isKindOfClass:myClass])
        {
            [self.navigationController popToViewController:vc animated:NO];
            
            if([temp isEqualToString:@"Delete"])
            {
                [(BaseViewController *)vc refreshWithDeleteView];
            }
            else if([temp isEqualToString:@"Manage"])
            {
                [(BaseViewController *)vc refreshWithManageView];
            }
            else
            {
                [(BaseViewController *)vc refresh];
            }
            return YES;
        }
    }
    return NO;
}
- (void)advanceSettingClicked:(UIButton *)sender
{
    movetoClassName = @"AdvanceSettingsViewController";
    [self moveToVCClass:movetoClassName];
}
- (void)tabButtonClicked:(UIButton *)sender
{
    BarItemTag option = (BarItemTag)sender.tag;
    switch (option)
    {
        case BarItemTag_Groups:
        {
            if (![self checkVarification]) return; // by nim
            //  [LoaderView addLoaderToView:self.view];
            //  [self validateUserAPI];
            movetoClassName = @"MessagesViewController";//@"GroupsViewController";
            [self moveToVCClass:movetoClassName];
        }
            break;
        case BarItemTag_Channel:
        {
            //movetoClassName = @"NetworkViewController";  // by nim
            movetoClassName = @"ChanelViewController";
            DLog(@"Class here is ###### %@",[self class]);
            //            if(validateUser == 0)
            //            {
            //                [LoaderView addLoaderToView:self.view];
            //                [self validateUserAPI];
            //            }
            //            else
            {
                [self moveToVCClass:movetoClassName];
            }
        } break;
        case BarItemTag_Sonar:
        {
            if ([PrefManager shouldOpenSonar])
            {
                movetoClassName = @"SonarViewController";
                //                if(validateUser == 0)
                //                {
                //                    [LoaderView addLoaderToView:self.view];
                //                    [self validateUserAPI];
                //                }
                //                else
                {
                    [self moveToVCClass:movetoClassName];
                }
            }
            else
                [AppManager showAlertWithTitle:@
                 "" Body:k_permissionAlertSonar];
        } break;
            
            
            //by nim - 4th option
        case BarItemTag_Wallet:
        {
            movetoClassName = @"WalletViewController";
            temp = @"None";
            if (![self checkVarification]) return;
            [self moveToVCClass:movetoClassName];
            
        }break;
            
            
        case BarItemTag_Saved:
        {
            movetoClassName = @"SavedViewController";
            [self moveToVCClass:movetoClassName];
        }
            break;
        case BarItemTag_Setting:
        {
            movetoClassName = @"SettingViewController";
            [self moveToVCClass:movetoClassName];
        }
            break;
        case  BarItemTag_Search:
        {
            if (![self checkVarification]) return;
            movetoClassName = @"SearchViewController";
            [self moveToVCClass:movetoClassName];
        }
            break;
        default: break;
    }
}

- (void)secondTabBarButtonClicked:(UIButton *)sender
{
    BarItem option = (BarItem)sender.tag;
    switch (option)
    {
        case BarItem_Notification:
        {
            movetoClassName = @"NotificationViewController";
            temp = @"None";
        }
            break;
        case BarItem_AddGroup:
        {
            movetoClassName = @"NewGroupViewController";
        }
            break;
        case BarItem_DeleteGroup:
        {
            movetoClassName = @"GroupsViewController";
            temp = @"Delete";
        }
            break;
        case BarItem_ManageGroup:
        {
            movetoClassName = @"GroupsViewController";
            temp = @"Manage";
        }
            break;
        default: break;
    }
    if (![self checkVarification]) return;
    [LoaderView addLoaderToView:self.view];
  //  [self validateUserAPI];
}

- (void)moveToVCClass:(NSString *)className
{
    if(className && className.length)
    {
       // Class myClass = NSClassFromString(className);
       // if(![self isAlreadyInStack:myClass])
        //{
            BaseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:className];
            
            [self.navigationController pushViewController:vc animated:NO];
            [vc refresh];
           
        //}
    }
  }

- (UIViewController*)moveToChannel:(NSString *)className
{
    if(className && className.length)
    {
        //Class myClass = NSClassFromString(className);
//        if(![self isAlreadyInStack:myClass])
//        {
            BaseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:className];
            
            [self.navigationController pushViewController:vc animated:NO];
             return vc;
        //}
    }
    return nil;
}

- (UIViewController*)getChannel:(NSString *)className
{
    
    if(className && className.length)
    {
        //Class myClass = NSClassFromString(className);
       // if(![self isAlreadyInStack:myClass])
       // {
            BaseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:className];
        
            
            return vc;
        //}
    }
    return nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if ([UIApplication sharedApplication].statusBarFrame.size.height>=20)
    {
        CGRect rect = _tabbar.frame;
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                
            case 2436:
                rect.origin.y = self.view.frame.size.height-rect.size.height - kIPhoneXExtraTabbarHeight;
                break;
            default:
                rect.origin.y = self.view.frame.size.height-rect.size.height;
        }
        _tabbar.frame = rect;
    }
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeviceCountUpdate object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBannerShown object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateProgressShout object:nil];
}

- (void)updateMessagePRogress:(NSNotification*)object
{
    NSNumber *status = (NSNumber*)object.object;
    [Global shared].isMessageForwarding = status.boolValue;
    [self updateProgressUI];
}

- (void)updateProgressUI
{
    [self.view bringSubviewToFront:bakMsgView];
    if ([Global shared].isMessageForwarding)
    {
        [UIView animateWithDuration:1.0 animations:^{
            bakMsgView.alpha = 1.0;
        }];
    }
    else
    {
        [UIView animateWithDuration:3.0 animations:^{
            bakMsgView.alpha = 0.0;
        }];
    }
}

- (void)checkStatus
{
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)updateDeviceCount
{
    if(([[BLEManager sharedManager] inCount] > 0) && ([[BLEManager sharedManager] outCount] > 0))
    {
        [AppManager hideAlert];
    }
    if (_inLabel)
    {
        _inLabel.text = [NSString stringWithFormat:@"IN: %li", (long)[[BLEManager sharedManager] inCount]];
    }
    if (_outLabel)
    {
        _outLabel.text = [NSString stringWithFormat:@"OUT: %li", (long)[[BLEManager sharedManager] outCount]];
    }
    if([[BLEManager sharedManager] inCount]  == [[BLEManager sharedManager]outCount]){
        //  [[BLEManager sharedManager]broadcastDataOverBbox];
    }
}

-(void)showCountOfNotifications{
    
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:k_actionableNotify];
    [self showActionCount:[str integerValue]];
}


#pragma mark API call

-(void)validateUserAPI
{
    if(![AppManager isInternetShouldAlert:YES]) {
        [LoaderView removeLoader];
        return;
    }
    DLog(@"user id %@",[Global shared].currentUser.user_id);
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:VALIDATE_USER];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *postDictionary ;
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",nil];
    NSData *myData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:myData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        DLog(@"Response---------->>>>>>>:%@ %@\n", response, error);
        if(error == nil)
        {
            NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
           DLog(@"responseDict is --- %@",dict);
            if(dict !=  NULL)
            {
            BOOL sucess = [[dict objectForKey:@"status"]boolValue];
            NSString *msgStr= [dict objectForKey:@"status"];
            if (sucess || [msgStr isEqualToString:@"Success"])
            {
                validateUser = 1;
                [self moveToVCClass:movetoClassName];
            }
            else
            {
                NSString *str = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
                [AppManager showAlertWithTitle:nil Body:str];
            }
            [LoaderView removeLoader];
        }
        else
            [LoaderView removeLoader];
        }
        else{
            
            NSLog(@"Error in validate user API %@", error.localizedDescription);
            [LoaderView removeLoader];
            [AppManager showAlertWithTitle:nil Body:error.localizedDescription];
        }
    }];
    [dataTask resume];
    [defaultSession finishTasksAndInvalidate];
}
//MARK:- Add left and Right button
- (void)addRightButton
{

    /* righttButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(showSearchBar)]; */
    righttButton = [[UIBarButtonItem alloc]
                  initWithTitle:@"g" style:UIBarButtonItemStylePlain target:self action:@selector(showSearchBar)];
    [righttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = righttButton;
   
  
}

- (void)addLefttButton
{
//    self.searchDisplayController.searchResultsDelegate = self;
//    self.searchDisplayController.searchResultsDataSource = self;
//    self.searchDisplayController.delegate = self;
     leftButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"h" style:UIBarButtonItemStylePlain target:self action:@selector(showREFrostermenu)];
    [leftButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil] 
                              forState:UIControlStateNormal];
    
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
}

- (void)showREFrostermenu {
    // _searchController.searchBar.hidden = YES;
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

-(void)addPanGesture{
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    
}

#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController panGestureRecognized:sender];
}


//MARK:- Search TextField
- (void)showSearchBar {
    
    searchBarGroup = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchBarGroup.delegate = self;
    [searchBarGroup sizeToFit];
    searchBarGroup.userInteractionEnabled =  YES; //temp
    // UISearchController *searchDisplayController = [[UISearchController alloc]initWithSearchResultsController:nil];
    UISearchDisplayController *searchDisplayController= [[UISearchDisplayController alloc] initWithSearchBar:searchBarGroup contentsController:self];
    
    self.navigationItem.titleView = nil;
    
    if (isSearchBarOpen){
        [righttButton  setTitle:@"g"];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOFIFICATION_IF_CANCELLED object:nil];
        isSearchBarOpen = false;
        UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 1;
        titleLabel.text=@"Messages";
        titleLabel.textColor= [UIColor whiteColor];
        [titleLabel sizeToFit];
        
        // set the label to the titleView of nav bar
        self.navigationItem.titleView = titleLabel;


        
    }else{
        
        self.navigationItem.titleView = searchDisplayController.searchBar;
        [searchDisplayController.searchBar sizeToFit];
        
        //manoj
        // change right bar button image to cross
        [righttButton  setTitle:@"u"];
        
        isSearchBarOpen = true;
        //manoj
        [searchBarGroup becomeFirstResponder];
    }
    
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{}


@end
