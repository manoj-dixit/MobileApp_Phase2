//
//  VerPinViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "VerPinViewController.h"
#import "UITextfield+Extra.h"
#import "AFAppDotNetAPIClient.h"
#import "LoaderView.h"
#import "NSString+Extra.h"
#import "NewProfileViewController.h"
#import "Common.h"
#import "SharedUtils.h"

@interface VerPinViewController ()<APICallProtocolDelegate>
{
    __weak IBOutlet UITextField *_codeFld;
    __weak IBOutlet UIButton    *_doneBtn;
    __weak IBOutlet UILabel *lblConfrm_Title;
    __weak IBOutlet UILabel *lbl_txtfldHeading;
    SharedUtils *sharedUtils;
}

- (IBAction)doneclicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end

@implementation VerPinViewController

#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Add Notifications --
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChange:) name:UITextFieldTextDidChangeNotification object:_codeFld];
    [self.navigationController.navigationBar setHidden:true]; // by nim
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [_codeFld resignFirstResponder];
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:true]; // by nim

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    [_codeFld setMargin:12];
    _codeFld.tintColor = [UIColor whiteColor];
    _codeFld.layer.masksToBounds=YES;
    _codeFld.layer.borderColor=[[UIColor colorWithRed:(85.0f/255.0f) green:(85.0f/255.0f) blue:(85.0f/255.0f) alpha:1.0]CGColor];
    _codeFld.layer.borderWidth= 1.0f;
    _doneBtn.enabled = ([_codeFld.text withoutWhiteSpaceString].length);
    _doneBtn.layer.cornerRadius = 24.0f * kRatio;

    // by nim
    //Beizer path
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    /*original one
     [path moveToPoint:CGPointMake(0, 100)]; // bottom left corner
     [path addLineToPoint:CGPointMake(100, 0)]; // top middle
     [path addLineToPoint:CGPointMake(300, 0)]; // top right corner
     [path addLineToPoint:CGPointMake(300, 100)]; // bottom right corner */
    
    [path moveToPoint:CGPointMake(0, 20)]; // bottom left corner
    [path addLineToPoint:CGPointMake(0, 0)]; // top middle
    [path addLineToPoint:CGPointMake(self.view.frame.size.width, 0)]; // top right corner
    // [path addLineToPoint:CGPointMake(self.view.frame.size.width, self.topDiag_View.frame.size.height + self.topDiag_View.frame.size.height/2 )]; // bottom right corner
    [path addLineToPoint:CGPointMake(self.view.frame.size.width, 80 )]; // bottom right corner
    
    //1B3664
    [path closePath];
    layer.path = path.CGPath;
    UIColor *color = [Common colorwithHexString:@"000000" alpha:0.5f];//1B3664
    layer.fillColor = color.CGColor;
    layer.strokeColor = nil;
    [_topDiag_View.layer addSublayer:layer];
    [_topLogo_View sendSubviewToBack:self.view];
    [_topLogo_View setBackgroundColor:color];
    [AppManager showAlertWithTitle:@"Notification" Body:@"Please check your email for your network credentials and verification code to continue."];
    
    // set textsize for whole screen
    [self addToolBarOnKeyboard];
    [self setFontSize];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *defaultCity = @"";
    for (NSDictionary *dic in [[PrefManager defaultUserCityArray] mutableCopy]) {
        if ([[dic valueForKey:@"city_type"] integerValue] == 1) {
            defaultCity = [dic valueForKey:@"id"];
        }
    }
    
    NSMutableDictionary  *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",defaultCity,@"default"
                                            ,[[PrefManager defaultUserCityArray] valueForKey:@"id"],@"options",nil];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,KSetUserCity_List];
    [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
    
}


-(void )setFontSize{
    
    _codeFld.font = [_codeFld.font fontWithSize:[Common setFontSize:_codeFld.font]];
    lbl_txtfldHeading.font = [lbl_txtfldHeading.font fontWithSize:[Common setFontSize:lbl_txtfldHeading.font]];
    lblConfrm_Title.font = [lblConfrm_Title.font fontWithSize:[Common setFontSize:lblConfrm_Title.font]];
    _doneBtn.titleLabel.font = [_doneBtn.titleLabel.font fontWithSize:[Common setFontSize:_doneBtn.titleLabel.font]];
    
}

-(void)addToolBarOnKeyboard
{
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                  target:self action:@selector(doneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    _codeFld.inputAccessoryView = keyboardToolbar;
}

-(void)doneButtonPressed
{
    [_codeFld resignFirstResponder];
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

- (IBAction)btnAction_ResendCode:(id)sender{
    
    if ([AppManager isInternetShouldAlert:YES])
    {
        
        NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"userid", nil];
        
        //show loader...
        [LoaderView addLoaderToView:self.view];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:RESENDVERCODE];
    }
}
- (IBAction)doneclicked:(id)sender
{
    [self checkVerCode];

}


-(void)checkVerCode
{
    [_codeFld resignFirstResponder];
    if(![AppManager isInternetShouldAlert:YES]) return;
    
    if (!_codeFld.text.length)
            {
               [AppManager showAlertWithTitle:nil Body:@"Please enter a code!"];
               return;
         }
    [LoaderView addLoaderToView:self.view];
    DLog(@"user id %@",[Global shared].currentUser.user_id);
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,VERIFYUSER];
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *postDictionary ;
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"userid",_codeFld.text,@"passcode",nil];
    NSData *myData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:myData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [LoaderView removeLoader];
        if(error == nil)
        {
            NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            DLog(@"responseDict is --- %@",dict);
            if(dict != NULL)
            {
            BOOL status = [[dict objectForKey:@"status"] boolValue];
            NSString *msgStr= [dict objectForKey:@"status"];
            if (status || [msgStr isEqualToString:@"Success"])
            {
                [BLEManager sharedManager].isRefreshBLE = YES;
                [PrefManager setVarified:YES];
                [PrefManager setNotfOn:YES];
                [[self.view viewWithTag:300] removeFromSuperview];
                [self.navigationController popViewControllerAnimated:YES];
                [[AppManager appDelegate] AddSidemenu];
                [AppManager initialStuff];
               }
            else
            {
               [AppManager showAlertWithTitle:nil Body:[dict objectForKey:@"message"]];
            }
            }
            [LoaderView removeLoader];
        }
        else{
            NSLog(@"Error is --- %@",error.localizedDescription);

            // [AppManager handleError:error withOpCode:response showMessageStatus:YES];
        }
    }];
    [dataTask resume];
    [defaultSession finishTasksAndInvalidate];
}


- (IBAction)cancelClicked:(id)sender
{
    [BaseViewController showLogin];
}

#pragma mark - Private methods
- (void)handleTextChange:(NSNotification *)notification
{
    _doneBtn.enabled = ([_codeFld.text withoutWhiteSpaceString].length);
}

#pragma mark - Touch Action
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_codeFld resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backClicked:(id)sender
{
[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - SharedUtilsDelegate

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    DLog(@"responseDict is --- %@",responseDict);
    BOOL status = [[responseDict objectForKey:@"status"]boolValue];
    NSString *msgStr= [responseDict objectForKey:@"status"];
    [LoaderView removeLoader];
    if (status || [msgStr isEqualToString:@"Success"])    
    {
        if ([[responseDict valueForKey:@"message"] isEqualToString:@"City id updated for the user..!"]) {
            return;
        }
        [AppManager showAlertWithTitle:@"Alert" Body:[responseDict objectForKey:@"message"]];
//        Printing description of responseDict:
//        {
//            message = "City id updated for the user..!";
//            status = 1;
//        }
    }
    else{
        [AppManager showAlertWithTitle:@"Alert" Body:[responseDict objectForKey:@"message"]];

    }
}


@end
