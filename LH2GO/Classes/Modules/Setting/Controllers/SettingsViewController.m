//
//  SettingsViewController.m
//  LH2GO
//
//  Created by Linchpin on 6/28/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "SettingsViewController.h"
#import "ChangePassViewController.h"
#import "UIView+Extra.h"
#import "UITextfield+Extra.h"
#import "UIImage+Extra.h"
#import "ImagePickManager.h"
#import "ImageCropViewController.h"
#import "AFAppDotNetAPIClient.h"
#import "LoaderView.h"
#import "SERVICES.h"
#import "BlockedUserListVC.h"
#import "EventLog.h"
#import "SharedUtils.h"
#import "TimeConverter.h"
#import "NotificationViewController.h"
#import "NotificationInfo.h"
#import "BackUpManager.h"
#import "BLEManager.h"

#define k_NetworkAvailable 101


@interface SettingsViewController ()<UIAlertViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,APICallProtocolDelegate>
{
    UIBarButtonItem * righttButton;
    BOOL _isNotOn;
    BOOL _isPicSelected;
    BOOL isEnable;
    User *user;
    SharedUtils *sharedUtils;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // if (IPAD)
        usrImg.contentMode = UIViewContentModeScaleAspectFill;
     sharedUtils = nil;
     sharedUtils = [[SharedUtils alloc] init];
     sharedUtils.delegate = self;
     [self addTabbarWithTag : BarItemTag_Setting];
     [self addPanGesture];
     self.title = @"Settings";
     [self addRightButtonInSettings];
   
     [reportUsrBtn.layer setBorderWidth:1.5];
     [reportUsrBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
     [reportBugBtn.layer setBorderWidth:1.5];
     [reportBugBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
     user = [[Global shared] currentUser];
  //  CGFloat newWidth = usrImg.frame.size.width * kRatio;
    //CGFloat newHeight = usrImg.frame.size.height * kRatio;
    //set height/width
    
//    usrImg.frame = CGRectMake(
//                              usrImg.frame.origin.x,
//                              usrImg.frame.origin.y, newWidth, newHeight);
    
    
    [notfSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kEditUserProfile object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:kEditUserProfile object:nil];
    // new shout notification..
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrived:) name:kNewShoutEncounter object:nil];
    
// set textsize for whole screen
 [self setFontSize];
    [self setNavBarTitle];
    
    //adjust UserImage /ChangeProfileImage Btn size
    CGRect frame ;
    frame = [Common adjustRoundShapeFrame:usrImg.frame];
    _userImgHeight.constant = frame.size.height;
    _userImgWidth.constant = frame.size.width ;
    frame = [Common adjustRoundShapeFrame:changeProfIconBtn.frame];
    _btnIconHeight.constant = frame.size.height;
    _btnIconWidth.constant = frame.size.width ;
    
    usrImg.layer.cornerRadius = usrImg.frame.size.height /2;
    usrImg.layer.masksToBounds = YES;
    usrImg.layer.borderWidth = 0;
    changeProfIconBtn.layer.cornerRadius = changeProfIconBtn.frame.size.height/2;
    changeProfIconBtn.layer.masksToBounds = YES;
    changeProfIconBtn.layer.borderWidth = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kchannelBadgeAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelBadgeAdded:) name:kchannelBadgeAdd object:nil];

}

-(void)channelBadgeAdded:(NSNotificationCenter*)notification{
    [self showCountOnChannelTab];
}


- (void)setNavBarTitle {
    
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Settings";
    titleLabel.textColor=[UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

-(void )setFontSize{
    
    usrName.font = [usrName.font fontWithSize:[Common setFontSize:usrName.font]];
    usrEmail.font = [usrEmail.font fontWithSize:[Common setFontSize:usrEmail.font]];
    versionNumber.font = [versionNumber.font fontWithSize:[Common setFontSize:versionNumber.font]];
    lbl_receive.font = [lbl_receive.font fontWithSize:[Common setFontSize:lbl_receive.font]];
    lbl_arrow.font = [lbl_arrow.font fontWithSize:[Common setFontSize:lbl_arrow.font]];
    lbl_chngPswd.font = [lbl_chngPswd.font fontWithSize:[Common setFontSize:lbl_chngPswd.font]];
   
    reportBugBtn.titleLabel.font = [reportBugBtn.titleLabel.font fontWithSize:[Common setFontSize:reportBugBtn.titleLabel.font]];
    reportUsrBtn.titleLabel.font = [reportUsrBtn.titleLabel.font fontWithSize:[Common setFontSize:reportUsrBtn.titleLabel.font]];
    lbl_arrow1.font = [lbl_arrow1.font fontWithSize:[Common setFontSize:lbl_arrow1.font]];
    lbl_blockedUser.font = [lbl_blockedUser.font fontWithSize:[Common setFontSize:lbl_blockedUser.font]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self showCountOfNotifications];
    [self showCountOnChannelTab];
    [self checkCountOfShouts];
    [self getData];
    usrName.delegate = self;
    usrName.userInteractionEnabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
    
    
}
#pragma mark - Private Methods

- (void)addRightButtonInSettings
{
    
    righttButton = nil;
    righttButton = [[UIBarButtonItem alloc]
                    initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveDetails)];
    [righttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"CenturyGothic" size:20.0], NSFontAttributeName,nil]
                                forState:UIControlStateNormal];
    righttButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = righttButton;
    
    
}

-(void)saveDetails
{
    if (!_isPicSelected && [usrName.text isEqualToString: user.user_name]) {
        [AppManager showAlertWithTitle:nil Body:@"No change."];
        return;
    }
    
    
    if(![AppManager isInternetShouldAlert:YES]) return;
    
    // add loader..
    [LoaderView addLoaderToView:self.view];
    
    NSMutableDictionary *param = nil;
    param = [[NSMutableDictionary alloc] init];
    [param setObject : user.user_id     forKey : @"user_id"];
    [param setObject : usrName.text   forKey : @"username"];
    
    
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    // image..
    __block NSData *imgData;
    if(_isPicSelected) imgData = UIImageJPEGRepresentation(usrImg.image, .5);
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
             user.user_name = usrName.text;
             if (_isPicSelected)
             {
                 user.picUrl = [AppManager sutableStrWithStr:[dict objectForKey:@"profile_photo"]];
                 [[SDImageCache sharedImageCache] storeImage:usrImg.image forKey:user.picUrl];
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




- (void)getData
{
    _isNotOn = [PrefManager isNotfOn];
    if(_isNotOn == 0)
        [notfSwitch setOn:NO];
    else
        [notfSwitch setOn:YES];
    usrName.text = user.user_name;
    usrEmail.text = user.email;
    
     if(_isPicSelected){
    }
     else{
    dispatch_async(dispatch_get_main_queue(), ^{
    [usrImg sd_setImageWithURL:[NSURL URLWithString:user.picUrl]placeholderImage:[UIImage imageNamed:placeholderUser]];
      });
     }
    
}

- (void)setState:(id)sender
{
    _isNotOn = !_isNotOn;
    [PrefManager setNotfOn:_isNotOn];
}

#pragma mark - IBAction


- (IBAction)changePwdAction:(id)sender {
    
    ChangePassViewController *vc = (ChangePassViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePassViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)receiveNotf:(id)sender {
    notfSwitch.selected = _isNotOn;

}

-(void)hitTheEventLog{
    
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:reportEmailIs,@"text",nil];

    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Report",@"log_category",@"on_report_user",@"log_sub_category",reportEmailIs,@"text",@"",@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary];

    
//    [EventLog addEventWithDict:postDictionary1];
//    
//    NSNumber *count = [Global shared].currentUser.eventCount;
//    int value = [count intValue];
//    count = [NSNumber numberWithInt:value + 1];
//    [[Global shared].currentUser setEventCount:count];
//    [DBManager save];
//    
//    if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0))
//    {
//        //show loader...
//        // [LoaderView addLoaderToView:self.view];
//        [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//    }

}
- (IBAction)editUsrName:(id)sender {
   

    if(!isEnable){
        usrName.text = @"";
        usrName.userInteractionEnabled = YES;
        [usrName becomeFirstResponder];
        isEnable = YES;
  
    }
    
    else{
        usrName.text = user.user_name;
        usrName.userInteractionEnabled = NO;
        isEnable = NO;
        
    }
    
}

- (IBAction)profPicChange:(id)sender {
    
    UIActionSheet *sheet = nil;
    sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view];
 
    
}

-(void)getreportuserEmail
{
    UIAlertView *alert = nil;
    alert = [[UIAlertView alloc] initWithTitle:@"Report a user for inappropriate language or content sharing" message:@"Please enter the username"delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle= UIAlertViewStylePlainTextInput;
    [alert show];
}

//BlockedUserListVC


- (IBAction)viewBlockedUsers:(id)sender
{
    
    BlockedUserListVC *vc = (BlockedUserListVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"BlockedUserListVC"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - AlertViewDelegate


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttontitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttontitle isEqualToString:@"OK"])
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        reportEmailIs = textField.text;
        DLog(@"Using the Textfield: %@",reportEmailIs);
        if(![textField.text isEqualToString:@""]){
            if ([AppManager isInternetShouldAlert:YES])
            {
                [self reportuserAPI];
                
            }
            else{
                [AppManager showAlertWithTitle:@"Alert" Body:@"Check your internet"];
            }
        }
        else{
            [AppManager showAlertWithTitle:@"Alert" Body:@"Please mention the email of the user you want to report"];
        }
        
           }
}


#pragma mark -Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [usrName  resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark API Call

-(void)reportuserAPI
{
    // NSString *temp = self->textView.text;
    if ([reportEmailIs isEqualToString:usrName.text])
    {
        [AppManager showAlertWithTitle:@"Alert" Body:@"You cannot report yourself"];
        
    }
    else
    {
    [LoaderView addLoaderToView:self.view];
    NSString *token = [PrefManager token];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:REPORT_USER];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *postDictionary ;
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:reportEmailIs,@"user_name",nil];
    NSData *myData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:myData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:token forHTTPHeaderField:@"token"];
    __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                              {
                                                  DLog(@"Response---------->>>>>>>:%@ %@\n", response, error);
                                                  if(error == nil)
                                                  {
                                                      [LoaderView removeLoader];
                                                      NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                      DLog(@"responseDict over here is --- %@",dict);
                                                      if(dict != NULL)
                                                      {
                                                      BOOL status = [[dict objectForKey:@"status"] boolValue];
                                                      NSString *msgStr= [dict objectForKey:@"status"];
                                                      if (status || [msgStr isEqualToString:@"Success"])
                                                      {
                                                                                                            
                                                          NSString *url = [REPORT_Email_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
                                                          if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:url]])
                                                          {
                                                              [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
                                                          }
                                                          else
                                                              [AppManager showAlertWithTitle:@"No Email Configured" Body:@"Email is not configured in your phone.Please add any email account first"];
                                                          
                                                          NSString *str = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
                                                          [AppManager showAlertWithTitle:nil Body:str];
                                                      }
                                                      else
                                                      {
                                                          NSString *str = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
                                                          [AppManager showAlertWithTitle:nil Body:str];
                                                      }
                                                      }
                                                  }
                                              }];
        [dataTask resume];
        [defaultSession finishTasksAndInvalidate];
}
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
                [self presentViewController:cropperVC animated:YES completion:NULL];
                [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller) {
                    if(success)
                    {
                        _isPicSelected = YES;
                        usrImg.image = image;
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:    (NSDictionary *)info {
    
   UIImage *Image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (Image==nil) {
        Image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
    ImageCropViewController *cropperVC = [[ImageCropViewController alloc]initWithNibName:@"ImageCropViewController~ipad" bundle:nil];;
    cropperVC.image = [Image fixOrientation];
    [self presentViewController:cropperVC animated:YES completion:NULL];
    [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller) {
        if(success)
        {
            _isPicSelected = YES;
            usrImg.image = image;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark- Notifications Method

- (void)shoutArrived:(NSNotification *)notification
{
    [self checkCountOfShouts];
}

-(void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground
{
    
    ChanelViewController *channelVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ChanelViewController class])];
    
    NSString *channelName;
    if(!isBackground)
    {
        channelName = [[[dic objectForKey:@"Data"] componentsSeparatedByString:@":"] objectAtIndex:1];
    }else
    {
        NSArray *arr = [[[[dic objectForKey:@"Data"] componentsSeparatedByString:@"go to"] lastObject] componentsSeparatedByString:@" "];
        
        NSString *mergeString = @"";
        int i = 1;
        for(NSString *str11 in arr)
        {
            if (i !=1 && i != arr.count) {
                mergeString = [mergeString stringByAppendingString:str11];
            }
            i++;
        }
        channelName = mergeString;
    }

    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    
    //NSArray *channel  = [DBManager getChannelsForNetwork:net];
    
    // fetch the data for channe;
    NSArray *dataOfParticularChannl =  [DBManager getChannelDataFromNameAndId:channelName isName:NO Network:net];
    
    NSString *channelID;
    Channels *channel;
    if (dataOfParticularChannl.count>0)
    {
        channel = [dataOfParticularChannl objectAtIndex:0];
        channelID = channel.channelId;
    }
    else
        return;
    
    channelVC.myChannel = channel;
    
    [self.navigationController pushViewController:channelVC animated:YES];
}

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick
{
    [self.navigationController.navigationBar setHidden:false];
    
    if (isForChannel)
    {
        //push to channel view controller
        [self setMyChannel:dataDict isFromBackground:isBackgroundClick];
        return;
    }    
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


- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType
{
    
    if([self.navigationController.topViewController isKindOfClass:[SettingsViewController class]])//crash fix , please dont remove this code
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

#pragma mark- PUSH Notification handling

- (void)goToNotificationScreen:(NSDictionary*)dict isClickedOnPush:(BOOL)isPush{
    NotificationViewController *cvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[NotificationViewController class]])//crash fix , please dont remove this code
    {
        [NotificationInfo parseResponse:dict];
        return;
    }
    if (isPush) {
        cvc = (NotificationViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CMSN" object:nil userInfo:dict];
}

- (void)goToChannelScreen:(NSDictionary*)dict{
    ChanelViewController *cvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]])//crash fix , please dont remove this code
    {
        NSString *cId = [dict objectForKey:@"channel_id"];
        NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:cId,@"channelId",@"NO",@"needToMove",nil];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
        return;
    }
    cvc = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil];
}

-(void)moveToChannelScreen:(NSString *)channelID
{
    
}

- (IBAction)logoutButtonAction:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Are you sure you want to logout from the app?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        NSLog(@">>>>>>>>>>>>>>>>logoutClicked");
        [BackUpManager createAutoBackUp];
        BOOL isconnected =[AppManager isInternetShouldAlert:NO];
        BOOL isSynced =[DBManager isSyncedShoutsAndShoutsBackUp];
        if (isconnected==YES)
        {
            if (isSynced==YES && App_delegate.cachedShoutDetails.count==0)
            {
                [self getLogout];
            }
            else if(isSynced == NO && App_delegate.cachedBackUpDetails.count !=0)
            {
                [self startAutoSyncing];
            }else
            {
                [self getLogout];
            }
        }
        else
        {
            if (isSynced==YES)
            {
                [self getLogout];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                               message:@"Do you want to logout without syncing data?"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action)
                                     {
                                         DLog( @"Not Log out");
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
            
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)getLogout
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
}

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

- (void)startAutoSyncing
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
    
 }

@end
