//
//  TimeConverter.h
//  LoudHailer
//
//  Created by Prakash Raj on 14/08/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeConverter : NSObject

+ (time_t)timeStamp; //  UTCFormateDate
+ (time_t)timeStampWithDate:(NSDate *)dt;
+ (NSDate *)dateFromTimestamp: (time_t)stamp;

@end
