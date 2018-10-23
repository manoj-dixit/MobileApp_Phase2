//
//  ReportViewController.m
//  LH2GO
//
//  Created by Parul Mankotia on 17/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "ReportViewController.h"
#import "Constant.h"
#import "NotificationViewController.h"
#import "NotificationInfo.h"

@interface ReportViewController () <UIAlertViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,APICallProtocolDelegate>

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_selectOptionView.layer setShadowColor:[UIColor blackColor].CGColor];
    [_selectOptionView.layer setShadowOpacity:0.6];
    [_selectOptionView.layer setShadowRadius:4.0];
    [_selectOptionView.layer setShadowOffset:CGSizeMake(0, 3.0)];
    [_selectOptionView.layer setMasksToBounds:NO];
    
    [self addNavigationBarViewComponents];
    [self addTabbarWithTag : BarItemTag_Setting];
}

-(void)viewDidAppear:(BOOL)animated
{
    usrName.delegate = self;
    usrName.userInteractionEnabled = NO;
    [super viewDidAppear:animated];
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Report";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)reportBugAction:(UIButton*)sender {
    NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
}

-(IBAction)reportUserAction:(UIButton*)sender
{
    UIAlertView *alert = nil;
    alert = [[UIAlertView alloc] initWithTitle:@"Report a user for inappropriate language or content sharing" message:@"Please enter the username"delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle= UIAlertViewStylePlainTextInput;
    [alert show];

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
        NSString *tempString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,REPORT_USER];
        NSURL * url = [NSURL URLWithString:tempString];
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
    
    if([self.navigationController.topViewController isKindOfClass:[ReportViewController class]])//crash fix , please dont remove this code
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


@end
