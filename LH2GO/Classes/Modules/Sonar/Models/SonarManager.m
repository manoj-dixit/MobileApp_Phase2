//
//  SonarManager.m
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "SonarManager.h"
#import "TimeConverter.h"
#import "SonarRequest.h"
#import "SonarResponce.h"
#import "BSONIdGenerator.h"
#import "BLEManager.h"
#import "User.h"
#import "UserLocation.h"
#import <CoreLocation/CoreLocation.h>

@interface SonarManager()<CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) NSInteger reqTimestamp;

@end

@implementation SonarManager

+ (instancetype)sharedManager
{
    static SonarManager *sharedManager = nil;
    @synchronized(self)
    {
        if(!sharedManager)
        {
            sharedManager = [[SonarManager alloc] init];
            sharedManager.sonarUserResults = [[NSMutableArray alloc] init];
        }
    }
    return sharedManager;
}

- (void)initiateSonarRequest
{
    if (self.currectRequstedSonarId.length>0)
    {
        return;
    }
    //To initialize the sonar request and brodcast for next 15 seconds.
    NSInteger diff = (NSInteger) [TimeConverter timeStamp]-_reqTimestamp;
    if(diff <= k_MAX_WAIT_TIME)
    {
        // since we just requested ignore - alert required.
        return;
    }
    [self flushSonarReq];
    _locationManager = [[CLLocationManager alloc] init];
    [self getCurrentLocation];
    SonarRequest *sonarReq = [[SonarRequest alloc] init];
    sonarReq.sonarId = [BSONIdGenerator generate];
    sonarReq.requstType = SonarTypeRequest;
    self.currectRequstedSonarId = sonarReq.sonarId;
    NSData *data = [SonarRequest getSonarRequestData:sonarReq];
    [[BLEManager sharedManager] brodcastSonarObject:data];
    [self performSelector:@selector(initiateSonarUIupdationAfter15Seconds) withObject:nil afterDelay:k_MAX_WAIT_TIME+1];
}

- (void)initiateSonarUIupdationAfter15Seconds
{
    self.currectRequstedSonarId = @"";
    [self filterSonarResponceUsers];
}

- (void)flushSonarReq
{
    [[SonarManager sharedManager].sonarUserResults removeAllObjects];
    [self.knownCurrentUsers removeAllObjects];
    [self.unKnownCurrentUsers removeAllObjects];
}

- (void)filterSonarResponceUsers
{
    DLog(@"%s",__PRETTY_FUNCTION__);
    //known and unknown
    NSMutableArray *arrKnown = [NSMutableArray new];
    NSMutableArray *arrUnKnown = [NSMutableArray new];
    NSMutableArray *allUsers = [SonarManager sharedManager].sonarUserResults;
    for (int i = 0; i < allUsers.count; i++)
    {
        @autoreleasepool
        {
            SonarResponce *sonRes = [allUsers objectAtIndex:i];
            UserLocation *userLocation = [[UserLocation alloc] init];
            userLocation.uId = [NSString stringWithFormat:@"%lld", sonRes.targetUserId];
            DLog(@"Sonar %f %f",sonRes.latitude, sonRes.longitude);
            userLocation.location = CLLocationCoordinate2DMake(sonRes.latitude, sonRes.longitude);
            userLocation.person = [User userWithId:userLocation.uId shouldInsert:NO];
            DLog(@"%f %f %f %f", sonRes.latitude,sonRes.longitude,_userLatitude,_userLongitude);
            if ((sonRes.latitude>0&&sonRes.longitude>0&&_userLatitude>0&&_userLongitude>0) || (sonRes.latitude<0&&sonRes.longitude<0&&_userLatitude<0&&_userLongitude<0) || (sonRes.latitude<0&&sonRes.longitude>0&&_userLatitude<0&&_userLongitude>0) || (sonRes.latitude>0&&sonRes.longitude<0&&_userLatitude>0&&_userLongitude<0) )
            {
                [arrKnown addObject:userLocation];
            }
            else if ((sonRes.latitude == 0 && sonRes.longitude == 0) || (_userLatitude == 0 &&_userLongitude == 0)) {}
            else
            {
                 [arrUnKnown addObject:userLocation];
            }
        }
    }
    self.knownCurrentUsers = arrKnown;
    self.unKnownCurrentUsers = arrUnKnown;
    // broadcast a notification (request finished).
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinishSonarPingAllReq object:nil userInfo:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    DLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil)
    {
        _userLongitude = currentLocation.coordinate.longitude;
        _userLatitude = currentLocation.coordinate.latitude;
    }
}

-(void)getCurrentLocation
{
    DLog(@"%s",__PRETTY_FUNCTION__);
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter=kCLDistanceFilterNone;
  
      
 //   [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestAlwaysAuthorization];
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingLocation];
}

@end
