//
//  InviteUserViewController.m
//  LH2GO
//
//  Created by Linchpin on 29/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "InviteUserViewController.h"
#import "Network.h"
#import "NSString+Extra.h"
#import "SharedUtils.h"
#import "TimeConverter.h"

@interface InviteUserViewController ()<UIScrollViewDelegate,APICallProtocolDelegate>{
    NSArray *allUsersList;
    SharedUtils *sharedUtils;
    Network *actNet;
}
@end

@implementation InviteUserViewController
@synthesize delegate;



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    _selectedUsers  = [[NSMutableArray alloc] init];
    sharedUtils.delegate = self;
    [self addTopBarButtons];
    NSString *activeNetId = [PrefManager activeNetId];
    actNet = [Network networkWithId:activeNetId shouldInsert:NO];
    if(_showAllUsers)
    {
        [self getUsersAll:actNet];
    }
    else
    {
        [self getUsersNotInGroup:self.groupObj];
    }
    //searchBar
    _serachBar.tintColor = [UIColor blackColor];
    [_serachBar setPlaceholder:@"Type email address"];
    _serachBar.barTintColor = [UIColor clearColor];
    _serachBar.backgroundColor = [UIColor clearColor];
    _serachBar.searchBarStyle = UISearchBarStyleProminent ;
    
    UITapGestureRecognizer *gestureRecognizer = nil;
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    [self setNavBarTitle];
}

- (void)setNavBarTitle {
    
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text = @"Invite Users";
    titleLabel.textColor=[UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

- (void)addTopBarButtons
{
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [leftButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    
    UIBarButtonItem * righttButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveChanges)];
    righttButton.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = righttButton;
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

-(void)saveChanges
{
    [_serachBar resignFirstResponder];
    if(_selectedUsers.count > 0)
    {
        NSArray *emails = [self usersEmails];
        if (emails && [emails count])
        {
            BOOL verified = [self verifyEmails:emails];
            if (!verified) return;
        }
        
        if (!_isSingleUserInvite) {
            if (delegate && [delegate respondsToSelector:@selector(didInviteUsers: andEmails:)]){
                [delegate didInviteUsers:_selectedUsers andEmails:emails];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else{
            [LoaderView addLoaderToView:self.view];
            [self inviteIndividualUser];
        }
    }
    else
    {
        [AppManager showAlertWithTitle:@"" Body:@"Please select a user to invite"];
    }
}

-(void)inviteIndividualUser{
    if([_selectedUsers count] > 1){
        [AppManager showAlertWithTitle:@"Alert!" Body:@"Please add only one user."];
    }
    else{
        NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[_selectedUsers valueForKey:@"email"] lastObject],@"user_email",[[[Global shared] currentUser] user_id],@"user_id",nil];
        NSLog(@"%@",postDictionary);
        //Make api call
        if ([AppManager isInternetShouldAlert:YES])
        {
            //show loader...
            //        [LoaderView addLoaderToView:self.view];
            NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,SENDUSERINVITE];
             [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
        }
        else
        {
            [AppManager showAlertWithTitle:@"Alert!" Body:@"Please check your internet connection"];
            [LoaderView removeLoader];
        }
    }
}

#pragma mark- Private Methods
- (NSArray *)usersEmails
{
    if (!_serachBar.text.length)
    {
        // no emails
        return nil;
    }
    NSArray *arr = [_serachBar.text componentsSeparatedByString:@","];
    return arr;
}

-(void)getUserDetails{
    [LoaderView addLoaderToView:self.view];
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:_serachBar.text,@"email",@"",@"username",nil];
    
    //Make api call
    if ([AppManager isInternetShouldAlert:YES])
    {
        //show loader...
        //        [LoaderView addLoaderToView:self.view];
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,DOESUSEREXISTS];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
    }
    else
    {
        [AppManager showAlertWithTitle:@"Alert!" Body:@"Please check your internet connection"];
        [LoaderView removeLoader];
    }
}

- (BOOL)verifyEmails:(NSArray *)emails
{
    NSMutableArray *list = [NSMutableArray new];
    NSMutableString *alrtstr = [NSMutableString new];
    for (NSString *email in emails)
    {
        if ([[email withoutWhiteSpaceString] isValidForEmail])
        {
            [list addObject:email];
        }
        else
        {
            if (alrtstr.length)
            {
                [alrtstr appendFormat:@","];
            }
            [alrtstr appendString:email];
        }
    }
    if (alrtstr.length)
    {
        [AppManager showAlertWithTitle:@"Alert!" Body:[NSString stringWithFormat:@"please check their emails are invalid - %@", alrtstr]];
        return NO;
    }
    return YES;
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hideKeyboard
{
    [_serachBar resignFirstResponder];
}

- (void)buttonTapped:(UIButton *)button
{
    DLog(@"Selected Users List  %@",_selectedUsers);
    if (_selectedUsers.count >= button.tag)
    {
        //NSArray *arr = _selectedUsers;
        User *u = [_selectedUsers objectAtIndex:button.tag];
        if ([_selectedUsers containsObject:u])
        {
            [_selectedUsers removeObject:u];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_collectionInvitee reloadData];
            [_table reloadData];
            
        });
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (isSearching) {
        return [filteredContentList count];
    }
    //    else {
    //        return allUsersList.count;
    //    }
    return [filteredContentList count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90 * kRatio;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"messageCell";
    
    MessageCell *cell = (MessageCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    User *u = nil;
    if (isSearching && filteredContentList.count>0) {
        u = [filteredContentList objectAtIndex:indexPath.row];
        [cell displayUser:u];
        [cell selectMe:[_selectedUsers containsObject:u]];
        
    }
    else {
        
        //        u = [allUsersList objectAtIndex:indexPath.row];
        //        [cell displayUser:u];
        //        [cell selectMe:[_selectedUsers containsObject:u]];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isSearching && filteredContentList.count>0)
    {
        NSArray *arr = filteredContentList;
        User *u = [arr objectAtIndex:indexPath.row];
        if ([_selectedUsers containsObject:u])
        {
            [_selectedUsers removeObject:u];
        }
        else
        {
            [_selectedUsers addObject:u];
        }
        MessageCell *cell = (MessageCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell selectMe:[_selectedUsers containsObject:u]];
        [_collectionInvitee reloadData];
    }
    else
    {
        //        NSArray *arr = allUsersList;
        //        User *u = [arr objectAtIndex:indexPath.row];
        //        if ([_selectedUsers containsObject:u])
        //        {
        //            [_selectedUsers removeObject:u];
        //        }
        //        else
        //        {
        //            [_selectedUsers addObject:u];
        //        }
    }
}
#pragma SearchBar Delegates

- (void)searchTableList {
    
    
}




#pragma mark - Search Implementation

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DLog(@"Text change - %d",isSearching);
    
    //Remove all objects first.
    
    NSPredicate *sPredicate;
    if ([searchBar.text isEqualToString:@""])
    {
        isSearching=NO;
        [_table reloadData];
    }
    else
    {
        isSearching = YES;
        NSString * match = searchBar.text;
        sPredicate = [NSPredicate predicateWithFormat:@"SELF.email LIKE[cd] %@", match];
        filteredContentList = [allUsersList filteredArrayUsingPredicate:sPredicate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_table reloadData];
            
        });
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"Search Clicked");
    if(filteredContentList.count == 0){
        [self getUserDetails];
    }
    
    [searchBar resignFirstResponder];
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return _selectedUsers.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"GroupCollectionCell";
    GroupCollectionCell *cell = (GroupCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.imageUser.image =  [UIImage imageNamed:@"GroupUserIcon.png"];
    
    cell.btnRemove.tag = indexPath.row;
    [cell.btnRemove addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    User *u = nil;
    u = [_selectedUsers objectAtIndex:indexPath.row];
    [cell displayUser:u];
    if (_selectedUsers.count > 0)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
    return cell;
}


#define kCellWidth 109
#define kCellHeight 109
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(kCellWidth*kRatio, kCellHeight*kRatio);
    
}



- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma Private Methods

- (void)getUsersAll:(Network*)selectedNetwork
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setInteger:1 forKey:k_userShow];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSString *str = @"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z";
    NSArray *alphas = [str componentsSeparatedByString:@" "];
    NSMutableArray *list = [[DBManager usersSorted:YES] mutableCopy];
    // remove me
    NSString *myId = [[[Global shared] currentUser] user_id];
    NSString*parent_account_id = [[[Global shared] currentUser] parent_account_id];
    NSString*user_role = [[[Global shared]currentUser] user_role];
    for (User *u in list)
    {
        if ([myId isEqualToString:u.user_id])
        {
            [list removeObject:u]; break;
        }
    }
    NSPredicate*NewbPredicate;
    if (selectedNetwork==nil)
    {
        if ([user_role isEqualToString:@"Account"])
        {
            NewbPredicate = [NSPredicate predicateWithFormat: @"SELF.parent_account_id=%@", myId];
        }
        else
        {
            NewbPredicate = [NSPredicate predicateWithFormat:@"SELF.parent_account_id=%@ OR SELF.user_id=%@", parent_account_id, parent_account_id];
        }
    }
    else
    {
        if ([user_role isEqualToString:@"Account"])
        {
            if ([selectedNetwork.netId integerValue] != k_LHNetworkId)
                NewbPredicate = [NSPredicate predicateWithFormat: @"SELF.parent_account_id=%@", myId];
            else
                NewbPredicate = nil;
        }
        else
        {
            if ([selectedNetwork.netId integerValue] != k_LHNetworkId && user_role.length > 0) {
                NewbPredicate = [NSPredicate predicateWithFormat:@"SELF.parent_account_id=%@ OR SELF.user_id=%@",parent_account_id, parent_account_id];
            }
            else
            {
                NewbPredicate = nil;
            }
        }
    }
    NSArray*newlist = nil;
    if (NewbPredicate != nil)
    {
        newlist = [list filteredArrayUsingPredicate:NewbPredicate];
    }
    else
    {
        newlist = list;
    }
    newlist = [newlist sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_name" ascending:YES]]];
    allUsersList = [NSArray arrayWithArray:newlist];
    // create sections
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSMutableArray *secs = [NSMutableArray new];
    for (NSString *str in alphas)
    {
        NSString *pstr = [NSString stringWithFormat:@"user_name beginswith[c] '%@'", [str lowercaseString]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:pstr];
        NSArray *usrs = [newlist filteredArrayUsingPredicate:predicate];
        if (usrs.count)
        {
            [secs addObject:str];
            [secs addObject:@""];
            [dict setObject:usrs forKey:str];
        }
    }
    
}


- (void)getUsersNotInGroup:(Group *)group
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setInteger:0 forKey:k_userShow];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSString *str = @"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z";
    NSArray *alphas = [str componentsSeparatedByString:@" "];
    NSMutableArray *list = [[DBManager usersSorted:YES notInGroup:group] mutableCopy];
    // remove me
    NSString *myId = [[[Global shared] currentUser] user_id];
    NSString*parent_account_id = [[[Global shared] currentUser] parent_account_id];
    NSString*user_role = [[[Global shared]currentUser] user_role];
    for (User *u in list)
    {
        if ([myId isEqualToString:u.user_id])
        {
            [list removeObject:u]; break;
        }
    }
    NSPredicate*NewbPredicate;
    if ([user_role isEqualToString:@"Account"])
    {
        if ([group.network.netId integerValue] != k_LHNetworkId)
            NewbPredicate = [NSPredicate predicateWithFormat: @"SELF.parent_account_id=%@", myId];
        else
            NewbPredicate = nil;
    }
    else
    {
        if ([group.network.netId integerValue] != k_LHNetworkId && user_role.length > 0)
        {
            NewbPredicate = [NSPredicate predicateWithFormat:@"SELF.parent_account_id=%@ OR SELF.user_id=%@",parent_account_id, parent_account_id];
        }
        else
        {
            NewbPredicate = nil;
        }
    }
    NSArray*newlist = nil;
    if (NewbPredicate != nil)
    {
        newlist = [list filteredArrayUsingPredicate:NewbPredicate];
    }
    else
    {
        newlist = list;
    }
    newlist = [newlist sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_name" ascending:YES]]];
    allUsersList = [NSArray arrayWithArray:newlist];
    // create sections
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSMutableArray *secs = [NSMutableArray new];
    for (NSString *str in alphas)
    {
        NSString *pstr = [NSString stringWithFormat:@"user_name beginswith[c] '%@'", [str lowercaseString]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:pstr];
        NSArray *usrs = [newlist filteredArrayUsingPredicate:predicate];
        if (usrs.count)
        {
            [secs addObject:str];
            [secs addObject:@""];
            [dict setObject:usrs forKey:str];
        }
    }
}

#pragma mark -  Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_serachBar resignFirstResponder];
}


#pragma mark- Shared Utils Delegate Method

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL{
    if(responseDict != nil)
    {
        DLog(@"responseDict is --- %@",responseDict);
        [LoaderView removeLoader];
        BOOL status = [[responseDict objectForKey:@"status"] boolValue];
        NSString *msgStr= [responseDict objectForKey:@"status"];
        if (status || [msgStr isEqualToString:@"Success"] || [[responseDict objectForKey:@"type"] intValue] == 20)
        {
            
//            Url : [Base_IP]/P2P/send_invite
//            Request Params : {"user_email":"xxx@vvdntech.in","user_id":"2999"}
//            Response : { "message": "P2P request sent.","status": "Success" }
            
            if([[dataTaskURL lastPathComponent] isEqualToString:@"send_invite"])
            {
                // get the user for the P2p Chat
                //user.loud_hailerid
                User *user= [_selectedUsers objectAtIndex:0];
                int length = (UInt64)strtoull([user.loud_hailerid UTF8String], NULL, 16);
                NSLog(@"The required Length is %d", length);

                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",length],@"id",user.user_name,@"group_name",[NSString stringWithFormat:@"%ld",[TimeConverter timeStamp]],@"timestamp",user.picUrl,@"group_photo", nil];
                
                [Group addGroupWithDictForP2PContact:dic forUsers:@[user] pic:nil isPendingStatus:YES];
                
                [AppManager showAlertViewWithTitle:@"Alert!" andMessage:[responseDict objectForKey:@"message"] firstButtonMsg:kP2PRequestSuccessResponse andSecondBtnMsg:@"Cancel" andVC:self noOfBtn:1 completion:^(BOOL isOkButton) {
                    if (isOkButton) {
                        [self goBack];
                    }
                }];
            }
            else
            {
                NSDictionary *data = [responseDict objectForKey:@"data"];
                NSDictionary *usrDict  = [data objectForKey:@"User"];
                User *u= [User addUserWithDict:usrDict pic:nil];
                u.parent_account_id = @"1011";
                [DBManager save];
            
                if(_showAllUsers){
                    [self getUsersAll:actNet];
                }
                else{
                    [self getUsersNotInGroup:self.groupObj];
                }
                NSPredicate *sPredicate;
                NSString * match = _serachBar.text;
                sPredicate = [NSPredicate predicateWithFormat:@"SELF.email LIKE[cd] %@", match];
                filteredContentList = [allUsersList filteredArrayUsingPredicate:sPredicate];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_table reloadData];
            });
               ///            }
//            else{
//            }
            }
        }
        else
        {
            [AppManager showAlertWithTitle:@"Alert" Body:@"No user exists with this email id."];
            [LoaderView removeLoader];
        }
    }else
    {
        [LoaderView removeLoader];
    }
}

@end
