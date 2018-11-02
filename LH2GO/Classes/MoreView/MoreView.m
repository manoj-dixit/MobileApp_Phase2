//
//  MoreView.m
//  LH2GO
//
//  Created by Sonal on 05/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "MoreView.h"
#import "MoreChannelCollectionViewCell.h"
#import "moreInfoChannelCollectionViewCell.h"
#import "SharedUtils.h"

@implementation MoreView
{
    NSArray *moreDeletechannelNameArray;
    NSMutableArray *channelsArray;
    NSMutableArray *favouriteChannelsArray;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
       self = [[[NSBundle mainBundle] loadNibNamed:@"MoreView" owner:self options:nil] objectAtIndex:0];
        self.frame =frame;
    }
    [self initialStuff];
    return self;
}

-(void)initialStuff
{
    [self.moreChannelCollectionView registerNib:[UINib nibWithNibName:@"MoreChannelCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MoreChannelCollectionViewCell"];
    [self.moreInfoChannelCollectionView registerNib:[UINib nibWithNibName:@"moreInfoChannelCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"moreInfoChannelCollectionViewCell"];
    [self getFavouriteChanelList];

}
-(void)deleteFromFavChannelCellLongTapped:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded){
        CGPoint point = [gesture locationInView:self.moreChannelCollectionView];
        NSIndexPath *indexPath = [self.moreChannelCollectionView indexPathForItemAtPoint:point];
        MoreChannelCollectionViewCell *favChannelCell = (MoreChannelCollectionViewCell*)[self.moreChannelCollectionView cellForItemAtIndexPath:indexPath];
        
        if(favouriteChannelsArray.count == 1)
        {
            [AppManager showAlertWithTitle:@"Info" Body:@"At least one channel is required."];
        }
        else
        {
            favChannelCell.crossButton.hidden = NO;
            favChannelCell.crossButton.accessibilityHint = [NSString stringWithFormat:@"%ld",indexPath.row];
                }
    }
}

-(void)crossButtonTappedOnFavChannelCell:(UIButton*)buttonTapped withAccessibilityHint:(NSString*)hintStirng{
    CGPoint point = [buttonTapped convertPoint:CGPointZero toView:self.moreChannelCollectionView];
    NSIndexPath *indexPath = [self.moreChannelCollectionView indexPathForItemAtPoint:point];
    MoreChannelCollectionViewCell *FavChannelCell = (MoreChannelCollectionViewCell*)[self.moreChannelCollectionView cellForItemAtIndexPath:indexPath];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:[NSString stringWithFormat: @"Do you want to remove channel from your favourite list?"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 FavChannelCell.crossButton.hidden = YES;
                             }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"YES"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       FavChannelCell.crossButton.hidden = YES;
                                                       [favouriteChannelsArray removeObjectAtIndex:[hintStirng integerValue]];
                                                       [_moreChannelCollectionView reloadData];
                                                   }];
    [alert addAction:cancel];
    [alert addAction:delete];
    
    NSArray *allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
    if ([[allVc lastObject] isKindOfClass:[ChanelViewController class]]) {
        [[allVc lastObject] presentViewController:alert animated:YES completion:nil];
    }}

-(void)crossButtonTappedOnAllChannelsCell:(UIButton *)buttonTapped withAccessibilityHint:(NSString *)hintStirng
{
    CGPoint point = [buttonTapped convertPoint:CGPointZero toView:self.moreInfoChannelCollectionView];
    NSIndexPath *indexPath = [self.moreInfoChannelCollectionView indexPathForItemAtPoint:point];
    moreInfoChannelCollectionViewCell *allChannelsCell = (moreInfoChannelCollectionViewCell*)[self.moreInfoChannelCollectionView cellForItemAtIndexPath:indexPath];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:[NSString stringWithFormat: @"Do you want to add channel to your favourite list?"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 allChannelsCell.infoButton.hidden = YES;
                             }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"YES"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       allChannelsCell.infoButton.hidden = YES;
                                                       [channelsArray removeObjectAtIndex:[hintStirng integerValue]];
                                                       [_moreInfoChannelCollectionView reloadData];
                                                   }];
    [alert addAction:cancel];
    [alert addAction:delete];
    
    NSArray *allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
    if ([[allVc lastObject] isKindOfClass:[ChanelViewController class]]) {
        [[allVc lastObject] presentViewController:alert animated:YES completion:nil];
    }}


-(void)addIntoMoreChannelsCellLongTapped:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded){
        CGPoint point = [gesture locationInView:self.moreInfoChannelCollectionView];
        NSIndexPath *indexPath = [self.moreInfoChannelCollectionView indexPathForItemAtPoint:point];
        moreInfoChannelCollectionViewCell *allChannelCell = (moreInfoChannelCollectionViewCell*)[self.moreInfoChannelCollectionView cellForItemAtIndexPath:indexPath];
        if(channelsArray.count == 1)
        {
            [AppManager showAlertWithTitle:@"Info" Body:@"At least one channel is required."];
        }
        else
        {
            allChannelCell.infoButton.hidden = NO;
            allChannelCell.infoButton.accessibilityHint = [NSString stringWithFormat:@"%ld",indexPath.row];
        }
    }

}
-(void)getFavouriteChanelList
{
    SharedUtils *sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    NSMutableDictionary *paramDictionary  = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:currentApplicationId],@"application_id",[Global shared].currentUser.user_id,@"user_id",nil];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,kUserChannel_List];
    [sharedUtils makePostCloudAPICall:paramDictionary andURL:urlString];
}

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    if(responseDict != NULL)
    {
        if([[responseDict objectForKey:@"status"] boolValue] || [[responseDict objectForKey:@"status"] isEqualToString:@"Success"])
        {
            {
                @try
                {                    
                    NSDictionary *channels  = [[responseDict objectForKey:@"data"] objectForKey:@"Channel"];
                    favouriteChannelsArray = [[channels objectForKey:@"default"] mutableCopy];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_moreChannelCollectionView reloadData];
                    });
                } @catch (NSException *exception) {
                    
                } @finally {
                }
            }
        }
    }
}

- (IBAction)cancelClicked:(id)sender
{
    if ([self delegate] && [self.delegate respondsToSelector:@selector(cancelButtonAction)]) {
        [self.delegate cancelButtonAction];
    }
}

- (IBAction)okClicked:(id)sender
{
    if ([self delegate] && [self.delegate respondsToSelector:@selector(doneButtonAction)]) {
        [self.delegate doneButtonAction];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    int itemsCount = 0;
    if(collectionView.tag == 101)
    {
        itemsCount = (int)favouriteChannelsArray.count;//(int)moreDeletechannelNameArray.count;
        return itemsCount;
    }
    else if(collectionView.tag ==  102)
    {
        NSString *activeNetId = [PrefManager activeNetId];
        Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
        NSArray  *channel  = [DBManager getChannelsForNetwork:net];
        NSMutableArray *nets = [NSMutableArray new];
        if(channel.count > 0)
        {
            NSDictionary *d = @{ @"network" : net,
                                 @"channels"  : channel
                                 };
            [nets addObject:d];
            _dataarray = nets;
            NSDictionary *dict = [_dataarray objectAtIndex:0];
            channelsArray = [[dict objectForKey:@"channels"] mutableCopy];
        }
        return channelsArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if(collectionView.tag == 101)
    {
        static NSString *cellIdentifier = @"MoreChannelCollectionViewCell";
        MoreChannelCollectionViewCell *cell = (MoreChannelCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        cell.channelNameLabel.text = [[favouriteChannelsArray valueForKey:@"channel_name"] objectAtIndex:indexPath.row];
        [cell.channelImageIcon sd_setImageWithURL:[NSURL URLWithString:[[favouriteChannelsArray valueForKey:@"channel_photo"]objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:placeholderGroup]];
        UILongPressGestureRecognizer *deleteLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteFromFavChannelCellLongTapped:)];
        [cell addGestureRecognizer:deleteLongPressGesture];

        return cell;
    }
    else if(collectionView.tag == 102)
    {
        static NSString *moreInfoCellIdentifier = @"moreInfoChannelCollectionViewCell";
        moreInfoChannelCollectionViewCell *infoCell = (moreInfoChannelCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:moreInfoCellIdentifier forIndexPath:indexPath];
        infoCell.delegate = self;
        infoCell.moreInfoChannelName.text = [[channelsArray valueForKey:@"name"]objectAtIndex:indexPath.row];
        [infoCell.moreInfoChannelImage sd_setImageWithURL:[NSURL URLWithString:[[channelsArray valueForKey:@"image"]objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:placeholderGroup]];
        UILongPressGestureRecognizer *addLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addIntoMoreChannelsCellLongTapped:)];
        [infoCell addGestureRecognizer:addLongPressGesture];
        return infoCell;
    }
    return nil;
}

@end
