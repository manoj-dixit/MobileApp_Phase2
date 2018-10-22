//
//  LoginViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LoginViewController.h"
#import "NewProfileViewController.h"
#import "BLEManager.h"
#import "UIView+Extra.h"
#import "UITextfield+Extra.h"
#import "NSString+Extra.h"
#import "LoaderView.h"
#import "AFAppDotNetAPIClient.h"
#import "BackUpManager.h"
#import <Crashlytics/Crashlytics.h>
#import "Common.h"
#import "VerPinViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
{
    __weak IBOutlet UITextField *_emailfld;
    __weak IBOutlet UITextField *_passFld;
    __weak IBOutlet UIButton    *_enterBtn;
    __weak IBOutlet UIButton    *_forgtPswdBtn;
    __weak IBOutlet UIButton    *_signupBtn;
    __weak IBOutlet UILabel *lbl_Acount;
     BOOL isPasswordIncorrect;
}

// Actions
- (IBAction)newUsrClicked:(id)sender;
- (IBAction)loginClicked:(id)sender;

// Private methods
- (void)handleTextChange:(NSNotification *)notification;
- (void)getLogin;

@end

@implementation LoginViewController
@synthesize topDiag_View,topLogo_View;
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _emailfld.text = @"";
    _passFld.text = @"";
    // Add Notifications --
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_emailfld];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChange:) name:UITextFieldTextDidChangeNotification object:_emailfld];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_passFld];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChange:) name:UITextFieldTextDidChangeNotification object:_passFld];
    
    // remove all objects from the shout
    [App_delegate.cachedShoutDetails removeAllObjects];
    [PrefManager setLoggedIn:NO];
    // disconnect all the ble connections if already connected
    [self disconnetAllBLEConnections];
}

-(void)disconnetAllBLEConnections
{
    NSMutableArray *centralDevices = [[BLEManager sharedManager].centralM.connectedDevices copy];
    NSMutableArray *periPheralDevices =  [[BLEManager sharedManager].perM.connectedCentrals copy];

    NSLog(@"Disconnect all the devices as user is going to log out");
    if([periPheralDevices count] ==0 && [ centralDevices count] >0)
    {
        // if both are connected
        //
        [centralDevices  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CBPeripheral *peri = [obj objectForKey:Peripheral_Ref];
            
            for (CBService *service in peri.services)
            {
                if (service.characteristics != nil) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        
                        [peri setNotifyValue:NO forCharacteristic:characteristic];
                        
                    }
                }
            }
            [ [BLEManager sharedManager].centralM.centralManager cancelPeripheralConnection:peri];
        }];
        
        [ [BLEManager sharedManager].centralM.connectedDevices removeAllObjects];
        [[BLEManager sharedManager].scanTimer invalidate];
        [BLEManager sharedManager].scanTimer = nil;
        
        [[BLEManager sharedManager].addTimer invalidate];
        [BLEManager sharedManager].addTimer = nil;
    }
    else if([periPheralDevices count] >0 && centralDevices ==0)
    {
        // to make sure all the connection will be break
        
        BOOL isSuccess;
        do {
            isSuccess =  [[BLEManager sharedManager].perM.peripheralManager updateValue:[@"02owly" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:[BLEManager sharedManager].perM.transferCharacteristicForShoutsUPDATE onSubscribedCentrals:nil];
            
        } while (isSuccess);
        
        [[BLEManager sharedManager].perM.peripheralManager removeAllServices];
        [[BLEManager sharedManager].perM.connectedCentrals removeAllObjects];
        
        [[BLEManager sharedManager].scanTimer invalidate];
        [BLEManager sharedManager].scanTimer = nil;
        
        [[BLEManager sharedManager].addTimer invalidate];
        [BLEManager sharedManager].addTimer = nil;
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [_emailfld resignFirstResponder];
    [_passFld resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _enterBtn.enabled = (_emailfld.text.length && _passFld.text.length);
    _enterBtn.clipsToBounds = YES;
    _emailfld.autocorrectionType = UITextAutocorrectionTypeNo;

    
    //half of the width
    _enterBtn.layer.cornerRadius = 24.0f*kRatio;
    [topLogo_View sendSubviewToBack:self.view];
    [self.navigationController.navigationBar setHidden:true];
    
    // set textsize for whole screen
    [self setFontSize];
}

-(void )setFontSize{
    
_emailfld.font = [_emailfld.font fontWithSize:[Common setFontSize:_emailfld.font]];
_passFld.font = [_passFld.font fontWithSize:[Common setFontSize:_passFld.font]];
_enterBtn.titleLabel.font = [_enterBtn.titleLabel.font fontWithSize:[Common setFontSize:_enterBtn.titleLabel.font]];
_forgtPswdBtn.titleLabel.font = [_forgtPswdBtn.titleLabel.font fontWithSize:[Common setFontSize:_forgtPswdBtn.titleLabel.font]];
//_signupBtn.titleLabel.font = [_signupBtn.titleLabel.font fontWithSize:[Common setFontSize:_signupBtn.titleLabel.font]];
//lbl_Acount.font = [lbl_Acount.font fontWithSize:[Common setFontSize:lbl_Acount.font]];
    
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


#pragma mark - Public Methods
- (void)parseResponse:(NSDictionary* )response addImage:(UIImage* )image
{
    NSLog(@"LOGIN  RESPONSE IS %@", response);
    if(response != NULL)
    {
    BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
    if(status)
    {
        NSDictionary *data = [response objectForKey:@"userData"];
        NSDictionary *usrDict  = [data objectForKey:@"User"];
        NSString *loudhailerID = [usrDict objectForKey:LoudHailer_ID];
        App_delegate.cloudDebugStatus = [[usrDict objectForKey:Debug_Mode] boolValue];
        [[NSUserDefaults standardUserDefaults] setObject:loudhailerID forKey:LoudHailer_ID];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber  numberWithBool:App_delegate.cloudDebugStatus] forKey:Debug_Mode];
        
        NSArray *networkArray = [data objectForKey:@"Networks"];
        App_delegate.toKnowtheFreshStartOfApp = YES;
        if ([networkArray count]>0)
        {
        NSString *nw_ID   = [[[data objectForKey:@"Networks"] objectAtIndex:0] objectForKey:@"id"];
                // make network id to 6 digits as it's max value can be 6
        if (nw_ID.length || [nw_ID isKindOfClass:(id)[NSNull null]])
        {
            // make network id to 6 digits as it's max value can be 6
            int nw_id_lenght = (int)nw_ID.length;

            for (int i = nw_id_lenght; i < 6; i++) {
                
                nw_ID  = [@"0" stringByAppendingString:nw_ID];
            }
        }
        else
        {
            nw_ID = @"1";
            int nw_id_lenght = (int)nw_ID.length;
            for (int i = nw_id_lenght; i < 6; i++) {
                
                nw_ID  = [@"0" stringByAppendingString:nw_ID];
            }
        }
            [[NSUserDefaults standardUserDefaults] setObject:nw_ID forKey:Network_Id];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
      // Template settimgs for the USer

      UserConfigurationSettings *userconfig =  [UserConfigurationSettings userWithId:[data objectForKey:@"template_settings"] shouldInsert:YES];

        [DBManager save];
    
        NSString *uId = [AppManager sutableStrWithStr:[usrDict objectForKey:@"id"]];
        int uid_lenght = (int)uId.length;

        // make network id to 4 digits as it's max value can be 4


        // To check that current user is Logged in Again as new user
        if ([[[[Global shared] currentUser] user_id] isEqualToString:uId] == FALSE)
        {
            //this condition check if same user login then dont clear the catch (fav and backups)
            [AppManager logOut];
        }
        
        for (int i = uid_lenght; i < 6; i++)
        {
            uId  = [@"0" stringByAppendingString:uId];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:uId forKey:KOWNER_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // token
        NSString *token = [AppManager sutableStrWithStr:[usrDict objectForKey:@"token"]];
        [PrefManager storeToken:token];
        // is verified
        BOOL verfied = [[AppManager sutableStrWithStr:[usrDict objectForKey:@"is_verified"]] integerValue];
        [PrefManager setVarified:verfied];
        // store user..
        
        User *user = [User addUserWithDict:usrDict pic:image];
        [[Global shared] setCurrentUser:user];
        [PrefManager storeUserId:user.user_id];
    
        [AppManager downloadUserSettingsAfterLogin:^(BOOL finished) {
            BOOL isActive = YES;
            NSString *activeNetId = [[PrefManager activeNetId] copy];
            NSArray *nets = [data objectForKey:@"Networks"];
            for (NSDictionary *netD in nets)
            {
                Network *netw = [Network addNetworkWithDict:netD];
                if (isActive&&activeNetId==nil)
                {
                    [PrefManager setActiveNetId:[netw.netId copy]];
                    isActive = NO;
                }
            }
            
            //Sonal commented as Providence App will not have default group
            NSArray *groups = [data objectForKey:@"Groups"];
            for (NSDictionary *gd in groups)
            {
                [Group addGroupWithDict:gd forUsers:@[user] pic:nil pending:NO];
            }
            NSDictionary *channels  = [data objectForKey:@"Channel"];
            NSArray *pvtChannel = [channels objectForKey:@"default"];
            for (NSDictionary *ch in pvtChannel)
            {
                [Channels addChannelWithDict:ch forUsers:@[user] pic:nil isSubscribed:[ch objectForKey:@"subscribe"]];
            }
            NSArray *publicChannel = [channels objectForKey:@"normal"];
            for (NSDictionary *ch in publicChannel)
            {
                [Channels addChannelWithDict:ch forUsers:@[user] pic:nil isSubscribed:[ch objectForKey:@"subscribe"]];
            }
            [BLEManager sharedManager].isRefreshBLE = YES;
            [DBManager save];

            [self loginCompleted:YES];
        }];
        //[self loginCompleted:YES];
    }
    else
    {
        NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
        [AppManager showAlertWithTitle:nil Body:str];
        isPasswordIncorrect = YES;
        
    }
    }
}



#pragma mark - IBAction

- (void)loginCompleted:(BOOL)isLoggedIn
{
    // save in user defaults encryption and decryption
    
    NSString *iv = @"MrbHw-zU63DzbD5G";
    NSString *key = @"029d58ed06c8a31f30458d9fb9e0aa90";
    [PrefManager storeIv:iv];
    [PrefManager storeKey:key];
    
    [PrefManager setLoggedIn: isLoggedIn];
    if(isLoggedIn && [PrefManager isVarified])
    {
        if(self.completion) self.completion (isLoggedIn, Nil);
        // by nim
        //[self dismissViewControllerAnimated:YES completion:nil];
        [[AppManager appDelegate]AddSidemenu];
        
        
        [PrefManager setNotfOn:YES];
        // download user list....
        
        /* Sonal Commented to make login simple, AT Login do login only DO rest of the stuff on respective pages*/
       // [AppManager downloadUsers];
      //  [AppManager downloadActivity];
        //[BackUpManager ShoutsBackupFromServerOnView:nil completion:^(BOOL finished) {}];
        
        [AppManager downloadSecurityKeys];
        [[BLEManager sharedManager] setIsRefreshBLE:YES];
    }
    
    else if(![PrefManager isVarified]){
        
        VerPinViewController *vc = (VerPinViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"VerPinViewController"];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (IBAction)forceCrash:(id)sender
{
    // [[Crashlytics sharedInstance] crash];
}

- (IBAction)newUsrClicked:(id)sender
{
     NewProfileViewController *vc = (NewProfileViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NewProfileViewController"];
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)forgotPasswordTapped:(id)sender
{
    //    [[Crashlytics sharedInstance] crash];
    ForgetPassViewController *vc = (ForgetPassViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ForgetPassViewController"];
    vc.comeBeforeLogin = YES;
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)loginClicked:(id)sender
{
    NSString *errTxt;
    if (![_emailfld.text isValidForEmail])
    {
        errTxt = @"Please Enter a valid email id.";
    }
    else if (_passFld.text.length < 6)
    {
        errTxt = @"Please Enter a valid Password with minimum length 6 characters";
    }
    if (errTxt.length)
    {
        [AppManager showAlertWithTitle:nil Body:errTxt]; return;
    }
    [_emailfld resignFirstResponder];
    [_passFld resignFirstResponder];
    [[NSUserDefaults standardUserDefaults]setObject:_emailfld.text forKey:k_LoginEmail];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[NSUserDefaults standardUserDefaults]setObject:_passFld.text forKey:k_LoginPassword];
    [[NSUserDefaults standardUserDefaults]synchronize];
    // Hit Login Api here..
    [self getLogin];
}

#pragma mark - Private methods

- (void)handleTextChange:(NSNotification *)notification
{
    _enterBtn.enabled = ([_emailfld.text withoutWhiteSpaceString].length && _passFld.text.length);
}

- (void)getLogin
{
    if(![AppManager isInternetShouldAlert:YES]) return;
    
    // add loader..
    [LoaderView addLoaderToView:self.view];
    User *user = [[Global shared] currentUser];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *email = [[NSUserDefaults standardUserDefaults]objectForKey:k_LoginEmail];
    NSString *Password = [[NSUserDefaults standardUserDefaults]objectForKey:k_LoginPassword];
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:k_DeviceToken];
    [param setObject : email  forKey : @"email"];
    [param setObject : Password   forKey : @"password"];
    [param  setObject:  [NSNumber numberWithInteger:currentApplicationId]  forKey :@"application_id"];
    [param setObject:@"1" forKey:@"device_type"];

    if (deviceToken != nil)
        [param setObject:deviceToken forKey:@"device_token"];
    else{
        [LoaderView removeLoader];
        [App_delegate registerForRemoteNotifications];
        [AppManager showAlertWithTitle:@"" Body:@"Registering device token to get updates for you,Please click on login again"];
        return;
        }
    if (user.parent_account_id != nil)
    {
        [param setObject : user.parent_account_id   forKey : @"parent_account_id"];
    }
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    client.securityPolicy.allowInvalidCertificates = YES;
    DLog(@"Login parameters %@",param);
    [client POST:LoginPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        [self parseResponse:response addImage:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoaderView removeLoader];
        [AppManager showAlertWithTitle:nil Body:error.localizedDescription];
    }];
}

#pragma mark - Touch Action
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [_emailfld resignFirstResponder];
    [_passFld resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == _emailfld){
        [_passFld becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    if  ([resultingString rangeOfCharacterFromSet:whitespaceSet].location == NSNotFound){
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(isPasswordIncorrect)
        _passFld.text = @"";
    return YES;
}

@end
