//
//  NotificationInfo.m
//  LH2GO
//
//  Created by Sumit Kumar on 01/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "NotificationInfo.h"
#import "TimeConverter.h"
#import "TabBar.h"
#import "GroupsViewController.h"
#import "EmailedUser.h"
#import "BadgeView.h"

static NSString *kUser_Notifications_Key = @"kUser_Notifications_Key";

@implementation NotificationInfo

- (BOOL)isActionAvailable{
    return (self.type == NotfType_groupInvite);
}

- (void)addGroupDataFromDict:(NSDictionary*)res{
    if (self.type == NotfType_groupInvite){}
}

- (void)addGroupIfUserAcceptRequest{
    if (self.type == NotfType_groupInvite){
        Group *grp = [Group groupWithId:_tempGrId shouldInsert:YES isP2PContact:NO isPendingStatus:NO];
        if (grp) {
            grp.grName = _tempGrName;
            grp.picUrl = _tempGrpPic;
            [grp addUsersObject:[Global shared].currentUser];
            Network *net = [Network networkWithId:_tempNetId shouldInsert:NO];
            grp.network = net;
            [self.sender addOwnedGroupsObject:grp];
            [self.network addUsersObject:[Global shared].currentUser];
            [[Global shared].currentUser addNetworksObject:self.network];
            
            //make changes to localDB as well
            Notifications *notf = [Notifications notificationWithId:_tempniD shouldInsert:NO];
            notf.status = @(1);
            
            // set group
            Group *group = [Group groupWithId:_tempGrId shouldInsert:NO isP2PContact:NO isPendingStatus:NO];
            notf.group = group;
            
            // set user
            User *user = [User userWithId:[Global shared].currentUser.user_id shouldInsert:NO];
            notf.user = user;
            
            // set network
            Network *net1 = [Network networkWithId:_tempNetId shouldInsert:NO];
            notf.network = net1;
            [DBManager save];
            
           [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
        }
    }else if(self.type == 20)
    {
        Group *grp = [Group groupWithId:_tempGrId shouldInsert:YES isP2PContact:YES isPendingStatus:YES];
        if (grp) {
            grp.grName = _tempGrName;
//            if(![_tempGrpPic isKindOfClass:[NSNull null]])
//            {
//            grp.picUrl = _tempGrpPic;
//            }
            [grp addUsersObject:[Global shared].currentUser];
            Network *net = [Network networkWithId:_tempNetId shouldInsert:NO];
            grp.network = net;
            [self.sender addOwnedGroupsObject:grp];
            [self.network addUsersObject:[Global shared].currentUser];
            //[[Global shared].currentUser addNetworksObject:self.network];
            
            //make changes to localDB as well
            Notifications *notf = [Notifications notificationWithId:_tempniD shouldInsert:NO];
            notf.status = @(1);
            
            // set group
            Group *group = [Group groupWithId:_tempGrId shouldInsert:NO isP2PContact:YES isPendingStatus:YES];
            notf.group = group;
            
            // set user
            User *user = [User userWithId:[Global shared].currentUser.user_id shouldInsert:NO];
            notf.user = user;
            
            // set network
         //   Network *net1 = [Network networkWithId:_tempNetId shouldInsert:NO];
          //  notf.network = net1;
            [DBManager save];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
        }
    }
}

- (BOOL)deleteGroupIfUserDeletedFromGroup{
    if (self.type == NotfType_quitMember || self.type == NotfType_groupDeleted)
    {
        Group *grp = [Group groupWithId:self.group.grId shouldInsert:NO isP2PContact:NO isPendingStatus:NO];
        if (grp && self.sender&&[grp.users containsObject:self.sender]){
            [grp removeUsersObject:self.sender];
            [self.sender removeOwnedGroupsObject:grp];
            return YES;
        }
    }
    return NO;
}

+ (NotificationInfo *)notWithDict:(NSDictionary *)dict{
    NotificationInfo *notf = [NotificationInfo new];
    NSString *aStr = [dict objectForKey:@"notification_id"];
    notf.notfId = [AppManager sutableStrWithStr:aStr];
    
    // type
    aStr = [dict objectForKey:@"type"];
    aStr = [AppManager sutableStrWithStr:aStr];
    notf.type = (NotfType)[aStr integerValue];
    
    // message
    aStr = [dict objectForKey:@"message"];
    notf.message = [AppManager sutableStrWithStr:aStr];
    
    // date
    aStr = [dict objectForKey:@"timestamp"];
    aStr = [AppManager sutableStrWithStr:aStr];
    notf.timeStamp = aStr.integerValue;
    notf.sender = [User addUserWithDict:[dict objectForKey:@"Sender"] pic:nil];
    NSDictionary *dictOfSender = [dict objectForKey:@"Sender"];
    NSString *email = [dictOfSender objectForKey:@"email"];
    
    notf.network = [Network addNetworkWithDict:[dict objectForKey:@"Network"]];
    if(notf.type == 4){
        NSDictionary *group = [dict objectForKey:@"Group"];
        NSString *gId = [AppManager sutableStrWithStr:[group objectForKey:@"id"]];
        NSString *gName = [AppManager sutableStrWithStr:[group objectForKey:@"group_name"]];
        NSString *netId = [AppManager sutableStrWithStr:[group objectForKey:@"network_id"]];
        NSString *picurl = [AppManager sutableStrWithStr:[group objectForKey:@"group_photo"]];
        notf.tempGrName = gName;
        notf.tempGrId = gId;
        notf.tempNetId = netId;
        notf.tempGrpPic = picurl;
    }
    else if(notf.type == 3){
        NSDictionary *group = [dict objectForKey:@"Group"];
        Group *grp = [Group groupWithId:[group objectForKey:@"id"] shouldInsert:NO isP2PContact:NO isPendingStatus:NO];
        if(grp){
            [DBManager deleteOb:grp];
        }
    }
    else if(notf.type == 20)
    {
        NSString *groupID = [dict objectForKey:@"loudhailer_id"];
        int length = (UInt64)strtoull([groupID UTF8String], NULL, 16);

        NSString *gId = [NSString stringWithFormat:@"%d",length];

        NSString *gName = [dict objectForKey:@"invited_by"];
//        NSString *netId = [AppManager sutableStrWithStr:[group objectForKey:@"network_id"]];
        NSString *picurl = [dict objectForKey:@"profile_photo"];
        notf.tempGrName = gName;
        notf.tempGrId = gId;
      //notf.tempNetId = netId;
        notf.tempGrpPic = picurl;
        
        notf.p2pToken = [dict objectForKey:@"activationKey"];
        
       // NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",u.loud_hailerid],@"id",user.user_name,@"group_name",[dict objectForKey:@"timestamp"],@"timestamp",user.picUrl,@"group_photo", nil];
        
       // [Group addGroupWithDictForP2PContact:dic forUsers:@[user] pic:nil];
    }
    else if(notf.type == 2){
        NSDictionary *group = [dict objectForKey:@"Group"];
        Group *grp = [Group groupWithId:[group objectForKey:@"id"] shouldInsert:NO isP2PContact:NO isPendingStatus:NO];
        if(grp != nil){
            User *u = [User userWithId:[dictOfSender objectForKey:@"id"] shouldInsert:NO];
            if([u.user_id isEqualToString:[Global shared].currentUser.user_id])
                [DBManager deleteOb:grp];
            notf.group = grp;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
    }
    else if(notf.type != 2){
        if(notf.type == 1){
            NSDictionary *group = [dict objectForKey:@"Group"];
            User *u;
            u = [User userWithId:[dictOfSender objectForKey:@"id"] shouldInsert:NO];
            if (u == nil) {
                NSString *msg = notf.message;
                msg  = [[msg componentsSeparatedByString:@"/"] objectAtIndex:0];
                msg = [msg stringByReplacingOccurrencesOfString:@"<h>" withString:@""];
                msg = [msg stringByReplacingOccurrencesOfString:@"<" withString:@""];
                u = [User userWithId:[dictOfSender objectForKey:@"id"] shouldInsert:YES withUserName:msg];
                // if still user is not saved into the database
                if (u == nil){
                    return nil;
                }
            }
            Group *grp = [Group groupWithId:[group objectForKey:@"id"] shouldInsert:NO isP2PContact:NO isPendingStatus:NO];
            [grp addUsersObject:u];
            [grp removePendingUsersObject:u];
            [EmailedUser deleteEmailUserWithEmailId:email];
            notf.group = grp;
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
        }
        else if (notf.type == 15){
            // if contact notification is there.
            notf.group = [Group addGroupWithDict:[dict objectForKey:@"Group"] forUsers:nil pic:nil pending:NO];
            notf.sender = [User addUserWithDict:[dict objectForKey:@"contacted_by"] pic:nil];
        }
        else{
              if(notf.type == 8){
                  NSDictionary *group = [dict objectForKey:@"Group"];
                  User *user = [User userWithId:[dictOfSender objectForKey:@"id"] shouldInsert:NO];
                  if(![user.user_id isEqualToString:[Global shared].currentUser.user_id]){
                      Group *grp = [Group groupWithId:[group objectForKey:@"id"] shouldInsert:NO isP2PContact:NO isPendingStatus:NO];
                      [grp removePendingUsersObject:user];
                      [EmailedUser deleteEmailUserWithEmailId:email];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
                  }
                  else{
                      notf.group = [Group addGroupWithDict:[dict objectForKey:@"Group"] forUsers:nil pic:nil pending:NO];
                  }                 
              }
              else{
                  notf.group = [Group addGroupWithDict:[dict objectForKey:@"Group"] forUsers:nil pic:nil pending:NO];
              }
        }
    }
    return notf;
}

#pragma mark Class Methods

+ (void)saveNotifications:(NSArray *)list{
    [[Global shared] setActivities:list];
}

+ (void)clearNotifications{
    [[Global shared] setActivities:nil];
}

+ (void)parseResponse:(NSDictionary *)resp{
    if([[resp objectForKey:@"message"] isEqualToString:@"No Notification!"]){
        [NotificationInfo saveNotifications:[NSArray new]];
    }
    
    NSArray *list = [resp objectForKey:@"Notifications"];
    BOOL isChange = NO;
    NSMutableArray *singleNotf = [NSMutableArray new];

    if(list == nil){
        NSString *notId = [NSString stringWithFormat:@"%d", [[resp objectForKey:@"notification_id"] intValue]];
        NSString *valueOfNotif = [[NSUserDefaults standardUserDefaults]valueForKey:k_notification_ID];
        if([valueOfNotif isEqualToString:notId])
            return;
        [[NSUserDefaults standardUserDefaults]setValue:notId forKey:k_notification_ID];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [PrefManager storeReadNotfIds:notId];
        Notifications *notf = [Notifications notificationWithId:notId shouldInsert:NO];
        if(notf){return;}
        else{
        NotificationInfo *notF = [NotificationInfo notWithDict:resp];
        [notF addGroupDataFromDict:resp];
        [Notifications addNotWithDict:resp];
        [singleNotf addObject:notF];
        NSArray *array = [[Global shared] activities];
        [singleNotf addObjectsFromArray:array];
        NSArray *arr = [singleNotf sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]]];
        [NotificationInfo saveNotifications:arr];
            if (notF.type == 2) {
                if([notF deleteGroupIfUserDeletedFromGroup]){
                       isChange=YES;
                }
                [notF addGroupDataFromDict:resp];
                [GroupsViewController refreshGroups];
            }
        return;}
    }
    NSMutableArray *allNotf = [NSMutableArray new];
    for (NSDictionary *dict in list){
        NotificationInfo *notF = [NotificationInfo notWithDict:dict];
        if([notF deleteGroupIfUserDeletedFromGroup])
            isChange=YES;
        [notF addGroupDataFromDict:resp];
        [Notifications addNotWithDict:dict];
        [allNotf addObject:notF];
    }
    
    if (isChange){[GroupsViewController refreshGroups];}
    //Short Notifications
    NSArray *arr = [allNotf sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]]];
    [NotificationInfo saveNotifications:arr];
}

@end
