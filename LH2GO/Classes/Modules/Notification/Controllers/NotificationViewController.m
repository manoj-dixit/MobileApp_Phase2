//
//  NotificationViewController.m
//  LH2GO
//
//  Created by Sumit Kumar on 01/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "NotificationViewController.h"
#import "LHNotificationCell.h"
#import "NotificationInfo.h"
#import "AFAppDotNetAPIClient.h"
#import "LoaderView.h"
#import "GroupsViewController.h"
#import "MessagesViewController.h"
#import "NSString+Addition.h"
#import "TimeConverter.h"
#import "SharedUtils.h"
#import "EventLog.h"
#import "ShoutManager.h"


@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate, LHNotificationCellDelegate,APICallProtocolDelegate>
{
    __weak IBOutlet UITableView *_table;
    NSArray *_activities;
    NSArray *offlineNotfs;
    NSInteger selectedIndex;
    NSMutableArray *_tempActivities;
}

@end

@implementation NotificationViewController

BOOL invitationAccepted = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTabbarWithTag : BarItemTag_Notification];
    [self navigationBarRightBarButton];
    [self refreshNotifications];
    [self addNavigationBarViewComponents];
    
    _table.allowsMultipleSelectionDuringEditing = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kchannelBadgeAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelBadgeAdded:) name:kchannelBadgeAdd object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChannelSoftKeyUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotificationScreenOnReceivingPush) name:@"ChannelSoftKeyUpdate" object:nil];
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Notifications";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    _activities = [[Global shared] activities];
    [_tempActivities removeAllObjects];
    [_tempActivities addObjectsFromArray:_activities];
    [AppManager appDelegate].tabCount = 0;

    [self checkCountOfShouts];
    [self showCountOnChannelTab];
    [self hitEventLogAPI:@"on_access_notifications"];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIPasteboardChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyToClip) name:UIPasteboardChangedNotification object:nil];
    
    //saving saved count in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:0] forKey:k_actionableNotify];
    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    // new shout notification..
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrivedInNotification:) name:kNewShoutEncounterTemp object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CMSN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePush:) name:@"CMSN" object:nil];
    self.view.backgroundColor = [UIColor colorWithRed:(39.0f/255.0f) green:(38.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0];
    _table.backgroundColor = [UIColor colorWithRed:(39.0f/255.0f) green:(38.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    DLog(@"Time stamp value %@",timeStampValue);
    
    [[NSUserDefaults standardUserDefaults] setObject:timeStampValue forKey:kReadNotificationsTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSuspendNotif:)
                                             name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChannelSoftKeyUpdate" object:nil];

    [self hitEventLogAPI:@"on_exit_Notifications"];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIPasteboardChangedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
}

-(void)navigationBarRightBarButton{
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"F" style:UIBarButtonItemStylePlain target:self action:@selector(getOnlineNotfs)];
    
    [rightBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.navigationItem.rightBarButtonItem = rightBarButton;
                   });

}

-(void)channelBadgeAdded:(NSNotificationCenter*)notification
{
    [self showCountOnChannelTab];
}

-(void)handlePush:(NSNotification *)noti{
    NSDictionary *d = noti.userInfo;
    [NotificationInfo parseResponse:d];
    _activities = [[Global shared] activities];
    [_tempActivities removeAllObjects];
    [_tempActivities addObjectsFromArray:_activities];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_table reloadData];
    });
    
    if([self.navigationController.visibleViewController isKindOfClass:[NotificationViewController class]]){
        App_delegate.tabCount = 0;
        [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:k_NotifTabCount];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self showCountOnNotificationsTab];
    }
}

-(void)refreshNotificationScreenOnReceivingPush{
    [AppManager downloadActivityOnView:self.view WithCompletion:^(BOOL finished,NSString * message)  {
        if (finished) {
            _activities = [[Global shared] activities];
            if (_activities == nil) _activities = [NSArray new];
            // store read notifications..ids
            if (_activities.count){
                _tempActivities = [NSMutableArray new];
                [_tempActivities addObjectsFromArray:_activities];
                NSMutableString *ids = [NSMutableString new];
                for (NotificationInfo *info in _activities){
                    if (ids.length){
                        [ids appendFormat:@","];
                    }
                    [ids appendString:info.notfId];
                }
                
                [PrefManager clearReadNotfIds];
                NSMutableDictionary *mutableRetrievedDictionary =  [[PrefManager ReadNotificationids]mutableCopy];
                if(mutableRetrievedDictionary){
                    [mutableRetrievedDictionary setObject:ids forKey:[[Global shared] currentUser].user_id];
                    [[NSUserDefaults standardUserDefaults] setObject:mutableRetrievedDictionary forKey:@"DicKey"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else{
                    [PrefManager saveReadNotfIds:ids];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_table reloadData];
                [LoaderView removeLoader];
                [self.navigationItem.rightBarButtonItem setEnabled: YES];
                [self.navigationItem.rightBarButtonItem setTitle:@"F"];
            });}
        else{
            DLog(@"SHow error response");
            [LoaderView removeLoader];
            [self.navigationItem.rightBarButtonItem setEnabled: YES];
            [self.navigationItem.rightBarButtonItem setTitle:@"F"];
            if(![message isEqualToString:@""]){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {}];
                [alertController addAction:defaultAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }}}];
}

//#pragma mark- Notifications Method
//- (void)shoutArrivedInNotification:(NSNotification *)notification{
//    [self checkCountOfShouts];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark-
#pragma mark - Table Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(![AppManager isInternetShouldAlert:NO]){
        return offlineNotfs.count;
    }
    else{
        return _tempActivities.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"LHNotificationCell";
    LHNotificationCell *cell;
    if(![AppManager isInternetShouldAlert:NO]){
        Notifications *notf = [offlineNotfs objectAtIndex:indexPath.row];
        NSInteger value = [notf.type intValue];
        NSInteger type = 0;
        if(value == 4 || value == 7){
            type = 1;
        }
        else{
            type = 0;
        }
        
         cell= (LHNotificationCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@%ld",cellIdentifier,(long)type]];
        if (cell == nil) cell = [LHNotificationCell cellAtIndex:type];
        [cell displayNotificationOffline:notf];
    }
    else{
        NotificationInfo *info = [_tempActivities objectAtIndex:indexPath.row];
        NSInteger type = (info.type == NotfType_groupInvite || info.type == NotfType_nonAdmingroupInvite || info.type == 20) ? 1 : 0;
        cell = (LHNotificationCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@%ld",cellIdentifier,(long)type]];
        if (cell == nil)
            cell = [LHNotificationCell cellAtIndex:type];
        
        [cell displayNotification:info];
        if(type == 1){
            [self hitEventLogAPI:@"type"];
        }
        cell.delegate = self;
    }
    cell.tag = indexPath.row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int fontsize = 16;
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5){
        fontsize = fontsize+2;
    }else{
        fontsize = fontsize*kRatio;
    }
    
    if(![AppManager isInternetShouldAlert:NO]){
        Notifications *notf = [offlineNotfs objectAtIndex:indexPath.row];
        NSString *msg = notf.message;
        NSInteger value = [notf.type intValue];
        msg = [msg stringByReplacingOccurrencesOfString:@"<h>" withString:@""];
        msg = [msg stringByReplacingOccurrencesOfString:@"</h>" withString:@""];
        
        UIFont *font = [UIFont fontWithName:@"Aileron-Regular" size:fontsize];
        CGFloat th;
        CGSize size;
        if(IS_IPHONE_5){
            th = [msg actualSizeWithFont:font stickToWidth:tableView.frame.size.width-90*kRatioiPhone5].height ;
            size = [msg actualSizeWithFont:font stickToWidth:tableView.frame.size.width-90*kRatioiPhone5]; // default mode
        }
        else{
            th = [msg actualSizeWithFont:font stickToWidth:tableView.frame.size.width-90*kRatio].height +10;
            size = [msg actualSizeWithFont:font stickToWidth:tableView.frame.size.width-90*kRatio]; // default mode
        }
        
        if (value == 4 || value == 7)
            return th+20+94*kRatio;//th+140*kRatio;//th+135*kRatio;
        else if(value == 5)
            return  th + 54*kRatioiPhone5;//th+70 kRatio;
        else
            return th + 60 *kRatio;//th+110*kRatio;
    }
    else{
        NotificationInfo *info = [_tempActivities objectAtIndex:indexPath.row];
        NSString *msg = info.message;
        msg = [msg stringByReplacingOccurrencesOfString:@"<h>" withString:@""];
        msg = [msg stringByReplacingOccurrencesOfString:@"</h>" withString:@""];
        
        UIFont *font = [UIFont fontWithName:@"Aileron-Regular" size:fontsize];
        CGFloat th;
        CGSize size;
        if(IS_IPHONE_5){
            th = [msg actualSizeWithFont:font stickToWidth:tableView.frame.size.width-90*kRatioiPhone5].height;
            size = [msg actualSizeWithFont:font stickToWidth:tableView.frame.size.width-90*kRatioiPhone5]; // default mode
        }
        else{
            th = [msg actualSizeWithFont:font stickToWidth:tableView.frame.size.width-90*kRatio].height+25;
            size = [msg actualSizeWithFont:font stickToWidth:tableView.frame.size.width-90*kRatio]; // default mode
        }
        if (info.type == NotfType_groupInvite || info.type == NotfType_nonAdmingroupInvite || info.type == 20){
            if(IS_IPHONE_5)
                return th+20+94*kRatioiPhone5;
            else
                return th+20+94*kRatio;//th+140*kRatio;//th+135*kRatio;
        }
        else if(info.type == NotfType_adminMessage){
            if(IS_IPHONE_5){
                return  th + 54 *kRatioiPhone5;
            }
            else
                return th+ 54*kRatio;    //th+70 kRatio;
        }
        else
            return th + 60 *kRatio;//(th + 60) *kRatio;//th+110*kRatio;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [LoaderView addLoaderToView:self.view];
        DLog(@"selected row %ld",(long)indexPath.row);
        selectedIndex = indexPath.row;
        [self deleteNotf];
    }
}

#pragma mark - LHNotificationCellDelegate
- (void)didAccept:(BOOL)accept onIndex:(NSInteger)index{
    if (_tempActivities == nil || _tempActivities.count == 0){
        [self showBackgroundRefreshAlert];
        return;
    }
    __block NotificationInfo *info = [_tempActivities objectAtIndex:index];
    if (info==nil || info.notfId==nil || info.tempGrId == nil){
        [self showBackgroundRefreshAlert];
        return;
    }
    // add loader..
    [LoaderView addLoaderToView:self.view];
    
    // for p2p contact requst
    if(info.type == 20)
    {
        // accept request for the p2p contact
        [self acceptGetAPIForP2P:info withParam:accept indexvalue:index];
    }
    else
    {
        // accept request for the Group
        [self acceptPostAPIForGroup:info withParam:accept indexvalue:index];
    }
}


-(void)acceptPostAPIForGroup:(NotificationInfo *)info withParam:(BOOL)isAccept indexvalue:(NSUInteger)index
{
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        User *user = [[Global shared] currentUser];
        NSString *stus = (isAccept) ? @"Accepted" : @"Rejected";
        NSString *path = NotificationAcceptPath;
        if (info.type == NotfType_groupInvite){
            stus = (isAccept) ? @"Accepted" : @"Rejected";
            path = NotificationAcceptPath;
        }
        else if (info.type == NotfType_nonAdmingroupInvite){
            stus = (isAccept) ? @"Approved" : @"Disapproved";
            path = NotificationAdminApprovalPath;
        }
        if([stus isEqualToString:@"Accepted"] ||[stus isEqualToString:@"Approved"])
            invitationAccepted = YES;
        [param setObject : info.notfId  forKey : @"notification_id"];
        [param setObject : user.user_id forKey : @"user_id"];
        [param setObject : info.tempGrId    forKey : @"group_id"];
        [param setObject : stus         forKey : @"status"];
        // add token..
        AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
        NSString *token = [PrefManager token];
        [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
        [client POST:path parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if(response != NULL){
                BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
                if(status){
                    info.status = (isAccept) ? NotfStatusAccepted : NotfStatusRejected;
                    LHNotificationCell *cell = (LHNotificationCell *) [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    [cell displayNotification:info];
                    info.tempniD = info.notfId;
                    if(info.status == NotfStatusAccepted){
                        [info addGroupIfUserAcceptRequest];
                    }
                    [LoaderView removeLoader];
                    [self hitEventLogAPI:stus];
                }
                else{
                    NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
                    [AppManager showAlertWithTitle:nil Body:str];
                    [LoaderView removeLoader];
                }
            }
            else
                [LoaderView removeLoader];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
            [LoaderView removeLoader];
            
        }];
}

-(void)acceptGetAPIForP2P:(NotificationInfo *)info withParam:(BOOL)isAccept indexvalue:(NSUInteger)index
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser];
   
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    NSString *api = (isAccept) ? GETP2PACCEPTREQUEST : GETP2PREJECTREQUEST;
    NSString *apiStr = [NSString stringWithFormat:@"%@%@",api,info.p2pToken];
    NSString *stus = (isAccept) ? @"Accepted" : @"Rejected";

    [client GET:apiStr parameters:@"" success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                if(response != NULL){
                    BOOL status = [[response objectForKey:@"status"] boolValue];//[[response objectForKey:@"status"] isEqualToString:@"Success"];
                              if(status){
                                  
                                  info.status = (isAccept) ? NotfStatusAccepted : NotfStatusRejected;
                                                  LHNotificationCell *cell = (LHNotificationCell *) [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                                                  [cell displayNotification:info];
                                                  info.tempniD = info.notfId;
                                                  if(info.status == NotfStatusAccepted){
                                                      [info addGroupIfUserAcceptRequest];
                            
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:info.tempGrId,@"id",info.tempGrName,@"group_name",             [NSString stringWithFormat:@"%d",info.timeStamp],@"timestamp",info.tempGrpPic,@"group_photo", nil];
                    
                    NSDictionary *usrDict  = [NSDictionary dictionaryWithObjectsAndKeys:info.tempGrId,@"loudhailer_id",info.tempGrName,@"username",info.tempGrpPic,@"profile_photo",nil];
                    User *u= [User addUserWithDict:usrDict pic:nil];
                    u.parent_account_id = @"1011";
                    [DBManager save];
                    
                    [Group addGroupWithDictForP2PContact:dic forUsers:@[user] pic:nil isPendingStatus:YES];
                    }
                                                  [LoaderView removeLoader];
                                                  [self hitEventLogAPI:stus];
                                              }
                                              else{
//                                                  NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
//                                                  [AppManager showAlertWithTitle:nil Body:str];
                                                  [LoaderView removeLoader];
                                              }
                              }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
               [LoaderView removeLoader];
    }];
}


-(void)showBackgroundRefreshAlert{
    NSString *title=@"Alert";
    NSString *message = @"Updating notifications inbox. Please try later.";
    [AppManager showAlertWithTitle:title Body:message];
}

#pragma mark - Other Functions
-(void)hitEventLogAPI:(NSString*)status{
    int timeStamp = (int)[TimeConverter timeStamp];
    NSMutableDictionary *postDictionary;
    NSMutableDictionary *detaildict;
    
    if([status isEqualToString:@"Accepted"]){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:status,@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_group_join",@"log_sub_category",status,@"text",@"",@"category_id",detaildict,@"details",nil];
    }
    else if([status isEqualToString:@"Approved"]){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:status,@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_allow_user",@"log_sub_category",status,@"text",@"",@"category_id",detaildict,@"details",nil];
    }
    else if([status isEqualToString:@"Disapproved"]){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:status,@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_denied_user",@"log_sub_category",status,@"text",@"",@"category_id",detaildict,@"details",nil];
    }
    else if([status isEqualToString:@"type"]){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"received_group_management",@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"received_group_management",@"log_sub_category",@"received_group_management",@"text",@"",@"category_id",detaildict,@"details",nil];
    }
    else if([status isEqualToString:@"Rejected"]){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:status,@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_group_reject",@"log_sub_category",status,@"text",@"",@"category_id",detaildict,@"details",nil];
    }
    else if([status isEqualToString:@"on_access_notifications"]){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:status,@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_access_notifications",@"log_sub_category",status,@"text",@"",@"category_id",detaildict,@"details",nil];
    }
    else{
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:status,@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_exit_Notifications",@"log_sub_category",status,@"text",@"",@"category_id",detaildict,@"details",nil];
    }
    [AppManager saveEventLogInArray:postDictionary];
}

-(void)getOnlineNotfs{
    if(![AppManager isInternetShouldAlert:NO]){
        [AppManager showAlertWithTitle:@"Alert!" Body:@"Please check your internet connection to perform this operation"];
    }
    else{
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setTitle:@""];
        [LoaderView addLoaderToView:self.view];
        [self refreshNotifications];
    }
}

-(void)deleteNotf{
    if(![AppManager isInternetShouldAlert:NO]){
        [LoaderView removeLoader];
        [AppManager showAlertWithTitle:@"Alert!" Body:@"Please check your internet connection to perform this operation"];
    }
    else{
        NotificationInfo *info = [_tempActivities objectAtIndex:selectedIndex];
        User *user = [[Global shared] currentUser];
        DLog(@"notid    -- >%@",info.notfId);
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        NSString *token = [PrefManager token];
        [param setObject : info.notfId  forKey : @"notification_id"];
        [param setObject : user.user_id forKey : @"user_id"];
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURL * url = [NSURL URLWithString:deleteNotification];
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
        NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:user.user_id,@"user_id", info.notfId,@"notification_id",nil];
        NSData *myData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:nil];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:myData];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:token forHTTPHeaderField:@"token"];
        __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                                  {
                                                      //DLog(@"Response:%@ %@\n", response, error);
                                                      if(error == nil)
                                                      {
                                                          [LoaderView removeLoader];
                                                          NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                          DLog(@"responseDict is --- %@",dict);
                                                          if(response != NULL)
                                                          {
                                                              BOOL status = [[dict objectForKey:@"status"] boolValue];
                                                              NSString *msgStr= [dict objectForKey:@"status"];
                                                              if (status || [msgStr isEqualToString:@"Success"])
                                                              {
                                                                  NSString *str = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
                                                                  [AppManager showAlertWithTitle:nil Body:str];
                                                                  if(_tempActivities.count == 1 && selectedIndex == 0)
                                                                  {
                                                                      [_tempActivities removeObjectAtIndex:selectedIndex];
                                                                      
                                                                      NSIndexPath *indp = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
                                                                      [_table beginUpdates];
                                                                      [_table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indp] withRowAnimation:UITableViewRowAnimationFade];
                                                                      [_table endUpdates];
                                                                      [_table reloadData];
                                                                      
                                                                  }
                                                                  else
                                                                  {
                                                                      [_tempActivities removeObjectAtIndex:selectedIndex];
                                                                      NSIndexPath *indp = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
                                                                      [_table beginUpdates];
                                                                      [_table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indp] withRowAnimation:UITableViewRowAnimationFade];
                                                                      [_table endUpdates];
                                                                      
                                                                      [_table reloadData];
                                                                  }
                                                              }
                                                              else{
                                                                  [AppManager showAlertWithTitle:@"Alert" Body:[NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]]];
                                                                  
                                                              }
                                                          }
                                                          else
                                                          {
                                                              [LoaderView removeLoader];
                                                              [AppManager showAlertWithTitle:nil Body:@"Request Time Out"];
                                                          }
                                                      }
                                                  }];
        [dataTask resume];
        [defaultSession finishTasksAndInvalidate];
    }
}

- (void)refreshUI{
    _activities = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_table reloadData];
    });
}

- (void)refreshNotifications{
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:k_NotifTabCount];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [LoaderView addLoaderToView:self.view];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    if(![AppManager isInternetShouldAlert:NO]){
        offlineNotfs = [DBManager getAllNotifications];
        DLog(@"offline notfs are %@",offlineNotfs);
        [PrefManager clearReadNotfIds];
        [LoaderView removeLoader];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setTitle:@"F"];
    }
    else{
        [self refreshNotificationScreenOnReceivingPush];
    }
}

-(void)receiveSuspendNotif :(NSNotification*)notification{
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:k_phNumberNotf];
    if(str!=nil){
        if(![str isEqualToString:@""])
        {
            int timeStamp = (int)[TimeConverter timeStamp];
            NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"on_click_phone_call",@"text",nil];
            NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_click_phone_call",@"log_sub_category",@"on_click_phone_call",@"text",@"",@"category_id",detaildict,@"details",nil];
            [AppManager saveEventLogInArray:postDictionary];
            [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:k_phNumberNotf];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
}

#pragma mark EventLog
-(void)copyToClip{
    NSString *copyClip;
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (pasteBoard.hasURLs) {
        copyClip = [pasteBoard.URL absoluteString];
        copyClip = [copyClip stringByReplacingOccurrencesOfString:@"%20" withString:@""];
        copyClip = [copyClip stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    else if ([UIPasteboard generalPasteboard].hasImages) {
        return;
    }
    else if ([UIPasteboard generalPasteboard].hasColors) {
        return;
    }
    else{
        copyClip = [UIPasteboard generalPasteboard].string;
    }
    NSString *temp = copyClip;
    int timeStamp = (int)[TimeConverter timeStamp];
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:temp,@"text",nil];
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Notification",@"log_category",@"on_copy",@"log_sub_category",temp,@"text",@"",@"category_id",detaildict,@"details",nil];
    [AppManager saveEventLogInArray:postDictionary];
}

#pragma mark- Notifications Method
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
    Group *group = sht.group;
    CommsViewController *commsViewController = nil;
    ReplyViewController *replyViewController = nil;
    
    //crash fix , please dont remove this code
    if([self.navigationController.topViewController isKindOfClass:[CommsViewController class]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KY" object:group];
        return;
    }
    
    if(sht.parent_shout==nil){
        commsViewController = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        commsViewController.myGroup = group;

        NSMutableArray *nets = [NSMutableArray new];
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
            Group *tempGroup = obj;
            if ([tempGroup.grId integerValue] == [group.grId integerValue]) {
                isAvailable = YES;
                index       = idx;
            }
        }];
        
        if (isAvailable) {
            commsViewController.selectedGroupIndex = index;
        }
        [self.navigationController pushViewController:commsViewController animated:YES];
    }
    else
    {
        commsViewController = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        commsViewController.myGroup = group;
        [self.navigationController pushViewController:commsViewController animated:NO];

        replyViewController = (ReplyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
        replyViewController.pShout = sht.parent_shout;
        replyViewController.myGroup=group;
        [self.navigationController pushViewController:replyViewController animated:YES];
    }
    //  clear badge on group.
    if (group.totShoutsReceived){
        [group clearBadge:group];
    }
}

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType
{
    //crash fix , please dont remove this code
    if([self.navigationController.topViewController isKindOfClass:[NotificationViewController class]]){
    // check owner
    Channels *channel = nil;
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    NSArray *channels = [DBManager getChannelsForNetwork:net];
        
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"channelId"
                                                 ascending:YES];
    channels = [channels sortedArrayUsingDescriptors:@[sortDescriptor]];
    for(Channels *tempChannel in channels){
        if([tempChannel.channelId isEqualToString:channelId]){
            if (isClick) {
                if (isClick) {
                    channel = tempChannel;
                }
            }
        }
    }
    ChanelViewController *chanelViewController = nil;

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content,@"content",length,@"length",contentId,@"contentId",cool,@"cool",share,@"share",contact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",@"NO",@"needToMove",[NSNumber numberWithInteger:createdTime],@"created",[NSNumber numberWithBool:feedType],@"feed_Type",nil];

    if([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]])//crash fix , please dont remove this code
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"KX" object:channel userInfo:dict];
        return;
    }
    if (isClick){
        chanelViewController = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
        chanelViewController.myChannel = channel;
        chanelViewController.dataDictionary =  dict;
        [self.navigationController pushViewController:chanelViewController animated:YES];
    }
    else{
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if(state == UIApplicationStateBackground){
            chanelViewController = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
            [self.navigationController pushViewController:chanelViewController animated:YES];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"KX" object:channel userInfo:dict];
    }
    }
}

-(void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground
{
    ChanelViewController *chanelViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ChanelViewController class])];
    
    NSString *channelName;
    if(!isBackground){
        channelName = [[[dic objectForKey:@"Data"] componentsSeparatedByString:@":"] objectAtIndex:1];
    }
    else{
        NSArray *arr = [[[[dic objectForKey:@"Data"] componentsSeparatedByString:@"go to"] lastObject] componentsSeparatedByString:@" "];
        NSString *mergeString = @"";
        int i = 1;
        for(NSString *str11 in arr){
            if (i !=1 && i != arr.count) {
                mergeString = [mergeString stringByAppendingString:str11];
            }
            i++;
        }
        channelName = mergeString;
    }
    
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    
    // fetch the data for channe;
    NSArray *dataOfParticularChannl =  [DBManager getChannelDataFromNameAndId:channelName isName:NO Network:net];
    
    NSString *channelID;
    Channels *channel;
    if (dataOfParticularChannl.count>0){
        channel = [dataOfParticularChannl objectAtIndex:0];
        channelID = channel.channelId;
    }
    else
        return;

    chanelViewController.myChannel = channel;
    [self.navigationController pushViewController:chanelViewController animated:YES];
}

@end
