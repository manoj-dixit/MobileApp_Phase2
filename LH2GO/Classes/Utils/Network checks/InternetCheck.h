//
//  InternetCheck.h
//  Kloof
//
//  Created by Sachin Kamboj on 21/05/13.
//  Copyright (c) 2013 Segment technologies. All rights reserved.
//  Class checks whether the device is connected to internet or not

#import <Foundation/Foundation.h>

@class Reachability;

@interface InternetCheck : NSObject {
     Reachability *hostReach;
}

@property (nonatomic, assign) BOOL internetWorking;

/*
 *	@method      	: sharedInstance
 *	@parameters		:
 *	@return			: Object of the class
 *	@description	: Creates the singleton object of the class
 */
+ (InternetCheck *) sharedInstance;

@end
