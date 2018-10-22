//
//  AddGroupViewController.m
//  LH2GO
//
//  Created by Linchpin on 27/06/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "AddGroupViewController.h"
#import "UIView+Extra.h"
#import "UITextfield+Extra.h"
#import "UIImage+Extra.h"
#import "ImagePickManager.h"
#import "ImageCropViewController.h"
#import "AFAppDotNetAPIClient.h"
#import "LoaderView.h"
#import "SERVICES.h"
#import "NSString+Extra.h"
#import "SelectNetworkCell.h"


@interface AddGroupViewController ()<UIActionSheetDelegate,InviteUserListViewDelegate>
{
    NSArray *_networks;
    BOOL     _isPicSelected;
    UIBarButtonItem  *lefttButton;
    UIBarButtonItem  *rightButton;
    BOOL _isEntered;
    NSMutableArray *_selectedUsers;
    NSArray *_emails;
    NSMutableArray *selectedNetwork;
    NSMutableArray *originalGroupArr;
    NSMutableArray *dataSource;
    NSInteger countOfGroups;

}

@end

@implementation AddGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedNetwork = [NSMutableArray new];
    _txt_GroupName.autocorrectionType = UITextAutocorrectionTypeNo;
    [self registerNib];
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width *kRatio/2;
    self.userImage.contentMode = UIViewContentModeScaleAspectFill;
    self.btnAddImage.layer.cornerRadius = self.btnAddImage.frame.size.width *kRatio/2;
    self.btnAddImage.layer.masksToBounds = YES;
    self.userImage.layer.masksToBounds = YES;
    [self addTopBarButtons];
    originalGroupArr = nil;
    originalGroupArr = [[NSMutableArray alloc]init];
    dataSource = nil;
    dataSource = [[NSMutableArray alloc]init];
    [self.txt_GroupName setPlaceholderColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    [self gatherNetworks];
    _isEntered = 0;
    _selectedUsers = [NSMutableArray new];
    [_selectedUsers removeAllObjects];
    UITapGestureRecognizer *gestureRecognizer = nil;
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    // Do any additional setup after loading the view.
    
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

//-(CGRect)adjustRoundShapeFrame:(CGRect)frame{
//    frame.size.height = frame.size.height *kRatio;
//    frame.size.width = frame.size.width *kRatio;
//    return frame;
//}

- (void)setNavBarTitle {
    
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text = @"Add Group";
    titleLabel.textColor=[UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

- (void)addTopBarButtons
{

    lefttButton = nil;
    lefttButton = [[UIBarButtonItem alloc]
                  initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    rightButton = nil;
    rightButton = [[UIBarButtonItem alloc]
                    initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveChanges)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = lefttButton;
    
}

#pragma mark -  Private Methods
-(void)saveChanges{
    [_txt_GroupName resignFirstResponder];
    NSString *activeNetId = [PrefManager activeNetId];
    User *user = [[Global shared] currentUser];
    
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
    dataSource = nets;
    if (dataSource.count) {
        NSDictionary *d = [dataSource objectAtIndex:0];
        originalGroupArr = [d objectForKey:@"groups"];
        
    }
    else
        dataSource = [[NSMutableArray alloc] init];
    
        countOfGroups = 0;

    
    for(Group *gr in originalGroupArr){
        if([gr.owner.user_id isEqualToString:[Global shared].currentUser.user_id]){
            countOfGroups++;
        }
    }
//    if(countOfGroups == 5){
//        [AppManager showAlertWithTitle:@"Alert" Body:@"You have reached the maximum limit of creating groups."];
//        return;
//    }
    

    if(![AppManager isInternetShouldAlertwithOutMessage:YES]) {
        
        [Global shared].isReadyToStartBLE = YES;
       
               NSString *alertTxt;
        if ([_txt_GroupName.text withoutWhiteSpaceString].length < 3 || [_txt_GroupName.text withoutWhiteSpaceString].length > 30)
        {
            alertTxt = @"Group name should be between 3 to 30 characters.";
        }
        if (alertTxt.length)
        {
            [AppManager showAlertWithTitle:nil Body:alertTxt]; return;
        }

        NSMutableArray *users = nil;
        users = [[NSMutableArray alloc] initWithCapacity:_selectedUsers.count+1];
        [users addObject:user];
        [users addObjectsFromArray:_selectedUsers];
        
        NSString *groupid = [self genRandStringLength:4];
        
        NSData *imageData =  UIImageJPEGRepresentation(_userImage.image, .5);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.png",@"cached",groupid]];
        
        DLog(@"pre writing to file");
        if (![imageData writeToFile:imagePath atomically:NO])
        {
            NSLog(@"Failed to cache image data to disk");
        }
        else
        {
            DLog(@"the cachedImagedPath is %@",imagePath);
        }
        
        NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:_txt_GroupName.text,@"group_name",imagePath,@"group_photo",groupid,@"id",activeNetId,@"network_id",user.user_id,@"owner_id",nil];
        
        Group *gr = [Group addGroupWithDict:postDictionary forUsers:users pic:_userImage.image pending:YES];
        
        NSString *str = [NSString stringWithFormat:@"%@", @"Your group creation is pending. Please connect to Internet to complete!"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AppManager showAlertWithTitle:@"Alert" Body:str];
        });
        // move to home
        [self.navigationController popViewControllerAnimated:YES];
        // fire notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupList object:nil userInfo:nil];
    }
    else{
    if(!_isEntered){
        NSString *str = [NSString stringWithFormat:@"Please select a network"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppManager showAlertWithTitle:@"Alert" Body:str];
            
        });
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
    
   
    NSMutableDictionary *param = nil;
    param = [[NSMutableDictionary alloc] init];
    NSString *test = _txt_GroupName.text;
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
    [param setObject : activeNetId   forKey : @"network_id"];
    [param setObject: [_txt_GroupName.text withoutWhiteSpaceString]  forKey : @"group_name"];
    // image..
    __block NSData *imgData;
    if(_isPicSelected) imgData = UIImageJPEGRepresentation(_userImage.image, .5);
    
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [client POST:AddGroupPath parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(_isPicSelected)  [formData appendPartWithFileData:imgData name:@"group_photo" fileName:@"grpImage.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LoaderView removeLoader];
        NSError *errorJson=nil;
        NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers |NSJSONReadingAllowFragments error:&errorJson];
//        NSLog(@"responseDict=%@",response);
        
        if(response != NULL)
        {
        BOOL status = [[response objectForKey:@"status"] isEqualToString:@"Success"];
        if(status)
        {
            User *user = [[Global shared] currentUser];
            NSMutableArray *users = nil;
            users = [[NSMutableArray alloc] initWithCapacity:_selectedUsers.count+1];
            [users addObject:user];
            [users addObjectsFromArray:_selectedUsers];
            NSDictionary *groupD = [response objectForKey:@"groupData"];
            Group *gr = [Group addGroupWithDict:groupD forUsers:users pic:(_isPicSelected) ? _userImage.image : nil pending:NO];
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
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
    }];
    }
}




-(void)goBack{
    [self.navigationController popViewControllerAnimated:true];
}




#pragma IB Action Methods


- (IBAction)addGroupPicture:(id)sender {
    [_txt_GroupName resignFirstResponder];
    UIActionSheet *sheet = nil;
    sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view];
    
}

-(void)registerNib
{
    [self.tableAddGroup registerNib:[UINib nibWithNibName:@"SelectNetworkCell" bundle:nil] forCellReuseIdentifier:@"SelectNetworkCell"];
    [self.tableAddGroup registerNib:[UINib nibWithNibName:@"InviteBtnCell" bundle:nil] forCellReuseIdentifier:@"InviteBtnCell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethods

// Generates alpha-numeric-random string
- (NSString *)genRandStringLength:(int)len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}



-(void)hideKeyboard
{
    [_txt_GroupName resignFirstResponder];
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

- (void)SelectButtonTapped:(UIButton *)button
{
    NSInteger buttonIndex = button.tag;
    
    for (int row = 0; row<1; row++)
    {
        NSIndexPath *indexPathHighlight = [NSIndexPath indexPathForRow:row inSection:0];
        
        SelectNetworkCell *newCell = [_tableAddGroup cellForRowAtIndexPath:indexPathHighlight];
        
        if (row == buttonIndex && !_isEntered)
        {
            [newCell setSelected:YES animated:YES];
            newCell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
            [newCell.btnCheck setTitle:@"y" forState:UIControlStateNormal];
            _isEntered = 1;


        }
        else
        {
            [newCell setSelected:NO animated:YES];
            newCell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
            [newCell.btnCheck setTitle:@"w" forState:UIControlStateNormal];
            _isEntered = 0;

        }
    }
}

- (void)selectCell:(BOOL)selected andCell :(SelectNetworkCell *)cell{
    
    
    if (selected) {
        _isEntered = 1;
        cell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
        [cell.btnCheck setTitle:@"y" forState:UIControlStateNormal];
        
    } else {
        _isEntered = 0;
        cell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
        [cell.btnCheck setTitle:@"w" forState:UIControlStateNormal];
        
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return 1; // rows
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
        _isEntered = 1;
        
         return cell;
    }else if ([indexPath section] == 1){
        static NSString *cellIdentifier = @"InviteBtnCell";
        InviteBtnCell *cell = (InviteBtnCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 ){
        UIView *v = nil;
        v = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width, 30*kRatio)];
        v.backgroundColor = [UIColor clearColor];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, 10,tableView.frame.size.width, 20*kRatio)];
        l.textColor = [UIColor lightGrayColor];
         l.font = [l.font fontWithSize:[Common setFontSize:l.font]];
        if (section == 0)
            l.text = @"Select Network";
        [v addSubview:l];
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20, l.frame.origin.y + l.frame.size.height+13,tableView.frame.size.width, 1)];
        [line setBackgroundColor:[Common colorwithHexString:@"ffffff" alpha:0.15f]] ;
        [v addSubview:line];
        return v;
    }return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return kRatio * 40;//40;
    }return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0){
        return kRatio * 40;//40
    }
    return  kRatio * 45;//45
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
//        SelectNetworkCell *cell = (SelectNetworkCell *) [tableView cellForRowAtIndexPath:indexPath];
//        if([selectedNetwork containsObject:indexPath]){
//            [selectedNetwork removeObject:indexPath];
//            [self selectCell:NO andCell:cell];
//            
//        }
//        else{
//            [selectedNetwork addObject:indexPath];
//            [self selectCell:YES andCell:cell];
//        }
        
    }

       if ([indexPath section] == 1){
        printf("invite");
        InviteUserViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteUserViewController"];
        vc.delegate = self;
        vc.selectedUsers = _selectedUsers;
        vc.showAllUsers = YES;
        [self.navigationController pushViewController:vc animated:NO];
        
    }
}


#pragma mark - Touch Action

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_txt_GroupName resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

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
                 [self presentViewController:cropperVC animated:YES completion:NULL];;
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
}

-(void)setMyChannel:(NSDictionary *)dic
{
    
    ChanelViewController *channelVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ChanelViewController class])];
    
    NSString *channelName = [[[dic objectForKey:@"Data"] componentsSeparatedByString:@":"] objectAtIndex:1];
    
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

// by nim
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict
{
    [self.navigationController.navigationBar setHidden:false];
    
    if (isForChannel)
    {
        //push to channel view controller
        [self setMyChannel:dataDict];
        return;
    }    
    // check owner
    Group *gr = sht.group;
    CommsViewController *gvc = nil;
    ReplyViewController *rvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[ReplyViewController class]])//crash fix , please dont remove this code
    {
        //        ReplyViewController *rv = (ReplyViewController *)self.navigationController.topViewController;
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


@end
