//
//  LHBackupSessionViewController.m
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHBackupSessionViewController.h"
#import "LHBackupSessionCell.h"
#import "LHBackupSessionDetailVC.h"
#import "LHBackupSessionInfoVC.h"
#import "BackUpManager.h"
#import "SavedViewController.h"
#import "BannerAlert.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "ShoutManager.h"
#import "NotificationViewController.h"
#import "NotificationInfo.h"

@interface LHBackupSessionViewController ()
<UITableViewDataSource, UITableViewDelegate, LHBackupSessionCellDelegate, ProtocolRefreshBackUps>
{
    IBOutlet UITableView *_table;
}

@end

@implementation LHBackupSessionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
    [self addPanGesture];
    [self addTabbarWithTag: BarItemTag_Saved];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]removeObserver:self name:k_GotuserSettings object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSettings) name:k_GotuserSettings object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrived:) name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kchannelBadgeAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelBadgeAdded:) name:kchannelBadgeAdd object:nil];
    [self addNavigationBarEntities];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (![AppManager isInternetShouldAlertwithOutMessage:YES]){
        [self showCountOfNotifications];
        [self checkCountOfShouts];
        [self showCountOnChannelTab];
        self.arrBackUp = [DBManager getAllBackUps];
        if (self.arrBackUp.count)
            [_table reloadData];
        else{
            [AppManager showAlertWithTitle:@"Alert" Body:@"Internet connection is required to fetch data from cloud"];
        }
    }
    else
    {
        [LoaderView addLoaderToView:self.view];
        [BackUpManager ShoutsBackupFromServerOnView:nil completion:^(BOOL finished) {
            [self showCountOfNotifications];
            [self checkCountOfShouts];
            [self showCountOnChannelTab];
            self.arrBackUp = [DBManager getAllBackUps];
            [_table reloadData];
            [LoaderView removeLoader];
        }];
        
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrived:) name:kNewShoutEncounterTemp object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNavigationBarEntities {
    
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text = @"Back-Up Sessions";
    titleLabel.textColor=[UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *lefttButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];
    
    
    self.navigationItem.leftBarButtonItem = lefttButton;
}

-(void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)channelBadgeAdded:(NSNotificationCenter*)notification{
    [self showCountOnChannelTab];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrBackUp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShoutBackup *shoutBackup = [self.arrBackUp objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"LHBackupSessionCell";
    LHBackupSessionCell *cell = (LHBackupSessionCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [LHBackupSessionCell cell];
        cell.delegate = self;
    }
    cell.tag = indexPath.row;
    [cell displayNotification:shoutBackup];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60*kRatio; //61;
}

#pragma mark - LHBackupSessionCellDelegate



- (void)showBackupsonIndex:(NSInteger)index
{
    ShoutBackup *shoutBackup = [self.arrBackUp objectAtIndex:index];
    if (shoutBackup.downloaded.boolValue == YES)
    {
        //dont download again if already downloaded
        [self openLHBackupSessionDetailVC:shoutBackup];
        return;
    }
    [LoaderView addLoaderToView:self.view];
    [BackUpManager ShoutsDataBackupwithBackUpId:shoutBackup.backupId.integerValue shoutBackUp:shoutBackup FromServerOnView:self.view completion:^(BOOL finished) {
        if (finished)
        {
            {
                [self performSelector:@selector(Call:) withObject:shoutBackup afterDelay:3.0 ];
                //            [self openLHBackupSessionDetailVC:shoutBackup];
            }
        }
        else
            [LoaderView removeLoader];
        
    }];
    
}

-(void)openLHBackupSessionDetailVC:(ShoutBackup *)shoutBackup
{
    NSArray *arrShout = [shoutBackup backupShouts].allObjects;
    arrShout = [arrShout filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.pShId = nil"]];
    LHBackupSessionDetailVC *vc = (LHBackupSessionDetailVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHBackupSessionDetailVC"];
    vc.arrBackUp = arrShout;
    vc.titleBarname = shoutBackup.backupName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editBackuponIndex:(NSInteger)index
{
    ShoutBackup *shoutBackup = [self.arrBackUp objectAtIndex:index];
    LHBackupSessionInfoVC *vc = (LHBackupSessionInfoVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHBackupSessionInfoVC"];
    vc.shoutBackUp = shoutBackup;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark LHBackupSessionInfoVC delegate

-(void)RefreshBackUps
{
    self.arrBackUp = [DBManager getAllBackUps];
    [_table reloadData];
}

#pragma mark Other Methods

-(void)gotSettings
{
    if ([PrefManager shouldOpenSaved] == NO)
    {
        [AppManager showAlertWithTitle:@"" Body:k_permissionAlertSaved];
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[SavedViewController class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }
}

- (void)Call:(ShoutBackup *)shoutBackup
{
    [LoaderView removeLoader];
    [self openLHBackupSessionDetailVC:shoutBackup];
    
}

-(void)dealloc
{
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- Notifications Method

- (void)shoutArrived:(NSNotification *)notification
{
    [self checkCountOfShouts];
}

-(void)setMyChannel:(NSDictionary *)dic withBackground:(BOOL)isBackground
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
    if (isForChannel)
    {
        [self setMyChannel:dataDict withBackground:isBackgroundClick];
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
    if([self.navigationController.topViewController isKindOfClass:[LHBackupSessionViewController class]])//crash fix , please dont remove this code
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
                    ch = ch1;
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

#pragma mark - PUSH Notification handling

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
