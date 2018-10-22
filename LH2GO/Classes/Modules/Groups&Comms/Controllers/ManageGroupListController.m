//
//  ManageGroupListController.m
//  LH2GO
//
//  Created by Linchpin on 30/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "ManageGroupListController.h"
#import "ShoutManager.h"

@interface ManageGroupListController (){
    BOOL _isEntered;
    NSMutableArray *tempGrps;
    NSIndexPath *selectedIndex;
    NSMutableArray *tempNameArr;
}

@end

@implementation ManageGroupListController
@synthesize comingFor;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isEntered = 0;
    _tableMessage.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tempNameArr = [NSMutableArray new];
    tempGrps = [NSMutableArray new];
    // new group/network notification..
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kUpdateGroupList object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kActiveNetworkChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:kUpdateGroupList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:kActiveNetworkChange object:nil];
    // new shout notification..
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNewShoutEncounter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrivedInNotification:) name:kNewShoutEncounter object:nil];
    
        // create title label
        UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 1;

    if ([comingFor isEqualToString:@"Manage"]){
        titleLabel.text = @"Manage Group";
        [self addTabbarWithTag: BarItemTag_Groups];
    }
    else if([comingFor isEqualToString:@"Delete"]){
        titleLabel.text = @"Delete Group";
        [_btnRight setTitle:@"DELETE" forState:UIControlStateNormal];
    }
    else if([comingFor isEqualToString:@"Exit"]){
        titleLabel.text = @"Exit Group";
        [_btnRight setTitle:@"EXIT" forState:UIControlStateNormal];
    }
    
    titleLabel.textColor=[UIColor colorWithRed:(229.0f/225.0f) green:(0.0f/225.0f) blue:(28.0f/225.0f) alpha:1.0];
    [titleLabel sizeToFit];
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;

    [self addTopBarButtons];
    
    //set font size
    _btnCancel.titleLabel.font = [_btnCancel.titleLabel.font fontWithSize:[Common setFontSize:_btnCancel.titleLabel.font]];
    _btnRight.titleLabel.font = [_btnRight.titleLabel.font fontWithSize:[Common setFontSize:_btnRight.titleLabel.font]];
    
}

- (void)shoutArrivedInNotification:(NSNotification *)notification
{
    [self checkCountOfShouts];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableMessage reloadData];
 });
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
    self.navigationItem.rightBarButtonItem = nil;
    
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)viewWillAppear:(BOOL)animated
{
    // bydefault value
    _isSelected = NO;
    // [AppManager downloadUsers];
    [self gatherDatasource];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshList {
    [self gatherDatasource];
    [_tableMessage reloadData];
}
#pragma mark -- Button IBActions
- (IBAction)btnAction_RightSide:(id)sender {
    
    if (_isSelected) {
        
        
        if([comingFor isEqualToString:@"Delete"]){
            
            Group *group = [self groupOnIndexPath:selectedIndex];
            if(group != nil)
            {
                if(group.isPending){
                    
                    [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Are you sure you want to delete this group?" firstButtonMsg:@"YES" andSecondBtnMsg:@"NO" andVC:self noOfBtn:2 completion:^(BOOL isOkButton) {
                        
                        if (isOkButton) {
                            
                            [self removeGroupAtIndexPath:selectedIndex];
                            
                        }
                    }];
                    
                    
                    
                    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Are you sure you want to delete this group?" preferredStyle:UIAlertControllerStyleAlert];
                    //    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    
                    //         [self removeGroupAtIndexPath:selectedIndex];
                    //      }];
                    //      UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    
                    //      }];
                    //       [alert addAction:okAction];
                    //      [alert addAction:noAction];
                    //      [self presentViewController:alert animated:YES completion:nil];
                    
                    
                    
                }
                else{
                    
                    if ([group.owner.user_id isEqualToString:[Global shared].currentUser.user_id])
                    {
                        [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Are you sure you want to delete this group?" firstButtonMsg:@"YES" andSecondBtnMsg:@"NO" andVC:self noOfBtn:2 completion:^(BOOL isOkButton) {
                            
                            if (isOkButton) {
                                
                                [self deleteGroup:group];
                            }
                            
                            
                        }];
                    }
                    else
                    {
                        [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Please select one of the Group" firstButtonMsg:@"OK" andSecondBtnMsg:@"" andVC:self noOfBtn:1 completion:^(BOOL isOkButton) {
                            
                            if (isOkButton) {
                                
                            }
                        }];
                    }
                    
                    //            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Are you sure you want to delete this group?" preferredStyle:UIAlertControllerStyleAlert];
                    //            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    //
                    //                [self deleteGroup:group];
                    //            }];
                    //            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    //
                    //            }];
                    //            [alert addAction:okAction];
                    //            [alert addAction:noAction];
                    //            [self presentViewController:alert animated:YES completion:nil];
                    
                }
                
            }
            
        }
        if([comingFor isEqualToString:@"Exit"]){
            Group *group = [self groupOnIndexPath:selectedIndex];
            if(group != nil){
                
                if ([group.owner.user_id isEqualToString:[Global shared].currentUser.user_id]) {
                    [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Please select one of the Group" firstButtonMsg:@"OK" andSecondBtnMsg:@"" andVC:self noOfBtn:1 completion:^(BOOL isOkButton) {
                        
                        if (isOkButton) {
                            
                        }
                    }];
                }
                else
                {
                    [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Are you sure you want to exit this group?" firstButtonMsg:@"YES" andSecondBtnMsg:@"NO" andVC:self noOfBtn:2 completion:^(BOOL isOkButton) {
                        
                        if (isOkButton) {
                            
                            [self quitGroup:group];
                        }
                    }];
                }
                
                
                //            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Are you sure you want to exit this group?" preferredStyle:UIAlertControllerStyleAlert];
                //            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                //
                //                [self quitGroup:group];
                //
                //            }];
                //            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                //
                //            }];
                //            [alert addAction:okAction];
                //            [alert addAction:noAction];
                //            [self presentViewController:alert animated:YES completion:nil];
                
                
            }
            
            
        }
        
    }
    
    else
    {
        [AppManager showAlertViewWithTitle:@"Alert" andMessage:@"Please select one of the Group" firstButtonMsg:@"OK" andSecondBtnMsg:@"" andVC:self noOfBtn:1 completion:^(BOOL isOkButton) {
            
            if (isOkButton) {
                
            }
        }];
    }
    
}

- (IBAction)btnAction_Cancel:(id)sender {
    
    if([comingFor isEqualToString:@"Delete"] || [comingFor isEqualToString:@"Exit"] ){
        
        MessageCell *newCell = [_tableMessage cellForRowAtIndexPath:selectedIndex];
        
        [newCell setSelected:NO animated:YES];
        newCell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
        [newCell.btnCheck setTitle:@"w" forState:UIControlStateNormal];
        [newCell.btnCheck setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        _isEntered = 0;
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

#pragma mark - PrivateMethods

- (void)gatherDatasource
{
    [Global shared].isReadyToStartBLE = YES;
    NSMutableArray *nets = [NSMutableArray new];
    NSArray *networks = [DBManager getNetworks];
    for(Network *net in networks){
        
        if([net.netId isEqualToString:@"1"]){
            
            NSArray *groups = [DBManager getShortedGroupsForNetwork:net];
            NSDictionary *d = @{ @"network" : net,
                                 @"groups"  : groups
                                 };
            [nets addObject:d];
            
            _datasource = nets;
            
        
    }

}
}


- (void)SelectButton:(UIButton *)button
{
    NSInteger buttonIndex = button.tag;
    NSIndexPath *indexPathHighlight = [NSIndexPath indexPathForRow:buttonIndex inSection:0];
    selectedIndex = indexPathHighlight;
    MessageCell *newCell = [_tableMessage cellForRowAtIndexPath:indexPathHighlight];
    
    if([tempNameArr count]==1)
    {
        MessageCell *oldCell = [_tableMessage cellForRowAtIndexPath:[tempNameArr objectAtIndex:0]];
        [oldCell setSelected:NO animated:YES];
        oldCell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
        [oldCell.btnCheck setTitle:@"w" forState:UIControlStateNormal];
        [oldCell.btnCheck setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [tempNameArr removeAllObjects];
        
    }
    if ([tempNameArr containsObject:selectedIndex] )
    {
        [tempNameArr removeObject:selectedIndex];
    }
    else
    {
        [tempNameArr addObject:selectedIndex];
    }
    [newCell selectForDelete:[tempNameArr containsObject:selectedIndex]];
}

-(void)removeGroupAtIndexPath:(NSIndexPath*)indexPath{
    // remove this group from the list
    NSMutableDictionary *d = [[_datasource objectAtIndex:indexPath.section] mutableCopy];
    NSMutableArray *grps = [[d objectForKey:@"groups"] mutableCopy];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                 ascending:YES];
    NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
    // the array count is greater than or equal the index path of that group
    if (arr.count>=indexPath.row)
    {
    Group *gr = [arr objectAtIndex:indexPath.row];
    
    [DBManager deleteOb:gr];
    [grps removeObjectAtIndex:indexPath.row];
    
    if (grps.count == 0) {
        // delete network
        //  Network *net = [d objectForKey:@"network"];
        //[DBManager deleteOb:net];
        
        // remove this section
        [_datasource removeObjectAtIndex:indexPath.section];
        _isSelected = NO;
        
        
    } else {
        [d setObject:grps forKey:@"groups"];
        [_datasource replaceObjectAtIndex:indexPath.section withObject:d];
        _isSelected = NO;
        [_tableMessage reloadData];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
    }
}

- (Group *)groupOnIndexPath:(NSIndexPath *)indxP {
    if (!indxP) return nil;
    
    NSDictionary *d = [_datasource objectAtIndex:indxP.section];
    NSArray *grps;
    Group *gr ;
    if ([d allKeys].count) {
        grps = [d objectForKey:@"groups"];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
        gr = [arr objectAtIndex:indxP.row];
    }
    else
    {
        grps = [NSArray new];
        gr = nil;
    }
    return gr;
}

#pragma mark - Notification methods
- (void)shoutEncountered:(NSNotification *)notification
{
    //    Shout *sh = (Shout *) [notification object];
    //    NSArray *allVc = [self.navigationController viewControllers];
    //    for(UIViewController *vc in allVc)
    //    {
    //        if([vc isKindOfClass: [CommsViewController class]])
    //        {
    //            CommsViewController *cVc = (CommsViewController *) vc;
    //            BOOL isActiveGr = [cVc.myGroup.grId isEqualToString:sh.group.grId];
    //            if (isActiveGr)
    //            {
    //                // notify this class.
    //                [cVc recievedShout:sh];
    //                //  [self removeNotfication];
    //                return;
    //            }
    //        }
    //        else if([vc isKindOfClass: [ReplyViewController class]])
    //        {
    //            ReplyViewController *cVc = (ReplyViewController *) vc;
    //            BOOL isActiveGr = [cVc.myGroup.grId isEqualToString:sh.group.grId];
    //            if (isActiveGr)
    //            {
    //                // notify this class.
    //                [cVc recievedReplyShout:sh];
    //                //  [self removeNotfication];
    //                return;
    //            }
    //        }
    //    }
    //    // make badge on group.
    //    // [_listView updateBadgeForGroup:sh.group];
    //    // show banner..
    //    //if condition: if app is in background and user is open the app by taping on app icon then it should display the badge icon on group cell UI, BUT NOT SHOW BANNERALERT >> ALOK
    //    if ([[notification.userInfo  objectForKey:kShouldShowBanner] boolValue] == TRUE)
    //    {
    //        UIView *vv = [[AppManager appDelegate] window];
    //        [BannerAlert showOnView:vv WithName:sh.owner.user_name text:sh.text
    //                          image:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sh.owner.picUrl] withUniqueId:sh.shId shout:sh];
    //    }
}

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict
{
    //    // check owner
    //    Group *gr = sht.group;
    //    CommsViewController *gvc = nil;
    //    ReplyViewController *rvc = nil;
    //    if([self.navigationController.topViewController isKindOfClass:[ReplyViewController class]])//crash fix , please dont remove this code
    //    {
    //        ReplyViewController *rv = (ReplyViewController *)self.navigationController.topViewController;
    //        [self.navigationController popToRootViewControllerAnimated:YES];
    //        rv = nil;
    //    }
    //    if(![self.navigationController.topViewController isKindOfClass:[self class]])
    //        [self.navigationController popToViewController:self animated:NO];
    //    if(sht.parent_shout==nil)
    //    {
    //        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
    //        gvc.myGroup = gr;
    //        [self.navigationController pushViewController:gvc animated:YES];
    //    }
    //    else
    //    {
    //        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
    //        gvc.myGroup = gr;
    //        [self.navigationController pushViewController:gvc animated:NO];
    //        rvc = (ReplyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
    //        rvc.pShout = sht.parent_shout;
    //        rvc.myGroup=gr;
    //        [self.navigationController pushViewController:rvc animated:YES];
    //    }
    //    // clear badge on group.
    //    //    if (gr.badge)
    //    //    {
    //    //        [gr clearBadge];
    //    //        [_listView updateBadgeForGroup:gr];
    //    //    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    //NSInteger cnt = _usrDict.allKeys.count;
    //    if (isSearch) {
    //        return 1;
    //    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *d = [_datasource objectAtIndex:section];
    NSArray *grps = [d objectForKey:@"groups"];
    [tempGrps addObjectsFromArray:grps];
    return grps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"messageCell";
    MessageCell *cell = (MessageCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.btn_onCell.hidden = YES;
    
    NSDictionary *d = [_datasource objectAtIndex:indexPath.section];
    NSArray *grps = [d objectForKey:@"groups"];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                 ascending:YES];
    NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
    Group *gr = [arr objectAtIndex:indexPath.row];
    
    if ([comingFor isEqualToString:@"Manage"]){
        
        BOOL mine;
        if(gr.owner){
            mine = [gr.owner.user_id isEqualToString:[Global shared].currentUser.user_id];
            
        }
        else if (gr.owner == nil) {
            mine = NO;
        }
        else{
            mine = YES;
        }
        cell.btnCheck.hidden = YES;
        if(!mine){
            cell.btn_onCell.hidden = YES;
            cell.img_onCell.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.img_onCell.layer.borderWidth = 0.0;
        }
        else{
            cell.btn_onCell.hidden = NO; //accessaryIcon
            cell.img_onCell.layer.borderColor = [UIColor yellowColor].CGColor;
            cell.img_onCell.layer.borderWidth = 2.0;
            
        }
        [cell.btn_onCell setTitle:@"j" forState:UIControlStateNormal];
        
    }
    
    //if required
    if([comingFor isEqualToString:@"Delete"]||[comingFor isEqualToString:@"Exit"]){
        
        
        if(tempNameArr.count>0){
            [tempNameArr removeAllObjects];
        }
        
        BOOL mine;
        if(gr.owner){
            mine = [gr.owner.user_id isEqualToString:[Global shared].currentUser.user_id];
        }
        else if (gr.owner == nil) {
            mine = NO;
        }
        else{
            mine = YES;
        }
        if([comingFor isEqualToString:@"Delete"]){
            if(mine){
                cell.btnCheck.hidden = NO;
                cell.img_onCell.layer.borderColor = [UIColor yellowColor].CGColor;
                cell.img_onCell.layer.borderWidth = 2.0;
            }
            else{
                cell.btnCheck.hidden = YES;
                cell.img_onCell.layer.borderColor = [UIColor whiteColor].CGColor;
                cell.img_onCell.layer.borderWidth = 0.0;
            }
            // [cell.btnCheck setTitle:@"w" forState:UIControlStateNormal];
        }
        
        else  if([comingFor isEqualToString:@"Exit"]){
            if(mine){
                cell.btnCheck.hidden = YES;
                cell.img_onCell.layer.borderColor = [UIColor whiteColor].CGColor;
                cell.img_onCell.layer.borderWidth = 0.0;
            }
            else{
                
                cell.btnCheck.hidden = NO;
                cell.img_onCell.layer.borderColor = [UIColor yellowColor].CGColor;
                cell.img_onCell.layer.borderWidth = 2.0;
            }
        }
        [cell.btnCheck setTitle:@"w" forState:UIControlStateNormal];
        
        cell.btnCheck.tag = indexPath.row;
    }
    
    [cell showGroup:gr];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return  44;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kRatio * tableView.rowHeight;// assuming that the image will stretch across the width of the screen
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([comingFor isEqualToString:@"Manage"])
    {
        NSDictionary *d = [_datasource objectAtIndex:indexPath.section];
        NSArray *grps = [d objectForKey:@"groups"];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
        Group *gr = [arr objectAtIndex:indexPath.row];
        BOOL mine = NO;
        if(gr.owner){
            mine = [gr.owner.user_id isEqualToString:[Global shared].currentUser.user_id];
        }
        else if(gr.isPending){
            mine = YES;
        }
        
        if(mine){
            ManageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ManageViewController"];
            vc.selectedIndex = indexPath.row;
            vc.myGroup = gr;
            [self.navigationController pushViewController:vc animated:true];
        }
    }
    else if([comingFor isEqualToString:@"Delete"] || [comingFor isEqualToString:@"Exit"])
    {
        
        //        NSDictionary *d = [_datasource objectAtIndex:indexPath.section];
        //        NSArray *grps = [d objectForKey:@"groups"];
        //        NSSortDescriptor *sortDescriptor;
        //        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
        //                                                     ascending:YES];
        //NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        // Group *gr = [arr objectAtIndex:indexPath.row];
        
        //        _isSelected  = YES;
        MessageCell *newCell = [_tableMessage cellForRowAtIndexPath:indexPath];
        
        if([tempNameArr count]==1)
        {
            
            MessageCell *oldCell = [_tableMessage cellForRowAtIndexPath:[tempNameArr objectAtIndex:0]];
            [oldCell setSelected:NO animated:YES];
            oldCell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
            [oldCell.btnCheck setTitle:@"w" forState:UIControlStateNormal];
            [oldCell.btnCheck setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
            [tempNameArr removeAllObjects];
            _isSelected  = YES;
            [tempNameArr addObject:indexPath];
            selectedIndex = indexPath;
            
        }
        else if ([tempNameArr containsObject:indexPath])
        {
            _isSelected  = YES;
            [tempNameArr addObject:indexPath];
            [tempNameArr removeObject:indexPath];
            selectedIndex = indexPath;
            
        }
        else
        {
            _isSelected  = YES;
            [tempNameArr addObject:indexPath];
            selectedIndex = indexPath;
            
            
        }
        
        [newCell selectForDelete:[tempNameArr containsObject:indexPath]];
        
    }
    
}

#pragma mark - DeleteGroup

- (void)deleteGroup:(Group *)gp
{
    if (!gp) return;
        // check internet
        if(![AppManager isInternetShouldAlert:YES])
            return;
        
        // add loader..
        [LoaderView addLoaderToView:self.view];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject : gp.grId  forKey : @"id"];
        // add token..
        AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
        NSString *token = [PrefManager token];
        [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
        // hit api to delete group..
        [client POST:DeleteGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        } success:^(AFHTTPRequestOperation *operation, id responseObject){
            [LoaderView removeLoader];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            DLog(@"%@", response);
            if(response != NULL)
            {
            BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
            if(status)
            {
                _isSelected = NO;
                [self removeGroupAtIndexPath:selectedIndex];
                
            }
            else
            {
                NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
                [AppManager showAlertWithTitle:nil Body:str];
                // [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
            }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // [_listView shouldMarkDeleteMode:NO AtIndex:_selIndexPath];
            [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
        }];
}



#pragma mark - Exit Group

- (void)quitGroup:(Group *)gp
{
    if (!gp) return;
    // check internet
   
        if(![AppManager isInternetShouldAlert:YES]) return;
        // add loader..
        [LoaderView addLoaderToView:self.view];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject : gp.grId  forKey : @"group_id"];
        [param setObject : [Global shared].currentUser.user_id  forKey : @"user_id"];
        
        // add token..
        AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
        NSString *token = [PrefManager token];
        [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
        
        // hit api to delete group..
        [client POST:QuitGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [LoaderView removeLoader];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            DLog(@"%@", response);
            if(response != NULL)
            {
            BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
            if(status)
            {
                [self removeGroupAtIndexPath:selectedIndex];
            }
            else
            {
                NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
                [AppManager showAlertWithTitle:nil Body:str];
                
                if ([str isEqualToString:@"Group does not exist.!"]) {
                    
                    [self removeGroupAtIndexPath:selectedIndex];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [_tableMessage reloadData];
                        
                    });
                    
                }
            }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
        }];
    
}

@end
