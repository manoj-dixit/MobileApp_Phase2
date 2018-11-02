//
//  ChanelViewController.m
//  LH2GO
//
//  Created by User on 13/10/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "ChanelViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "ChanelTableViewCell.h"
#import "BLEManager.h"
#import "LoaderView.h"
#import "Channels.h"
#import "Constant.h"
#import "SharedUtils.h"
#import "NSData+Base64.h"
#import "ChannelDetail.h"
#import "FLAnimatedImage.h"
#import "TimeConverter.h"
#import "EventLog.h"
#import "ImageOverlyViewController.h"
#import "BannerAlert.h"
#import "ShoutManager.h"
#import "UIImage+MultiFormat.h"
#import "SDWebImageDecoder.h"
#import "UIImage+animatedGIF.h"
#import "UIImage+GIF.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "SettingsViewController.h"
#import "LHSavedCommsViewController.h"
#import "SavedViewController.h"
#import "LHBackupSessionInfoVC.h"
#import "LHBackupSessionDetailVC.h"
#import "LHBackupSessionViewController.h"
#import "MessagesViewController.h"
#import "NotificationViewController.h"
#import "SonarViewController.h"
#import "CoreDataManager.h"
#import "NotificationInfo.h"
#import "CryptLib.h"
#import "ChannelDataClassInfo.h"
#import "DebugLogsInfo.h"
#import "FilterView.h"
#import "MoreView.h"
#import "FeedView.h"

#define kInitialHeightConstant 40

@interface ChanelViewController ()<APICallProtocolDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,ChanelTableCellDelegate,ChannelDetailCellDelegate,MoreViewDelegate,CustomViewDelegate>
{
    NSMutableArray *arrayValue;
    NSMutableArray *_dataSource;
    NSInteger _selectedSec;
    NSInteger selectedChannelIndex;
    NSInteger channelIndex;
    NSInteger selectedContentIndex;
    NSInteger channelsCount;
    NSArray *channels;
    NSInteger currentChannelId;
    UIImage *img;
    SharedUtils *sharedUtils;
    UIImage *image;
    NSMutableArray *array;
    NSMutableArray *channelContent;
    NSDictionary *channelDict;
    NSInteger globalVal;
    NSInteger tagChannelLog;
    BOOL toShowBadge;
    NSInteger reportedContentId;
    NSTimer *setTimer;
    NSString *plistPath;
    NSFileManager *fileManager;
    NSString *plistPath1;
    NSFileManager *fileManager1;
    NSInteger pullCount;
    UIView *refreshView;
    UIRefreshControl *refreshControl;
    NSMutableArray *expiredContent;
    NSMutableArray *countOfPull;
    NSTimeInterval time;
    NSInteger selectedTextTag;
    NSMutableArray *tempArr;
    NSString *phNumber;
    NSMutableArray *loadedCellsArray;
    NSInteger numberOfSections,numberofPagesForChannelContent;
    NSMutableDictionary *postDictionaryforBackwardCompatibiltyAPI ;
    NSString *currentAppVersion;
    // BOOL isSoftKeysAPICalled; //Reveretd for cool contact count issue
    BOOL isTitleClicked;
    BOOL isMoreClicked;
    CustomTitleView *customTitleView;
    MoreView * moreView;
    UIButton *moreButton;
    NSMutableArray *userSelectedCityArray;
    UILabel * titleLabel;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centreX;


@end

@implementation ChanelViewController
@synthesize myChannel = _myChannel;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    self.navigationController.navigationBar.hidden = NO;
    self.expandedCells = [[NSMutableArray alloc] init];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

   // [self.view setBackgroundColor:[UIColor colorWithRed:(39.0f/255.0f) green:(38.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0]];
    [self.view setBackgroundColor:[Common colorwithHexString:@"242426" alpha:1]];
    userSelectedCityArray = [[NSMutableArray alloc] init];
    
    _tableChannel.allowsMultipleSelectionDuringEditing = YES;
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    reportedContentId = 0;
    plistPath = @"";
    selectedTextTag = 0;
    self.navigationItem.rightBarButtonItem = nil;
    [self addTabbarWithTag: BarItemTag_Channel];
    toShowBadge = NO;
    // [self addPanGesture];
    [self checkVarification]; // for pincode
    channels = nil;
    channelContent = nil;
    expiredContent = nil;
    countOfPull = nil;
    //urlMatches = nil;
    tempArr = nil;
    channels = nil;
    channels = [[NSArray alloc]init];
    channelContent = nil;
    channelContent = [[NSMutableArray alloc]init];
    expiredContent = nil;
    expiredContent = [[NSMutableArray alloc]init];
    isTitleClicked = NO;
    
    _detailsOfAllChannelData  = [[NSMutableArray alloc] init];
    
    _detailsOfAllChannelScheduledData  = [[NSMutableArray alloc]init];
    
    countOfPull = nil;
    countOfPull = [[NSMutableArray alloc]init];
    tempArr = [[NSMutableArray alloc]initWithObjects:@"1", nil];
    time = [[NSDate date] timeIntervalSince1970]-KCellFadeOutDuration;
    [NSTimer scheduledTimerWithTimeInterval:5.0f
                                     target:self selector:@selector(showActionableCount:) userInfo:nil repeats:NO];
    
    [self addLongPressGesture];
    [self addPulltoRefreshView];
    [self fetchChannels];
    //Get the documents directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    plistPath = [documentsDirectory stringByAppendingPathComponent:@"ChannelContent.plist"];
    plistPath1 = [documentsDirectory stringByAppendingPathComponent:@"PullCount.plist"];
    
    fileManager = [NSFileManager defaultManager];
    fileManager1 = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: plistPath]) {
        plistPath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"ChannelContent.plist"] ];
    }
    if (![fileManager1 fileExistsAtPath: plistPath1]) {
        plistPath1 = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"PullCount.plist"] ];
    }
    
    // Start topology upload if debug mode is enabled
    if(App_delegate.cloudDebugStatus)
        [AppManager startLogfileTimer];
    
    loadedCellsArray = [[NSMutableArray alloc] init];
    
    //CREATE FEED
    
    //*** Hide/Show accordingly***
   // _btnCreateFeed.hidden = true;
    
    CGFloat h_w_ofMoreButton ;
    if (IPAD){
        h_w_ofMoreButton =66.f;
    }else{
        h_w_ofMoreButton = 56.f;
    }
    
    _btnIconHeight.constant = h_w_ofMoreButton;
    _btnIconWidth.constant =  h_w_ofMoreButton;
    CGFloat height = 0;
    if(IS_IPHONE_X){
         height = self.view.bounds.size.height-90;
    }
    else{
       height =  self.view.bounds.size.height-61.3;
    }
    
    _filterButton.layer.cornerRadius = _filterButton.frame.size.width/2;
    [_filterButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [_filterButton.layer setShadowOpacity:0.6];
    [_filterButton.layer setShadowRadius:4.0];
    [_filterButton.layer setShadowOffset:CGSizeMake(0, 3.0)];
    [_filterButton.layer setMasksToBounds:NO];
    
    _latestFeedsButton.layer.cornerRadius = _filterButton.frame.size.width/2;
    [_latestFeedsButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [_latestFeedsButton.layer setShadowOpacity:0.6];
    [_latestFeedsButton.layer setShadowRadius:4.0];
    [_latestFeedsButton.layer setShadowOffset:CGSizeMake(0, 3.0)];
    [_latestFeedsButton.layer setMasksToBounds:NO];


    NSMutableArray *postDataArray = App_delegate.softKeyActionArray;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"softKeyAPICalled"] && [postDataArray count]>0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"softKeyAPICalled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self multipleSoftKeysAPIPostToCloud];
    }
    
    
    // if Application is started
    if(App_delegate.toKnowtheFreshStartOfApp)
    {
        // call to backword compatibilty API
        [self toCallBackwordCompatibilityAPI];
    }
    
    // add notification observers
    [self addNotificationObservers];
    
    // enable BLE classes
    [self enableBLE];
    
    [Global shared].isReadyToStartBLE = YES;
    if ([AppManager isInternetShouldAlert:NO]) {
        if(App_delegate.toKnowtheFreshStartOfApp)
        {
            // send channel update request
            App_delegate.toKnowtheFreshStartOfApp = NO;
           // [AppManager sendRequestToGetChannelList];
        }
    }
    DLog(@"%s",__PRETTY_FUNCTION__);
    [self addNavigationBarViewComponents];
    self.tableChannel.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0);

}

-(void)pinchGestureAction:(UIPinchGestureRecognizer*)gesture{
    NSLog(@"pinch getsure added");
}

- (void)addNavigationBarViewComponents {
    // create title label
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    containerView.backgroundColor = [UIColor clearColor];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 225, 35)];
    if ([PrefManager defaultUserSelectedCity]) {
        titleLabel.text=[PrefManager defaultUserSelectedCity];
    }
    else{
        titleLabel.text=@"";
    }
    titleLabel.numberOfLines = 1;
    titleLabel.textColor= [UIColor whiteColor];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [containerView addSubview:titleLabel];
    
    UILabel * titleArrow = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 220, 10)];
    titleArrow.text=@"U";
    titleArrow.numberOfLines = 1;
    titleArrow.textColor= [UIColor whiteColor];
    titleArrow.alpha = 0.6;
    titleArrow.font = [UIFont fontWithName:@"loudhailer" size:14];
    titleArrow.textAlignment=NSTextAlignmentCenter;
    [containerView addSubview:titleArrow];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForTitleChange:)];
    tapGesture.numberOfTapsRequired = 1;
    [containerView addGestureRecognizer:tapGesture];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = containerView;
    
   UIButton *bukiboxFeedButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [bukiboxFeedButton setTitle:@"&" forState:UIControlStateNormal];
    [bukiboxFeedButton.titleLabel setFont:[UIFont fontWithName:@"loudhailer" size:25]];
    [bukiboxFeedButton addTarget:self action:@selector(discoverButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    bukiboxFeedButton.hidden = YES;
    [bukiboxFeedButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    
    moreButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setTitle:@"$" forState:UIControlStateNormal];
    [moreButton.titleLabel setFont:[UIFont fontWithName:@"loudhailer" size:20]];
    [moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton setFrame:CGRectMake(44, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    [rightBarButtonItems addSubview:bukiboxFeedButton];
    [rightBarButtonItems addSubview:moreButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
}

-(void)tapForTitleChange:(UITapGestureRecognizer*)gesture{
    if(isMoreClicked == YES) {
        [self removeMoreViewWithAnimation];
    }
    CGFloat height=0.0;
    if(IS_IPHONE_X){
        height = self.view.bounds.size.height-90;
    }
    else{
        height =  self.view.bounds.size.height-61.3;
    }
    
    if (!isTitleClicked) {
        isTitleClicked=YES;
        customTitleView = [[CustomTitleView alloc] initWithFrame:CGRectMake(0, -height, self.view.frame.size.width, height)];
        [customTitleView showHideNextButton:YES];
        customTitleView.hidden = YES;
        customTitleView.delegate = self;
        [self.view addSubview:customTitleView];
        [customTitleView setCollectionDataArray:[userSelectedCityArray mutableCopy]];
        [customTitleView initializeData];

        [UIView animateWithDuration:0.5 animations:^{
            customTitleView.hidden = NO;
            customTitleView.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        } completion:^(BOOL finished) {
        }];
   }
    else{
        isTitleClicked=NO;
        [UIView animateWithDuration:0.5 animations:^{
            customTitleView.frame = CGRectMake(0, -height, self.view.frame.size.width, height);
        } completion:^(BOOL finished) {
            [customTitleView removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CustomViewClose" object:nil];
        }];
    }
}

-(void)toCallBackwordCompatibilityAPI
{
    postDictionaryforBackwardCompatibiltyAPI = nil;
    postDictionaryforBackwardCompatibiltyAPI = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",[NSString stringWithFormat:@"%d",currentApplicationId],@"application_id",[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]],kApp_Version,nil];
    if ([AppManager isInternetShouldAlert:NO])
    {
        //show loader...
        // [LoaderView addLoaderToView:self.view];
        [sharedUtils makePostCloudAPICall:postDictionaryforBackwardCompatibiltyAPI andURL:BACKWARDCOMPATIBILTY];
    }
}


-(void)addPulltoRefreshView
{
    //pull@refresh
    refreshView = nil;
    refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
    [self.tableChannel insertSubview:refreshView atIndex:0]; //the tableView is a IBOutlet
    
    refreshControl = nil;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@"Updating content"];
    [refreshString addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, refreshString.length)];
    refreshControl.attributedTitle = refreshString;
    [refreshView addSubview:refreshControl];
}

-(void)addLongPressGesture
{
    //attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionChannel addGestureRecognizer:lpgr];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableChannel reloadData];
    });
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkCountOfShouts];
    [self showCountOfNotifications];
    [self startUpdateExpiryTimer];
    DLog(@"%s",__PRETTY_FUNCTION__);
    DLog(@"Top View controller %@",self.navigationController.topViewController);
    if(_dataDictionary){
        [self scrollIndex:_myChannel dict:_dataDictionary];
        _dataDictionary =  nil;
    }
}

-(void)addNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelDataFromBLE:) name:@"AA" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XYZ" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChannelDataViaPush:) name:@"XYZ" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeletePacketNotifocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteContentOverBLE:) name:kDeletePacketNotifocation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"channelRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"channelRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChannelSoftKeyUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:@"ChannelSoftKeyUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"channelUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelUpdate:) name:@"channelUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"channelUpdateRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelUpdateRequest:) name:@"channelUpdateRequest" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"channelRemoved" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:@"channelRemoved" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationReceivedForNotfTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTabBadge) name:@"NotificationReceivedForNotfTab" object:nil];
    // new shout notification..
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutEncounteredHere:) name:kNewShoutEncounter object:nil];
    //user has logged out
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USERLOGGEDOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTimers:) name:USERLOGGEDOUT object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIPasteboardChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyToClip) name:UIPasteboardChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelAllOperations" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAllOperationsQueue) name:@"cancelAllOperations" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"KX" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollNotif:) name:@"KX" object:nil];
    
    
    //  }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getUserCityList];
    if(_myChannel.channelId == nil)
    {
        _myChannel.channelId = @"1";
        [self getPrivateContentAPI];

    }

    if(_myChannel.contentCount.integerValue>0){
        [_myChannel clearCount:_myChannel];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // reloading the data
        [_tableChannel reloadData];
        
    });
    
    if (_myChannel.channelId) {
        
        @try {
            channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
        } @catch (NSException *exception) {
        } @finally {}
        
        selectedChannelIndex = [channels indexOfObject:_myChannel];
        [self scrollCollectionToIndex];
        [self setMyChannel:_myChannel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionChannel reloadData];
            [_tableChannel reloadData];
        });
        //}
        for(Channels *ch in channels)
        {
            if([ch.channelId intValue] ==[_myChannel.channelId intValue]){
                selectedChannelIndex = [channels indexOfObject:ch];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self scrollCollectionToIndex];
                    [self setMyChannel:ch];
                    
                    [_collectionChannel reloadData];
                    [_tableChannel reloadData];
                });
                break;
            }
        }
        [self getPrivateContentAPI];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionChannel reloadData];
        [_tableChannel reloadData];
    });
    
    Global *shared = [Global shared];
    NSInteger unreadShoutsCount =[DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
    NSInteger unreadContents = [DBManager getUnreadChannelContentCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount + unreadContents)];
    
    [self accessChannels : _myChannel.channelId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showCountOnNotificationsTab];
    });
    

    [super viewWillAppear:YES];
    
    //    [[UIApplication sharedApplication] sendAction:@selector(xyz) to:self from:self forEvent:nil];
    
    // isSoftKeysAPICalled=NO; //Reveretd for cool contact count issue
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSuspendNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    
    DLog(@"%s",__PRETTY_FUNCTION__);
    
    DLog(@"Top View controller %@",self.navigationController.topViewController);
    
}

-(void)handleTabBadge{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showCountOnNotificationsTab];
    });
}

-(void)accessChannels : (NSString *)channelID
{
    
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:channelID,@"channelId",@"accessed_channels",@"text",nil];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_access_channels",@"log_sub_category",@"",@"category_id",detaildict,@"details",nil];
    
    //        EventLog *log = [totalChannelAccessLogs objectAtIndex:a];
    //         postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:log.timeStamp,@"timestamp",log.logCat,@"log_category",log.logSubCat,@"log_sub_category",@"",@"category_id",detaildict,@"details",nil];
    
    
    [AppManager saveEventLogInArray:postDictionary];
    
    //    [EventLog addEventWithDict:postDictionary];
    //
    //    NSNumber *count = [Global shared].currentUser.eventCount;
    //    int value = [count intValue];
    //    count = [NSNumber numberWithInt:value + 1];
    //    [[Global shared].currentUser setEventCount:count];
    //
    //    [DBManager save];
    //
    //
    //    if (delegate && [delegate respondsToSelector:@selector(hitEventLog:)] && ([count intValue]%10 == 0)){
    //        [delegate hitEventLog:[Global shared].currentUser.user_id];
    //    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [self captureEventLogs];
    [self stopUpdateExpiryTimer];
    [self unregisterNotificationObservers];
    // Remove all cells from loaded cell array.
    [loadedCellsArray removeAllObjects];
    // [self cancelAllOperationsQueue];
    [super viewWillDisappear:animated];
}

-(void)unregisterNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIPasteboardChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}


#pragma mark- Show Count on Notification Tab
-(void)showActionableCount:(NSTimer*)timer{
    
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:k_actionableNotify];
    [self showActionCount:[str integerValue]];
    
}

#pragma mark - Stop Timers
-(void)stopTimers:(NSNotification *)notification
{
    [setTimer invalidate];
    setTimer = nil;
}

#pragma mark- Refresh Table

- (void)refreshData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"Nav Top %@ >> %@",self.navigationController.topViewController,_tableChannel);
        //NSLog(@"forcefully refresh data was called here");
        [_tableChannel reloadData];
    });
}

- (void)refreshList {
    [self fetchChannels];
}


#pragma mark - private methods

-(BOOL) isLoadMoreBtnVisible:(UITextView *)textView
{
    CGSize contentSize = textView.contentSize;
    int numberOfLinesNeeded = contentSize.height / textView.font.lineHeight;
    
    if (IPAD)
    {
        //165 for two line
        if ((numberOfLinesNeeded > 1  || contentSize.height >=43) && textView.text.length >165)
            return false;
    }
    else {
        if ((numberOfLinesNeeded > 1  || contentSize.height >=43) && textView.text.length >107)
            return false;
    }
    return true;
}

- (void)enableBLE
{
    if ([Global shared].isReadyToStartBLE && [BLEManager sharedManager].isRefreshBLE) {
        [LoaderView addLoaderToView:[UIApplication sharedApplication].keyWindow];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startBLE];
        });
    }
}

- (void)startBLE{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        NSString *activeNetId = [PrefManager activeNetId];
        if (activeNetId.length>0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BLEManager sharedManager] reInitialize];
            });
        }
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [LoaderView removeLoader];
        });
    });
}

- (void) receiveSuspendNotification:(NSNotification*)notif
{
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:k_PhoneNumber];
    if([phNumber isEqualToString:str]){
        int timeStamp = (int)[TimeConverter timeStamp];
        
        NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"on_click_phone_call",@"text",nil];
        
        NSMutableDictionary *postDictionary1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_click_phone_call",@"log_sub_category",@"on_click_phone_call",@"text",_myChannel.channelId,@"channelId",_myChannel.channelId,@"category_id",detaildict,@"details",nil];
        
        [AppManager saveEventLogInArray:postDictionary1];
        
        //        [EventLog addEventWithDict:postDictionary1];
        //
        //        NSNumber *count = [Global shared].currentUser.eventCount;
        //        int value = [count intValue];
        //        count = [NSNumber numberWithInt:value + 1];
        //        [[Global shared].currentUser setEventCount:count];
        //
        //       [DBManager save];
        //
        //        if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0))
        //        {
        //            //show loader...
        //            // [LoaderView addLoaderToView:self.view];
        //            [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
        //        }
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:k_PhoneNumber];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

-(void)readMore:(UIButton*)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableChannel];
    NSIndexPath *indexPath = [self.tableChannel indexPathForRowAtPoint:buttonPosition];

    if ([self.expandedCells containsObject:indexPath])
    {
        [sender setTitle:@"READ MORE" forState:UIControlStateNormal];
        [self.expandedCells removeObject:indexPath];
    }
    else
    {
        [sender setTitle:@"READ LESS" forState:UIControlStateNormal];
        [self.expandedCells addObject:indexPath];
    }
    [self.tableChannel beginUpdates];
    [self.tableChannel endUpdates];
    
   /* NSArray *totalChannelContent3 = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", _myChannel.channelId] descr:[NSSortDescriptor sortDescriptorWithKey:@"created_time" ascending:NO] isDistinctResults:YES];
    
    ChannelDetail *c = [totalChannelContent3 objectAtIndex:sender.tag];
    
    selectedContentIndex = c.contentId.integerValue;
    
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",_myChannel.channelId,@"channelId",@"click image",@"text",nil];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_click_image",@"log_sub_category",_myChannel.channelId,@"channelId",[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",_myChannel.channelId,@"category_id",@"click image",@"text",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary];
    
//        [EventLog addEventWithDict:postDictionary];
//
//        NSNumber *count = [Global shared].currentUser.eventCount;
//        int value = [count intValue];
//        count = [NSNumber numberWithInt:value + 1];
//        [[Global shared].currentUser setEventCount:count];
//
//        [DBManager save];
//
//    
//        if (delegate && [delegate respondsToSelector:@selector(hitEventLog:)] && ([count intValue]%10 == 0)){
//            [delegate hitEventLog:[Global shared].currentUser.user_id];
//        }
    
    ChanelDetailVC *vc = (ChanelDetailVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelDetailVC"];
    NSNumber *time1 = [NSNumber numberWithDouble:([c.created_time doubleValue] - 3600)];
    NSTimeInterval interval = [time1 doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString=[dateformatter stringFromDate:date];
    vc.dateStr = dateString;
    vc.mediaPath = c.mediaPath;
    vc.textToBeDisplayed = c.text;
    if(([c.duration intValue] == k_ForeverFeed_AppDisplayTime || [c.duration intValue] == k_OLD_ForeverFeed_AppDisplayTime) && c.isForeverFeed){
        c.timeStr = @"";
        c.toBeDisplayed = YES;
        vc.timeDisplay = c.timeStr;
        
    }
    else{
        vc.timeDisplay = c.timeStr;
        
    }
    vc.currentChannel = _myChannel;
    vc.mediaType = c.mediaType;
    vc.cID = c.contentId;
    vc.mediaType = c.mediaType;
    vc.currentContentDetail = c;
    vc.isCool = c.cool;
    vc.isContact = c.contact;
    vc.isShare = c.share;
    vc.coolNumber = c.coolCount;
    vc.contactNumber = c.contactCount;
    vc.shareNumber = c.shareCount;
    [self.navigationController pushViewController:vc animated:YES];*/
}

#pragma mark- Channel methods
-(void)fetchChannels
{
    [Global shared].isReadyToStartBLE = YES;
    NSArray *channel = nil;
    channel = [[NSArray alloc]init];
    NSMutableArray *nets = [NSMutableArray new];
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    if(net == nil){
        NSArray *networks = [DBManager getNetworks];
        for(Network *net in networks){
            if([net.netId isEqualToString:@"1"]){
                channel  = [DBManager getChannelsForNetwork:net];
                if(channel.count > 0)
                {
                    NSDictionary *d = @{ @"network" : net,
                                         @"channels"  : channel
                                         };
                    [nets addObject:d];
                    // }
                    _dataarray = nets;
                }
                
                if(_dataarray.count == 0){
                    // [AppManager showAlertWithTitle:@"Alert" Body:@"No channels have been added for you"];
                }
                
                else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_collectionChannel reloadData];
                        [_tableChannel reloadData];
                    });
                    
                    [self setPvtChannel];
                    
                }
            }
        }
    }
    else{
        channel  = [DBManager getChannelsForNetwork:net];
        if(channel.count > 0)
        {
            NSDictionary *d = @{ @"network" : net,
                                 @"channels"  : channel
                                 };
            [nets addObject:d];
            // }
            _dataarray = nets;
            NSDictionary *dict = [_dataarray objectAtIndex:0];
            channels = [dict objectForKey:@"channels"];
            channelsCount = channels.count; // nim
            
            @try {
                channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
            } @catch (NSException *exception) {
            } @finally {}
            
            __block BOOL isPresent =NO;
            [channels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                ChannelDetail *cd = obj;
                if ([cd.channelId isEqualToString:_myChannel.channelId]) {
                    
                    isPresent = YES;
                }
            }];
            
            if (!isPresent) {
                _myChannel = [channels objectAtIndex:0];
                selectedChannelIndex = 0;
            }
        }
        
        if(_dataarray.count == 0){
           // [AppManager showAlertWithTitle:@"Alert" Body:@"No channels have been added for you"];
        }
        
        else{
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collectionChannel reloadData];
                [_tableChannel reloadData];
            });
            
            [self setPvtChannel];
            
        }
    }
}


- (void)setMyChannel:(Channels *)myChannel{
    if (_myChannel !=myChannel) {
        _myChannel = myChannel;
        
        //        DLog(@"selected index is %lu",selectedChannelIndex);
        //
        //        DLog(@"Set my channel is %@",myChannel);
        currentChannelId = _myChannel.channelId.integerValue;
        [[Global shared] setCurrentChannel:_myChannel];
        [PrefManager storeChannelId:_myChannel.channelId];
        
    }
    if(_needToMove){
    }
    
}

- (Channels*)myChannel{
    
    DLog(@"Set my channel is ++ %@",_myChannel);
    
    if (_myChannel.channelId ==nil) {
        Channels *ch = [Channels channelWithId:[NSString stringWithFormat:@"%ld", (long)currentChannelId] shouldInsert:NO];
        _myChannel = ch;
        return ch;
    }
    return _myChannel;
}

-(void)setPvtChannel{
    
    NSDictionary *d = [_dataarray objectAtIndex:0];
    NSArray *channel = [d objectForKey:@"channels"];
    if(channel.count > 0)
    {
        Channels *channel1 = [channel objectAtIndex:0];
        if([channel1.network.netId isEqualToString:@"1"]){
            if (!_myChannel.channelId) {
                [self setMyChannel:channel1];
            }
            
            NSArray *allVc ;//= [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
            
            if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
            {
                if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
                {
                    
                    if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                        
                        if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                            
                            
                            allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                            if (allVc.count>0) {
                                
                            }else
                                return;
                        }
                        else
                        {
                            DLog(@"Not a navigation controller");
                            
                            return;
                        }
                    }else
                    {
                        DLog(@"If content view controller not exist");
                        
                        return;
                    }
                }else{
                    
                    DLog(@"Root view controller is not REFrosted view controller");
                    return;
                }
            }
            
            
            UIViewController *vc = allVc[0];
            if ([vc isKindOfClass:[SettingsViewController class]]|| [vc isKindOfClass:[SavedViewController class]] || [vc isKindOfClass:[LHSavedCommsViewController class]] || [vc isKindOfClass:[LHBackupSessionInfoVC class]] || [vc isKindOfClass:[LHBackupSessionDetailVC class]] || [vc isKindOfClass:[LHBackupSessionViewController class]]) {
                
            }
            else{
                [self getPrivateContentAPI];
            }
        }
    }
}

-(void)setTimeOfEachContent:(NSTimer*)timer
{
    int hours, minutes, seconds,secondsLeft,days;
    BOOL isContentValid;
    NSArray *totalChannelContent;//= [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"toBeDisplayed = YES"] descr:nil  isDistinctResults:YES];
    
    totalChannelContent = [_detailsOfChannel copy];
    
    if(totalChannelContent.count == 0)return;
    for(int i = 0;i<[totalChannelContent count];i++){
        ChannelDetail *contentDetails = [totalChannelContent objectAtIndex:i];
        
        // In case of DB migration, new key "received_timeStamp" will be nil. Initializing it with current time for further calculations
        if(!contentDetails.received_timeStamp) {
            contentDetails.received_timeStamp = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
            [DBManager save];
        }
        
        if(!contentDetails || !contentDetails.duration)
        {
            return;
        }
        
        if(([contentDetails.duration intValue] == k_ForeverFeed_AppDisplayTime || [contentDetails.duration intValue] == k_OLD_ForeverFeed_AppDisplayTime) && contentDetails.isForeverFeed)
        {
            @try {
                if(![contentDetails.timeStr isEqualToString:@""] )
                {
                    contentDetails.timeStr = @"";
                    
                }
                if(!contentDetails.toBeDisplayed)
                {
                    contentDetails.toBeDisplayed = YES;
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
        else{
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"Z"];  // 09:30 AM
            [formatter setTimeZone:[NSTimeZone systemTimeZone]]; // system time zone
            NSString *timeZoneValue = [formatter stringFromDate:[NSDate date]];  // Current time
            
            isContentValid =  [[NSDate date] timeIntervalSince1970] - [contentDetails.created_time longLongValue]  <=  [contentDetails.duration intValue];
            
            if ( [[NSDate date] timeIntervalSince1970] - [contentDetails.created_time longLongValue] < 0) {
                isContentValid = NO;
            }
            if(isContentValid) {
                secondsLeft = [contentDetails.duration intValue] - ([[NSDate date] timeIntervalSince1970] - [contentDetails.created_time longLongValue]);
                
                days = secondsLeft/(60*60*24);
                if(days > 0)
                    secondsLeft = secondsLeft - (days * 60*60*24);
                hours = secondsLeft / (60*60);
                if(hours > 0)
                    secondsLeft = secondsLeft - (hours * 60*60);
                minutes = secondsLeft / 60;
                if(minutes > 0)
                    secondsLeft = secondsLeft - (minutes * 60);
                seconds = secondsLeft;
                NSString *str =[NSString stringWithFormat:@"%02d:%02d:%02d:%02d",days,hours, minutes, seconds];//Time Remaining
                
                contentDetails.timeStr = str;
                contentDetails.toBeDisplayed = YES;
                
                // Change timeout value label for each loaded cell
                for(ChanelTableViewCell *cell in loadedCellsArray) {
                    @try {
                        
                        cell.lblText.text = cell.currentContentDetail.timeStr;
                        
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
                }
            }
            else {
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                     NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSError *error;
                NSArray *directoryContent;
                directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory  error:&error];
                
                DLog(@"Count of Array before Deletion %lu",(unsigned long)directoryContent.count);
                
                //contentDetails.toBeDisplayed = NO;
                NSArray  *arr = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"contentId = \"%@\"",contentDetails.contentId] descr:nil isDistinctResults:YES];
                
                for (ChannelDetail *contentDetails1 in arr) {
                    
                    NSLog(@"Media Path is %@",[contentDetails1.mediaPath lastPathComponent]);
                    NSString *contentPathValue = [contentDetails1.mediaPath lastPathComponent];
                    if([directoryContent containsObject:contentPathValue])
                    {
                        @try {
                            // Delete log file for previous date
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",contentPathValue]];
                            NSError *error;
                            BOOL isSucees = [fileManager removeItemAtPath:filePath error:&error];
                            if (isSucees){
                                DLog(@"Sucessfully deleted data file");
                                //*stop = YES;
                            }else{
                                DLog(@"Failed to delete data file due to error %@",error.localizedDescription);
                            }
                        } @catch (NSException *exception) {
                            
                        } @finally {
                            
                        }
                    }
                    [DBManager deleteOb:contentDetails1];
                }
                
                NSArray *directoryContent1;
                directoryContent1 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory  error:&error];
                [self createContentIdPlist:contentDetails];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableChannel reloadData];
                });
            }
        }
        NSArray *allVc;
        
        if([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]]){
            
        }
        else{
            if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
            {
                if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
                {
                    
                    if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                        
                        if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                            
                            
                            allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                            if (allVc.count>0) {
                                
                            }else
                                return;
                        }
                        else
                        {
                            DLog(@"Not a navigation controller");
                            
                            return;
                        }
                    }else
                    {
                        DLog(@"If content view controller not exist");
                        
                        return;
                    }
                }else{
                    
                    DLog(@"Root view controller is not REFrosted view controller");
                    return;
                }
            }
            else if ([UIApplication sharedApplication].keyWindow.rootViewController != nil)
            {
                if([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[REFrostedViewController class]])
                {
                    
                    if ([((REFrostedViewController*)[UIApplication sharedApplication].keyWindow.rootViewController) contentViewController])
                    {
                        
                        if([[((REFrostedViewController*)[UIApplication sharedApplication].keyWindow.rootViewController) contentViewController] isKindOfClass:[UINavigationController class]])
                        {
                            
                            allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].keyWindow.rootViewController) contentViewController] viewControllers];
                            if (allVc.count>0) {
                                
                            }else
                            {
                                return;
                            }
                        }
                        else
                        {
                            DLog(@"Not a navigation controller");
                            
                            return;
                        }
                    }else
                    {
                        DLog(@"If content view controller not exist");
                        
                        return;
                    }
                }
                else
                {
                    DLog(@"Root view controller is not REFrosted view controller");
                    return;
                }
            }
            if(allVc != nil || allVc.count != 0)
            {
                UIViewController *vc = allVc[0];
                if ([vc isKindOfClass:[SettingsViewController class]]|| [vc isKindOfClass:[SavedViewController class]] || [vc isKindOfClass:[LHSavedCommsViewController class]] || [vc isKindOfClass:[LHBackupSessionInfoVC class]] || [vc isKindOfClass:[LHBackupSessionDetailVC class]] || [vc isKindOfClass:[LHBackupSessionViewController class]]) {
                    
                }
                else{
                    // [self refreshData];
                    
                }
                
                
            }
            
            else{
                //    [_tableChannel reloadData];
            }
        }
    }
}




-(void)refreshTable:(NSTimer*)timer{
    [_tableChannel reloadData];
    
}

- (void)startUpdateExpiryTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [setTimer invalidate];
        setTimer = nil;
        setTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(setTimeOfEachContent:)
                                                   userInfo:nil
                                                    repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer: setTimer forMode:NSRunLoopCommonModes];
    });
}

- (void)stopUpdateExpiryTimer {
    [setTimer invalidate];
    setTimer = nil;
}

#pragma mark- PullToRefresh
-(void)pullToRefresh:(UIRefreshControl*)refreshControl
{
    DLog(@"Nav Top %@",self.navigationController.topViewController);
    
    [self refreshData];
    
    // for pull to refresh
    [self getPrivateContentAPI];
}

#pragma mark- ToLoadMoreContents
- (void)refreshToGetMoreCounts{
    
    //    NSString *pullC;
    //    NSString *channelId;
    //    BOOL check = NO;
    //    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    
    // cancel all pending requests
    [App_delegate.downloadQueue cancelAllOperations];
    
    int pullCountValue = 0;
    NSMutableArray *totalChannelContent = [[NSMutableArray alloc] init];
    
    NSArray *totalChannelContent1 = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND isForChannel = YES AND feed_Type = NO", [Global shared].currentChannel.channelId] descr:nil isDistinctResults:YES];
    
    totalChannelContent  =[totalChannelContent1 mutableCopy];
    
    BOOL isNeedToCheckScheduledFeed = NO;
    if (totalChannelContent.count==0 || !totalChannelContent) {
        // count value is not existed or it is zero
        isNeedToCheckScheduledFeed = YES;
    }
    else if(totalChannelContent.count/25>=2)
    {
        // if count value is greater than 0
        pullCountValue = totalChannelContent.count/25 +1;
        isNeedToCheckScheduledFeed = NO;
    }else
    {
        isNeedToCheckScheduledFeed = YES;
    }
    if(isNeedToCheckScheduledFeed)
    {
        NSArray *totalChanneScheduledContentData = [DBManager entitiesForScheduled:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND feed_Type = %@", [Global shared].currentChannel.channelId,@"1"] descr:nil isDistinctResults:YES];
        if(totalChanneScheduledContentData.count/25>=2)
        {
            pullCountValue = totalChanneScheduledContentData.count/25 +1;
        }
    }
    
    DLog(@"Pull to count value is  as total content count is  %d %lu",pullCountValue,(unsigned long)totalChannelContent.count);
    if (![self checkVarification]) {
        
        [refreshControl endRefreshing];
        
    }
    else{
        NSMutableDictionary *postDictionary ;
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.loud_hailerid,@"loudhailer_id",_myChannel.channelId,@"channel_id",[PrefManager activeNetId],@"network_id",[NSString stringWithFormat:@"%d",pullCountValue],@"page",nil];
        
        
        if ([AppManager isInternetShouldAlert:NO])
        {
            //show loader...
            // [LoaderView addLoaderToView:self.view];
            [sharedUtils makePostCloudAPICall:postDictionary andURL:GET_PRIVATE_CHANNEL_CONTENT];
        }
        else{
            [refreshControl endRefreshing];
        }
    }
}

-(void)refreshToGetMoreFeeds
{
    DLog(@"Downlaod More Feeds Here for All FeedView");
    NSMutableDictionary *postDictionary ;
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.loud_hailerid,@"loudhailer_id"
                      ,[PrefManager activeNetId],@"network_id",@"2",@"page",nil];
    [App_delegate.downloadQueue setSuspended:NO];
    if ([AppManager isInternetShouldAlert:NO])
    {
        //show loader...
        [self stopUpdateExpiryTimer];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:[NSString stringWithFormat:@"%@%@",BASE_API_URL,kFeed_ListAPI]];
    }
    else
    {
        [refreshControl endRefreshing];
    }
}

-(void)createContentIdPlist:(ChannelDetail *)content
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    
    if ([fileManager fileExistsAtPath: plistPath]) {
        
        expiredContent = [[NSMutableArray alloc] initWithContentsOfFile: plistPath];
    }
    else {
        // If the file doesn’t exist, create an empty dictionary
        expiredContent = [[NSMutableArray alloc] init];
    }
    
    //To insert the data into the plist
    if ([content.contentId isKindOfClass:(id)[NSNull null]] || content.contentId == nil || !content.contentId) {
        return;
    }
    @try {
        
        if(content.contentId)
        {
            [data setObject:content.contentId forKey:@"contentId"];
        }
        [expiredContent addObject:data];
        [expiredContent writeToFile:plistPath atomically:YES];
        
        [DBManager deleteOb:content];
        
        DLog(@"Feed deleted as it expired %@",content.contentId);
        
    } @catch (NSException *exception) {
    } @finally {
    }
}


#pragma mark - Unsubscribe Channel

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    int timeStamp = (int)[TimeConverter timeStamp];
    
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionChannel];
    NSIndexPath *indexPath = [self.collectionChannel indexPathForItemAtPoint:p];
    gestureRecognizer.view.tag= indexPath.row;
    
    @try {
        channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
    } @catch (NSException *exception) {
    } @finally {}
    
    Channels *ch = [channels objectAtIndex:gestureRecognizer.view.tag];
    if([ch.isSubscribed isEqualToNumber:[NSNumber numberWithBool:1]]){
        if (indexPath == nil){
            DLog(@"couldn't find index path");
        } else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:[NSString stringWithFormat: @"Do you want to unsubscribe this channel?"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                 
                                 {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action){
                                                            UICollectionViewCell* cell =
                                                            [self.collectionChannel cellForItemAtIndexPath:indexPath];
                                                            [self hitSubscriptionAPI:@"0" value:gestureRecognizer.view.tag];                                                                   cell.contentView.alpha = 0.4;
                                                            Channels *tempChanel = [channels objectAtIndex:gestureRecognizer.view.tag];
                                                            [tempChanel setIsSubscribed:[NSNumber numberWithInteger:0]];
                                                            [DBManager save];
                                                            
                                                            NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"channelContentId",ch.channelId,@"channelId",@"unsubscribe channel",@"text",nil];
                                                            
                                                            NSMutableDictionary *postDictionary1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_unsubscribe",@"log_sub_category",ch.channelId,@"channelId",@"subscribed",@"type",@"unsubscribe channel",@"text",ch.channelId,@"category_id",detaildict,@"details",nil];
                                                            
                                                            [AppManager saveEventLogInArray:postDictionary1];
                                                            
                                                        }];
            
            [alert addAction:no];
            [alert addAction:yes];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        
    }
    else{
        if (indexPath == nil){
            DLog(@"couldn't find index path");
        } else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:[NSString stringWithFormat: @"Do you want to subscribe this channel?"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                 
                                 {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action){
                                                            UICollectionViewCell* cell =
                                                            [self.collectionChannel cellForItemAtIndexPath:indexPath];
                                                            [self hitSubscriptionAPI:@"1" value:gestureRecognizer.view.tag];
                                                            
                                                            cell.contentView.alpha = 1.0;
                                                            Channels *tempChanel = [channels objectAtIndex:gestureRecognizer.view.tag];
                                                            [tempChanel setIsSubscribed:[NSNumber numberWithInteger:1]];
                                                            [DBManager save];
                                                            
                                                            NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"channelContentId",ch.channelId,@"channelId",@"subscribe channel",@"text",nil];
                                                            
                                                            NSMutableDictionary *postDictionary1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_subscribe",@"log_sub_category",ch.channelId,@"channelId",@"subscribed",@"type",@"subscribe channel",@"text",ch.channelId,@"category_id",detaildict,@"details",nil];
                                                            
                                                            [AppManager saveEventLogInArray:postDictionary1];
                                                            
                                                            //                                                            [EventLog addEventWithDict:postDictionary1];
                                                            //
                                                            //                                                            NSNumber *count = [Global shared].currentUser.eventCount;
                                                            //                                                            int value1 = [count intValue];
                                                            //                                                            count = [NSNumber numberWithInt:value1 + 1];
                                                            //                                                            [[Global shared].currentUser setEventCount:count];
                                                            //
                                                            //                                                          //  [DBManager save];
                                                            //
                                                            //
                                                            //                                                            if (delegate && [delegate respondsToSelector:@selector(hitEventLog:)] && ([count intValue]%10 == 0)){
                                                            //                                                                [delegate hitEventLog:[Global shared].currentUser.user_id];
                                                            //                                                            }
                                                            
                                                            
                                                            
                                                            
                                                        }];
            
            [alert addAction:no];
            [alert addAction:yes];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }
}


-(void)hitSubscriptionAPI:(NSString*)subsribeVal value:(NSInteger)value{
    NSMutableDictionary *postDictionary ;
    Channels *tempChanel = [channels objectAtIndex:value];
    
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",tempChanel.channelId,@"channel_id"
                      ,subsribeVal,@"subscribe",nil];
    
    
    
    if ([AppManager isInternetShouldAlert:YES])
    {
        //show loader...
        // [LoaderView addLoaderToView:self.view];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:SUBSCRIPTIONOFCHANNELS];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableChannel reloadData];
    });
    
}

-(Channels *)getCurrentChannel
{
    @try {
        NSString *activeNetId = [PrefManager activeNetId];
        Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
        
        NSArray  *channel  = [DBManager getChannelsForNetwork:net];
        NSMutableArray *nets = [NSMutableArray new];
        NSArray *channelsArray;
        
        if(channel.count > 0)
        {
            
            NSDictionary *d = @{ @"network" : net,
                                 @"channels"  : channel
                                 };
            [nets addObject:d];
            // }
            _dataarray = nets;
            NSDictionary *dict = [_dataarray objectAtIndex:0];
            channelsArray = [dict objectForKey:@"channels"];
            channelsCount = channelsArray.count; // nim
            @try {
                channels = [channelsArray sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
            } @catch (NSException *exception) {
            } @finally {}
        }
    } @catch (NSException *exception) {
    } @finally {}
    
    if(channels.count>0)
    {
        if(selectedChannelIndex>channels.count)
        {
            _myChannel = [channels objectAtIndex:0];
            selectedChannelIndex = 0;
        }else
            if (channels.count > selectedChannelIndex) {
                _myChannel = [channels objectAtIndex:selectedChannelIndex];
            }else
            {
                selectedChannelIndex = channels.count-1;
                _myChannel = [channels objectAtIndex:selectedChannelIndex];
            }
    }
    return _myChannel;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    //DLog(@"Channel is %@",[Global shared].currentChannel);
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    [Global shared].currentChannel = [self getCurrentChannel];
    if([[Global shared].currentChannel.isSubscribed isEqualToNumber:[NSNumber numberWithInteger:0]]){
        return 0;
    }
    else
    {
        if(_allChannelView.hidden == YES)
        {
            DLog(@"Feed cells Count %i",_detailsOfChannel.count);
            return _detailsOfChannel.count;
        }
        else
        {
            [_detailsOfChannel removeAllObjects];
            
            NSSortDescriptor *sortDescToSortDataArray1 = [[NSSortDescriptor alloc] initWithKey:@"contentId" ascending:NO];
            NSSortDescriptor *sortDescToSortDataArray2 = [[NSSortDescriptor alloc] initWithKey:@"created_time" ascending:NO];
            
            NSArray *descArray = @[[sortDescToSortDataArray2 copy],[sortDescToSortDataArray1 copy]];

        NSArray *totalChannelContent1 = [DBManager entitiesByArrayDesc:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", [Global shared].currentChannel.channelId] arrayOfDesc:descArray isDistinctResults:YES];
        
        _myChannel = [Global shared].currentChannel;
        
        if(_myChannel.contentCount>0)
        {
            if(_myChannel.contentCount.integerValue>0){
                [_myChannel clearCount:_myChannel];
                
                NSIndexPath *indp = [NSIndexPath indexPathForRow:selectedChannelIndex inSection:0];
                [_collectionChannel reloadItemsAtIndexPaths:[NSArray arrayWithObject:indp]];
            }
        }
        
        NSArray *totalChannelContentData = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND feed_Type = %@", [Global shared].currentChannel.channelId,@"0"] descr:nil isDistinctResults:YES];
        
        NSArray *totalChanneScheduledContentData;
        
        if(totalChannelContentData.count<25)
        {
            totalChanneScheduledContentData = [DBManager entitiesForScheduled:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND feed_Type = %@", [Global shared].currentChannel.channelId,@"1"] descr:nil isDistinctResults:YES];
            [_detailsOfAllChannelScheduledData removeAllObjects];
            _detailsOfAllChannelScheduledData =  [totalChanneScheduledContentData mutableCopy];
        }
        
        [_detailsOfAllChannelData removeAllObjects];
        _detailsOfAllChannelData = [totalChannelContentData mutableCopy];
        // if(totalChannelContent1.count>=25 && totalChannelContent1.count<=50){
        if(_detailsOfAllChannelData.count / 25 >= 1 || totalChanneScheduledContentData.count / 25 >= 1)
        {
            [_detailsOfChannel removeAllObjects];
            _detailsOfChannel = [totalChannelContent1 mutableCopy];
            return totalChannelContent1.count;
        }
        else{
            [_detailsOfChannel removeAllObjects];
            _detailsOfChannel = [totalChannelContent1 mutableCopy];
            return totalChannelContent1.count;
        }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

   if (indexPath.row == _detailsOfChannel.count){
        return 50*kRatio; //load more
    }
    else
    {
    if(_detailsOfChannel.count != 0)
    {
        ChannelDetail *c = [_detailsOfChannel objectAtIndex:indexPath.row];
       NSString *string = c.mediaPath;
        CGFloat initialHeight = 0;
        if ([c.mediaType isEqualToString:@"TXXX"]) {
            CGFloat h = [self getTextviewHeightForText:c.text];
            h = h - kInitialHeightConstant;
            return 183+h;
        }
        else if ([c.mediaType isEqualToString:@"TIXX"]){
            CGFloat h = [self getTextviewHeightForText:c.text];
            h = h - kInitialHeightConstant;
            return 428+h;
        }
        else if ([c.mediaType isEqualToString:@"TGXX"]){
            CGFloat h = [self getTextviewHeightForText:c.text];
            h = h - kInitialHeightConstant;
            return 428+h;
        }
        if(![string isEqualToString:@""] &&  string != nil){
            initialHeight =366*kRatio;
        }
        else{
            //initialHeight = 183;
        }
        CGFloat heightOnExpand = [self getTextviewHeightFromIndex:indexPath];

        if ([self.expandedCells containsObject:indexPath])
        {
            if ([c.mediaType isEqualToString:@"TIXX"]) {
                heightOnExpand = heightOnExpand+200;
            }
            else if([c.mediaType isEqualToString:@"TGXX"]){
                heightOnExpand = heightOnExpand+500;
            }
            else{
                //heightOnExpand = heightOnExpand+50;
            }
            return initialHeight+heightOnExpand;}
        else
        {
            return initialHeight;}
        
    }
           else
           {return 0;}
        }
}

-(CGFloat)getTextviewHeightFromIndex:(NSIndexPath *)indexPath
{
    if (indexPath.row == _detailsOfChannel.count){
        return 0;}
    else{
        ChannelDetail *c = [_detailsOfChannel objectAtIndex:indexPath.row];
        NSString *textToDisplay = c.text;
        NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:textToDisplay attributes:@{ NSFontAttributeName: [UIFont fontWithName:@"Aileron-Regular" size:15*kRatio]}];
        CGSize constraintSize = CGSizeMake(self.tableChannel.frame.size.width - 30, MAXFLOAT);
        CGRect rect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        return rect.size.height;}
}

// Set the spacing between sections
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0){
        return 4;}
    return 0;}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    // [self stopUpdateExpiryTimer];
    numberOfSections = [tableView numberOfRowsInSection:0]-1;
    DLog(@"Row count %li %li %li",numberOfSections,(long)indexPath.row,(long)indexPath.row);
    if(indexPath.row == numberOfSections && numberOfSections > 25)
        return NO;
    else
        return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:@"Are you sure you want to delete this content?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action)
                              {
                                  
                                  NSMutableArray *totalChannelContent9 = [NSMutableArray new];
                                  
                                  totalChannelContent9 = [_detailsOfChannel copy];
                                  
                                  ChannelDetail *c = [totalChannelContent9 objectAtIndex:indexPath.row];
                                  c.toBeDisplayed = NO;
                                  [DBManager save];
                                  
                                  [self refreshData];
                                  //                                  [_tableChannel reloadData];
                              }];
        
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                             }];
        
        [alert addAction:no];
        [alert addAction:yes];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_allChannelView.hidden == YES)
    {

        if(_detailsOfChannel.count != 0)
        {
        ChannelDetail *c = [_detailsOfChannel objectAtIndex:indexPath.row];
        NSString *string = c.mediaType;

        DLog(@"Time stamp at index is %ld ++ %@",(long)indexPath.row,c.created_time);

        if ([string containsString:@"G"])
        {
            NSLog(@"for GIF");
            static NSString *cellIdentifier = @"ChannelDetailCell";
            ChannelDetailCell *cell;
            cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Animated",cellIdentifier]];
            if (cell == nil) {
                cell = [ChannelDetailCell cellAtIndex:2];
            }
            NSLog(@"channel feed data%@",c);
            cell.delegate = self;
            cell.channelDescriptionTextView.delegate = self;
            cell.dateTextLabel.text = [self convertToDateString:c.created_time];
            CGFloat h = [self getTextviewHeightForText:c.text];
            cell.textViewHeightContraint.constant = h;
            cell.channelDescriptionTextView.text = c.text;
            cell.channelDescriptionTextView.textColor = [UIColor blackColor];
            FLAnimatedImage *animatedImage = [self animatedImageForChannelFeed:c];
            if (animatedImage) {
                cell.channelFeedAnimatedImageView.animatedImage = animatedImage;
            }
            else{
                UIImage *cellImage = [[SDImageCache sharedImageCache] diskImageForKey:c.mediaPath];
                cell.channelFeedAnimatedImageView.image  = cellImage;
            }

            [self coolForChannelDetail:c forTableViewCell:cell];
            [self contactForChannelDetail:c forTableViewCell:cell];
            cell.channelDetail = c;
            NSMutableAttributedString *attributedTxt = [Common getAttributedString:c.text withFontSize:cell.channelDescriptionTextView.font.pointSize];
            [cell.channelDescriptionTextView setAttributedText: attributedTxt];
            cell.channelDescriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
            return cell;
        }
        else if([string containsString:@"I"])
        {
            NSLog(@"for image");
            static NSString *cellIdentifier = @"ChannelDetailCell";
            ChannelDetailCell *cell;
            cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Image",cellIdentifier]];
            if (cell == nil) {
                cell = [ChannelDetailCell cellAtIndex:0];
            }
            NSLog(@"channel feed data%@",c);

            cell.delegate=self;
            cell.channelDescriptionTextView.delegate = self;
            cell.dateTextLabel.text = [self convertToDateString:c.created_time];
            CGFloat h = [self getTextviewHeightForText:c.text];
            cell.textViewHeightContraint.constant = h;
            cell.channelDescriptionTextView.textColor = [UIColor blackColor];
            cell.channelDescriptionTextView.text = c.text;
            cell.channelFeedImageView.image = [self imageForChannelFeed:c];
            cell.reportButton.accessibilityIdentifier = [NSString stringWithFormat:@"%ld",indexPath.row];
            [self coolForChannelDetail:c forTableViewCell:cell];
            [self contactForChannelDetail:c forTableViewCell:cell];
            cell.channelDetail = c;
            NSMutableAttributedString *attributedTxt = [Common getAttributedString:c.text withFontSize:cell.channelDescriptionTextView.font.pointSize];
            [cell.channelDescriptionTextView setAttributedText: attributedTxt];
            cell.channelDescriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;

            return cell;
        }
        else
        {
            NSLog(@"with text");
            static NSString *cellIdentifier = @"ChannelDetailCell";
            ChannelDetailCell *cell;
            cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Text",cellIdentifier]];

            if (cell == nil) {
                cell = [ChannelDetailCell cellAtIndex:1];
            }
            NSLog(@"channel feed data%@",c);
            cell.delegate=self;
            cell.channelDescriptionTextView.delegate = self;
            cell.dateTextLabel.text = [self convertToDateString:c.created_time];
            CGFloat h = [self getTextviewHeightForText:c.text];
            cell.textViewHeightContraint.constant = h;
            cell.channelDescriptionTextView.text = c.text;
            cell.reportButton.accessibilityIdentifier = [NSString stringWithFormat:@"%ld",indexPath.row];
            [self coolForChannelDetail:c forTableViewCell:cell];
            [self contactForChannelDetail:c forTableViewCell:cell];
            cell.channelDetail = c;
            //formatting: urls & phonenumber in bold
            NSMutableAttributedString *attributedTxt = [Common getAttributedString:c.text withFontSize:cell.channelDescriptionTextView.font.pointSize];
            [cell.channelDescriptionTextView setAttributedText: attributedTxt];
            cell.channelDescriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
            return cell;

        }
        }
        else
        {
            static NSString *cellIdentifier = @"ChanelTableViewCell";

            ChanelTableViewCell *cell = (ChanelTableViewCell *)  [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.delegate=self;

            return cell;
        }
    }
    else
    {
    NSMutableArray *totalChannelContent2 = [[NSMutableArray alloc] init];
    totalChannelContent2  =[_detailsOfChannel mutableCopy];
    
    NSMutableArray *totalChannelContent1  = [[NSMutableArray alloc] init];
    totalChannelContent1 = [_detailsOfAllChannelData copy];
    
    NSMutableArray *totalChannelContentForSch  = [[NSMutableArray alloc] init];
    totalChannelContentForSch = [_detailsOfAllChannelScheduledData copy];
    
    if(totalChannelContent2.count!= 0)
    {
        {
            ChannelDetail *c = [totalChannelContent2 objectAtIndex:indexPath.row];
            NSString *string = c.mediaType;
            
            DLog(@"Time stamp at index is %ld ++ %@",(long)indexPath.row,c.created_time);
            
            if ([string containsString:@"G"])
            {
                NSLog(@"for GIF");
                static NSString *cellIdentifier = @"ChannelDetailCell";
                ChannelDetailCell *cell;
                cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Animated",cellIdentifier]];
                if (cell == nil) {
                    cell = [ChannelDetailCell cellAtIndex:2];
                }
                NSLog(@"channel feed data%@",c);
                cell.delegate = self;
                cell.channelDescriptionTextView.delegate = self;
                cell.dateTextLabel.text = [self convertToDateString:c.created_time];
                CGFloat h = [self getTextviewHeightForText:c.text];
                cell.textViewHeightContraint.constant = h;
                cell.channelDescriptionTextView.text = c.text;
                cell.channelDescriptionTextView.textColor = [UIColor blackColor];
                FLAnimatedImage *animatedImage = [self animatedImageForChannelFeed:c];
                if (animatedImage) {
                    cell.channelFeedAnimatedImageView.animatedImage = animatedImage;
                }
                else{
                    UIImage *cellImage = [[SDImageCache sharedImageCache] diskImageForKey:c.mediaPath];
                    cell.channelFeedAnimatedImageView.image  = cellImage;
                }
                
                [self coolForChannelDetail:c forTableViewCell:cell];
                [self contactForChannelDetail:c forTableViewCell:cell];
                cell.channelDetail = c;
                NSMutableAttributedString *attributedTxt = [Common getAttributedString:c.text withFontSize:cell.channelDescriptionTextView.font.pointSize];
                [cell.channelDescriptionTextView setAttributedText: attributedTxt];
                cell.channelDescriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
                return cell;
            }
            else if([string containsString:@"I"])
            {
                NSLog(@"for image");
                static NSString *cellIdentifier = @"ChannelDetailCell";
                ChannelDetailCell *cell;
                cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Image",cellIdentifier]];
                if (cell == nil) {
                    cell = [ChannelDetailCell cellAtIndex:0];
                }
                NSLog(@"channel feed data%@",c);

                cell.delegate=self;
                cell.channelDescriptionTextView.delegate = self;
                cell.dateTextLabel.text = [self convertToDateString:c.created_time];
                CGFloat h = [self getTextviewHeightForText:c.text];
                cell.textViewHeightContraint.constant = h;
                cell.channelDescriptionTextView.textColor = [UIColor blackColor];
                cell.channelDescriptionTextView.text = c.text;
                cell.channelFeedImageView.image = [self imageForChannelFeed:c];
                cell.reportButton.accessibilityIdentifier = [NSString stringWithFormat:@"%ld",indexPath.row];
                [self coolForChannelDetail:c forTableViewCell:cell];
                [self contactForChannelDetail:c forTableViewCell:cell];
                cell.channelDetail = c;
                NSMutableAttributedString *attributedTxt = [Common getAttributedString:c.text withFontSize:cell.channelDescriptionTextView.font.pointSize];
                [cell.channelDescriptionTextView setAttributedText: attributedTxt];
                cell.channelDescriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;

                return cell;
            }
            else
            {
                NSLog(@"with text");
                static NSString *cellIdentifier = @"ChannelDetailCell";
                ChannelDetailCell *cell;
                cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Text",cellIdentifier]];
                
                if (cell == nil) {
                    cell = [ChannelDetailCell cellAtIndex:1];
                }
                NSLog(@"channel feed data%@",c);
                cell.delegate=self;
                cell.channelDescriptionTextView.delegate = self;
                cell.dateTextLabel.text = [self convertToDateString:c.created_time];
                CGFloat h = [self getTextviewHeightForText:c.text];
                cell.textViewHeightContraint.constant = h;
                cell.channelDescriptionTextView.text = c.text;
                cell.reportButton.accessibilityIdentifier = [NSString stringWithFormat:@"%ld",indexPath.row];
                [self coolForChannelDetail:c forTableViewCell:cell];
                [self contactForChannelDetail:c forTableViewCell:cell];
                cell.channelDetail = c;
                //formatting: urls & phonenumber in bold
                NSMutableAttributedString *attributedTxt = [Common getAttributedString:c.text withFontSize:cell.channelDescriptionTextView.font.pointSize];
                [cell.channelDescriptionTextView setAttributedText: attributedTxt];
                cell.channelDescriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
                return cell;
               
            }
            
        }
    }
    else{
        static NSString *cellIdentifier = @"ChanelTableViewCell";
        
        ChanelTableViewCell *cell = (ChanelTableViewCell *)  [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.delegate=self;
      
        return cell;
    }
    }
}

-(void)multipleSoftKeysAPIPostToCloud
{
    SharedUtils *sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate=self;
    NSMutableArray *postDataArray = App_delegate.softKeyActionArray;
    if([AppManager isInternetShouldAlert:NO] && ([postDataArray count]>0))
    {
        for(NSMutableDictionary *softkeyDict in postDataArray)
        {
            [sharedUtils makePostCloudAPICall:softkeyDict andURL:CHANNELCONTENTTYPE];
        }
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"softKeyAPICalled"];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{


   /* [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *totalChannelContent3 = [[NSMutableArray alloc] init];
    totalChannelContent3 = [_detailsOfChannel copy];
    
    NSMutableArray *totalChannelContent1  = [[NSMutableArray alloc] init];
    totalChannelContent1 = [_detailsOfAllChannelData copy];
    
    NSMutableArray *totalChannelContentForSch  = [[NSMutableArray alloc] init];
    totalChannelContentForSch = [_detailsOfAllChannelScheduledData copy];
    
    if (indexPath.row == totalChannelContent3.count && ((totalChannelContent1.count >=25) || (totalChannelContentForSch.count>=25)))
    {
        //load more fucntionality
        
        
        [self refreshToGetMoreCounts];
        
    }else{
        
        // check to be sure that total channel content will be greater than or equal to the indexpath section
        if(totalChannelContent3.count>=indexPath.row)
        {
            ChannelDetail *c = [totalChannelContent3 objectAtIndex:indexPath.row];
            
            selectedContentIndex = c.contentId.integerValue;
            
            int timeStamp = (int)[TimeConverter timeStamp];
            NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",_myChannel.channelId,@"channelId",@"click image",@"text",nil];
            
            NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_click_image",@"log_sub_category",_myChannel.channelId,@"channelId",[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",_myChannel.channelId,@"category_id",@"click image",@"text",detaildict,@"details",nil];
            
            
            [AppManager saveEventLogInArray:postDictionary];
            
            //            [EventLog addEventWithDict:postDictionary];
            //
            //            NSNumber *count = [Global shared].currentUser.eventCount;
            //            int value = [count intValue];
            //            count = [NSNumber numberWithInt:value + 1];
            //            [[Global shared].currentUser setEventCount:count];
            //
            //       //     [DBManager save];
            //
            //
            //            if (delegate && [delegate respondsToSelector:@selector(hitEventLog:)] && ([count intValue]%10 == 0)){
            //                [delegate hitEventLog:[Global shared].currentUser.user_id];
            //            }
            
            //for new implementation
            ChanelDetailVC *vc = (ChanelDetailVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelDetailVC"];
            NSNumber *time1 = [NSNumber numberWithDouble:([c.created_time doubleValue] - 3600)];
            NSTimeInterval interval = [time1 doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
            NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
            [dateformatter setLocale:[NSLocale currentLocale]];
            [dateformatter setDateFormat:@"MM-dd-yyyy"];
            NSString *dateString=[dateformatter stringFromDate:date];
            vc.dateStr = dateString;
            vc.mediaPath = c.mediaPath;
            vc.textToBeDisplayed = c.text;
            if(([c.duration intValue] == k_ForeverFeed_AppDisplayTime || [c.duration intValue] == k_OLD_ForeverFeed_AppDisplayTime) && c.isForeverFeed){
                c.timeStr = @"";
                c.toBeDisplayed = YES;
                vc.timeDisplay = c.timeStr;
            }
            else
                vc.timeDisplay = c.timeStr;
            
            vc.currentChannel = _myChannel;
            vc.cID = c.contentId;
            vc.mediaType = c.mediaType;
            vc.currentContentDetail = c;
            vc.isCool = c.cool;
            vc.isContact = c.contact;
            vc.isShare = c.share;
            vc.coolNumber = c.coolCount;
            vc.contactNumber = c.contactCount;
            vc.shareNumber = c.shareCount;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }*/
}


-(void)chanelImageTappedOnCell:(NSInteger)selectedRow
{
    ChannelDetail *chanelDetail =[_detailsOfChannel objectAtIndex:selectedRow];
    if ([chanelDetail.mediaType containsString:@"I"] || [chanelDetail.mediaType containsString:@"G"])
    {
        ImageOverlyViewController *imageOverlayViewController   = (ImageOverlyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ImageOverlyViewController"];
        imageOverlayViewController.mediaType = chanelDetail.mediaType;
        imageOverlayViewController.mediaPath = chanelDetail.mediaPath;
        imageOverlayViewController.channelId = chanelDetail.channelId;
        imageOverlayViewController.contentId = [chanelDetail.contentId integerValue];
        [self.navigationController presentViewController:imageOverlayViewController animated:YES completion:nil];
    }
}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
//    if (endScrolling >= scrollView.contentSize.height)
//    {
//        [self performSelector:@selector(refreshToGetMoreCounts) withObject:nil afterDelay:1];
//    }
//}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    @try {
        NSString *activeNetId = [PrefManager activeNetId];
        Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
        
        NSArray  *channel  = [DBManager getChannelsForNetwork:net];
        NSMutableArray *nets = [NSMutableArray new];
        NSArray *channelsArray;
        
        if(channel.count > 0)
        {
            NSDictionary *d = @{ @"network" : net,
                                 @"channels"  : channel
                                 };
            [nets addObject:d];
            _dataarray = nets;
            NSDictionary *dict = [_dataarray objectAtIndex:0];
            channelsArray = [dict objectForKey:@"channels"];
            channelsCount = channelsArray.count; // nim
            @try {
                channels = [channelsArray sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
            } @catch (NSException *exception) {
            } @finally {}
            
            channel = [channelsArray copy];
        }
        if(channels.count <= 3)
        {
            _leftArrow.hidden = YES;
            _rightArrow.hidden = YES;
        }
        else
        {
            _leftArrow.hidden = NO;
            _rightArrow.hidden = NO;
        }
        return channels.count;
    }
    @catch (NSException *exception) {
    } @finally {}
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"GroupCollectionCell";
    GroupCollectionCell *cell = (GroupCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    DLog(@"Index path is %ld",(long)indexPath.row);
    cell.indicatorLine.hidden =  YES;
    
    @try {
        channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
    } @catch (NSException *exception) {
    } @finally {}
    
    if (indexPath.row == selectedChannelIndex){
        cell.indicatorLine.hidden =  NO;
    }
    
    if(channels.count > 0){
        Channels *channel = [channels objectAtIndex:indexPath.row];
        [cell showChannel:channel];
    }
    else{
        cell.UserName.text = [NSString stringWithFormat:@"Channel %ld",(long)indexPath.row + 1 ];
    }
    if(channels.count <= 3)
    {
        _leftArrow.hidden = YES;
        _rightArrow.hidden = YES;
    }
    else
    {
        _leftArrow.hidden = NO;
        _rightArrow.hidden = NO;
    }
    
    return cell;
}


#define kCellWidth 110
#define kCellHeight 90
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_X) {
        return CGSizeMake(kCellWidth, kCellHeight);
    }
    return CGSizeMake(kCellWidth, kCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [refreshControl endRefreshing];
    selectedChannelIndex = indexPath.row;
    Channels *ch = [channels objectAtIndex:indexPath.row];
    
    if(ch.contentCount.integerValue>0){
        [ch clearCount:ch];
    }
    
    if ([ch isEqual:_myChannel]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionChannel reloadData];
            [_tableChannel reloadData];
        });
        return;
    }
    [self setMyChannel:ch];
    [self setNeedToMove:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionChannel reloadData];
        [_tableChannel reloadData];
    });
    
    if([ch.channelId isKindOfClass:(id)[NSNull null]])
    {
        return;
    }
    
    if (ch.channelId)
    {
        [tempArr addObject:ch.channelId];
        [self getPrivateContentAPI];
    }
    
    int timeStamp = (int)[TimeConverter timeStamp];
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:ch.channelId,@"channelId",ch.name,@"text",nil];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_click_channel",@"log_sub_category",ch.channelId,@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary];
}

#pragma mark - IBActions
- (IBAction)preNextBtn_Clicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    //channelsCount = 6;//[grps count];
    
    if (channels.count==0) {
        return;
    }
    
    // handle collectionView scroll
    if (button.tag == 101 ){
        if(selectedChannelIndex > 0){
            selectedChannelIndex -= 1 ;
        }
    }else if (button.tag == 102){
        if(channelsCount>=1){
            if(selectedChannelIndex < channelsCount - 1 ){
                selectedChannelIndex += 1 ;
            }else
            {
                selectedChannelIndex = 0 ;
            }
        }
        else{
            selectedChannelIndex = 0 ;
        }
    }
    
    [self scrollCollectionToIndex];
    if (channels.count>=selectedChannelIndex) {
        Channels *ch = [channels objectAtIndex:selectedChannelIndex];
        [self setMyChannel:ch];
        dispatch_async(dispatch_get_main_queue(), ^{
            [App_delegate.downloadQueue cancelAllOperations];
            [self getPrivateContentAPI];
            [_collectionChannel reloadData];
            [_tableChannel reloadData];
        });
    }
}

-(void)channelUpdateRequest:(NSNotification *)noti
{
    // note down the time at which Channel List is getting refreshed
    [PrefManager setValueForChannelRefreshTime:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *activeNetId = [PrefManager activeNetId];
        Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
        
        NSArray  *channel  = [DBManager getChannelsForNetwork:net];
        NSMutableArray *nets = [NSMutableArray new];
        NSArray *channelsArray;
        
        if(channel.count > 0)
        {
            NSDictionary *d = @{ @"network" : net,
                                 @"channels"  : channel
                                 };
            [nets addObject:d];
            _dataarray = nets;
            NSDictionary *dict = [_dataarray objectAtIndex:0];
            channelsArray = [dict objectForKey:@"channels"];
            channelsCount = channelsArray.count; // nim
            
            @try {
                channels = [channelsArray sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
            } @catch (NSException *exception) {
            } @finally {}
            
            channel = [channelsArray copy];
        }
        
        [_tableChannel reloadData];
        [_collectionChannel reloadData];
        
    });
}

-(void)channelUpdate:(NSNotification *)noti
{
    NSDictionary *d = noti.userInfo;
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    channels = [DBManager getChannelsForNetwork:net];
    
    @try {
        channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
    } @catch (NSException *exception) {
    } @finally {}
    
    NSString *channelId = [d objectForKey:@"channelId"];
    
    for(Channels *ch in channels){
        if([channelId isEqualToString:ch.channelId]){
            
            DLog(@"Reload data : scrollIndex");
            if(selectedChannelIndex < channels.count)
            {
                @try {
                    NSString *str = [d objectForKey:@"needToMove"];
                    if([str containsString:@"Y"]){
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self setNeedToMove:YES];
                            
                            @try {
                                selectedChannelIndex = [channels indexOfObject:ch];
                                NSIndexPath *nextItem = [NSIndexPath indexPathForItem:selectedChannelIndex inSection:0];
                                [_collectionChannel scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                                [_tableChannel reloadData];
                                
                            } @catch (NSException *exception) {
                                
                            } @finally {
                                
                            }
                        });
                    }
                    else{
                        [self setNeedToMove:NO];
                    }
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
            }
            
        }
        
        
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionChannel reloadData];
        [_tableChannel reloadData];
    });
    //   [self fetchChannels];
}



-(void)scrollNotif:(NSNotification *)noti
{
    
    if(![self.navigationController.topViewController isKindOfClass:[ChanelViewController class]])//crash fix , please dont remove this code
    {
        if([noti object] || [noti userInfo])
        {
            
            //            [self refreshData];
            
            //[AppManager showAlertWithTitle:@"Hii" Body:@""];
            self.myChannel = noti.object;
            NSDictionary *d = noti.userInfo;
            [self scrollIndex:noti.object dict:d];
        }
    }
}

-(void)scrollIndex:(id)channel dict:(NSDictionary*)dict
{
    Channels *ch = channel;
    NSDictionary *d = dict;
    if(channels == nil){
        @try {
            NSString *activeNetId = [PrefManager activeNetId];
            Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
            
            NSArray  *channel  = [DBManager getChannelsForNetwork:net];
            NSMutableArray *nets = [NSMutableArray new];
            NSArray *channelsArray;
            
            if(channel.count > 0)
            {
                NSDictionary *d = @{ @"network" : net,
                                     @"channels"  : channel
                                     };
                [nets addObject:d];
                // }
                _dataarray = nets;
                NSDictionary *dict = [_dataarray objectAtIndex:0];
                channelsArray = [dict objectForKey:@"channels"];
                channelsCount = channelsArray.count; // nim
                @try {
                    channels = [channelsArray sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                } @catch (NSException *exception) {
                } @finally {}
                
                channel = [channelsArray copy];
            }
        }
        @catch (NSException *exception) {
        } @finally {}
    }else
    {
        selectedChannelIndex = [channels indexOfObject:ch];
    }
    
    DLog(@"Top View controller  ++ %@",self.navigationController.topViewController);
    
    [self downloadContent:[dict objectForKey:@"content"] length:[dict objectForKey:@"length"] contentId:[dict objectForKey:@"contentId"]cool:[dict objectForKey:@"cool"] coolCount:[dict objectForKey:@"coolCount"] share:[dict objectForKey:@"share"] shareCount:[dict objectForKey:@"shareCount"] Contact:[dict objectForKey:@"contact"] contactCount:[dict objectForKey:@"contactCount"] chanelId:[dict objectForKey:@"channelId"] isPush:NO isOnSameScreenDataFetchByAPI:NO isCreatedTime:[[dict objectForKey:@"created"] integerValue] typeOfFeed:[[dict objectForKey:@"feed_Type"] boolValue]];
    
    [self getPrivateContentAPI];
}

-(void)scrollCollectionToIndex{
    
    if(selectedChannelIndex <=(channels.count-1))
    {
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:selectedChannelIndex inSection:0];
        [_collectionChannel scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

#pragma mark - HitPrivateContentAPI
-(void)getPrivateContentAPI
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        // refresh the channel list if current channel will not have the channel icon
        if ([_myChannel.image isEqualToString:@""]) {
            [AppManager sendRequestToGetChannelList];
        }
    }];
    
    // cancel all the operations
    [App_delegate.downloadQueue cancelAllOperations];
    
    if (![self checkVarification]) {
    }
    else{
        
        NSMutableDictionary *postDictionary ;
        if(_myChannel.channelId == nil)
        {
            postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.loud_hailerid,@"loudhailer_id",@"1",@"channel_id"
                              ,@"1",@"network_id",@"1",@"page",nil];

        }
        else
        {
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.loud_hailerid,@"loudhailer_id",_myChannel.channelId,@"channel_id"
                          ,[PrefManager activeNetId],@"network_id",@"1",@"page",nil];
        }
        [App_delegate.downloadQueue setSuspended:NO];
        if ([AppManager isInternetShouldAlert:NO])
        {
            //show loader...
            [self stopUpdateExpiryTimer];
            [sharedUtils makePostCloudAPICall:postDictionary andURL:GET_PRIVATE_CHANNEL_CONTENT];
        }
        else
        {
            [refreshControl endRefreshing];
        }
    }
}

-(void)discoverButtonClicked:(UIButton*)button{
    
}

-(void)moreButtonClicked:(UIButton*)button
{
    if (isTitleClicked == YES) {
        isTitleClicked=NO;
        [UIView animateWithDuration:0.5 animations:^{
            customTitleView.frame = CGRectMake(0, -customTitleView.frame.size.height, self.view.frame.size.width, customTitleView.frame.size.height);
        } completion:^(BOOL finished) {
            [customTitleView removeFromSuperview];
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"CustomViewClose" object:nil];
        }];
        
    }
    CGFloat height=0.0;
    if(IS_IPHONE_X){
        height = self.view.bounds.size.height-90;
    }
    else{
        height =  self.view.bounds.size.height-61.3;
    }
    
    if (isMoreClicked == NO) {
        isMoreClicked = YES;
        moreView = [[MoreView alloc] initWithFrame:CGRectMake((self.view.frame.size.width)*2, 0, self.view.frame.size.width, height)];
        moreView.hidden = YES;
        moreView.delegate=self;
        [self.view addSubview:moreView];
        [UIView animateWithDuration:0.7 animations:^{
            moreView.hidden = NO;
            moreView.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        } completion:^(BOOL finished) {
            [button setTitleColor:[UIColor colorWithRed:(133.0f/255.0f)green:(189.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0] forState:UIControlStateNormal];
        }];
    }
    else{
        isMoreClicked = NO;
        [UIView animateWithDuration:0.7 animations:^{
            moreView.frame = CGRectMake((self.view.frame.size.width)*2, 0, self.view.frame.size.width, height);
        } completion:^(BOOL finished)
         {
             [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [moreView removeFromSuperview];
        }];
    }
}


-(IBAction)filterButtonAction:(id)sender{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    FilterView *filterView = [[FilterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height+64)];
    filterView.hidden = YES;
    [window addSubview:filterView];
    
    [UIView animateWithDuration:0.5 animations:^{
        filterView.hidden = NO;
        filterView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+64);
    } completion:^(BOOL finished) {
    }];
}

-(IBAction)latestFeedsButtonAction:(UIButton*)sender
{
    if (sender.selected == NO)
    {
        sender.selected = YES;
        [sender setTitle:@"?" forState:UIControlStateNormal];
        [_tableChannel layoutIfNeeded];
        [UIView animateWithDuration:1.0 animations:^{
            _allChannelView.alpha =0;
            self.topSpace.constant = 1;
            _latestFeedsButton.userInteractionEnabled = NO;
            [_tableChannel layoutIfNeeded];
        } completion:^(BOOL finished) {
            _allChannelView.hidden = YES;
            _latestFeedsButton.userInteractionEnabled = YES;
            
        }];
        NSMutableDictionary *postDictionary ;
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.loud_hailerid,@"loudhailer_id"
                          ,[PrefManager activeNetId],@"network_id",@"1",@"page",nil];
        [App_delegate.downloadQueue setSuspended:NO];
        if ([AppManager isInternetShouldAlert:NO])
        {
            //show loader...
            [self stopUpdateExpiryTimer];
            [sharedUtils makePostCloudAPICall:postDictionary andURL:[NSString stringWithFormat:@"%@%@",BASE_API_URL,kFeed_ListAPI]];
        }
        else
        {
            [refreshControl endRefreshing];
        }
    }
    else{
        sender.selected = NO;
        [sender setTitle:@"<" forState:UIControlStateNormal];
        [_tableChannel layoutIfNeeded];
        [UIView animateWithDuration:1.0 animations:^{
            _allChannelView.alpha=1;
            self.topSpace.constant = 90;
            _allChannelView.hidden = NO;
            [_tableChannel layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    if(responseDict != nil)
    {
        BOOL status = [[responseDict objectForKey:@"status"]boolValue];
        NSString *msgStr= [responseDict objectForKey:@"status"];
        if ([msgStr isEqualToString:@"Success"]) {
            status = YES;
        }
        if (status)
        {
            if([[responseDict objectForKey:@"message"] isEqualToString:@"Channel unsubscribed successfully"] || [[responseDict objectForKey:@"message"] isEqualToString:@"Channel subscribed successfully"] ){
                
                [AppManager showAlertWithTitle:@"Alert" Body:[responseDict objectForKey:@"message"]];
                
            }
            else if([[responseDict objectForKey:@"message"] isEqualToString:@"Channel content reported successfully..!"] ){
                DLog(@"Content has been removed from cloud As reported by User");
                
                [AppManager showAlertViewWithTitle:@"Acknowledgement" andMessage:@"Your concern has been reported to super admin and he will take the required action within 24 hours." firstButtonMsg:@"OK" andSecondBtnMsg:nil andVC:self noOfBtn:1 completion:^(BOOL isOkButton) {
                    if (isOkButton) {
                        
                        // move back to previous screen
                        // [self.navigationController popViewControllerAnimated:true];
                    }
                }];
            }
            
            else if([[responseDict objectForKey:@"message"] isEqualToString:@"Channel contact saved successfully.!"] ){
                DLog(@"Channel contact saved successfully!");
                [AppManager showAlertViewWithTitle:@"Acknowledgement" andMessage:@"Your contact request has been processed, admin will contact you within 24 hours." firstButtonMsg:@"OK" andSecondBtnMsg:nil andVC:self noOfBtn:1 completion:^(BOOL isOkButton) {
                    if (isOkButton) {
                        
                        // move back to previous screen
                        // [self.navigationController popViewControllerAnimated:true];
                    }
                }];
            }
            else if ([[responseDict objectForKey:@"message"] isEqualToString:@"Send App version and Compatibility successfully..!"] )
            {
                DLog(@"Send App version and Compatibility successfully..!");
                
                NSString *appVesrionFromCloud = [[[responseDict objectForKey:@"data"] objectForKey:@"app_version"] stringByReplacingOccurrencesOfString:@"." withString:@""];
                
                NSUInteger compatibility = [[[responseDict objectForKey:@"data"] objectForKey:@"compatibility"] floatValue];
                
                NSString *currentAppVersion = [[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] stringByReplacingOccurrencesOfString:@"." withString:@""];
                
                // if App Version from Cloud is greater than the  current App version
                if ([appVesrionFromCloud intValue] > [currentAppVersion intValue]) {
                    // now check that the What was the Backword Compatibility Value for the Current Application Version
                    
                    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppVersionList" ofType:@".plist"]];
                    // get the value where we will save the value according to the backword compatibilty
                    
                    NSString *backwordCompatibilyForCurrentVersion = [dataDict objectForKey:[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
                    
                    // Now check if Backword comopatibilty for the current App version and Backword compatibity from the cloud is not the same
                    if (compatibility > [backwordCompatibilyForCurrentVersion integerValue]) {
                        
                        // forecly ask user to update the application
                        // also redirect user to APp store
                        [AppManager showAlertViewWithTitle:@"Alert!" andMessage:@"Please update the Application As we have added new features to the Application" firstButtonMsg:@"Update" andSecondBtnMsg:@"" andVC:self noOfBtn:1  completion:^(BOOL isOkButton) {
                            
                            // redirect user to current application with having latest version
                            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/in/app/providence2go/id1270610797?mt=8"]];
                        }];
                    }
                    else if (compatibility == [backwordCompatibilyForCurrentVersion integerValue])
                    {
                        return;
                        // ask user permision to update the application
                        // User can take action if he wants to update the Application
                        [AppManager showAlertViewWithTitle:@"Alert!" andMessage:@"New version is available, Please update. Do you want to update the Application?" firstButtonMsg:@"YES" andSecondBtnMsg:@"NO" andVC:self noOfBtn:2  completion:^(BOOL isOkButton) {
                            // redirect user to current application with having latest version
                            if (isOkButton) {
                                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/in/app/providence2go/id1270610797?mt=8"]];
                            }
                        }];
                    }
                    else
                    {
                        DLog(@"Something is wrong as Backward compatibilty for the Current Version is greater than backward compatibilty coming from the cloud. ");
                    }
                }
            }
            else if ([[responseDict objectForKey:@"message"] isEqualToString:@"City information..!"] ){
                userSelectedCityArray = [responseDict valueForKey:@"data"];
                for (NSDictionary *dic in userSelectedCityArray) {
                    if ([[dic valueForKey:@"city_type"] integerValue] == 1) {
                        [PrefManager setDefaultCity:[dic valueForKey:@"city_name"]];
                    }
                }
                titleLabel.text = [PrefManager defaultUserSelectedCity];
                [AppManager sendRequestToGetChannelList];
            }
            else{
                [self startUpdateExpiryTimer];
                array = [responseDict objectForKey:@"data"];
                
                // parse the data based upon the feed id
                DLog(@"%s",__PRETTY_FUNCTION__);
                NSSortDescriptor *sortDescToSortDataArray = [[NSSortDescriptor alloc] initWithKey:k_FeedID ascending:NO];
                NSArray *descArray = [NSArray arrayWithObject:sortDescToSortDataArray];
                NSArray *parseArray = [array sortedArrayUsingDescriptors:descArray];
                DLog(@"%s",__PRETTY_FUNCTION__);
                
                if(parseArray!=nil)
                {
                    for(NSDictionary *pvt in parseArray)
                    {
                        if([pvt objectForKey:@"content_url"] != nil && [pvt objectForKey:@"content_length"] != nil && [pvt objectForKey:@"content_id"] != nil)
                        {
                            BOOL isFeedType = NO;
                            if([[pvt objectForKey:@"scheduler_type"] intValue] == 1)
                                isFeedType = YES;
                            else
                                isFeedType = [[pvt objectForKey:@"scheduler_type"] boolValue];
                            
                            DLog(@"Value  %@ %ld",[pvt objectForKey:@"created"],[[pvt objectForKey:@"created"] integerValue]);
                            [self downloadContent:[pvt objectForKey:@"content_url"] length:[pvt objectForKey:@"content_length"] contentId:[pvt objectForKey:@"content_id"] cool:[pvt objectForKey:@"cool"] coolCount:[pvt objectForKey:@"cool_count"] share:[pvt objectForKey:@"share"] shareCount:[pvt objectForKey:@"share_count"] Contact:[pvt objectForKey:@"contact"] contactCount:[pvt objectForKey:@"contact_count"] chanelId:[[pvt objectForKey:@"channel_ids"] objectAtIndex:0] isPush:NO isOnSameScreenDataFetchByAPI:YES isCreatedTime:[[pvt objectForKey:@"updated"] integerValue] typeOfFeed:isFeedType];
                            [refreshControl endRefreshing];
                        }
                        else{
                            [refreshControl endRefreshing];
                        }
                    }
                    NSArray *allFeedsArray = [FeedView getAllFeedsForFeedView];
                    if(allFeedsArray.count > 0)
                    {
                    [_detailsOfChannel removeAllObjects];
                    _detailsOfChannel = [allFeedsArray mutableCopy];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [_tableChannel reloadData];
                    });
                    }

                    DLog(@"AllFeeds Temp Array %@",ALlFeedsTempArray);
                }
                else{
                    [refreshControl endRefreshing];
                }
                
            }
            [LoaderView removeLoader];

        }
        else
        {
            if([[responseDict valueForKey:@"message"] isEqualToString:kUserCityInformationNotFound])
            {
                CustomTitleView *customTitleView = [[CustomTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height)];
                customTitleView.tag = 300;
                [customTitleView showHideNextButton:NO];
                [customTitleView initializeData];
                customTitleView.delegate=self;
                [self.view addSubview:customTitleView];
            }
            else{
                [self startUpdateExpiryTimer];
                if ([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]])
                {
                    
                    [self.view setBackgroundColor:[UIColor colorWithRed:(39.0f/255.0f) green:(38.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0]];
                    //  [AppManager showAlertWithTitle:@"Alert" Body:@"There are no new contents to be shown."];
                    [refreshControl endRefreshing];
                }
            }
        }
    }
}

-(void)requestFail:(NSError *)errorCode{
    
    if (errorCode.code != -999) {
        [refreshControl endRefreshing];
    }
}

-(void)downloadContent:(NSString *)content length:(NSString*)lengthh contentId:(NSString*)contentID cool:(NSString*)isCoolV coolCount:(NSString*)coolCountV share:(NSString*)isShareV shareCount:(NSString*)shareCountV Contact:(NSString*)isContactV contactCount:(NSString*)contactCountV chanelId:(NSString *)chanelId isPush:(BOOL)isPushClick isOnSameScreenDataFetchByAPI:(BOOL)isUsingAPI isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)isFeedType
{
    NSString *contentId =  [contentID copy];
    NSString *isCool = [isCoolV copy];
    NSString *coolCount = [coolCountV copy];
    NSString *isShare = [isShareV copy];
    NSString *shareCount = [shareCountV copy];
    NSString *isContact = [isContactV copy];
    NSString *contactCount = [contactCountV copy];
    NSString *chanelID = [chanelId copy];
    BOOL isFeedTypeValue = isFeedType;
    BOOL isPush = NO;
    isPush = isPushClick;
    
    if(!App_delegate.downloadQueue)
    {
        DLog(@"Again alloc download queue");
        App_delegate.downloadQueue = [[NSOperationQueue alloc] init];
        App_delegate.downloadQueue.maxConcurrentOperationCount = 4;
        App_delegate.downloadQueue.qualityOfService = NSQualityOfServiceBackground;
    }
    
    __block NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        
        if (blockOp.isCancelled) {
            NSLog(@"Block Operation is cancelled");
            return;
        }
        
        if (App_delegate.downloadQueue.isSuspended) {
            NSLog(@"Opertaion Queue is suspended");
            return;
        }
        
        __block NSArray *arr;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            arr = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND contentId = \"%@\"", chanelID,contentId] descr:nil isDistinctResults:YES];
        });
        
        sleep(1);
        
        if (arr.count>0) {
            
            ChannelDetail *channelDetails = [arr objectAtIndex:0];
            
            if (([channelDetails.contactCount isEqualToNumber:[NSNumber numberWithInt:[contactCount intValue]]] &&  [channelDetails.coolCount isEqualToNumber:[NSNumber numberWithInt:[coolCount intValue]]] &&  channelDetails.cool == [isCool boolValue] && channelDetails.contact == [isContact boolValue])  &&  channelDetails.share ==[isShare boolValue] && [channelDetails.shareCount isEqualToNumber:[NSNumber numberWithInt:[shareCount intValue]]] && [channelDetails.created_time isEqualToNumber:[NSNumber numberWithInteger:createdTime]] && channelDetails.feed_Type == isFeedTypeValue)
            {
                if([_myChannel.channelId isEqualToString:chanelID])
                    
                    return;
            }
            else
            {
                
                NSMutableDictionary  *channelDict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:channelDetails.mediaType,@"mediaType",contentId,@"content_id",channelDetails.text,@"text",channelDetails.duration, @"duration",channelDetails.channelId,@"channelId",[NSString stringWithFormat:@"%@",isCool],@"cool",[NSString stringWithFormat:@"%@",isShare],@"share",[NSString stringWithFormat:@"%@",isContact],@"contact",[NSString stringWithFormat:@"%@",coolCount],@"coolCount",[NSString stringWithFormat:@"%@",shareCount],@"shareCount",[NSString stringWithFormat:@"%@",contactCount],@"contactCount",[NSString stringWithFormat:@"%d",channelDetails.isForChannel],@"isForChannel",[NSString stringWithFormat:@"%lu",(unsigned long)createdTime],@"created_time",[NSNumber numberWithBool:channelDetails.feed_Type],@"feed_Type",channelDetails.mediaPath,@"mediaPath",nil];
                if(_allChannelView.hidden == YES)
                {
                    DLog(@"channelDictTemp Third %@",channelDict1);
                   // [FeedView addChannelContentWithDict:channelDict1 tempId:globalVal];

                }
                else
                {
                    ChannelDetail *channelD = [ChannelDetail addChannelContentWithDict:channelDict1 tempId:globalVal];
                }
                
                
                [DBManager save];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_tableChannel reloadData];
                    
                });
                return;
            }
        }
        
        NSLog(@"Download request for the content id %@",contentID);
        // timeout the image if image is not downloaded within 40 sec
        NSURLResponse* urlResponse;
        NSError* error1;
        NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:content] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
        NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error1];
        
        NSError *error;
        NSDateFormatter *dateFormatterb = [[NSDateFormatter alloc] init];
        [dateFormatterb setDateFormat:@"HH:mm:ss.SSS"];
        
        
        if (data==nil)
        {
            // if data is nil
            if(isPush)
            {
                //  is clicked on Push
                NSString *activeNetId = [PrefManager activeNetId];
                Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                channels = [DBManager getChannelsForNetwork:net];
                
                @try {
                    channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                } @catch (NSException *exception) {
                } @finally {}
                // NSLog(@"Manoj 2 Channel %@",_myChannel);
                
                if(isPush)
                {
                    if (![_myChannel.channelId isEqualToString:chanelID]) {
                        selectedChannelIndex = [channels indexOfObject:_myChannel];
                        [self scrollCollectionToIndex];
                    }
                }
                [blockOp cancel];
                return;
            }
            else{
                [blockOp cancel];
                return;
            }
        }
        
        // NSLog(@"Manoj 3 Channel %@",_myChannel);
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if(json != NULL)
        {
            NSArray *arrayOfChannel = [json objectForKey:@"channel_ids"];
            NSString *channelIdString = [arrayOfChannel objectAtIndex:0];
            
            //To retrieve the data from the plist
            NSMutableArray *savedArray = [[NSMutableArray alloc] initWithContentsOfFile: plistPath];
            for (NSDictionary *dic in savedArray)
            {
                // NSLog(@"Manoj 4 Channel %@",_myChannel);
                
                NSString *cId = [dic objectForKey:@"contentId"];
                NSString *channelId = [dic objectForKey:@"channelId"];
                if([cId isEqualToString:contentId] && [channelId isEqualToString:channelIdString]){
                    
                    if([channelIdString isEqualToString:_myChannel.channelId]){
                        
                        if(_needToMove)
                        {
                            NSString *activeNetId = [PrefManager activeNetId];
                            Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                            channels = [DBManager getChannelsForNetwork:net];
                            @try {
                                channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                            } @catch (NSException *exception) {
                            } @finally {}
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(isPush)
                                {
                                    
                                    if (![_myChannel.channelId isEqualToString:chanelID]) {
                                        selectedChannelIndex = [channels indexOfObject:_myChannel];
                                        [self scrollCollectionToIndex];
                                    }
                                }
                                [blockOp cancel];
                                return;
                            });
                        }
                        else{
                            [blockOp cancel];
                            return;
                        }
                    }
                }
            }
            
            NSString *value = [[NSUserDefaults standardUserDefaults]valueForKey:@"contentId"];
            
            if([value isEqualToString:contentId]){
                
                if([channelIdString isEqualToString:_myChannel.channelId]){
                    
                    if(_needToMove){
                        
                        NSString *activeNetId = [PrefManager activeNetId];
                        Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                        channels = [DBManager getChannelsForNetwork:net];
                        
                        @try {
                            channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                        } @catch (NSException *exception) {
                        } @finally {}
                        
                        // NSLog(@"Manoj 12 Channel %@",_myChannel);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(isPush)
                            {
                                if (![_myChannel.channelId isEqualToString:chanelID]) {
                                    selectedChannelIndex = [channels indexOfObject:_myChannel];
                                    [self scrollCollectionToIndex];
                                }
                            }
                            [blockOp cancel];
                            return;
                        });
                    }
                }
                else{
                    DLog(@"I still need reload");
                    [blockOp cancel];
                    return;
                }
            }
            else{
                [[NSUserDefaults standardUserDefaults]setValue:contentId forKey:@"contentId"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            }
            
            if([channelIdString isEqualToString:_myChannel.channelId]){
                
                if(_needToMove){
                    
                    NSString *activeNetId = [PrefManager activeNetId];
                    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                    channels = [DBManager getChannelsForNetwork:net];
                    
                    @try {
                        channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                    } @catch (NSException *exception) {
                    } @finally {}
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(isPush)
                        {
                            if (![_myChannel.channelId isEqualToString:chanelID]) {
                                selectedChannelIndex = [channels indexOfObject:_myChannel];
                                [self scrollCollectionToIndex];
                                [_tableChannel reloadData];
                            }
                        }
                    });
                }
            }
            else{
                if(channels == nil){
                    NSString *activeNetId = [PrefManager activeNetId];
                    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                    channels = [DBManager getChannelsForNetwork:net];
                    
                    @try {
                        channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                    } @catch (NSException *exception) {
                    } @finally {}
                }
                for(Channels *ch in channels){
                    
                    if([ch.channelId isEqualToString:channelIdString]){
                        
                        if(selectedChannelIndex != [channels indexOfObject:ch]){
                            
                            channelIndex = [channels indexOfObject:ch];
                            if(_needToMove){
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if(isPush)
                                    {
                                        if (![_myChannel.channelId isEqualToString:chanelID]) {
                                            
                                            selectedChannelIndex = [channels indexOfObject:_myChannel];
                                            [self scrollCollectionToIndex];
                                            [self setMyChannel:ch];
                                        }
                                    }
                                });
                            }
                            else{
                                
                                if(_needToMove){
                                    
                                    if(isPush)
                                    {
                                        if (![_myChannel.channelId isEqualToString:chanelID]) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                selectedChannelIndex = [channels indexOfObject:_myChannel];
                                                [self scrollCollectionToIndex];
                                                [self setMyChannel:ch];
                                            });
                                            
                                        }
                                    }
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        NSIndexPath *indp = [NSIndexPath indexPathForRow:channelIndex inSection:0];
                                        @try {
                                            
                                            [_collectionChannel reloadItemsAtIndexPaths:[NSArray arrayWithObject:indp]];
                                            
                                        } @catch (NSException *exception) {
                                            
                                        } @finally {
                                            
                                        }
                                    });
                                }
                            }
                        }else{
                            
                            if(isPush)
                            {
                                if (![_myChannel.channelId isEqualToString:chanelID])
                                {
                                    selectedChannelIndex = [channels indexOfObject:_myChannel];
                                    [self scrollCollectionToIndex];
                                }
                            }
                        }
                        
                        if(_needToMove){
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(isPush)
                                {
                                    if (![_myChannel.channelId isEqualToString:chanelID]) {
                                        
                                        selectedChannelIndex = [channels indexOfObject:_myChannel];
                                        [self scrollCollectionToIndex];
                                        [self setMyChannel:ch];
                                    }
                                }
                                [_collectionChannel reloadData];
                                [_tableChannel reloadData];
                            });
                        }
                    }
                }
            }
            
            NSString *hexString = [json objectForKey:@"message"];
            
            if (hexString.length<3) {
                [blockOp cancel];
                return;
            }
            
            int numberValueToDivide = 1;
            if([[hexString substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"CMS"])
            {
                numberValueToDivide = 2;
            }
            else
            {
                numberValueToDivide = 1;
            }
            
            DLog(@"Range is %@",[hexString substringWithRange:NSMakeRange(0, 6/numberValueToDivide)]);
            
            
            if (hexString.length<6) {
                [blockOp cancel];
                return;
            }
            
            NSString *stringForBLEData = [hexString substringWithRange:NSMakeRange(0, 6/numberValueToDivide)];
            
            NSString *begTxt;
            NSString *resultingString;
            NSData *datafromHexString;
            
            if(numberValueToDivide==1)
            {
                datafromHexString =  [AppManager dataFromHexString:hexString];
                resultingString = [[NSString alloc] initWithData:datafromHexString encoding:NSUTF8StringEncoding];
            }else
            {
                resultingString = hexString;
                begTxt = [resultingString substringToIndex:3];
            }
            //NSString *begTxt = [resultingString substringToIndex:3];
            if([stringForBLEData isEqualToString:@"424F4D"])
            {
                NSDictionary *dc  = [[NSDictionary alloc] initWithObjectsAndKeys:hexString,@"Data",contentId,@"Key", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"XYZ" object:nil userInfo:dc];
                
            }
            else if([begTxt isEqualToString:@"CMS"] || [stringForBLEData isEqualToString:@"434d53"])
            {
                if (resultingString.length<55) {
                    [blockOp cancel];
                    return;
                }
                NSString *channelID = [resultingString substringWithRange:NSMakeRange(3, 4)];
                
                NSString *extraBits = [resultingString substringWithRange:NSMakeRange(7, 6)];
                
                ChannelDataClassInfo *dataObject = nil;
                
                if ([extraBits intValue] ==1 || [extraBits intValue] == 0) {
                    // old packet format
                    dataObject  = [[ChannelDataClassInfo alloc] initWithChannelDataStringHavingEncryption:hexString withContentID:contentID isForOldPacketForFomat:YES];
                    dataObject.pushTimeStamp = [NSString stringWithFormat:@"%lu",(unsigned long)createdTime];
                    dataObject.packetVersion = @"0";
                    dataObject.contentID = contentId;
                }
                else
                {
                    // new packet format
                    dataObject  = [[ChannelDataClassInfo alloc] initWithChannelDataStringHavingEncryption:hexString withContentID:contentID isForOldPacketForFomat:NO];
                    dataObject.pushTimeStamp =[NSString stringWithFormat:@"%lu",(unsigned long)createdTime];
                }
                
                NSUInteger  secondsLeft = [dataObject.appDisplayTime intValue] - ([[NSDate date] timeIntervalSince1970] - [dataObject.pushTimeStamp longLongValue]);
                
                if (secondsLeft < 30 && !dataObject.isForeverFeed) {
                    [blockOp cancel];
                    dataObject = nil;
                    return;
                }
                
                NSLog(@"Print the Data Object and channel ID %@ %@",dataObject.contentID,dataObject.channelID);
                
                NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
                NSString *mediaPath;
                if([dataObject.msgType isEqualToString:@"TIXX"] || [dataObject.msgType isEqualToString:@"XIXX"]){
                    NSString *str1= [str stringByAppendingString:@".png"];
                    mediaPath = [self saveDataToFile:dataObject.imgData withFileName:str1];
                }
                else if([dataObject.msgType isEqualToString:@"TGXX"] || [dataObject.msgType isEqualToString:@"XGXX"]){
                    NSString *str1= [str stringByAppendingString:@".gif"];
                    //  gifData = decodedImageData;
                    mediaPath = [self saveDataToFile:dataObject.imgData withFileName:str1];
                }
                else if([dataObject.msgType isEqualToString:@"TXXX"]){
                    mediaPath = @"";
                }
                else
                {
                    mediaPath = @"";
                    NSLog(@"Something is wrong as did not get the proper message Type");
                    [blockOp cancel];
                    return;
                }
                
                dataObject.mediaPath =  mediaPath;
                __block BOOL isNewData = NO;
                [AppManager toCheckDuplicateContent:dataObject.contentID EntityName:kEntityForChannelFeed Attribute_key_Id:kAttributeOfChannelFeedForContent_Id CompletionBlock:^(BOOL success)
                 {
                     if (!success) {
                         // New contents
                         // save in data base
                         isNewData = YES;
                         NSLog(@"In Download Contnet New content New Contents as Content id is %@",dataObject.contentID);
                         
                     }else
                     {
                         NSLog(@"Not new Contents as Content id is %@",dataObject.contentID);
                         isNewData = NO;
                     }
                 }];
                
                if (!isNewData) {
                    NSString *activeNetId = [PrefManager activeNetId];
                    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                    
                    NSArray *channelArray = [DBManager  getChannelDataFromFromContentID:[NSString stringWithFormat:@"%@",dataObject.contentID] Network:net];
                    if (channelArray.count>1)
                    {
                        // Channel exist for current content id
                        DLog(@"Channel informations related to delete packet and content id %@ %@",channelArray,contentId);
                        
                        ChannelDetail *channelDetails;
                        @try {
                            channelDetails = [channelArray objectAtIndex:1];
                        } @catch (NSException *exception) {
                            
                        } @finally {
                        }
                        
                        if (channelDetails==nil) {
                            [blockOp cancel];
                            return;
                        }
                        
                        if (([channelDetails.contactCount isEqualToNumber:[NSNumber numberWithInt:[contactCount intValue]]] &&  [channelDetails.coolCount isEqualToNumber:[NSNumber numberWithInt:[coolCount intValue]]] &&  channelDetails.cool == [isCool boolValue] && channelDetails.contact == [isContact boolValue])  &&  channelDetails.share ==[isShare boolValue] && [channelDetails.shareCount isEqualToNumber:[NSNumber numberWithInt:[shareCount intValue]]] && [channelDetails.created_time isEqualToNumber:[NSNumber numberWithInteger:createdTime]] && channelDetails.feed_Type == isFeedTypeValue)
                        {
                            if([_myChannel.channelId isEqualToString:chanelID])
                                [blockOp cancel];
                            return;
                        }
                        else
                        {
                            if (dataObject==nil) {
                                [blockOp cancel];
                                return;
                            }
                            
                            NSMutableDictionary  *channelDict1;
                            @try {
                                channelDict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:channelDetails.mediaType,@"mediaType",dataObject.contentID,@"content_id",channelDetails.text,@"text",channelDetails.duration, @"duration",channelDetails.channelId,@"channelId",[NSString stringWithFormat:@"%@",isCool],@"cool",[NSString stringWithFormat:@"%@",isShare],@"share",[NSString stringWithFormat:@"%@",isContact],@"contact",[NSString stringWithFormat:@"%@",coolCount],@"coolCount",[NSString stringWithFormat:@"%@",shareCount],@"shareCount",[NSString stringWithFormat:@"%@",contactCount],@"contactCount",[NSString stringWithFormat:@"%d",channelDetails.isForChannel],@"isForChannel",[NSString stringWithFormat:@"%lu",(unsigned long)createdTime],@"created_time",[NSNumber numberWithBool:channelDetails.feed_Type],@"feed_Type",channelDetails.mediaPath,@"mediaPath",nil];
                                
                            } @catch (NSException *exception) {
                            } @finally {}
                            
                            if(_allChannelView.hidden == YES)
                            {
                                DLog(@"channelDictTemp first %@",channelDict1);
                           //     [FeedView addChannelContentWithDict:channelDict1 tempId:globalVal];
                            }
                            else
                            {
                                ChannelDetail *channelD = [ChannelDetail addChannelContentWithDict:channelDict1 tempId:globalVal];
                            }
                            [DBManager save];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [_tableChannel reloadData];
                                
                            });
                            [blockOp cancel];
                            return;
                        }
                    }
                    else
                    {
                        NSLog(@"Array count is Zero");
                    }
                    [blockOp cancel];
                    return;
                }
                
                DLog(@"Manoj 2 Channel ID and Content Id is %@ %@",channelIdString,dataObject.contentID);
                
                channelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:dataObject.msgType,@"mediaType",dataObject.contentID,@"content_id",dataObject.textMessage,@"text",dataObject.appDisplayTime, @"duration",[NSString stringWithFormat:@"%d",[dataObject.channelID intValue]],@"channelId",isCool,@"cool",isShare,@"share",isContact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",[NSNumber numberWithBool:YES],@"isForChannel",[NSNumber numberWithInteger:createdTime],@"created_time",[NSNumber numberWithBool:dataObject.isForeverFeed],@"isForeverFeed",[NSNumber numberWithBool:isFeedTypeValue],@"feed_Type",dataObject.mediaPath,@"mediaPath",nil];
                
                ChannelDetail *channelD;
                if(_allChannelView.hidden == YES)
                {
                    DLog(@"channelDictTemp Second %@",channelDict);
                    [FeedView addChannelContentWithDict:channelDict tempId:globalVal];

                }
                else
                {
                    channelD = [ChannelDetail addChannelContentWithDict:channelDict tempId:globalVal];
                }
                
                [DBManager save];
                
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableChannel reloadData];
                });
                
                @try {
                    NSString *activeNetId = [PrefManager activeNetId];
                    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                    
                    NSArray  *channel  = [DBManager getChannelsForNetwork:net];
                    NSMutableArray *nets = [NSMutableArray new];
                    NSArray *channelsArray;
                    
                    if(channel.count > 0)
                    {
                        NSDictionary *d = @{ @"network" : net,
                                             @"channels"  : channel
                                             };
                        [nets addObject:d];
                        _dataarray = nets;
                        NSDictionary *dict = [_dataarray objectAtIndex:0];
                        channelsArray = [dict objectForKey:@"channels"];
                        channelsCount = channelsArray.count; // nim
                        
                        @try {
                            channels = [channelsArray sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                        } @catch (NSException *exception) {
                        } @finally {}
                    }
                } @catch (NSException *exception) {
                } @finally {}
                
                __block BOOL isDefaultChannel = NO;
                [channels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    ChannelDetail *channelD = obj;
                    if ([channelD.channelId intValue] == [channelIdString intValue]) {
                        if (idx ==0) {
                            isDefaultChannel = YES;
                        }
                    }
                }];
                
                if(channels.count==0)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableChannel reloadData];
                    });
                    return;
                }
                Channels *requiredChannel = [channels objectAtIndex:0];
                
                if (isDefaultChannel) {}
                else
                {
                    if ([requiredChannel.channelId isEqualToString:kRequiredChannelId]) {
                        
                        NSLog(@"making copy on default channel for Feed Id %@",dataObject.contentID);
                        NSMutableDictionary *requiredchannelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:dataObject.msgType,@"mediaType",dataObject.contentID,@"content_id",dataObject.textMessage,@"text",channelD.duration, @"duration",requiredChannel.channelId,@"channelId",@"0",@"cool",@"0",@"share",@"0",@"contact",@"0",@"coolCount",@"0",@"shareCount",@"0",@"contactCount",[NSNumber numberWithBool:NO],@"isForChannel",[NSNumber numberWithInteger:[dataObject.pushTimeStamp integerValue]],@"created_time",[NSNumber numberWithBool:dataObject.isForeverFeed],@"isForeverFeed",[NSNumber numberWithBool:isFeedTypeValue],@"feed_Type",dataObject.mediaPath,@"mediaPath",nil];
                        
                        [ChannelDetail addChannelContentWithDictForDefaultChannel:requiredchannelDict tempId:globalVal];
                        
                        [DBManager save];
                        
                        sleep(1);
                    }
                }
                
                if(channelD){
                    
                    if([channelIdString isEqualToString:_myChannel.channelId]){
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if ([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]]) {
                                [_myChannel clearCount:_myChannel];
                                Global *shared = [Global shared];
                                NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];                                NSInteger unreadContents = [DBManager getUnreadChannelContentCount];
                                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount + unreadContents)];
                            }
                            
                            else{
                                Global *shared = [Global shared];
                                NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];                                NSInteger unreadContents = [DBManager getUnreadChannelContentCount];
                                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount + unreadContents)];
                            }
                        });
                    }
                    else{
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_tableChannel reloadData];
                    
                    [self callMethod];
                });
                DLog(@"Top View controller %@",self.navigationController.topViewController);
                
                
                if(selectedChannelIndex > channels.count){
                    [blockOp cancel];
                    return;
                }
                
                if (!isUsingAPI)
                {
                    // if data is not by getting the feed from API
                    
                    Channels *tempChanel = [channels objectAtIndex:selectedChannelIndex];
                    int timeStamp = (int)[TimeConverter timeStamp];
                    
                    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:contentId,@"channelContentId",tempChanel.channelId,@"channelId",content,@"text",nil];
                    
                    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_receiving_channelcontent_fromPUSH",@"log_sub_category",tempChanel.channelId,@"category_id",contentId,@"channelContentId",content,@"text",detaildict,@"details",nil];
                    
                    [AppManager saveEventLogInArray:postDictionary];
                }
                
                if ([_myChannel.channelId isEqualToString:@"1"]) {
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableChannel reloadData];
                    });
                }
            }
        }else
        {
            [blockOp cancel];
            return;
        }
    }];
    
    if(![[App_delegate.downloadQueue operations] containsObject:blockOp])
    {
        __block BOOL isAlreadyExist = NO;
        [[App_delegate.downloadQueue operations] enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([contentId isEqualToString:obj.name]) {
                isAlreadyExist = YES;
                *stop = YES;
            }
        }];
        
        if (isAlreadyExist) {
            if (isPush) {
                
                NSString *activeNetId = [PrefManager activeNetId];
                Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
                
                NSArray *dataOfParticularChannl =  [DBManager getChannelDataFromNameAndId:chanelID isName:YES Network:net];
                NSString *channelID;
                if (dataOfParticularChannl.count>0)
                {
                    Channels *channel = [dataOfParticularChannl objectAtIndex:0];
                    channelID = channel.channelId;
                }
                else
                    return;
                
                
                NSArray  *channel  = [DBManager getChannelsForNetwork:net];
                NSMutableArray *nets = [NSMutableArray new];
                NSArray *channelsArray;
                
                if(channel.count > 0)
                {
                    // NSLog(@"Manoj 48 Channel %@",_myChannel);
                    
                    NSDictionary *d = @{ @"network" : net,
                                         @"channels"  : channel
                                         };
                    [nets addObject:d];
                    // }
                    _dataarray = nets;
                    NSDictionary *dict = [_dataarray objectAtIndex:0];
                    channelsArray = [dict objectForKey:@"channels"];
                    channelsCount = channelsArray.count; // nim
                    
                    @try {
                        channelsArray = [channelsArray sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                    } @catch (NSException *exception) {
                    } @finally {}
                }else
                {
                    return;
                }
                
                for(Channels *ch in channelsArray)
                {
                    if([ch.channelId intValue] == [channelID intValue])
                    {
                        selectedChannelIndex = [channelsArray indexOfObject:ch];
                        [self scrollCollectionToIndex];
                        [self setMyChannel:ch];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_collectionChannel reloadData];
                            [_tableChannel reloadData];
                        });
                        break;
                    }
                }
            }
            
            // NSLog(@"Manoj 53 Channel %@",_myChannel);
            return;
        }
        
        if ((isPush || !isUsingAPI) && !isAlreadyExist)
        {
            blockOp.name = contentId;
            blockOp.queuePriority = NSOperationQueuePriorityVeryHigh;
        }
        else if (!isAlreadyExist)
        {
            if ([chanelId isEqualToString:_myChannel.channelId])
            {
                blockOp.name = contentId;
                blockOp.queuePriority = NSOperationQueuePriorityHigh;
            }
            else
            {
                blockOp.name = contentId;
                blockOp.queuePriority = NSOperationQueuePriorityNormal;
            }
        }
        if (!isAlreadyExist)
        {
            [App_delegate.downloadQueue addOperation:blockOp];
        }
    }
}

- (NSString*)saveDataToFile:(NSData*)data withFileName:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName]; //Add the file name
    //[data writeToFile:filePath atomically:YES]; //Write the file
    
    if (![data writeToFile:filePath atomically:YES])
    {
        if(![data writeToFile:filePath atomically:YES])
        {
            NSLog(@"File Failed to saved even after second attempt");
        }
        else
        {
            DLog(@"File Successfully saved in second attempt");
        }
    }
    else
    {
        DLog(@"File Successfully saved in first attempt");
        
    }
    
    UIImage *image1 = [UIImage imageWithData:data];
    if(image1)
    {
        [[SDImageCache sharedImageCache] storeImage:image1 forKey:filePath toDisk:YES];
    }
    
    return filePath;
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView{
    
    selectedTextTag = textView.tag;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSArray *totalChannelContent ; // = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", _myChannel.channelId] descr:[NSSortDescriptor sortDescriptorWithKey:@"received_timeStamp" ascending:NO] isDistinctResults:YES];
    totalChannelContent = [_detailsOfChannel copy];
    ChannelDetail *c = [totalChannelContent objectAtIndex:textView.tag];
    
    selectedContentIndex = c.contentId.integerValue;
    
    NSString *urlString = [NSString stringWithFormat:@"%@",URL];
    NSMutableDictionary *postDictionary;
    NSMutableDictionary *detaildict;
    
    if([urlString hasPrefix:@"https://"] || ([urlString hasPrefix:@"http://"]))
    {
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",_myChannel.channelId,@"channelId",textView.text,@"text",nil];
        
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_click_url",@"log_sub_category",_myChannel.channelId,@"channelId",[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",textView.text,@"text",detaildict,@"details",nil];
    }
    else if([urlString hasPrefix:@"telprompt:"] || [urlString hasPrefix:@"tel:"])
    {
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:textView.text,@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_click_phone_number",@"log_sub_category",_myChannel.channelId,@"channelId",[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",textView.text,@"text",@"",@"category_id",detaildict,@"details",nil];
        
        phNumber = urlString;
        [[NSUserDefaults standardUserDefaults]setObject:urlString forKey:k_PhoneNumber];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    [AppManager saveEventLogInArray:postDictionary];
    return YES;
}

#pragma mark - Notification methods
-(void)channelDataFromBLE:(NSNotification *)ce
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableChannel reloadData];
    });
    
    NSArray *arr = [[ce userInfo] objectForKey:@"Data"];
    
    NSMutableArray *arrayV = [[NSMutableArray alloc] init];
    
    arrayV =  [arr mutableCopy];
    
    NSSortDescriptor * brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Frag_No" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    NSArray *sortedArray = [arrayV sortedArrayUsingDescriptors:sortDescriptors];
    
    [arrayV  removeAllObjects];
    arrayV  = [sortedArray mutableCopy];
    
    
    NSString *dats;
    for(NSDictionary *dic in arrayV)
    {
        NSString *dataString =[[[[NSString stringWithFormat:@"%@",[dic objectForKey:@"Data"]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
        if(!dats)
        {
            dats =dataString;
        }else
        {
            dats = [dats stringByAppendingString:dataString];
        }
    }
    
    NSString *trimmed  =  [dats copy];
    NSString *hexfffString = [[trimmed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableString *string = [[NSMutableString alloc] init];
    int i = 0;
    unsigned long y = hexfffString.length/40;
    
    for (i=0; i<=y; i++) {
        
        NSString *ff;
        if (i == y) {
            ff = [hexfffString substringWithRange:NSMakeRange(i*40, hexfffString.length-(i*40))];
        }
        else
        {
            ff  = [hexfffString substringWithRange:NSMakeRange(i*40, 40)];
        }
        if (i ==0) {
            
            [string appendString:[ff substringWithRange:NSMakeRange(24, 16)]];
            
        }else
        {
            if(![ff isEqualToString:@""])
            {
                [string appendString:[ff substringWithRange:NSMakeRange(12, ff.length-12)]];
            }
        }
    }
    
    NSString *hexString = string;
    NSDateFormatter *dateFormatterb = [[NSDateFormatter alloc] init];
    [dateFormatterb setDateFormat:@"HH:mm:ss.SSS"];
    
    NSData *datafromHexString =  [AppManager dataFromHexString:hexString];
    
    NSString *resultingStringForContent_ID = [[NSString alloc] initWithData:datafromHexString encoding:NSUTF8StringEncoding];
    NSString *resultingString = [resultingStringForContent_ID substringWithRange:NSMakeRange(8, resultingStringForContent_ID.length-8)];
    
    //NSLog(@"HI Data is %@",resultingStringForContent_ID);
    
    if (resultingString.length<55) {
        return;
    }
    
    NSString *content_ID = [resultingStringForContent_ID substringWithRange:NSMakeRange(0, 8)];
    DLog(@"Content_Id %@",content_ID);
    
    ChannelDataClassInfo *dataObject = [[ChannelDataClassInfo alloc] initWithChannelDataStringHavingEncryption:resultingString withContentID:content_ID isForOldPacketForFomat:NO];
    
    if(dataObject == nil)
    {
        return;
    }
    
    [self saveDebugLogsInDataBase:dataObject uniqueId:[[ce userInfo] objectForKey:@"Key"] count:arrayV.count];
    
    NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
    NSString *mediaPath;
    if([dataObject.msgType isEqualToString:@"TIXX"] || [dataObject.msgType isEqualToString:@"XIXX"]){
        NSString *str1= [str stringByAppendingString:@".png"];
        mediaPath = [self saveDataToFile:dataObject.imgData withFileName:str1];
    }
    else if([dataObject.msgType isEqualToString:@"TGXX"] || [dataObject.msgType isEqualToString:@"XGXX"]){
        NSString *str1= [str stringByAppendingString:@".gif"];
        //  gifData = decodedImageData;
        mediaPath = [self saveDataToFile:dataObject.imgData withFileName:str1];
    }
    else if([dataObject.msgType isEqualToString:@"TXXX"]){
        mediaPath = @"";
    }
    else
    {
        mediaPath = @"";
        NSLog(@"Something is wrong as did not get the proper message Type");
        return;
    }
    
    dataObject.mediaPath =  mediaPath;
    
    int channelIdd = [dataObject.channelID intValue];
    NSString *chnnlId  = [NSString stringWithFormat:@"%d",channelIdd];
    
    Channels *channel = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:chnnlId];
    NSString *contentIDValue = content_ID;
    int cid_lenght = (int)contentIDValue.length;
    
    for (int i = cid_lenght; i < 6; i++) {
        
        contentIDValue  = [@"0" stringByAppendingString:contentIDValue];
    }
    
    if (contentIDValue.length>6) {
        int x =  contentIDValue.length-6;
        contentIDValue = [contentIDValue substringWithRange:NSMakeRange(x, contentIDValue.length-x)];
    }
    
    //category_id
    dataObject.contentID = contentIDValue;
    channelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:dataObject.msgType,@"mediaType",dataObject.contentID,@"content_id",dataObject.textMessage,@"text",dataObject.appDisplayTime, @"duration",chnnlId,@"channelId", [NSString stringWithFormat:@"%@",dataObject.pushTimeStamp],@"created_time",[NSNumber numberWithBool:dataObject.isForeverFeed],@"isForeverFeed",[NSNumber numberWithBool:YES],@"feed_Type",dataObject.mediaPath,@"mediaPath",nil];
    
    sleep(1);
    
    NSArray *totalChannelContentTemp = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", chnnlId] descr:nil  isDistinctResults:NO];
    globalVal = [totalChannelContentTemp count] + 1;
    [[NSUserDefaults standardUserDefaults]setInteger:globalVal forKey:k_GlobalValue];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // First need to check same shout id already exist in database or not
    // If exist exit the code
    // If not exist Save in data base
    
    if ([contentIDValue intValue] == 0) {
        DLog(@"Content Id is %@",content_ID);
        return;
    }
    
    __block BOOL isNewData = NO;
    
    [AppManager toCheckDuplicateContent:contentIDValue EntityName:kEntityForChannelFeed Attribute_key_Id:kAttributeOfChannelFeedForContent_Id CompletionBlock:^(BOOL success) {
        
        if (!success) {
            
            // New contents
            // save in data base
            isNewData = YES;
            DLog(@"New Contents as Content id is %@",content_ID);
            
        }
    }];
    
    
    if (!isNewData)//[AppManager toCheckDuplicateContent:content_ID EntityName:kEntityForChannelFeed Attribute_key_Id:kAttributeOfChannelFeedForContent_Id])
    {
        // duplicate contents
        // Do not save in data base
        // Just ignore the content as it is already shown
        NSArray *arr;
        arr = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"contentId = \"%@\"",dataObject.contentID] descr:nil isDistinctResults:YES];
        if(arr.count>0)
        {
            ChannelDetail *channelDetails = [arr objectAtIndex:0];
            DLog(@"Duplicate Contents as Content id is %@",content_ID);
            channelDetails.created_time = [NSNumber numberWithInteger:[dataObject.pushTimeStamp integerValue]];
            [DBManager save];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_tableChannel reloadData];
                
            });
        }
        return;
    }
    else{
        // New contents
        // save in data base
        NSNumber *number = [NSNumber numberWithInteger:channel.contentCount.integerValue];
        int value = [number intValue];
        number = [NSNumber numberWithInt:value + 1];
        channel.contentCount = number;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_collectionChannel reloadData];
            
        });
        DLog(@"New Contents as Content id is %@",content_ID);
    }
    
    ChannelDetail *channelD = [ChannelDetail addChannelContentWithDict:channelDict tempId:globalVal];
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    
    DLog(@"channels %@",channel);
    
    // fetch the data for channe;
    NSArray *dataOfParticularChannl =  [DBManager getChannelDataFromNameAndId:chnnlId isName:YES Network:net];
    
    NSString *channelName;
    
    DLog(@"Info for the channel is %@",dataOfParticularChannl);
    
    if (dataOfParticularChannl.count>0)
    {
        Channels *channel = [dataOfParticularChannl objectAtIndex:0];
        channelName = channel.name;
    }else
        return;
    
    [DBManager save];
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    //if app is in background and user is open the app by taping on app icon then it should display the badge icon on group cell UI, BUT NOT SHOW BANNERALERT >> ALOK
    NSDictionary* userInfo = @{kShouldShowBanner: [NSNumber numberWithBool:0]};
    
    if(state != UIApplicationStateBackground) {
        BOOL showBanner = [PrefManager isNotfOn];
        if(showBanner){
            userInfo = @{kShouldShowBanner: [NSNumber numberWithBool:1]};
            
        }
        else{
            userInfo = @{kShouldShowBanner: [NSNumber numberWithBool:0]};
            
        }
        // insert shout to DB
        dispatch_async(dispatch_get_main_queue(), ^{
            if([_myChannel.channelId isEqualToString:chnnlId] && ([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]]))
            {
                NSString *str;
                if ([dataObject.textMessage isEqualToString:@""]) {
                    str = @"Media file Received";
                }else
                    str =  dataObject.textMessage;
                
                if([PrefManager isNotfOn])
                {
                    UIView *vv = [[AppManager appDelegate] window];
                    NSString *customMsg = [NSString stringWithFormat:@"%@ %@ %@",dataObject.bleCustomAlert,GOTO,channel.name];
                    [BannerAlert showOnView:vv WithName:@"  " text:customMsg
                                      image:nil withUniqueId:nil shout:nil];
                    
                    [BannerAlert sharedBaner].bannerData = [NSString stringWithFormat:@"%@%@%@ Channel",[NSString stringWithFormat:@"%@:%@:",kKeyToShowDataInNotifForChannel,channelName],str,@""];
                }
                [_tableChannel reloadData];
            }
            else if (![self isKindOfClass:[ChanelViewController class]] || ![_myChannel.channelId isEqualToString:chnnlId])
            {
                NSString *str;
                if ([dataObject.textMessage isEqualToString:@""]) {
                    str = @"Media file Received";
                }else
                    str =  dataObject.textMessage;
                
                if([PrefManager isNotfOn])
                {
                    UIView *vv = [[AppManager appDelegate] window];
                    
                    NSString *customMsg = [NSString stringWithFormat:@"%@ %@ %@ Channel",dataObject.bleCustomAlert,GOTO,channel.name];
                    [BannerAlert showOnView:vv WithName:@"  " text:customMsg
                                      image:nil withUniqueId:nil shout:nil];
                    
                    [BannerAlert sharedBaner].bannerData = [NSString stringWithFormat:@"%@%@%@",[NSString stringWithFormat:@"%@:%@:",kKeyToShowDataInNotifForChannel,channelName],str,@""];
                }
            }
            else
            {
                NSString *str;
                if ([dataObject.textMessage isEqualToString:@""]) {
                    str = @"Media file Received";
                }else
                    str =  dataObject.textMessage;
                
                if([PrefManager isNotfOn])
                {
                    UIView *vv = [[AppManager appDelegate] window];
                    NSString *customMsg = [NSString stringWithFormat:@"%@ %@ %@ Channel",dataObject.bleCustomAlert,GOTO,channel.name];
                    [BannerAlert showOnView:vv WithName:@"  " text:customMsg
                                      image:nil withUniqueId:nil shout:nil];
                    
                    [BannerAlert sharedBaner].bannerData = [NSString stringWithFormat:@"%@%@%@",[NSString stringWithFormat:@"%@:%@:",kKeyToShowDataInNotifForChannel,channelName],str,@""];
                    
                }
                
                [_tableChannel reloadData];
            }
        });
    }
    else
    {
        if([PrefManager isNotfOn]) {
            // fire local notification (log will not work).
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            notif.alertAction = @"view";
            if ([chnnlId isKindOfClass:[NSNull class]] || [chnnlId isEqualToString:@""] || chnnlId == nil) {
                channelName = @"Unknown";
            }
            //else
            //channelName = chnnlId;
            NSString *customMsg = [NSString stringWithFormat:@"%@ %@ %@ Channel",dataObject.bleCustomAlert,GOTO,channel.name];
            if ([dataObject.msgType isEqualToString:@"TXXX"])
            {
                notif.alertBody = customMsg;//[NSString stringWithFormat:@"%@:%@:%@",kKeyToShowDataInNotifForChannel,channelName, k_TextFileReceived];
            }
            else if ([dataObject.msgType isEqualToString:@"XIXX"] || [dataObject.msgType isEqualToString:@"XGXX"])
            {
                notif.alertBody = customMsg;//[NSString stringWithFormat:@"%@:%@:%@",kKeyToShowDataInNotifForChannel,channelName, k_MediaFileReceived];
            }
            else
            {
                notif.alertBody = customMsg;//[NSString stringWithFormat:@"%@:%@:%@",kKeyToShowDataInNotifForChannel,channelName, k_TextFileReceived];
            }
            
            NSString *str;
            if ([dataObject.textMessage isEqualToString:@""]) {
                str = @"Media file Received";
            }else
                str =  dataObject.textMessage;
            
            NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@%@%@",[NSString stringWithFormat:@"%@:%@:",kKeyToShowDataInNotifForChannel,channelName],str,@""], @"Msg", nil];
            
            notif.userInfo = userDict;
            if([PrefManager isNotfOn])
            {
                notif.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
                Global *shared = [Global shared];
                NSInteger unreadShoutsCount = [DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id];
                NSInteger unreadContents = [DBManager getUnreadChannelContentCount];
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(unreadShoutsCount + unreadContents)];
            }
        }
    }
    //mediaPath = nil;
    [channelContent addObject:channelD];
    
    //EventLog To be Taken
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content_ID,@"channelContentId",chnnlId,@"channelId",dataObject.textMessage,@"text",nil];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_receiving_channelcontent_fromBLE",@"log_sub_category",chnnlId,@"category_id",contentIDValue,@"channelContentId",dataObject.textMessage,@"text",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]]) {
            
            [_tableChannel reloadData];
        }
    });
}

-(void)goToChannelScreen:(NSDictionary *)dic isFromBackground:(BOOL)isBackground
{
    NSMutableArray *arr;
    NSInteger index;
    index = 0;
    arr=nil;
    arr= [[ NSMutableArray alloc]init];
    
    NSArray *allVc;
    if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
    {
        if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
        {
            
            if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                
                if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                    
                    
                    allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                    if (allVc.count>0) {
                        
                    }else
                        return;
                }
                else
                {
                    DLog(@"Not a navigation controller");
                    
                    return;
                }
            }else
            {
                DLog(@"If content view controller not exist");
                
                return;
            }
        }else{
            
            DLog(@"Root view controller is not REFrosted view controller");
            return;
        }
    }
    
    [arr addObjectsFromArray:allVc];
    BOOL isBreak = false;
    for (ChanelViewController *vcx in arr){
        if([vcx isKindOfClass:[ChanelViewController class]]){
            index = [arr indexOfObject:vcx];
            if(index != 0)
            {
                [arr removeObjectAtIndex:index];
                isBreak = YES;
            }
            break;
        }
    }
    if (index <= arr.count)
    {
        if (allVc.count>=index && allVc.count==0) {
            return;
        }
        if (isBreak) {
            ChanelViewController *vc = [allVc objectAtIndex:index];
            [self.navigationController popToViewController:vc animated:YES];
        }
        else
        {
            ChanelViewController *vc = [allVc objectAtIndex:index];
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
    else if(!isBreak)
    {
        UIViewController *vc  = self.navigationController.topViewController;
        
        if ([vc isKindOfClass:[ChanelViewController class]]){}
        else
        {
            if(index <= allVc.count && allVc.count==0)
            {
                ChanelViewController *vc = [allVc objectAtIndex:index];
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }
    NSString *channelName;
    if(!isBackground || isBackground)
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
    
    if (dataOfParticularChannl.count>0)
    {
        Channels *channel = [dataOfParticularChannl objectAtIndex:0];
        channelID = channel.channelId;
    }
    else
        return;
    
    for(Channels *ch in channels)
    {
        if([ch.channelId intValue] ==[channelID intValue]){
            [refreshControl endRefreshing];
            [App_delegate.downloadQueue cancelAllOperations];
            selectedChannelIndex = [channels indexOfObject:ch];
            [self scrollCollectionToIndex];
            [self setMyChannel:ch];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collectionChannel reloadData];
                [_tableChannel reloadData];
            });
            break;
        }
    }
    // download content API
    [self getPrivateContentAPI];
}

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict
{
    // check owner
    Group *gr = sht.group;
    CommsViewController *gvc = nil;
    ReplyViewController *rvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[ReplyViewController class]])//crash fix , please dont remove this code
    {}
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
    }
}
#pragma mark- ReportContentAction

-(void)deleteContent:(UIButton*)btn{
    
    NSArray *totalChannelContent ;//= [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", _myChannel.channelId] descr:[NSSortDescriptor sortDescriptorWithKey:@"received_timeStamp" ascending:NO] isDistinctResults:YES];
    
    totalChannelContent = [_detailsOfChannel copy];
    
    ChannelDetail *c = [totalChannelContent objectAtIndex:btn.tag];
    reportedContentId = c.contentId.integerValue;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Content" message:@"Do you want to mark this content as abusive/inappropriate?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        
        [LoaderView addLoaderToView:self.view];
        
        [self reportContentToAdmin];
        c.toBeDisplayed = NO;
        
        [DBManager save];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableChannel reloadData];
            [LoaderView removeLoader];
        });
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)reportContentToAdmin{
    
    int timeStamp = (int)[TimeConverter timeStamp];
    
    
    NSString *contentId = [NSString stringWithFormat:@"%ld",(long)reportedContentId];
    
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.loud_hailerid,@"loudhailer_id",_myChannel.channelId,@"channel_id",contentId,@"content_id",nil];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",contentId],@"channelContentId",_myChannel.channelId,@"channelId",@"offendedcontent",@"text",nil];
    
    NSMutableDictionary *postDictionary1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_report_content",@"log_sub_category",_myChannel.channelId,@"channelId",[NSString stringWithFormat:@"%@",contentId],@"channelContentId",@"offendedcontent",@"text",_myChannel.channelId,@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary1];
    if ([AppManager isInternetShouldAlert:YES])
    {
        [sharedUtils makePostCloudAPICall:postDictionary andURL:REPORT_CHANNEL_CONTENT];
    }
}

-(void)showBadgeonChannel:(NSInteger)badge{
    NSIndexPath *indp = [NSIndexPath indexPathForRow:selectedChannelIndex inSection:0];
    toShowBadge = YES;
    [_collectionChannel reloadItemsAtIndexPaths:[NSArray arrayWithObject:indp]];
}

- (void)shoutEncounteredHere:(NSNotification *)notification
{
    if (!isLoggedIn) {
        return;
    }
    BOOL isActiveGroup =  NO;
    Shout *sh = (Shout *) [notification object];
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    NSString *str = [[NSUserDefaults standardUserDefaults]valueForKey:k_ShoutEncountered];
    if([str isEqualToString:[sh.timestamp stringValue]]){
        [self checkCountOfShouts];
    }
    else{
        NSArray *allVc ;//= [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
        if([UIApplication sharedApplication].delegate.window.rootViewController != nil)
        {
            if([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[REFrostedViewController class]])
            {
                
                if ([((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController]) {
                    
                    if ([[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] isKindOfClass:[UINavigationController class]]) {
                        
                        
                        allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
                        if (allVc.count>0) {
                            
                        }else
                            return;
                    }
                    else
                    {
                        DLog(@"Not a navigation controller");
                        return;
                    }
                }else
                {
                    DLog(@"If content view controller not exist");
                    return;
                }
            }else{
                DLog(@"Root view controller is not REFrosted view controller");
                return;
            }
        }
        
        BOOL isNeedToSHowBanner = NO;
        UIViewController *tempVC;
        for(UIViewController *vc in allVc)
        {
            if([vc isKindOfClass: [CommsViewController class]])
            {
                tempVC = vc;
                CommsViewController *cVc = (CommsViewController *) vc;
                BOOL isActiveGr = [cVc.myGroup.grId isEqualToString:sh.group.grId];
                if (isActiveGr)
                {
                    // notify this class.
                    isActiveGroup = YES;
                    [cVc recievedShout:sh];
                    isNeedToSHowBanner = NO;
                    if(state == UIApplicationStateBackground){
                        sh.group.totShoutsReceived = [NSNumber numberWithInt:([ sh.group.totShoutsReceived intValue] +1)];
                        [DBManager save];
                    }
                    return;
                }else{
                    isActiveGroup = NO;
                    isNeedToSHowBanner = YES;
                }
            }
            else if([vc isKindOfClass: [ReplyViewController class]])
            {
                tempVC = vc;
                ReplyViewController *cVc = (ReplyViewController *) vc;
                BOOL isActiveGr = [cVc.myGroup.grId isEqualToString:sh.group.grId];
                if (isActiveGr)
                {
                    // notify this class.
                    isActiveGroup = YES;
                    [cVc recievedReplyShout:sh];
                    isNeedToSHowBanner = NO;
                    return;
                }
                else
                {
                    isActiveGroup = NO;
                    isNeedToSHowBanner = YES;
                }
            }
            else if([vc isKindOfClass: [MessagesViewController class]]){
                tempVC = vc;
                isNeedToSHowBanner = YES;
            }
            else if([vc isKindOfClass: [NotificationViewController class]]){
                tempVC = vc;
                isNeedToSHowBanner = YES;
            }
            else if([vc isKindOfClass: [SonarViewController class]]){
                tempVC = vc;
                isNeedToSHowBanner = YES;
            }
            else if([vc isKindOfClass: [SettingsViewController class]]){
                tempVC = vc;
                isNeedToSHowBanner = YES;
            }
            else{
                tempVC = vc;
            }
        }
        if([tempVC isKindOfClass: [ReplyViewController class]] || [tempVC isKindOfClass: [CommsViewController class]]){
            isNeedToSHowBanner = NO;
        }
        if(!isActiveGroup && [tempVC isKindOfClass: [CommsViewController class]]){
            isNeedToSHowBanner = YES;
            sh.group.totShoutsReceived = [NSNumber numberWithInt:([ sh.group.totShoutsReceived intValue] +1)];
            [DBManager save];
            [self checkCountOfShouts];
        }
        else{
            if(tempVC!=nil){
                sh.group.totShoutsReceived = [NSNumber numberWithInt:([ sh.group.totShoutsReceived intValue] +1)];
                [DBManager save];
                [self checkCountOfShouts];
                isNeedToSHowBanner = YES;
            }
        }
        // show banner..
        //if condition: if app is in background and user is open the app by taping on app icon then it should display the badge icon on group cell UI, BUT NOT SHOW BANNERALERT >> ALOK
        if ([[notification.userInfo  objectForKey:kShouldShowBanner] boolValue] == TRUE)
        {
            if(isNeedToSHowBanner && ([tempVC isKindOfClass: [CommsViewController class]]) && !isActiveGroup){
                
                tempVC = nil;
                UIView *vv = [[AppManager appDelegate] window];
                [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text
                                  image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
            }
            else if(isNeedToSHowBanner && ([tempVC isKindOfClass: [MessagesViewController class]] || [tempVC isKindOfClass:[NotificationViewController class]] || [tempVC isKindOfClass:[SonarViewController class]])){
                tempVC = nil;
                UIView *vv = [[AppManager appDelegate] window];
                [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text
                                  image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
            }
            else if (isNeedToSHowBanner && !([tempVC isKindOfClass: [ReplyViewController class]] || [tempVC isKindOfClass: [CommsViewController class]]) && (tempVC != nil)) {
                tempVC = nil;
                UIView *vv = [[AppManager appDelegate] window];
                [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text
                                  image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults]setValue:[sh.timestamp stringValue] forKey:k_ShoutEncountered];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark- CopyTextLogs
-(void)copyToClip
{
    NSString *copyClip;
    if ([UIPasteboard generalPasteboard].hasURLs) {
        copyClip = [[UIPasteboard generalPasteboard].URL absoluteString];
        copyClip = [copyClip stringByReplacingOccurrencesOfString:@"%20" withString:@""];
    }
    else
    {
        copyClip = [UIPasteboard generalPasteboard].string;
    }
    NSString *temp = copyClip;
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSArray *totalChannelContent ;
    totalChannelContent = [_detailsOfChannel copy];
    
    ChannelDetail *c = [totalChannelContent objectAtIndex:selectedTextTag];
    
    selectedContentIndex = c.contentId.integerValue;
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",_myChannel.channelId,@"channelId",temp,@"text",nil];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_copy_text",@"log_sub_category",_myChannel.channelId,@"channelId",[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",temp,@"text",_myChannel.channelId,@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary];
}

#pragma mark- ExitFromChannelLogs
-(void)captureEventLogs
{
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"leave_channels",@"text",nil];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_exit_channels",@"log_sub_category",@"leave_channels",@"text",@"",@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary];
}

-(void)moveToChannelScreen:(NSString *)channelIDValue
{
    DLog(@"Channel ID is %@",channelIDValue);
    
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    if ([_myChannel.channelId  isEqualToString:channelIDValue]) {
        [self getPrivateContentAPI];
        return;
    }else
    {
        NSArray *dataOfParticularChannl =  [DBManager getChannelDataFromNameAndId:channelIDValue isName:YES Network:net];
        NSString *channelID;
        if (dataOfParticularChannl.count>0)
        {
            Channels *channel = [dataOfParticularChannl objectAtIndex:0];
            channelID = channel.channelId;
        }
        else
            return;
        
        @try {
            channels = [channels sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
        } @catch (NSException *exception) {
            
        } @finally {}
        for(Channels *ch in channels)
        {
            if([ch.channelId intValue] ==[channelID intValue]){
                selectedChannelIndex = [channels indexOfObject:ch];
                [self scrollCollectionToIndex];
                [self setMyChannel:ch];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_collectionChannel reloadData];
                    [_tableChannel reloadData];
                });
                break;
            }
        }
    }
    [self getPrivateContentAPI];
}


#pragma mark- PUSH notification handling

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

-(void)deleteContentOverBLE:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableChannel reloadData];
    });
    
    // #!DELETE-000011!#
    DLog(@"Delete Notification dictionary is %@",[notification userInfo]);
    
    if([[notification userInfo] objectForKey:kDeletePacket] )
    {
        NSString *deleteString = [[NSString alloc] initWithData:[[notification userInfo] objectForKey:kDeletePacket] encoding:NSUTF8StringEncoding];
        
        if (deleteString.length>16) {
            
            NSString *contentIDValue = [deleteString substringWithRange:NSMakeRange(9,4)] ;
            
            NSString *contentID = contentIDValue;
            int cid_lenght = (int)contentID.length;
            
            for (int i = cid_lenght; i < 6; i++) {
                
                contentID  = [@"0" stringByAppendingString:contentID];
            }
            
            NSString *activeNetId = [PrefManager activeNetId];
            Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
            if (net != nil) {
                NSArray *channelArray = [DBManager  getChannelDataFromFromContentID:[NSString stringWithFormat:@"%@",contentID] Network:net];
                
                
                @try {
                    channelArray = [channelArray sortedArrayUsingDescriptors:@[[self sortDescriptor]]];
                } @catch (NSException *exception) {
                } @finally {}
                
                
                if (channelArray.count>0)
                {
                    __block ChannelDetail *channelDetails;
                    [channelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        // Channel exist for current content id
                        DLog(@"Channel informations related to delete packet and content id %@ %@",channelArray,contentID);
                        // delete the content form the channel content
                        channelDetails = [channelArray objectAtIndex:idx];
                        
                        [DBManager deleteOb:channelDetails];
                        
                        if (channelDetails==nil) {
                            return;
                        }
                        
                        if ([channelDetails.channelId isEqualToString:_myChannel.channelId])
                        {
                            // reload the table afte deleting the data so it will reflect at the same time
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_tableChannel reloadData];
                            });
                        }
                        else
                        {
                            // reload the table afte deleting the data so it will reflect at the same time
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_tableChannel reloadData];
                            });
                        }
                    }];
                }
                else
                {
                    NSLog(@"No channel existed for current delete packet having id content id - %@",contentID);
                }
            }
        }
    }
}


-(void)refreshTableView:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_tableChannel reloadData];
        
    });
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

-(void)showChannelDataViaPush:(NSNotification *)ce
{
    NSString *trimmed  =  [[[[NSString stringWithFormat:@"%@",[[ce userInfo] objectForKey:@"Data"]] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] copy];
    
    NSString *hexfffString = [[trimmed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableString *string = [[NSMutableString alloc] init];
    int i = 0;
    unsigned long y = hexfffString.length/40;
    
    for (i=0; i<=y; i++) {
        
        NSString *ff;
        if (i == y) {
            ff = [hexfffString substringWithRange:NSMakeRange(i*40, hexfffString.length-(i*40))];
        }
        else
        {
            ff  = [hexfffString substringWithRange:NSMakeRange(i*40, 40)];
        }
        if (i ==0) {
            
            [string appendString:[ff substringWithRange:NSMakeRange(28, 12)]];
            
        }else
        {
            [string appendString:[ff substringWithRange:NSMakeRange(16, ff.length-16)]];
        }
    }
    
    DLog(@"data string +++ %@",string);
    
    NSString *hexString = string;
    NSDateFormatter *dateFormatterb = [[NSDateFormatter alloc] init];
    [dateFormatterb setDateFormat:@"HH:mm:ss.SSS"];
    
    NSData *datafromHexString =  [AppManager dataFromHexString:hexString];
    
    NSString *resultingStringForContent_ID = [[NSString alloc] initWithData:datafromHexString encoding:NSUTF8StringEncoding];
    NSString *resultingString = [resultingStringForContent_ID substringWithRange:NSMakeRange(6, resultingStringForContent_ID.length-6)];
    //  NSString *begTxt = [resultingString substringToIndex:3];
    
    if (resultingString.length<55) {
        return;}
    
    NSString *content_ID = [[ce userInfo] objectForKey:@"Key"];
    DLog(@"Content_Id %@",content_ID);
    
    NSString *channelID = [resultingString substringWithRange:NSMakeRange(3, 4)];
    DLog(@"channelID %@",channelID);
    
    NSString *extraBytes  = [resultingString substringWithRange:NSMakeRange(7, 6)];
    
    NSString *shoutId = [resultingString substringWithRange:NSMakeRange(13, 4)];
    DLog(@"shout id is %@",shoutId);
    
    NSString *appDisplayTime = [resultingString substringWithRange:NSMakeRange(17, 6)];
    DLog(@"appDisplayTime %@",appDisplayTime);
    
    NSString *msgType = [resultingString substringWithRange:NSMakeRange(23, 4)];
    DLog(@"msg type is  %@",msgType);
    
    NSString *msgl = [resultingString substringWithRange:NSMakeRange(27, 28)];
    DLog(@"msg length is  %@",msgl);
    NSString *textL=  [msgl substringToIndex:7];
    NSString *actualTxtL = [NSString stringWithFormat:@"%d", [textL intValue]];
    
    NSString *imageL= [msgl substringWithRange:NSMakeRange(7, 7)];
    NSString *actualImgL = [NSString stringWithFormat:@"%d", [imageL intValue]];
    
    NSString *audioL= [msgl substringWithRange:NSMakeRange(14, 7)];
    NSString *actualAudioL = [NSString stringWithFormat:@"%d", [audioL intValue]];
    
    NSString *videoL= [msgl substringWithRange:NSMakeRange(21, 7)];
    NSString *actualVideoL = [NSString stringWithFormat:@"%d", [videoL intValue]];
    
    if (!(resultingString.length >  ([actualTxtL integerValue] + [actualImgL integerValue] + [actualAudioL integerValue] + [actualVideoL integerValue]))) {
        return;
    }
    
    NSString *decodedText = [resultingString substringWithRange:NSMakeRange(55, [actualTxtL integerValue])];
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:decodedText options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    DLog(@"%@", decodedString);
    
    NSString *EOMSTR = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]), 3)];
    
    int valueToKnowTheTypeOfContent = 1;
    
    NSString *mediaPath;
    //  1  = text and image together
    //  2  = Text and Gif together
    
    if(![EOMSTR isEqualToString:@"EOM"])
    {
        if (resultingString.length >=55+[actualTxtL integerValue]+[actualImgL integerValue]+3)
        {
            //Image
            NSString *decodedImageText = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]), [actualImgL integerValue])];
            NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:decodedImageText options:0];
            
            image = [UIImage imageWithData:decodedImageData];
            
            NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
            
            if([msgType isEqualToString:@"TIXX"] || [msgType isEqualToString:@"XIXX"]){
                NSString *str1= [str stringByAppendingString:@".png"];
                mediaPath = [self saveDataToFile:decodedImageData withFileName:str1];
                valueToKnowTheTypeOfContent  =2;
            }
            else if([msgType isEqualToString:@"TGXX"] || [msgType isEqualToString:@"XGXX"])
            {
                NSString *str1= [str stringByAppendingString:@".gif"];
                //  gifData = decodedImageData;
                mediaPath = [self saveDataToFile:decodedImageData withFileName:str1];
                valueToKnowTheTypeOfContent  =2;
            }
        }
    }
    else
    {
        valueToKnowTheTypeOfContent = 1;
    }
    
    if (resultingString.length >=55+[actualTxtL integerValue]+[actualImgL integerValue]+3) {
        
        NSString *EOMSTR1 = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]), 3)];
        
        if(![EOMSTR1 isEqualToString:@"EOM"])
        {
            //Audio
            NSString *decodedAudioText = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]), [actualAudioL integerValue])];
            
            NSData *decodedAudioData = [[NSData alloc] initWithBase64EncodedString:decodedAudioText options:0];
            NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
            NSString *str1= [str stringByAppendingString:@".m4a"];
            mediaPath = [self saveDataToFile:decodedAudioData withFileName:str1];
        }
    }
    
    if (resultingString.length >=55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]+3)
    {
        
        NSString *EOMSTR2 = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]), 3)];
        
        
        if(![EOMSTR2 isEqualToString:@"EOM"])
        {
            //Video
            NSString *decodedVideoText = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]), [actualVideoL integerValue])];
            
            NSData *decodedVideoData = [[NSData alloc] initWithBase64EncodedString:decodedVideoText options:0];
            NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
            NSString *str1= [str stringByAppendingString:@".mov"];
            mediaPath = [self saveDataToFile:decodedVideoData withFileName:str1];
        }
    }
    
    int channelIdd = [channelID intValue];
    NSString *chnnlId  = [NSString stringWithFormat:@"%d",channelIdd];
    
    Channels *channel = [DBManager entityWithStr:@"Channels" idName:@"channelId" idValue:chnnlId];
    
    NSString *contentIDValue = content_ID;
    int cid_lenght = (int)contentIDValue.length;
    
    for (int i = cid_lenght; i <= 6; i++) {
        
        contentIDValue  = [@"0" stringByAppendingString:contentIDValue];
    }
    
    channelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:msgType,@"mediaType",contentIDValue,@"content_id",decodedString,@"text",appDisplayTime, @"duration",chnnlId,@"channelId",mediaPath,@"mediaPath",nil];
    
    sleep(1);
    
    NSArray *totalChannelContentTemp = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", chnnlId] descr:nil  isDistinctResults:NO];
    globalVal = [totalChannelContentTemp count] + 1;
    [[NSUserDefaults standardUserDefaults]setInteger:globalVal forKey:k_GlobalValue];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // First need to check same shout id already exist in database or not
    // If exist exit the code
    // If not exist Save in data base
    
    if ([contentIDValue intValue] == 0) {
        DLog(@"Content Id is %@",content_ID);
        return;
    }
    
    __block BOOL isNewData = NO;
    
    [AppManager toCheckDuplicateContent:contentIDValue EntityName:kEntityForChannelFeed Attribute_key_Id:kAttributeOfChannelFeedForContent_Id CompletionBlock:^(BOOL success) {
        
        if (!success) {
            
            // New contents
            // save in data base
            isNewData = YES;
            DLog(@"In if of Show Data Via Push New Contents as Content id is %@",content_ID);
            
        }
    }];
    
    
    if (!isNewData)//[AppManager toCheckDuplicateContent:content_ID EntityName:kEntityForChannelFeed Attribute_key_Id:kAttributeOfChannelFeedForContent_Id])
    {
        // duplicate contents
        // Do not save in data base
        // Just ignore the content as it is already shown
        
        DLog(@"Duplicate Contents as Content id is %@",content_ID);
        return;
    }
    else{
        // New contents
        // save in data base
        NSNumber *number = [NSNumber numberWithInteger:channel.contentCount.integerValue];
        int value = [number intValue];
        number = [NSNumber numberWithInt:value + 1];
        channel.contentCount = number;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_collectionChannel reloadData];
            [_tableChannel reloadData];
            
            
        });
        DLog(@"In showChannelDataViaPush :New Contents as Content id is %@",content_ID);
    }
    
    ChannelDetail *channelD = [ChannelDetail addChannelContentWithDict:channelDict tempId:globalVal];
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    
    
    DLog(@"channels %@",channel);
    
    // fetch the data for channe;
    NSArray *dataOfParticularChannl =  [DBManager getChannelDataFromNameAndId:chnnlId isName:YES Network:net];
    
    NSString *channelName;
    
    DLog(@"Info for the channel is %@",dataOfParticularChannl);
    
    if (dataOfParticularChannl.count>0)
    {
        Channels *channel = [dataOfParticularChannl objectAtIndex:0];
        channelName = channel.name;
    }else
        return;
    
    [DBManager save];
    
    //mediaPath = nil;
    [channelContent addObject:channelD];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableChannel reloadData];
        [_collectionChannel reloadData];
        
    });
}

-(void)cancelAllOperationsQueue
{
    NSLog(@"Number of operations %lu",(unsigned long)[App_delegate.downloadQueue operationCount]);
    [App_delegate.downloadQueue cancelAllOperations];
    [App_delegate.downloadQueue setSuspended:YES];
    
    [[App_delegate.downloadQueue operations] enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSBlockOperation *blockOp = obj;
        
        [blockOp cancel];
        
    }];
    
    [sharedUtils cancelAllCurrentlyTask];
}

-(void)callMethod
{
    [[UIApplication sharedApplication] sendAction:@selector(xyz) to:self from:self forEvent:nil];
}

-(void)xyz
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"Top View controller  %@ %@",self.navigationController.topViewController,_tableChannel);
        [_tableChannel reloadData];
    });
}

-(NSSortDescriptor *)sortDescriptor
{
    NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"channelId" ascending:YES comparator:^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    return aSortDescriptor;
}


-(void)saveDebugLogsInDataBase:(ChannelDataClassInfo *)pckData uniqueId:(NSString *)uniqueID count:(int)packetCount
{
    DebugLogsInfo *object;// = [[DebugLogsInfo alloc] init];
    
    if(YES)
    {
        object =  [NSEntityDescription insertNewObjectForEntityForName:@"DubugLogs" inManagedObjectContext:[App_delegate xyz]];
    }
    object.messageType = @"CMS";
    // dataType
    
    object.numberOfPackets = [NSNumber numberWithInt:packetCount];
    object.typeOfData =  pckData.msgType;
    
    NSString *receiveStatus;
    receiveStatus = @"Receiving";
    object.event = @"Received Channel Data";
    // utc timestamp
    object.timeStamp =  [NSNumber numberWithInteger:[[AppManager timeStamp] integerValue]];
    // shout id of the message
    object.messageID =  @"";
    // group id of the message
    object.groupID   =  @"";
    
    // channel id of the message
    object.channelID =  pckData.channelID;
    
    NSMutableDictionary *deviceDict = [self deviceIdOfDevices];
    
    if([deviceDict objectForKey:@"Device1"])
    {
        object.deviceID1 = [deviceDict objectForKey:@"Device1"];
    }else
    {
        object.deviceID1 = @"";
    }
    
    if([deviceDict objectForKey:@"Device2"])
    {
        object.deviceID2 = [deviceDict objectForKey:@"Device2"];
    }else
    {
        object.deviceID2 = @"";
    }
    
    if([deviceDict objectForKey:@"Device3"])
    {
        object.deviceID3 = [deviceDict objectForKey:@"Device3"];
    }else
    {
        object.deviceID3 = @"";
    }
    
    if([deviceDict objectForKey:@"BukiBox"])
    {
        object.bukiBoxID = [deviceDict objectForKey:@"BukiBox"];
    }else
    {
        object.bukiBoxID = @"";
    }
    
    if([deviceDict objectForKey:@"Mode"])
    {
        if([[deviceDict objectForKey:@"Mode"] intValue] == 0)
        {
            object.deviceRole = @"Master";
        }else
        {
            object.deviceRole = @"Slave";
        }
    }
    else
    {
        object.deviceRole = @"";
    }
    
    // save the data base
    object.msgUniqueID =  uniqueID;
    
    //to save the data
    [DBManager save];
}

-(NSMutableDictionary *)deviceIdOfDevices
{
    NSMutableArray *centralDevices    = [[NSMutableArray alloc] init];
    NSMutableArray *periPheralDevices = [[NSMutableArray alloc] init];
    NSMutableDictionary *deviceDictionary       = [[NSMutableDictionary alloc] init];
    centralDevices = [[BLEManager sharedManager].centralM.connectedDevices copy];
    
    periPheralDevices =  [[BLEManager sharedManager].perM.connectedCentrals copy];
    
    if(periPheralDevices != nil && (centralDevices != nil))
    {
        if([periPheralDevices count] ==0 && [centralDevices count] >0)
        {
            
            if([periPheralDevices count] > 0 && [centralDevices count] ==0)
            {
                
                [periPheralDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    CBCentral *central = [obj objectForKey:Central_Ref];
//                    DLog(@"Central Name %@",central.name);
                    
                    if([obj objectForKey:@"Adv_Data"])
                    {
                        NSString *str = [NSString stringWithFormat:@"%@%lu",[obj objectForKey:@"Adv_Data"],(unsigned long)idx];
                        [deviceDictionary setObject:[obj objectForKey:@"Adv_Data"] forKey:str];
                    }
                }];
                [deviceDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Mode"];
                
            }
            else if([periPheralDevices count] == 0 && [centralDevices count] >0)
            {
                
                [centralDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    CBPeripheral *peri = [obj objectForKey:Peripheral_Ref];
                    DLog(@"Peripheral Name %@",peri.name);
                    
                    if(([peri.name hasPrefix:@"iP"] || ([peri.name hasPrefix:@"M0000"])) && (peri.state == 2)) {
                        
                        if([obj objectForKey:@"Adv_Data"])
                        {
                            NSString *str = [NSString stringWithFormat:@"%@%lu",[obj objectForKey:@"Adv_Data"],(unsigned long)idx];
                            [deviceDictionary setObject:[obj objectForKey:@"Adv_Data"] forKey:str];
                        }
                    }
                    else
                    {
                        if([obj objectForKey:@"Adv_Data"])
                        {
                            if([[obj objectForKey:@"Adv_Data"] hasPrefix:@"B000"])
                            {
                                [deviceDictionary setObject:[obj objectForKey:@"Adv_Data"] forKey:@"BukiBox"];
                            }
                        }
                    }
                }];
                [deviceDictionary setObject:[NSNumber numberWithInt:0] forKey:@"Mode"];
            }
        }
    }
    return deviceDictionary;
}

-(NSString *)convertToDateString:(NSNumber*)createdTime
{
    NSNumber *time1 = [NSNumber numberWithDouble:([createdTime doubleValue] - 3600)];
    NSTimeInterval interval = [time1 doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"dd-MM-yyyy"];
    return [dateformatter stringFromDate:date];
}

-(CGFloat)getTextviewHeightForText:(NSString *)text
{
    UITextView *txtvw= [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 375, 0)];
    [txtvw setFont:[UIFont fontWithName:@"Aileron-Regular" size:15]];
    txtvw.text = text;
    CGSize contentSize = txtvw.contentSize;
    
    int numberOfLinesNeeded = contentSize.height / txtvw.font.lineHeight;
    CGRect textViewFrame= txtvw.frame;
    textViewFrame.size.height = numberOfLinesNeeded * txtvw.font.lineHeight + 25   ;//
    return textViewFrame.size.height;
}

-(UIImage*)imageForChannelFeed:(ChannelDetail*)channel
{
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString* currentFile = [stringPath stringByAppendingPathComponent:[channel.mediaPath lastPathComponent]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
    UIImage *channelImage;
    if(fileExists){
        channelImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:currentFile]];
    }
    else{
        channelImage = [[SDImageCache sharedImageCache] diskImageForKey:channel.mediaPath];
    }
    return channelImage;
}

-(FLAnimatedImage*)animatedImageForChannelFeed:(ChannelDetail*)channel{
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString* currentFile = [stringPath stringByAppendingPathComponent:[channel.mediaPath lastPathComponent]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
    FLAnimatedImage *animatedImage;
    if (fileExists) {
        animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:currentFile]];
    }
    else{
        NSData *gifdata = [NSData dataWithContentsOfFile:channel.mediaPath];
        animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifdata];
    }
    return animatedImage;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollingFinish:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingFinish:scrollView];
}

- (void)scrollingFinish:(UIScrollView*)scrollView
{
    if(_allChannelView.hidden == NO)
    {
    //enter code here
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
        [self performSelector:@selector(refreshToGetMoreCounts) withObject:nil afterDelay:1];
    }
    }
    else
    {
        float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (endScrolling >= scrollView.contentSize.height)
        {
            [self performSelector:@selector(refreshToGetMoreFeeds) withObject:nil afterDelay:1];
        }
    }
}

-(void) cancelButtonAction{
    [self removeMoreViewWithAnimation];
}

-(void) doneButtonAction{
    [self removeMoreViewWithAnimation];
}

-(void)removeMoreViewWithAnimation{
    CGFloat height=0.0;
    if(IS_IPHONE_X){
        height = self.view.bounds.size.height-90;
    }
    else{
        height =  self.view.bounds.size.height-61.3;
    }
    isMoreClicked = NO;
    [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        moreView.frame = CGRectMake(0, -height, self.view.frame.size.width, height);
    } completion:^(BOOL finished) {
        [moreView removeFromSuperview];
    }];
}

-(void)coolForChannelDetail:(ChannelDetail*)channelDetail forTableViewCell:(ChannelDetailCell*)cell{
    if (channelDetail.cool == YES) {
        cell.coolView.accessibilityIdentifier=@"cool_Selected";
        cell.coolColorLabel.textColor = [UIColor colorWithRed:(229.0f/255.0f) green:(0.0f/255.0f) blue:(28.0f/255.0f) alpha:1.0];
    }
    else{
        cell.coolView.accessibilityIdentifier=@"cool_not_Selected";
        cell.coolColorLabel.textColor = [UIColor colorWithRed:(184.0f/255.0f) green:(184.0f/255.0f) blue:(184.0f/255.0f) alpha:1.0];
    }
    if(![channelDetail.coolCount isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        cell.coolNumberLabel.text = [NSString stringWithFormat:@"%@ Cool",channelDetail.coolCount];
    }
    else
        cell.coolNumberLabel.text = @"Cool";
}

-(void)contactForChannelDetail:(ChannelDetail*)channelDetail forTableViewCell:(ChannelDetailCell*)cell{
    if (channelDetail.contact == YES) {
        cell.contactView.accessibilityIdentifier=@"contact_Selected";
        cell.contactColorLabel.textColor = [UIColor colorWithRed:(245.0f/255.0f) green:(187.0f/255.0f) blue:(66.0f/255.0f) alpha:1.0];
    }
    else{
        cell.contactView.accessibilityIdentifier=@"contact_not_Selected";
        cell.contactColorLabel.textColor = [UIColor colorWithRed:(184.0f/255.0f) green:(184.0f/255.0f) blue:(184.0f/255.0f) alpha:1.0];
    }
    if(![channelDetail.contactCount isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        cell.contactNumberLabel.text = [NSString stringWithFormat:@"%@ Contact",channelDetail.contactCount];
    }
    else
        cell.contactNumberLabel.text = @"Contact";
}

-(void)getUserCityList{
    SharedUtils *sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate=self;
    NSMutableDictionary  *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",nil];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,kGetUserCity_List];
    [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
}

-(void)redirectToChannelScreen
{
    CGFloat height=0.0;
    if(IS_IPHONE_X){
        height = self.view.bounds.size.height-90;
    }
    else{
        height =  self.view.bounds.size.height-61.3;
    }
    isTitleClicked=NO;
    [UIView animateWithDuration:0.5 animations:^{
        customTitleView.frame = CGRectMake(0, -height, self.view.frame.size.width, height);
       [self viewWillAppear:NO];
    } completion:^(BOOL finished) {
        [customTitleView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CustomViewClose" object:nil];
    }];
}

@end
