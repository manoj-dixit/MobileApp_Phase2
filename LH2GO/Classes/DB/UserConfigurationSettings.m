//
//  UserConfigurationSettings.m
//  LH2GO
//
//  Created by Manoj Dixit on 16/02/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "UserConfigurationSettings.h"

@implementation UserConfigurationSettings

@dynamic default_network;
@dynamic default_group;
@dynamic allow_user;
@dynamic server_backup;
@dynamic phone_backup;
@dynamic messaging;
@dynamic allow_channels;
@dynamic sonar;

+ (UserConfigurationSettings *)userWithId:(NSDictionary *)settingDict shouldInsert:(BOOL)insert
{
    UserConfigurationSettings *userConfigurationSettings;
    
    if(insert)
    {
   userConfigurationSettings =  [NSEntityDescription insertNewObjectForEntityForName:@"UserConfigurationSettings" inManagedObjectContext:[App_delegate xyz]];
    }
    //"default_network": 1,
    //"default_group": 1,
    //"allow_user": 0,
    //"server_backup": 0,
    //"phone_backup": 0,
    //"messaging": 0,
    //"sonar": 0,
    //"allow_channels": 0
    
    // default network
    if ([settingDict objectForKey:@"default_network"]) {
        userConfigurationSettings.default_network = [NSString stringWithFormat:@"%@",[settingDict objectForKey:@"default_network"]];
    }
    
    // default group
    if ([settingDict objectForKey:@"default_group"]) {
        userConfigurationSettings.default_group = [NSString stringWithFormat:@"%@",[settingDict objectForKey:@"default_group"]];
    }
    
    // allow user
    if ([settingDict objectForKey:@"allow_user"]) {
        userConfigurationSettings.allow_user =[NSString stringWithFormat:@"%@",[settingDict objectForKey:@"allow_user"]];
    }

    // server backup
    if ([settingDict objectForKey:@"server_backup"]) {
        userConfigurationSettings.server_backup = [NSString stringWithFormat:@"%@",[settingDict objectForKey:@"server_backup"]];
    }

    // phone backup
    if ([settingDict objectForKey:@"phone_backup"]) {
        userConfigurationSettings.phone_backup = [NSString stringWithFormat:@"%@",[settingDict objectForKey:@"phone_backup"]];
    }

    // messaging
    if ([settingDict objectForKey:@"messaging"]) {
        userConfigurationSettings.messaging = [NSString stringWithFormat:@"%@",[settingDict objectForKey:@"messaging"]];
    }

    // sonar
    if ([settingDict objectForKey:@"sonar"]) {
        userConfigurationSettings.sonar = [NSString stringWithFormat:@"%@",[settingDict objectForKey:@"sonar"]];
    }
    
    // allow chanels
    if ([settingDict objectForKey:@"allow_channels"]) {
        userConfigurationSettings.allow_channels = [NSString stringWithFormat:@"%@",[settingDict objectForKey:@"allow_channels"]];
    }
    
    // save the data into the core data base
    [CoreDataManager saveContext];
    
    return userConfigurationSettings;
}
@end
