//
//  ReportViewController.m
//  LH2GO
//
//  Created by Parul Mankotia on 17/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "ReportViewController.h"
#import "Constant.h"

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
    [self hitTheEventLog];

}
-(void)hitTheEventLog{
    
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:reportEmailIs,@"text",nil];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Report",@"log_category",@"on_report_user",@"log_sub_category",reportEmailIs,@"text",@"",@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary];
}

#pragma mark - AlertViewDelegate


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttontitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttontitle isEqualToString:@"OK"])
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        reportEmailIs = textField.text;
        if([reportEmailIs isEqualToString:[Global shared].currentUser.user_name])
        {
            DLog(@"Using the Textfield: %@ %@",reportEmailIs,[Global shared].currentUser.user_name );
            [AppManager showAlertWithTitle:@"Info" Body:@"You cannot report yourself"];

        }
        else
        {
        DLog(@"Using the Textfield: %@",reportEmailIs);
        if(![textField.text isEqualToString:@""]){
            if ([AppManager isInternetShouldAlert:YES])
            {
                [self reportuserAPI];
                
            }
            else{
                [AppManager showAlertWithTitle:@"Info" Body:@"Please connect to internet."];
            }
        }
        else{
            [AppManager showAlertWithTitle:@"Alert" Body:@"Please mention the email of the user you want to report"];
        }
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
        [AppManager showAlertWithTitle:@"Info" Body:@"You cannot report yourself"];
        
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
                                                                  if([str isEqualToString:@"Your session expired, Please login to continue..!"])
                                                                  {
                                                                      [AppManager handleSessionExpiration];
                                                                  }
                                                                  else
                                                                  {
                                                                  [AppManager showAlertWithTitle:nil Body:str];
                                                                  }
                                                              }
                                                          }
                                                      }
                                                  }];
        [dataTask resume];
        [defaultSession finishTasksAndInvalidate];
    }
}


@end
