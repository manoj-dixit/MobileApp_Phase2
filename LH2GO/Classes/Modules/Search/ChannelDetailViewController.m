//
//  ChannelDetailViewController.m
//  LH2GO
//
//  Created by Parul Mankotia on 28/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "ChannelDetailViewController.h"

#define kInitialHeightConstant 40

@interface ChannelDetailViewController ()<ChannelDetailCellDelegate>{
    NSArray *channelDataArray;
}

@end

@implementation ChannelDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _channelImageView.layer.cornerRadius = _channelImageView.frame.size.width/2;
    _channelImageView.layer.masksToBounds = NO;
    
    _channelInformationButton.layer.cornerRadius = _channelInformationButton.frame.size.width/2;
    _channelInformationButton.layer.masksToBounds = NO;
    channelDataArray = [[NSArray alloc] init];
    [self addTopBarButtons];
    [self selectedChannel:_channelSelected];
}

- (void)addTopBarButtons
{
    UIBarButtonItem *lefttButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = lefttButton;
    
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Channel";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectedChannel:(Channels*)channel{
    [_channelImageView sd_setImageWithURL:[NSURL URLWithString:channel.image] placeholderImage:[UIImage imageNamed:placeholderGroup]];
    _channelNameLabel.text = channel.name;
    if (_channelFeedSelected) {
        channelDataArray = [channelDataArray arrayByAddingObject:_channelFeedSelected];
        [_channelFeedTableView reloadData];
}
    else{
        channelDataArray = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND feed_Type = %@", channel.channelId,@"0"] descr:nil isDistinctResults:YES];
    }
}

#pragma mark-
#pragma mark- Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [channelDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ChannelDetailCell";
    ChannelDetailCell *cell;
    ChannelDetail *channelDetail = [channelDataArray objectAtIndex:indexPath.row];
    
    if ([channelDetail.mediaType isEqualToString:@"TIXX"]) {
        cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Image",cellIdentifier]];
        
        if (cell == nil) {
            cell = [ChannelDetailCell cellAtIndex:0];
            cell.delegate=self;

        }
        NSString *textString = channelDetail.text;
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
    else if([channelDetail.mediaType isEqualToString:@"TXXX"]){
        cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Text",cellIdentifier]];
        
        if (cell == nil) {
            cell = [ChannelDetailCell cellAtIndex:1];
            cell.delegate=self;
        }
        NSString *textString = channelDetail.text;
        CGFloat h = [self getTextviewHeightForText:textString];
        cell.textViewHeightContraint.constant = h;
        cell.channelDescriptionTextView.text = textString;
        [self coolForChannelDetail:channelDetail forTableViewCell:cell];
        [self contactForChannelDetail:channelDetail forTableViewCell:cell];

        cell.reportButton.accessibilityIdentifier = [NSString stringWithFormat:@"%ld",indexPath.row];
        cell.channelDetail = channelDetail;
        return cell;
    }
    else if ([channelDetail.mediaType isEqualToString:@"TGXX"]){
        cell= (ChannelDetailCell *) [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_Animated",cellIdentifier]];
        
        if (cell == nil) {
            cell = [ChannelDetailCell cellAtIndex:2];
            cell.delegate=self;

        }
        NSString *textString = channelDetail.text;
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
    ChannelDetail *channelDetail = [channelDataArray objectAtIndex:indexPath.row];
    NSString *textString = channelDetail.text;
    CGFloat h = [self getTextviewHeightForText:textString];
    h = h -kInitialHeightConstant;
    
    if ([channelDetail.mediaType isEqualToString:@"TIXX"]){
        return 428+h;
    }
    else if ([channelDetail.mediaType isEqualToString:@"TXXX"]){
        return 183+h;
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

-(void)chanelImageTappedOnCell:(NSInteger)selectedRow
{
    ChannelDetail *chanelDetail =[channelDataArray objectAtIndex:selectedRow];
    if ([chanelDetail.mediaType containsString:@"I"] || [chanelDetail.mediaType containsString:@"G"])
    {
        ImageOverlyViewController *imageOverlayViewController   = (ImageOverlyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ImageOverlyViewController"];
        imageOverlayViewController.mediaType = chanelDetail.mediaType;
        imageOverlayViewController.mediaPath = chanelDetail.mediaPath;
        imageOverlayViewController.channelId = chanelDetail.channelId;
        imageOverlayViewController.contentId = [chanelDetail.contentId integerValue];
        [self.navigationController presentViewController:imageOverlayViewController animated:YES completion:nil];
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


- (void)refreshData{
    if ([channelDataArray count] == 1 && [[[channelDataArray lastObject] valueForKey:@"toBeDisplayed"] integerValue] == 0) {
        NSArray *tempArray = [[NSArray alloc] init];
        channelDataArray = tempArray;
    }
    [_channelFeedTableView reloadData];
}


@end
