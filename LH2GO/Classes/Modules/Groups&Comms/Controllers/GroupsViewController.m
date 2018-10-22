//
//  GroupsViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 20/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "GroupsViewController.h"
#import "CommsViewController.h"
#import "NewGroupViewController.h"
#import "NotificationViewController.h"
#import "LHManegGroupViewController.h"
#import "ReplyViewController.h"
#import "GroupList.h"
#import "LoaderView.h"
#import "AFAppDotNetAPIClient.h"
#import "ShoutManager.h"
#import "BannerAlert.h"
#import "BadgeView.h"
#import "NotificationInfo.h"
#import "BLEManager.h"
#import "messageCell.h"

#define kDeleteAlertTag 399
#define kLeaveGroupAlertTag 499


typedef NS_ENUM(NSInteger, GroupState)
{
    GroupStateNone = 0,
    GroupStateDelete,
    GroupStateManage
};

@interface GroupsViewController () <GroupListDelegate, NotificationViewControllerDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet UIImageView *_titleImgV;
    __weak IBOutlet UIButton    *_activityBtn;
    IBOutlet UIImageView *lineImg;
    IBOutlet UIButton *manageGroup;
    IBOutlet UIButton *deleteGroup;
    GroupState _gState;
    GroupList *_listView;
    BOOL _shouldRefresh;
    // delete alert time cache index path.
    NSIndexPath *_selIndexPath;
    NSString *buttonClickedIs;
}

- (IBAction)addGrClicked:(id)sender;
- (IBAction)deleteGrClicked:(id)sender;
- (IBAction)manageGrClicked:(id)sender;
- (IBAction)notificationClicked:(id)sender;

@end

@implementation GroupsViewController
@synthesize tableMessage;
- (void)viewWillAppear:(BOOL)animated
{
    validateUser = 1; //Set it to 0 if want to hit validate user API to check if user is blocked or not
    [self.view endEditing:YES];
    [super viewWillAppear:animated];
    if(_gState == GroupStateNone)
    {
        [lineImg setImage:[UIImage imageNamed:@"lightgreen.png"]] ;
    }
    if (_shouldRefresh)
        [self updateMe];
    if (isLoggedIn)
    {
        if(invitationAccepted)
        {
            [LoaderView addLoaderToView:self.view];
            DLog(@"Inviation Accepted......!!!!!");
            [self getLogin];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //   [self addTabbarWithTag: BarItemTag_None];
    _gState = GroupStateNone;
    [self updateUIWithState];
    float yy = 36;
    float hh = self.view.frame.size.height-[self tabHieght]-yy-10-81; // 5 - margin
    CGRect selfFrame = self.view.frame;
    CGRect fr = CGRectMake(10, yy, selfFrame.size.width-20, hh);
    _listView = [[GroupList alloc] initWithFrame:fr];
    [self.view addSubview:_listView];
    _listView.backgroundColor = [UIColor clearColor];
    _listView.delegate = self;
    if (!isLoggedIn)
    {
        [BaseViewController showLogin];
    }
    else
    {
        
       // [self checkVarification];
        
    }
    // new group/network notification..
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kActiveNetworkChange object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kUpdateGroupList object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:kUpdateGroupList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:kActiveNetworkChange object:nil];
    // new shout notification..
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutEncountered:) name:kNewShoutEncounter object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getLogin
{
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    User *user = [[Global shared] currentUser];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *email = [[NSUserDefaults standardUserDefaults]objectForKey:k_LoginEmail];
    NSString *Password = [[NSUserDefaults standardUserDefaults]objectForKey:k_LoginPassword];
    [param setObject : email  forKey : @"email"];
    [param setObject : Password   forKey : @"password"];
    if (user.parent_account_id != nil)
    {
        [param setObject : user.parent_account_id   forKey : @"parent_account_id"];
    }
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    client.securityPolicy.allowInvalidCertificates = YES;
    [client POST:LoginPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
     } success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         // [LoaderView removeLoader];
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         [self parseResponse:response addImage:nil];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [LoaderView removeLoader];
         [AppManager showAlertWithTitle:nil Body:error.localizedDescription];
     }];
}

- (void)parseResponse:(NSDictionary *)response addImage:(UIImage *)image
{
    DLog(@"%@", response);
    if(response != NULL)
    {
    BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
    if(status)
    {
        NSDictionary *data = [response objectForKey:@"userData"];
        NSDictionary *usrDict  = [data objectForKey:@"User"];
        NSString *uId = [AppManager sutableStrWithStr:[usrDict objectForKey:@"id"]];
        if ([[[[Global shared] currentUser] user_id] isEqualToString:uId] == FALSE)
        {//this condition check if same user login then dont clear the catch (fav and backups)
            [AppManager logOut];
        }
        // token
        NSString *token = [AppManager sutableStrWithStr:[usrDict objectForKey:@"token"]];
        [PrefManager storeToken:token];
        // is varified
        BOOL verfied = [[AppManager sutableStrWithStr:[usrDict objectForKey:@"is_verified"]] integerValue];
        [PrefManager setVarified:verfied];
        // store user..
        User *user = [User addUserWithDict:usrDict pic:image];
        [[Global shared] setCurrentUser: user];
        [PrefManager storeUserId:user.user_id];
        [AppManager downloadUserSettingsAfterLogin:^(BOOL finished) {
            BOOL isActive = YES;
            NSString *activeNetId = [[PrefManager activeNetId] copy];
            NSArray *nets = [data objectForKey:@"Networks"];
            for (NSDictionary *netD in nets)
            {
                Network *netw = [Network addNetworkWithDict:netD];
                if (isActive&&activeNetId==nil)
                {
                    [PrefManager setActiveNetId:[netw.netId copy]];
                    isActive = NO;
                }
            }
            //Sonal commented as Providence App will not have default group
            NSArray *groups = [data objectForKey:@"Groups"];
            for (NSDictionary *gd in groups)
            {
                [Group addGroupWithDict:gd forUsers:@[user] pic:nil pending:NO];
            }
            [LoaderView addLoaderToView:self.view];
            [self loginCompleted:YES];
        }];
    }
    else
    {
        NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
        [AppManager showAlertWithTitle:nil Body:str];
    }
    }
    [LoaderView removeLoader];
}

- (void)loginCompleted:(BOOL)isLoggedIn
{
    [PrefManager setLoggedIn: isLoggedIn];
    [PrefManager setNotfOn:YES];
    // download user list....
//    [AppManager downloadUsers];
//    [AppManager downloadActivity];
//    [AppManager downloadSecurityKeys];
    [[BLEManager sharedManager] setIsRefreshBLE:YES];
}


#pragma mark - Public Methods

+ (void)checkNotificationBadge
{
    UINavigationController *nvc = (UINavigationController *)[[[AppManager appDelegate] window] rootViewController];
    GroupsViewController *vc = (GroupsViewController *) [[nvc viewControllers] firstObject];
    [vc checkbadge];
}

+ (void)refreshGroups
{
    UINavigationController *nvc = (UINavigationController *)[[[AppManager appDelegate] window] rootViewController];
    
    UIViewController *vc = [AppManager getTopviewController:nvc];
    
    if([vc isKindOfClass:[GroupsViewController class]])
    {
        [(GroupsViewController *)vc updateMe];
    }
}

// on logout..
- (void)refreshStateOnLogout
{
    _gState = GroupStateNone;
    [self updateUIWithState];
}
-(void)savingdbnotifycount:(NSInteger)passedactionableNotifycount
{
    //saving saved count in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:passedactionableNotifycount] forKey:k_actionableNotify];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkbadge
{
    NSMutableDictionary *mutableRetrievedDictionary = [[PrefManager ReadNotificationids]mutableCopy];
    DLog(@"dict is %@",mutableRetrievedDictionary);
    NSString *str = [mutableRetrievedDictionary objectForKey:[[Global shared] currentUser].user_id];
    NSArray * arr = [str componentsSeparatedByString:@","];
    DLog(@"array is %@",arr);
    int countRead = 0;
    NSArray *list = [[Global shared] activities];
    for (NotificationInfo *inf in list)
    {
        if ([arr containsObject:inf.notfId])
        {
            countRead ++;
        }
    }
    [BadgeView addBadge:[list count]-countRead toView:_activityBtn inCorner:badgeCorner_TopRight marginX:-3 marginY:8];
    NSInteger countActonableNotif = [DBManager getArrayOfActionableNotifications].count;
    //Comparing countActonableNotif not equal to saved count of NSUserDefaults
    if ([[NSUserDefaults standardUserDefaults] valueForKey:k_actionableNotify]==nil || [[[NSUserDefaults standardUserDefaults] valueForKey:k_actionableNotify] integerValue] != countActonableNotif)
    {
        if (countActonableNotif==1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"You have %ld pending notification for Approval.", (long)countActonableNotif] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            if (alert.visible==FALSE)
            {
                [alert show];
            }
        }
        else if (countActonableNotif>1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"You have %ld pending notifications for Approval.", (long)countActonableNotif] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            if (alert.visible==FALSE)
            {
                [alert show];
            }
        }
    }
    [self savingdbnotifycount:countActonableNotif];
}

- (void)updateMe
{
    [super updateMe];
    [_listView refreshData];
}

- (void)refreshList
{
    _shouldRefresh = YES;
}

- (void)refresh
{
    // uncomment this if you want none state on tab change.
    if (_gState == GroupStateNone) return; // already in none mode
    // convert to none mode
    _gState = GroupStateNone;
    [self updateUIWithState];
}

- (void)refreshWithDeleteView
{
    // uncomment this if you want none state on tab change.
    _gState = GroupStateDelete;
    [self updateUIWithState];
    [lineImg setImage:[UIImage imageNamed:@"redline.png"]] ;
    [deleteGroup setImage:[UIImage imageNamed:@"deletegroupcolor.png"] forState:UIControlStateNormal];
}

- (void)refreshWithManageView
{
    // uncomment this if you want none state on tab change.
    _gState = GroupStateManage;
    [self updateUIWithState];
    [lineImg setImage:[UIImage imageNamed:@"lightorange.png"]] ;
    [manageGroup setImage:[UIImage imageNamed:@"managegroupcolor"] forState:UIControlStateNormal];
}

#pragma mark - Private methods

- (void)updateUIWithState
{
    if(_gState == GroupStateNone)
    {
        [manageGroup setImage:[UIImage imageNamed:@"manageGroup.png"] forState:UIControlStateNormal];
        [deleteGroup setImage:[UIImage imageNamed:@"deleteGroup.png"] forState:UIControlStateNormal];
        [lineImg setImage:[UIImage imageNamed:@"lightgreen.png"]];
        [self addTabbarWithTag: BarItemTag_Groups];
    }
    else
    {
        [self addTabbarWithTag: BarItemTag_None];
    }
    CGRect fr = _listView.frame;
    float yy = (_gState == GroupStateNone) ? 50 : _titleImgV.frame.origin.y+_titleImgV.frame.size.height+10;
    float hh = self.view.frame.size.height-[self tabHieght]-yy-5-64;
    fr.origin.y = yy;
    fr.size.height = hh;
    //_titleImgV.alpha = 0;
    if (_gState != GroupStateNone)
    {
        NSString *imgN = (_gState == GroupStateManage) ? @"manage.png" : @"delete.png";
        _titleImgV.image = [UIImage imageNamed:imgN];
    }
    _listView.shouldHighlightOwn = (_gState != GroupStateNone);
    [_listView refreshList];
    [UIView animateWithDuration:.5 animations:^{
        _listView.frame = fr;
        _titleImgV.alpha = (_gState == GroupStateNone) ? 0:1;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Notification methods
- (void)shoutEncountered:(NSNotification *)notification
{
    Shout *sh = (Shout *) [notification object];
    NSArray *allVc = [self.navigationController viewControllers];
    for(UIViewController *vc in allVc)
    {
        if([vc isKindOfClass: [CommsViewController class]])
        {
            CommsViewController *cVc = (CommsViewController *) vc;
            BOOL isActiveGr = [cVc.myGroup.grId isEqualToString:sh.group.grId];
            if (isActiveGr)
            {
                // notify this class.
                [cVc recievedShout:sh];
              //  [self removeNotfication];
                return;
            }
        }
        else if([vc isKindOfClass: [ReplyViewController class]])
        {
            ReplyViewController *cVc = (ReplyViewController *) vc;
            BOOL isActiveGr = [cVc.myGroup.grId isEqualToString:sh.group.grId];
            if (isActiveGr)
            {
                // notify this class.
                [cVc recievedReplyShout:sh];
               //  [self removeNotfication];
                return;
            }
        }
    }
    // make badge on group.
    [_listView updateBadgeForGroup:sh.group];
    // show banner..
    //if condition: if app is in background and user is open the app by taping on app icon then it should display the badge icon on group cell UI, BUT NOT SHOW BANNERALERT >> ALOK
    if ([[notification.userInfo  objectForKey:kShouldShowBanner] boolValue] == TRUE)
    {
        UIView *vv = [[AppManager appDelegate] window];
        [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text
                          image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
    }
}

-(void)removeNotfication{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNewShoutEncounter object:nil];
    
}
#pragma mark - IBAction

- (IBAction)addGrClicked:(id)sender
{
    buttonClickedIs = @"Add_Group";
    if(validateUser == 0)
    {
        [LoaderView addLoaderToView:self.view];
        [self validateUserAPIGroup];
    }
    else
    {
        invitationAccepted = NO;
        if (![self checkVarification]) return;
        NewGroupViewController *vc = (NewGroupViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)deleteGrClicked:(id)sender
{
    buttonClickedIs = @"Delete_Group";
    if(validateUser == 0)
    {
        [LoaderView addLoaderToView:self.view];
        [self validateUserAPIGroup];
    }
    else
    {
        invitationAccepted = NO;
        [manageGroup setImage:[UIImage imageNamed:@"manageGroup.png"] forState:UIControlStateNormal];
        [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]] ;
        if (![self checkVarification]) return;
        // reset to default mode or convert to delete mode.
        _gState = (_gState == GroupStateDelete) ? GroupStateNone : GroupStateDelete;
        if(_gState != GroupStateNone)
        {
            [lineImg setImage:[UIImage imageNamed:@"redline.png"]] ;
            [deleteGroup setImage:[UIImage imageNamed:@"deletegroupcolor.png"] forState:UIControlStateNormal];
        }
        else
        {
            [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]] ;
            [deleteGroup setImage:[UIImage imageNamed:@"deleteGroup.png"] forState:UIControlStateNormal];
        }
        [self updateUIWithState];
    }
}

- (IBAction)manageGrClicked:(id)sender
{
    buttonClickedIs = @"Manage_Group";
    if(validateUser == 0)
    {
        [LoaderView addLoaderToView:self.view];
        [self validateUserAPIGroup];
    }
    else
    {
        invitationAccepted = NO;
        [deleteGroup setImage:[UIImage imageNamed:@"deleteGroup.png"] forState:UIControlStateNormal];
        [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]] ;
        if (![self checkVarification]) return;
        // reset to default mode or convert to manage mode.
        _gState = (_gState == GroupStateManage) ? GroupStateNone : GroupStateManage;
        if(_gState != GroupStateNone)
        {
            [lineImg setImage:[UIImage imageNamed:@"lightorange.png"]] ;
            [manageGroup setImage:[UIImage imageNamed:@"managegroupcolor"] forState:UIControlStateNormal];
        }
        else
        {
            [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]] ;
            [manageGroup setImage:[UIImage imageNamed:@"manageGroup.png"] forState:UIControlStateNormal];
        }
        [self updateUIWithState];
    }
}

- (IBAction)notificationClicked:(id)sender
{
    buttonClickedIs = @"Notification";
    if(validateUser == 0)
    {
        [LoaderView addLoaderToView:self.view];
        [self validateUserAPIGroup];
    }
    else
    {
        if (![self checkVarification]) return;
        [AppManager downloadActivityOnView:self.view WithCompletion:^(BOOL finished,NSString *message) {
            NotificationViewController *vc = (NotificationViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
            [BadgeView addBadge:0 toView:_activityBtn inCorner:badgeCorner_TopRight marginX:3 marginY:8];
        }];
    }
}

- (void)deleteGroup:(Group *)gp
{
    if (!gp) return;
    // check internet
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject : gp.grId  forKey : @"id"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    // hit api to delete group..
    [client POST:DeleteGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject){
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        DLog(@"%@", response);
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            [_listView removeGrAtIndexpath:_selIndexPath];
            
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            [AppManager showAlertWithTitle:nil Body:str];
            [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
        }
    }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
    }];
}

- (void)quitGroup:(Group *)gp
{
    if (!gp) return;
    // check internet
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject : gp.grId  forKey : @"group_id"];
    [param setObject : [Global shared].currentUser.user_id  forKey : @"user_id"];
    
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    
    // hit api to delete group..
    [client POST:QuitGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            [_listView removeGrAtIndexpath:_selIndexPath];
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            [AppManager showAlertWithTitle:nil Body:str];
            [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
        }
    }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
        NSLog(@"Error is %@", error.localizedDescription);

        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kDeleteAlertTag)
    {
        if (buttonIndex)
        {
            // delete the group
            Group *gr = [_listView groupOnIndexPath:_selIndexPath];
            [self deleteGroup:gr];
        }
        else
        {
            [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
        }
    }
    else if(alertView.tag == kLeaveGroupAlertTag)
    {
        if (buttonIndex)
        {
            // leave the group
            Group *gr = [_listView groupOnIndexPath:_selIndexPath];
            [self quitGroup:gr];
        }
        else
        {
            [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
        }
    }
}

#pragma mark - GroupListDelegate
- (void)didSelectIndexPath:(NSIndexPath *)indxpath
{
    // check owner
    Group *gr = [_listView groupOnIndexPath:indxpath];
    if (_gState == GroupStateNone)
    {
        CommsViewController *vc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        vc.myGroup = gr;
        [self.navigationController pushViewController:vc animated:YES];
        // clear badge on group.
        if (gr.badge)
        {
            [gr clearBadge];
            [_listView updateBadgeForGroup:gr];
        }
    }
    else if (_gState == GroupStateDelete)
    {
        // delete..
        _selIndexPath = indxpath;
        if (![gr.owner.user_id isEqualToString:[[[Global shared] currentUser] user_id]])
        {
            // its not my group.
            [_listView shouldMarkDeleteMode:YES AtIndex:_selIndexPath];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications" message:@"You are not the administrator and can not make changes. Do you want to leave the group?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil];
            alert.tag = kLeaveGroupAlertTag;
            [alert show]; alert = nil;
        }
        else
        {
            [_listView shouldMarkDeleteMode:YES AtIndex:_selIndexPath];
            NSInteger c = [_listView groupsCountInSec:_selIndexPath.section];
            NSString *str = (c == 1) ? @"This is last group of this network. Do you want to delete this group with this network?" :  @"Are you sure, you want to delete this group?";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert !" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
            alert.tag = kDeleteAlertTag;
            [alert show]; alert = nil;
        }
    }
    else
    {
        if (![gr.owner.user_id isEqualToString:[[[Global shared] currentUser] user_id]])
        {
            // its not my group.
            //[AppManager showAlertWithTitle:nil Body:@"You are not admin of this group"];
            _shouldRefresh=YES;
            LHManegGroupViewController *vc = (LHManegGroupViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHManegGroupViewController"];
            vc.myGroup = gr;
            vc.isNonAdmin=YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            // manage...
            _shouldRefresh=YES;
            LHManegGroupViewController *vc = (LHManegGroupViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHManegGroupViewController"];
            vc.myGroup = gr;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict
{
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
    if(![self.navigationController.topViewController isKindOfClass:[self class]])
        [self.navigationController popToViewController:self animated:NO];
    if(sht.parent_shout==nil)
    {
        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        gvc.myGroup = gr;
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
    // clear badge on group.
    if (gr.badge)
    {
        [gr clearBadge];
        [_listView updateBadgeForGroup:gr];
    }
}

-(void)dealloc
{
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)validateUserAPIGroup
{
    if(![AppManager isInternetShouldAlert:YES]) return;
    DLog(@"user id %@",[Global shared].currentUser.user_id);
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:VALIDATE_USER];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *postDictionary ;
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",nil];
    NSData *myData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:myData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        DLog(@"Response---------->>>>>>>:%@ %@\n", response, error);
        if(error == nil)
        {
        NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        DLog(@"responseDict is --- %@",dict);
        [LoaderView removeLoader];
        if(dict != NULL)
        {
        BOOL sucess = [[dict objectForKey:@"status"]boolValue];
        if(sucess)
        {
            if([buttonClickedIs isEqualToString:@"Notification"])
            {
                if (![self checkVarification]) return;
                validateUser = 1;
                [AppManager downloadActivityOnView:self.view WithCompletion:^(BOOL finished,NSString *message) {
                NotificationViewController *vc = (NotificationViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                [BadgeView addBadge:0 toView:_activityBtn inCorner:badgeCorner_TopRight marginX:3 marginY:8];
                }];
            }
            else if ([buttonClickedIs isEqualToString:@"Add_Group"])
            {
                invitationAccepted = NO;
                if (![self checkVarification]) return;
                validateUser = 1;
                NewGroupViewController *vc = (NewGroupViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([buttonClickedIs isEqualToString:@"Delete_Group"])
            {
                invitationAccepted = NO;
                [manageGroup setImage:[UIImage imageNamed:@"manageGroup.png"] forState:UIControlStateNormal];
                [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]] ;
                if (![self checkVarification]) return;
                validateUser = 1;
                // reset to default mode or convert to delete mode.
                _gState = (_gState == GroupStateDelete) ? GroupStateNone : GroupStateDelete;
                if(_gState != GroupStateNone)
                {
                    [lineImg setImage:[UIImage imageNamed:@"redline.png"]] ;
                    [deleteGroup setImage:[UIImage imageNamed:@"deletegroupcolor.png"] forState:UIControlStateNormal];
                }
                else
                {
                    [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]] ;
                    [deleteGroup setImage:[UIImage imageNamed:@"deleteGroup.png"] forState:UIControlStateNormal];
                }
                    [self updateUIWithState];
            }
            else if ([buttonClickedIs isEqualToString:@"Manage_Group"])
            {
                invitationAccepted = NO;
                [deleteGroup setImage:[UIImage imageNamed:@"deleteGroup.png"] forState:UIControlStateNormal];
                [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]] ;
                if (![self checkVarification]) return;
                validateUser = 1;
                // reset to default mode or convert to manage mode.
                _gState = (_gState == GroupStateManage) ? GroupStateNone : GroupStateManage;
                if(_gState != GroupStateNone)
                {
                    [lineImg setImage:[UIImage imageNamed:@"lightorange.png"]] ;
                    [manageGroup setImage:[UIImage imageNamed:@"managegroupcolor"] forState:UIControlStateNormal];
                }
                else
                {
                    [lineImg setImage:[UIImage imageNamed:@"whiteline.png"]] ;
                    [manageGroup setImage:[UIImage imageNamed:@"manageGroup.png"] forState:UIControlStateNormal];
                }
                    [self updateUIWithState];
            }
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


@end
