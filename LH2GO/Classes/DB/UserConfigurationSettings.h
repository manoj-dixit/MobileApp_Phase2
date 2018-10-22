//
//  UserConfigurationSettings.h
//  LH2GO
//
//  Created by Manoj Dixit on 16/02/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface UserConfigurationSettings : NSManagedObject

//"default_network": 1,
//"default_group": 1,
//"allow_user": 0,
//"server_backup": 0,
//"phone_backup": 0,
//"messaging": 0,
//"sonar": 0,
//"allow_channels": 0

@property (nonatomic, retain) NSString * default_network;
@property (nonatomic, retain) NSString * default_group;
@property (nonatomic, retain) NSString * allow_user;
@property (nonatomic, retain) NSString * server_backup;
@property (nonatomic, retain) NSString * phone_backup;
@property (nonatomic, retain) NSString * messaging;
@property (nonatomic,retain) NSString *sonar;
@property (nonatomic, retain) NSString *allow_channels;


+ (UserConfigurationSettings *)userWithId:(NSDictionary *)settingDict shouldInsert:(BOOL)insert;

@end
