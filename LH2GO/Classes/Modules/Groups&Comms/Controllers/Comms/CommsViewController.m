//
//  CommsViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 20/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "CommsViewController.h"
#import "NSString+Extra.h"
#import "ShoutInfo.h"
#import "BLEManager.h"
#import "ShoutManager.h"
#import "MediaCommsViewController.h"
#import "LHBackupSessionInfoVC.h"
#import "ImagePickManager.h"
#import "LoaderView.h"
#import "AFAppDotNetAPIClient.h"
#import "RelayView.h"
#import "SharedUtils.h"
#import "CryptLib.h"
#import "NSData+Base64.h"
//#import "SchedulerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "AttachmentOptionView.h"


@interface CommsViewController () <UIAlertViewDelegate, UIActionSheetDelegate,APICallProtocolDelegate>
{
    SharedUtils *sharedUtils;
    NSString *groupID;
    ShoutInfo *shoutSave;
    NSString *buttonName;
    BOOL accepted;
    AttachmentOptionView *attchVieww;
    BOOL isBackupSelected;
}

@end
@implementation CommsViewController
@synthesize popoverController;

- (void)viewWillAppear:(BOOL)animated
{
    validateUser = 1; //Set it to 0 if want to hit validate user API to check if user is blocked or not
    [self.view endEditing:YES];
    [super viewWillAppear:animated];
    [self addTopBarButtons];
   [self enableOrDisableButtons];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_presentScheduler object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentScheduler) name:k_presentScheduler object:nil];
    if (App_delegate.toShowDebug) {
        
        [_firstIndexLabel setHidden:NO];
        [_secondLabelIndex setHidden:NO];
        [_masterOrSlaveCount setHidden:NO];
        [_user_IdLabel setHidden:NO];
        
        _user_IdLabel.text =    [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID]];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:kDeviceCountUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceCount) name:kDeviceCountUpdate object:nil];
        
    }else
    {
        [_firstIndexLabel setHidden:YES];
        [_secondLabelIndex setHidden:YES];
        [_masterOrSlaveCount setHidden:YES];
        [_user_IdLabel setHidden:YES];
        
    }
    if(_isBackFromComms)
    {
        _shInputFld.text =  @"";
        _isBackFromComms = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view setBackgroundColor:[UIColor colorWithRed:(36.0f/255.0f) green:(36.0f/255.0f) blue:(36.0f/255.0f) alpha:1.0]];
}

- (void)updateBadgeCount {
    
    NSArray *allVc;
    if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
    {
        if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
        {
            
            if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                
                if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                    
                    
                    allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                    if (allVc.count>0) {
                        
                    }else
                        return;
                }
                else
                {
                    DLog(@"Not a navigation controller");
                    
                    return;
                }
            }else
            {
                DLog(@"If content view controller not exist");
                
                return;
            }
        }else{
            
            DLog(@"Root view controller is not REFrosted view controller");
            return;
        }
    }
    else if ([UIApplication sharedApplication].keyWindow.rootViewController != nil)
    {
        if([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[REFrostedViewController class]])
        {
            
            if ([((REFrostedViewController*)[UIApplication sharedApplication].keyWindow.rootViewController) contentViewController])
            {
                
                if([[((REFrostedViewController*)[UIApplication sharedApplication].keyWindow.rootViewController) contentViewController] isKindOfClass:[UINavigationController class]])
                {
                    
                    allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].keyWindow.rootViewController) contentViewController] viewControllers];
                    if (allVc.count>0) {
                        
                    }else
                    {
                        return;
                    }
                }
                else
                {
                    DLog(@"Not a navigation controller");
                    
                    return;
                }
            }else
            {
                DLog(@"If content view controller not exist");
                
                return;
            }
        }
        else
        {
            DLog(@"Root view controller is not REFrosted view controller");
            return;
    }
    }
    for(UIViewController *vc in allVc)
    {
        if([vc isKindOfClass: [CommsViewController class]])
        {
            
            if(self.myGroup.totShoutsReceived){
                [self.myGroup clearBadge:self.myGroup];
            }
            
        }
    }
 //   }
}

- (void)updateDeviceCount
{
    
    if([[[[BLEManager sharedManager] centralM] connectedDevices] count] > 0 && [[[[BLEManager sharedManager] perM] connectedCentrals] count] == 0){
        if ([[[BLEManager sharedManager] perM] connectedCentrals] != nil) {
            
            CBPeripheral *per;
            for (NSDictionary *dic in [[[BLEManager sharedManager]  centralM] connectedDevices]) {
                per = [dic objectForKey:Peripheral_Ref];
                
                if(per.state == CBPeripheralStateConnected)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _firstIndexLabel.text = @"M";
                        _secondLabelIndex.text = @"M";
                        _masterOrSlaveCount.text = [NSString stringWithFormat:@"M:%lu",(unsigned long)[[[[BLEManager sharedManager] centralM] connectedDevices] count]];
                    });
                }
            }
        }
    }
    else if([[[[BLEManager sharedManager] centralM] connectedDevices] count] == 0 && [[[[BLEManager sharedManager] perM] connectedCentrals] count] == 1){
        
        @try {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
            if([[[[BLEManager sharedManager] perM] connectedCentrals] count]>0 && [[[BLEManager sharedManager] perM] connectedCentrals] != nil)
            {
                if([[[[[BLEManager sharedManager] perM] connectedCentrals] objectAtIndex:0] objectForKey:Ref_ID] !=nil)
                {
                        _firstIndexLabel.text = [[[[[BLEManager sharedManager] perM] connectedCentrals] objectAtIndex:0] objectForKey:Ref_ID];
                        _secondLabelIndex.text = @"";
                        _masterOrSlaveCount.text = [NSString stringWithFormat:@"S:%lu",(unsigned long)[[[[BLEManager sharedManager] perM] connectedCentrals] count]];
                        
                }
            }
            });
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    else if([[[[BLEManager sharedManager] centralM] connectedDevices] count] == 0 && [[[[BLEManager sharedManager] perM] connectedCentrals] count] == 2){
        
        @try {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if([[[[BLEManager sharedManager] perM] connectedCentrals] count]>0 && [[[BLEManager sharedManager] perM] connectedCentrals]!=nil)
                {
                    
                    if([[[[[BLEManager sharedManager] perM] connectedCentrals] objectAtIndex:0] objectForKey:Ref_ID] !=nil)
                    {
                        _firstIndexLabel.text = [[[[[BLEManager sharedManager] perM] connectedCentrals] objectAtIndex:0] objectForKey:Ref_ID];
                    }
                    if([[[[[BLEManager sharedManager] perM] connectedCentrals] objectAtIndex:1] objectForKey:Ref_ID] !=nil)
                    {
                        
                        _secondLabelIndex.text = [[[[[BLEManager sharedManager] perM] connectedCentrals] objectAtIndex:1] objectForKey:Ref_ID];
                    }
                    
                    _masterOrSlaveCount.text = [NSString stringWithFormat:@"S:%lu",(unsigned long)[[[[BLEManager sharedManager] perM] connectedCentrals] count]];
                }
            });
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _firstIndexLabel.text = @"";
            _secondLabelIndex.text = @"";
            _masterOrSlaveCount.text = @"";
        });
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IPHONE_5)
    {
        CGRect favframe = _shInputFld.frame;
        favframe.origin.x = favframe.origin.x - 20;
        favframe.size.width = favframe.size.width + 35;
        _shInputFld.frame =  favframe;
    }
    _shInputFld.text = @" start typing...";
    _shInputFld.autocorrectionType = UITextAutocorrectionTypeNo;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:k_GotuserSettings object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSettings) name:k_GotuserSettings object:nil];
    
    _shInputFld.textContainerInset = UIEdgeInsetsMake(5, 5, 10, 0);  //(top,left, bottom, right) // by nim chat#3
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    [self shouldShowUserList:NO animated:NO];   // show user list NO
    [self scrollCollectionToIndex];
    [self addNavigationBarViewComponents];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"activeGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeCount) name:@"activeGroup" object:nil];
   self.view.backgroundColor = [Common colorwithHexString:themeColor alpha:1];
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Chats";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

- (void)addTopBarButtons
{
    
    UIBarButtonItem *lefttButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];
    
    
    self.navigationItem.leftBarButtonItem = lefttButton;
    
    
    UIBarButtonItem *rightButton;
    
    //    if (App_delegate.toShowDebug) {
    //
    //        rightButton = [[UIBarButtonItem alloc]
    //                                        initWithTitle:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LoudHailer_ID]] style:UIBarButtonItemStylePlain target:self action:@selector(backUp)];
    //        [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                             [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
    //                                             [UIColor whiteColor], NSForegroundColorAttributeName,
    //                                             nil]
    //                                   forState:UIControlStateNormal];
    //
    //
    //        self.navigationItem.rightBarButtonItem = rightButton;
    //        return;
    //    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    _btnBackupforAnimate =  button;
    [button.titleLabel setFont:[UIFont fontWithName:@"loudhailer" size:25.0]];
    [button setTitle:@"r" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backUp) forControlEvents:UIControlEventTouchUpInside];
    rightButton = [[UIBarButtonItem alloc] initWithCustomView:_btnBackupforAnimate];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

-(void)backUp{
    
    if (isBackupSelected)
    {
        isBackupSelected = NO;
        [_btnBackupforAnimate.layer removeAllAnimations];
        [PrefManager setBackUpStarted:[NSNumber numberWithBool:NO].boolValue];
        //validate is there any shout or backup in progress
        NSArray *arrOfShoutsForBackUp = [DBManager getAllShoutsForBackup:YES];
        if (arrOfShoutsForBackUp.count==0)
        {
            [AppManager showAlertWithTitle:@"Alert" Body:@"There is no communication for backup."];
            return;
        }
        NSDictionary *dicOfArrBackUp = [NSDictionary dictionaryWithObjectsAndKeys:arrOfShoutsForBackUp, @"arrForBackup",  nil];
        [self navigate:dicOfArrBackUp];
    }
    else
    {
        isBackupSelected = YES;
        [self animateBackUpButton];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"BackUp Started!" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        
        [alert show];
        [self performSelector:@selector(byeAlertView:) withObject:alert afterDelay:1.2];
        [PrefManager setBackUpStarted:[NSNumber numberWithBool:YES].boolValue];
        [[NSUserDefaults standardUserDefaults]setObject:self.myGroup.grId forKey:k_groupInWhichBackupStarted];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}


-(void)goBack
{
    if ([PrefManager isBackUpAlreadyInProcess]) {
        [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Backup is in progress. Do you want to discard backup ?" firstButtonMsg:@"YES" andSecondBtnMsg:@"NO" andVC:self noOfBtn:2 completion:^(BOOL isOkButton) {
            
            if (isOkButton) {
                [self.navigationController popViewControllerAnimated:true];
                [PrefManager setBackUpStarted:[NSNumber numberWithBool:NO].boolValue];
                
            }
            
        }];
    }
    else
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    
}

-(void)closebackupButton
{
    isBackupSelected = NO;
    [_btnBackupforAnimate.layer removeAllAnimations];

}

#pragma mark - IBAction
- (IBAction)nextPre_BtnClicked:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isBackupOn = [[defaults objectForKey:@"kBackUp_Key"] intValue];
    if (!isBackupOn)
    {
        UIButton *button = (UIButton *)sender;
        groupsCount = [grps count];
        
        // handle collectionView scroll
        if (button.tag == 101 ){
            if(self.selectedGroupIndex > 0){
                self.selectedGroupIndex -= 1 ;
            }
            // [AppManager showAlertWithTitle:@"" Body:@"Pre Button"];
        }else if (button.tag == 102){

            if(self.selectedGroupIndex < groupsCount - 1 ){
                self.selectedGroupIndex += 1 ;
            }
            //[AppManager showAlertWithTitle:@"" Body:@"Next Button"];
        }
        NSSortDescriptor *sortDescriptor = nil;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
        Group *gr = [arr objectAtIndex:self.selectedGroupIndex];
        [self setMyGroup:gr];
        
        [self sortShouts:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            // [self sortShouts:nil]; //Moving sort shouts out of dispatch
            [_table reloadData];
            [self scrollCollectionToIndex];
            [collectionGroup reloadData];
            
        });
    }
    else
    {
        NSLog(@"Please stop Backup");
        [AppManager showAlertWithTitle:@"Alert" Body:@"Backup is in progress please stop first to continue."];
    }
}

-(void)scrollCollectionToIndex
{
    @try {
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:self.selectedGroupIndex inSection:0];
        [collectionGroup scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

//- (IBAction)startBackupClicked:(id)sender
//{
//    if ([sender isSelected])
//    {
//        [sender setSelected: NO];
//        [_BackupBtn setTitle:@"start backup" forState:UIControlStateNormal];
//        [_BackupBtn.layer removeAllAnimations];
//        [PrefManager setBackUpStarted:[NSNumber numberWithBool:NO].boolValue];
//        //validate is there any shout or backup in progress
//        NSArray *arrOfShoutsForBackUp = [DBManager getAllShoutsForBackup:YES];
//        if (arrOfShoutsForBackUp.count==0)
//        {
//            [AppManager showAlertWithTitle:@"Alert" Body:@"There is no communication for backup."];
//            return;
//        }
//        NSDictionary *dicOfArrBackUp = [NSDictionary dictionaryWithObjectsAndKeys:arrOfShoutsForBackUp, @"arrForBackup",  nil];
//        [self navigate:dicOfArrBackUp];
//        // timer= [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(navigate:) userInfo:dicOfArrBackUp repeats:NO];
//    }
//    else
//    {
//        [sender setSelected: YES];
//        [_BackupBtn setTitle:@"backup in progress" forState:UIControlStateNormal];
//        [self animateButtonInProgress];
//        [PrefManager setBackUpStarted:[NSNumber numberWithBool:YES].boolValue];
//    }
//}

- (IBAction)hitShoutclicked:(id)sender
{
    validateUser = 1;
    [_shInputFld becomeFirstResponder];
    // [_table setBackgroundColor:[UIColor magentaColor]];
    _bottomInpView.translatesAutoresizingMaskIntoConstraints = YES;
    
    //commented for emoji
    /* if(IS_IPHONE_6P)
     {
     _bottomInpView.frame = CGRectMake(_bottomInpView.frame.origin.x, self.view.frame.size.height - 303, _bottomInpView.frame.size.width, _bottomInpView.frame.size.height);
     _table.frame =  CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width, 240);
     }
     else if (IS_IPHONE_6)
     {
     _bottomInpView.frame = CGRectMake(_bottomInpView.frame.origin.x, self.view.frame.size.height - 295, _bottomInpView.frame.size.width, _bottomInpView.frame.size.height);
     _table.frame =  CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width, 201);
     }
     else if(IS_IPHONE_5)
     {
     _bottomInpView.frame = CGRectMake(_bottomInpView.frame.origin.x, self.view.frame.size.height - 282, _bottomInpView.frame.size.width, _bottomInpView.frame.size.height);
     _table.frame =  CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width, 130);
     
     }*/
    buttonName = @"Send";
    // Remove white space
    NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
    // if user is validated and as well as there is any text to be send
    if(validateUser == 0 && txt.length>0)
    {
        [LoaderView addLoaderToView:self.view];
        [self validateUserAPIComms];
    }
    else
    {
        [self sendButtonAction];
    }
}

- (IBAction)shoutClicked:(id)sender
{
    buttonName = @"B-Box";
    if(validateUser == 0)
    {
        [LoaderView addLoaderToView:self.view];
        [self validateUserAPIComms];
    }
    else
    {
        [self bboxButtonAction];
    }
}


- (IBAction)advanceSettingClicked:(id)sender{
    /*AdvanceSettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AdvanceSettingsViewController"];
    Group *group = [grps objectAtIndex:self.selectedGroupIndex];
    vc.delegate = self;
    vc.grp = group;
    vc.previewTxt = [_shInputFld.text withoutWhiteSpaceString];
    [self.navigationController pushViewController:vc animated:NO];*/
}

- (IBAction)camclicked:(id)sender
{
    [self askPhotoLibPermission];
}

- (IBAction)soundClicked:(id)sender
{
    // [self askMicroPhonePermission];
}

#pragma mark Private Methods

-(void)bboxButtonAction
{
    [self.view endEditing:YES];
    NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
    if (!txt.length)
    {
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Please write something!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alrt show]; alrt = nil;
        return;
    }
    DLog(@"The Group id is %@",self.myGroup.grId);
    NSMutableArray *group_ids = [[NSMutableArray alloc]init];
    NSNumber *groupNumber;
    groupNumber = [NSNumber numberWithInt:[self.myGroup.grId intValue]];
    groupID = [NSString stringWithFormat:@"%@",groupNumber];
    [group_ids addObject: groupNumber];
    NSMutableDictionary * postDictionary = [[NSMutableDictionary alloc]init];
    [postDictionary setObject:group_ids forKey:@"group_id"];
    //Make api call
    if ([AppManager isInternetShouldAlert:YES])
    {
        //show loader...
        [LoaderView addLoaderToView:self.view];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:GET_LIST_OF_RELAYS_URL];
    }
}

-(void)sendButtonAction
{
    if ([[BLEManager sharedManager].centralM.connectedDevices count] >0 || [[BLEManager sharedManager].perM.connectedCentrals count]>0) {
        
#if TARGET_IPHONE_SIMULATOR
#else
        if ([[BLEManager sharedManager] on] == FALSE)
        {
            [AppManager showAlertWithTitle:@"Alert" Body:@"Please turn on Bluetooth in Settings, When the BT/BLE radio is off, shout will not be sent"];
            return;
        }
#endif
        NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
        if(txt.length > k_MAX_SHOUT_LENGTH)
        {
            txt = [txt substringToIndex:k_MAX_SHOUT_LENGTH];
        }
        if (!txt.length||self.myGroup.grId==nil)
        {
            return;
        }
        
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            ShoutInfo *sh = [ShoutInfo composeText:txt type:ShoutTypeTextMsg content:nil groupId:self.myGroup.grId parentShId:nil p2pChat:self.myGroup.isP2PContact];
            //    _leftLbl.text = [NSString stringWithFormat:@" %i\n Left", k_MAX_SHOUT_LENGTH];
            dispatch_async(dispatch_get_main_queue(), ^{
            _leftLbl.text = [NSString stringWithFormat:@" %i Left", k_MAX_SHOUT_LENGTH]; // by nim
            //            [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"CMS"];
            //            [[NSUserDefaults standardUserDefaults]synchronize];
            });

            [[BLEManager sharedManager] addSh:sh toQueueAt:YES];
            // enter in the list.
            [[ShoutManager sharedManager] enqueueShoutForSender:sh forUpdation:YES];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _shInputFld.text = @"";
            _leftLbl.numberOfLines = 0;
        });
        
    }
    else
    {
        [AppManager showAlertWithTitle:@"" Body:@"You are not connected to any Buki-Box or iPhone via BLE. Please connect first to send"];
    }
}

- (void)shouldShowUserList:(BOOL)show animated:(BOOL)animate
{
    _relayView.listOfRelays.tableFooterView= [[UIView alloc]initWithFrame:CGRectZero];
    CGRect fr = _relayView.frame;
    fr.origin.y = (show)?_table.frame.origin.y : self.view.frame.size.height;
    if (show) [_relayView reload];
    if (!animate)
    {
        _relayView.frame = fr; return;
    }
    [UIView animateWithDuration:.4 animations:^{
        _relayView.frame = fr;
    } completion:^(BOOL finished) {}];
}

-(void)gotSettings
{
    [self enableOrDisableButtons];
}

-(void)enableOrDisableButtons
{
    [_BackupBtn setHidden:![PrefManager shouldOpenSaved]];
    if ([PrefManager isBackUpAlreadyInProcess] == YES)
    {
        if ([PrefManager shouldOpenSaved] == YES)
        {
            [_BackupBtn setSelected: YES];
            [_BackupBtn setTitle:@"backup in progress" forState:UIControlStateNormal];
           // [self animateButtonInProgress];
            [self animateBackUpButton];
            
        }
        else
        {
            [_BackupBtn setTitle:@"start backup" forState:UIControlStateNormal];
            [_BackupBtn.layer removeAllAnimations];
            [PrefManager setBackUpStarted:[NSNumber numberWithBool:NO].boolValue];
        }
    }
}

-(void)navigate:(NSDictionary *)dicOfArrOfShoutsForBackUp
{
    NSArray *arrOfShoutsForBackUp = [dicOfArrOfShoutsForBackUp objectForKey:@"arrForBackup"];
    LHBackupSessionInfoVC *vc = (LHBackupSessionInfoVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHBackupSessionInfoVC"];
    vc.arrOfShoutsForBackUp = arrOfShoutsForBackUp;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)animateButtonInProgress
{
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=1.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    theAnimation.removedOnCompletion = false;
    [_BackupBtn.layer addAnimation:theAnimation forKey:@"animateOpacity"];
}

- (void)animateBackUpButton
{
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.byValue = @(M_PI*2); // Change to - angle for counter clockwise rotation
    theAnimation.duration = 5.0;
    theAnimation.removedOnCompletion = false;
    [_btnBackupforAnimate.layer addAnimation:theAnimation forKey:@"myRotationAnimation"];
}

-(void)byeAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ASK Permissions

-(void)askCameraPermission
{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
            // until iOS 8. So for iOS 7 permission will always be granted.
            if (granted) {
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(accepted){
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) { [_shInputFld resignFirstResponder];}
                        if (k_EnableVideoRecording == 1)
                        {
                            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Capture Video", @"Click image from camera", @"Pick image from library", nil];
                            [sheet showInView:self.view];
                        }
                        else
                        {
                            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Click image from camera", @"Pick image from library", nil];
                            [sheet showInView:self.view];
                        }
                        
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to your camera. To enable access, tap Settings and turn on Camera." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                    alrt.tag = 1001001;
                    [alrt show];
                    alrt = nil;
                });
                // Permission has been denied.
            }
        }];
    } else {
        // We are on iOS <= 6. Just do what we need to do.
        //        [self doStuff];
    }
}

-(void)askPhotoLibPermission
{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if(*stop == NO)
        {
            accepted = 1;
            [self askCameraPermission];
            *stop = YES;
        }
    } failureBlock:^(NSError *error) {
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to Photos. To enable access, tap Settings and turn on Photos." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                alrt.tag = 1001001;
                [alrt show];
                alrt = nil;
            });
            
        }else{
            NSLog(@"Other error code: %li",(long)error.code);
        }
    }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Settings"])
    {
        NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settings])
        {
            [[UIApplication sharedApplication] openURL:settings];
        }
        //Sonal commented to remove warning
        //        if (&UIApplicationOpenSettingsURLString != NULL)
        //        {
        //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        //        }
    }
    else if ([buttonTitle isEqualToString:@"Cancel"]){}
}

#pragma mark- Shared Utils Delegate Method

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    DLog(@"responseDict is --- %@",responseDict);
    BOOL status = [[responseDict objectForKey:@"status"] boolValue];
    NSString *msgStr= [responseDict objectForKey:@"status"];
    if (status || [msgStr isEqualToString:@"Success"])
    {
        if ([responseDict objectForKey:@"method"])
        {
            [AppManager showAlertWithTitle:@"Sent Successfully!!" Body:nil];
            //remove loader from view
            [LoaderView removeLoader];
            _shInputFld.text = @"";
            // enter in the list.
            [[ShoutManager sharedManager] enqueueShout:shoutSave forUpdation:NO];
        }
        else
        {
            //parse response
            NSMutableDictionary *dictOfRelays = [responseDict objectForKey:@"data"];
            NSMutableArray * arrayOfRelays = [dictOfRelays objectForKey:self.myGroup.network.netId];
            [LoaderView removeLoader];
            self.relayView.relaysList = [[NSMutableArray alloc] init];
            [arrayOfRelays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                RelayObject *relayObj = [[RelayObject alloc] initRelayObjectWithDic:obj];
                [self.relayView.relaysList addObject:relayObj];
            }];
            //   NSLog(@"The arrays is %@",self.relayView.relaysList);
            //remove loader from view
            [LoaderView removeLoader];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.relayView.listOfRelays reloadData];
                
            });
            if (self.relayView.relaysList.count > 0)
            {
                //open relay view
                [self shouldShowUserList:YES animated:YES];
            }
        }
    }
    else
    {
        //remove loader
        [LoaderView removeLoader];
        //show alert if relays are not connected
        if(msgStr != nil){
            [AppManager showAlertWithTitle:msgStr Body:nil];
            
        }
    }
}

#pragma mark- Relay View Delegate methods

- (void)didCancelView
{
    [self shouldShowUserList:NO animated:YES];
}

-(void)relaySelectedWithMacId : (NSMutableArray *)macIds
{
    //show loader
    [LoaderView addLoaderToView:self.view];
    //NSLog(@"The array of mac ids is %@",macIds);
    //Make api call to send data
    NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
    ShoutInfo *sh = [ShoutInfo composeText:txt type:ShoutTypeTextMsg content:nil groupId:groupID parentShId:nil p2pChat:NO];
    shoutSave = sh;
    NSData *data = [ShoutManager dataFromObjectForShout:sh];
    NSString *iv = [PrefManager iv];
    const unsigned char *bytes = [data bytes];
    NSUInteger length = [data length];
    NSMutableArray *byteArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < length; i++)
    {
        [byteArray addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
    }
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"advertisement",@"method",@"relays",@"type",macIds,@"ble_mac_ids", byteArray,@"message",[NSNumber numberWithInt:(int)length], @"length",iv,@"iv",@"text",@"message_type",nil];
    if ([AppManager isInternetShouldAlert:YES])
    {
        [sharedUtils makePostCloudAPICall:postDictionary andURL:SEND_DATA_TO_CLOUD_URL];
    }
    //hide view
    [self shouldShowUserList:NO animated:YES];
}


#pragma mark- Relay Delegate methods


-(void)relaySelectedWithMacIdForCMS:(NSMutableArray *)relays displayTime:(NSString*)displayTime startTime:(NSString*)startTime endTime:(NSString*)endTime duration:(NSString*)duration{
    
    [self relayWithMacId:relays duration:duration startTime:startTime endTime:endTime displayTime:displayTime];
}



-(void)relayWithMacId : (NSMutableArray *)macIds duration:(NSString*)duration startTime:(NSString*)startTime endTime:(NSString*)endTime displayTime:(NSString*)displayTime{
    
    Group *group = [grps objectAtIndex:self.selectedGroupIndex];
    //NSLog(@"The array of mac ids is %@",macIds);
    //Make api call to send data
    NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
    ShoutInfo *sh = [ShoutInfo composeText:txt type:ShoutTypeTextMsg content:nil groupId:groupID parentShId:nil p2pChat:NO];
    shoutSave = sh;
    NSData *data = [ShoutManager dataFromObjectForShout:sh];
    NSString *iv = [PrefManager iv];
    const unsigned char *bytes = [data bytes];
    NSUInteger length = [data length];
    NSMutableArray *byteArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < length; i++)
    {
        [byteArray addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
    }
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"advertisement",@"method",@"relays",@"type",macIds,@"ble_mac_ids", byteArray,@"message",[NSNumber numberWithInt:(int)length],"length",iv,@"iv",@"text",@"message_type",@"Scheduler",@"category",displayTime,@"app_display_time",duration,@"duration",startTime,@"start_date_time",endTime,@"end_date_time",group.grId,@"group_id",nil];
    
    
    if ([AppManager isInternetShouldAlert:YES])
    {
        [sharedUtils makePostCloudAPICall:postDictionary andURL:SENDVIASCHEDULER];
    }
    
    
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex >= 3) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        MediaCommsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaCommsViewController"];
        if(buttonIndex == 1)
            vc.mediaType = MediaTypeImageCamera;
        else if (buttonIndex == 2)
            vc.mediaType = MediaTypeImageLibrary;
        else
            vc.mediaType = MediaTypeVideo;
        vc.myGroup = self.myGroup;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

#pragma mark API Call

-(void)validateUserAPIComms
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
    __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                              {
                                                  DLog(@"Response---------->>>>>>>:%@ %@\n", response, error);
                                                  if(error == nil)
                                                  {
                                                      NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                      DLog(@"responseDict is --- %@",dict);
                                                      [LoaderView removeLoader];
                                                      if(dict != NULL)
                                                      {
                                                      if([buttonName isEqualToString:@"Send"])
                                                      {
                                                          BOOL sucess = [[dict objectForKey:@"status"]boolValue];
                                                          NSString *msgStr= [dict objectForKey:@"status"];
                                                          if (sucess || [msgStr isEqualToString:@"Success"])
                                                          {
                                                              validateUser = 1;
                                                              [self sendButtonAction];
                                                          }
                                                          else
                                                          {
                                                              NSString *str = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
                                                              [AppManager showAlertWithTitle:nil Body:str];
                                                          }
                                                      }
                                                      else if([buttonName isEqualToString:@"B-Box"])
                                                      {
                                                          BOOL sucess = [[dict objectForKey:@"status"]boolValue];
                                                          if(sucess)
                                                          {
                                                              validateUser = 1;
                                                              [self bboxButtonAction];
                                                          }
                                                          else
                                                          {
                                                              NSString *str = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
                                                              [AppManager showAlertWithTitle:nil Body:str];
                                                          }
                                                      }
                                                  }
                                                  }
                                              }];
    [dataTask resume];
    [defaultSession finishTasksAndInvalidate];
}



-(void)presentScheduler
{
    /*SchedulerViewController *vc = (SchedulerViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SchedulerViewController"];
    [self presentViewController:vc animated:YES completion:nil];
    // [self.navigationController pushViewController:vc animated:YES];*/
}

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType
{
    if([self.navigationController.topViewController isKindOfClass:[CommsViewController class]])//crash fix , please dont remove this code
    {

    // check owner
    Channels *ch = nil;
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    NSArray *channels = [DBManager getChannelsForNetwork:net];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"channelId"
                                                 ascending:YES];
    channels = [channels sortedArrayUsingDescriptors:@[sortDescriptor]];
    for(Channels *ch1 in channels){
        
        if([ch1.channelId isEqualToString:channelId]){
            if (isClick) {
                if (isClick) {
                    ch = ch1;
                }
            }
        }
    }
    ChanelViewController *cvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]])//crash fix , please dont remove this code
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content,@"content",length,@"length",contentId,@"contentId",cool,@"cool",share,@"share",contact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",@"NO",@"needToMove",[NSNumber numberWithInteger:createdTime],@"created",[NSNumber numberWithBool:feedType],@"feed_Type",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"KX" object:ch userInfo:dict];
        return;
    }
    if (isClick) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content,@"content",length,@"length",contentId,@"contentId",cool,@"cool",share,@"share",contact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",@"NO",@"needToMove",[NSNumber numberWithInteger:createdTime],@"created",[NSNumber numberWithBool:feedType],@"feed_Type",nil];
        cvc = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
        cvc.myChannel = ch;
        cvc.dataDictionary =  dict;
        [self.navigationController pushViewController:cvc animated:YES];
        
    }else
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content,@"content",length,@"length",contentId,@"contentId",cool,@"cool",share,@"share",contact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",@"NO",@"needToMove",[NSNumber numberWithInteger:createdTime],@"created",[NSNumber numberWithBool:feedType],@"feed_Type",nil];
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if(state == UIApplicationStateBackground)
        {
            cvc = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
            [self.navigationController pushViewController:cvc animated:YES];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"KX" object:ch userInfo:dict];
    }
    }
}
@end
