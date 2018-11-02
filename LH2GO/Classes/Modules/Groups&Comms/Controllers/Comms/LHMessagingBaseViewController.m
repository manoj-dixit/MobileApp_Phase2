//
//  LHMessagingBaseViewController.m
//  LH2GO
//
//  Created by Kiwitech on 25/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHMessagingBaseViewController.h"
#import "ReplyViewController.h"
#import "ShoutCell.h"
#import "ShoutCellReceiverCell.h"
#import "LHBackupSessionInfoVC.h"
#import "ProfileViewController.h"
#import "DAKeyboardControl.h"
#import "AppManager.h"
#import "ShoutManager.h"
#import "BannerAlert.h"
#import "NSString+Extra.h"
#import "NSString+Addition.h"
#import "ImageOverlyViewController.h"
#import "LoaderView.h"
#import "BLEManager.h"
#import "MediaCommsViewController.h"
#import "LHAudioRecorder.h"
#import "LHVideoPlayer.h"
#import "LHAutoSyncing.h"
#import "CommsViewController.h"
#import "ImagePickManager.h"
#import "UIView+position.h"
#import "UIViewController+CommonActions.h"
#import "TimeConverter.h"
#import "AFAppDotNetAPIClient.h"
#import "GroupCollectionCell.h"
#import "EventLog.h"

#define k_FavToUnFav 10

@interface LHMessagingBaseViewController ()<ShoutCellDelegate,ShoutCellReceiverDelegate, UITextViewDelegate,UIAlertViewDelegate, UIActionSheetDelegate,APICallProtocolDelegate> {
    __weak IBOutlet UILabel     *_grpNmLbl;
    __weak IBOutlet UILabel     *_netNmLbl;
    __weak IBOutlet UIImageView *_txtInpbackImgV;
    __weak IBOutlet UIButton    *_speakerBtn;
    //new button
    __weak IBOutlet UIButton *shoutBtn;
    BOOL _shouldRefresh;     // network activation
    BOOL _isActiveNet;
    BOOL _isUp;
    
    NSInteger currentGroupId;
    NSInteger shoutIndex;
    NSInteger tagEventLog;
    NSString *eventLogVideoPath;
    NSString *eventLogAudioPath;
    NSString *commonUrl;
    NSString *eventLogImagePath;
    SharedUtils *sharedUtils;
    NSInteger selectedRow;
    NSMutableArray *actualShouts;
    NSMutableArray *nonNullShouts;
    NSInteger index1;
    BOOL  shouldUpdate;
}
- (void)setUpKeyboard;
- (void)checkActiveNetwork;

@end

@implementation LHMessagingBaseViewController
@synthesize selectedGroupIndex;
@synthesize myGroup = _myGroup;

#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    shouldUpdate =YES;
    index1 = 0;
    if(_shouts.count >0 ){
        if (_table.hidden == NO){
            dispatch_async(dispatch_get_main_queue(), ^{
                DLog(@"Reload data : viewWillAppear");
                [_table reloadData];
            });
        }

    }else{
        _table.hidden = NO;
    }
    
    if (_shouldRefresh)     [self checkActiveNetwork];
    if (_isActiveNet)       [self setUpKeyboard];
    if (_shouldReloadShout) {[self refreshShoutes:nil];
    }
    NSDictionary  *d = [_datasource objectAtIndex:0];
    NSArray *groups = [d objectForKey:@"groups"];
    NSSortDescriptor *sortDescriptor = nil;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                 ascending:YES];
    NSArray *arr = [groups sortedArrayUsingDescriptors:@[sortDescriptor]];

    __block BOOL isAvailable = false;
    __block NSUInteger index;
    [arr enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Group *gr = obj;
        if ([gr.grId integerValue] == _groupIdIS) {
            isAvailable = YES;
            index       = idx;
        }
    }];
    
    if (isAvailable) {
        selectedGroupIndex = index;
    }
    
    [self.navigationItem setRightBarButtonItems:nil];

    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"KY" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollNotif:) name:@"KY" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSuspend:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    shouldUpdate =NO;
    if (_isActiveNet) [self.view removeKeyboardControl];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"PauseAudioNotification"
     object:self];
   [[NSNotificationCenter defaultCenter]removeObserver:self name:UIPasteboardChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kActiveNetworkChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShoutDead object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


-(void)viewDidAppear:(BOOL)animated{
    if(_shouts.count >0 ){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_table reloadData];
        });

        _table.hidden = NO;
    }
}

- (void)viewDidLoad{
    shouldUpdate =NO;
    _table.hidden = YES;
    [super viewDidLoad];
    actualShouts = [NSMutableArray new];
    nonNullShouts = [NSMutableArray new];
    _speakerBtn.hidden = YES;
    shoutBtn.hidden = YES;
    grps = [NSArray new];
    CGRect camBtnframe = _camBtn.frame;
    camBtnframe.origin.x = 7;
    camBtnframe.origin.y = 15;
    camBtnframe.size.height = 20;
    camBtnframe.size.width = 25;
    _camBtn.frame =  camBtnframe;
    CGRect voiceBtnframe = _voiceBtn.frame;
    voiceBtnframe.origin.x = _camBtn.frame.size.width + 10;
    voiceBtnframe.origin.y = 15;
    voiceBtnframe.size.height = 20;
    voiceBtnframe.size.width = 20;
    _voiceBtn.frame =  voiceBtnframe;
    _shInputFld.text = @" start typing...";
    _shInputFld.textColor = [UIColor lightGrayColor];
    _shInputFld.dataDetectorTypes  = UIDataDetectorTypeAll;
    _sendButton.enabled = NO;
    _shInputFld.autocorrectionType = UITextAutocorrectionTypeNo;
    [[ShoutManager sharedManager] clearInProgressGarbageShoutes];
    _grpNmLbl.text = _myGroup.grName;
    _netNmLbl.text = _myGroup.network.netName;
    //by nim chat#3
    if ([_shInputFld.text isEqualToString:@" start typing..."]) {
        _shInputFld.text = @"";
    }
    _leftLbl.text  = [NSString stringWithFormat:@" %lu Left", (NSInteger)k_MAX_SHOUT_LENGTH - _shInputFld.text.length];
    [self checkActiveNetwork];
    [self sortShouts:nil];
    // network change notification..
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kActiveNetworkChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMe) name:kActiveNetworkChange object:nil];
    // new shout notification..
     [[NSNotificationCenter defaultCenter]removeObserver:self name:kShoutDead object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutDead:) name:kShoutDead object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (actualShouts.count > 1)
        {
            @try {
                
                [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:actualShouts.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES]; // by nim chat#3
                
                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    });
    
    [self checkIFNetworkIsActive];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackgroundNotificationOrBecomeActive:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackgroundNotificationOrBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UITapGestureRecognizer *gestureRecognizer = nil;
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [_table addGestureRecognizer:gestureRecognizer];
    [self gatherDatasource];
    
    groupsCount = [grps count];
    [self roundTextviewCorners];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIPasteboardChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyToClip) name:UIPasteboardChangedNotification object:nil];
    
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc]init];
    sharedUtils.delegate = self;
    
    //for resizing screen during calls
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kStatusBarWillChange object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kStatusBarWillChange) name:kStatusBarWillChange object:nil];

    //for keyboard up/down
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // new shout notification..
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounter object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrivedforComms:) name:kNewShoutEncounter object:nil];
}

- (void)shoutArrivedforComms:(NSNotification *)notification{
    if (shouldUpdate) {
        Global  *shared = [Global shared];
        [DBManager updateShoutsIsReadOnClickingMessages:self.myGroup.grId withUserID:shared.currentUser.user_id];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionGroup reloadData];
            [_table reloadData];
        });
    }
}

-(void)roundTextviewCorners{
//CAShapeLayer * maskLayer = [CAShapeLayer layer];
//maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _shInputFld.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: (CGSize){10.0, 10.}].CGPath;
//
//    _shInputFld.layer.mask = maskLayer;
    
    _viewForTextView.layer.cornerRadius = 10;
    _viewForTextView.clipsToBounds = YES;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)sortShouts:(Shout*)sh
{
    
    NSTimeInterval timeInMiliseconds;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    _shouts = nil;
    _totalShouts = nil;
    _cmsShouts = nil;
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];//original_timestamp
    
    NSArray *arr = self.myGroup.shouts.allObjects;
    _totalShouts = [arr sortedArrayUsingDescriptors:sortDescriptors];
    timeInMiliseconds = [[NSDate date] timeIntervalSince1970]-KCellFadeOutDuration;
   
    if(_totalShouts.count > 1){
        sh = _totalShouts[_totalShouts.count - 1];
    }
    else{
      
    }
    if(sh.isFromCMS && [sh.cmsTime intValue]>0){
        
        
        _cmsShouts = [_totalShouts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.pShId = nil AND SELF.cmsTime>%@ AND SELF.timestamp>%@", [NSNumber numberWithInteger:0],[NSNumber numberWithInteger:time]]];
        
        
    }
    else{
      
        
    }
       _shouts = [_totalShouts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.pShId = nil AND SELF.cmsTime=%@ AND SELF.timestamp>%@", [NSNumber numberWithInteger:0],[NSNumber numberWithInteger:timeInMiliseconds]]];
    
    
    
    if(_shouts != nil){
        _shouts = [_shouts arrayByAddingObjectsFromArray:_cmsShouts];
        
    }
    else if(_cmsShouts != nil){
        _shouts = [_cmsShouts arrayByAddingObjectsFromArray:_shouts];
        
    }
    else{
        
    }
    
    [actualShouts removeAllObjects];
    [actualShouts addObjectsFromArray:_shouts];
}

#pragma mark - Public methods

-(void)recievedShout:(Shout *)sh{
    UIViewController *vc1 = [self.navigationController topViewController];
    BOOL isOnTop = [vc1 isKindOfClass:[self class]];
    
    if(isOnTop) {
        NSInteger oldCount = _shouts.count;
        [self sortShouts:sh];
        // shout entered..
        if (sh.parent_shout)
            [self updateRowForObject:sh.parent_shout];
        else if(oldCount<_shouts.count){
            Shout *s = _shouts[_shouts.count - 1];
            if(s.reciever != nil){
            [self insertRowAtIndex:_shouts.count-1];
            }
        }
        else{
            [self updateRowForObject:sh];
        }
    } else {
        _shouldReloadShout = YES;
        UIViewController *vc1 = [self.navigationController topViewController];
        BOOL isOnTop = [vc1 isKindOfClass:[ReplyViewController class]];
        if(isOnTop&&sh.parent_shout) {
            ReplyViewController *tVc = (ReplyViewController*)vc1;
            [self updateRowForObject:sh.parent_shout];
            [tVc recievedReplyShout:sh];
        }
        else{
            // show banner.
            if(sh.owner.picUrl){}
            else{
                UIView *vv = [[AppManager appDelegate] window];
                
                [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
            }
        }
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:self.selectedGroupIndex inSection:0];
    NSUInteger numbers = [collectionGroup numberOfItemsInSection:0];
    if (numbers>=self.selectedGroupIndex)
    {
        @try {
            [collectionGroup scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        } @catch (NSException *exception) {
            DLog(@"Exception is %@",exception.description);
        } @finally {
            
        }
    }
}

#pragma mark - Notification methods

- (void)updateMe {
    _shouldRefresh = YES;
}

- (void)shoutDead:(NSNotification *)notification {
    // dead shout..
    Shout *sh = (Shout *) [notification object];
    if (sh == nil || ![sh.group.grId isEqualToString:_myGroup.grId]) return;
    
    
    UIViewController *vc1 = [self.navigationController topViewController];
    BOOL isOnTop = [vc1 isKindOfClass:[self class]];
    
    if(isOnTop) {
        [self removeShoutCellwithShoutInfo:sh];
    } else {
        _shouldReloadShout = YES;
    }
}
-(void)updateRefreshFlag:(BOOL)shouldRefresh
{
    _shouldReloadShout = shouldRefresh;
}

#pragma mark - Private methods
- (void)gatherDatasource
{
    [Global shared].isReadyToStartBLE = YES;
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
    _datasource = nets;
    
}

- (void)insertRowAtIndex:(NSInteger)indx {
    NSInteger count = _shouts.count;
    if(count == 0) return;
    // isReloadingTable=NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_table reloadData];
        
    });
    [self scrollUPAnimated:YES];

}

- (void)scrollUPAnimated:(BOOL)isAnimated
{
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        NSLog(@"Reload data : scrollUPAnimated");
//        [_table reloadData];
//    });
       // _table.backgroundColor = [UIColor blueColor];
    dispatch_async(dispatch_get_main_queue(), ^{
    if (_table.contentSize.height > _table.frame.size.height)
    {
        if(_shouts.count)
        {
            if(_isUp)
            {
                //commented for emoji
               /* if(IS_IPHONE_5)
                    [_table setFrame:CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width,190)];
                else if (IS_IPHONE_6 || IS_IPHONE_6_PLUS)
                    [_table setFrame:CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width,250)];
                else if (IS_IPAD_PRO_1024)
                {
                    [_table setFrame:CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width,420)];
                }
                            //  _table.backgroundColor = [UIColor cyanColor];
                
                _table.translatesAutoresizingMaskIntoConstraints = YES; // by nim chat#16*/
            }
            
                
                if (actualShouts.count > 1 ) {
                    
                    NSUInteger rows = [_table numberOfRowsInSection:0];

                    // if count is equal or greater the rows
                    if (actualShouts.count >= rows) {
                        
                        @try {
                            
                            [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:actualShouts.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES]; // by nim chat#3

                            
                        } @catch (NSException *exception) {
                            
                        } @finally {
                            
                        }
                        
                    }
                }
            }
    }
    });
}

- (void)updateRowForObject:(Shout*)sht {
    if (sht==nil) {
        return;
    }
    [self sortShouts:sht];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        DLog(@"Reload data : updateRowForObject");
        [_table reloadData];
        
      //  [self scrollUPAnimated:YES]; Moving it out of dispatch.
        
    });
    [self scrollUPAnimated:YES];

}

- (void)setUpKeyboard
{
    self.view.keyboardTriggerOffset = _bottomInpView.frame.size.height+ 5;
    __block int maxY = _bottomInpView.frame.origin.y;
    
    __weak typeof(UIView)      *messageV  = _bottomInpView;
    __weak typeof(UITableView) *tableV    = _table;
    __weak typeof(UITextView)  *inpF      = _shInputFld;
  //  __weak typeof(UIButton)     *sendBtn  = _sendButton;
    
    __weak typeof(LHMessagingBaseViewController *) cont = self;

    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        // Try not to call "self" inside this block (retain cycle).But if you do, make sure to remove DAKeyboardControl when you are done with the view controller by calling:
        // [self.view removeKeyboardControl];
        
        if (keyboardFrameInView.origin.y > maxY) {
            CGRect fr = messageV.frame;
            fr.origin.y = maxY;
            if (IS_IPAD_PRO_1024){
                fr.origin.y = maxY-48; // by nim chat#17
            }
            messageV.frame = fr;
            fr = tableV.frame;
            if (IS_IPAD_PRO_1024){
                fr.size.height = maxY-tableV.frame.origin.y;
            }
            tableV.frame = fr;

            
        }
        else
        {
            CGRect fr = messageV.frame;
            fr.origin.y = keyboardFrameInView.origin.y - fr.size.height;
            messageV.frame = fr;
            fr = tableV.frame;
            if (IS_IPAD_PRO_1024)
                fr.size.height = keyboardFrameInView.origin.y - fr.origin.y-messageV.frame.size.height; // removed 10 from here for resolving table issue in iPad
            else
                fr.size.height = keyboardFrameInView.origin.y - fr.origin.y-messageV.frame.size.height;

            tableV.frame = fr;
        }

        if(closing)
        {
            [tableV setFrame:CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, tableV.frame.size.height + 10)]; //+40
            if (IS_IPAD_PRO_1024)
            {
                [tableV setFrame:CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, 780)];
            //  [tableV setFrame:CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, tableV.frame.size.height + keyboardFrameInView.size.height-50)];//-50
            }
            else if(IS_IPHONE_X)
            {
                [tableV setFrame:CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, 540)];
            }
            else if (IS_IPHONE_6_PLUS)
            {
                [tableV setFrame:CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, 524)];//height:tableV.frame.size.height + keyboardFrameInView.size.height-155
            }
            else if (IS_IPHONE_6){
            [tableV setFrame:CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, 500)];
                
            }
            else if (IS_IPHONE_5)
                [tableV setFrame:CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, 379 +kB_heightDiff )];
            // tableV.backgroundColor = [UIColor redColor];
            tableV.translatesAutoresizingMaskIntoConstraints =  true; // by nim chat#17
            int height = [UIScreen mainScreen].bounds.size.height;
            if(IS_IPHONE_X)
                height -= 60;
            
           /* int kB_H = keyboardFrameInView.size.height;
            CGFloat origin_y = height - (kB_H-(messageV.frame.size.height + 62)); //where 62 is tab height  - //by nim Chat#3
            //messageV.frame = CGRectMake(messageV.frame.origin.x, height-112-62, messageV.frame.size.width, messageV.frame.size.height+6); //by nim Chat#1  */
            
            // if call is active
            if (App_delegate.isCallProgress || ([[UIApplication sharedApplication]statusBarFrame].size.height== 40))
                height -= 20;
            CGFloat origin_y = height - 114; //fixed //by nim Chat#3
            messageV.frame = CGRectMake(messageV.frame.origin.x, origin_y, messageV.frame.size.width, messageV.frame.size.height);//by nim Chat#3
        }
    } constraintBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if(opening)  {
            [cont shouldMoveUp:opening];
            [inpF becomeFirstResponder];
        }
        else if(closing)
        {   //shoutBtn.hidden = YES; // by nim
            [cont shouldMoveUp:opening];
        }
    }];
}

- (void)checkActiveNetwork {
    
    NSString *activeNetId = [PrefManager activeNetId];
    if(_myGroup.network !=nil)
    {
        _isActiveNet = [_myGroup.network.netId isEqualToString:activeNetId];
    }
    
    [_txtInpbackImgV setImage:[UIImage imageNamed:_isActiveNet ? @"2GO SCREEN 320X568 1 LINE TEXT BOX.png" : @"input_txt_inactive.png"]];
    
    if (_isActiveNet) [self setUpKeyboard]; [LoaderView removeLoader];
}


- (void)shouldMoveUp:(BOOL)up {
    if (up == _isUp) return;
    _isUp = up;
    [[NSUserDefaults standardUserDefaults]setBool:_isUp forKey:k_isKeyboardUp];
    [[NSUserDefaults standardUserDefaults]synchronize];

    CGRect btmVfr     = _bottomInpView.frame;
    CGRect cmBtnVfr   = _camBtn.frame;
    CGRect voiceBtnfr = _voiceBtn.frame;
    CGRect spkrBtnfr  =  _sendButton.frame; //_speakerBtn.frame; // by nim
  //  CGRect leftlblfr  = _leftLbl.frame;
    CGRect bond       = self.view.bounds;
    CGRect shoutBtnfr = shoutBtn.frame;
//    _table.scrollEnabled = !_isUp; //by nim chat#2
    if (_isUp)
    {
        if(IS_IPHONE_6P || IS_IPHONE_6 || IS_IPHONE_X)
        {
            
            btmVfr.size.height = 78;
            //spkrBtnfr.size.height = 78; // added by nim
            cmBtnVfr.origin.y   = 46;  // move to up
            cmBtnVfr.size.width = 42;
            cmBtnVfr.size.height = 27;
            
            voiceBtnfr.origin.x = cmBtnVfr.origin.x + 3; // align left
            voiceBtnfr.origin.y = 7;
            voiceBtnfr.size.height = 27;
            voiceBtnfr.size.width = 32;
            
            /*
            leftlblfr.origin.x  = spkrBtnfr.origin.x ;
            leftlblfr.origin.y  = spkrBtnfr.origin.y + spkrBtnfr.size.height; //-17
            leftlblfr.size.width = spkrBtnfr.size.width; // by nim
            */ //by nim chat#1

        }
        if(IS_IPHONE_5)
        {
            btmVfr.size.height = 65;
            
            cmBtnVfr.origin.y   = 38;  // move down
            cmBtnVfr.size.width = 40;
            cmBtnVfr.size.height = 25;
            voiceBtnfr.origin.x = cmBtnVfr.origin.x + 1; // align left
            voiceBtnfr.origin.y = 8;
            voiceBtnfr.size.height = 25;
            voiceBtnfr.size.width = 33;
           /* leftlblfr.origin.x  = spkrBtnfr.origin.x ;
            leftlblfr.origin.y  = spkrBtnfr.origin.y + spkrBtnfr.size.height - 3; */ //by nim Chat#1
        }
        
        if(IPAD)
        {
            btmVfr.size.height = 78; //88; //by nim chat#15
            cmBtnVfr.origin.y   = 50;  // move down
            cmBtnVfr.size.width = 50;
            cmBtnVfr.size.height = 35;
            voiceBtnfr.origin.x = cmBtnVfr.origin.x + 1; // align left
            voiceBtnfr.origin.y = 18;
            voiceBtnfr.size.height = 35;
            voiceBtnfr.size.width = 43;
           /* leftlblfr.origin.x  = spkrBtnfr.origin.x + 55;
            leftlblfr.origin.y  = spkrBtnfr.origin.y + spkrBtnfr.size.height-20; */ //by nim Chat#1
            
        }
        
        
       // btmVfr.origin.y    = bond.size.height - [self tabHieght] - btmVfr.size.height;
        //btmVfr.origin.y    = bond.size.height - 61.3 - btmVfr.size.height; //by nim Chat#1
        btmVfr.origin.y    = bond.size.height - btmVfr.size.height;

        spkrBtnfr.origin.x  = btmVfr.size.width - spkrBtnfr.size.width;
        
        //set frame of new button
        shoutBtnfr.origin.x = btmVfr.size.width - shoutBtnfr.size.width;
        _txtInpbackImgV.image = [UIImage imageNamed:@"BUKI-BOX.png"];
        [_camBtn setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"microphcolor.png"] forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollUPAnimated:YES];
        });
    } else {
        btmVfr.size.height = 50; //40 // by nim 25July
        
    //btmVfr.origin.y    = bond.size.height - [self tabHieght] - btmVfr.size.height;
      // btmVfr.origin.y    = bond.size.height - 61.3 - btmVfr.size.height; //by nim Chat#1
        
        btmVfr.origin.y    = bond.size.height - btmVfr.size.height;
        

        cmBtnVfr.origin.y   = 15;
        cmBtnVfr.size.height = 20;
        cmBtnVfr.size.width = 25;
        voiceBtnfr.origin.x = voiceBtnfr.size.width + 10;
        // voiceBtnfr.origin.x = btmVfr.size.width - voiceBtnfr.size.width - 5;
        voiceBtnfr.origin.y = 15;
        voiceBtnfr.size.height = 20;
        voiceBtnfr.size.width = 20;
        spkrBtnfr.origin.x  = btmVfr.size.width; // hide
        shoutBtnfr.origin.x = btmVfr.size.width; // hide
       // leftlblfr.origin.x  = spkrBtnfr.origin.x; //by nim Chat#1
        _txtInpbackImgV.image = [UIImage imageNamed:@"2GO SCREEN 320X568 1 LINE TEXT BOX.png"];
        [_camBtn setImage:[UIImage imageNamed:@"2GO SCREEN 320X568 CAMERA.png"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"2GO SCREEN 320X568 MICROPHONE.png"] forState:UIControlStateNormal];
        [_table setFrame:CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width,  _table.frame.size.height +_bottomInpView.frame.size.height+ 25)];
       //_table.backgroundColor = [UIColor darkGrayColor];

        
    }
    // _bottomInpView.alpha     = 0.2;
    //[UIView animateWithDuration:.1 animations:^{
    _bottomInpView.frame = btmVfr;
    _bottomInpView.translatesAutoresizingMaskIntoConstraints = YES;//by nim Chat#1
    _table.translatesAutoresizingMaskIntoConstraints = YES;
    _camBtn.frame        = cmBtnVfr;
    _voiceBtn.frame      = voiceBtnfr;
    //  _speakerBtn.frame    = spkrBtnfr;
    
    //shoutBtn.frame    = shoutBtnfr;
   // leftlblfr.origin.x = leftlblfr.origin.x; //by nim Chat#1
    
  //  _leftLbl.frame       = leftlblfr;  //by nim Chat#1
    _bottomInpView.alpha = 1.0;
    // } completion:nil];
    //[_table setBackgroundColor:[UIColor greenColor]];
}

- (BOOL)checkIFNetworkIsActive
{
    if (!_isActiveNet) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Network"
                                                                       message:[NSString stringWithFormat: @"to send message to this group you must switch to the %@ network.\n Switch now?", _myGroup.network.netName]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action)
                              {
                                  NSString *activeNetId = [_myGroup.network.netId copy];
                                  [PrefManager setActiveNetId:activeNetId];
                                  [self checkActiveNetwork];
                                  [AppDelegate networkChange];  //
                                  
                                  // fire notification
                                  [[NSNotificationCenter defaultCenter] postNotificationName:kActiveNetworkChange object:nil userInfo:nil];
                                  _shouldRefresh = NO;
                                  
                                  [self goBack:nil];
                              }];
        
        [alert addAction:no];
        [alert addAction:yes];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}


-(void)kStatusBarWillChange{
    CGFloat y;
    _isUp = [[NSUserDefaults standardUserDefaults]boolForKey:k_isKeyboardUp];
    
    if (App_delegate.isCallProgress) {
        
        if (!_isUp)
            y = self.view.frame.size.height -  _bottomInpView.frame.size.height ;
        else
            y = _bottomInpView.frame.origin.y;
        
    }else{
        
        if (!_isUp)
            y = self.view.frame.size.height -  _bottomInpView.frame.size.height ;
        else
            y = _bottomInpView.frame.origin.y+20;
        
    }
    _bottomInpView.frame = CGRectMake(_bottomInpView.frame.origin.x,y, _bottomInpView.frame.size.width, _bottomInpView.frame.size.height);
}

-(void)receiveSuspend:(NSNotification *) notification
{
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:k_phNumberShoutReceiverCell];
    
    NSString *str1 = [[NSUserDefaults standardUserDefaults]objectForKey:k_phNumberShoutCell];
    
    if(![str isEqualToString:@""] || ![str1 isEqualToString:@""]){
        int timeStamp = (int)[TimeConverter timeStamp];
        
        NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"on_click_phone_call",@"text",nil];

        NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_click_phone_call",@"log_sub_category",@"on_click_phone_call",@"text",@"",@"category_id",detaildict,@"details",nil];
                
        [AppManager saveEventLogInArray:postDictionary];

        
//        [EventLog addEventWithDict:postDictionary1];
//        
//        NSNumber *count = [Global shared].currentUser.eventCount;
//        int value = [count intValue];
//        count = [NSNumber numberWithInt:value + 1];
//        [[Global shared].currentUser setEventCount:count];
//        [DBManager save];
//        
//        if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0))
//        {
//            //show loader...
//            // [LoaderView addLoaderToView:self.view];
//            [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//        }
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:k_phNumberShoutReceiverCell];
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:k_phNumberShoutCell];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }

    
}

- (void) keyboardWillChangeFrame:(NSNotification*)notification {
    NSDictionary* notificationInfo = [notification userInfo];
    CGRect keyboardFrame = [[notificationInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (keyboardFrame_BACKUP.size.height > keyboardFrame.size.height)
        kB_heightDiff = keyboardFrame_BACKUP.size.height - keyboardFrame.size.height ;
    else
        kB_heightDiff =  keyboardFrame.size.height - keyboardFrame_BACKUP.size.height  ;
    
    keyboardFrame_BACKUP = keyboardFrame;
    
    [UIView animateWithDuration:[[notificationInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]
                          delay:0
                        options:[[notificationInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]
                     animations:^{
                         
                         if (kB_heightDiff == keyboardFrame.size.height) {}else{
                             CGRect frame = _table.frame;
                             if(IS_IPHONE_X)
                             {
                                 frame.size.height -= (kB_heightDiff +32);
                             }
                             else
                             {
                                 frame.size.height -= kB_heightDiff;
                             }
                             _table.frame = frame;
                         }
                         
                     } completion:nil];
}



#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@" start typing..."]) {
        _shInputFld.text = @"";
    }
    _sendButton.enabled = YES;
    _shInputFld.textColor = [UIColor whiteColor];

#if TARGET_IPHONE_SIMULATOR
#else
    //    if ([[BLEManager sharedManager] on] == FALSE) {
    //        [AppManager showAlertWithTitle:@"Alert" Body:@"Please turn on Bluetooth in Settings, When the BT/BLE radio is off, shout will not be sent"];
    //        return NO;
    //    }
#endif
    if ([self checkIFNetworkIsActive]) {
        
        
        [self.view bringSubviewToFront:_bottomInpView];
        
        //Sonal 30,June,2017
        //_speakerBtn.hidden = YES;
        shoutBtn.hidden = NO; // by nim
        _leftLbl.hidden = NO;
        
        _speakerBtn.frame = CGRectMake(textView.frame.size.width + textView.frame.origin.x-5, 30, 50, 21);
        shoutBtn.frame = CGRectMake(textView.frame.origin.x-15, 15,48, 48); // by nim
        
        _txtInpbackImgV.image = [UIImage imageNamed:@"BUKI-BOX.png"];
        //[shoutBtn setBackgroundColor:[UIColor clearColor]];
        [shoutBtn setImage:[UIImage imageNamed:@"BukiBox.png"] forState:UIControlStateNormal]; // by nim
        [_camBtn setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"microphcolor.png"] forState:UIControlStateNormal];
        [textView resignFirstResponder];
        [textView endEditing:YES];
        return YES;
    }
    
    return NO;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (_isActiveNet) [self shouldMoveUp:NO];
    _speakerBtn.hidden = YES;
    shoutBtn.hidden = YES;
    if(_shInputFld.text.length == 0){
        _shInputFld.textColor = [UIColor lightGrayColor];
        _shInputFld.text = @" start typing...";
        [shoutBtn resignFirstResponder];
        _sendButton.enabled = NO;
        
    }
    CGRect camBtnframe = _camBtn.frame;
    
    camBtnframe.origin.x = 7;
    camBtnframe.origin.y = 15;
    camBtnframe.size.height = 20;
    camBtnframe.size.width = 25;
    
    _camBtn.frame =  camBtnframe;
    
    
    
    CGRect voiceBtnframe = _voiceBtn.frame;
    
    voiceBtnframe.origin.x = _camBtn.frame.size.width + 10;
    voiceBtnframe.origin.y = 15;
    voiceBtnframe.size.height = 20;
    voiceBtnframe.size.width = 20;
    
    
    _voiceBtn.frame =  voiceBtnframe;
    
    
    _txtInpbackImgV.image = [UIImage imageNamed:@"2GO SCREEN 320X568 1 LINE TEXT BOX.png"];
    [_camBtn setImage:[UIImage imageNamed:@"2GO SCREEN 320X568 CAMERA.png"] forState:UIControlStateNormal];
    [_voiceBtn setImage:[UIImage imageNamed:@"2GO SCREEN 320X568 MICROPHONE.png"] forState:UIControlStateNormal];
    DLog(@"%@", _bottomInpView);
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //Compare backSpace....
    if(textView.text.length >= k_MAX_SHOUT_LENGTH && ![text isEqualToString:@""]) {
        return FALSE;
    }
    
    if([text  isEqual: @"\n"]){
        
        [textView resignFirstResponder];
        
        
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length > k_MAX_SHOUT_LENGTH) {
        textView.text = [textView.text substringToIndex:k_MAX_SHOUT_LENGTH];
    }
    if([textView.text hasPrefix:@"tel:"] ||[textView.text hasPrefix:@"telprompt:"])
    {
        textView.text = [textView.text stringByReplacingOccurrencesOfString:@"tel:" withString:@""];
        textView.text = [textView.text stringByReplacingOccurrencesOfString:@"telprompt:" withString:@""];

        textView.text = [textView.text stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    }
    // text changed..
   // _leftLbl.text = [NSString stringWithFormat:@" %lu\n Left", (NSInteger)k_MAX_SHOUT_LENGTH - textView.text.length];
    _leftLbl.text = [NSString stringWithFormat:@" %lu Left", (NSInteger)k_MAX_SHOUT_LENGTH - textView.text.length]; // by nim

    //[shoutBtn setHidden:YES];//Sonal
    
}

- (void) hideKeyboard
{
    [_shInputFld resignFirstResponder];
   // [_table setBackgroundColor: [UIColor yellowColor]];
    _table.frame = CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width, _table.frame.size.height);

    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==1)
    {
        if (alertView.tag == k_FavToUnFav)
        {
            if (shoutIndex<[_shouts count]) {
                isReloadingTable = YES;
                Shout *sht = [_shouts objectAtIndex:shoutIndex];
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:shoutIndex inSection:0];
                [AppManager favouriteCall:sht withFavFlag:NO];
                [_table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        else if (alertView.tag == 1001001)
        {
            NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settings])
            {
                [[UIApplication sharedApplication] openURL:settings];
            }

        }
        else if (alertView.tag == 1001011)
        {
            if (shoutIndex<[_shouts count]) {
                Shout *sht = [_shouts objectAtIndex:shoutIndex];
                [[Global shared] saveVideo:sht];
            }
        }
        else
        {
            // change network.
            // store .....
            NSString *activeNetId = [_myGroup.network.netId copy];
            [PrefManager setActiveNetId:activeNetId];
            [self checkActiveNetwork];
            [AppDelegate networkChange];  //
            
            // fire notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kActiveNetworkChange object:nil userInfo:nil];
            _shouldRefresh = NO;
        }
    }
    else{
        [self goBack:nil];
    }
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for (Shout *s in _shouts)
    {
        if([s.owner.isBlocked isEqualToNumber:[NSNumber numberWithInteger:1]]){
            index1 = [actualShouts indexOfObject:s];
            if(index1<actualShouts.count)
                [actualShouts removeObjectAtIndex:index1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DBManager deleteOb:s];
                
            });
        }
    }
    [nonNullShouts removeAllObjects];
    [nonNullShouts addObjectsFromArray:actualShouts];
    for (Shout *s in nonNullShouts){
        if(s.owner ==nil && s.reciever ==nil){
            [actualShouts removeObject:s];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DBManager deleteOb:s];
                
            });
        }
    }
    return actualShouts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // if actual shout count is greater than and equal to indexpath row
    // Also the actual shout having the shout value (Greater than 0)
    if (indexPath.row<actualShouts.count && actualShouts.count>0) {
    
        Shout *sht = [actualShouts objectAtIndex:indexPath.row];
        
    [sht trackMe:sht];
    if (sht.owner.email != sht.reciever.email){
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:1 forKey:k_shoutSaved];
        [defaults synchronize];
        
        ShoutCell *cell;
        static NSString *ident;
        if (sht.type.integerValue == ShoutTypeTextMsg) {
            ident = @"ShoutCellIdentifier_Text";
            cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
           
            
        } else if (sht.type.integerValue == ShoutTypeImage) {
            ident = @"ShoutCellIdentifier_Image";
            cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
            
        } else if (sht.type.integerValue == ShoutTypeAudio) {
            ident = @"ShoutCellIdentifier_Sound";
            cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
            
        } else if (sht.type.integerValue == ShoutTypeGif) {
            ident = @"ShoutCellIdentifier_Gif";
            cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
            
        }else {
            ident = @"ShoutCellIdentifier_Video";
            cell = (ShoutCell *) [tableView dequeueReusableCellWithIdentifier:ident];
        }
        
        
        if (cell == nil)
        {
                cell = (ShoutCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
                cell = [ShoutCell cellWithType:sht.type.integerValue shouldFade:YES];
        }
        
        cell.delegate = self;
        cell.tag = indexPath.row;
        if ([self isKindOfClass:[CommsViewController class]]) {
            [cell showShout:sht forChieldCell:NO];
        }
        else{
            [cell showShout:sht forChieldCell:NO];
            [cell hideRebroadCastAndReply];
        }
        [cell updateCellVisibility:sht];
        return cell;
    }
    
    else{ //sendingSide
        
        
        ShoutCellReceiverCell *cell;

        // Shout *sht = [_shouts objectAtIndex:indexPath.row];
        static NSString *ident;
        if (sht.type.integerValue == ShoutTypeTextMsg) {
            ident = @"ShoutCellReceiver_Text";
            cell = (ShoutCellReceiverCell *) [tableView dequeueReusableCellWithIdentifier:ident];
            
        } else if (sht.type.integerValue == ShoutTypeImage) {
            ident = @"ShoutCellReceiver_Image";
            cell = (ShoutCellReceiverCell *) [tableView dequeueReusableCellWithIdentifier:ident];
            
        } else if (sht.type.integerValue == ShoutTypeAudio) {
            ident = @"ShoutCellReceiver_Sound";
            cell = (ShoutCellReceiverCell *) [tableView dequeueReusableCellWithIdentifier:ident];
            
        } else if (sht.type.integerValue == ShoutTypeGif) {
            ident = @"ShoutCellReceiver_Gif";
            cell = (ShoutCellReceiverCell *) [tableView dequeueReusableCellWithIdentifier:ident];
            
        }else {
            ident = @"ShoutCellReceiver_Video";
            cell = (ShoutCellReceiverCell *) [tableView dequeueReusableCellWithIdentifier:ident];
        }
        
        
        if (cell == nil)
        {
            cell = [(ShoutCellReceiverCell *)[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
            cell = [ShoutCellReceiverCell cellWithType:sht.type.integerValue shouldFade:YES];
        }
        
        cell.delegate = self;
        cell.tag = indexPath.row;
        if ([self isKindOfClass:[CommsViewController class]]) {
            [cell showShout:sht forChieldCell:NO];
        }
        else{
            [cell showShout:sht forChieldCell:NO];
            [cell hideRebroadCastAndReply];
        }
        [cell updateCellVisibility:sht];
        return cell;
    }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if (!isReloadingTable) {
        cell.contentView.transform = CGAffineTransformMakeScale(.8, .9);
        [UIView animateWithDuration:.3 animations:^{
            cell.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row < _shouts.count)
    {
    Shout *sht = [_shouts objectAtIndex:indexPath.row];
    if((sht.reciever.email == nil || sht.text == nil) && !sht.isFromCMS){   // receiving side
        //[tableView reloadData];
        return 0;
    }
    else
    {
    CGFloat width = 180*kRatioWidth; //170
     CGFloat th = [sht.text actualSizeWithFont:[UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize] stickToWidth:width].height+10;
    CGSize size = [sht.text actualSizeWithFont:[UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize] stickToWidth:width] ;
        DLog(@"Size is %f",size.width);
    
    UIFont *font = [UIFont fontWithName:@"Aileron-Regular" size:kShoutTextFontSize];
    int num = th / font.lineHeight;
        
    //on 16Aug
    if(!txtvw)
    txtvw = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 38)];
    [txtvw setFont:[UIFont fontWithName:@"Aileron-Regular" size:14]];
    txtvw.text = sht.text;
    CGSize countentSize = txtvw.contentSize;
    int numberOfLinesNeeded = countentSize.height / txtvw.font.lineHeight;
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
    return 0;
}

- (void)reBrodCastShout:(Shout*)shout withCellObj:(ShoutCell *)cell{
    NSData *content;
    if ([shout.type integerValue] == ShoutTypeGif) {
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:shout.contentUrl];
        content = [NSData dataWithContentsOfFile:path];
    }
    else if ([shout.type integerValue] == ShoutTypeImage) {
        //content = UIImageJPEGRepresentation([cell getCellImage], 0.4);
    } else if([shout.type integerValue] == ShoutTypeVideo || [shout.type integerValue] == ShoutTypeAudio) {
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:shout.contentUrl];
        if (path != nil) {
            content = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]]; // video file data(NSData).
        }
    }
    ShoutInfo *sh = [ShoutInfo composeExistingText:shout.text type:[shout.type integerValue] content:content groupId:shout.group.grId parentShId:nil shoutId:shout.shId];
    sh.shout.mediaPath = shout.contentUrl;
    
    [[BLEManager sharedManager] addSh:sh toQueueAt:YES];
}

#pragma mark - ShoutCellReceiverDelegate
- (void)didClickReceiverButtonWithTag:(CellButtonReceiverTag)tag ForObject:(Shout *)sht
{
    if (tag == CellButtonReceiverTag_Video) {
        tagEventLog = 5;
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
        eventLogVideoPath = path;
        if (path != nil) {
            [LHVideoPlayer playVideoURL:[NSURL fileURLWithPath:path] onController:self];
            [self uploadMedia:sht];
        }
    }
    if (tag == CellButtonReceiverTag_Audio) {
        tagEventLog = 6;
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
        eventLogAudioPath = path;
        [[LHAudioRecorder shared] playAudioUrl:[NSURL URLWithString:path]];
        [self uploadMedia:sht];
    }
    else if (tag == CellButtonReceiverTag_Profile) {
        // move to user detail.
        ProfileViewController *vc = (ProfileViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        vc.usr = sht.owner;
        vc.activeTag = BarItemTag_Groups;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (tag == CellButtonReceiverTag_Reply&& [self isKindOfClass:[CommsViewController class]])
    {
        [self comingSoon];
//        ReplyViewController *vc = (ReplyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
//        vc.pShout = sht;
//        vc.myGroup = _myGroup;
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (tag == CellButtonReceiverTag_Fav) {
        
        shoutIndex = [_shouts indexOfObject:sht];
        if ([sht.favorite integerValue]>=1){
            
            
            
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                           message:[NSString stringWithFormat: @"Are you sure you want to unfavourite?"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                 {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                  {
                                      if (shoutIndex<[_shouts count]) {
                                          isReloadingTable = YES;
                                          Shout *sht = [_shouts objectAtIndex:shoutIndex];
                                          NSIndexPath *indexpath = [NSIndexPath indexPathForRow:shoutIndex inSection:0];
                                          [AppManager favouriteCall:sht withFavFlag:NO];
                                          [_table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationFade];
                                      }
                                      
                                  }];
            
            [alert addAction:no];
            [alert addAction:yes];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            [AppManager favouriteCall:sht withFavFlag:YES];
        }
        
    }
    else if (tag == CellButtonReceiverTag_All)
    {
        //Rebroadcast message: User can re-broadcast the message by tapping on the icon. Message will be rebroadcasted to all the users; however it will be displayed only to those users who have never received it earlier. It shall be displayed for 15 minutes timeout for users who have not received.
//        NSInteger index = [_shouts indexOfObject:sht];
//        NSIndexPath *indp = [NSIndexPath indexPathForRow:index inSection:0];
//        ShoutCell *cell = (ShoutCell *)[_table cellForRowAtIndexPath:indp];
//        Shout *shout = [_shouts objectAtIndex:index];
//        [self reBrodCastShout:shout withCellObj:cell];
        [self comingSoon];
        
    }
    else if (tag == CellButtonReceiverTag_Image) {
        tagEventLog = 7;
        ImageOverlyViewController *vc = (ImageOverlyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ImageOverlyViewController"];
        vc.imagePath = URLForShoutContent(sht.shId, @"png");
        eventLogImagePath = URLForShoutContent(sht.shId, @"png");
        vc.sht = sht;
        [self eventLogAPI:sht];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    else if (tag == CellButtonTag_Video_Export){
        shoutIndex = [_shouts indexOfObject:sht];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:[NSString stringWithFormat: k_exportVideoAlert]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action)
                              {
                                  if (shoutIndex<[_shouts count]) {
                                      Shout *sht = [_shouts objectAtIndex:shoutIndex];
                                      [[Global shared] saveVideo:sht];
                                  }
                              }];
        
        [alert addAction:no];
        [alert addAction:yes];
        [self presentViewController:alert animated:YES completion:nil];
       // alrt = nil;
    }
}

- (void)removeShoutCellReceiverwithShoutInfo:(Shout *)sh {
    [self refreshShoutes:sh];
}


#pragma mark - ShoutCellDelegate
- (void)didClickButtonWithTag:(CellButtonTag)tag ForObject:(Shout *)sht
{
    if (tag == CellButtonTag_Video)
    {
        tagEventLog = 5;
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
        eventLogVideoPath = path;
        if (path != nil) {
            [LHVideoPlayer playVideoURL:[NSURL fileURLWithPath:path] onController:self];
            [self uploadMedia:sht];
        }
    }
    if (tag == CellButtonTag_Audio)
    {
        tagEventLog = 6;
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:sht.contentUrl];
        eventLogAudioPath = path;
        [[LHAudioRecorder shared] playAudioUrl:[NSURL URLWithString:path]];
        [self uploadMedia:sht];
    }
    else if (tag == CellButtonTag_Profile)
    {
        //downloadUserImage
        // move to user detail.
        ProfileViewController *vc = (ProfileViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        vc.usr = sht.owner;
        vc.activeTag = BarItemTag_Groups;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (tag == CellButtonTag_Reply&& [self isKindOfClass:[CommsViewController class]])
    {
//        ReplyViewController *vc = (ReplyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
//        vc.pShout = sht;
//        vc.myGroup = _myGroup;
//        [self.navigationController pushViewController:vc animated:YES];
        
        [self comingSoon];
    }
    else if (tag == CellButtonTag_Fav) {
        
        shoutIndex = [_shouts indexOfObject:sht];
        if ([sht.favorite integerValue]>=1){
            
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                           message:[NSString stringWithFormat: @"Are you sure you want to unfavourite?"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                 {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                  {
                                      if (shoutIndex<[_shouts count]) {
                                          isReloadingTable = YES;
                                          Shout *sht = [_shouts objectAtIndex:shoutIndex];
                                          NSIndexPath *indexpath = [NSIndexPath indexPathForRow:shoutIndex inSection:0];
                                          [AppManager favouriteCall:sht withFavFlag:NO];
                                          [_table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationFade];
                                      }
                                  }];
            
            [alert addAction:no];
            [alert addAction:yes];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [AppManager favouriteCall:sht withFavFlag:YES];
        }
    }
    else if (tag == CellButtonTag_All)
    {
        //Rebroadcast message: User can re-broadcast the message by tapping on the icon. Message will be rebroadcasted to all the users; however it will be displayed only to those users who have never received it earlier. It shall be displayed for 15 minutes timeout for users who have not received.
//        NSInteger index = [_shouts indexOfObject:sht];
//        NSIndexPath *indp = [NSIndexPath indexPathForRow:index inSection:0];
//        ShoutCell *cell = (ShoutCell *)[_table cellForRowAtIndexPath:indp];
//        Shout *shout = [_shouts objectAtIndex:index];
//        [self reBrodCastShout:shout withCellObj:cell];

        [self comingSoon];
    }
    else if (tag == CellButtonTag_Image)
    {
        tagEventLog = 7;
        ImageOverlyViewController *vc = (ImageOverlyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ImageOverlyViewController"];
        vc.imagePath = URLForShoutContent(sht.shId, @"png");
        
        UIImage *image  = [[SDImageCache sharedImageCache] diskImageForKey:vc.imagePath];
        if (!image) {
            if(sht.type == [NSNumber numberWithInt:ShoutTypeImage])
            {
            NSLog(@"Not proper image");
            [AppManager showAlertWithTitle:@"Alert!" Body:@"Not proper image"];
            return;
            }
        }
        
        eventLogImagePath = URLForShoutContent(sht.shId, @"png");
        vc.sht = sht;
        [self eventLogAPI:sht];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    else if (tag == CellButtonTag_Video_Export){
        shoutIndex = [_shouts indexOfObject:sht];
        
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:[NSString stringWithFormat: k_exportVideoAlert]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action)
                              {
                                  if (shoutIndex<[_shouts count]) {
                                      Shout *sht = [_shouts objectAtIndex:shoutIndex];
                                      [[Global shared] saveVideo:sht];
                                  }
                              }];
        
        [alert addAction:no];
        [alert addAction:yes];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)removeShoutCellwithShoutInfo:(Shout *)sh {
    [self refreshShoutes:sh];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ((k_EnableVideoRecording == 1 && buttonIndex == 3)|| (k_EnableVideoRecording == 0 && buttonIndex == 2)) return; // cancel
    
    MediaType mType = MediaTypeImageCamera; //Default is  camera
    
    if (k_EnableVideoRecording == 1) {
        mType = (buttonIndex == 0) ? MediaTypeVideo : ((buttonIndex == 1) ? MediaTypeImageCamera : MediaTypeImageLibrary); // video : camera : library
    }
    else{
        mType = (buttonIndex == 0) ? MediaTypeImageCamera : MediaTypeImageLibrary; // camera : library
    }
    
    int type;
    if (mType == MediaTypeVideo || mType == MediaTypeImageCamera) {
        type = 1;
    }
    else{
        type = 2;
    }
    if (![ImagePickManager checkUserPermission:type]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (type==1) {
                
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                               message:[NSString stringWithFormat: @"App does not have access to your camera. To enable access, tap Settings and turn on Camera"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action)
                                     {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }];
                UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action)
                                      {
                                          NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                          if ([[UIApplication sharedApplication] canOpenURL:settings])
                                          {
                                              [[UIApplication sharedApplication] openURL:settings];
                                          }
                                      }];
                
                [alert addAction:no];
                [alert addAction:yes];
                [self presentViewController:alert animated:YES completion:nil];
                
                
                        }
            else if(type==2){
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                               message:[NSString stringWithFormat: @"App does not have access to Photos. To enable access, tap Settings and turn on Photos"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action)
                                     {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }];
                UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action)
                                      {
                                          NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                          if ([[UIApplication sharedApplication] canOpenURL:settings])
                                          {
                                              [[UIApplication sharedApplication] openURL:settings];
                                          }
                                      }];
                
                [alert addAction:no];
                [alert addAction:yes];
                [self presentViewController:alert animated:YES completion:nil];
                
                       }
        });
        return;
    }
    CommsViewController *comms;
    if ([self isKindOfClass:[CommsViewController class]]) {
        comms = (CommsViewController*)self;
        [comms.view endEditing:YES];
    }
    MediaCommsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaCommsViewController"];
    vc.mediaType = mType;
    vc.myGroup = _myGroup;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setMyGroup:(Group *)myGroup
{
    
    if ([PrefManager isBackUpAlreadyInProcess]) {
        [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Backup is in progress. Do you want to discard backup ?" firstButtonMsg:@"YES" andSecondBtnMsg:@"NO" andVC:self noOfBtn:2 completion:^(BOOL isOkButton) {
            
            if (isOkButton)
            {
                CommsViewController *comms;
                if ([self isKindOfClass:[CommsViewController class]]) {
                    comms = (CommsViewController*)self;
                    [comms closebackupButton];
                }
                    if (_myGroup!=myGroup) {
                    _myGroup = myGroup;
                    currentGroupId = _myGroup.grId.integerValue;
                }
                NSSortDescriptor *sortDescriptor = nil;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                             ascending:YES];
                NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
                
                selectedGroupIndex = [arr indexOfObject:_myGroup];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [collectionGroup reloadData];
                    [self sortShouts:nil];
                });

                [PrefManager setBackUpStarted:[NSNumber numberWithBool:NO].boolValue];
            }
            else
            {
                self.myGroup.grId = [[NSUserDefaults standardUserDefaults]objectForKey:k_groupInWhichBackupStarted];
                currentGroupId = _myGroup.grId.integerValue;
            NSSortDescriptor *sortDescriptor = nil;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                         ascending:YES];
            NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
            
             selectedGroupIndex = [arr indexOfObject:self.myGroup];
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    [collectionGroup reloadData];
                });
        }
        }];
    }
    else
    {
        if (_myGroup!=myGroup) {
            _myGroup = myGroup;
            currentGroupId = _myGroup.grId.integerValue;
        }
    }
}

- (Group*)myGroup{
    if (_myGroup.grId==nil) {
        Group *grp = [Group groupWithId:[NSString stringWithFormat:@"%ld", (long)currentGroupId] shouldInsert:NO isP2PContact:NO isPendingStatus:NO];
        _myGroup = grp;
        return grp;
    }
    return _myGroup;
}

-(void)appEnterBackgroundNotificationOrBecomeActive:(NSNotification*)note
{
    [self refreshShoutes:nil];
    [self.myGroup clearBadge];
}

- (void)refreshShoutes:(Shout*)sh
{
    [self sortShouts:sh];
    dispatch_async(dispatch_get_main_queue(), ^{
       // [self sortShouts:sh]; Moving it out of dispatch
        isReloadingTable = YES;
        [_table reloadData];
    });
}

-(void)uploadMedia:(Shout *)sht
{
    
    NSMutableDictionary *param = nil;
    param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser] ;
    
    [param setObject : user.user_id  forKey : @"user_id"];
    NSString *token = [PrefManager token];
    
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    
    [[AFAppDotNetAPIClient sharedClient] POST:uploadMedia parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (tagEventLog == 5) {
            NSString *path = eventLogVideoPath;
            if (path != nil) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
                if (data) {
                    [formData appendPartWithFileData:data name:@"media" fileName:@"video.mov" mimeType:@"video/quicktime"];
                }
            }
            
        }
        else if(tagEventLog == 6){
            NSString *path = eventLogAudioPath;
            if (path != nil) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
                if (data) {
                    [formData appendPartWithFileData:data name:@"media" fileName:@"audio.m4a" mimeType:@"audio/x-m4a"];
                }
            }
        }
        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        NSDictionary *dict = [response objectForKey:@"data"];
        commonUrl = [dict objectForKey:@"url"];
        BOOL status = [[response objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInteger:1]];
        if(status){
            [self eventLogAPI:sht];
        }
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
    }];
    
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kActiveNetworkChange object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShoutDead object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
   
    NSDictionary *d = [_datasource objectAtIndex:section];
    grps = [d objectForKey:@"groups"];
    if(grps.count <= 3)
    {
        _leftArrow.hidden = YES;
        _rightArrao.hidden = YES;
    }
    else
    {
        _leftArrow.hidden = NO;
        _rightArrao.hidden = NO;
    }
    return grps.count;// _selectedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"GroupCollectionCell";
    GroupCollectionCell *cell = (GroupCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.imageUser.image =  [UIImage imageNamed:@"GroupUserIcon.png"];
    cell.indicatorLine.hidden =  YES;
    if (indexPath.row == selectedGroupIndex){
        cell.indicatorLine.hidden =  NO;
    }
    NSSortDescriptor *sortDescriptor = nil;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                 ascending:YES];
    NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];

    Group *group = [arr objectAtIndex:indexPath.row];
    
    [cell showGroup:group];
    if(grps.count <= 3)
    {
        _leftArrow.hidden = YES;
        _rightArrao.hidden = YES;
    }
    else
    {
        _leftArrow.hidden = NO;
        _rightArrao.hidden = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_table reloadData];
        
    });

    return cell;
}


#define kCellWidth 125
#define kCellHeight 100
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_X) {
        return CGSizeMake(kCellWidth*kRatioIPhoneX-14, kCellHeight*kRatio-14);
    }
    
    return CGSizeMake(kCellWidth*kRatio-7, kCellHeight*kRatio);
    
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isBackupOn = [[defaults objectForKey:@"kBackUp_Key"] intValue];
    if (!isBackupOn)
    {
        
        selectedGroupIndex = indexPath.row;
        
        NSSortDescriptor *sortDescriptor = nil;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
        Group *gr = [arr objectAtIndex:indexPath.row];
        
        
        if(gr.totShoutsReceived.integerValue>1){
            [gr clearBadge:gr];
        }
        
        if(gr.isPending){
            if(gr.isP2PContact)
            {
                [AppManager showAlertWithTitle:@"Alert" Body:[NSString stringWithFormat:@"Your P2P contact request is pending. Please wait"]];
                
            }else
            {
                [AppManager showAlertWithTitle:@"Alert" Body:[NSString stringWithFormat:@"Your group is pending. Please go to manage group to complete the process"]];
            }
        }
        else
        {
            Global *shared = [Global shared];
            [DBManager updateShoutsIsReadOnClickingMessages:gr.grId withUserID:shared.currentUser.user_id];
            [self setMyGroup:gr];
            [self sortShouts:nil];
            CommsViewController *comms;
            if ([self isKindOfClass:[CommsViewController class]]) {
                comms = (CommsViewController*)self;
                comms.myGroup = gr;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // [self sortShouts:nil]; Moving it out of dispatch
                
                [collectionGroup reloadData];
                [_table reloadData];
                if(actualShouts.count > 1)
                    
                    @try {
                        
                        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:actualShouts.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES]; // by nim chat#3
                        
                        
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
            });

//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//               // [self sortShouts:nil]; Moving it out of dispatch
//                
//                [collectionGroup reloadData];
//                
//            });
//            
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [_table reloadData];
//                
//            });
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                if(actualShouts.count > 0)
//                    [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:actualShouts.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES]; // by nim chat#3
//                
//            });
        }
    }
    else
    {
        NSLog(@"Please stop Backup");
        [AppManager showAlertWithTitle:@"Alert" Body:@"Backup is in progress please stop first to continue."];
        
    }
    //    GroupCollectionCell *cell  = [collectionView cellForItemAtIndexPath:indexPath];
    //    cell.indicatorLine.hidden =  NO;
}


- (IBAction)addAttchmentView:(id)sender
{
    [_shInputFld resignFirstResponder];
    if ([attchVieww superview] != nil){
        
        
        [attchVieww removeFromSuperview];
        //[self.view willRemoveSubview:attchVieww];
        attchVieww = nil;
        
    }else{
        CGSize sz = self.view.bounds.size;
        CGFloat tHieght = 50;//50*kRatio; //61.3;
        CGFloat btmView = 50;
        CGFloat origin_y = sz.height - (tHieght + btmView);
        if(IS_IPHONE_X)
            origin_y -= 34;
        CGRect frame = CGRectMake(0, origin_y, sz.width, tHieght);
        attchVieww= [AttachmentOptionView tabbarWithFrame:frame];
        //attchVieww = attchView;
        [self.view addSubview:attchVieww];
        // _tabbar.selectedItemTag = barTag;
        [attchVieww addTarget:self andSelector:@selector(attachMediaButtonClicked:)];
    }
}

-(void)attachMediaButtonClicked:(UIButton *)sender
{
    if([sender.titleLabel.text isEqualToString:@"Camera"])
    {
        [self askCameraAccessPermission:@"Camera"];
    }
    else if([sender.titleLabel.text isEqualToString:@"Image"])
    {
        [self askPhotoLibAccessPermission];
    }
    else if([sender.titleLabel.text isEqualToString:@"Audio"])
    {
       // [self askMicroPhoneAccessPermission];
        [self comingSoon];
    }
    else if([sender.titleLabel.text isEqualToString:@"Video"])
    {
       // [self askCameraAccessPermission:@"Video"];
        [self comingSoon];
    }
    
}

-(void)comingSoon
{
        UIAlertView * alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"Coming Soon!" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        [self performSelector:@selector(byeAlertView:) withObject:alert afterDelay:1.2];
}

-(void)byeAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}


-(void)askMicroPhoneAccessPermission
{
    //audio
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSLog(@"Permission granted");
#if TARGET_IPHONE_SIMULATOR
#else
            //    if ([[BLEManager sharedManager] on] == FALSE) {
            //        [AppManager showAlertWithTitle:@"Alert" Body:@"Please turn on Bluetooth in Settings, When the BT/BLE radio is off, shout will not be sent"];
            //        return;
            //    }
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                MediaCommsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaCommsViewController"];
                vc.mediaType = MediaTypeSound;
                vc.myGroup = self.myGroup;
                [self.navigationController pushViewController:vc animated:NO];
            });
        }
        else {
            NSLog(@"Permission denied");
            if ([self checkIFNetworkIsActive])
            {
                //if (![ImagePickManager checkUserPermission:3])
                //{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alrt = nil;
                    alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to your microphone. To enable access, tap Settings and turn on Microphone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                    [alrt show];
                    alrt = nil;
                });
                return;
                 }
          //  }
        }
    }];
}

-(void)askCameraAccessPermission:(NSString *)mediaType
{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
            // until iOS 8. So for iOS 7 permission will always be granted.
            if (granted) {
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) { [_shInputFld resignFirstResponder];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MediaCommsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaCommsViewController"];
                        if([mediaType isEqualToString:@"Camera"])
                            vc.mediaType = MediaTypeImageCamera;
                        else if([mediaType isEqualToString:@"Video"])
                            vc.mediaType = MediaTypeVideo;
                        vc.myGroup = self.myGroup;
                        [self.navigationController pushViewController:vc animated:NO];
                    });
                    
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alrt = nil;
                    alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to your camera. To enable access, tap Settings and turn on Camera." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                    alrt.tag = 1001001;
                    [alrt show];
                    alrt = nil;
                });
                // Permission has been denied.
            }
        }];
    } else {
        // We are on iOS <= 6. Just do what we need to do.
        //        [self doStuff];
    }
}

-(void)askPhotoLibAccessPermission
{
    ALAssetsLibrary *lib = nil;
    lib = [[ALAssetsLibrary alloc] init];
    
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(group != nil){
            MediaCommsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaCommsViewController"];
        
            vc.mediaType = MediaTypeImageLibrary;
            vc.myGroup = self.myGroup;
                vc.msgString =  _shInputFld.text ;
            [self.navigationController pushViewController:vc animated:NO];
            }
        });
        
    } failureBlock:^(NSError *error) {
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            NSLog(@"user denied access, code: %li",(long)error.code);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alrt = nil;
                alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to Photos. To enable access, tap Settings and turn on Photos." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                alrt.tag = 1001001;
                [alrt show];
                alrt = nil;
            });
            
        }else{
            NSLog(@"Other error code: %li",(long)error.code);
        }
    }];
}

#pragma mark - EventLog

-(void)eventLogAPI:(Shout*)sht
{
    int timeStamp = (int)[TimeConverter timeStamp];
    NSMutableDictionary *detailDict;
    NSMutableDictionary *detaildict1;

     if(tagEventLog == 7)
    {
        detaildict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:sht.shId,@"shoutId",_myGroup.grId,@"groupId",eventLogImagePath,@"text",nil];

        detailDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_click_image",@"log_sub_category",_myGroup.grId,@"groupId",eventLogImagePath,@"text",sht.shId,@"shoutId",detaildict1,@"details",_myGroup.grId,@"category_id",nil];
    }
    else if (tagEventLog == 5)
    {
//        NSLog(@"video path is %@",eventLogVideoPath);
        detailDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"logCat",@"on_click_video",@"logSubCat",_myGroup.grId,@"groupId",eventLogVideoPath,@"text",sht.shId,@"shoutId",nil];
        
    }
    
    else{
//        NSLog(@"audio path is %@",eventLogAudioPath);
        detailDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"logCat",@"on_click_audio",@"logSubCat",_myGroup.grId,@"groupId",eventLogAudioPath,@"text",sht.shId,@"shoutId",nil];
    }
       
    [AppManager saveEventLogInArray:detailDict];

//    [EventLog addEventWithDict:detailDict];
//
//    
//    NSNumber *count = [Global shared].currentUser.eventCount;
//    int value = [count intValue];
//    count = [NSNumber numberWithInt:value + 1];
//    [[Global shared].currentUser setEventCount:count];
//    [DBManager save];
//
//  if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0))
//    {
//        //show loader...
//        // [LoaderView addLoaderToView:self.view];
//        [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//    }
}

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
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)currentGroupId],@"groupId",temp,@"text",nil];

       NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Group_Message",@"log_category",@"on_copy_text",@"log_sub_category",[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",temp,@"text",[NSString stringWithFormat:@"%ld",(long)currentGroupId],@"groupId",[NSString stringWithFormat:@"%ld",(long)currentGroupId],@"category_id",detaildict,@"details",nil];
        
    [AppManager saveEventLogInArray:postDictionary];

//    [EventLog addEventWithDict:postDictionary];
//    NSNumber *count = [Global shared].currentUser.eventCount;
//    int value = [count intValue];
//    count = [NSNumber numberWithInt:value + 1];
//    [[Global shared].currentUser setEventCount:count];
//    [DBManager save];
//    
//    
//    if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0)){          //show loader...
//        // [LoaderView addLoaderToView:self.view];
//        [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//    
//    }
}

-(void)scrollNotif:(NSNotification *)noti
{
    if ([noti object]) {
        
        self.myGroup = noti.object;
        [self scrollIndex:noti.object];

    }
}

-(void)scrollIndex:(id)groupId
{
    Group *gr1 = groupId;
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
    
    NSSortDescriptor *sortDescriptor = nil;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                 ascending:YES];
    NSArray *arr = [groups sortedArrayUsingDescriptors:@[sortDescriptor]];

    __block BOOL isAvailable = false;
    __block NSUInteger index;
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        Group *gr = obj;
        if ([gr.grId integerValue] == [gr1.grId integerValue]) {
            isAvailable = YES;
            index       = idx;
        }
    }];
    
    if (isAvailable) {
        self.selectedGroupIndex = index;
        [self.myGroup clearBadge:gr1];

    }
    
    [self sortShouts:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [collectionGroup reloadData];
//        NSLog(@"Reload data : scrollIndex");
        [_table reloadData];
        if(actualShouts.count > 1)
        {
            @try {
                
                [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:actualShouts.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES]; // by nim chat#3
                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    });
}

#pragma mark - Report Message

-(void)showAlertForReport:(Shout*)sh{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Content" message:@"Do you want to mark this content as abusive/inappropriate?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction*  action){
        for(Shout *shout in _shouts){
            
            if([shout.shId isEqualToString:sh.shId]){
                selectedRow = [_shouts indexOfObject:shout];
                
            }
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
        
        ShoutCell* cell = [_table cellForRowAtIndexPath:indexPath];
       // tempSh = sh;
        
        [cell updateReportIcon];
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"Reload data : showAlertForReport");
            [_table reloadData];
            [self reportMessageToAdmin:sh];

        });
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction*  action){
        
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)reportMessageToAdmin:(Shout *)sh{
   
    int timeStamp = (int)[TimeConverter timeStamp];

    
    NSInteger type = sh.type.integerValue;
    NSString *typeOfMsg;
    NSString *msgContent;
    
    if(type == 0){
        typeOfMsg = @"text";
        msgContent = sh.text;
    }
    else if(type == 1){
        typeOfMsg = @"image";
        msgContent = sh.contentUrl;
    }
    else if(type == 2){
        typeOfMsg = @"audio";
        msgContent = [sh.contentUrl stringByAppendingString:sh.text];
        
    }
    else if(type == 3){
        typeOfMsg = @"video";
        msgContent = [sh.contentUrl stringByAppendingString:sh.text];
        
    }
    else if(type == 6){
        //typeOfMsg = @"gif";
        typeOfMsg = @"image";

        if (sh.text) {
            msgContent = [sh.contentUrl stringByAppendingString:sh.text];
        }else
            msgContent = sh.contentUrl;
    }
    
    NSString *userDetails;
    
    if (sh.isFromCMS)
    {
        if (sh.cmsID) {
            userDetails = sh.cmsID;
        }else
            userDetails = @"CMS";
    }
    else if(sh.owner.user_id)
        userDetails = sh.owner.user_id;
    else
        userDetails = @"Unknown";
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:userDetails,@"sender_id",sh.shId,@"message_id",typeOfMsg,@"message_type",msgContent,@"message_content",nil];
    
    [self blockUserOption:sh];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:_myGroup.grId,@"groupId",msgContent,@"text",nil];

    NSMutableDictionary *postDictionary1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_report_content",@"log_sub_category",_myGroup.grId,@"groupId",msgContent,@"text",_myGroup.grId,@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary1];

//    [EventLog addEventWithDict:postDictionary1];
//    
//    NSNumber *count = [Global shared].currentUser.eventCount;
//    int value = [count intValue];
//    count = [NSNumber numberWithInt:value + 1];
//    [[Global shared].currentUser setEventCount:count];
//    [DBManager save];
//
//    if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0))
//    {
//        //show loader...
//        // [LoaderView addLoaderToView:self.view];
//        [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//    }
    
    if ([AppManager isInternetShouldAlert:YES])
    {
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,REPORT_MESSAGE_CONTENT];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
    }
}

-(void)blockUserOption:(Shout *)sh
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    
    ShoutCell* cell = [_table cellForRowAtIndexPath:indexPath];
    
    int timeStamp = (int)[TimeConverter timeStamp];

    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block User" message:@"Do you also wish to block the user?If blocked, you would not receive any further messasges from the user.If dismissed only the message will be deleted.Please confirm" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        [cell changeTheReportIcon];
        self.blockedUsers = [NSMutableArray new];
        [self.blockedUsers addObject:sh.owner.user_id];
        [[NSUserDefaults standardUserDefaults] setInteger:[sh.owner.user_id integerValue] forKey:@"blockedUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:sh.owner.user_id,@"text",nil];

        NSMutableDictionary *postDictionary1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_block_user",@"log_sub_category",sh.owner.user_id,@"text",sh.owner.user_id,@"category_id",detaildict,@"details",nil];
                
        [AppManager saveEventLogInArray:postDictionary1];
        
//        [EventLog addEventWithDict:postDictionary1];
//        
//        NSNumber *count = [Global shared].currentUser.eventCount;
//        int value = [count intValue];
//        count = [NSNumber numberWithInt:value + 1];
//        [[Global shared].currentUser setEventCount:count];
//        [DBManager save];
//        
//        if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0))
//        {
//            //show loader...
//            // [LoaderView addLoaderToView:self.view];
//            [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//        }
//
        dispatch_async(dispatch_get_main_queue(), ^{
            [sh.owner setIsBlocked:[NSNumber numberWithInteger:1]];
            [DBManager deleteOb:sh];
             [DBManager save];
            [self sortShouts:nil];
            [_table reloadData];
        });
        [AppManager showAlertWithTitle:@"Acknowledgement" Body:@"The user has been blocked!"];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        dispatch_async(dispatch_get_main_queue(), ^{
        [cell changeTheReportIcon];
        [DBManager deleteOb:sh];
        [DBManager save];
        [self sortShouts:nil];
        [_table reloadData];
            
        });
        
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];    
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark- Shared Utils Delegate Method

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    if(responseDict != nil)
    {
//    NSLog(@"responseDict is --- %@",responseDict);
    BOOL status = [[responseDict objectForKey:@"status"]boolValue];
    NSString *msgStr= [responseDict objectForKey:@"status"];
    if (status || [msgStr isEqualToString:@"Success"])
    {
   
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Message content reported successfully..!"] ){
            NSLog(@"Message has been reported to admin");
            
        }
        else
        {
            
        }
    }
    }
}

@end
