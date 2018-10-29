//
//  ForgetPassViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 06/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "ForgetPassViewController.h"
#import "ChangePassViewController.h"
#import "AFAppDotNetAPIClient.h"
#import "LoaderView.h"

#import "UITextfield+Extra.h"
#import "NSString+Extra.h"
#import "Common.h"
#import "NewProfileViewController.h"

@interface ForgetPassViewController () <UITextFieldDelegate,UIAlertViewDelegate>
    {
        __weak IBOutlet UITextField *_emailFld;
        __weak IBOutlet UIButton    *_doneBtn;
        __weak IBOutlet UILabel    *lblForgetPswd;
        __weak IBOutlet UILabel    *lbl_maybeTxt;
        __weak IBOutlet UIButton    *_createBtn;
    }
    
- (IBAction)doneClicked:(id)sender;
    
    @end

@implementation ForgetPassViewController
    
- (void)viewWillDisappear:(BOOL)animated
    {
        [_emailFld resignFirstResponder];
        [super viewWillDisappear:animated];
    }
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        if (!_comeBeforeLogin) {
            User *user = [[Global shared] currentUser];
            
            _emailFld.text = user.email ;
            [_emailFld setUserInteractionEnabled:NO];
        }
        _emailFld.autocorrectionType = UITextAutocorrectionTypeNo;
        [_emailFld setMargin:12];
        _doneBtn.layer.cornerRadius = 24.0f*kRatio;


        [_poweredby_view sendSubviewToBack:self.view];
        [self.navigationController.navigationBar setHidden:true];
        
        // set textsize for whole screen
        [self setFontSize];
        
        // for createAccount
        if([[self getPreviousVC] isKindOfClass:[ChangePassViewController class]]){
            _createBtn.hidden = YES;
            lbl_maybeTxt.hidden =  YES;
        }
        
        
    }

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.navigationController.navigationBar setHidden:true];
    
}
-(void )setFontSize{
    
    _emailFld.font = [_emailFld.font fontWithSize:[Common setFontSize:_emailFld.font]];
    lblForgetPswd.font = [lblForgetPswd.font fontWithSize:[Common setFontSize:lblForgetPswd.font]];
    
    _doneBtn.titleLabel.font = [_doneBtn.titleLabel.font fontWithSize:[Common setFontSize:_doneBtn.titleLabel.font]];
    _createBtn.titleLabel.font = [_createBtn.titleLabel.font fontWithSize:[Common setFontSize:_createBtn.titleLabel.font]];
    
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
    
#pragma mark - IBAction
- (IBAction)doneClicked:(id)sender
    {
        if(![_emailFld.text isValidForEmail])
        {
            [AppManager showAlertWithTitle:@"Alert" Body:@"Please enter a valid email."];
            return;
        }
        [_emailFld resignFirstResponder];
        if(![AppManager isInternetShouldAlert:YES]) return;
        // add loader..
        [LoaderView addLoaderToView:self.view];
        [self forgetPassforEmail:[_emailFld.text withoutWhiteSpaceString] completion:^(BOOL success, NSError *error) {
            [LoaderView removeLoader];
            _emailFld.text = @"";
        }];
    }
    
#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
        [_emailFld resignFirstResponder];
    }
    
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
    {
        [textField resignFirstResponder];
        return YES;
    }
    
#pragma mark -
//+ (void)forgetPassforEmail:(NSString *)email completion:(void (^)(BOOL success, NSError *error))block
//    {
//        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//        [param setObject:email forKey:@"email"];
//        // add token..
//        AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
//        NSString *token = [PrefManager token];
//        [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
//        [client POST:ForgetPassPath parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//            NSLog(@"%@", response);
//            BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
//            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
//         
//            [AppManager goBack:str withvc:self];
//            
//            
//           // [AppManager showAlertWithTitle:nil Body:str];
//            
//            if (block) block(status, nil);
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [AppManager showAlertWithTitle:nil Body:error.localizedDescription];
//            if (block) block(NO, error);
//        }];
//    }
- (void)forgetPassforEmail:(NSString *)email completion:(void (^)(BOOL success, NSError *error))block
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:email forKey:@"email"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    
    DLog(@"shtparam%@",param);
    
    [client POST:ForgetPassPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // if(_isPicSelected)  [formData appendPartWithFileData:imgData name:@"group_photo" fileName:@"grpImage.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        [LoaderView removeLoader];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        
        NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
        [LoaderView removeLoader];
        [self goBack:str andStatus:status];
    }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error is %@",error.localizedDescription);
        [AppManager showAlertWithTitle:nil Body:error.localizedDescription];
        [LoaderView removeLoader];
        
    }];
}

-(void)goBack:(NSString *)MsgBody andStatus:(BOOL)status{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:MsgBody preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
    {
        
        if (status){
            if([[self getPreviousVC] isKindOfClass:[ChangePassViewController class]]){
                self.navigationController.navigationBar.hidden = NO;
            }
            [self.navigationController popViewControllerAnimated:true];
        }

    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


    
    
- (IBAction)backClicked:(id)sender{
//    NSMutableArray *VCs = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
//    UIViewController *vc = VCs[VCs.count-2];
    if([[self getPreviousVC] isKindOfClass:[ChangePassViewController class]]){
        self.navigationController.navigationBar.hidden = NO;
    }
    [self.navigationController popViewControllerAnimated:false];
}

-(UIViewController *)getPreviousVC{
    NSMutableArray *VCs = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
    UIViewController *vc = VCs[VCs.count-2];
    return vc;
}
- (IBAction)backToSignupView:(id)sender
{
    NewProfileViewController *vc =  nil;
    vc = (NewProfileViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NewProfileViewController"];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict
{
      [self.navigationController.navigationBar setHidden:false];
    // check owner
    Group *gr = sht.group;
    CommsViewController *gvc = nil;
    ReplyViewController *rvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[ReplyViewController class]])//crash fix , please dont remove this code
    {
//        ReplyViewController *rv = (ReplyViewController *)self.navigationController.topViewController;
//        [self.navigationController popToRootViewControllerAnimated:YES];
//        rv = nil;
    }
    if([self.navigationController.topViewController isKindOfClass:[CommsViewController class]])//crash fix , please dont remove this code
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KY" object:gr];
        return;
    }
    if(sht.parent_shout==nil)
    {
        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        gvc.myGroup = gr;
        
        NSMutableArray *nets = [NSMutableArray new];
        //   NSString *activeNetId = [PrefManager activeNetId];
        NSArray *networks = [DBManager getNetworks];
        for(Network *net in networks){
            NSArray *groups = [DBManager getShortedGroupsForNetwork:net];
            NSDictionary *d = @{ @"network" : net,
                                 @"groups"  : groups
                                 };
            [nets addObject:d];
            
        }
        
        NSDictionary  *d = [nets objectAtIndex:0];
        NSArray *groups = [d objectForKey:@"groups"];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [groups sortedArrayUsingDescriptors:@[sortDescriptor]];

        __block BOOL isAvailable = false;
        __block NSUInteger index;
        
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            Group *gr1 = obj;
            if ([gr1.grId integerValue] == [gr.grId integerValue]) {
                isAvailable = YES;
                index       = idx;
            }
        }];
        
        if (isAvailable) {
            gvc.selectedGroupIndex = index;
        }
        
        
        [self.navigationController pushViewController:gvc animated:YES];
    }
    else
    {
        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        gvc.myGroup = gr;
        [self.navigationController pushViewController:gvc animated:NO];
        rvc = (ReplyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
        rvc.pShout = sht.parent_shout;
        rvc.myGroup=gr;
        [self.navigationController pushViewController:rvc animated:YES];
    }
    //  clear badge on group.
    if (gr.totShoutsReceived)
    {
        [gr clearBadge:gr];
        //[self updateBadgeForGroup];
    }
}



    @end
