//
//  SavedViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 05/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "SavedViewController.h"
#import "LHBackupSessionViewController.h"
#import "LHSavedCommsViewController.h"
#import "BackUpManager.h"
#import "FavoriteDownloadManager.h"
#import "LoaderView.h"
#import "BannerAlert.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "ShoutManager.h"
@interface SavedViewController ()
{
    __weak IBOutlet UIImageView *_baseImageView;
}
@property(nonatomic, weak) IBOutlet UIButton *btnSave;
@property(nonatomic, weak) IBOutlet UIButton *btnBkup;
@end

@implementation SavedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:k_GotuserSettings object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSettings) name:k_GotuserSettings object:nil];
    [self addTabbarWithTag: BarItemTag_Saved];
    [self setTabOneLineColor:BarItemTag_Saved];
    [self.view sendSubviewToBack:_baseImageView];
    [self addPanGesture]; // by nim

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showCountOfNotifications];
    [self enableOrDisableButtons];
    [self checkCountOfShouts];
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
}

#pragma mark other Methods

-(void)gotSettings
{
    [self enableOrDisableButtons];
}

-(void)enableOrDisableButtons
{
    [self.btnBkup setEnabled:[PrefManager shouldOpenSaved]];
}

-(void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBAction

- (IBAction)backupSessionClicked:(id)sender
{
    if ([PrefManager shouldOpenSaved] == FALSE)
    {
        return;
    }
    //get all back ups
    [LoaderView addLoaderToView:self.view];
    [BackUpManager ShoutsBackupFromServerOnView:self.view completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *arrBackUp = [DBManager getAllBackUps];
            LHBackupSessionViewController *vc = (LHBackupSessionViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHBackupSessionViewController"];
            vc.arrBackUp = arrBackUp;
            [self.navigationController pushViewController:vc animated:YES];
            [LoaderView removeLoader];
        });
    }];
}

- (IBAction)savedComsClicked:(id)sender
{
    [LoaderView addLoaderToView:self.view];
    [FavoriteDownloadManager downloadFavFromServerOnView:self.view completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LHSavedCommsViewController *vc = (LHSavedCommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LHSavedCommsViewController"];
            NSArray *arrSouts = [DBManager getAllFavouriteShouts];
            vc.savedShouts = [NSMutableArray arrayWithArray:arrSouts];
            [self.navigationController pushViewController:vc animated:YES];
            [LoaderView removeLoader];
        });
    }];
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
