//
//  ChangePassViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 06/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "ChangePassViewController.h"
#import "UITextfield+Extra.h"
#import "AFAppDotNetAPIClient.h"
#import "LoaderView.h"
#import "ForgetPassViewController.h"

@interface ChangePassViewController ()<UITextFieldDelegate>
{
    __weak IBOutlet UITextField *_currentPassFld;
    __weak IBOutlet UITextField *_newPassFld;
    __weak IBOutlet UITextField *_confPassFld;
    __weak IBOutlet UIView *chnagePssView;
    UIBarButtonItem *leftButton;
}

- (IBAction)saveClicked:(id)sender;

@end

@implementation ChangePassViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Change Password";
    [self addPanGesture];
    [self addLeftAndRightButton];
    
    _currentPassFld.delegate  =self;
    _newPassFld.delegate  =self;
    _confPassFld.delegate  =self;
    [self UI];
    // set textsize for whole screen
    [self setFontSize];
    [self setNavBarTitle];
    
    [_currentPassFld setValue:[UIColor colorWithRed:(85.0f/255.0f) green:(85.0f/255.0f) blue:(85.0f/255.0f) alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [_newPassFld setValue:[UIColor colorWithRed:(85.0f/255.0f) green:(85.0f/255.0f) blue:(85.0f/255.0f) alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [_confPassFld setValue:[UIColor colorWithRed:(85.0f/255.0f) green:(85.0f/255.0f) blue:(85.0f/255.0f) alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
  }

-(void )setFontSize{
    _currentPassFld.font = [_currentPassFld.font fontWithSize:[Common setFontSize:_currentPassFld.font]];
    _newPassFld.font = [_newPassFld.font fontWithSize:[Common setFontSize:_newPassFld.font]];
    _confPassFld.font = [_confPassFld.font fontWithSize:[Common setFontSize:_confPassFld.font]];
    _saveButton.titleLabel.font = [_saveButton.titleLabel.font fontWithSize:[Common setFontSize:_saveButton.titleLabel.font]];
}

- (void)setNavBarTitle {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Change Password";
    titleLabel.textColor=[UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)addLeftAndRightButton{
   
        
        leftButton = [[UIBarButtonItem alloc]
                        initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(popView)];
        [leftButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                              [UIColor whiteColor], NSForegroundColorAttributeName,
                                              nil]
                                    forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = leftButton;
    
    
        righttButton = nil;
        self.navigationItem.rightBarButtonItem = righttButton;
}

-(void)popView{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - IBActions
- (IBAction)btnAction_ForgotPassword:(id)sender{
    ForgetPassViewController *vc = (ForgetPassViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ForgetPassViewController"];
    vc.comeBeforeLogin = NO;
    [self.navigationController pushViewController:vc animated:NO];
}
-(void) UI
{
    UIColor *pClr = [UIColor colorWithWhite:1.0 alpha:0.5];//[UIColor whiteColor]; //†kColor(232, 213, 18, 0.5);
    [_currentPassFld setPlaceholderColor:pClr];
    [_newPassFld setPlaceholderColor:pClr];
    [_confPassFld setPlaceholderColor:pClr];
    [_confPassFld setPlaceholderColor:pClr];
    
    _saveButton.clipsToBounds = YES;
    
    //half of the width
    _saveButton.layer.cornerRadius = 24.0f * kRatio;
}

- (IBAction)saveClicked:(id)sender
{
    [self.view endEditing:YES];
    NSString *errTxt;
    if (_currentPassFld.text.length < 6)
    {
        errTxt = @"Password must be at least 6 characters.";
    }
    else if (_newPassFld.text.length < 6)
    {
        errTxt = @"Password must be at least 6 characters.";
    }
    else if (![_newPassFld.text isEqualToString:_confPassFld.text])
    {
        errTxt = @"Password does not match.";
    }
    if (errTxt.length)
    {
        [AppManager showAlertWithTitle:nil Body:errTxt]; return;
    }
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser];
    DLog(@"user id , old pwd , new password is %@ %@ %@",user.user_id,_currentPassFld.text,_newPassFld.text);
    [param setObject : user.user_id            forKey : @"user_id"];
    [param setObject : _currentPassFld.text    forKey : @"oldpassword"];
    [param setObject : _newPassFld.text        forKey : @"newpassword"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client POST:ChangePassPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject){
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        DLog(@"%@", response);
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        // show message
        NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
        [AppManager showAlertWithTitle:nil Body:str];
        if(status)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {}
    }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Erro is %@", error.localizedDescription);

        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
    }];
}

#pragma mark -Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_confPassFld resignFirstResponder];
    [_currentPassFld resignFirstResponder];
    [_newPassFld resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
     if(_newPassFld.text.length > 29 || _currentPassFld.text.length > 29){
         return NO;
     }
     else{
         return YES;
     }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range     replacementString:(NSString *)string
{
    if(textField.tag == 201 || textField.tag == 202 || textField.tag == 203){
        if (textField.text.length < 30 || string.length == 0){
            return YES;
        }
        
        else{
            [AppManager showAlertWithTitle:@"Alert" Body:@"Password length cannot be greater than 30 characters!"];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _currentPassFld)
    {
        [_newPassFld becomeFirstResponder];
    }
    else if (textField == _newPassFld)
    {
        [_confPassFld becomeFirstResponder];
    }
    
    return YES;
}


@end
