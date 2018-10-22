//
//  RelayView.m
//  LH2GO
//
//  Created by Himani Bathla on 12/07/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//


#import "RelayView.h"
#import "RelayCell.h"
#import "UITextfield+Extra.h"
#import "NSString+Extra.h"
#import "RelayObject.h"
#import "SelectNetworkCell.h"

@interface RelayView ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *_selectedUsers;
    NSMutableDictionary *_usrDict;
    NSArray *allUsersList;
    NSArray *searchUsers;
    BOOL isSearch;
    NSArray *_sections;
    RelayObject *relayObj;
    NSMutableArray *selectedBboxes;
}
@end


@implementation RelayView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RelayView" owner:self options:nil];
        UIView *vv = [objects objectAtIndex:0];
        [self addSubview:vv];
        vv.frame = self.bounds;
        DLog(@"****** arr %@ and %@",_relaysList,_relayDelegate);
        _selectedUsers = [NSMutableArray new];
     
        if ([_listOfRelays respondsToSelector:@selector(setSectionIndexColor:)]) {
            _listOfRelays.sectionIndexColor = [UIColor whiteColor]; // some color
            _listOfRelays.sectionIndexBackgroundColor = [UIColor clearColor];
            _listOfRelays.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; // some other color
            _listOfRelays.layer.borderWidth = 2.0;
            _listOfRelays.layer.borderColor = [UIColor whiteColor].CGColor;
            _listOfRelays.separatorColor = [UIColor whiteColor];
        }
        
        [self setBtnBorder:_doneClicked];
        [self setBtnBorder:_cancelClicked];
    }
    DLog(@"****** arr %@",self.relaysList);
    
    
    return self;
}
-(void)setBtnBorder:(UIButton *)btn{
    btn.layer.borderWidth = 1.0;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
}
- (id)initWithFramer:(CGRect)frame andController:(UIViewController *)obj {
    if (self = [super initWithFrame:frame]) {
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RelayView" owner:self options:nil];
        UIView *vv = [objects objectAtIndex:0];
        [self addSubview:vv];
        vv.frame = self.bounds;
        _relaysList = [[NSMutableArray alloc]init];
        DLog(@"****** arr %@ and %@",_relaysList,_relayDelegate);
        _selectedUsers = [NSMutableArray new];
        _listOfRelays.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _listOfRelays.layer.borderWidth = 2.0;
        _listOfRelays.layer.borderColor = [UIColor whiteColor].CGColor;
        _listOfRelays.separatorColor = [UIColor whiteColor];
        if ([_listOfRelays respondsToSelector:@selector(setSectionIndexColor:)]) {
            _listOfRelays.sectionIndexColor = [UIColor whiteColor]; // some color
            _listOfRelays.sectionIndexBackgroundColor = [UIColor clearColor];
            _listOfRelays.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; // some other color
            _listOfRelays.layer.borderWidth = 2.0;
            _listOfRelays.layer.borderColor = [UIColor whiteColor].CGColor;
            _listOfRelays.separatorColor = [UIColor whiteColor];
        }
    }
    DLog(@"****** arr %@",self.relaysList);
    
   // self.relayDelegate=obj;
    
    return self;
}

- (void)drawRectForView:(NSMutableArray *)yourArray{
    DLog(@"%@",yourArray);
    if (yourArray != nil) {
        _relaysList = yourArray;
        DLog(@"the relaysList is *** %@",_relaysList);
        [self reload];
    }
    
}

- (void)reload {
    selectedBboxes = nil;
    selectedBboxes = [NSMutableArray new];
    [_listOfRelays reloadData];
}

- (void)selectCell:(BOOL)selected andCell :(SelectNetworkCell *)cell{
    
    
    if (selected) {
        cell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
        [cell.btnCheck setTitle:@"y" forState:UIControlStateNormal];
        
    } else {
        
        cell.btnCheck.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
        [cell.btnCheck setTitle:@"w" forState:UIControlStateNormal];
        
    }
}

#pragma mark- IBAction

- (IBAction)doneClicked:(id)sender {
    
    DLog(@"selected rows %@",self.listOfRelays.indexPathsForSelectedRows);

    NSArray *selectedIndexPathArray = self.listOfRelays.indexPathsForSelectedRows;
    if (selectedIndexPathArray.count > 0) {
        NSMutableArray *selectedMacIdArray = [[NSMutableArray alloc] init];
        [selectedIndexPathArray enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [selectedMacIdArray addObject:[[self.relaysList objectAtIndex:obj.row] relayMacId]];
            
        }];
        
        if ([self.relayDelegate respondsToSelector:@selector(relaySelectedWithMacId:)]) {
            [self.relayDelegate relaySelectedWithMacId:selectedMacIdArray];
        }
    } else {
        [AppManager showAlertWithTitle:@"Please select a chatter box!!" Body:nil];
    }
   
    
}

- (IBAction)cancelClicked:(id)sender {

    if ([self.relayDelegate respondsToSelector:@selector(didCancelView)]) {
        [self.relayDelegate didCancelView];
    }
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    DLog(@"The relay list is %@",_relaysList);
    return _relaysList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"SelectNetworkCell";
    [_listOfRelays registerNib:[UINib nibWithNibName:@"SelectNetworkCell" bundle:nil] forCellReuseIdentifier:@"SelectNetworkCell"];
    SelectNetworkCell *cell = (SelectNetworkCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.lbl_network.text = [[_relaysList objectAtIndex:indexPath.row]relayName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *arrayOfSelectedIndexPaths = _listOfRelays.indexPathsForSelectedRows;
    if ([arrayOfSelectedIndexPaths containsObject:indexPath]) {
        [self selectCell:YES andCell:cell];
    } else {
        [self selectCell:NO andCell:cell];
    }
    
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  58;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [_sections indexOfObject:title];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    SelectNetworkCell *cell = (SelectNetworkCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    if([selectedBboxes containsObject:indexPath]){
        [selectedBboxes removeObject:indexPath];
        [self selectCell:NO andCell:cell];

    }
    else{
        [selectedBboxes addObject:indexPath];
        [self selectCell:YES andCell:cell];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
  
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _listOfRelays.userInteractionEnabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _listOfRelays.userInteractionEnabled = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)goToScheduler:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k_presentScheduler object:nil userInfo:nil];
    
    
}

@end
