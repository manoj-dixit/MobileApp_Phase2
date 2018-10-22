//
//  ProfileViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 04/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "ProfileViewController.h"

//#import "UIView+Extra.h"

@interface ProfileViewController ()
{
    __weak IBOutlet UILabel *_usrNmLbl;
    __weak IBOutlet UILabel *_emailLbl;
    __weak IBOutlet UIImageView *_usrImgV;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTabbarWithTag:_activeTag];
    self.title = @"Profile";
    [[NSNotificationCenter defaultCenter]removeObserver:self name:k_GotuserSettings object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSettings) name:k_GotuserSettings object:nil];
    
//    _heightImg.constant = 130 ;
//    _widthImg.constant = 130;
    CGRect frame ;
    frame = [Common adjustRoundShapeFrame:_usrImgV.frame];
    _heightImg.constant = frame.size.height;
    _widthImg.constant = frame.size.width ;
    _usrImgV.layer.cornerRadius = _usrImgV.frame.size.height/2;
    _usrImgV.layer.masksToBounds = true;
    
    if(IS_IPHONE_5)
    {
//        _heightImg.constant = 130;
//        _widthImg.constant = 130;
//        _usrImgV.layer.cornerRadius = 65;
    }
    if(IS_IPHONE_6 || IS_IPHONE_6P)
    {
//        _usrImgV.layer.cornerRadius = 70;
//        _topConst.constant = 200;
    }
    if (_usr)
    {
        _usrNmLbl.text = (_usr.user_name.length) ? _usr.user_name : @"Unknown";
        _emailLbl.text = (_usr.email.length) ? _usr.email : @"";
        if([[Global shared].currentUser.user_id isEqualToString:_usr.user_id]){
            [_usrImgV sd_setImageWithURL:[NSURL URLWithString:_usr.picUrl]  placeholderImage:_usrImgV.image];
            _usrImgV.layer.backgroundColor=[[UIColor clearColor] CGColor];
        }
        else{
            [self downloadImage:_usr];
        }      
        DLog(@"_usrImgV.layer.cornerRadius%f",  _usrImgV.layer.cornerRadius);
    }
    
    _emailLbl.font = [_emailLbl.font fontWithSize:[Common setFontSize:_emailLbl.font]];
    _usrNmLbl.font = [_usrNmLbl.font fontWithSize:[Common setFontSize:_usrNmLbl.font]];
    
    [self addLeftAndRightButton];
    
}

-(void)downloadImage :(User*)user{
    
    if(![AppManager isInternetShouldAlert:YES]) return;
    
    [LoaderView addLoaderToView:self.view];
    NSString *token = [PrefManager token];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:getUserImage];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:user.user_id,@"user_id",nil];
    NSData *myData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:myData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:token forHTTPHeaderField:@"token"];
    __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                              {
                                                  
                                                  // if data is not nil and there is no error
                                                  if (!error && data !=nil)
                                                  {
                                                  NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                      if(dict != NULL)
                                                      {
                                                  BOOL status = [[dict objectForKey:@"status"] boolValue];
                                                  NSString *msgStr= [dict objectForKey:@"status"];
                                                  if (status || [msgStr isEqualToString:@"Success"])
                                                  {                                                      if(data!=nil){
                                                      //NSString *data = [dict objectForKey:@"data"];
                                                      
                                                      if ([[dict objectForKey:@"data"] objectForKey:@"email"]) {
                                                          _emailLbl.text = [[dict objectForKey:@"data"] objectForKey:@"email"];
                                                      }
                                                      
                                                      if ([[dict objectForKey:@"data"] objectForKey:@"profile_photo"]) {
                                                          [user setPicUrl:[[dict objectForKey:@"data"] objectForKey:@"profile_photo"]];
                                                      }
                                                      
                                                          [DBManager save];
                                                          [LoaderView removeLoader];
                                                          [_usrImgV sd_setImageWithURL:[NSURL URLWithString:_usr.picUrl] placeholderImage:_usrImgV.image];
                                                          _usrImgV.layer.backgroundColor=[[UIColor clearColor] CGColor];
                                                        
                                                      }
                                                      else{
                                                          [LoaderView removeLoader];
                                                          [_usrImgV sd_setImageWithURL:[NSURL URLWithString:_usr.picUrl]placeholderImage:_usrImgV.image];
                                                          _usrImgV.layer.backgroundColor=[[UIColor clearColor] CGColor];
                                                      }
                                                  }
                                                  
                                                  else{
                                                      [LoaderView removeLoader];
                                                      [_usrImgV sd_setImageWithURL:[NSURL URLWithString:_usr.picUrl]placeholderImage:_usrImgV.image];
                                                      _usrImgV.layer.backgroundColor=[[UIColor clearColor] CGColor];
                                                     
                                                  }
                                                  }
                                                      else
                                                          [LoaderView removeLoader];
                                              }else
                                              {
                                                  // if there is some error or data dictionary is not proper or nil
                                                  [LoaderView removeLoader];
                                                  [_usrImgV sd_setImageWithURL:[NSURL URLWithString:_usr.picUrl]placeholderImage:_usrImgV.image];
                                                  _usrImgV.layer.backgroundColor=[[UIColor clearColor] CGColor];
                                              }
                                              }];
    [dataTask resume];
    [defaultSession finishTasksAndInvalidate];
}

-(void)addLeftAndRightButton{
    
    
    leftButton = nil ;
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Other Methods

-(void)gotSettings
{
    if ([PrefManager shouldOpenSonar] == NO)
    {
        [AppManager showAlertWithTitle:@"" Body:k_permissionAlertSaved];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
