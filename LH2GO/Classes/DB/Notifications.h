//
//  Notifications.h
//  LH2GO
//
//  Created by Arpit Toshniwal on 22/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notifications : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * notId;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber  *type;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Network *network;
@property (nonatomic,retain) NSNumber * status;



/*! @method : get a Notification with id */
+ (Notifications *)notificationWithId:(NSString *)nId shouldInsert:(BOOL)insert;

/*! @method : to insert a Notification to DB. */
+ (Notifications *)addNotWithDict:(NSDictionary *)dict;


@end
