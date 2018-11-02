//
//  NewProfileViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "NewProfileViewController.h"

#import "UITextfield+Extra.h"
#import "UIView+Extra.h"
#import "UIImage+Extra.h"
#import "NSString+Extra.h"
#import "ImagePickManager.h"
#import "ImageCropViewController.h"
#import "LoginViewController.h"
#import "AFAppDotNetAPIClient.h"
#import "LoaderView.h"
#import "TermsOfServiceViewController.h"
#import "Common.h"
#import "SharedUtils.h"

@interface NewProfileViewController () <UITextFieldDelegate, UIActionSheetDelegate, TOSDelegate,APICallProtocolDelegate>
{
    __weak IBOutlet UITextField *_usrNmFld;
    __weak IBOutlet UITextField *_emailFld;
    __weak IBOutlet UITextField *_passwordFld;
    __weak IBOutlet UITextField *_confPassFld;
    __weak IBOutlet UIImageView *_usrImageV;
    __weak IBOutlet UIButton    *_enterBtn;
    
    __weak IBOutlet UIButton *btnSignIn;
    
    __weak IBOutlet UILabel *lbl_acount;
    BOOL _isPicSelected;
    BOOL _isAgree;
    SharedUtils *sharedUtils;
    NSString *username;
    NSString *usrEmail;
    NSDictionary *response;
    

}

// Actions
- (IBAction)takePhotoClicked:(id)sender;
- (IBAction)enterClicked:(id)sender;
// Private methods
- (void)innovateFields;
- (void)addNotifications;
- (void)checkEnterEnable;
- (void)registerMe;

@end

@implementation NewProfileViewController
@synthesize popoverController;
@synthesize topDiag_View,topLogo_View;

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addNotifications]; // Add Notifications --
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     username = nil;
    usrEmail = nil;
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    _usrNmFld.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailFld.autocorrectionType = UITextAutocorrectionTypeNo;
    _isAgree = NO;
    [_usrImageV roundCorner: 7 border: 1 borderColor:kColor(255, 242, 0, 0.5)];
    [self innovateFields];
    [self checkEnterEnable];
    
    
    //half of the width
    _enterBtn.clipsToBounds = YES;
    _enterBtn.layer.cornerRadius = 24.0f*kRatio;
    
    // set textsize for whole screen
    [self setFontSize];
    _content_ViewHgt.constant = SCREEN_HEIGHT + 40;
        _userSelectedCityArray = [[NSMutableArray alloc] init];
}


-(void )setFontSize{
    _emailFld.font = [_emailFld.font fontWithSize:[Common setFontSize:_emailFld.font]];
    _passwordFld.font = [_passwordFld.font fontWithSize:[Common setFontSize:_passwordFld.font]];
    _usrNmFld.font = [_usrNmFld.font fontWithSize:[Common setFontSize:_usrNmFld.font]];
    _confPassFld.font = [_passwordFld.font fontWithSize:[Common setFontSize:_confPassFld.font]];
    _enterBtn.titleLabel.font = [_enterBtn.titleLabel.font fontWithSize:[Common setFontSize:_enterBtn.titleLabel.font]];
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

- (IBAction)takePhotoClicked:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view];
}

- (IBAction)signIn:(id)sender
{
    //[self dismissViewControllerAnimated:NO completion:nil];
   // [self.navigationController popViewControllerAnimated:NO];
    LoginViewController *vc = (LoginViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
    navC.navigationBarHidden = YES;
    [self presentViewController:navC animated:NO completion:nil];
}
- (IBAction)enterClicked:(id)sender
{
    NSString *errTxt = [self isValid];
    if (errTxt.length)
    {
        [AppManager showAlertWithTitle:nil Body:errTxt]; return;
    }
    if(![AppManager isInternetShouldAlert: YES]) return;
    else
    {
    if(_isAgree)
    {
        [self doSubmit];
    }
    else
    {
        // go to terms of services.
        TermsOfServiceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsOfServiceViewController"];
        vc.delegate = self;
        //[self presentViewController:vc animated:NO completion:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    }
}

#pragma mark - Private methods

- (void)innovateFields
{
    // margin
    NSInteger margin = 12;
    [_usrNmFld setMargin:margin];
    [_emailFld setMargin:margin];
    [_passwordFld setMargin:margin];
    [_confPassFld setMargin:margin];
}

- (void)addNotifications
{
    // ------------------ Add Notifications -----------------
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_usrNmFld];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_emailFld];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_passwordFld];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_confPassFld];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChange:) name:UITextFieldTextDidChangeNotification object:_usrNmFld];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChange:) name:UITextFieldTextDidChangeNotification object:_emailFld];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChange:) name:UITextFieldTextDidChangeNotification object:_passwordFld];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChange:) name:UITextFieldTextDidChangeNotification object:_confPassFld];
}

- (void)checkEnterEnable
{
    _enterBtn.enabled = (_usrNmFld.text.length && _passwordFld.text.length && _emailFld.text.length && _confPassFld.text.length);
}

- (void)registerMe
{
    [_emailFld resignFirstResponder];
    [_passwordFld resignFirstResponder];
    [_usrNmFld resignFirstResponder];
    [_confPassFld resignFirstResponder];
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    User *user = [[Global shared] currentUser];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:k_DeviceToken];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject : _usrNmFld.text       forKey : @"username"];
    [param setObject : _emailFld.text       forKey : @"email"];
    [param setObject : _passwordFld.text    forKey : @"password"];
    [param setObject:@"1"                   forKey:@"device_type"];
    if(deviceToken != nil)
        [param setObject:deviceToken forKey:@"device_token"];
    else
    {
        [LoaderView removeLoader];
        [App_delegate registerForRemoteNotifications];
        [AppManager showAlertWithTitle:@"" Body:@"Registering device token to get upadtes for you,Please click on login again"];
        return;
    }
    [param  setObject:[NSNumber numberWithInteger:currentApplicationId] forKey:@"application_id"];

    if (user.parent_account_id != nil)
    {
        [param setObject : user.parent_account_id   forKey : @"parent_account_id"];
    }
    // image..
    __block NSData *imgData;
    if(_isPicSelected) imgData = UIImageJPEGRepresentation(_usrImageV.image, .5);
    [[AFAppDotNetAPIClient sharedClient] POST:RegistrationPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(_isPicSelected)  [formData appendPartWithFileData:imgData name:@"profile_photo" fileName:@"myimage.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        DLog(@"%@", response);
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            NSString *loudhailerID = [[response objectForKey:@"userData"]objectForKey:@"loudhailer_id"];
            [[NSUserDefaults standardUserDefaults]setObject:loudhailerID forKey:@"loudhailer_id"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            NSString *userID = [[[response objectForKey:@"userData"]objectForKey:@"User"] objectForKey:@"id"];
            NSString *token = [AppManager sutableStrWithStr:[[[response objectForKey:@"userData"]objectForKey:@"User"] objectForKey:@"token"]];
            [PrefManager storeToken:token];

            [self getUserCityList: userID];
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            [AppManager showAlertWithTitle:nil Body:str];
            [LoaderView removeLoader];

        }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoaderView removeLoader];
        [AppManager showAlertWithTitle:nil Body:error.localizedDescription];
    }];
}

-(void)getUserCityList :(NSString *)user_ID{
    NSMutableDictionary  *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:user_ID,@"user_id",nil];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,kGetUserCity_List];
    [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
}


-(NSString *)isValid
{
    NSString *errTxt;
    if ([_usrNmFld.text withoutWhiteSpaceString].length < 3)
    {
        [_usrNmFld becomeFirstResponder];
        errTxt = @"User Name must be at least 3 characters.";
    }
    else if ([_usrNmFld.text withoutWhiteSpaceString].length > 29)
    {
        [_usrNmFld becomeFirstResponder];
        errTxt = @"User Name should be maximum 30 characters.";
    }
    else if (![_emailFld.text isValidForEmail])
    {
        [_emailFld becomeFirstResponder];
        errTxt = @"Please Enter a valid email id.";
    }
    else if (_passwordFld.text.length < 6)
    {
        [_passwordFld becomeFirstResponder];
        errTxt = @"Password must be at least 6 characters.";
    }
    else if (_passwordFld.text.length > 29)
    {
        [_passwordFld becomeFirstResponder];
        errTxt = @"Password cannot be greater than 30 characters";
    }
    else if (![_passwordFld.text isEqualToString:_confPassFld.text])
    {
        [_confPassFld becomeFirstResponder];
        errTxt = @"Password does not match.";
    }
    return errTxt;
}

-(void)checkIfUserExists{
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:_emailFld.text,@"email",_usrNmFld.text,@"username",nil];

    //Make api call
    if ([AppManager isInternetShouldAlert:YES])
    {
        //show loader...
        [LoaderView addLoaderToView:self.view];
       // [LoaderView addAnimatedLoaderToView:self.view];
        self.view.backgroundColor = [UIColor whiteColor];
        self.view.alpha = 0.7;
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,DOESUSEREXISTS];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
    }

    
}

- (void)doSubmit
{
    // register...
    [self registerMe];
}

#pragma mark - Touch Action
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_usrNmFld resignFirstResponder];
    [_emailFld resignFirstResponder];
    [_passwordFld resignFirstResponder];
    [_confPassFld resignFirstResponder];
}

#pragma mark - UITextField-Notification
- (void)handleTextChange:(NSNotification *)notification
{
    [self checkEnterEnable];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _usrNmFld)
    {
      [_emailFld becomeFirstResponder];
    }
    else if (textField == _emailFld)
    {
        [_passwordFld becomeFirstResponder];
    }
    else if (textField == _passwordFld)
    {
        [_confPassFld becomeFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
   
   if(!(textField.tag == 201) && ![_usrNmFld.text isEqualToString:@""]  && ![username isEqualToString:_usrNmFld.text]){
       username = _usrNmFld.text;
       [self checkIfUserExists];
    }
  
   else if(!(textField.tag == 202) && ![_emailFld.text isEqualToString:@""] && ![usrEmail isEqualToString:_emailFld.text]  ){
        usrEmail = _emailFld.text;
        [self checkIfUserExists];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField.tag == 201){//username
        if (textField.text.length < 30 || string.length == 0){
            return YES;
        }
       
        else{
            [AppManager showAlertWithTitle:@"" Body:@"User Name cannot be greater than 50 characters!"];
            return NO;
        }
        
    }
   else if(textField.tag == 202)
    {
        if (textField.text.length < 50 || string.length == 0){
            return YES;
        }
        
        else{
            [AppManager showAlertWithTitle:@"" Body:@"Email ID cannot be greater than 50 characters!"];
            return NO;
        }
    }

    else if(textField.tag == 203 || textField.tag == 204){
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
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex >= 2) return;
    if(IS_IPHONE)
    {
        [ImagePickManager presentImageSource:(buttonIndex == 0) forVideo:NO onController:self withCompletion:^(BOOL isSelected, UIImage *anImage, NSURL *videoURL) {
            if(isSelected)
            {
                // go for crop
                ImageCropViewController *cropperVC = [[ImageCropViewController alloc]initWithNibName:@"ImageCropViewController~iphone" bundle:nil];
                cropperVC.image = [anImage fixOrientation];
                [self.navigationController pushViewController:cropperVC animated:YES];
                [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller) {
                    if(success)
                    {
                        _isPicSelected = YES;
                        _usrImageV.image = image;
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }];
    }
    else
    {
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        } else {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *imagePicker =
                [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                          (NSString *) kUTTypeImage,
                                          nil];
                imagePicker.allowsEditing = NO;
                if(buttonIndex == 0)
                    imagePicker.sourceType =
                    UIImagePickerControllerSourceTypeCamera;
                else
                    imagePicker.sourceType =
                    UIImagePickerControllerSourceTypePhotoLibrary;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self presentViewController:imagePicker animated:YES completion:nil];
                    
                }];
            }
        }
    }
    
}


#pragma mark Image Picker Delegates

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:    (NSDictionary *)info {
    
    UIImage *anImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (anImage==nil) {
        anImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
    ImageCropViewController *cropperVC = [[ImageCropViewController alloc]initWithNibName:@"ImageCropViewController~ipad" bundle:nil];;
    cropperVC.image = [anImage fixOrientation];
    [self presentViewController:cropperVC animated:YES completion:NULL];
    [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller) {
        if(success)
        {
            _isPicSelected = YES;
            _usrImageV.image = image;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark - TOSDelegate

- (void)didAcceptTOS:(BOOL)accept
{
    _isAgree = accept;
    if(accept)
    {
        [self performSelector:@selector(doSubmit) withObject:nil afterDelay:1];
    }
}

#pragma mark- Shared Utils Delegate Method

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    NSLog(@"responseDict is --- %@",responseDict);
    [LoaderView removeAnimatedLoader];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.alpha = 1.0;

    BOOL status = [[responseDict objectForKey:@"status"] boolValue];
    NSString *msgStr= [responseDict objectForKey:@"status"];
    if (status || [msgStr isEqualToString:@"Success"])
    {
        NSString *msg = [responseDict objectForKey:@"message"];
        if([msg isEqualToString:@"Username already exist..!"]){
            [AppManager showAlertWithTitle:@"Alert" Body:[responseDict objectForKey:@"message"]];

            _usrNmFld.text = @"";
            [_usrNmFld becomeFirstResponder];

          }
        else if([msg isEqualToString:@"Email already exist..!"]){
            [AppManager showAlertWithTitle:@"Alert" Body:[responseDict objectForKey:@"message"]];
            _emailFld.text = @"";
            [_emailFld becomeFirstResponder];
            
        }
       else if ([[responseDict objectForKey:@"message"] isEqualToString:@"City information..!"] )
                                                                      {
                                                                          self.userSelectedCityArray = [responseDict valueForKey:@"data"];
                                                                          [PrefManager setCityArray:self.userSelectedCityArray];
                                                                          for (NSDictionary *dic in self.userSelectedCityArray) {
                                                                              if ([[dic valueForKey:@"city_type"] integerValue] == 1) {
                                                                                  [PrefManager setDefaultCity:[dic valueForKey:@"city_name"]];
                                                                                  [PrefManager setDefaultCityId:[dic valueForKey:@"id"]];
                                                                              }
                                                                          }
                                                                          LoginViewController *rvc =  nil;
                                                                          rvc = (LoginViewController *) [self.navigationController.viewControllers firstObject];
                                                                          //[self dismissViewControllerAnimated:NO completion:nil];
                                                                          [self.navigationController popToRootViewControllerAnimated:NO];
                                                                          [rvc parseResponse:response addImage:(_isPicSelected) ? _usrImageV.image : nil];
                                                                          [LoaderView removeLoader];

                                                                      }
        

    }
    else{
      //  [AppManager showAlertWithTitle:@"Alert" Body:[responseDict objectForKey:@"message"]];

    }
    

    

    
}


@end
