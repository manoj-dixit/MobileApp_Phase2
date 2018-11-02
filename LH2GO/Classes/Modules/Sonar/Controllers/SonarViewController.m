//
//  SonarViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "SonarViewController.h"
#import "UserLocationsView.h"
#import "LocationManager.h"
#import "SonarManager.h"
#import "LoaderView.h"
#import "ProfileViewController.h"
#import "BLEManager.h"
#import "SERVICES.h"
#import "iCarousel.h"
#import "SharedUtils.h"
#import "RelayObject.h"
#import "INTULocationManager.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "TimeConverter.h"
#import "EventLog.h"
#import "ShoutManager.h"

@interface SonarViewController () <iCarouselDelegate,iCarouselDataSource,APICallProtocolDelegate,CLLocationManagerDelegate>
{
    UserLocationsView *_userGraph;
    SharedUtils *sharedUtils;
    NSMutableArray *listOfRelays;
    NSMutableArray *relayCoord;
    NSMutableArray *relayName;
    NSMutableArray *relayStatus;
    NSMutableArray *bboxType;
    NSMutableArray *contentArray;
    __weak IBOutlet UILabel *_netNmLbl;
    __weak IBOutlet UIView *tempView;
   // BOOL isInProgress;
    __weak IBOutlet iCarousel *iCarousel_obj;
    NSInteger selectedIndex;
    BOOL isUserLocation;
    NSString *defaultStringCoordinates,*defaultMapCoordinates;
}
- (void)disableLocation;
@end

@implementation SonarViewController
@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.rightBarButtonItem = nil;

    defaultMapCoordinates = @"41.82113,-71.41196";
    _vw_banner.alpha = 1;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    
    listOfRelays = [NSMutableArray new];
    relayCoord = [NSMutableArray new];
    relayName = [NSMutableArray new];
    relayStatus = [NSMutableArray new];
    bboxType = [NSMutableArray new];
    
    _carouselView.hidden = YES;
    
    // add persons ploting view..
    CGFloat userLocationYAxis = 0.0;
    if(IS_IPHONE_5){
        userLocationYAxis = (self.view.bounds.size.height-[self tabHieght])/2-128;}
    if(IS_IPHONE_6){
        userLocationYAxis = (self.view.bounds.size.height-[self tabHieght])/2-158;}
    if(IS_IPHONE_6P){
        userLocationYAxis = (self.view.bounds.size.height-[self tabHieght])/2-168;}
    _userGraph = [[UserLocationsView alloc]initWithFrame:CGRectMake(10,userLocationYAxis , self.view.bounds.size.width-20, self.view.bounds.size.width-20)];
    
    _recenterButton.hidden = true;
    _bannerLabel.font = [_bannerLabel.font fontWithSize:[Common setFontSize:_bannerLabel.font]];
    
    // iCarousel
    iCarousel_obj.type = iCarouselTypeCustom;
    selectedIndex = 1; //default
    iCarousel_obj.decelerationRate = 0.6f;
    self.mapView.delegate=self;
    _crossButton.layer.cornerRadius = _crossButton.frame.size.height/2;
    _crossButton.layer.masksToBounds = YES;
    _crossButton.backgroundColor =  [UIColor whiteColor];
    
    [self addTabbarWithTag : BarItemTag_Sonar];
    [self setTabOneLineColor:BarItemTag_Sonar];
    [self addPanGesture];
    [self scrollCarouselToIndex];
    [self getDefaultLocationCoordinates];
    [self addNavigationBarViewComponents];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrivedInNotification:) name:kNewShoutEncounter object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:k_GotuserSettings object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSettings) name:k_GotuserSettings object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kchannelBadgeAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelBadgeAdded:) name:kchannelBadgeAdd object:nil];
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Discover";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
    
}

-(void)getDefaultLocationCoordinates{
    NSMutableDictionary  *defaultLocationPostDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[PrefManager defaultUserSelectedCityId],@"application_id",nil];
    if ([AppManager isInternetShouldAlert:NO])
    {
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,GETDEFAULTLOCATION];
        [sharedUtils makePostCloudAPICall:defaultLocationPostDict andURL:urlString];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hitEventLogApi:@"Access" status:@""];
    contentArray = [[NSMutableArray alloc] init];
    [self enableLocationPermission];
    [self displayOfflineData];
    [self comeInForeground];

    // update curent network label
    NSString *activeNetId = [PrefManager activeNetId];
    Network *activeNet = [Network networkWithId:activeNetId shouldInsert:YES];
    _netNmLbl.text = activeNet.netName;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationReceivedForNotfTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTabBadge) name:@"NotificationReceivedForNotfTab" object:nil];
}

-(void)displayOfflineData{
    if (![AppManager isInternetShouldAlert:NO]){
    [relayCoord removeAllObjects];
    [relayName removeAllObjects];
    [relayStatus removeAllObjects];
    [bboxType removeAllObjects];
    [self displaySavedBboxes];
    [self displaySavedOfflineBboxes];
    return;}
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self toCheckIfDataServiceIsOn];
    [self checkCountOfShouts];
    [self showCountOnNotificationsTab];
    [self showCountOnChannelTab];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [self disableLocation];
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
    self.mapView = nil;

    int timeStamp = (int)[TimeConverter timeStamp];
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"discover",@"text",nil];
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Discover",@"log_category",@"on_exit_discover",@"log_sub_category",@"discover",@"text",@"",@"category_id",detaildict,@"details",nil];
    [AppManager saveEventLogInArray:postDictionary];
}

-(void)channelBadgeAdded:(NSNotificationCenter*)notification{
    [self showCountOnChannelTab];
}

- (void)shoutArrivedInNotification:(NSNotification *)notification{
    [self checkCountOfShouts];
}

- (void)applicationIsActive:(NSNotification *)notification
{
    if (![AppManager isInternetShouldAlert:NO])
        [self performSelector:@selector(toCheckIfDataServiceIsOn) withObject:nil afterDelay:5];
    else
        [self performSelector:@selector(comeInForeground) withObject:nil afterDelay:5];
    NSLog(@"Application Did Become Active");
}

-(void)toCheckIfDataServiceIsOn{
    if (![AppManager isInternetShouldAlert:NO]){
        _vw_banner.hidden = NO;
        _vw_banner.alpha = 0;
        [UIView animateWithDuration:6 delay:1
                              options: UIViewAnimationOptionAutoreverse |                 UIViewAnimationOptionRepeat|  UIViewAnimationOptionAllowUserInteraction
                              animations:^{
                                   _vw_banner.alpha = 1;}
                              completion:nil];
        _bannerLabel.text = @"Please turn-on Data services to download the most updated map. Be aware Buki-Boxes could have been relocated from your last map update.";}
    else{
        _vw_banner.hidden =  YES;}
}

-(void)hitEventLogApi:(NSString*)str status:(NSString*)status{
    int timeStamp = (int)[TimeConverter timeStamp];
    NSMutableDictionary *postDictionary;
    NSMutableDictionary *detaildict;
    if([str isEqualToString:@"Access"]){
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"discover",@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Discover",@"log_category",@"on_access_discover",@"log_sub_category",@"discover",@"text",@"",@"category_id",detaildict,@"details",nil];}
    else{
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:status,@"text",nil];
         postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Discover",@"log_category",@"on_click_buki",@"log_sub_category",status,@"text",@"",@"category_id",detaildict,@"details",nil];}
    [AppManager saveEventLogInArray:postDictionary];
}

-(void)enableLocationPermission{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LocationManager sharedManager] startWithCompletion:^(BOOL success, NSError *error, double latetude, double longitude, double angle) {
            DLog(@"latiutde is %f",latetude);
            DLog(@"latiutde is %f",longitude);
            if (latetude!= 0.00000 && longitude != 0.00000) {
                NSString *str = [NSString stringWithFormat:@"%f%@%f",
                                 latetude,@",",longitude];
                isUserLocation = YES;
                [self addPinWithTitle:@"User" AndCoordinate:str andStatus:@"user" bboxType:@""];
                [self disableLocation];}}];});
    [self getRelayList];
}

-(void)getRelayList
{
    NSArray *arr = [[NSArray alloc]initWithObjects:@"1", nil];
    NSMutableDictionary * postDictionary = [[NSMutableDictionary alloc]init];
    [postDictionary setObject:arr forKey:@"group_id"];
    if ([AppManager isInternetShouldAlert:NO]){
        //show loader...
        [LoaderView addLoaderToView:self.view];
        NSString *url = [NSString stringWithFormat:@"%@%@",BASE_API_URL,GET_LIST_OF_RELAYS_URL];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:url];}
}

-(void)handleTabBadge{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showCountOnNotificationsTab];
    });
}

-(void)gotSettings
{
    if ([PrefManager shouldOpenSonar] == NO){
        [AppManager showAlertWithTitle:@"" Body:k_permissionAlertSonar];
        [self.navigationController popToRootViewControllerAnimated:YES];}
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];}

- (void)comeInForeground{
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                    timeout:10.0
                    block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                        if(status == INTULocationStatusServicesDenied  || status == INTULocationStatusServicesDisabled){
                        isUserLocation = NO;
                        _vw_banner.alpha = 0;
                        [UIView animateWithDuration:6 delay:1
                                options: UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction
                                animations:^{
                                     _vw_banner.alpha = 1;} completion:nil];
                        _bannerLabel.text= @"Please turn-on location services for best user experience";
                        _vw_banner.hidden = NO;}
                        if(status == INTULocationStatusSuccess){
                        isUserLocation = YES;
                        _vw_banner.hidden =  YES;}
                        DLog(@"%ld", (long)status);}];
}

- (void)disableLocation{
    [[LocationManager sharedManager] stop];}

-(void)initConstraints{
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    id views = @{
                 @"mapView": self.mapView
                 };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
}

#pragma mark-
#pragma mark- Map View Methods
-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    if ([annotation.subtitle containsString:@"online"]){
        if([AppManager isInternetShouldAlert:NO]){
            annotationView.image = [UIImage imageNamed:@"onlineLocationIcon.png"];}
        else{
            annotationView.image = [UIImage imageNamed:@"blackIcon.png"];}
            }
    else  if ([annotation.subtitle containsString:@"offline"]){
        annotationView.image = [UIImage imageNamed:@"offlinelocationIcon.png"];}
    else if ([annotation.subtitle isEqualToString:@"user"]){
        User *user = [[Global shared] currentUser];
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(0, 0, 35, 35);
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        imageView.layer.masksToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:user.picUrl] placeholderImage:[UIImage imageNamed:placeholderUser]];
        if (![imageView isDescendantOfView:annotationView]){
            [annotationView addSubview:imageView];}}
    else{
        annotationView.image = [UIImage imageNamed:@"blackIcon.png"];}
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    MKPointAnnotation *mapPin = view.annotation;
    [self hitEventLogApi:mapPin.title status:mapPin.subtitle];
    NSArray * dataArray = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"RelayLocation"];
    [relayCoord removeAllObjects];
    [relayName removeAllObjects];
    [relayStatus removeAllObjects];
    [bboxType removeAllObjects];
    DLog(@"Selected index %ld and value %@",(long)selectedIndex,[dataArray objectAtIndex:selectedIndex]);
    for (NSDictionary *location in dataArray){
        NSString *lat = [location objectForKey:@"Latitude"];
        NSString *longitutude = [location objectForKey:@"Longitude"];
        NSString *str = [NSString stringWithFormat:@"%@,%@",lat,longitutude];
        NSString *name = [location objectForKey:@"Name"];
        [relayCoord addObject:str];
        [relayName addObject:name];
        [relayStatus addObject:[location objectForKey:@"status"]];
        [bboxType addObject:[location objectForKey:@"bukiboxType"]];}
    if([relayName containsObject:mapPin.title]){
        for(int i =0; i<relayName.count;i++){
            NSUInteger selectedIndexV = [relayName indexOfObject:mapPin.title];
            if(selectedIndex == selectedIndexV){
            [self scrollCarouselToIndex];
            [iCarousel_obj reloadData];
            return;}
        }}
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disclosure Pressed" message:@"Click Cancel to Go Back" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark iCarousel methods
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return listOfRelays.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{
    view.clipsToBounds=YES;
    UILabel *lbl_BukiBox,*lbl_loc;
    UIImageView *lbl_Icon;
    view.userInteractionEnabled=YES;
    //create new view if no view is available for recycling
    if (view == nil){
        view = [[UIView alloc] init];
        view.contentMode=UIViewContentModeScaleToFill;
        CGRect rect = CGRectZero;
        if(IS_IPHONE_X)
            rect = CGRectMake(0, 0,SCREEN_WIDTH-115*kRatioIPhoneX,carousel.frame.size.height-20);
        else
            rect = CGRectMake(0, 0,SCREEN_WIDTH-140*kRatio,carousel.frame.size.height);
        view.frame=rect;
        view.layer.cornerRadius=20.0;
        view.clipsToBounds=YES;
        view.layer.shadowColor=[UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0].CGColor ;
        view.layer.shadowOffset = CGSizeMake(0.3f,0.3f);
        view.layer.masksToBounds = YES;
        view.layer.shadowRadius =1.0;
        view.layer.shadowOpacity =1.0;
        view.userInteractionEnabled=YES;
        
        //label for bukiBox Icon using ttf
        lbl_Icon = [[UIImageView alloc] init];
        [lbl_Icon setImage:[UIImage imageNamed:@"BukiChatIcon"]];
        CGFloat widthOfImg = 50*kRatio;
        CGFloat heightOfImg = 50*kRatio;
        CGFloat x = view.frame.size.width/2 - widthOfImg/2;
        [lbl_Icon setFrame:CGRectMake(x , 15*kRatio,widthOfImg, heightOfImg)];
        lbl_Icon.layer.cornerRadius = lbl_Icon.frame.size.width/2;
        lbl_Icon.layer.masksToBounds =  YES;
        [view addSubview:lbl_Icon];
        
        //label for bukiBox listing
        lbl_BukiBox = [[UILabel alloc] init];
        [lbl_BukiBox setFrame:CGRectMake(10,lbl_Icon.frame.size.height+20*kRatio, view.frame.size.width-20, 40*kRatio)];
        NSString *bboxName = [[listOfRelays objectAtIndex:index]relayName];
        //        NSString *bboxName = [[[listOfRelays objectAtIndex:index]relayName] stringByAppendingString:@"-("];
        //        bboxName = [bboxName stringByAppendingString:[[listOfRelays objectAtIndex:index]bboxType]];
        //        bboxName = [bboxName stringByAppendingString:@")"];
        lbl_BukiBox.text = bboxName;
        lbl_BukiBox.textColor = [UIColor whiteColor];
        lbl_BukiBox.tag=2;
        lbl_BukiBox.textAlignment = NSTextAlignmentCenter;
        lbl_BukiBox.numberOfLines = 0;
        if(IS_IPHONE_X)
            lbl_BukiBox.font = [UIFont fontWithName:@"Aileron-SemiBold" size:15*kRatioIPhoneX];
        else
            lbl_BukiBox.font = [UIFont fontWithName:@"Aileron-SemiBold" size:15*kRatio];
        [lbl_BukiBox setBackgroundColor:[UIColor clearColor]];
        [view addSubview:lbl_BukiBox];
        
        //label for location
        //        lbl_loc = [[UILabel alloc] init];
        //        [lbl_loc setFrame:CGRectMake(10,lbl_BukiBox.frame.origin.y +lbl_BukiBox.frame.size.height, view.frame.size.width-20, 20*kRatio)];
        //        lbl_loc.text =  [[listOfRelays objectAtIndex:index]geolocation];
        //        lbl_loc.textColor = [UIColor lightGrayColor];
        //        lbl_loc.tag=2;
        //        lbl_loc.textAlignment = NSTextAlignmentCenter;
        //        lbl_loc.font = [UIFont fontWithName:@"Aileron-Regular" size:15*kRatio];
        //        [lbl_loc setBackgroundColor:[UIColor clearColor]];
        //        [view addSubview:lbl_loc];
        
        
    }
    else{
        
        //        lbl_BukiBox=(UILabel *)[view viewWithTag:2];
        //        imageview = (UIImageView *)[view viewWithTag:1];
        
    }
    view.backgroundColor = [Common colorwithHexString:@"00000" alpha:0.8];
    return view;
}


- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    CGFloat distance = 130.0f; //number of pixels to move the items away from camera
    CGFloat z = - fminf(1.0f, fabs(offset)) * distance;
    return CATransform3DTranslate(transform, offset * iCarousel_obj.itemWidth, 0.0f, z);
    
}
- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return SCREEN_WIDTH-140*kRatio;
}
- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
    UIImageView *imageview = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
//        //don't do anything specific to the index within
//        //this `if (view == nil) {...}` statement because the view will be
//        //recycled and used with other index values later
//        //view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,150.0f,150.0f)];
//        ((UIImageView *)view).image = [UIImage imageNamed:@"UserIcon"];//[UIImage imageNamed:[[_array_UserForCarousel objectAtIndex:index] valueForKey:@"image"]];
//        view.backgroundColor = [UIColor greenColor]; // by nim
//        view.contentMode = UIViewContentModeCenter;
//        
//        imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"UserIcon"]];//[[UIImageView alloc] initWithImage:[UIImage imageNamed:[[_array_UserForCarousel objectAtIndex:index]valueForKey:@"image"]]];
//        imageview.frame = view.bounds;
//        imageview.layer.cornerRadius =  imageview.frame.size.height/2;
//        imageview.tag = 1;
//        [view addSubview:imageview];
//        imageview.userInteractionEnabled=YES;
//        
        
        
    }else{
        //get a reference to the label in the recycled view
        
        imageview = (UIImageView *)[view viewWithTag:1];
    }
    
    
    
    return view;
}
//- (void)carousel:(iCarousel *)carousel itemMoveWithIndex:(NSInteger)index{
//    
//    [self moveItemToTop:index];
//    
//    
//    
//}
//- (void)carousel:(iCarousel *)carousel itemMoveAtBottomWithIndex:(NSInteger)index
//{
//    [self resetAlpha];
//    
//    NSLog(@"asdasdasdasd");
//    [listArray removeObjectAtIndex:index];
//    [self.iCarousel_activityDetail removeItemAtIndex:index animated:YES];
//}
//- (void)moveItemToTop:(NSInteger)itemIndex{
//    
//    
//    index_SwippedImage = itemIndex;
//    
//    [self resetAlpha];
//    [listArray removeObjectAtIndex:itemIndex];
//    [self.iCarousel_activityDetail removeItemAtIndex:itemIndex animated:YES];
//    leftBarButton.enabled=NO;
//    [self performSelector:@selector(showItsMatchView) withObject:self afterDelay:0.7];
//    
//    //[_iCarousel_activityDetail reloadData];
//}
//-(void)carouselItemsMoveUp:(iCarousel *)carousel andValue:(float)value{
//    // NSLog(@"value=%f",1-(value/100));
//    //if (value>=0) {
//    
//    if (listArray.count>0) {
//        //        [self.button_GreenPlus sendSubviewToBack:self.view];
//        //        [self.button_RedMinus sendSubviewToBack:self.view];
//        
//        self.button_GreenPlus.alpha=0.0;
//        self.button_RedMinus.alpha=0.0;
//        self.button_remove_activity.alpha=0.5;
//        self.button_invite_activity.alpha=0.5;
//        self.label_ActivityName.alpha=0.5;
//        
//    }
//    
//    
//}
//-(void)carouselItemsMoveFinish:(iCarousel *)carousel andValue:(float)value
//{
//    [self resetAlpha];
//}
//-(void)resetAlpha
//{
//    //    [self.view bringSubviewToFront:_button_GreenPlus];
//    //    [self.view bringSubviewToFront:_button_RedMinus];
//    self.button_GreenPlus.alpha=1;
//    self.button_RedMinus.alpha=1;
//    self.button_remove_activity.alpha=1;
//    self.button_invite_activity.alpha=1;
//    self.label_ActivityName.alpha=1;
//}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
            //        case iCarouselOptionWrap:
            //        {
            //            //normally you would hard-code this to YES or NO
            //            return NO;
            //        }
            //        case iCarouselOptionSpacing:
            //        {
            //            //add a bit of spacing between the item views
            //
            //            return value * 1.05f;
            //        }
            //        case iCarouselOptionFadeMax:
            //        {
            //            if (iCarousel_activityDetail.type == iCarouselTypeCustom)
            //            {
            //                //set opacity based on distance from camera
            //                return 0.0f;
            //            }
            //            return value;
            //        }
            //        default:
            //        {
            //            return value;
            //        }
            //    }
            
        case  iCarouselOptionSpacing :
            return 10;
        case iCarouselOptionVisibleItems:
            return listOfRelays.count;
        case  iCarouselOptionTilt:
            return 13.0;
        default:
            return value;
    }
}
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
    selectedIndex = carousel.currentItemIndex;
}
#pragma mark iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    DLog(@"+++Relays count %lu",(unsigned long)listOfRelays.count);
    
    __block NSString *relayNameOfSelectedBukiBox;
    selectedIndex = carousel.currentItemIndex;
    
    if (listOfRelays.count>=selectedIndex)
    {
       RelayObject  *obj = [listOfRelays objectAtIndex:selectedIndex];
        NSString *locationString = obj.geolocation;
        relayNameOfSelectedBukiBox = obj.relayName;
        [self initViews:locationString span:MKCoordinateSpanMake(0.002, 0.002)];
    }
    // find out the current selected annotation
    NSArray *annotations = [mapView selectedAnnotations];
    if (annotations.count>0) {
        for (int i=0; i<[annotations count]; i++)
        {
            // any of the annotation is selected
            // Hide the previous annotation
            [mapView deselectAnnotation:[annotations objectAtIndex:i] animated:YES];
        }
    }else
    {
        // Currently not selected any of the Annotation
    }
    
    // loop to select the selected Buki-Box
    [[mapView annotations] enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         // if Object is kind of class of MKPointAnnotation
         if ([obj isKindOfClass:[MKPointAnnotation class]])
         {
             MKPointAnnotation *mkPoint = (MKPointAnnotation *)obj;
             // if it's title is equal to the selected buki box name
             if ([mkPoint.title isEqualToString:relayNameOfSelectedBukiBox])
             {
                 // select the buki box
                 [mapView selectAnnotation:mkPoint animated:YES];
                 *stop = YES;
             }
         }
     }];
}

#pragma mark - IBAction
- (IBAction)recenter_BtnClicked:(id)sender
{
    [relayCoord removeAllObjects];
    [relayName removeAllObjects];
    [relayStatus removeAllObjects];
    [bboxType removeAllObjects];
    [self displaySavedBboxes];
    [self displaySavedOfflineBboxes];
    return;
    //[AppManager showAlertWithTitle:@"" Body:@"coming soon"];
}
- (IBAction)nextPre_BtnClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger bukiBoxCount = listOfRelays.count;//[grps count];
    
    // handle collectionView scroll
    if (button.tag == 101 ){
        if(selectedIndex > 0){
            selectedIndex -= 1 ;
        }
        // [AppManager showAlertWithTitle:@"" Body:@"Pre Button"];
    }else if (button.tag == 102){
        if(selectedIndex < bukiBoxCount - 1 ){
            selectedIndex += 1 ;
        }
        //[AppManager showAlertWithTitle:@"" Body:@"Next Button"];
    }
    
    [self scrollCarouselToIndex];
    [iCarousel_obj reloadData];
}

-(void)scrollCarouselToIndex{

    [iCarousel_obj scrollToItemAtIndex:selectedIndex animated:true];
}

#pragma mark- Shared Utils Delegate Method

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    DLog(@"responseDict is --- %@",responseDict);
    BOOL status = [[responseDict objectForKey:@"status"] boolValue];
    NSString *msgStr= [responseDict objectForKey:@"status"];
    if (status || [msgStr isEqualToString:@"Success"])
    {
        if ([responseDict objectForKey:@"method"])
        {
            DLog(@"You enterd in the wrong area");
            [LoaderView removeLoader];
        }
        else if([[responseDict objectForKey:@"message"] isEqualToString:@"Default location is available"])
        {
            NSDictionary *dictOfCordinates = [responseDict objectForKey:@"data"];
            
            defaultStringCoordinates = [NSString stringWithFormat:@"%@,%@",[dictOfCordinates objectForKey:@"latitude"],[dictOfCordinates objectForKey:@"longitude"]];
        }
        else
        {
            //parse response
            [LoaderView removeLoader];
            NSMutableDictionary *dictOfRelays = [responseDict objectForKey:@"data"];
            
            
            // Offline Boxes data
            NSArray * offlineSonarArray  = [[NSArray alloc] init];
            offlineSonarArray = [[dictOfRelays objectForKey:@"1"]objectForKey:@"offline"];
            NSString * latValue;
            NSString * longValue;
            contentArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary * dict in offlineSonarArray) {
                NSMutableDictionary * relayInfoDict = [[NSMutableDictionary alloc] init];
                
                NSString * geoLocation = [dict objectForKey:@"geo_location"];
                if ([geoLocation isKindOfClass:[NSNull class]] || [geoLocation isEqualToString:@""])
                {
                    latValue =@"0.0";
                    longValue =@"0.0";
                }
                else {
                    NSArray * latLongValueArray = [geoLocation componentsSeparatedByString:@","];
                    if (latLongValueArray.count>1)
                    {
                        latValue =[latLongValueArray firstObject];
                        longValue =[latLongValueArray lastObject];}}
                
                
               // NSString *deviceName = [dict objectForKey:@"relay_name"];
                NSString *bleMac = [dict objectForKey:@"ble_mac"];
                NSString *bleMaclast4 = @"";
                if(bleMac.length>5){
                    bleMaclast4 = [bleMac substringFromIndex: [bleMac length] - 5];
                }
                NSString *bboxName = [dict objectForKey:@"relay_name"];
                DLog(@"%@",bboxName);
                
                [relayInfoDict setObject:latValue forKey:@"Latitude"];
                [relayInfoDict setObject:longValue forKey:@"Longitude"];
                [relayInfoDict setObject:bboxName forKey:@"Name"];
                [relayInfoDict setObject:@"offline" forKey:@"status"];
                [relayInfoDict setObject:[dict objectForKey:@"bukibox_type"] forKey:@"bboxType"];
                
                [contentArray addObject:relayInfoDict];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OfflineRelayLocation"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            [self getOfflineLocations:YES];
            
            // online Sonars
            
            [listOfRelays removeAllObjects];
            //          [self addAllPins];
            
            
            // Get Online Boxes Data
            NSMutableArray * arrayOfRelays = [[dictOfRelays objectForKey:@"1"] objectForKey:@"online"];
            if(arrayOfRelays.count != 0){
            [arrayOfRelays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //                [listOfRelays removeAllObjects];
                
                NSString * geoLoc = [obj objectForKey:@"geo_location"];
                RelayObject *relayObj = [[RelayObject alloc] init];
                
                if ([geoLoc isKindOfClass: [NSNull class]] || [geoLoc isEqualToString:@""])
                    relayObj.geolocation = @"1.342,1.3242";
                else
                    relayObj.geolocation = [obj objectForKey:@"geo_location"];
                NSString * name = [obj objectForKey:@"relay_name"];
                if ([name isKindOfClass: [NSNull class]] || [name isEqualToString:@""])
                    relayObj.relayName = @"Unknown";
                else{
                    relayObj.relayName = [obj objectForKey:@"relay_name"];
                    relayObj.bboxType = [obj objectForKey:@"bukibox_type"];
                    NSString *bleMac = [obj objectForKey:@"ble_mac"];
                    NSString *bleMaclast4 = @"";
                    if(bleMac.length>5){
                        bleMaclast4 = [bleMac substringFromIndex: [bleMac length] - 5];
                    }
                    DLog(@"%@",bleMaclast4);
                    NSString *bboxName = [obj objectForKey:@"relay_name"];
                    DLog(@"%@",bboxName);
                    
                    
                    relayObj.relayMacId = bleMac;
                   // bboxName = [bboxName stringByAppendingString:@"-"];
                    //bboxName = [bboxName stringByAppendingString:bleMaclast4];
                    relayObj.relayName = bboxName;
                }
                relayObj.Status = @"online";
                [listOfRelays addObject:relayObj];
                _carouselView.hidden = NO;
                _recenterButton.hidden =  NO;
                [iCarousel_obj reloadData];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RelayLocation"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            }];
        }
        
                if (listOfRelays.count)
                [self addAllPins];
        }
    }
    else if ([msgStr isEqualToString:@"Error"] && [[responseDict objectForKey:@"message"] isEqualToString:@"No B-Box found ..!"])
    {
        [LoaderView removeLoader];
        _carouselView.hidden = YES;
        _recenterButton.hidden = YES;
    }
    else if([msgStr isEqualToString:@"Default location is not available"])
    {
        defaultStringCoordinates = defaultMapCoordinates;
    }
    else if([msgStr isEqualToString:@"No Application ID!"] || ([msgStr isEqualToString:@"Application not found!"])) {}
    else
    {
        //remove loader
        [LoaderView removeLoader];
        [self getOfflineLocations:NO];
        if(listOfRelays.count == 0){
            _carouselView.hidden = YES;
            _recenterButton.hidden = YES;
        }
        
    }
    
    // display providence area in offline case
    if(defaultStringCoordinates == nil)
        [self initViews:defaultMapCoordinates span:MKCoordinateSpanMake(0 ,1)];
    else
        [self initViews:defaultStringCoordinates span:MKCoordinateSpanMake(0 ,1)];
}

-(void) getOfflineLocations:(BOOL)fromResponse{
    if (fromResponse) {
        
        // Read plist from bundle and get Root Dictionary out of it
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"OfflineLocations" ofType:@"plist"];
        if (!fromResponse)
            contentArray = [[NSArray arrayWithContentsOfFile:plistPath] mutableCopy];
        
        [relayCoord removeAllObjects];
        [relayName removeAllObjects];
        [relayStatus removeAllObjects];
        [bboxType removeAllObjects];
        
        for (NSDictionary *location in contentArray)
        {
            NSString *lat = [location objectForKey:@"Latitude"];
            NSString *longitutude = [location objectForKey:@"Longitude"];
            NSString *str = [NSString stringWithFormat:@"%@,%@",lat,longitutude];
            NSString *name = [location objectForKey:@"Name"];
            NSString *boxType = [location objectForKey:@"bboxType"];
            [relayCoord addObject:str];
            [relayName addObject:name];
            if (!boxType || [boxType isEqualToString:@""]) {
                boxType = @"Public";
            }
            [bboxType addObject:boxType];
            if (!fromResponse)
            {
                if([location objectForKey:@"disable"] != nil)
                    [relayStatus addObject:[location objectForKey:@"disable"]];
            }
            else
            {
                if([location objectForKey:@"status"] != nil)
                    [relayStatus addObject:[location objectForKey:@"status"]];
            }
            
        }
        
        for(int i = 0; i < relayCoord.count; i++)
        {
            
            [self addPinWithTitle:relayName[i] AndCoordinate:relayCoord[i] andStatus:relayStatus[i] bboxType:bboxType[i]];
        }
        
        // if all bookieboxes are offline map move to Providence area
        if (listOfRelays.count == 0 || listOfRelays == nil) {
            
            // if no online box save other wise already saving in online method
            [self saveInDefaults];
            if(defaultStringCoordinates == nil)
                [self initViews:defaultMapCoordinates span:MKCoordinateSpanMake(0 ,1)];
            else
                [self initViews:defaultStringCoordinates span:MKCoordinateSpanMake(0 ,1)];
            
            // [self initViews:@"41.82113,-71.41196" span:MKCoordinateSpanMake(0 ,1)];
            
            //   [self initViews:@"41.82113,-71.41196"];
        }
    }else
    {
        _recenterButton.hidden =  NO;
        if(defaultStringCoordinates == nil)
            [self initViews:defaultMapCoordinates span:MKCoordinateSpanMake(0 ,1)];
        else
            [self initViews:defaultStringCoordinates span:MKCoordinateSpanMake(0 ,1)];
    }
}

-(void)saveInDefaults//:(NSString *)title location:(NSString *)location andStatus:(NSString *)status{
    
{

    NSMutableArray * onlineSonarArray = [[NSMutableArray alloc] init];
    NSString * latValue;
    NSString * longValue;
    for(int i = 0; i < listOfRelays.count; i++) {
        NSMutableDictionary *relayInfoDict = [[NSMutableDictionary alloc] init];
        NSString * geoLocation = [[listOfRelays objectAtIndex:i] geolocation];
        if ([geoLocation isEqual: [NSNull null]] || [geoLocation isEqualToString:@""])
        {
            latValue =@"0.0";
            longValue =@"0.0";
        }
        else {
            NSArray * latLongValueArray = [geoLocation componentsSeparatedByString:@","];
            if (latLongValueArray.count>1)
            {
                latValue =[latLongValueArray firstObject];
                longValue =[latLongValueArray lastObject];
            }
        }
        NSString *deviceName = [[listOfRelays objectAtIndex:i]relayName];
        NSString *statusOfBox = [[listOfRelays objectAtIndex:i]Status];
        NSString *boxType = [[listOfRelays objectAtIndex:i]bboxType];
        if (latValue)
            [relayInfoDict setObject:latValue forKey:@"Latitude"];
        
        if (longValue)
            [relayInfoDict setObject:longValue forKey:@"Longitude"];

        if (deviceName)
            [relayInfoDict setObject:deviceName forKey:@"Name"];
        
        if (statusOfBox)
            [relayInfoDict setObject:statusOfBox forKey:@"status"];

        if (boxType)
            [relayInfoDict setObject:boxType forKey:@"bukiboxType"];

        if (relayInfoDict) {
            
            [onlineSonarArray addObject:relayInfoDict];

        }
}
    
    [[NSUserDefaults standardUserDefaults] setObject:contentArray forKey:@"OfflineRelayLocation"];
    
    

    [[NSUserDefaults standardUserDefaults] setObject:onlineSonarArray forKey:@"RelayLocation"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)displaySavedBboxes{
    
    NSArray * dataArray = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"RelayLocation"];
    
    [relayCoord removeAllObjects];
    [relayName removeAllObjects];
    [relayStatus removeAllObjects];
    [bboxType removeAllObjects];
    
    for (NSDictionary *location in dataArray)
    {
        NSString *lat = [location objectForKey:@"Latitude"];
        NSString *longitutude = [location objectForKey:@"Longitude"];
        NSString *str = [NSString stringWithFormat:@"%@,%@",lat,longitutude];
        NSString *name = [location objectForKey:@"Name"];
        [relayCoord addObject:str];
        [relayName addObject:name];
        [relayStatus addObject:[location objectForKey:@"status"]];
        [bboxType addObject:[location objectForKey:@"bukiboxType"]];
        
    }
    
    for(int i = 0; i < relayCoord.count; i++)
    {
        [self addPinWithTitle:relayName[i] AndCoordinate:relayCoord[i] andStatus:relayStatus[i] bboxType:bboxType[i]];
    }
    
    // display providence area in offline case
    if(defaultStringCoordinates == nil)
        [self initViews:defaultMapCoordinates span:MKCoordinateSpanMake(0 ,1)];
    else
        [self initViews:defaultStringCoordinates span:MKCoordinateSpanMake(0 ,1)];
}


- (void)displaySavedOfflineBboxes {
    contentArray = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"OfflineRelayLocation"];
    
    
    
    [relayCoord removeAllObjects];
    [relayName removeAllObjects];
    [relayStatus removeAllObjects];
    [bboxType removeAllObjects];
   
    for (NSDictionary *location in contentArray)
    {
        NSString *lat = [location objectForKey:@"Latitude"];
        NSString *longitutude = [location objectForKey:@"Longitude"];
        NSString *str = [NSString stringWithFormat:@"%@,%@",lat,longitutude];
        NSString *name = [location objectForKey:@"Name"];
        [relayCoord addObject:str];
        [relayName addObject:name];
        [relayStatus addObject:[location objectForKey:@"status"]];
        [bboxType addObject:[location objectForKey:@"bboxType"]];
        
    }
    
    for(int i = 0; i < relayCoord.count; i++)
    {
    [self addPinWithTitle:relayName[i] AndCoordinate:relayCoord[i] andStatus:relayStatus[i] bboxType:bboxType[i]];
    
    }

}


- (IBAction)closebanner:(id)sender
{
    [UIView animateWithDuration:1
                          delay:0
                        options: UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat |UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //  _vw_banner.alpha = 0;
                         _vw_banner.hidden = YES;
                     } completion:nil];
}



#pragma mark- Shout Encountered
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
        //[self updateBadgeForGroup];
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

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType
{
    if([self.navigationController.topViewController isKindOfClass:[SonarViewController class]])//crash fix , please dont remove this code
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

-(void)initViews:(NSString *)strCoordinate  span:(MKCoordinateSpan)spnSIze
{
    strCoordinate = [strCoordinate stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // convert string into actual latitude and longitude values
    NSArray *components = [strCoordinate componentsSeparatedByString:@","];
    
    double latitude = [components[0] doubleValue];
    double longitude = [components[1] doubleValue];
    
    
    MKCoordinateRegion region;
    region.center.latitude = latitude;
    region.center.longitude = longitude;
    
    region.span= spnSIze;
    //    MKCoordinateSpanMake(0.0105, 0.0105)
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:TRUE];
}

-(void)addAllPins
{
    [relayCoord removeAllObjects];
    [relayName removeAllObjects];
    [relayStatus removeAllObjects];
    [bboxType removeAllObjects];
    
    
    for(int j = 0; j < listOfRelays.count; j++ ){
        
        NSString *geoLoc = [[listOfRelays objectAtIndex:j]geolocation];
        NSString *name = [[listOfRelays objectAtIndex:j]relayName];
        NSString * status = [[listOfRelays objectAtIndex:j]Status];
        NSString *typeOfBox = [[listOfRelays objectAtIndex:j]bboxType];
        [relayCoord addObject:geoLoc];
        [relayName addObject:name];
        [relayStatus addObject:status];
        [bboxType addObject:typeOfBox];
    }
    
    for(int i = 0; i < relayCoord.count; i++)
    {
        [self addPinWithTitle:relayName[i] AndCoordinate:relayCoord[i] andStatus:relayStatus[i] bboxType:bboxType[i]];
    }
    [self saveInDefaults];
    
    
    //   int count = (int)relayCoord.count/2;
    if (relayCoord.count) {
    }
}

-(void)addPinWithTitle:(NSString *)title AndCoordinate:(NSString *)strCoordinate andStatus:(NSString *)status bboxType:(NSString*)bboxTypes
{
    // clear out any white space
    strCoordinate = [strCoordinate stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // convert string into actual latitude and longitude values
    NSArray *components = [strCoordinate componentsSeparatedByString:@","];
    
    if (components.count<2) {
        return;
    }
    double latitude  = [components[0] doubleValue];
    double longitude = [components[1] doubleValue];
    
    if (latitude == 0.0 && longitude == 0.0) {
        
        latitude  = 1.073663;
        longitude = 1.445555;
    }
    // setup the map pin with all data and add to map view
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    MKPointAnnotation *mapPin = [[MKPointAnnotation alloc] init];
    
    mapPin.title = title;
    if (![status isEqualToString:@"disable"]){
        if(![bboxTypes isEqualToString:@""]){
            NSString *stringOfBbox;
            stringOfBbox = status;
            //            stringOfBbox = [status stringByAppendingString:@"("];
            //            stringOfBbox = [stringOfBbox stringByAppendingString:bboxTypes];
            //            stringOfBbox = [stringOfBbox stringByAppendingString:@")"];
            mapPin.subtitle = stringOfBbox;
            
        }
        else{
            mapPin.subtitle = @"user";
        }
        
    }
    if([status isEqualToString:@"online"] || [status isEqualToString:@"offline"]){
        
    }
    mapPin.coordinate = coordinate;
    
    [self.mapView addAnnotation:mapPin];
}


@end
