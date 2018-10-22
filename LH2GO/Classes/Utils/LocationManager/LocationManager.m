//
//  KLLocationManager.m
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright (c) 2016 LH2GO. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "INTULocationManager.h"

/*
 * @block : to perform task on completion.
 * @arg : success - provide the result status YES/NO.
 * @arg : error - error if found
 * @arg : latetude - latitude of location.
 * @arg : longitude - longitude of location.
 */
typedef void (^CallBackBlock)(BOOL success, NSError *error, double latetude, double longitude, double angle);


@interface LocationManager () <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
}

@property (nonatomic, assign) double latitude, longitude, angle;

@end


@implementation LocationManager

@synthesize latitude, longitude, angle;

#pragma mark - Class methods
// @method : to return shared instance.
+ (LocationManager *)sharedManager {
    static LocationManager *manager = nil;
    @synchronized (self) {
        if (!manager) {
            manager = [[LocationManager alloc] init];
        }
    }
    return manager;
}

// @method : to get latitude/longitude.
+ (double)latitude {
    return [[LocationManager sharedManager] latitude];
}

+ (double)longitude {
    return [[LocationManager sharedManager] longitude];
}

+ (double)angle {
    return [[LocationManager sharedManager] angle];
}


// @method : to start updation of location.
- (void)startWithCompletion:(void (^)(BOOL success, NSError *error, double latetude, double longitude, double angle)) block
{
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
   // [locMgr requestAuthorizationIfNeeded]; ramayash
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:10.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 self.latitude = currentLocation.coordinate.latitude;
                                                 self.longitude = currentLocation.coordinate.longitude;
                                                 self.angle = currentLocation.course;
                                                 if (block) {
                                                     block(NO, nil, self.latitude, self.longitude, self.angle);
                                                 }
                                             }
                                             else {
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                                 self.latitude = 0;
                                                 self.longitude = 0;
                                                 self.angle = 0;
                                                 if (block) {
                                                     block(NO, nil, self.latitude, self.longitude, self.angle);
                                                 }
                                             }
                                         }];

}

// @method : to stop all the processes if any running.
- (void)stop {
    
}

-(void)dealloc{
    
}

@end
