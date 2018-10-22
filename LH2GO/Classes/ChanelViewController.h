//
//  ChanelViewController.h
//  LH2GO
//
//  Created by Linchpin on 6/16/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "BaseViewController.h"
#import "GroupCollectionCell.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "ChanelDetailVC.h"
#import "CreateChannelFeedVC.h"
#import "CryptLib.h"
#import "ChanelTableViewCell.h"
#import "CustomTitleView.h"

@protocol TopologyEventLogDelegate <NSObject>
- (void)hitEventLog:(NSString *)userid;
@end



@interface ChanelViewController : BaseViewController<CustomViewDelegate>
@property (strong, nonatomic) NSMutableArray *expandedCells;
@property (nonatomic, assign) BOOL shouldHighlightOwn;
@property (weak, nonatomic) IBOutlet UITableView *tableChannel;
@property (strong,nonatomic) NSMutableArray *dataarray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionChannel;
@property (nonatomic, strong) Channels *myChannel;
@property (weak, nonatomic) IBOutlet UIButton *leftArrow;
@property (weak, nonatomic) IBOutlet UIButton *rightArrow;
@property (nonatomic, assign) id <TopologyEventLogDelegate> delegate;
@property BOOL needToMove;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnIconWidth;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *latestFeedsButton;
@property (weak, nonatomic) IBOutlet UIView *allChannelView;


- (IBAction)btnAction_CreateFeed:(id)sender;
- (void)refreshData;

@property (strong,nonatomic) NSMutableArray *detailsOfChannel;
@property (strong,nonatomic) NSMutableArray *detailsOfAllChannelData;
@property (strong,nonatomic) NSMutableArray *detailsOfAllChannelScheduledData;

@property (nonatomic,strong) Channels *dataChannel;
@property (nonatomic,strong) NSMutableDictionary *dataDictionary;

-(void)downloadContent:(NSString *)content length:(NSString*)lengthh contentId:(NSString*)contentID cool:(NSString*)isCoolV coolCount:(NSString*)coolCountV share:(NSString*)isShareV shareCount:(NSString*)shareCountV Contact:(NSString*)isContactV contactCount:(NSString*)contactCountV chanelId:(NSString *)chanelId isPush:(BOOL)isPushClick isOnSameScreenDataFetchByAPI:(BOOL)isUsingAPI isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)isFeedType;

- (void)moveToChannelScreen:(NSString *)channelID;
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict;
-(void)goToChannelScreen:(NSDictionary *)dic isFromBackground:(BOOL)isBackground;
- (void)goToNotificationScreen:(NSDictionary*)dict isClickedOnPush:(BOOL)isPush;
-(void)cancelAllOperationsQueue;
-(void)chanelImageTappedOnCell:(NSInteger)selectedRow;
-(void) cancelButtonAction;
-(void) doneButtonAction;

-(void)redirectToChannelScreen;

@end


