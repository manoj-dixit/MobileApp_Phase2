//
//  LHBackupSessionDetailVCViewController.m
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHBackupSessionDetailVC.h"
#import "ShoutCell.h"
#import "NSString+Addition.h"
#import "Common.h"
#import "LHVideoPlayer.h"
#import "LHAudioRecorder.h"
#import "ImageOverlyViewController.h"
#import "SavedViewController.h"
#import "BannerAlert.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "ShoutManager.h"
@interface LHBackupSessionDetailVC ()<ShoutCellDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    IBOutlet UILabel *_lblTitle;
    Shout *tempShout;
    NSInteger selectedIndex;
}

@end
@implementation LHBackupSessionDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedIndex = 0;
    [self addTabbarWithTag: BarItemTag_Saved];
    // Do any additional setup after loading the view.
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    NSArray *arrSorted = [self.arrBackUp sortedArrayUsingDescriptors:sortDescriptors];
    self.arrBackUp = arrSorted;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:k_GotuserSettings object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSettings) name:k_GotuserSettings object:nil];
    
    UIView *customTitleView = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 0, 200, 44)];
    customTitleView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, customTitleView.frame.size.width, customTitleView.frame.size.height)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines=0;
    titleLabel.text =_titleBarname;
    titleLabel.textColor = [UIColor colorWithRed:(229.0f/225.0f) green:(0.0f/225.0f) blue:(28.0f/225.0f) alpha:1.0];
    [customTitleView addSubview:titleLabel];
    self.navigationItem.titleView = customTitleView;
    self.navigationItem.rightBarButtonItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kchannelBadgeAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelBadgeAdded:) name:kchannelBadgeAdd object:nil];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated

{
    [super viewWillAppear:YES];
    [self checkCountOfShouts];
    [self showCountOfNotifications];
    [self showCountOnChannelTab];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrived:) name:kNewShoutEncounterTemp object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"PauseAudioNotification"
     object:self];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark other methods

-(void)channelBadgeAdded:(NSNotificationCenter*)notification{
    [self showCountOnChannelTab];
}

-(void)initUI
{
    
        
        UIBarButtonItem *lefttButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
        [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                             [UIColor whiteColor], NSForegroundColorAttributeName,
                                             nil]
                                   forState:UIControlStateNormal];
    
        self.navigationItem.leftBarButtonItem = lefttButton;
        
    

}

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

-(void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)dealloc
{
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrBackUp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShoutCell *cell;
    Shout *sht = [_arrBackUp objectAtIndex:indexPath.row];
    selectedIndex = indexPath.row;
    if (sht.type.integerValue == ShoutTypeTextMsg)
    {
        static NSString *ident = @"ShoutCellIdentifier_Text";
        cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
        
    }
    else if (sht.type.integerValue == ShoutTypeImage)
    {
        static NSString *ident = @"ShoutCellIdentifier_Image";
        cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    }
    else if (sht.type.integerValue == ShoutTypeAudio)
    {
        static NSString *ident = @"ShoutCellIdentifier_Sound";
        cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    }
    else if (sht.type.integerValue == ShoutTypeGif)
    {
        static NSString *ident = @"ShoutCellIdentifier_Gif";
        cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    }
    else
    {
        static NSString *ident = @"ShoutCellIdentifier_Video";
        cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    }
    if (cell == nil)
        cell = [ShoutCell cellWithType:sht.type.integerValue shouldFade:NO];
    cell.delegate = self;
    cell.tag = indexPath.row;
    [cell showShout:sht forChieldCell:NO];
    [cell hideAllButtons];
    NSTimeInterval timestamp = sht.timestamp.doubleValue ;
    NSString *str = [Common localDateInStringFromTimeStamp:timestamp];
    [cell setDateLabelForSessionInfo:str];
    cell.alpha = 1.0f;
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.alpha = 1.0f;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Shout *sht = [_arrBackUp objectAtIndex:indexPath.row];
    //CGFloat th = [sht.text actualSizeWithFont:[UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize] stickToWidth:tableView.frame.size.width-32].height;
    
    CGFloat width = 170*kRatio;
    CGFloat th = [sht.text actualSizeWithFont:[UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize] stickToWidth:width].height+10;
    CGSize size = [sht.text actualSizeWithFont:[UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize] stickToWidth:width] ;
    
    
    //UIFont *font = [UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize];
    //int num = th / font.lineHeight;
  
    
    
    if (sht.type.integerValue == ShoutTypeTextMsg)
    {
//        CGFloat hh = th+50+15;
//        return MAX(hh, 75.0);
        
        // by nim
        if IS_IPAD_PRO_1024 {
            return 120 + (size.height -38);//138
        }
        return 130 + (size.height -38);//138
    }
    else if (sht.type.integerValue == ShoutTypeImage || sht.type.integerValue == ShoutTypeGif)
    {
        CGFloat hh = th+80+120+25;
        return MAX(hh, 210.0);
    }
    else if (sht.type.integerValue == ShoutTypeAudio)
    {
        CGFloat hh = th+50+45+25;
        return MAX(hh, 135.0);
    }
    else if (sht.type.integerValue == ShoutTypeVideo)
    {
        CGFloat hh = th+50+120+25;
        return MAX(hh, 210.0);
    }
    return  250;
}

#pragma mark - ShoutCellDelegate
- (void)didClickButtonWithTag:(CellButtonTag)tag ForObject:(Shout *)sht
{
    if (tag == CellButtonTag_Video)
    {
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
        if (path != nil)
        {
            [LHVideoPlayer playVideoURL:[NSURL fileURLWithPath:path] onController:self];
        }
    }
    else if (tag == CellButtonTag_Audio)
    {
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
        [[LHAudioRecorder shared] playAudioUrl:[NSURL URLWithString:path]];
    }
    else if (tag == CellButtonTag_Image)
    {
        ImageOverlyViewController *vc = (ImageOverlyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ImageOverlyViewController"];
        vc.imagePath = URLForShoutContent(sht.shId, @"png");
        vc.sht = sht;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    else if (tag == CellButtonTag_Video_Export)
    {
        tempShout = sht;
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:k_exportVideoAlert delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alrt.tag = 1001011;
        [alrt show];
        alrt = nil;
    }
    else if (tag == CellButtonTag_Reply)
    {
        if (self.isChieldView)
        {
            return;
        }
        Shout *sht = [self.arrBackUp objectAtIndex:selectedIndex];
        LHBackupSessionDetailVC *vc = (LHBackupSessionDetailVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHBackupSessionDetailVC"];
        NSArray *childShout = [DBManager getAllFavouriteChieldShouts:sht];
        if (childShout.count>0)
        {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:childShout];
            [arr insertObject:sht atIndex:0];
            vc.arrBackUp = arr;
            vc.title=self.title;
            vc.isChieldView = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        childShout = nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        if (alertView.tag == 1001011)
        {
            [[Global shared] saveVideo:tempShout];
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

#pragma mark- Notifications Method

- (void)shoutArrived:(NSNotification *)notification
{
    [self checkCountOfShouts];
}

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick
{
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

@end
