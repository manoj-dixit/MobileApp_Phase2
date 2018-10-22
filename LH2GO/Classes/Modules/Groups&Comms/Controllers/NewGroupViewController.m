//
//  NewGroupViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 16/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "NewGroupViewController.h"
#import "UITextfield+Extra.h"
#import "UIView+Extra.h"
#import "UIImage+Extra.h"
#import "NSString+Extra.h"
#import "ImagePickManager.h"
#import "ImageCropViewController.h"
#import "GroupUserListView.h"
#import "LoaderView.h"
#import "AFAppDotNetAPIClient.h"

@interface NewGroupViewController () <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, GroupUserListViewDelegate>
{
    __weak IBOutlet UIView      *_contentView;
    __weak IBOutlet UITextField *_grNmFld;
    __weak IBOutlet UIImageView *_grImageV;
    __weak IBOutlet UIButton    *_selPhotoBtn;
    __weak IBOutlet UIButton    *_selNetBtn;
    __weak IBOutlet UIButton    *_inviteUserBtn;
    __weak IBOutlet UILabel     *_netNameLbl;
    __weak IBOutlet UITableView *_networksTable;
    GroupUserListView           *_userListView;
    BOOL     _isPicSelected;
    NSArray *_networks;
    Network *_selectedNet;
    NSArray *_selectedUsers;
    NSArray *_emails;
}

- (IBAction)selectPicClicked:(id)sender;
- (IBAction)selectNetClicked:(id)sender;
- (IBAction)inviteUserClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;

@end

@implementation NewGroupViewController
@synthesize popoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTabbarWithTag: BarItemTag_None];
    [self addSecondTabbarWithTag:BarItem_AddGroup];
    [self gatherNetworks];                      // gather networks.
    [self highlightBtnAtIndex:0];               // highlight.
    [_grImageV roundCorner: 7 border: 1 borderColor:kColor(146, 212, 0, 1)];
    // placeholder color
    [_grNmFld setPlaceholderColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    _grNmFld.tintColor = [UIColor whiteColor];
    [_grNmFld setMargin:12];
    // add user list..
    _userListView = [[GroupUserListView alloc] initWithFrame:CGRectMake(0, _contentView.frame.origin.y, self.view.frame.size.width,self.view.frame.size.height)];
    [self.view addSubview:_userListView];
    [_userListView getUsersAll:nil];
    _userListView.delegate = self;
    [self shouldShowUserList:NO animated:NO];   // show user list NO
    // reset network table frame
    CGRect fr = _networksTable.frame;
    fr.origin.y = _selNetBtn.frame.origin.y;
    _networksTable.frame = fr;
    if (_networkName.length)
    {
        _netNameLbl.text = _networkName;
        _selNetBtn.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods
// 0 - none, 1 - photo, 2 - net, 3 - invite
- (void)highlightBtnAtIndex:(NSInteger)indx
{
    _selPhotoBtn.selected = (indx == 1);
    _selNetBtn.selected = (indx == 2);
    _inviteUserBtn.selected = (indx == 3);
    _networksTable.hidden = YES;
    _netNameLbl.hidden = NO;
}

- (void)shouldShowUserList:(BOOL)show animated:(BOOL)animate
{
    CGRect fr = _userListView.frame;
    fr.origin.y = (show)?_contentView.frame.origin.y : self.view.frame.size.height;
    DLog(@"New group self.view height --- %f",self.view.frame.size.height);
    if (show) [_userListView reload];
    if (!animate)
    {
        _userListView.frame = fr; return;
    }
    [UIView animateWithDuration:.4 animations:^{
       _userListView.frame = fr;
    } completion:^(BOOL finished) {
    }];
}

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

- (void)addGroup
{
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    User *user = [[Global shared] currentUser];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *test = _grNmFld.text;
    DLog (@" %@ ", test);
    NSMutableArray *users = [NSMutableArray new];
    for (User *usr in _selectedUsers)
    {
        [users addObject:usr.user_id];
    }
    if(_selectedUsers.count && _selectedUsers)
    {
        [param setObject : users   forKey : @"users_list"];
    }
    else
    {
        [param setObject :[NSNull null] forKey : @"users_list"];
    }
    if (_emails && _emails.count)
    {
        [param setObject : _emails   forKey : @"user_emails"];
    }
    else
    {
        [param setObject :[NSNull null]   forKey : @"user_emails"];
    }
    [param setObject :  user.user_id forKey : @"owner_id"];
    [param setObject : _selectedNet.netId   forKey : @"network_id"];
    [param setObject: [_grNmFld.text withoutWhiteSpaceString]  forKey : @"group_name"];
    // image..
    __block NSData *imgData;
    if(_isPicSelected) imgData = UIImageJPEGRepresentation(_grImageV.image, .5);
    
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [client POST:AddGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        DLog(@"Class%@",[param class]);
        if(_isPicSelected)  [formData appendPartWithFileData:imgData name:@"group_photo" fileName:@"grpImage.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSError *errorJson=nil;
        NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers |NSJSONReadingAllowFragments error:&errorJson];
        DLog(@"responseDict=%@",response);
        NSLog(@"error=%@",errorJson);
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            User *user = [[Global shared] currentUser];
            NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:_selectedUsers.count+1];
            [users addObject:user];
            [users addObjectsFromArray:_selectedUsers];
            NSDictionary *groupD = [response objectForKey:@"groupData"];
            Group *gr = [Group addGroupWithDict:groupD forUsers:users pic:(_isPicSelected) ? _grImageV.image : nil pending:NO];
            DLog(@"*** grp id  %@", gr.grId);
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppManager showAlertWithTitle:nil Body:str];

            });
            // move to home
            [self.navigationController popToRootViewControllerAnimated:YES];
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

- (void)addGroupAndNetwork
{
    if(![AppManager isInternetShouldAlert:YES]) return;
    // add loader..
    [LoaderView addLoaderToView:self.view];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    User *user = [[Global shared] currentUser];
    [param setObject:_networkName forKey:@"network_name"];
    [param setObject : user.user_id  forKey : @"owner_id"];
    [param setObject : [_grNmFld.text withoutWhiteSpaceString]   forKey : @"group_name"];
    NSMutableArray *users = [NSMutableArray new];
    for (User *usr in _selectedUsers)
    {
        [users addObject:usr.user_id];
    }
    [param setObject : users   forKey : @"users"];
    if (_emails && _emails.count)
    {
        [param setObject : _emails   forKey : @"user_emails"];
    }
    // image..
    __block NSData *imgData;
    if(_isPicSelected) imgData = UIImageJPEGRepresentation(_grImageV.image, .5);
    
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client POST:AddNetPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(_isPicSelected)  [formData appendPartWithFileData:imgData name:@"group_photo" fileName:@"grpImage.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        DLog(@"%@", response);
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            NSDictionary *aDict = [response objectForKey:@"networkData"];
            NSArray *nets = [aDict objectForKey:@"Networks"];
            for (NSDictionary *nD in nets)
            {
                // add network.
                [Network addNetworkWithDict:nD];
                NSArray *groups = [nD objectForKey:@"Groups"];
                // traverse groups
                for (NSDictionary *gD in groups)
                {
                    NSMutableArray *userlist = [NSMutableArray new];
                    NSArray *users = [gD objectForKey:@"Users"];
                    // traverse users
                    for (NSDictionary *uD in users)
                    {
                        User *aUser = [User addUserWithDict:uD pic:nil];
                        if (aUser) [userlist addObject:aUser];
                    }
                    [userlist addObject:[[Global shared] currentUser]];
                    // add group.
                    Group *group = [Group addGroupWithDict:gD forUsers:userlist pic:nil pending:NO];
                    [DBManager addInvitedUsers:_selectedUsers toGroup:group];
                    [DBManager addEmailedUsers:_emails toGroup:group];
                }
            }
            // move to home
            [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - IBAction

- (IBAction)selectPicClicked:(id)sender
{
    [_grNmFld resignFirstResponder];
    [self highlightBtnAtIndex:1];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view];
}

- (IBAction)selectNetClicked:(id)sender
{
    [_grNmFld resignFirstResponder];
    [self highlightBtnAtIndex:2];
    _networksTable.hidden = NO;
    _netNameLbl.hidden = YES;
}

- (IBAction)inviteUserClicked:(id)sender
{
    [_userListView getUsersAll:_selectedNet];
    [_grNmFld resignFirstResponder];
    [self highlightBtnAtIndex:3];
    [self shouldShowUserList:YES animated:YES];
}

- (IBAction)doneClicked:(id)sender
{
    [_grNmFld resignFirstResponder];
    NSString *alertTxt;
    if ([_grNmFld.text withoutWhiteSpaceString].length < 3 || [_grNmFld.text withoutWhiteSpaceString].length > 30)
    {
        alertTxt = @"Group name should be between 3 to 30 characters.";
    }
    else if (!_selectedNet && _networkName.length == 0)
    {
        alertTxt = @"Please choose a network";
    }
    if (alertTxt.length)
    {
        [AppManager showAlertWithTitle:nil Body:alertTxt]; return;
    }
    if (_networkName.length)
    {
        // add network/group.
        [self addGroupAndNetwork];
    }
    else
    {
        // add group
        [self addGroup];
    }
}

#pragma mark - Touch Action

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_grNmFld resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self highlightBtnAtIndex:0];
    if(buttonIndex >= 2) return;
    if(IS_IPHONE)
    {
    [ImagePickManager presentImageSource:(buttonIndex == 0) forVideo:NO onController:self withCompletion:^(BOOL isSelected, UIImage *anImage, NSURL *videoURL) {
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
                _grImageV.image = image;
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _networks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NetworkCellidentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *netNameLabel = (UILabel *)[cell viewWithTag:101];
    netNameLabel.text = [[_networks objectAtIndex:indexPath.row] netName];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self highlightBtnAtIndex:0];
    _selectedNet = [_networks objectAtIndex:indexPath.row];
    _netNameLbl.text = _selectedNet.netName;
}

#pragma mark - GroupUserListViewDelegate

- (void)didCancel
{
    [self highlightBtnAtIndex:0];
    [self shouldShowUserList:NO animated:YES];
}

- (void)didInviteUsers:(NSArray *)users andEmails:(NSArray *)emails
{
    _selectedUsers = users;
    _emails = emails;
    [self highlightBtnAtIndex:0];
    [self shouldShowUserList:NO animated:YES];
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
            _grImageV.image = image;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
