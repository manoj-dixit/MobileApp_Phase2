//
//  SearchViewController.m
//  LH2GO
//
//  Created by Sonal on 04/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#import "NotificationViewController.h"
#import "NotificationInfo.h"

@interface SearchViewController ()

@end

@implementation SearchViewController
{
    NSArray *searchedChannelsArray;
    NSArray *searchedFeedsArray;
    NSArray *searchSectionArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTabbarWithTag : BarItemTag_Search];
    [_searchTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 30.0f)];
    clearButton.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:14];
    [clearButton setTitle:@"u" forState:UIControlStateNormal];
    [clearButton setTitleColor:[Common colorwithHexString:@"85BD40" alpha:1.0] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _searchTextField.rightView = clearButton;
    _searchTextField.rightViewMode = UITextFieldViewModeUnlessEditing;

    self.navigationItem.rightBarButtonItem = nil;
    self.navigationController.navigationBar.hidden = NO;
    [self addNavigationBarViewComponents];
    searchedChannelsArray=[[NSArray alloc] init];
    searchSectionArray = @[@"Channels",@"Feeds"];
    
    UITapGestureRecognizer *gestureRecognizer = nil;
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_searchTextField resignFirstResponder];
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Search Results";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Table Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return [searchSectionArray count];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return searchedChannelsArray.count;
    }
    else if (section == 1){
        return searchedFeedsArray.count;
    }
    return 0;
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchTableViewCell *cell = [self.searchTableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell" forIndexPath:indexPath];
    if (indexPath.section == 0){
        Channels *channel = [searchedChannelsArray objectAtIndex:indexPath.row];
        cell.searchedTextLabel.text = channel.name;
        [cell.searchedImageView sd_setImageWithURL:[NSURL URLWithString:channel.image] placeholderImage:[UIImage imageNamed:placeholderGroup]];
    }
    else if (indexPath.section == 1){
        ChannelDetail *channelDetail = [searchedFeedsArray objectAtIndex:indexPath.row];
        cell.searchedTextLabel.text = channelDetail.text;
        [cell.searchedImageView sd_setImageWithURL:[NSURL URLWithString:channelDetail.mediaPath] placeholderImage:[UIImage imageNamed:placeholderGroup]];

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ChannelDetailViewController *channelDetailViewCntrl =(ChannelDetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ChannelDetailViewController"];
        Channels *channel = [searchedChannelsArray objectAtIndex:indexPath.row];
        channelDetailViewCntrl.channelSelected=channel;
        [self.navigationController pushViewController:channelDetailViewCntrl animated:YES];
    }
    if (indexPath.section == 1){
        ChannelDetailViewController *channelDetailViewCntrl =(ChannelDetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ChannelDetailViewController"];
        ChannelDetail *channelDetail = [searchedFeedsArray objectAtIndex:indexPath.row];
        NSString *activeNetId = [PrefManager activeNetId];
        Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
        NSArray *tempArray = [DBManager entities:@"Channels" pred:nil descr:nil isDistinctResults:YES];
         NSArray *channels = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.network = %@ && SELF.channelId = %@", net,channelDetail.channelId]];
        channelDetailViewCntrl.channelSelected=[channels lastObject];
        channelDetailViewCntrl.channelFeedSelected = channelDetail;
        [self.navigationController pushViewController:channelDetailViewCntrl animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor colorWithRed:(39.0f/255.0f) green:(38.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0];
    
    UILabel *headerHeading = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.frame.size.width-20, headerView.frame.size.height)];
    headerHeading.text = [searchSectionArray objectAtIndex:section];
    headerHeading.textColor = [UIColor whiteColor];
    headerHeading.font = [UIFont fontWithName:@"Aileron-Regular" size:16];
    [headerView addSubview:headerHeading];
    
    return headerView;
}

# pragma Mark
# pragma Mark- Text Field Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   // [self searchTextAddedByUser:textField.text];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    [self searchTextAddedByUser:textField.text];
    if ([textField.text isEqualToString:@""]) {
        [_searchTextField resignFirstResponder];
        return;
    }
}

/*- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [self searchTextAddedByUser:textField.text];
    return YES;
}*/

-(void)clearButtonAction:(UIButton*)button{
    [self searchTextAddedByUser:@""];
    _searchTextField.text=@"";
    [_searchTextField resignFirstResponder];
}

-(void)searchTextAddedByUser:(NSString*)searchText{
    searchedChannelsArray = [DBManager searchKeywordinChannelsForText:searchText];
    searchedFeedsArray = [DBManager searchKeywordinChannelFeedForText:searchText];
    _foundResultLabel.text = [NSString stringWithFormat:@"Found %ld results",[searchedChannelsArray count]+[searchedFeedsArray count]];
    [_searchTableView reloadData];
}

-(void)hideKeyboard
{
    [_searchTextField resignFirstResponder];
}

-(void)setMyChannel:(NSDictionary *)dic isFromBackground:(BOOL)isBackground
{
    
    ChanelViewController *channelVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ChanelViewController class])];
    
    NSString *channelName;
    if(!isBackground)
    {
        channelName = [[[dic objectForKey:@"Data"] componentsSeparatedByString:@":"] objectAtIndex:1];
    }else
    {
        NSArray *arr = [[[[dic objectForKey:@"Data"] componentsSeparatedByString:@"go to"] lastObject] componentsSeparatedByString:@" "];
        
        NSString *mergeString = @"";
        int i = 1;
        for(NSString *str11 in arr)
        {
            if (i !=1 && i != arr.count) {
                mergeString = [mergeString stringByAppendingString:str11];
            }
            i++;
        }
        channelName = mergeString;
    }
    
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    
    //NSArray *channel  = [DBManager getChannelsForNetwork:net];
    
    // fetch the data for channe;
    NSArray *dataOfParticularChannl =  [DBManager getChannelDataFromNameAndId:channelName isName:NO Network:net];
    
    NSString *channelID;
    Channels *channel;
    if (dataOfParticularChannl.count>0)
    {
        channel = [dataOfParticularChannl objectAtIndex:0];
        channelID = channel.channelId;
    }
    else
        return;
    
    channelVC.myChannel = channel;
    
    [self.navigationController pushViewController:channelVC animated:YES];
}

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict isBackGroundClick:(BOOL)isBackgroundClick
{
    [self.navigationController.navigationBar setHidden:false];
    
    if (isForChannel)
    {
        //push to channel view controller
        [self setMyChannel:dataDict isFromBackground:isBackgroundClick];
        return;
    }
    // check owner
    Group *gr = sht.group;
    CommsViewController *gvc = nil;
    ReplyViewController *rvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[ReplyViewController class]])//crash fix , please dont remove this code
    {
        //        ReplyViewController rv = (ReplyViewController )self.navigationController.topViewController;
        //        [self.navigationController popToRootViewControllerAnimated:YES];
        //        rv = nil;
    }
    if([self.navigationController.topViewController isKindOfClass:[CommsViewController class]])//crash fix , please dont remove this code
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KY" object:gr];
        return;
    }
    if(sht.parent_shout==nil)
    {
        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        gvc.myGroup = gr;
        
        NSMutableArray *nets = [NSMutableArray new];
        //   NSString *activeNetId = [PrefManager activeNetId];
        NSArray *networks = [DBManager getNetworks];
        for(Network *net in networks){
            NSArray *groups = [DBManager getShortedGroupsForNetwork:net];
            NSDictionary *d = @{ @"network" : net,
                                 @"groups"  : groups
                                 };
            [nets addObject:d];
            
        }
        
        NSDictionary  *d = [nets objectAtIndex:0];
        NSArray *groups = [d objectForKey:@"groups"];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [groups sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        __block BOOL isAvailable = false;
        __block NSUInteger index;
        
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            Group *gr1 = obj;
            if ([gr1.grId integerValue] == [gr.grId integerValue]) {
                isAvailable = YES;
                index       = idx;
            }
        }];
        
        if (isAvailable) {
            gvc.selectedGroupIndex = index;
        }
        
        
        [self.navigationController pushViewController:gvc animated:YES];
    }
    else
    {
        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        gvc.myGroup = gr;
        [self.navigationController pushViewController:gvc animated:NO];
        rvc = (ReplyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
        rvc.pShout = sht.parent_shout;
        rvc.myGroup=gr;
        [self.navigationController pushViewController:rvc animated:YES];
    }
    //  clear badge on group.
    if (gr.totShoutsReceived)
    {
        [gr clearBadge:gr];
        //[self updateBadgeForGroup];
    }
}


- (void)goToChannelScreenForFeed:(NSString *)content length:(NSString*)length contentId:(NSString*)contentId channelId:(NSString*)channelId cool:(NSString*)cool share:(NSString*)share contact:(NSString*)contact coolCount:(NSString*)coolCount shareCount:(NSString*)shareCount contactCount:(NSString*)contactCount channelID:(NSString *)channelID isClickOnPush:(BOOL)isClick isCreatedTime:(NSUInteger)createdTime typeOfFeed:(BOOL)feedType
{
    
    if([self.navigationController.topViewController isKindOfClass:[InfoViewController class]])//crash fix , please dont remove this code
    {
        // check owner
        Channels *ch = nil;
        NSString *activeNetId = [PrefManager activeNetId];
        Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
        NSArray *channels = [DBManager getChannelsForNetwork:net];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"channelId"
                                                     ascending:YES];
        channels = [channels sortedArrayUsingDescriptors:@[sortDescriptor]];
        for(Channels *ch1 in channels){
            
            if([ch1.channelId isEqualToString:channelId]){
                if (isClick) {
                    if (isClick) {
                        ch = ch1;
                    }
                }
            }
        }
        ChanelViewController *cvc = nil;
        if([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]])//crash fix , please dont remove this code
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content,@"content",length,@"length",contentId,@"contentId",cool,@"cool",share,@"share",contact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",@"NO",@"needToMove",[NSNumber numberWithInteger:createdTime],@"created",[NSNumber numberWithBool:feedType],@"feed_Type",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"KX" object:ch userInfo:dict];
            return;
        }
        if (isClick) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content,@"content",length,@"length",contentId,@"contentId",cool,@"cool",share,@"share",contact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",@"NO",@"needToMove",[NSNumber numberWithInteger:createdTime],@"created",[NSNumber numberWithBool:feedType],@"feed_Type",nil];
            cvc = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
            cvc.myChannel = ch;
            cvc.dataDictionary =  dict;
            [self.navigationController pushViewController:cvc animated:YES];
            
        }else
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:content,@"content",length,@"length",contentId,@"contentId",cool,@"cool",share,@"share",contact,@"contact",coolCount,@"coolCount",shareCount,@"shareCount",contactCount,@"contactCount",@"NO",@"needToMove",[NSNumber numberWithInteger:createdTime],@"created",[NSNumber numberWithBool:feedType],@"feed_Type",nil];
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            if(state == UIApplicationStateBackground)
            {
                cvc = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
                [self.navigationController pushViewController:cvc animated:YES];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"KX" object:ch userInfo:dict];
        }
    }
}

#pragma mark- PUSH Notification handling

- (void)goToNotificationScreen:(NSDictionary*)dict isClickedOnPush:(BOOL)isPush{
    NotificationViewController *cvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[NotificationViewController class]])//crash fix , please dont remove this code
    {
        [NotificationInfo parseResponse:dict];
        return;
    }
    if (isPush) {
        cvc = (NotificationViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CMSN" object:nil userInfo:dict];
}

- (void)goToChannelScreen:(NSDictionary*)dict{
    ChanelViewController *cvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[ChanelViewController class]])//crash fix , please dont remove this code
    {
        NSString *cId = [dict objectForKey:@"channel_id"];
        NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:cId,@"channelId",@"NO",@"needToMove",nil];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil userInfo:dict1];
        return;
    }
    cvc = (ChanelViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ChanelViewController"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"channelUpdate" object:nil];
}

-(void)moveToChannelScreen:(NSString *)channelID
{
    
}
@end
