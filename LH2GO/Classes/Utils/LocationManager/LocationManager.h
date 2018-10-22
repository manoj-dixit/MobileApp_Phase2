//
//  KLLocationManager.h
//  KLoof
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright (c) 2016. All rights reserved.
//
//  KLLocationManager : The class is created to check and update location simultaniously.
//  Comment :  Must add core location framework.

#import <Foundation/Foundation.h>


@interface LocationManager : NSObject

//  @method : to return shared instance.
+ (LocationManager *)sharedManager;

//  @method : to get latitude/longitude.
+ (double)latitude;
+ (double)longitude;
+ (double)angle;
/*
 *  @method : to start updation of location.
 *  @param : block - exectuble code block on completion.
 */
- (void)startWithCompletion:(void (^)(BOOL success, NSError *error, double latetude, double longitude, double angle))block;

//  @method : to stop all the processes if any running.
- (void)stop;

@end
