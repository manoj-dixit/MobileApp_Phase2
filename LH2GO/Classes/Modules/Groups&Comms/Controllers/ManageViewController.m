//
//  ManageViewController.m
//  LH2GO
//
//  Created by Linchpin on 28/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "ManageViewController.h"
#import "NSString+Extra.h"
#import "SelectNetworkCell.h"

@interface ManageViewController ()
{
    NSArray *_networks;
    BOOL isEnable;
    BOOL  _isPicSelected;
    NSMutableArray *_selectedUsers;
    NSArray *_emails;
    NSMutableArray *allUsers;
    NSMutableArray *deletedUsersIDs;
    NSMutableArray *newUserIds;
    NSArray *pendingEmailUsers;
    NSMutableDictionary *_usrDict;
    NSArray *pendingUsersArr;


}
@end

@implementation ManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNib];
    [self addTabbarWithTag: BarItemTag_Groups];
    [self gatherNetworks];
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width*kRatio/2;
    self.userImage.contentMode = UIViewContentModeScaleAspectFill;
    self.userImage.layer.masksToBounds = YES;
    _txt_GroupName.delegate = self;
   
    self.btnAddImage.layer.cornerRadius = self.btnAddImage.frame.size.width*kRatio/2;
    self.btnAddImage.layer.masksToBounds = YES;
    self.userImage.layer.masksToBounds = YES;
    
    [self addTopBarButtons];
    [self.txt_GroupName setPlaceholderColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    self.txt_GroupName.text = self.myGroup.grName;
    
    _selectedUsers = [NSMutableArray new];
    [_selectedUsers removeAllObjects];
    
    [_userImage sd_setImageWithURL:[NSURL URLWithString: self.myGroup.picUrl]placeholderImage:[UIImage imageNamed:placeholderUser]];
    
    deletedUsersIDs = [[NSMutableArray alloc] init];
    [deletedUsersIDs removeAllObjects];
    
    newUserIds = [[NSMutableArray alloc] init];
    allUsers = [[NSMutableArray alloc] initWithArray:self.myGroup.users.allObjects];
    [self getUsers];
    
    //setFontSize
    _txt_GroupName.font = [_txt_GroupName.font fontWithSize:[Common setFontSize:_txt_GroupName.font]];
    _btnAddImage.titleLabel.font = [_btnAddImage.titleLabel.font fontWithSize:[Common setFontSize:_btnAddImage.titleLabel.font]];
    
    //adjust tableHeaderView
    _tableAddGroup.autoresizesSubviews = YES;
    CGRect newFrame = _tableAddGroup.tableHeaderView.frame;
    newFrame.size.height = newFrame.size.height * kRatio;
    _tableAddGroup.tableHeaderView.frame = newFrame;
    
    //adjust UserImage /ChangeProfileImage Btn size
    CGRect frame ;
    frame = [Common adjustRoundShapeFrame:_userImage.frame];
    _userImgHeight.constant = frame.size.height;
    _userImgWidth.constant = frame.size.width ;
    frame = [Common adjustRoundShapeFrame:_btnAddImage.frame];
    _btnIconHeight.constant = frame.size.height;
    _btnIconWidth.constant = frame.size.width ;
    [self setNavBarTitle];

}

- (void)setNavBarTitle {
    
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text = @"Manage Group";
    titleLabel.textColor=[UIColor colorWithRed:(229.0f/225.0f) green:(0.0f/225.0f) blue:(28.0f/225.0f) alpha:1.0];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}


- (void)addTopBarButtons
{
    
    UIBarButtonItem * lefttButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveChanges)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = lefttButton;
    
}


-(void)saveChanges{
       if(![AppManager isInternetShouldAlert:YES]) {
        
           if (!_isPicSelected && [_txt_GroupName.text isEqualToString: self.myGroup.grName]&&!deletedUsersIDs.count&&!_selectedUsers.count&&!_emails.count)
           {
               [AppManager showAlertWithTitle:nil Body:@"No change."];
               return;
           }
           if (_txt_GroupName.text.length<3)
           {
               [AppManager showAlertWithTitle:nil Body:@"Group name should be between 3 to 30 characters."];
               return;
           }

           
        if(self.myGroup.isPending){
            [DBManager deleteUsers:deletedUsersIDs fromGroup:self.myGroup];
            [DBManager addInvitedUsers:_selectedUsers toGroup:self.myGroup];
            [DBManager addEmailedUsers:_emails toGroup:self.myGroup];
            
            if(_isPicSelected){
                NSData *imageData =  UIImageJPEGRepresentation(_userImage.image, .5);
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",@"cached"]];
                
                DLog(@"pre writing to file");
                if (![imageData writeToFile:imagePath atomically:NO])
                {
                    NSLog(@"Failed to cache image data to disk");
                }
                else
                {
                    DLog(@"the cachedImagedPath is %@",imagePath);
                }
                
                self.myGroup.picUrl = imagePath;
                [DBManager save];
            }
        }
        else{
            self.myGroup.isPending = YES;
            self.myGroup.grName = [_txt_GroupName.text withoutWhiteSpaceString];
            if(_isPicSelected){
                NSData *imageData =  UIImageJPEGRepresentation(_userImage.image, .5);
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",@"cached"]];
                
                DLog(@"pre writing to file");
                if (![imageData writeToFile:imagePath atomically:NO])
                {
                    NSLog(@"Failed to cache image data to disk");
                }
                else
                {
                    DLog(@"the cachedImagedPath is %@",imagePath);
                }
                
                self.myGroup.picUrl = imagePath;
                
            }
            [DBManager save];

            if (_selectedUsers.count)
            {
                NSMutableArray *users = [NSMutableArray new];
                for (User *usr in _selectedUsers)
                {
                    [users addObject:usr.user_id];
                }
                [DBManager addInvitedUsers:_selectedUsers toGroup:self.myGroup];
                _selectedUsers = nil;


            }
            if(_emails && _emails.count)
            [DBManager addEmailedUsers:_emails toGroup:self.myGroup];
            if(deletedUsersIDs&&deletedUsersIDs.count){
            [DBManager deleteUsers:deletedUsersIDs fromGroup:self.myGroup];
            [deletedUsersIDs removeAllObjects];
            }
            NSString *str = [NSString stringWithFormat:@"%@", @"Your group changes are pending. Please connect to Internet to complete!"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppManager showAlertWithTitle:nil Body:str];
                
            });
            // move to home
            [self.navigationController popViewControllerAnimated:YES];
            // fire notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];

            
        }
        
        
    }
    
    else if(self.myGroup.isPending && [AppManager isInternetShouldAlert:YES] ){
        
        if (_txt_GroupName.text.length<3)
        {
            [AppManager showAlertWithTitle:nil Body:@"Group name should be between 3 to 30 characters."];
            return;
        }

        NSString *alertTxt;
        if ([_txt_GroupName.text withoutWhiteSpaceString].length < 3 || [_txt_GroupName.text withoutWhiteSpaceString].length > 30)
        {
            alertTxt = @"Group name should be between 3 to 30 characters.";
        }
        if (alertTxt.length)
        {
            [AppManager showAlertWithTitle:nil Body:alertTxt]; return;
        }
        
     
        // add loader..
        [LoaderView addLoaderToView:self.view];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        NSString *test = _txt_GroupName.text;
        DLog (@" %@ ", test);
        NSMutableArray *users = [NSMutableArray new];
       NSMutableArray *tempUsers = [[self.myGroup.pendingUsers allObjects] mutableCopy];
        for (User *usr in tempUsers)
        {
            [users addObject:usr.user_id];
        }
        if(tempUsers.count && tempUsers)
        {
            [param setObject : users   forKey : @"users_list"];
        }
        else
        {
            [param setObject :[NSNull null] forKey : @"users_list"];
        }
        
        if(tempUsers.count && tempUsers){
         for (User *usr in tempUsers)
        {
            
            if(usr.email)
            [param setObject : usr.email   forKey : @"user_emails"];
            else
            [param setObject :[NSNull null] forKey : @"user_emails"];
   
        }
        }
        else{
             [param setObject :[NSNull null] forKey : @"user_emails"];
        }
       
        if (_selectedUsers.count)
        {
            NSMutableArray *users = [NSMutableArray new];
            for (User *usr in _selectedUsers)
            {
                [users addObject:usr.user_id];
            }
            if(users&&users.count)
                [param setObject:users   forKey:@"addedusers"];
        }
        if (_emails && _emails.count)
            [param setObject:_emails   forKey:@"user_emails"];
        
        [param setObject : [Global shared].currentUser.user_id forKey : @"owner_id"];
        [param setObject : [PrefManager activeNetId]   forKey : @"network_id"];
        [param setObject: [_txt_GroupName.text withoutWhiteSpaceString]  forKey : @"group_name"];
        // image..
      //  __block NSData *imgData;
      //  if(_isPicSelected) imgData = UIImageJPEGRepresentation(_userImage.image, .5);
        if(_isPicSelected){
            NSData *imageData =  UIImageJPEGRepresentation(_userImage.image, .5);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",@"cached"]];
            
            NSLog(@"pre writing to file");
            if (![imageData writeToFile:imagePath atomically:NO])
            {
                NSLog(@"Failed to cache image data to disk");
            }
            else
            {
                NSLog(@"the cachedImagedPath is %@",imagePath);
            }
            
            self.myGroup.picUrl = imagePath;
            
        }
        [DBManager save];
        // add token..
        AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
        NSString *token = [PrefManager token];
        [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
        [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSData *imageData = [NSData dataWithContentsOfFile:self.myGroup.picUrl];
        UIImage *img = [UIImage imageWithData:imageData];
       
       
      
        [client POST:AddGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            DLog(@"Class%@",[param class]);
            if(imageData)  [formData appendPartWithFileData:imageData name:@"group_photo" fileName:@"grpImage.jpg" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
            [LoaderView removeLoader];
            NSError *errorJson=nil;
            NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers |NSJSONReadingAllowFragments error:&errorJson];
            DLog(@"responseDict AND error is %@=%@",response,errorJson);
             if(response != NULL)
             {
            BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
            if(status)
            {
               // User *user = [[Global shared] currentUser];
                NSMutableArray *users = [[self.myGroup.pendingUsers allObjects] mutableCopy];
               // users = [users initWithCapacity:users.count + 1];

              //  NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:_selectedUsers.count+1];
              //  [users addObject:user];
               // [users addObjectsFromArray:_selectedUsers];
                [self removeGroupAtIndexPath:_selectedIndex];

                NSDictionary *groupD = [response objectForKey:@"groupData"];
                Group *gr = [Group addGroupWithDict:groupD forUsers:users pic:(img) ? img : nil pending:NO];
                DLog(@"*** grp id  %@", gr.grId);
                NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppManager showAlertWithTitle:nil Body:str];
                    
                });
                // move to home
                [self.navigationController popViewControllerAnimated:YES];
                // fire notification
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
            }
            else
            {
                NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
                [AppManager showAlertWithTitle:nil Body:str];
            }
             }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
        }];

    }
    
    else{
        if (!_isPicSelected && [_txt_GroupName.text isEqualToString: self.myGroup.grName]&&!deletedUsersIDs.count&&!_selectedUsers.count&&!_emails.count)
        {
            [AppManager showAlertWithTitle:nil Body:@"No change."];
            return;
        }
        if (_txt_GroupName.text.length<3)
        {
            [AppManager showAlertWithTitle:nil Body:@"Group name should be between 3 to 30 characters."];
            return;
        }

    // add loader..
    [LoaderView addLoaderToView:self.view];
    _selectedUsers = nil;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject : self.myGroup.grId  forKey : @"id"];
    [param setObject : [Global shared].currentUser.user_id  forKey : @"user_id"];
    if (_selectedUsers.count)
    {
        NSMutableArray *users = [NSMutableArray new];
        for (User *usr in _selectedUsers)
        {
            [users addObject:usr.user_id];
        }
        if(users&&users.count)
            [param setObject:users   forKey:@"addedusers"];
    }
    if (_emails && _emails.count)
        [param setObject:_emails   forKey:@"user_emails"];
    if(deletedUsersIDs&&deletedUsersIDs.count)
        [param setObject:deletedUsersIDs  forKey : @"deletedusers"];
    [param setObject:_txt_GroupName.text   forKey:@"group_name"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // image..
    __block NSData *imgData;
    if(_isPicSelected) imgData = UIImageJPEGRepresentation(_userImage.image, .5);
    [client POST:EditGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(_isPicSelected)  [formData appendPartWithFileData:imgData name:@"group_photo" fileName:@"myimage.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        DLog(@"%@", response);
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            NSDictionary *userData = [response objectForKey:@"groupData"];
            self.myGroup.grName = _txt_GroupName.text;
            _txt_GroupName.text = self.myGroup.grName;
            self.myGroup.isPending = NO;
            _txt_GroupName.userInteractionEnabled = NO;
            isEnable = NO;

            if (_isPicSelected)
            {
                self.myGroup.picUrl = [AppManager sutableStrWithStr:[userData objectForKey:@"group_photo"]];
            
                [[SDImageCache sharedImageCache] storeImage:_userImage.image forKey:self.myGroup.picUrl];
            }
            [DBManager deleteUsers:deletedUsersIDs fromGroup:self.myGroup];
            [DBManager addInvitedUsers:_selectedUsers toGroup:self.myGroup];
            [DBManager addEmailedUsers:_emails toGroup:self.myGroup];
            _selectedUsers = nil;
            [deletedUsersIDs removeAllObjects];
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            [AppManager showAlertWithTitle:nil Body:str];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            [AppManager showAlertWithTitle:nil Body:str];
        }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
        [LoaderView removeLoader];
    }];
}

}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)gatherDatasource
{
    [Global shared].isReadyToStartBLE = YES;
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
    _datasource = nets;
    
}

-(void)removeGroupAtIndexPath:(NSInteger)indexPath{
    // remove this group from the list
    [self gatherDatasource];
    NSMutableDictionary *d = [[_datasource objectAtIndex:0] mutableCopy];
    NSMutableArray *grps = [[d objectForKey:@"groups"] mutableCopy];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                 ascending:YES];
    NSArray *arr = [grps sortedArrayUsingDescriptors:@[sortDescriptor]];

    Group *gr = [arr objectAtIndex:indexPath];
    [DBManager deleteOb:gr];
    [grps removeObjectAtIndex:indexPath];
    
    if (grps.count == 0) {
        // delete network
    //    Network *net = [d objectForKey:@"network"];
      //  [DBManager deleteOb:net];
        
        // remove this section
        [_datasource removeObjectAtIndex:0];
        
        
    } else {
        [d setObject:grps forKey:@"groups"];
        [_datasource replaceObjectAtIndex:0 withObject:d];
       
    }
}
#pragma mark - IBAction Methods

- (IBAction)btnAction_Edit:(id)sender {
    
    if(!isEnable){
        _txt_GroupName.text = @"";
        _txt_GroupName.userInteractionEnabled = YES;
        [_txt_GroupName becomeFirstResponder];
        isEnable = YES;
        
    }
    
    else{
        _txt_GroupName.text = self.myGroup.grName;
        _txt_GroupName.userInteractionEnabled = NO;
        isEnable = NO;
        
    }

}

- (IBAction)changeGrpImg:(id)sender {

    [_txt_GroupName resignFirstResponder];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view];

}



-(void)registerNib
{
    [self.tableAddGroup registerNib:[UINib nibWithNibName:@"SelectNetworkCell" bundle:nil] forCellReuseIdentifier:@"SelectNetworkCell"];
    [self.tableAddGroup registerNib:[UINib nibWithNibName:@"InviteBtnCell" bundle:nil] forCellReuseIdentifier:@"InviteBtnCell"];
    [self.tableAddGroup registerNib:[UINib nibWithNibName:@"PendingUsersCell" bundle:nil] forCellReuseIdentifier:@"PendingUsersCell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethods

- (void)gatherNetworks
{
    User *user = [[Global shared] currentUser];
    NSArray *allGroups = [[user groups] allObjects];
    NSMutableArray *nets = [NSMutableArray new];
    for (Group *gr in allGroups)
    {
        if (gr.network&&![nets containsObject:gr.network])
            [nets addObject:gr.network];
    }
    _networks = nets;
}

- (void)getUsers
{
    pendingEmailUsers = [DBManager getPendingEmailUsers:self.myGroup];
    // remove me
    NSString *myId = [[[Global shared] currentUser] user_id];
    for (User *u in allUsers)
    {
        if ([myId isEqualToString:u.user_id])
        {
            [allUsers removeObject:u]; break;
        }
    }
    NSMutableArray *mutableSection = [[NSMutableArray alloc] init];
    NSString *addedUsers = @" Group users";
    NSString *pendingUsers = @" Pending registered users";
    NSString *emailUsers = @" Pending unregistered users";
    NSMutableDictionary *aMutableDict = [NSMutableDictionary dictionary];
    //Shot All Users Array by Name
    NSArray *shortedUsers = [allUsers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_name" ascending:YES]]];
    allUsers = [NSMutableArray arrayWithArray:shortedUsers];
    if (allUsers.count > 0)
    {
        [aMutableDict setObject:allUsers forKey:addedUsers];
        [mutableSection addObject:addedUsers];
    }
    //Shot All Users Array by Name
  pendingUsersArr = self.myGroup.pendingUsers.allObjects;
  pendingUsersArr = [pendingUsersArr sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_name" ascending:YES]]];
    if (self.myGroup.pendingUsers.allObjects.count > 0)
    {
        [aMutableDict setObject:pendingUsersArr forKey:pendingUsers];
        [mutableSection addObject:pendingUsers];
    }
    //Shot All Users Array by Name
    NSArray *pendingEmailUsersArr = pendingEmailUsers;
    pendingEmailUsersArr = [pendingEmailUsersArr sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"emailId" ascending:YES]]];
    if (pendingEmailUsers.count > 0)
    {
        [aMutableDict setObject:pendingEmailUsersArr forKey:emailUsers];
        [mutableSection addObject:emailUsers];
    }
    _usrDict = aMutableDict;
}

- (void)inviteGroup
{
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject : self.myGroup.grId  forKey : @"group_id"];
    [param setObject : [Global shared].currentUser.user_id  forKey : @"user_id"];
    [param setObject:self.myGroup.network.netId forKey:@"network_id"];
    if (_selectedUsers.count)
    {
        NSMutableArray *users = [NSMutableArray new];
        for (User *usr in _selectedUsers)
        {
            [users addObject:usr.user_id];
        }
        if(users&&users.count)
            [param setObject:users   forKey:@"addedusers"];
    }
    if (_emails && _emails.count)
        [param setObject:_emails   forKey:@"user_emails"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client POST:InviteGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            [DBManager addInvitedUsers:_selectedUsers toGroup:self.myGroup];
            [DBManager addEmailedUsers:_emails toGroup:self.myGroup];
            [self getUsers];
            [_tableAddGroup reloadData];
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            [AppManager showAlertWithTitle:nil Body:str];
        }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
        [LoaderView removeLoader];
    }];
}

-(void)removeUserFromGroup:(UIButton *)button{
    
    NSInteger buttonIndex = button.tag;
    NSIndexPath *indexPathHighlight = [NSIndexPath indexPathForRow:0 inSection:2];
    
    GroupUsersCell *newCell = [_tableAddGroup cellForRowAtIndexPath:indexPathHighlight];
    User *deleteduser = [allUsers objectAtIndex:buttonIndex];
    [deletedUsersIDs addObject:deleteduser.user_id];
    [allUsers removeObjectAtIndex:buttonIndex];
    
    [newCell.collection reloadData];

    
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return 1;
    }
    if(section == 3){
        return pendingUsersArr.count; // rows
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section] == 0){
        static NSString *cellIdentifier = @"SelectNetworkCell";
        SelectNetworkCell *cell = (SelectNetworkCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       // Network *net = [_networks objectAtIndex:indexPath.row];
        
        cell.lbl_network.text = @"Loud-Hailer";
        cell.btnCheck.tag = indexPath.row;
        [cell.btnCheck setTitle:@"y" forState:UIControlStateNormal];
        

        return cell;
    }else if ([indexPath section] == 1){
        static NSString *cellIdentifier = @"InviteBtnCell";
        InviteBtnCell *cell = (InviteBtnCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if ([indexPath section] == 2){
        static NSString *cellIdentifier = @"GroupUsersCell";
        GroupUsersCell *cell = (GroupUsersCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.collection.delegate = self;
        cell.collection.dataSource = self;
        [cell.collection reloadData ];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *cellIdentifier = @"PendingUsersCell";
        PendingUsersCell *cell = (PendingUsersCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        User *u = nil;
        u = [pendingUsersArr objectAtIndex:indexPath.row];
        [cell displayUser:u];
        return cell;
    }
}


#pragma mark - UITableViewDelegate


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 3 || section == 2){
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width, 30*kRatio)];
        v.backgroundColor = [UIColor clearColor];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, 10,tableView.frame.size.width, 20*kRatio)];
         l.font = [l.font fontWithSize:[Common setFontSize:l.font]];
        l.textColor = [UIColor lightGrayColor];
        
        [v addSubview:l];
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20, l.frame.origin.y + l.frame.size.height+13,tableView.frame.size.width, 1)];
        [line setBackgroundColor:[Common colorwithHexString:@"ffffff" alpha:0.15f]] ;
        
        if (section == 0){
            l.text = @"Selected Network";
            
            [v addSubview:line];
        }else if (section == 2){
            l.text = @"Group Users";
        }
        else if (section == 3)
            l.text = @"Pending Registered Users";
        
        
        return v;
    }return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 3 ||section == 2 ){
        return kRatio * 40;//40
    }return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // height according to iPhone/iPad
    if ([indexPath section] == 0){
        return kRatio * 40;//40
    }else if ([indexPath section] == 1){
        return kRatio * 45;//45
    }else if ([indexPath section] == 2){
        return kRatio * 140;//150
    }else if ([indexPath section] == 3){
        return kRatio * 86;//70
    }
    return  kRatio * 95;//95
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([indexPath section] == 1){
        printf("invite");
        InviteUserViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteUserViewController"];
        vc.delegate = self;
        vc.selectedUsers = _selectedUsers;
        vc.showAllUsers = NO;
        vc.groupObj = self.myGroup;
        [self.navigationController pushViewController:vc animated:NO];

    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    if(section == 0){
        return allUsers.count; // rows
    }
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"GroupCollectionCell";
    GroupCollectionCell *cell = (GroupCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    cell.imageUser.image =  [UIImage imageNamed:placeholderGroup];
    cell.btnRemove.tag = indexPath.row;
    [cell.btnRemove addTarget:self action:@selector(removeUserFromGroup:) forControlEvents:UIControlEventTouchUpInside];
    User *u = nil;
    u = [allUsers objectAtIndex:indexPath.row];
    [cell displayUser:u];

    
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
//    if (_delegate && [_delegate respondsToSelector:@selector(didSelectIndexPath:)]) {
//        [_delegate didSelectIndexPath:indexPath];
//    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(isEnable)
        return YES;
    else
        return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == self.txt_GroupName){
        if (textField.text.length < 30 || string.length == 0){
            return YES;
        }
        else{
            return NO;
        }
    }
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex >= 2) return;
    if(IS_IPHONE)
    {
        [ImagePickManager presentImageSource:(buttonIndex == 0) forVideo:NO onController:self withCompletion:^(BOOL isSelected, UIImage *anImage, NSURL *videoURL) {
            if(isSelected)
            {
                // go for crop
                ImageCropViewController *cropperVC = [[ImageCropViewController alloc]initWithNibName:@"ImageCropViewController~iphone" bundle:nil];
                cropperVC.image = [anImage fixOrientation];
                [self presentViewController:cropperVC animated:YES completion:NULL];
                [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller) {
                    if(success)
                    {
                        _isPicSelected = YES;
                        _userImage.image = image;
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        }];
    }
    else
    {
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        } else {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *imagePicker =
                [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                          (NSString *) kUTTypeImage,
                                          nil];
                imagePicker.allowsEditing = NO;
                if(buttonIndex == 0)
                    imagePicker.sourceType =
                    UIImagePickerControllerSourceTypeCamera;
                else
                    imagePicker.sourceType =
                    UIImagePickerControllerSourceTypePhotoLibrary;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self presentViewController:imagePicker animated:YES completion:nil];
                    
                }];
            }
        }
    }
    
}

#pragma mark Image Picker Delegates

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:    (NSDictionary *)info {
    
    UIImage *anImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (anImage==nil)
    {
        anImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
    ImageCropViewController *cropperVC = [[ImageCropViewController alloc]initWithNibName:@"ImageCropViewController~ipad" bundle:nil];;
    cropperVC.image = [anImage fixOrientation];
    [self presentViewController:cropperVC animated:YES completion:NULL];
    [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller) {
        if(success)
        {
            _isPicSelected = YES;
            _userImage.image = image;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - InviteUserDelegate
- (void)didInviteUsers:(NSMutableArray *)users andEmails:(NSArray *)emails
{
    _selectedUsers = users;
    _emails = emails;
    if (users.count > 0 || emails.count > 0) {
        if(self.myGroup.isPending){
            
        }
        else{
            [self inviteGroup];
        }
    }
}

@end
