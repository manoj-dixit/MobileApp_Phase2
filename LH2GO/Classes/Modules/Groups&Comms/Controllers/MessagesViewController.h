//
//  MessagesViewController.h
//  LH2GO
//
//  Created by Linchpin on 23/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messageCell.h"
#import "LGPlusButtonsView.h"
#import "Common.h"
#import "NotificationViewController.h"


@interface MessagesViewController : BaseViewController<UISearchDisplayDelegate,UISearchBarDelegate,LGPlusButtonsViewDelegate,MessageCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableMessage;
@property (strong,nonatomic)NSMutableArray *datasource;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, weak) IBOutlet UIView *notificationView;
@property (nonatomic, weak) IBOutlet UILabel *bellIconLabel;
@property (nonatomic, weak) IBOutlet UILabel *notificationCountLabel;


- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick;
- (void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground;
- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType;
@end
