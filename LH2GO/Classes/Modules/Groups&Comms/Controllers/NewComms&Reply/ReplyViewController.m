//
//  ReplyViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 19/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "ReplyViewController.h"
#import "NSString+Extra.h"
#import "ShoutInfo.h"
#import "BLEManager.h"
#import "ShoutManager.h"
#import "MediaCommsViewController.h"
#import "BannerAlert.h"
#import "ImagePickManager.h"
#import "LoaderView.h"
#import "SharedUtils.h"

@interface ReplyViewController ()<UIActionSheetDelegate,APICallProtocolDelegate>{
    NSString *groupID;
    SharedUtils *sharedUtils;
    ShoutInfo *shoutSave;
    UIBarButtonItem  *lefttButton;
    UIBarButtonItem  *rightButton;
}

@end

@implementation ReplyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 /*   [_shInputFld.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_shInputFld.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    _shInputFld.layer.cornerRadius = 20;
    _shInputFld.clipsToBounds = YES; */ // by nim chat#2
    _shInputFld.textContainerInset = UIEdgeInsetsMake(5, 5, 10, 0);  //(top,left, bottom, right) // by nim chat#3
    _shInputFld.autocorrectionType = UITextAutocorrectionTypeNo;
    if(IS_IPHONE_4_OR_LESS)
    {
        DLog(@"IS_IPHONE_4_OR_LESS");
    }
    if(IS_IPHONE_5)
    {
        CGRect favframe = _shInputFld.frame;
        favframe.origin.x = favframe.origin.x - 10;
        favframe.size.width = favframe.size.width + 15 ;
        _bottomInpView.frame = CGRectMake(_bottomInpView.frame.origin.x, self.view.frame.size.height-118, _bottomInpView.frame.size.width, _bottomInpView.frame.size.height);
        _shInputFld.frame =  favframe;
    }
    if(IS_IPHONE_6P || IS_IPHONE_6)
    {
        CGRect favframe = _shInputFld.frame;
        favframe.size.width = favframe.size.width ;
        _shInputFld.frame =  favframe;
    }
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RelayView" owner:self options:nil];
    self.relayView = [objects objectAtIndex:0];
    self.relayView.stringValue = @"MEGHA";
    self.relayView.relayDelegate = self;
    [self.relayView setFrame:CGRectMake(0, _table.frame.origin.y, self.view.frame.size.width, _table.frame.size.height)];
    [self.view addSubview:_relayView];
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
   // [self shouldShowUserList:NO animated:NO];   // show user list NO
    //[self addAdvanceSettingsView]; // by nim chat#2
    
    
    self.title = @"Reply" ; // by nim chat#2
    [self addTopBarButtons];
    
}
- (void)addTopBarButtons
{
    
    lefttButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = lefttButton;
    
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction

- (IBAction)hitShoutclicked:(id)sender
{
    NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
    if (!txt.length)
    {
        return;
    }
    ShoutInfo *sh = [ShoutInfo composeText:txt type:ShoutTypeTextMsg content:nil groupId:self.myGroup.grId parentShId:_pShout.shId p2pChat:self.myGroup.isP2PContact];
    _shInputFld.text = @"";
    _leftLbl.numberOfLines = 0;
    _leftLbl.text = [NSString stringWithFormat:@" %i Left", k_MAX_SHOUT_LENGTH]; //by nim chat#4
    [[BLEManager sharedManager] addSh:sh toQueueAt:YES];
    // enter in the list.
    [[ShoutManager sharedManager] enqueueShout:sh forUpdation:NO];
}

- (IBAction)hitToCloud:(id)sender
{
    //hide text field
    [self.view endEditing:YES];
    NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
    if (!txt.length)
    {
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Please write something!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alrt show]; alrt = nil;
        return;
    }
    DLog(@"The Group id is %@",self.myGroup.grId);
    NSMutableArray *group_ids = [[NSMutableArray alloc]init];
    NSNumber *groupNumber;
    groupNumber = [NSNumber numberWithInt:[self.myGroup.grId intValue]];
    groupID = [NSString stringWithFormat:@"%@",groupNumber];
    [group_ids addObject: groupNumber];
    NSMutableDictionary * postDictionary = [[NSMutableDictionary alloc]init];
    [postDictionary setObject:group_ids forKey:@"group_id"];
    //Make api call
    if ([AppManager isInternetShouldAlert:YES])
    {
        //show loader...
        [LoaderView addLoaderToView:self.view];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:GET_LIST_OF_RELAYS_URL];
    }
}

- (IBAction)camclicked:(id)sender
{
#if TARGET_IPHONE_SIMULATOR
#else
    if ([[BLEManager sharedManager] on] == FALSE)
    {
        [AppManager showAlertWithTitle:@"Alert" Body:@"Please turn on Bluetooth in Settings, When the BT/BLE radio is off, shout will not be sent"];
        return;
    }
#endif
    if ([self checkIFNetworkIsActive])
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) { [_shInputFld resignFirstResponder];}
        if (k_EnableVideoRecording == 1)
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Capture Video", @"Click image from camera", @"Pick image from library", nil];
            [sheet showInView:self.view];
        }
        else
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Click image from camera", @"Pick image from library", nil];
            [sheet showInView:self.view];
        }
    }
}

- (IBAction)soundClicked:(id)sender
{
#if TARGET_IPHONE_SIMULATOR
#else
    if ([[BLEManager sharedManager] on] == FALSE)
    {
        [AppManager showAlertWithTitle:@"Alert" Body:@"Please turn on Bluetooth in Settings, When the BT/BLE radio is off, shout will not be sent"];
        return;
    }
#endif
    if ([self checkIFNetworkIsActive])
    {
        MediaCommsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaCommsViewController"];
        vc.mediaType = MediaTypeSound;
        vc.myGroup = self.myGroup;
        vc.parentSh = self.pShout;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Index->%li", (long)buttonIndex);
     if ((k_EnableVideoRecording == 1 && buttonIndex == 3)|| (k_EnableVideoRecording == 0 && buttonIndex == 2)) return; // cancel
    MediaType mType = MediaTypeImageCamera; //Default is  camera
    if (k_EnableVideoRecording == 1)
    {
        mType = (buttonIndex == 0) ? MediaTypeVideo : ((buttonIndex == 1) ? MediaTypeImageCamera : MediaTypeImageLibrary); // video : camera : library
    }
    else
    {
        mType = (buttonIndex == 0) ? MediaTypeImageCamera : MediaTypeImageLibrary; // camera : library
    }
    int type;
    if (mType == MediaTypeVideo || mType == MediaTypeImageCamera)
    {
        type = 1;
    }
    else
    {
        type = 2;
    }
    if (![ImagePickManager checkUserPermission:type])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        if (type==1)
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to your camera. To enable access, tap Settings and turn on Camera." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            alrt.tag = 1001001;
            [alrt show];
            alrt = nil;
        }
        else if(type==2)
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to Photos. To enable access, tap Settings and turn on Photos." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            alrt.tag = 1001001;
            [alrt show];
            alrt = nil;
        }
        });
        return;
    }
    MediaCommsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaCommsViewController"];
    vc.mediaType = mType;
    vc.myGroup = self.myGroup;
    vc.parentSh = self.pShout;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Public methods

-(void) addAdvanceSettingsView
{
    CGSize sz = self.view.bounds.size;
    CGFloat tHieght = 61.3; //47;
    //CGFloat y = sz.height - tHieght;
    // CGRect frame = CGRectMake(0, sz.height-tHieght, sz.width, tHieght);
    
    CGRect frame = CGRectMake(0, sz.height-tHieght-62, sz.width, 61.3);//y
    _advanceSettingBottomView = [AdvanceSettingBottomView tabbarWithFrame:frame];
    [self.view addSubview:_advanceSettingBottomView];
    
    // _tabbar.selectedItemTag = barTag;
    [_advanceSettingBottomView addTarget:self andSelector:@selector(advanceSettingsClicked:)];
}

- (IBAction)advanceSettingsClicked:(id)sender
{
  /*  AdvanceSettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AdvanceSettingsViewController"];
    //    vc.grp = _myGroup;
    //    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:NO];*/
}

- (void)sortShouts
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"original_timestamp" ascending:YES]];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[_pShout.chield_shouts.allObjects sortedArrayUsingDescriptors:sortDescriptors]];
    if (arr.count==0)
        [arr addObject:_pShout];
    else
        [arr insertObject:_pShout atIndex:0];
    _shouts = arr;
}

-(void)recievedReplyShout:(Shout *)sh
{
    UIViewController *vc1 = [self.navigationController topViewController];
    BOOL isOnTop = [vc1 isKindOfClass:[self class]];
    if(isOnTop)
    {
        self.pShout.timestamp = sh.timestamp;
        [self sortShouts];
        // shout entered..
        [self insertReplyRowAtIndex:_pShout.chield_shouts.count];
    }
    else
    {
        _shouldReloadShout = YES;
        // show banner.
        UIView *vv = [[AppManager appDelegate] window];
        [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
        //_noShoutView.hidden = [[ShoutManager sharedManager] shouts].count;
    }
}

- (void)insertReplyRowAtIndex:(NSInteger)indx
{
    NSInteger count = _pShout.chield_shouts.count;
    if(count == 0) return;
    isReloadingTable=NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_table beginUpdates];
        NSIndexPath *indp = [NSIndexPath indexPathForRow:indx inSection:0];
        NSIndexPath *pindp = [NSIndexPath indexPathForRow:0 inSection:0];
        @try
        {
            [_table insertRowsAtIndexPaths:[NSArray arrayWithObject:indp] withRowAnimation:UITableViewRowAnimationFade];
            [[_table cellForRowAtIndexPath:indp] reloadInputViews];
            [_table reloadRowsAtIndexPaths:[NSArray arrayWithObject:pindp] withRowAnimation:UITableViewRowAnimationFade];
            [[_table cellForRowAtIndexPath:indp] reloadInputViews];
            [_table endUpdates];
            [_table scrollToRowAtIndexPath:indp atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        @catch (NSException *exception) { }
        @finally {}

    });
    }

-(void)shouldShowUserList:(BOOL)show animated:(BOOL)animate
{
    _relayView.listOfRelays.tableFooterView= [[UIView alloc]initWithFrame:CGRectZero];
    CGRect fr = _relayView.frame;
    fr.origin.y = (show)?_table.frame.origin.y : self.view.frame.size.height;
    DLog(@"comms self.view height --- %f",self.view.frame.size.height);
    if (show) [_relayView reload];
    if (!animate)
    {
        _relayView.frame = fr; return;
    }
    [UIView animateWithDuration:.4 animations:^{
        _relayView.frame = fr;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark- Shared Utils Delegate Method

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    DLog(@"responseDict is --- %@",responseDict);
    BOOL status = [[responseDict objectForKey:@"status"] boolValue];
    NSString *msgStr= [responseDict objectForKey:@"message"];
    if (status)
    {
        if ([responseDict objectForKey:@"method"])
        {
            [AppManager showAlertWithTitle:@"Sent Successfully!!" Body:nil];
            //remove loader from view
            [LoaderView removeLoader];
            _shInputFld.text = @"";
            // enter in the list.
            [[ShoutManager sharedManager] enqueueShout:shoutSave forUpdation:NO];
        }
        else
        {
            //parse response
            NSMutableDictionary *dictOfRelays = [responseDict objectForKey:@"data"];
            NSMutableArray * arrayOfRelays = [dictOfRelays objectForKey:groupID];
            [LoaderView removeLoader];
            self.relayView.relaysList = [[NSMutableArray alloc] init];
            [arrayOfRelays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                RelayObject *relayObj = [[RelayObject alloc] initRelayObjectWithDic:obj];
                [self.relayView.relaysList addObject:relayObj];
            }];
            DLog(@"The arrays is %@",self.relayView.relaysList);
            //remove loader from view
            [LoaderView removeLoader];
            [self.relayView.listOfRelays reloadData];
            if (self.relayView.relaysList.count > 0)
            {
                //open relay view
                [self shouldShowUserList:YES animated:YES];
            }
        }
    }
    else
    {
        //remove loader
        [LoaderView removeLoader];
        //show alert if relays are not connected
        [AppManager showAlertWithTitle:msgStr Body:nil];
    }
}

#pragma mark- Relay View Delegate methods

- (void)didCancelView
{
    [self shouldShowUserList:NO animated:YES];
}

-(void)relaySelectedWithMacId : (NSMutableArray *)macIds
{
    //show loader
    [LoaderView addLoaderToView:self.view];
    DLog(@"The array of mac ids is %@",macIds);
    //Make api call to send data
    NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
   ShoutInfo *sh = [ShoutInfo composeText:txt type:ShoutTypeTextMsg content:nil groupId:self.myGroup.grId parentShId:_pShout.shId p2pChat:self.myGroup.isP2PContact];
    shoutSave = sh;
    NSData *data = [ShoutManager dataFromObjectForShout:sh];
    const unsigned char *bytes = [data bytes];
    NSUInteger length = [data length];
    NSMutableArray *byteArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < length; i++)
    {
        [byteArray addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
    }
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"advertisement",@"method",@"relays",@"type",macIds,@"ble_mac_ids", byteArray,@"message",[NSNumber numberWithInt:(int)length], @"length",nil];
    if ([AppManager isInternetShouldAlert:YES])
    {
        [sharedUtils makePostCloudAPICall:postDictionary andURL:SEND_DATA_TO_CLOUD_URL];
    }
    //hide view
    [self shouldShowUserList:NO animated:YES];
}


@end
