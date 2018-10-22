//
//  LHBackupSessionDetailVCViewController.h
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "BaseViewController.h"
#import "ShoutCell.h"

@interface LHBackupSessionDetailVC : BaseViewController<ShoutCellDelegate>
@property(nonatomic, strong) NSArray *arrBackUp;
@property(nonatomic, strong) NSString *titlelbl;
@property(nonatomic, assign) BOOL isChieldView;
@property NSString *titleBarname;
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick;
-(void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground;
@end
