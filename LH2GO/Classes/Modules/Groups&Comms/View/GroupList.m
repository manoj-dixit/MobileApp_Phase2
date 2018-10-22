//
//  GroupList.m
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "GroupList.h"
#import "GroupCollectionViewCell.h"
#import "BLEManager.h"
#import "LoaderView.h"
#import "HeaderCollectionView.h"


#define kCellsPerRow 3
#define kCellWidth 90
#define kCellHeight 70

@interface GroupList () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableArray *_dataSource;
    NSInteger _selectedSec;
    UIView *_xibV;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectView;

@end

@implementation GroupList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self gatherDatasource];
        
        // add xib
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupList" owner:self options:nil];
        GroupList *vv = [topLevelObjects objectAtIndex:0];
      
        _collectView.frame = vv.frame = self.bounds;
        
        [_collectView registerClass:[HeaderCollectionView class]
               forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                      withReuseIdentifier:@"HeaderView"];
        
        [_collectView registerClass:[GroupCollectionViewCell class]
               forCellWithReuseIdentifier:@"GroupCollectionViewCellIdentifier"];
        
        [self addSubview:vv];
        if (isLoggedIn) {
            [LoaderView addLoaderToView:[UIApplication sharedApplication].keyWindow];
        }
        _xibV = vv;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _xibV.frame = self.bounds;
}

- (void)refreshData {
    [self gatherDatasource];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectView reloadData];
    });
}

- (void)refreshList {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectView reloadData];
    });
}

- (void)shouldMarkDeleteMode:(BOOL)mark AtIndex:(NSIndexPath *)indxPath {
    GroupCollectionViewCell *cell = (GroupCollectionViewCell *) [_collectView cellForItemAtIndexPath:indxPath];
    [cell shoudAddRedView:mark];
}

- (void)removeGrAtIndexpath:(NSIndexPath *)indexPath {
    
    [_collectView performBatchUpdates:^{
        
        // remove this group from the list
        NSMutableDictionary *d = [[_dataSource objectAtIndex:indexPath.section] mutableCopy];
        NSMutableArray *grps = [[d objectForKey:@"groups"] mutableCopy];
        
        Group *gr = [grps objectAtIndex:indexPath.row];
        [DBManager deleteOb:gr];
        [grps removeObjectAtIndex:indexPath.row];
        
        if (grps.count == 0) {
            // delete network
            Network *net = [d objectForKey:@"network"];
            [DBManager deleteOb:net];
            
            // remove this section
            [_dataSource removeObjectAtIndex:indexPath.section];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
            [_collectView deleteSections:indexSet];
            
        } else {
            [d setObject:grps forKey:@"groups"];
            [_dataSource replaceObjectAtIndex:indexPath.section withObject:d];
            [_collectView deleteItemsAtIndexPaths:@[indexPath]];
        }
        
    } completion:nil];
}

- (NSInteger)groupsCountInSec:(NSInteger)sec {
    NSDictionary *d = [_dataSource objectAtIndex:sec];
    NSArray *grps = [d objectForKey:@"groups"];
    return grps.count;
}

- (Group *)groupOnIndexPath:(NSIndexPath *)indxP {
    if (!indxP) return nil;
    NSDictionary *d = [_dataSource objectAtIndex:indxP.section];
    NSArray *grps = [d objectForKey:@"groups"];
    Group *gr = [grps objectAtIndex:indxP.row];
    return gr;
}

- (void)updateBadgeForGroup:(Group *)gr {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"network = %@", gr.network];
    NSArray *nets = [_dataSource filteredArrayUsingPredicate:predicate];
    if (!nets.count) return;
    
    NSDictionary *d = [nets firstObject];
    NSArray *grps = [d objectForKey:@"groups"];
    
    NSInteger sect = [_dataSource indexOfObject:d];
    NSInteger row = [grps indexOfObject:gr];
    
    GroupCollectionViewCell *cell = (GroupCollectionViewCell *) [_collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:sect]];
    [cell updateBadge:gr.badge.integerValue];
}

#pragma mark - private methods
- (void)gatherDatasource
{
    [Global shared].isReadyToStartBLE = YES;
    NSMutableArray *nets = [NSMutableArray new];
    NSString *activeNetId = [PrefManager activeNetId];
    NSArray *networks = [DBManager getNetworks];
    _selectedSec = -1;
    for(Network *net in networks){
        NSArray *groups = [DBManager getShortedGroupsForNetwork:net];
        NSDictionary *d = @{ @"network" : net,
                             @"groups"  : groups
                             };
        [nets addObject:d];
        if ([net.netId isEqualToString:activeNetId]) {
            _selectedSec = nets.count-1;
        }
    }
    _dataSource = nets;
    if ([Global shared].isReadyToStartBLE&&[_dataSource count]>0&&_selectedSec != -1&&[BLEManager sharedManager].isRefreshBLE) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startBLE];
        });
    }
}

- (void)startBLE{
    [LoaderView addLoaderToView:[UIApplication sharedApplication].keyWindow];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        NSString *activeNetId = [PrefManager activeNetId];
        if (activeNetId.length>0) {
            dispatch_async(dispatch_get_main_queue(), ^{
               // [[BLEManager sharedManager] reInitialize];
            });
        }
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [LoaderView removeLoader];
        });
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    NSDictionary *d = [_dataSource objectAtIndex:section];
    NSArray *grps = [d objectForKey:@"groups"];
    return grps.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"GroupCollectionViewCellIdentifier";
    GroupCollectionViewCell *cell = (GroupCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *d = [_dataSource objectAtIndex:indexPath.section];
    NSArray *grps = [d objectForKey:@"groups"];
    Group *gr = [grps objectAtIndex:indexPath.row];
    [cell showGroup:gr];
    cell.alpha = (_selectedSec == indexPath.section) ? 1.0 : 0.5;
    
    if (_shouldHighlightOwn) {
        User *me = [[Global shared] currentUser];
        BOOL mine = [gr.owner.user_id isEqualToString:me.user_id];
        cell.alpha = mine ? 1.0 : 0.5;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
   // if (kind == UICollectionElementKindSectionHeader) {
        HeaderCollectionView *reusableview = (HeaderCollectionView *) [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        NSDictionary *d = [_dataSource objectAtIndex:indexPath.section];
        Network *net = [d objectForKey:@"network"];
        [reusableview setTitle:[net netName]];
        
        reusableview.alpha = (_selectedSec == indexPath.section) ? 1.0 : 0.5;
        return reusableview;
//    }
//    return nil;
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];;
    float ratio = screenRect.size.width/320.0;
    return CGSizeMake(kCellWidth*ratio, kCellHeight*ratio);
}

// header size.
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    int hh = 33;
    if (section==0) {
        hh = 22;
    }
    return CGSizeMake(collectionView.bounds.size.width, hh);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (_delegate && [_delegate respondsToSelector:@selector(didSelectIndexPath:)]) {
        [_delegate didSelectIndexPath:indexPath];
    }
}

@end
