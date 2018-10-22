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

@implementation MoreView
{
    NSArray *moreDeletechannelNameArray,*moreInfoChannelNameArray;
    NSArray *imageArray;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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

    moreDeletechannelNameArray =   @[@"Timberwolves", @"Falcons", @"Raptors",
                           @"Philadelphia"];
    moreInfoChannelNameArray = @[@"Arena District",@"GCCC", @"Exp.Columbus",@"German Village", @"FCCFA Art",@"Minnisota Vikings", @"Dallas Mavericks",@"Toronto Blue Jays", @"Angeles lakers",@"Denver Broncos", @"Jacksonville Jaguars",@"Minnisota Vikings"];

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
        itemsCount = (int)moreDeletechannelNameArray.count;
    else if(collectionView.tag ==  102)
        itemsCount =  (int)moreInfoChannelNameArray.count;
    return itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if(collectionView.tag == 101)
    {
        static NSString *cellIdentifier = @"MoreChannelCollectionViewCell";
        MoreChannelCollectionViewCell *cell = (MoreChannelCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.channelNameLabel.text = [moreDeletechannelNameArray objectAtIndex:indexPath.row];
        return cell;
    }
    else if(collectionView.tag == 102)
    {
        static NSString *moreInfoCellIdentifier = @"moreInfoChannelCollectionViewCell";
        moreInfoChannelCollectionViewCell *infoCell = (moreInfoChannelCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:moreInfoCellIdentifier forIndexPath:indexPath];
        infoCell.moreInfoChannelName.text = [moreInfoChannelNameArray objectAtIndex:indexPath.row];
        return infoCell;
    }
    return nil;
}

@end
