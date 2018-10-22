//
//  BackUpManager.h
//  LH2GO
//
//  Created by Alok Deepti on 26/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackUpManager : NSObject

+ (void)createAutoBackUp;
+ (void)ShoutsBackup:(NSArray*)shtArr backup:(ShoutBackup*)shout_bk onView:(UIView*)view isAdding:(BOOL)isAdding andAutobackup:(BOOL)autoBackup completion:(void (^)(BOOL status))completion;
//back up from server
+ (void)ShoutsBackupFromServerOnView:(UIView*)view completion:(void (^)(BOOL finished))completion;
+ (void)ShoutsDataBackupwithBackUpId:(NSInteger )backup_id shoutBackUp:(ShoutBackup *)shoutBackup FromServerOnView:(UIView*)view completion:(void (^)(BOOL finished))completion;

@end
