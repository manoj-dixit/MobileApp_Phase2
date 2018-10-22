//
//  GroupUserListView.m
//  LH2GO
//
//  Created by Prakash Raj on 17/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "GroupUserListView.h"
#import "UserCell.h"
#import "UITextfield+Extra.h"
#import "NSString+Extra.h"

@interface GroupUserListView () <UITextFieldDelegate>
{
    __weak IBOutlet UITableView *_table;
    __weak IBOutlet UITextField *_emailFld;
    NSMutableArray *_selectedUsers;
    NSMutableDictionary *_usrDict;
    NSArray *allUsersList;
    NSArray *searchUsers;
    BOOL isSearch;
    NSArray *_sections;
}

- (IBAction)inviteClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
@end


@implementation GroupUserListView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GroupUserListView" owner:self options:nil];
        UIView *vv = [objects objectAtIndex:0];
        [self addSubview:vv];
        vv.frame = self.bounds;
        _selectedUsers = [NSMutableArray new];
        if ([_table respondsToSelector:@selector(setSectionIndexColor:)])
        {
            _table.sectionIndexColor = [UIColor whiteColor]; // some color
            _table.sectionIndexBackgroundColor = [UIColor clearColor];
            _table.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; // some other color
        }
        // placeholder color
        UIColor *pClr = kColor(255, 255, 255, 0.5);
        [_emailFld setPlaceholderColor:pClr];
        _emailFld.tintColor = [UIColor whiteColor];
        [_emailFld setMargin:12];
        [self SearchingEnabled];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_emailFld endEditing:YES];
}

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

- (void)reload
{
    [_table reloadData];
}

#pragma mark - Private methods
- (NSArray *)usersEmails
{
    if (!_emailFld.text.length)
    {
        // no emails
        return nil;
    }
    NSArray *arr = [_emailFld.text componentsSeparatedByString:@","];
    return arr;
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

#pragma mark - IBAction

- (IBAction)inviteClicked:(id)sender
{
    [_emailFld resignFirstResponder];
    NSArray *emails = [self usersEmails];
    if (emails && [emails count])
    {
       BOOL varified = [self verifyEmails:emails];
        if (!varified) return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didInviteUsers: andEmails:)])
        [_delegate didInviteUsers:_selectedUsers andEmails:emails];
}

- (IBAction)cancelClicked:(id)sender
{
    isSearch = NO;
    _emailFld.text = @"";
    [_emailFld resignFirstResponder];
    [_selectedUsers removeAllObjects];
    if (_delegate && [_delegate respondsToSelector:@selector(didCancel)])
        [_delegate didCancel];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSInteger cnt = _usrDict.allKeys.count;
    if (isSearch) {
        return 1;
    }
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearch)
    {
        return searchUsers.count;
    }
  NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:k_userShow];
    if(value)
    {
        NSArray *arr = [_usrDict objectForKey:[_sections objectAtIndex:section]];
        return arr.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UserCellIdentifier";
    UserCell *cell = (UserCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [UserCell cellWithGesture:NO];
    }
    User *u = nil;
    if (!isSearch)
    {
        NSArray *arr = [_usrDict objectForKey:[_sections objectAtIndex:indexPath.section]];
        u = [arr objectAtIndex:indexPath.row];
        [cell selectMe:[_selectedUsers containsObject:u]];
    }
    else
    {
        u = [searchUsers objectAtIndex:indexPath.row];
        [cell selectMe:[_selectedUsers containsObject:u]];
    }
    [cell displayUser:u];
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  44;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _sections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [_sections indexOfObject:title];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearch)
    {
        NSArray *arr = searchUsers;
        User *u = [arr objectAtIndex:indexPath.row];
        if ([_selectedUsers containsObject:u])
        {
            [_selectedUsers removeObject:u];
        }
        else
        {
            [_selectedUsers addObject:u];
        }
        UserCell *cell = (UserCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell selectMe:[_selectedUsers containsObject:u]];
    }
    else
    {
        NSArray *arr = [_usrDict objectForKey:[_sections objectAtIndex:indexPath.section]];
        User *u = [arr objectAtIndex:indexPath.row];
        if ([_selectedUsers containsObject:u])
        {
            [_selectedUsers removeObject:u];
        }
        else
        {
            [_selectedUsers addObject:u];
        }
        UserCell *cell = (UserCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell selectMe:[_selectedUsers containsObject:u]];
    }
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

//Search Functionality
-(void)SearchingEnabled
{
    [_emailFld addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void)textFieldDidChange:(UITextField *)txtFld
{
    NSPredicate *sPredicate;
    if ([txtFld.text isEqualToString:@""])
    {
        isSearch=NO;
        [_table reloadData];
    }
    else
    {
        isSearch = YES;
        NSString * match = txtFld.text;
        sPredicate = [NSPredicate predicateWithFormat:@"SELF.email LIKE[cd] %@", match];
        searchUsers = [allUsersList filteredArrayUsingPredicate:sPredicate];
        [_table reloadData];
    }
}

@end
