//
//  EventLog.h
//  LH2GO
//
//  Created by Linchpin on 8/21/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface EventLog : NSManagedObject

@property (nonatomic, retain) NSString * channelContentId;
@property (nonatomic, retain) NSString * channelId;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * shoutId;
@property (nonatomic, retain) NSString * timeStamp;
@property (nonatomic, retain) NSString *logCat;
@property (nonatomic, retain) NSString *logSubCat;
@property (nonatomic, retain) NSString *text;

/*! @method : to insert event to DB. */
+ (EventLog *)addEventWithDict:(NSDictionary *)dict ;

@end
