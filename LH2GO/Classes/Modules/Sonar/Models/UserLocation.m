//
//  UserLocation.m
//  LH2GO
//
//  Created by Sumit Kumar on 11/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "UserLocation.h"
#import "User.h"


@implementation UserLocation

+ (UserLocation *)userLocationAlongPing:(Ping *)ping
{
    UserLocation *usr = [UserLocation new];
    usr.uId = ping.responderId;
    usr.location = CLLocationCoordinate2DMake(ping.lat, ping.lan);
    usr.person = [User userWithId:ping.responderId shouldInsert:YES];
    return usr;
}

@end
