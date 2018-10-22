//
//  LHBackupSessionInfoVC.h
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "BaseViewController.h"
#import "ShoutBackup.h"

@protocol ProtocolRefreshBackUps <NSObject>

-(void)RefreshBackUps;

@end
@interface LHBackupSessionInfoVC : BaseViewController

@property(nonatomic, strong) NSArray *arrOfShoutsForBackUp;
@property(nonatomic, strong)ShoutBackup *shoutBackUp;
@property (nonatomic, assign) id <ProtocolRefreshBackUps> delegate;
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict;
@end
