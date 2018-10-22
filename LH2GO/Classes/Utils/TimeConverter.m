//
//  TimeConverter.m
//  LoudHailer
//
//  Created by Prakash Raj on 14/08/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "TimeConverter.h"

@implementation TimeConverter

+ (time_t)timeStamp {
    
    NSDate *dt = [NSDate dateWithTimeIntervalSinceNow:0];
    return [TimeConverter timeStampWithDate:dt];   // in sec.
}

+ (time_t)timeStampWithDate:(NSDate *)dt {
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:unit  fromDate:dt];
    
    time_t unixTime = (time_t) [[[NSCalendar currentCalendar] dateFromComponents:comps] timeIntervalSince1970];
    
   // NSLog(@"timestamp : %li", unixTime);
    
    return unixTime;   // in sec.
}

+ (NSDate *)dateFromTimestamp: (time_t)stamp {
    NSDate *dt = [[NSDate alloc] initWithTimeIntervalSince1970:stamp];
    return dt;
}

@end
