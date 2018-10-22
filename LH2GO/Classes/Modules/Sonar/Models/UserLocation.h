//
//  UserLocation.h
//  LH2GO
//
//  Created by Sumit Kumar on 11/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// - Store User's Location....
@interface UserLocation : NSObject

@property (nonatomic, strong) NSString *uId; // in case the person is unknown.
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, assign) double distance;
@property (nonatomic, strong) User *person;

+ (UserLocation *)userLocationAlongPing:(Ping *)ping;
@end
