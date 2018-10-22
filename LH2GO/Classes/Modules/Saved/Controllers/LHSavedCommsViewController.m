//
//  LHSavedCommsViewController.m
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHSavedCommsViewController.h"
#import "ShoutCell.h"
#import "NSString+Addition.h"
#import "LHAudioRecorder.h"
#import "LHVideoPlayer.h"
#import "ImageOverlyViewController.h"
#import "BannerAlert.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "ShoutManager.h"
#import "ChanelViewController.h"
#import "FavoriteDownloadManager.h"
#import "NotificationViewController.h"
#import "NotificationInfo.h"

#define k_FavToUnFavSaved 100

@interface LHSavedCommsViewController ()<ShoutCellDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITableView *_favTable;
      NSInteger shoutIndex;
}

@end

@implementation LHSavedCommsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Saved Stuff";
    self.navigationItem.rightBarButtonItem = nil;
    [self addPanGesture];
    //[self sortRecords];
    [self addTabbarWithTag: BarItemTag_Saved];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrived:) name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kchannelBadgeAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelBadgeAdded:) name:kchannelBadgeAdd object:nil];
    [self addNavigationBarEntities];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkCountOfShouts];
    
    if (![AppManager isInternetShouldAlertwithOutMessage:YES]){
        [self showCountOfNotifications];
        [self checkCountOfShouts];
        [self showCountOnChannelTab];
        self.savedShouts=[[DBManager getAllFavouriteShouts] mutableCopy];
        if (self.savedShouts)
            [_favTable reloadData];
        else{
            [AppManager showAlertWithTitle:@"Alert" Body:@"Internet connection is required to fetch data from cloud"];
        }
    }
    else
    {
        [FavoriteDownloadManager downloadFavFromServerOnView:self.view completion:^(BOOL finished) {
            [self showCountOfNotifications];
            [self checkCountOfShouts];
            [self showCountOnChannelTab];
            self.savedShouts=[[DBManager getAllFavouriteShouts] mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_favTable reloadData];
            });
        }];
        
    }

    
    
    if (!self.isChieldView)
    {
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showCountOfNotifications];
    if(_savedShouts.count >0 ){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_favTable reloadData];
        });
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"PauseAudioNotification"
     object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
        
        
    
}

- (void)addNavigationBarEntities{
    
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text = @"Saved Stuff";
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

-(void)channelBadgeAdded:(NSNotificationCenter*)notification{
    [self showCountOnChannelTab];
}

-(void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return _savedShouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShoutCell *cell;
    Shout *sht = [_savedShouts objectAtIndex:indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:k_shoutSaved];
    [defaults synchronize];
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
    cell._btnReport.hidden = YES;
    [cell showShout:sht forChieldCell:NO];
    cell.contentView.alpha = 1.0f;
    [cell hideRebroadCastAndReply];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.transform = CGAffineTransformMakeScale(.8, .9);
    [UIView animateWithDuration:.3 animations:^{
        cell.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UITableViewDelegate
/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Shout *sht = [_savedShouts objectAtIndex:indexPath.row];
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
        CGFloat hh = th+50+120+25;
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
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Shout *sht = [_savedShouts objectAtIndex:indexPath.row];
    if((sht.reciever.email == nil || sht.text == nil) && !sht.isFromCMS){   // receiving side
        //[tableView reloadData];
        return 0;
    }
    else
    {
        CGFloat width = 180*kRatioWidth; //170
        CGFloat th = [sht.text actualSizeWithFont:[UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize] stickToWidth:width].height+10;
        CGSize size = [sht.text actualSizeWithFont:[UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize] stickToWidth:width] ;
        
        
        UIFont *font = [UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize];
        int num = th / font.lineHeight;
        //printf(@"sht.text = %@ , Height = %f",sht.text,size.height);
        DLog(@"sht.text = %@ , Height = %f",sht.text,size.height);
        
        
        //on 16Aug
        if(!txtvw)
        txtvw= [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 38)];
        [txtvw setFont:[UIFont fontWithName:@"Aileron-Regular" size:14]];
        txtvw.text = sht.text;
        CGSize countentSize = txtvw.contentSize;
        int numberOfLinesNeeded = countentSize.height / txtvw.font.lineHeight;
        //int numberOfLinesInTextView = _txtViewNotes.frame.size.height / _txtViewNotes.font.lineHeight;
        CGRect textViewFrame= txtvw.frame;
        textViewFrame.size.height = numberOfLinesNeeded * txtvw.font.lineHeight;
        num = numberOfLinesNeeded;
        th = textViewFrame.size.height;
        
        
        //int num  = [sht.text length]/25;
        
        //    if (th <=30)
        //        th = 50;
        
        if (sht.type.integerValue == ShoutTypeTextMsg) {
            
            
            if (num>0)
            {
                CGFloat hh;
                hh = th+((num+1) *25)+42;
                hh = th+((num+1) *font.lineHeight)+42;
                // return MAX(hh, 85.0);
                
                if IS_IPAD_PRO_1024 {
                    //                return 120 + (size.height -38);//138
                    return 130 + (th -38); // by nim chat#18
                }
                
                if IS_IPHONE_6P{
                    if (th == 16.800000000000001 ){
                        return 120 + (th+10 -38); // by nim chat#18
                    }
                }
                //            return 130 + (size.height -38);//138
                return 130 + (th -38);//138 // 110
            }
            else
            {
                return 120;
                //            return (th+80);
                //            return MAX(hh, 75.0);
            }
        } else if (sht.type.integerValue == ShoutTypeImage || sht.type.integerValue == ShoutTypeGif) {
            
            if([sht.text isEqualToString:@"" ])
            {
                //  CGFloat hh = th+120+25;
                return 200;//150; // by nim chat#11 return 150;
            }
            else
            {
                if (num>0)
                {
                    //                CGFloat hh;
                    //                hh = th+((num +1) *25)+120+60;
                    //                return MAX(hh, 170.0);
                    
                    
                    // by nim chat#18
                    if IS_IPAD_PRO_1024 {
                        return 263 + (th -30);//253-
                    }
                    return 263 + (th -30);//253-
                }
                else
                {
                    CGFloat hh = th+50+120+25;
                    return MAX(hh, 150.0);
                }
            }
            
        } else if (sht.type.integerValue == ShoutTypeAudio) {
            
            if([sht.text isEqualToString:@"" ])
            {
                //  CGFloat hh = th+120+25;
                return 100;
            }
            else
            {
                if (num>0) {
                    //                CGFloat hh = th+(num *25)+120;
                    //                return MAX(hh, 135.0);
                    
                    if IS_IPAD_PRO_1024 {
                        return 188 + (th -30);
                    }
                    return 188 + (th -30);//cellsize+8
                }else
                {
                    CGFloat hh = th+50+45+25;
                    return MAX(hh, 100.0);
                }
            }
        }
        else if (sht.type.integerValue == ShoutTypeVideo)
        {
            if([sht.text isEqualToString:@"" ])
            {
                //  CGFloat hh = th+120+25;
                return 200;//130;  // by nim chat#12
            }
            else
            {
                if (num>0)
                {
                    
                    // by nim chat#18
                    if IS_IPAD_PRO_1024 {
                        return 253 + (th -30);//253-
                    }
                    return 253 + (th -30);//253-
                    
                }else
                {
                    CGFloat hh = th+50+120;//+25;
                    return MAX(hh, 120.0);
                }
            }
        }
        return  250;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isChieldView)
    {
        return;
    }
    Shout *sht = [_savedShouts objectAtIndex:indexPath.row];
    LHSavedCommsViewController *vc = (LHSavedCommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHSavedCommsViewController"];
    NSArray *childShout = [DBManager getAllFavouriteChieldShouts:sht];
    if (childShout.count>0)
    {
        vc.savedShouts = [NSMutableArray arrayWithArray:childShout];
        [vc.savedShouts insertObject:sht atIndex:0];
        vc.isChieldView = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    childShout = nil;
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
    if (tag == CellButtonTag_Audio)
    {
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
        [[LHAudioRecorder shared] playAudioUrl:[NSURL URLWithString:path]];
    }
    else if (tag == CellButtonTag_Fav)
    {
        shoutIndex = [_savedShouts indexOfObject:sht];
        if ([sht.favorite integerValue]>=1)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Are you sure you want to delete?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alertView.tag = k_FavToUnFavSaved;
            [alertView show];
        }
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
        shoutIndex = [_savedShouts indexOfObject:sht];
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:k_exportVideoAlert delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alrt.tag = 1001011;
        [alrt show];
        alrt = nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == k_FavToUnFavSaved && buttonIndex==1&&shoutIndex<[_savedShouts count])
    {
        Shout *sht = [_savedShouts objectAtIndex:shoutIndex];
        [AppManager favouriteCall:sht withFavFlag:NO];
        if (self.isChieldView)
        {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [_savedShouts removeObjectAtIndex:shoutIndex];
        NSIndexPath *indp = [NSIndexPath indexPathForRow:shoutIndex inSection:0];
        [_favTable beginUpdates];
        [_favTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indp] withRowAnimation:UITableViewRowAnimationFade];
        [_favTable endUpdates];
    }
    else if (alertView.tag == 1001011 && buttonIndex==1&&shoutIndex<[_savedShouts count])
    {
        Shout *sht = [_savedShouts objectAtIndex:shoutIndex];
        [[Global shared] saveVideo:sht];
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


- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType
{
    if([self.navigationController.topViewController isKindOfClass:[LHSavedCommsViewController class]])//crash fix , please dont remove this code
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
    if (isClick)
    {
         NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content,@"content",length,@"length",contentId,@"contentId",cool,@"cool",share,@"share",contact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",@"NO",@"needToMove",[NSNumber numberWithInteger:createdTime],@"created",[NSNumber numberWithBool:feedType],@"feed_Type",nil];
        cvc = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
        cvc.myChannel = ch;
        cvc.dataDictionary =  dict;
        [self.navigationController pushViewController:cvc animated:YES];
        
        
        NSLog(@"Top View controller %@",self.navigationController.topViewController);
        
       
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"KX" object:ch];
        
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"KX" object:ch userInfo:dict];
        
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

- (UINavigationController *) getnavController:(UIViewController *) viewController {
    
    UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:viewController];
    return navController;
    //[UIApplication sharedApplication].delegate.window.rootViewController=navController;
}

#pragma mark - PUSH notification handling

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

        [[NSNotificationCenter defaultCenter] postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
        return;
    }
    cvc = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil];
}

-(void)moveToChannelScreen:(NSString *)channelID
{
    
}
@end
