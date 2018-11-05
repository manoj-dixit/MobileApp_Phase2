//
//  BukiFeedView.m
//  LH2GO
//
//  Created by Parul Mankotia on 01/11/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "BukiFeedView.h"
#define kInitialHeightConstant 40


@implementation BukiFeedView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"BukiFeedView" owner:self options:nil] objectAtIndex:0];
        self.frame =frame;
    }
    bukiFeedsArray = [[NSMutableArray alloc] init];
    [self initializeData];
    return self;
}

-(void)initializeData
{
    [bukiFeedsArray removeAllObjects];
    [bukiFeedsArray addObjectsFromArray:[DBManager feedsFromBukiBox]];
    NSSortDescriptor *sortByTime = [NSSortDescriptor sortDescriptorWithKey:@"created_time" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByTime];
    NSArray *sortedArray = [bukiFeedsArray sortedArrayUsingDescriptors:sortDescriptors];
    [bukiFeedsArray removeAllObjects];
    [bukiFeedsArray addObjectsFromArray:sortedArray];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource=self;
}

#pragma mark-
#pragma mark- Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [bukiFeedsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ChannelDetailCell";
    ChannelDetailCell *cell;
    ChannelDetail *channelDetail = [bukiFeedsArray objectAtIndex:indexPath.row];
    if ([channelDetail.mediaType isEqualToString:@"TIXX"]) {
        cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Image",cellIdentifier]];
        
        if (cell == nil) {
            cell = [ChannelDetailCell cellAtIndex:0];
            cell.delegate=self;
        }
        NSString *textString = channelDetail.text;
        cell.dateTextLabel.text = [self convertToDateString:channelDetail.created_time];
        CGFloat h = [self getTextviewHeightForText:textString];
        cell.textViewHeightContraint.constant = h;
        cell.channelDescriptionTextView.text = textString;
        cell.channelFeedImageView.image =[self imageForChannelFeed:channelDetail];
        [self coolForChannelDetail:channelDetail forTableViewCell:cell];
        [self contactForChannelDetail:channelDetail forTableViewCell:cell];

        cell.reportButton.accessibilityIdentifier = [NSString stringWithFormat:@"%ld",indexPath.row];
        cell.channelDetail = channelDetail;
        return cell;
    }
    else if([channelDetail.mediaType isEqualToString:@"TXXX"])
    {
        cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Text",cellIdentifier]];
        
        if (cell == nil) {
            cell = [ChannelDetailCell cellAtIndex:1];
            cell.delegate=self;
        }
        NSString *textString = channelDetail.text;
        cell.dateTextLabel.text = [self convertToDateString:channelDetail.created_time];
        CGFloat h = [self getTextviewHeightForText:textString];
        cell.textViewHeightContraint.constant = h;
        cell.channelDescriptionTextView.text = textString;
        [self coolForChannelDetail:channelDetail forTableViewCell:cell];
        [self contactForChannelDetail:channelDetail forTableViewCell:cell];

        cell.reportButton.accessibilityIdentifier = [NSString stringWithFormat:@"%ld",indexPath.row];
        cell.channelDetail = channelDetail;
        return cell;
    }
    else if ([channelDetail.mediaType isEqualToString:@"TGXX"])
    {
        cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Animated",cellIdentifier]];
        
        if (cell == nil) {
            cell = [ChannelDetailCell cellAtIndex:2];
            cell.delegate=self;;
        }
        NSString *textString = channelDetail.text;
        cell.dateTextLabel.text = [self convertToDateString:channelDetail.created_time];
        CGFloat h = [self getTextviewHeightForText:textString];
        cell.textViewHeightContraint.constant = h;
        cell.channelDescriptionTextView.text = textString;
        cell.reportButton.accessibilityIdentifier = [NSString stringWithFormat:@"%ld",indexPath.row];
        cell.channelDetail = channelDetail;

        FLAnimatedImage *animatedImage = [self animatedImageForChannelFeed:channelDetail];
        if (animatedImage) {
            cell.channelFeedAnimatedImageView.animatedImage = animatedImage;
        }
        else{
            UIImage *cellImage = [[SDImageCache sharedImageCache] diskImageForKey:channelDetail.mediaPath];
            cell.channelFeedAnimatedImageView.image  = cellImage;
        }
        [self coolForChannelDetail:channelDetail forTableViewCell:cell];
        [self contactForChannelDetail:channelDetail forTableViewCell:cell];
        
        return cell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChannelDetail *channelDetail = [bukiFeedsArray objectAtIndex:indexPath.row];
    NSString *textString = channelDetail.text;
    CGFloat h = [self getTextviewHeightForText:textString];
    h = h -kInitialHeightConstant;
    
    if ([channelDetail.mediaType isEqualToString:@"TIXX"]){
        return 428+h;
    }
    else if ([channelDetail.mediaType isEqualToString:@"TXXX"]){
        return 183+h;//183+h;
    }
    else if ([channelDetail.mediaType isEqualToString:@"TGXX"]){
        return 428+h;
    }
    return 183;
}

-(CGFloat)getTextviewHeightForText:(NSString *)text
{
    UITextView *txtvw= [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 375, 0)];
    [txtvw setFont:[UIFont fontWithName:@"Aileron-Regular" size:15]];
    txtvw.text = text;
    CGSize contentSize = txtvw.contentSize;
    
    int numberOfLinesNeeded = contentSize.height / txtvw.font.lineHeight;
    CGRect textViewFrame= txtvw.frame;
    textViewFrame.size.height = numberOfLinesNeeded * txtvw.font.lineHeight + 25   ;//
    if (IS_IPHONE_X) {
        textViewFrame.size.height = textViewFrame.size.height+30;
    }
    else if (IS_IPHONE_6) {
        textViewFrame.size.height = textViewFrame.size.height+30;
    }
    return textViewFrame.size.height;
}

-(UIImage*)imageForChannelFeed:(ChannelDetail*)channel
{
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString* currentFile = [stringPath stringByAppendingPathComponent:[channel.mediaPath lastPathComponent]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
    UIImage *channelImage;
    if(fileExists){
        channelImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:currentFile]];
    }
    else{
        channelImage = [[SDImageCache sharedImageCache] diskImageForKey:channel.mediaPath];
    }
    return channelImage;
}

-(FLAnimatedImage*)animatedImageForChannelFeed:(ChannelDetail*)channel{
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString* currentFile = [stringPath stringByAppendingPathComponent:[channel.mediaPath lastPathComponent]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
    FLAnimatedImage *animatedImage;
    if (fileExists) {
        animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:currentFile]];
    }
    else{
        NSData *gifdata = [NSData dataWithContentsOfFile:channel.mediaPath];
        animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifdata];
    }
    return animatedImage;
}

-(void)chanelImageTappedOnCell:(ChannelDetail*)channelDetail
{
    if ([channelDetail.mediaType containsString:@"I"] || [channelDetail.mediaType containsString:@"G"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chanelImageTappedOnCell:)]) {
            [self.delegate chanelImageTappedOnCell:channelDetail];
        }
    }
}

-(void)saveTappedForChannelImageOnCell:(ChannelDetail*)channelDetail{
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveTappedForChannelImageOnCell:)]) {
        [self.delegate saveTappedForChannelImageOnCell:channelDetail];
    }
}

-(void)coolForChannelDetail:(ChannelDetail*)channelDetail forTableViewCell:(ChannelDetailCell*)cell{
    if (channelDetail.cool == YES) {
        cell.coolView.accessibilityIdentifier=@"cool_Selected";
        cell.coolColorLabel.textColor = [UIColor colorWithRed:(229.0f/255.0f) green:(0.0f/255.0f) blue:(28.0f/255.0f) alpha:1.0];
    }
    else{
        cell.coolView.accessibilityIdentifier=@"cool_not_Selected";
        cell.coolColorLabel.textColor = [UIColor colorWithRed:(184.0f/255.0f) green:(184.0f/255.0f) blue:(184.0f/255.0f) alpha:1.0];
    }
    if(![channelDetail.coolCount isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        cell.coolNumberLabel.text = [NSString stringWithFormat:@"%@ Cool",channelDetail.coolCount];
    }
    else
        cell.coolNumberLabel.text = @"Cool";
}

-(void)contactForChannelDetail:(ChannelDetail*)channelDetail forTableViewCell:(ChannelDetailCell*)cell{
    if (channelDetail.contact == YES) {
        cell.contactView.accessibilityIdentifier=@"contact_Selected";
        cell.contactColorLabel.textColor = [UIColor colorWithRed:(245.0f/255.0f) green:(187.0f/255.0f) blue:(66.0f/255.0f) alpha:1.0];
    }
    else{
        cell.contactView.accessibilityIdentifier=@"contact_not_Selected";
        cell.contactColorLabel.textColor = [UIColor colorWithRed:(184.0f/255.0f) green:(184.0f/255.0f) blue:(184.0f/255.0f) alpha:1.0];
    }
    if(![channelDetail.contactCount isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        cell.contactNumberLabel.text = [NSString stringWithFormat:@"%@ Contact",channelDetail.contactCount];
    }
    else
        cell.contactNumberLabel.text = @"Contact";
}

-(NSString *)convertToDateString:(NSNumber*)createdTime
{
    NSNumber *time1 = [NSNumber numberWithDouble:([createdTime doubleValue] - 3600)];
    NSTimeInterval interval = [time1 doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"dd-MM-yyyy"];
    return [dateformatter stringFromDate:date];
}

- (void)refreshData
{
    [self initializeData];
    [_feedTableView reloadData];
}





@end
