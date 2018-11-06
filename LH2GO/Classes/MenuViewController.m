//
//  MenuViewController.m
//  LH2GO
//
//  Created by Linchpin on 6/16/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuTableViewCell.h"
#import "SavedViewController.h"
#import "SettingsViewController.h"
#import "LHSavedCommsViewController.h"
#import "LHBackupSessionViewController.h"
#import "SERVICES.h"
#import "BackUpManager.h"
#import "LHAutoSyncing.h"
#import "FavoriteDownloadManager.h"
#import "BLEManager.h"

#define k_NetworkAvailable 101

@interface MenuViewController ()
{
    NSMutableArray *arrayValue;
    NSMutableArray *arrayValueImgIcon;
    NSString *movetoClassName;
    BOOL _isPicSelected;
  //  NSMutableArray *centralDevices;
   // NSMutableArray *periPheralDevices;
}
@end

@implementation MenuViewController
@synthesize popoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //if (IPAD)
    self.userImage.contentMode = UIViewContentModeScaleAspectFill;
   // arrayValue = [[NSMutableArray alloc]initWithObjects:@"PROFILE SETTINGS",@"REPORT",@"INFO",nil];
    arrayValue = [[NSMutableArray alloc]initWithObjects:@"PROFILE SETTINGS",@"FAQ",@"REPORT",@"INFO",@"INVITE FRIENDS",nil];

    arrayValueImgIcon = [[NSMutableArray alloc]initWithObjects:@"b",@".",@")",@"+",@"*",nil];
    self.navigationController.navigationBar.topItem.title = @"Loud Hailer";
    self.navigationItem.title = @"Loud Hailer";
    [self.userImage.layer setCornerRadius:self.userImage.frame.size.height*kRatio/2];
    [self.userImage.layer setMasksToBounds:YES];
    [self.userPlusButton.layer setCornerRadius:self.userPlusButton.frame.size.height*kRatio/2];
    [self.userPlusButton.layer setMasksToBounds:YES];
    [self adjustScreenAccordingToDevices];
    //for resizing screen during calls
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kStatusBarWillChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kStatusBarWillChange) name:kStatusBarWillChange object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kStatusBarDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kStatusBarDidChange) name:kStatusBarDidChange object:nil];
}

-(void)adjustScreenAccordingToDevices
{
    //adjust tableHeaderView
    _menuTableView.autoresizesSubviews = YES;
    CGRect newFrame = _menuTableView.tableHeaderView.frame;
    newFrame.size.height = newFrame.size.height * kRatio;
    _menuTableView.tableHeaderView.frame = newFrame;
    
    //set font size
//    _userName.font = [_userName.font fontWithSize:15];
//    _userEmail.font = [_userEmail.font fontWithSize:15];

    _userName.font = [_userName.font fontWithSize:[Common setFontSize:_userName.font]];
    _userEmail.font = [_userEmail.font fontWithSize:[Common setFontSize:_userEmail.font]];

    _logoutButton.titleLabel.font = [_logoutButton.titleLabel.font fontWithSize:[Common setFontSize:_logoutButton.titleLabel.font]];
    
    //adjust UserImage /ChangeProfileImage Btn size
    CGRect frame ;
    frame = [Common adjustRoundShapeFrame:_userImage.frame];
    _userImgHeight.constant = frame.size.height;
    _userImgWidth.constant = frame.size.width ;
    frame = [Common adjustRoundShapeFrame:_userPlusButton.frame];
    _btnIconHeight.constant = frame.size.height;
    _btnIconWidth.constant = frame.size.width ;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    centralDevices = [[BLEManager sharedManager].centralM.connectedDevices copy];
//    periPheralDevices =  [[BLEManager sharedManager].perM.connectedCentrals copy];
//    //if(centralDevices.count >0 || periPheralDevices.count >0)
//        [_menuTableView reloadData];
    user = [[Global shared] currentUser];
    self.userName.text = user.user_name.capitalizedString;
    self.userEmail.text = user.email;
    if (App_delegate.isCallProgress || ([[UIApplication sharedApplication]statusBarFrame].size.height== 40))
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height-20);
    }
    else
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height);
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
       // if (!_isPicSelected)
            [self.userImage sd_setImageWithURL:[NSURL URLWithString:user.picUrl]placeholderImage:[UIImage imageNamed:placeholderUser]];
    });
    
    [super viewDidAppear:animated];
}

-(void)dealloc
{
    //    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)kStatusBarWillChange{
    if (App_delegate.isCallProgress)
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height-20);
    }
    else
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height);
    }
}

-(void)kStatusBarDidChange
{
    if (App_delegate.isCallProgress)
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height-20);
    }
    else
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height);
    }
}
#pragma mark - choose Image

- (IBAction)uploadUserImage:(id)sender
{
    // if(![AppManager isInternetShouldAlert:YES]) return;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    if (IPAD){
        //        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        //        while (topController.presentedViewController) {
        //            topController = topController.presentedViewController;
        //        }
        [sheet showInView:[self topView]];
    }
    else
        [sheet showInView:self.view];
    
    /*
     UIButton *button = (UIButton *)sender;
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
     message:[NSString stringWithFormat: @"Choose an option"]
     preferredStyle:UIAlertControllerStyleActionSheet];
     UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
     style:UIAlertActionStyleCancel
     handler:^(UIAlertAction *action)
     {
     [self dismissViewControllerAnimated:YES completion:nil];
     }];
     UIAlertAction *Camera = [UIAlertAction actionWithTitle:@"Camera"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
     {
     [self call_ImageFucn:0]; //0 if camera
     }];
     
     UIAlertAction *photoLibrary = [UIAlertAction actionWithTitle:@"Photo Library"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
     {
     [self call_ImageFucn:1]; //1 if photolibrary
     }];
     
     [alert addAction:Camera];
     [alert addAction:photoLibrary];
     [alert addAction:cancel];
     [alert setModalPresentationStyle:UIModalPresentationPopover];
     UIPopoverPresentationController *popPresenter = [alert
     popoverPresentationController];
     popPresenter.sourceView = button;
     popPresenter.sourceRect = button.bounds;
     [self presentViewController:alert animated:YES completion:nil];
     */
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
                [self dismissViewControllerAnimated:true completion:nil];
                // go for crop
                ImageCropViewController *cropperVC = [[ImageCropViewController alloc]initWithNibName:@"ImageCropViewController~iphone" bundle:nil];
                cropperVC.image = [anImage fixOrientation];
                [self presentViewController:cropperVC animated:YES completion:NULL];
                [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller)
                 {
                     [self dismissViewControllerAnimated:YES completion:NULL];
                     if(success)
                     {
                         //using to save image on server
                         [self ask_toSaveImageOnServer:image];
                         
                     }
                 }];
            }
        }];
    }
    else
    {
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
        else
        {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *imagePicker = nil;
                imagePicker =  [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                          (NSString *) kUTTypeImage,
                                          nil];
                imagePicker.allowsEditing = NO;
                imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
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


-(void)call_ImageFucn:(NSInteger)buttonIndex{
    
    if(buttonIndex >= 2) return;
    if(IS_IPHONE)
    {
        [ImagePickManager presentImageSource:(buttonIndex == 0) forVideo:NO onController:self withCompletion:^(BOOL isSelected, UIImage *anImage, NSURL *videoURL) {
            if(isSelected)
            {
                [self dismissViewControllerAnimated:true completion:nil];
                // go for crop
                ImageCropViewController *cropperVC = [[ImageCropViewController alloc]initWithNibName:@"ImageCropViewController~iphone" bundle:nil];
                cropperVC.image = [anImage fixOrientation];
                [self presentViewController:cropperVC animated:YES completion:NULL];
                [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller)
                 {
                     [self dismissViewControllerAnimated:YES completion:NULL];
                     if(success)
                     {
                         //using to save image on server
                         [self ask_toSaveImageOnServer:image];
                     }
                 }];
            }
        }];
    }
    else
    {
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
        else
        {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *imagePicker = nil;
                imagePicker =  [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                          (NSString *) kUTTypeImage,
                                          nil];
                imagePicker.allowsEditing = NO;
                imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
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
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:    (NSDictionary *)info
{
    UIImage *anImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (anImage==nil)
    {
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
           // _userImage.image = image;
            if (IPAD)
                [self ask_toSaveImageOnServer:anImage];

        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)ask_toSaveImageOnServer:(UIImage *)image{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save Image" message:[NSString stringWithFormat: @"Do you want to set selected image as your profile image?"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                         {
                             _isPicSelected = NO;
                             [self.userImage sd_setImageWithURL:[NSURL URLWithString:user.picUrl]placeholderImage:[UIImage imageNamed:placeholderUser]];
                             [self dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action)
                          {
                              _isPicSelected = YES;
                              //changes on 9oct
                              if(![AppManager isInternetShouldAlert:YES])
                              {
                                  [AppManager showAlertWithTitle:@"Error!" Body:@"Your Internet is not working, Please connect and try again."];
                                  return;
                              }
                              else
                              {
                                  self.userImage.image = image;
                                  [[SDImageCache sharedImageCache] storeImage:self.userImage.image forKey:user.picUrl];
                                  [self changeUserprofileImage];
                              }
                          }];
    [alert addAction:no];
    [alert addAction:yes];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)changeUserprofileImage
{
    // User *user = [[Global shared] currentUser];
    if (!_isPicSelected)
    {
        [AppManager showAlertWithTitle:nil Body:@"No change."];
        return;
    }
    // if(![AppManager isInternetShouldAlert:YES]) return;
    
    // add loader..
    
    //    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //
    //    while (topController.presentedViewController) {
    //        topController = topController.presentedViewController;
    //    }
    
    [LoaderView addLoaderToView: [self topView]];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject : user.user_id     forKey : @"user_id"];
    [param setObject : user.user_name   forKey : @"username"];
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // image..
    __block NSData *imgData;
    if(_isPicSelected) imgData = UIImageJPEGRepresentation(self.userImage.image, .5);
    [[AFAppDotNetAPIClient sharedClient] POST:EditProfilePath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         if(_isPicSelected)  [formData appendPartWithFileData:imgData name:@"profile_photo" fileName:@"myimage.jpg" mimeType:@"image/jpeg"];
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         [LoaderView removeLoader];
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         DLog(@"%@", response);
         if(response != NULL)
         {
             BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
             if(status)
             {
                 NSDictionary *userData = [response objectForKey:@"userData"];
                 NSDictionary *dict = [userData objectForKey:@"User"];
                 if (_isPicSelected)
                 {
                     user.picUrl = [AppManager sutableStrWithStr:[dict objectForKey:@"profile_photo"]];
                     [[SDImageCache sharedImageCache] storeImage:self.userImage.image forKey:user.picUrl];
                 }
                 [[NSNotificationCenter defaultCenter] postNotificationName:kEditUserProfile object:nil userInfo:nil];
                 [[Global shared] setCurrentUser:user];
                 [DBManager save];
                 NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
                 [self.navigationController popViewControllerAnimated:YES];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [AppManager showAlertWithTitle:nil Body:str];
                     ;
                 });
             }
             else{}
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
     }];
}

- (IBAction)backBtn:(id)sender {
    [self.frostedViewController hideMenuViewController];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayValue count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MenuTableViewCell *cell = [self.menuTableView dequeueReusableCellWithIdentifier:@"MenuTableViewCell" forIndexPath:indexPath];
        cell.labelName.text =[arrayValue objectAtIndex:indexPath.row];
        cell.labelIcon.text =[arrayValueImgIcon objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch ([indexPath row]) {
            
        case 0:
        {
            SettingsViewController *obj = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            self.frostedViewController.contentViewController = [self getnavController:obj];
        }
            break;
        case 2:{
            ReportViewController *obj = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
            self.frostedViewController.contentViewController = [self getnavController:obj];
        }
            break;
        case 3:{
            InfoViewController *obj = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
            self.frostedViewController.contentViewController = [self getnavController:obj];
        }
            break;

        case 1:{
        }
            break;
       default:
            break;
    }
    [self.frostedViewController hideMenuViewController];
}

- (UINavigationController *) getnavController:(UIViewController *) viewController {
    
    UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:viewController];
    return navController;
    //[UIApplication sharedApplication].delegate.window.rootViewController=navController;
}

-(UIView *) topView{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController.view;
}

#pragma mark Private Methods
/*- (void)getLogout
{
    // redirect all the logs to the folder to check the issue.
    [App_delegate redirectConsoleLogToDocumentFolder];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:USERLOGGEDOUT object:nil];
    if(![AppManager isInternetShouldAlert:NO])
    {
        [LoaderView addLoaderToView:[UIApplication sharedApplication].keyWindow withMessage:@"logging Out"];
        
        // disconnect all the peripheral and master connections
        [self disconnetAllBLEConnections];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [PrefManager setLoggedIn:NO];
        [BaseViewController showLogin];
        [AppManager stopLogfileTimer];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_LoginEmail];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_LoginPassword];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //        [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_DeviceToken];
        //        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_contentId];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_PhoneNumber];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_ShoutEncountered];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [LoaderView removeLoader];
        return;
    }
    NSString *token = [PrefManager token];
    if (token.length==0) return;
    // add loader..
    [LoaderView addLoaderToView:[UIApplication sharedApplication].keyWindow withMessage:@"logging Out"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *users = [[Global shared] currentUser];
    [param setObject : users.user_id forKey : @"user_id"];
    
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client POST:LogoutPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // disconnect all the peripheral and master connections
        [self disconnetAllBLEConnections];
        
        [PrefManager setLoggedIn:NO];
        [BaseViewController showLogin];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_LoginEmail];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_LoginPassword];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [LoaderView removeLoader];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(operation.response.statusCode == kTokenExpCode){
            // disconnect all the peripheral and master connections
            [self disconnetAllBLEConnections];
            [PrefManager setLoggedIn:NO];
            [BaseViewController showLogin];
        }else{
            
            // disconnect all the peripheral and master connections
            [self disconnetAllBLEConnections];
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            [PrefManager setLoggedIn:NO];
            [BaseViewController showLogin];
            [AppManager stopLogfileTimer];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_LoginEmail];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_LoginPassword];
            [[NSUserDefaults standardUserDefaults]synchronize];
            //            [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_DeviceToken];
            //            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_contentId];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_PhoneNumber];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:k_ShoutEncountered];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:NO];
        }
        [LoaderView removeLoader];
    }];
}*/

-(void)disconnetAllBLEConnections
{
    NSMutableArray *centralDevices = [[BLEManager sharedManager].centralM.connectedDevices copy];
    NSMutableArray *periPheralDevices =  [[BLEManager sharedManager].perM.connectedCentrals copy];
    
    [[BLEManager sharedManager].centralM clearTransmitQueues];
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

-(void)uploadCacheBackupOnServer:(void (^) (BOOL isAllSend))isAllShoutSend
{
    if ([AppManager isInternetShouldAlert:NO])
    {
        if ([App_delegate.cachedBackUpDetails count]>0) {
            
            // upload bookmark data
            @try {
                
                [App_delegate.cachedBackUpDetails  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
                    NSString *token = [PrefManager token];
                    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
                    
                    NSString *addEditPath = ShoutsBackup;
                    
                    [client POST:addEditPath parameters:obj success:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                         
                         DLog(@"Response is  : %@",response);
                         if(response != NULL)
                         {
                             BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
                             
                             // remove the object if bookmarked or unbookmarked
                             [App_delegate.cachedBackUpDetails removeObject:obj];
                             if(status)
                             {
                                 DLog(@"Successfully Back UP");
                             }
                             else{
                                 DLog(@"UnSuccessful BackUp");
                                 //   [AppManager showAlertWithTitle:@"Alert!" Body:@"This message is bookmarked locally. You may not view them after re-login"];
                             }
                         }
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         
                         NSLog(@"ERROR is %@",error.localizedDescription);
                         
                         // Remove the object as we don't want to try for that
                         // coz user wants to log-out
                         [App_delegate.cachedBackUpDetails removeObject:obj];
                     }];
                }];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            // callback for returing that all the shout  are sync with CLoud or also not good internet to be sync or failure
            isAllShoutSend(YES);
            
        }
        else
        {
            // callback for returing coz there is no cache shout
            
            isAllShoutSend(YES);
        }
    }
    else
    {
        // callback for returing coz there is no internet connection
        isAllShoutSend(YES);
    }
}


-(void)uploadCacheShoutOnServer:(void (^) (BOOL isAllSend))isAllShoutSend
{
    if ([AppManager isInternetShouldAlert:NO])
    {
        if ([App_delegate.cachedShoutDetails count]>0) {
            
            // upload bookmark data
            @try {
                
                [App_delegate.cachedShoutDetails  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
                    NSString *token = [PrefManager token];
                    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
                    
                    [client POST:ShoutsFavourites parameters:obj success:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                         
                         DLog(@"Response is  : %@",response);
                         if(response != NULL)
                         {
                             BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
                             
                             // remove the object if bookmarked or unbookmarked
                             [App_delegate.cachedShoutDetails removeObject:obj];
                             if(status)
                             {
                                 DLog(@"Successfully BookMark");
                             }
                             else{
                                 DLog(@"Successfully Un-BookMark");
                                 //   [AppManager showAlertWithTitle:@"Alert!" Body:@"This message is bookmarked locally. You may not view them after re-login"];
                             }
                         }
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         
                         NSLog(@"ERROR is %@",error.localizedDescription);
                         
                         // Remove the object as we don't want to try for that
                         // coz user wants to log-out
                         [App_delegate.cachedShoutDetails removeObject:obj];
                     }];
                    
                }];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            // callback for returing that all the shout  are sync with CLoud or also not good internet to be sync or failure
            isAllShoutSend(YES);
            
        }
        else
        {
            // callback for returing coz there is no cache shout
            
            isAllShoutSend(YES);
        }
    }
    else
    {
        // callback for returing coz there is no internet connection
        isAllShoutSend(YES);
    }
}

/*- (void)startAutoSyncing
{
    // add loader..
    [LoaderView addLoaderToView:[UIApplication sharedApplication].keyWindow withMessage:@"Syncing Data..."];
    
    [self uploadCacheShoutOnServer:^(BOOL isAllSend)
     {
         [App_delegate.cachedShoutDetails removeAllObjects];
         
         [self uploadCacheBackupOnServer:^(BOOL isAllSend) {
             
             if (isAllSend) {
                 [LoaderView removeLoader];
                 [App_delegate.cachedBackUpDetails removeAllObjects];
                 [self getLogout];
             }
         }];
     }];
}

- (void)showAlertforUnsyncedData
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                   message:@"Do you want to logout without syncing data?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                         {
                             NSLog( @"Not Log out");
                             //                                                                   [self sendDataOverBLE];
                         }];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action)
                          {
                              [self getLogout];
                          }];
    
    [alert addAction:no];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==k_NetworkAvailable)
    {
        if (buttonIndex == 0)
        {
            [self getLogout];
        }
    }
    
}*/

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}
@end
