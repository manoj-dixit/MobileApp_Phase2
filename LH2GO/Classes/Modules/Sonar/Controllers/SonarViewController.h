//
//  SonarViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BaseViewController.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "UserConfigurationSettings.h"


@interface SonarViewController : BaseViewController <MKMapViewDelegate>

@property  BOOL isUserSettingRestrict;
@property (weak, nonatomic) IBOutlet UIView *carouselView;
@property (weak, nonatomic) IBOutlet UIView *vw_banner;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *bannerLabel;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;
@property (weak, nonatomic) IBOutlet UIButton *recenterButton;

//- (IBAction)hideBanner:(id)sender;

- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType;

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick;

-(void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground;

@end
