//
//  LHManegGroupViewController.m
//  LH2GO
//
//  Created by Sumit Kumar on 05/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHManegGroupViewController.h"
#import "UserCell.h"
#import "UIView+Extra.h"
#import "UITextfield+Extra.h"
#import "UIImage+Extra.h"
#import "NSString+Extra.h"
#import "LoaderView.h"
#import "AFAppDotNetAPIClient.h"
#import "GroupUserListView.h"
#import "UIImage+Extra.h"
#import "ImageCropViewController.h"
#import "ImagePickManager.h"
#import "EmailedUser.h"

@interface LHManegGroupViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UserCellDelegate, GroupUserListViewDelegate, UIActionSheetDelegate>
{
    __weak IBOutlet UITableView *_table;
    __weak IBOutlet UITextField *_lblName;
    __weak IBOutlet UIImageView *_usrImageV;
    __weak IBOutlet UIButton *_btnInviteUser;
    __weak IBOutlet UIButton *_btnChangeImage;
    BOOL _isPicSelected;
    NSMutableDictionary *_usrDict;
    NSArray *_sections;
    NSMutableArray *allUsers;
    NSMutableArray *deletedUsersIDs;
    NSMutableArray *newUserIds;
    NSArray *_selectedUsers;
    NSArray *_emails;
    GroupUserListView      *_userListView;
    NSMutableArray *secsCustom;
    NSArray *pendingEmailUsers;
}

@end

@implementation LHManegGroupViewController
@synthesize popoverController;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustFloatingSectionHeaderInTable:_table];
    [self initUI];
   // [self addTabbarWithTag: BarItemTag_Groups];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark other methods

- (void)initUI
{
    [_usrImageV roundCorner: 5 border: 1 borderColor:kColor(243, 112, 73, 1)];
    [_btnInviteUser roundCorner:4 border: 1 borderColor:kColor(146, 212, 0, 1)];
    [_lblName setMargin:12];
    _lblName.text = _myGroup.grName;
    [_usrImageV sd_setImageWithURL:[NSURL URLWithString:self.myGroup.picUrl]
                  placeholderImage:[UIImage imageNamed:@"icon_add_photo"]];
    if ([_table respondsToSelector:@selector(setSectionIndexColor:)])
    {
        _table.sectionIndexColor = [UIColor whiteColor]; // some color
        _table.sectionIndexBackgroundColor = [UIColor clearColor];
        _table.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; // some other color
    }
    deletedUsersIDs = [[NSMutableArray alloc] init];
    newUserIds = [[NSMutableArray alloc] init];
    allUsers = [[NSMutableArray alloc] initWithArray:self.myGroup.users.allObjects];
    [self getUsers];
    [self addUserList];
    if (self.isNonAdmin)
    {
        _btnChangeImage.userInteractionEnabled = NO;
        _lblName.userInteractionEnabled = NO;
        [_btnChangeImage setTitle:@"" forState:UIControlStateNormal];
        [_usrImageV roundCorner: 5 border: 1 borderColor:kColor(146, 212, 0, 1)];
    }
}

- (void)addUserList
{
    // add user list..
    _userListView = [[GroupUserListView alloc] initWithFrame:CGRectMake(0, _lblName.frame.origin.y+_lblName.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(_lblName.frame.origin.y+_lblName.frame.size.height))];
    [self.view addSubview:_userListView];
    _userListView.delegate = self;
    [self shouldShowUserList:NO animated:NO];   // show user list NO
}

- (void)shouldShowUserList:(BOOL)show animated:(BOOL)animate
{
    CGRect fr = _userListView.frame;
    fr.origin.y = (show)?_lblName.frame.origin.y+20 : self.view.frame.size.height;
    if (show)
    {
        [_userListView getUsersNotInGroup:self.myGroup];
        [_userListView reload];
    }
    if (!animate)
    {
        _userListView.frame = fr; return;
    }
    [UIView animateWithDuration:.4 animations:^{
        _userListView.frame = fr;
    } completion:^(BOOL finished) {
    }];
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
    NSArray *pendingUsersArr = self.myGroup.pendingUsers.allObjects;
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
    _sections = mutableSection;
}

- (void)reload
{
    [_table reloadData];
}

- (BOOL)verifyEmails:(NSArray *)emails
{
    NSMutableArray *list = [NSMutableArray new];
    NSMutableString *alrtstr = [NSMutableString new];
    for (NSString *email in emails)
    {
        if ([email isValidForEmail])
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

#pragma mark - IBAction

- (IBAction)photoClicked:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view];
}

- (IBAction)doneClicked:(id)sender
{
    [self editGroup];
}

- (IBAction)cancelClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)inviteMoreUsersClicked:(id)sender
{
    [self shouldShowUserList:YES animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_sections count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self getHeaderViewFortableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *sectionUsers = [self getContentAtSection:section];
    return [sectionUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UserCellIdentifier";
    UserCell *cell = (UserCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [UserCell cellWithGesture:!self.isNonAdmin];
        cell.delegate = self;
    }
    NSArray *sectionUsers = [self getContentAtSection:indexPath.section];
    if (sectionUsers.count>indexPath.row&&[[sectionUsers objectAtIndex:indexPath.row] isKindOfClass:[User class]])
    {
        User *u = [sectionUsers objectAtIndex:indexPath.row];
        [cell displayUser:u];
    }
    else if (sectionUsers.count>indexPath.row)
    {
        EmailedUser *emailUser = [sectionUsers objectAtIndex:indexPath.row];
        [cell displayEmail:emailUser.emailId];
    }
     cell.userInteractionEnabled=YES;
    if (indexPath.section>0)
    {
        cell.userInteractionEnabled=NO;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    return  height;
}

//Sonal commneted as on ipad it was showing s as title index
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return [self getCustomIndexTitles];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return [secsCustom indexOfObject:title];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_lblName resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _table.userInteractionEnabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _table.userInteractionEnabled = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UserCellDelegate 

- (void)deleteUser:(User*)user withTableCell:(UserCell *)cell
{
    //Implement the webserve...
    //Add deleted user ids in array
    NSString *user_id = [[NSString alloc] initWithString:user.user_id];
    [deletedUsersIDs addObject:user_id];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = cell.frame;
        rect.origin.x=-rect.size.width;
        cell.frame=rect;
    } completion:^(BOOL finished) {
        [allUsers removeObject:user];
        [self getUsers];
        [self reload];
    }];
}

- (NSString*)getCombinedDeletedUserIds
{
    NSString *result = nil;
    int i=0;
    for(NSString *uid in deletedUsersIDs)
    {
        if (i==0)
            result = uid;
        else
            result = [NSString stringWithFormat:@"%@,%@", result, uid];
        i++;
    }
    return result;
}

- (void)editGroup
{
    if (!_isPicSelected && [_lblName.text isEqualToString: self.myGroup.grName]&&!deletedUsersIDs.count&&!_selectedUsers.count&&!_emails.count)
    {
        [AppManager showAlertWithTitle:nil Body:@"No change."];
        return;
    }
    if (_lblName.text.length<3)
    {
        [AppManager showAlertWithTitle:nil Body:@"Group name should be between 3 to 30 characters."];
        return;
    }
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
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
    [param setObject:_lblName.text   forKey:@"group_name"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // image..
    __block NSData *imgData;
    if(_isPicSelected) imgData = UIImageJPEGRepresentation(_usrImageV.image, .5);
    [client POST:EditGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         if(_isPicSelected)  [formData appendPartWithFileData:imgData name:@"group_photo" fileName:@"myimage.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"%@", response);
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            NSDictionary *userData = [response objectForKey:@"groupData"];
            self.myGroup.grName = _lblName.text;
            if (_isPicSelected)
            {
                self.myGroup.picUrl = [AppManager sutableStrWithStr:[userData objectForKey:@"group_photo"]];
                [[SDImageCache sharedImageCache] storeImage:_usrImageV.image forKey:self.myGroup.picUrl];
            }
            [DBManager deleteUsers:deletedUsersIDs fromGroup:self.myGroup];
            [DBManager addInvitedUsers:_selectedUsers toGroup:self.myGroup];
            [DBManager addEmailedUsers:_emails toGroup:self.myGroup];
            _selectedUsers = nil;
            [deletedUsersIDs removeAllObjects];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            [AppManager showAlertWithTitle:nil Body:str];
        }
    }
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
        [LoaderView removeLoader];
    }];
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
            _selectedUsers = nil;
            [self getUsers];
            [_table reloadData];
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

//Block User API
- (void)blockUser:(NSString*)blockUserID ByUser:(NSString*)userId forGroup:(NSString*)groupID
{
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject : self.myGroup.grId  forKey : @"group_id"];
    [param setObject : self.myGroup.owner.user_id  forKey : @"user_id"];
    [param setObject : self.myGroup.grId  forKey : @"blocked_user_id"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client POST:EditGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != NULL)
        {
        NSLog(@"%@", response);
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status){}
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

#pragma mark - GroupUserListViewDelegate

- (void)didCancel
{
    [self shouldShowUserList:NO animated:YES];
}

- (void)didInviteUsers:(NSArray *)users andEmails:(NSArray *)emails
{
    _selectedUsers = users;
    _emails = emails;
    [self shouldShowUserList:NO animated:YES];
    if (users.count > 0 || emails.count > 0) [self inviteGroup];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex >= 2) return;
    if(IS_IPHONE)
    {
    [ImagePickManager presentImageSource:(buttonIndex == 0) forVideo:NO onController:self withCompletion:^(BOOL isSelected, UIImage *anImage, NSURL *videoURL)
     {
        if(isSelected)
        {
            // go for crop
            ImageCropViewController *cropperVC = [[ImageCropViewController alloc]initWithNibName:@"ImageCropViewController~iphone" bundle:nil];
            cropperVC.image = [anImage fixOrientation];
            [self.navigationController pushViewController:cropperVC animated:YES];
            [cropperVC setCompletionBlock:^(BOOL success, UIImage *image, UIViewController *controller) {
                if(success)
                {
                    _isPicSelected = YES;
                    _usrImageV.image = image;
                }
                [self.navigationController popViewControllerAnimated:YES];
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
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum ])
            {
                UIImagePickerController *imagePicker = nil;
                imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeImage,nil];
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

//get
-(NSArray *)getContentAtSection:(NSInteger )section
{
    @autoreleasepool
    {
        NSString *sectionTitle = [_sections objectAtIndex:section];
        NSArray *sectionUsers = [_usrDict objectForKey:sectionTitle];
        return sectionUsers;
    }
}

-(UIView *)getHeaderViewFortableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    @autoreleasepool
    {
        CGFloat paddingFromRight = 25;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, tableView.frame.size.width-paddingFromRight, 28.0f)];
        /* Create custom view to display section header... */
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, tableView.frame.size.width-paddingFromRight, 24.0f)];
        [label setBackgroundColor:kColor(146, 196, 74, 1.0)];
        [label setFont:[UIFont fontWithName:@"Aileron-Regular" size:10]];
        [label setTextColor:[UIColor blackColor]];
        NSString *string =[_sections objectAtIndex:section];
        [label setText:string];
        [view addSubview:label];
        [view setBackgroundColor:[UIColor clearColor]];
        return view;
    }
}

-(void)adjustFloatingSectionHeaderInTable:(UITableView *)table
{
    CGFloat dummyViewHeight = 48;
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _table.bounds.size.width, dummyViewHeight)];
    _table.tableHeaderView = dummyView;
    _table.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
}

-(NSMutableArray *)getCustomIndexTitles
{
    NSString *str = @"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z";
    NSArray *alphas = [str componentsSeparatedByString:@" "];
    // remove me
    NSString *myId = [[[Global shared] currentUser] user_id];
    for (User *u in allUsers)
    {
        @autoreleasepool
        {
            if ([myId isEqualToString:u.user_id])
            {
                [allUsers removeObject:u]; break;
            }
        }
    }
    // create sections
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSMutableArray *secs = [NSMutableArray new];
    //arrays
    NSArray *pendingUsers = self.myGroup.pendingUsers.allObjects;
    NSArray *emailedUsers = pendingEmailUsers;//have object of type emailedUser with attribute emailId
    NSMutableArray *allUserArray = [NSMutableArray array];
    [allUserArray addObjectsFromArray:allUsers];//both allUsers and pendingUsers have object of type user which have attribute user_name
    [allUserArray addObjectsFromArray:pendingUsers];
    //user_name and emailid different attribute of different classes, so i have to implement code this way
    for (NSString *str in alphas)
    {
        @autoreleasepool
        {
            NSString *pstr = [NSString stringWithFormat:@"user_name beginswith[c] '%@'", [str lowercaseString]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:pstr];
            NSArray *usrs = [allUserArray filteredArrayUsingPredicate:predicate];
            if (usrs.count)
            {
                [secs addObject:str];
                [secs addObject:@""];
                [dict setObject:usrs forKey:str];
            }
        }
    }
    for (NSString *str in alphas)
    {
        @autoreleasepool
        {
            NSString *pstr = [NSString stringWithFormat:@"emailId beginswith[c] '%@'", [str lowercaseString]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:pstr];
            NSArray *usrs = [emailedUsers filteredArrayUsingPredicate:predicate];
            if (usrs.count)
            {
                [secs addObject:str];
                [secs addObject:@""];
                [dict setObject:usrs forKey:str];
            }
        }
    }
    secsCustom = secs;
    return secs;
}

#pragma mark Image Picker Delegates

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:    (NSDictionary *)info {
    
    UIImage *anImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (anImage==nil) {
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
            _usrImageV.image = image;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
