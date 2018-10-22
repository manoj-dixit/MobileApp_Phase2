//
//  SearchViewController.m
//  LH2GO
//
//  Created by Sonal on 04/09/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"

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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _searchTextField.text = @"";
    [_searchTextField resignFirstResponder];
    NSArray *tempArray = [[NSArray alloc] init];
    searchedChannelsArray = tempArray;
    searchedFeedsArray = tempArray;
    [_searchTableView reloadData];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField.text isEqualToString:@""]) {
        [self searchTextAddedByUser:string];
    }
    else{
        [self searchTextAddedByUser:textField.text];
    }
    return YES;
}

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

@end
