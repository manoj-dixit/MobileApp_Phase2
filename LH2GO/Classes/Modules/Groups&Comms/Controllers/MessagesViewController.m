//
//  MessagesViewController.m
//  LH2GO
//
//  Created by Linchpin on 23/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "MessagesViewController.h"
#import "CommsViewController.h"
#import "ShoutManager.h"
#import "ReplyViewController.h"
#import "BannerAlert.h"
#import "AddGroupViewController.h"
#import "ManageViewController.h"
#import "ManageGroupListController.h"
#import "BadgeView.h"
#import "SonarViewController.h"
#import "TimeConverter.h"

@interface MessagesViewController ()<UITableViewDelegate,UITableViewDataSource,APICallProtocolDelegate>
{
    NSArray *filteredContentList;
    NSMutableArray *groupArr;
    NSMutableArray *originalGroupArr;
    BOOL isSearching;
    NSInteger globalVal;
    SharedUtils *sharedUtils;
    
}

@property (strong, nonatomic) LGPlusButtonsView *plusButtonsViewMain;

@end

@implementation MessagesViewController
@synthesize searchResults;

#pragma FloatingButton
-(void)addfloatingButton {
    NSArray *colorsArray = nil;
    colorsArray = [[NSArray alloc] initWithObjects:[UIColor  whiteColor], [UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor], nil];
    
    _plusButtonsViewMain = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:5
                                                         firstButtonIsPlusButton:YES
                                                                   showAfterInit:YES
                                                                   actionHandler:^(LGPlusButtonsView* plusButtonView, NSString* title, NSString *description, NSUInteger index)
                            {
                                DLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                                
                                if(globalVal != 6){
                                    
                                    if (index == 0)
                                        printf("index 0");
                                    else if (index == 1){
                                        AddGroupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddGroupViewController"];
                                        [_plusButtonsViewMain hideButtonsAnimated:YES completionHandler:nil];
                                        [self.navigationController pushViewController:vc animated:NO];
                                    }else if (index == 2){
                                        InviteUserViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteUserViewController"];
                                        vc.isSingleUserInvite=YES;
                                        [_plusButtonsViewMain hideButtonsAnimated:YES completionHandler:nil];
                                        [self.navigationController pushViewController:vc animated:NO];
                                    }else if (index == 3){
                                        LHBackupSessionViewController *backUpSessionCntrl= [self.storyboard instantiateViewControllerWithIdentifier:@"LHBackupSessionViewController"];
                                        [self.navigationController pushViewController:backUpSessionCntrl animated:NO];
                                    }else if (index == 4){
                                        LHSavedCommsViewController *savedCommsCntrl = [self.storyboard instantiateViewControllerWithIdentifier:@"LHSavedCommsViewController"];
                                        [self.navigationController pushViewController:savedCommsCntrl animated:NO];
                                    }
                                }
                            }];
    
    // _plusButtonsViewMain.observedScrollView = self.scrollView;
    _plusButtonsViewMain.coverColor = [Common colorwithHexString:@"000000" alpha:0.7];
    _plusButtonsViewMain.position = LGPlusButtonsViewPositionBottomRight;
    _plusButtonsViewMain.plusButtonAnimationType = LGPlusButtonAnimationTypeCrossDissolve;
    
    [_plusButtonsViewMain setButtonsTitleFont:[UIFont fontWithName:@"loudhailer" size:25] forOrientation:LGPlusButtonsViewOrientationAll];
    //   [_plusButtonsViewMain setButtonsTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_plusButtonsViewMain setButtonsTitleColors:colorsArray forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonsAppearingAnimationType:LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical];
    [_plusButtonsViewMain setButtonsTitles:@[@"s", @"v", @"/", @"(",@"'"] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonsTitles:@[@"u", @"v", @"/", @"(", @"'"] forState:UIControlStateSelected];
    [_plusButtonsViewMain setDescriptionsTexts:@[@"", @"Create Group", @"Add Contact", @"Back Ups", @"Saved Stuff"]];
    
    CGFloat h_w_ofButtons,h_w_ofMoreButton ;
    if (IPAD){
        h_w_ofButtons = 54.f;
        h_w_ofMoreButton =66.f;
        
    }else{
        h_w_ofButtons = 44.f;
        h_w_ofMoreButton = 56.f;
    }
    
    [_plusButtonsViewMain setButtonsSize:CGSizeMake(h_w_ofButtons, h_w_ofButtons) forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setButtonsLayerCornerRadius:h_w_ofButtons/2.f forOrientation:LGPlusButtonsViewOrientationAll];
    
    [_plusButtonsViewMain setButtonsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [_plusButtonsViewMain setButtonsLayerShadowOpacity:0.5];
    [_plusButtonsViewMain setButtonsLayerShadowRadius:3.f];
    [_plusButtonsViewMain setButtonsLayerShadowOffset:CGSizeMake(0.f, 2.f)];
    [_plusButtonsViewMain setButtonAtIndex:0 size:CGSizeMake(h_w_ofMoreButton, h_w_ofMoreButton)
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    
    [_plusButtonsViewMain setButtonAtIndex:0 layerCornerRadius:h_w_ofMoreButton/2.f
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont fontWithName:@"Aileron-Regular" size:30]
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [_plusButtonsViewMain setButtonAtIndex:0 titleOffset:CGPointMake(0.f, 0.f) forOrientation:LGPlusButtonsViewOrientationAll];
    
    [_plusButtonsViewMain setButtonAtIndex:0 backgroundColor:[Common colorwithHexString:@"85BD40" alpha:1] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:0 backgroundColor:[Common colorwithHexString:@"85BD40" alpha:1] forState:UIControlStateHighlighted];
    [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont fontWithName:@"loudhailer" size:25] forOrientation:LGPlusButtonsViewOrientationAll];
    
    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_plusButtonsViewMain setButtonAtIndex:3 backgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:3 backgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_plusButtonsViewMain setButtonAtIndex:4 backgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:4 backgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    
    [_plusButtonsViewMain setDescriptionsBackgroundColor:[UIColor clearColor]];
    [_plusButtonsViewMain setDescriptionsTextColor:[UIColor whiteColor]];
    [_plusButtonsViewMain setDescriptionsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [_plusButtonsViewMain setDescriptionsLayerShadowOpacity:0.25];
    [_plusButtonsViewMain setDescriptionsLayerShadowRadius:1.f];
    [_plusButtonsViewMain setDescriptionsLayerShadowOffset:CGSizeMake(0.f, 1.f)];
    [_plusButtonsViewMain setDescriptionsLayerCornerRadius:6.f forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setDescriptionsContentEdgeInsets:UIEdgeInsetsMake(4.f, 8.f, 4.f, 8.f) forOrientation:LGPlusButtonsViewOrientationAll];
    
    for (NSUInteger i=1; i<=4; i++)
        [_plusButtonsViewMain setButtonAtIndex:i offset:CGPointMake(-6.f, 0.f)
                                forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [_plusButtonsViewMain setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -2.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont fontWithName:@"Aileron-Regular" size:30] forOrientation:LGPlusButtonsViewOrientationLandscape];
    }
    [self.view addSubview:_plusButtonsViewMain];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    
    _bellIconLabel.layer.cornerRadius = _bellIconLabel.frame.size.width/2;
    _bellIconLabel.layer.masksToBounds = YES;
    
    _notificationCountLabel.layer.cornerRadius = _notificationCountLabel.frame.size.width/2;
    _notificationCountLabel.layer.masksToBounds = YES;
    _notificationCountLabel.text = [NSString stringWithFormat:@"%ld",[[NSUserDefaults standardUserDefaults]integerForKey:k_NotifTabCount]];// will need to check this at run time sending notifications
    
    UITapGestureRecognizer *notificationTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notificationViewTapped:)];
    [_notificationView addGestureRecognizer:notificationTapGesture];
    
    self.navigationController.navigationBar.hidden = NO;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEConnected" object:nil];
    _tableMessage.delegate = self;
    _tableMessage.dataSource = self;
    [groupArr removeAllObjects];
    [originalGroupArr removeAllObjects];
    globalVal = 6;
    [self addTabbarWithTag: BarItemTag_Groups];
    
    [self addPanGesture];
    _tableMessage.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // new group/network notification..
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kUpdateGroupList object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kActiveNetworkChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:kUpdateGroupList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:kActiveNetworkChange object:nil];
    groupArr = [[NSMutableArray alloc]init];
    originalGroupArr = [[NSMutableArray alloc]init];
    // new shout notification..
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounter object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrivedInNotification:) name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kchannelBadgeAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelBadgeAdded:) name:kchannelBadgeAdd object:nil];
    [self addfloatingButton];
    _plusButtonsViewMain.delegate = self;
    [self addNavigationBarViewComponents];
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Messages";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self gatherDatasource];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationReceivedForNotfTab" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTabBadge) name:@"NotificationReceivedForNotfTab" object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableMessage reloadData];
        
    });
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOFIFICATION_IF_CANCELLED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:KNOFIFICATION_IF_CANCELLED object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showCountHere];
    [self showCountOnNotificationsTab];
    [self showCountOnChannelTab];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)channelBadgeAdded:(NSNotificationCenter*)notification{
    [self showCountOnChannelTab];
}

- (void)shoutArrivedInNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableMessage reloadData];
    });
}

- (void)refreshList
{
    [self gatherDatasource];
    if (_datasource.count >0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableMessage reloadData];
        });
    }
}

-(void)handleTabBadge{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showCountOnNotificationsTab];
    });
}

#pragma mark - PrivateMethods

-(void)showCountHere{
    
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:k_actionableNotify];
    [self showActionCount:[str integerValue]];
}

- (void)gatherDatasource
{
    [Global shared].isReadyToStartBLE = YES;
    NSMutableArray *nets = [NSMutableArray new];
    //   NSString *activeNetId = [PrefManager activeNetId];
    NSArray *networks = [DBManager getNetworks];
    for(Network *net in networks){
        
        if([net.netId isEqualToString:@"1"]){
            
            NSArray *groups = [DBManager getShortedGroupsForNetwork:net];
            
            if(groups.count==0)
            {
                [self methodToCallGroupAPI];
            }
            NSDictionary *d = @{ @"network" : net,
                                 @"groups"  : groups
                                 };
            [nets addObject:d];
            _datasource = nets;
            if (_datasource.count) {
                NSDictionary *d = [_datasource objectAtIndex:0];
                originalGroupArr = [d objectForKey:@"groups"];
                
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    [self methodToGetP2PContact];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableMessage reloadData];
                });
                
            }
            else
                _datasource = [[NSMutableArray alloc] init];
        }else
        {
            [self methodToCallGroupAPI];
            
            //[self methodToGetP2PContact];
        }
    }
}

-(void)p2pGroup
{
    NSMutableArray *nets = [NSMutableArray new];
    NSArray *networks = [DBManager getNetworks];
    for(Network *net in networks){
        
        if([net.netId isEqualToString:@"1"]){
            
            NSArray *groups = [DBManager getShortedGroupsForNetwork:net];
            
            if(groups.count==0)
            {
                [self methodToCallGroupAPI];
            }
            NSDictionary *d = @{ @"network" : net,
                                 @"groups"  : groups
                                 };
            [nets addObject:d];
            _datasource = nets;
            if (_datasource.count) {
                NSDictionary *d = [_datasource objectAtIndex:0];
                originalGroupArr = [d objectForKey:@"groups"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableMessage reloadData];
                });
                
            }
            else
                _datasource = [[NSMutableArray alloc] init];
        }else
        {
            
            //[self methodToGetP2PContact];
        }
    }
}

-(void)methodToGetP2PContact
{
    //return;
    if ([AppManager isInternetShouldAlert:NO])
    {
        //show loader...
        NSMutableDictionary *postDictionary ;
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",nil];
        //show loader...
        //        [LoaderView addLoaderToView:self.view];
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,GETP2PList];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
    }
}

-(void)methodToCallGroupAPI
{
    if ([AppManager isInternetShouldAlert:NO])
    {
        //show loader...
        NSMutableDictionary *postDictionary ;
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"owner_id",nil];
        
        AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
        NSString *token = [PrefManager token];
        [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,GETGroupList];
        [client POST:urlString parameters:postDictionary constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            DLog(@"%@", response);
            if(response != NULL)
            {
                if([[response objectForKey:@"status"] boolValue])
                {
                    NSArray *arrayOfData =  [response objectForKey:@"data"];
                    for (NSDictionary *ch in arrayOfData)
                    {
                        [Group addGroupWithDict:ch forUsers:@[[Global shared].currentUser]  pic:nil pending:NO];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableMessage reloadData];
                        
                    });
                    [self methodToGetP2PContact];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(operation.response.statusCode == kTokenExpCode){
                // disconnect all the peripheral and master connections
                [PrefManager setLoggedIn:NO];
                [BaseViewController showLogin];
            }else{
                [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:NO];
            }
        }];
    }
}

- (Group *)groupOnIndexPath:(NSIndexPath *)indxP{
    
    if (!indxP) return nil;
    NSDictionary *d;
    NSArray *grps;
    Group *gr;
    if(isSearching)
    {
        gr = [filteredContentList objectAtIndex:indxP.row];
        
    }
    else
    {
        d = [_datasource objectAtIndex:indxP.section];
        grps = [d objectForKey:@"groups"];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
        gr = [arr objectAtIndex:indxP.row];
        
    }
    return gr;
    
}

- (void)updateBadgeForGroup {
    [self checkCountOfShouts];
}


- (void)updateCountOfGroup:(Group*)gr{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"network = %@", gr.network];
    NSArray *nets = [_datasource filteredArrayUsingPredicate:predicate];
    if (!nets.count) return;
    
    NSDictionary *d = [nets firstObject];
    NSArray *grps = [d objectForKey:@"groups"];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                 ascending:YES];
    NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSInteger row;
    if(isSearching){
        row = [groupArr indexOfObject:gr];
        
    }
    else{
        row = [arr indexOfObject:gr];
    }
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
    
    NSUInteger numberOfIndex = [_tableMessage numberOfRowsInSection:0];
    
    // to check rows is already equal or greater than the existing rows
    if (numberOfIndex>=row)
    {
        @try {
            [_tableMessage reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationFade];
        } @catch (NSException *exception) {
            DLog(@"Exception is %@",exception.description);
        } @finally {
        }
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
        //        ReplyViewController rv = (ReplyViewController )self.navigationController.topViewController;
        //        [self.navigationController popToRootViewControllerAnimated:YES];
        //        rv = nil;
    }
    //    if(![self.navigationController.topViewController isKindOfClass:[self class]])
    //        [self.navigationController popToViewController:self animated:NO];
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
        // [self updateBadgeForGroup];
    }
}

#pragma mark - Notification methods
- (void)shoutArrived:(NSNotification *)notification
{
    // BOOL isActiveGroup =  NO;
    
    Shout *sh = (Shout *) [notification object];
    NSString *str = [[NSUserDefaults standardUserDefaults]valueForKey:k_ShoutEncountered];
    
    
    //NSArray arr = [(UINavigationController )[((REFrostedViewController*)[UIApplication sharedApplication].keyWindow.rootViewController)contentViewController] viewControllers];
    // NSLog(@"%@",arr);
    if([str isEqualToString:[sh.timestamp stringValue]]){
        [self updateCountOfGroup:sh.group];
    }
    else{
        
        //        NSArray *allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
        //        BOOL isNeedToSHowBanner = NO;
        //        //    if (allVc == nil) {
        //        //        // for channel content page
        //        //        isNeedToSHowBanner = YES;
        //        //    }else
        //        //    {
        //        NSLog(@"Prsent view controller is %@",self.navigationController.visibleViewController);
        //        UIViewController *tempVC;
        //
        //        for(UIViewController *vc in allVc)
        //        {
        //            if([vc isKindOfClass: [CommsViewController class]])
        //            {
        //                tempVC = vc;
        //                CommsViewController *cVc = (CommsViewController *) vc;
        //                BOOL isActiveGr = [cVc.myGroup.grId isEqualToString:sh.group.grId];
        //                if (isActiveGr)
        //                {
        //                    // notify this class.
        //                    isActiveGroup = YES;
        //                    [cVc recievedShout:sh];
        //                    isNeedToSHowBanner = NO;
        //                    return;
        //                }else{
        //                       isActiveGroup = NO;
        //                       isNeedToSHowBanner = YES;
        //                }
        //
        //            }
        //            else if([vc isKindOfClass: [ReplyViewController class]])
        //            {
        //                tempVC = vc;
        //                ReplyViewController *cVc = (ReplyViewController *) vc;
        //                BOOL isActiveGr = [cVc.myGroup.grId isEqualToString:sh.group.grId];
        //                if (isActiveGr)
        //                {
        //                    // notify this class.
        //                    isActiveGroup = YES;
        //                    [cVc recievedReplyShout:sh];
        //                    isNeedToSHowBanner = NO;
        //
        //                    return;
        //                }
        //                else
        //                {
        //                    isActiveGroup = NO;
        //                    isNeedToSHowBanner = YES;
        //                }
        //            }
        //
        //            else if([vc isKindOfClass: [MessagesViewController class]]){
        //                tempVC = vc;
        //                isNeedToSHowBanner = YES;
        //            }
        //            else if([vc isKindOfClass: [NotificationViewController class]]){
        //                tempVC = vc;
        //                isNeedToSHowBanner = YES;
        //            }
        //            else if([vc isKindOfClass: [SonarViewController class]]){
        //                tempVC = vc;
        //                isNeedToSHowBanner = YES;
        //            }
        //            else if([vc isKindOfClass: [SettingsViewController class]]){
        //                tempVC = vc;
        //                isNeedToSHowBanner = YES;
        //            }
        //            else{
        //                 tempVC = vc;
        //            }
        //
        //
        //        }
        //
        //        // make badge on group.
        //        //   if(![str isEqualToString:[sh.timestamp stringValue]]){
        //
        //        if([tempVC isKindOfClass: [ReplyViewController class]] || [tempVC isKindOfClass: [CommsViewController class]]){
        //            isNeedToSHowBanner = NO;
        //        }
        //        if(!isActiveGroup && [tempVC isKindOfClass: [CommsViewController class]]){
        //            isNeedToSHowBanner = YES;
        //        }
        //        else{
        //            if(tempVC!=nil){
        sh.group.totShoutsReceived = [NSNumber numberWithInt:([ sh.group.totShoutsReceived intValue] +1)];
        [DBManager save];
        
        // [self updateBadgeForGroup];
        [self updateCountOfGroup:sh.group];
        
        //  isNeedToSHowBanner = YES;
        //  }
        
        // }
        
        
        // show banner..
        //if condition: if app is in background and user is open the app by taping on app icon then it should display the badge icon on group cell UI, BUT NOT SHOW BANNERALERT >> ALOK
        //        if ([[notification.userInfo  objectForKey:kShouldShowBanner] boolValue] == TRUE)
        //        {
        //            if(isNeedToSHowBanner && ([tempVC isKindOfClass: [CommsViewController class]]) && !isActiveGroup){
        //
        //                tempVC = nil;
        //                UIView *vv = [[AppManager appDelegate] window];
        //                [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text
        //                                  image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
        //            }
        //          else if(isNeedToSHowBanner && ([tempVC isKindOfClass: [MessagesViewController class]] || [tempVC isKindOfClass:[NotificationViewController class]] || [tempVC isKindOfClass:[SonarViewController class]])){
        //                tempVC = nil;
        //                UIView *vv = [[AppManager appDelegate] window];
        //                //        if(sh.owner.picUrl){}
        //                //        else{
        //                [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text
        //                                  image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
        //                //        }
        //            }
        //            else if (isNeedToSHowBanner && !([tempVC isKindOfClass: [ReplyViewController class]] || [tempVC isKindOfClass: [CommsViewController class]]) && (tempVC != nil)) {
        //                tempVC = nil;
        //                UIView *vv = [[AppManager appDelegate] window];
        //                //        if(sh.owner.picUrl){}
        //                //        else{
        //                [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text
        //                                  image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
        //                //        }
        //            }
        //        }
        
    }
    
    //  }
    //  [[NSUserDefaults standardUserDefaults]setValue:[sh.timestamp stringValue] forKey:@"shoutEn"];
    //[[NSUserDefaults standardUserDefaults]synchronize];
    
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    //NSInteger cnt = _usrDict.allKeys.count;
    //    if (isSearch) {
    //        return 1;
    //    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        if (_datasource.count>0) {
            return filteredContentList.count;
        }
        else
            return 0;
    }
    else
    {
        if (_datasource.count>0) {
            
            return originalGroupArr.count;
            //NSDictionary *d = [_datasource objectAtIndex:section];
            // NSArray *grps = [d objectForKey:@"groups"];
            // return grps.count;
        }
        else
            return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView* )tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"messageCell";
    MessageCell *cell = (MessageCell* ) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Group *gr;
    if(isSearching)
    {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        filteredContentList = [filteredContentList sortedArrayUsingDescriptors:@[sortDescriptor]];
        if(indexPath.row<filteredContentList.count)
            gr = [filteredContentList objectAtIndex:indexPath.row];
        else
            gr = [filteredContentList objectAtIndex:filteredContentList.count-1];
    }
    else
    {    NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [originalGroupArr sortedArrayUsingDescriptors:@[sortDescriptor]];
        if(indexPath.row<arr.count)
            gr = [arr objectAtIndex:indexPath.row];
        else
            gr = [arr objectAtIndex:arr.count-1];
    }
    [cell showGroup:gr];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.btn_onCell setTitle:@"w" forState:UIControlStateNormal];
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return  44;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kRatio * tableView.rowHeight;// assuming that the image will stretch across the width of the screen
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Group *gr = [self groupOnIndexPath:indexPath];
    if(gr.isPending){
        if(gr.isP2PContact)
        {
            [AppManager showAlertWithTitle:@"Alert" Body:[NSString stringWithFormat:@"Your P2P contact request is pending. Please wait"]];

        }else
        {
        [AppManager showAlertWithTitle:@"Alert" Body:[NSString stringWithFormat:@"Your group is pending. Please go to manage group to complete the process"]];
        }
    }
    else{
        
        //manoj
        // hide the keyboard if used tapped on any index
        [searchBarGroup resignFirstResponder];
        Global *shared = [Global shared];
        [DBManager updateShoutsIsReadOnClickingMessages:gr.grId withUserID:shared.currentUser.user_id];
        CommsViewController *vc = nil;
        vc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        vc.myGroup = gr;
        vc.groupIdIS = [gr.grId integerValue];
        vc.selectedGroupIndex = indexPath.row;
        [self.navigationController pushViewController:vc animated:YES];
        if (gr.totShoutsReceived)
        {
            [gr clearBadge:gr];
            // [self updateBadgeForGroup];
        }
        [righttButton  setTitle:@"g"];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOFIFICATION_IF_CANCELLED object:nil];
    }
}

#pragma mark - Search Implementation

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if(searchBar.text.length >1)
        isSearching = YES;
    else
        isSearching = NO;
}

- (void)searchBar:(UISearchBar* )searchBar textDidChange:(NSString* )searchText {
    
    //Remove all objects first.
    NSPredicate *sPredicate;
    [groupArr removeAllObjects];
    if ([searchBar.text isEqualToString:@""])
    {
        isSearching=NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableMessage reloadData];
        });
    }
    else
    {
        isSearching = YES;
        NSString * match = searchBar.text;
        sPredicate = [NSPredicate predicateWithFormat:@"grName contains[c] %@", match];;
        DLog(@"Datasource is %@",[_datasource objectAtIndex:0]);
        NSDictionary *d = [_datasource objectAtIndex:0];
        NSArray *grps = [d objectForKey:@"groups"];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        filteredContentList = [arr filteredArrayUsingPredicate:sPredicate];
        [groupArr addObjectsFromArray:filteredContentList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableMessage reloadData];
        });
    }
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    DLog(@"Cancel clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    DLog(@"Search Clicked");
    [searchBar resignFirstResponder];
}


#pragma mark -- LGPlusButtonsViewDelegate functions

- (void)plusButtonsViewWillShowButtons:(LGPlusButtonsView *)plusButtonsView{
    globalVal = 0;
    DLog(@"5");
    
}
- (void)plusButtonsViewWillHideButtons:(LGPlusButtonsView *)plusButtonsView{
    globalVal = 6;
    DLog(@"6");
    
}


#pragma mark reload table
-(void)reloadTable:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        isSearching = NO;
        [self checkCountOfShouts];
        [_tableMessage reloadData];
        
    });
}

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType
{
    if([self.navigationController.topViewController isKindOfClass:[MessagesViewController class]])//crash fix , please dont remove this code
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

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL{
    if(responseDict != nil)
    {
        NSLog(@"responseDict is URL is--- %@ ++ %@",dataTaskURL,responseDict);
        [LoaderView removeLoader];
        BOOL status = [[responseDict objectForKey:@"status"] boolValue];
        NSString *msgStr= [responseDict objectForKey:@"status"];
        if (status || [msgStr isEqualToString:@"Success"])
        {
            
            //            data =     (
            //                        {
            //                            email = "manojdixit.dixit8@gmail.com";
            //                            "profile_photo" = "https://s3-us-west-2.amazonaws.com/loud-hailer/user_files/manojhh_df9ab343810f84b3860bf9ad9b26f9fb.jpg";
            //                            status = 0;
            //                            username = manojhh;
            //                        }
            //                        );
            //            message = "P2P List!";
            //            status = 1;
            
            NSArray *arrayOfData =  [responseDict objectForKey:@"data"];
            NSDictionary *dict = [responseDict objectForKey:@"data"];
            
            NSDictionary *inviteDict = [dict objectForKey:@"invite_received"];
            NSDictionary *sendDict = [dict objectForKey:@"invited_sent"];
            
            
            BOOL isAnyAdded1 =  [self addp2pGroups:inviteDict forInviteing:YES];
            
            BOOL isAnyAdded2 =  [self addp2pGroups:sendDict forInviteing:NO];
            
            if(isAnyAdded1 || isAnyAdded2)
            {
                [self p2pGroup];
                
            }
        }
    }
}

-(BOOL)addp2pGroups:(NSDictionary *)dict forInviteing:(BOOL)isInvite
{
    BOOL isAnyAdded = NO;
    for (NSDictionary *ch in dict)
    {
        // user blocked
        if([[ch objectForKey:@"status"] intValue] == 2)
        {
            continue;
        }
        // if user in invited
        if(isInvite)
        {
            // user in invited and
            if([[ch objectForKey:@"status"] intValue] == 0)
            {
                continue;
            }
        }
        Group *gr;
        BOOL isALreadyExist =  NO;
        NSArray *arr = originalGroupArr;
        for(int i =0; i< arr.count; i++)
        {
            gr = [arr objectAtIndex:i];
            
            
            if([gr.grId isEqualToString:[ch objectForKey:@"loudhailer_id"]])
            {
                isALreadyExist = YES;
            }
        }
        
        if(!isALreadyExist)
        {
            //  User
            User *u= [User addUserWithDict:ch pic:nil];
            u.parent_account_id = @"1011";
            [DBManager save];
            
            int length = (UInt64)strtoull([[ch objectForKey:@"loudhailer_id"] UTF8String], NULL, 16);
            NSLog(@"The required Length is %d", length);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[ch objectForKey:@"username"],@"group_name",[NSString stringWithFormat:@"%@",[ch objectForKey:@"timestamp"]],@"timestamp",[ch objectForKey:@"profile_photo"],@"group_photo",[ch objectForKey:@"email"],@"email_Id",[NSString stringWithFormat:@"%d",length],@"id", nil];
            isAnyAdded = YES;
            [Group addGroupWithDictForP2PContact:dic forUsers:@[u]  pic:nil isPendingStatus:![[ch objectForKey:@"status"] boolValue]];
            // sleep(1);
        }
    }
    return isAnyAdded;
}

#pragma mark - PrivateMethods
-(void)notificationViewTapped:(UITapGestureRecognizer*)gesture
{
    NotificationViewController *notificationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    [self.navigationController pushViewController:notificationViewController animated:YES];    
}

-(void)sendSelectedTypeForCell:(NSString*)actionType withRow:(NSIndexPath*)indexPath
{
    if([actionType isEqualToString:@"Exit"]){
        Group *group = [self groupOnIndexPath:indexPath];
        if(group != nil){
            [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Are you sure you want to exit this group?" firstButtonMsg:@"YES" andSecondBtnMsg:@"NO" andVC:self noOfBtn:2 completion:^(BOOL isOkButton) {
                if (isOkButton) {
                    [self quitGroup:group forIndex:indexPath];
                }
            }];
        }
    }
    else if ([actionType isEqualToString:@"Delete"]){
        Group *group = [self groupOnIndexPath:indexPath];
        if(group != nil)
        {
            [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Are you sure you want to delete this group?" firstButtonMsg:@"YES" andSecondBtnMsg:@"NO" andVC:self noOfBtn:2 completion:^(BOOL isOkButton) {
                if (isOkButton) {
                    [self deleteGroup:group forIndex:indexPath];
                }
            }];
        }
    }
    else if([actionType isEqualToString:@"Manage"]){
        Group *group = [self groupOnIndexPath:indexPath];
        if(group != nil){
            BOOL mine = NO;
            if(group.owner){
                mine = [group.owner.user_id isEqualToString:[Global shared].currentUser.user_id];
            }
            else if(group.isPending){
                mine = YES;
            }
            
            if(mine){
                ManageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ManageViewController"];
                vc.selectedIndex = indexPath.row;
                vc.myGroup = group;
                [self.navigationController pushViewController:vc animated:true];
            }
        }
    }
}

- (void)quitGroup:(Group *)gp forIndex:(NSIndexPath*)selectedIndex
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
        DLog(@"%@", response);
        if(response != NULL)
        {
            BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
            if(status)
            {
                [self removeGroupAtIndexPath:selectedIndex];
            }
            else
            {
                NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
                [AppManager showAlertWithTitle:nil Body:str];
                if ([str isEqualToString:@"Group does not exist.!"]) {
                    [self removeGroupAtIndexPath:selectedIndex];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableMessage reloadData];
                    });
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
    }];
    
}

-(void)removeGroupAtIndexPath:(NSIndexPath*)indexPath{
    // remove this group from the list
    NSMutableDictionary *d = [[_datasource objectAtIndex:indexPath.section] mutableCopy];
    NSMutableArray *grps = [[d objectForKey:@"groups"] mutableCopy];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                 ascending:YES];
    NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
    // the array count is greater than or equal the index path of that group
    if (arr.count>=indexPath.row)
    {
        Group *gr = [arr objectAtIndex:indexPath.row];
        
        [DBManager deleteOb:gr];
        [grps removeObjectAtIndex:indexPath.row];
        
        if (grps.count == 0) {
            // delete network
            //  Network *net = [d objectForKey:@"network"];
            //[DBManager deleteOb:net];
            
            // remove this section
            [_datasource removeObjectAtIndex:indexPath.section];
            //_isSelected = NO;
            
        } else {
            [d setObject:grps forKey:@"groups"];
            [_datasource replaceObjectAtIndex:indexPath.section withObject:d];
            //_isSelected = NO;
            [_tableMessage reloadData];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
    }
}

#pragma mark - DeleteGroup
- (void)deleteGroup:(Group *)gp forIndex:(NSIndexPath*)selectedIndex
{
    if (!gp) return;
    // check internet
    if(![AppManager isInternetShouldAlert:YES])
        return;
    
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
                [self removeGroupAtIndexPath:selectedIndex];
            }
            else
            {
                NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
                [AppManager showAlertWithTitle:nil Body:str];
                // [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
    }];
}

@end
