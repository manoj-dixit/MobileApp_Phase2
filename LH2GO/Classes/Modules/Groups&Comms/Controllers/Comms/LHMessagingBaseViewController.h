//
//  LHMessagingBaseViewController.h
//  LH2GO
//
//  Created by Kiwitech on 25/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "BaseViewController.h"
#import "AttachmentOptionView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface LHMessagingBaseViewController : BaseViewController{
    __weak IBOutlet UITextView  *_shInputFld;
    __weak IBOutlet UIView      *_viewForTextView;
    __weak IBOutlet UILabel     *_leftLbl;
    __weak IBOutlet UIButton    *_BackupBtn;
    __weak IBOutlet UITableView *_table;
    __weak IBOutlet UIButton    *_camBtn;
    __weak IBOutlet UIButton    *_voiceBtn;
    __weak IBOutlet UIView      *_bottomInpView;
    __weak IBOutlet UIButton *_sendButton;
    __weak IBOutlet UICollectionView *collectionGroup;
    AttachmentOptionView *attchVieww; // by nim chat#3
    BOOL isReloadingTable;
    NSArray *_shouts;
    NSArray *_totalShouts;
    NSArray *_cmsShouts;
    NSMutableArray *_testCMS1;
    NSMutableArray *_testCMS2;
    BOOL _shouldReloadShout; // shouts reload (shout comes when view is inactive)
    
    // by nim
    //NSInteger selectedGroupIndex;
    NSInteger groupsCount;
    NSArray *grps;
    CGFloat kB_heightDiff;
    CGRect keyboardFrame_BACKUP;
    UITextView *txtvw;
    
}
@property NSInteger selectedGroupIndex;
@property NSInteger groupIdIS;
@property (strong,nonatomic)NSMutableArray *datasource;
@property (weak, nonatomic) IBOutlet UIButton *leftArrow;
@property (weak, nonatomic) IBOutlet UIButton *rightArrao;
@property (nonatomic, strong) Group *myGroup;

-(void)recievedShout:(Shout *)sh;
-(void)updateRefreshFlag:(BOOL)shouldRefresh;
- (BOOL)checkIFNetworkIsActive;
- (void)sortShouts:(Shout*)sh;
@end
