//
//  CustomDropDownView.m
//  LH2GO
//
//  Created by VVDN on 01/11/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "CustomDropDownView.h"

@implementation CustomDropDownView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CustomDropDownView" owner:self options:nil];
        UIView *vv = [objects objectAtIndex:0];
        [self addSubview:vv];
        vv.frame = self.bounds;
        /*
        NSLog(@"****** arr %@ and %@",_relaysList,_relayDelegate);
        _selectedUsers = [NSMutableArray new];
        
        if ([_listOfRelays respondsToSelector:@selector(setSectionIndexColor:)]) {
            _listOfRelays.sectionIndexColor = [UIColor whiteColor]; // some color
            _listOfRelays.sectionIndexBackgroundColor = [UIColor clearColor];
            _listOfRelays.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; // some other color
            _listOfRelays.layer.borderWidth = 2.0;
            _listOfRelays.layer.borderColor = [UIColor whiteColor].CGColor;
            _listOfRelays.separatorColor = [UIColor whiteColor];
        }
        
 
    }
    NSLog(@"****** arr %@",self.relaysList);
         */
        
    
}
    return self;
}
//- (id)initWithFramer:(CGRect)frame andController:(UIViewController *)obj {
//    if (self = [super initWithFrame:frame]) {
//        
//        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RelayView" owner:self options:nil];
//        UIView *vv = [objects objectAtIndex:0];
//        [self addSubview:vv];
//        vv.frame = self.bounds;
//        _relaysList = [[NSMutableArray alloc]init];
//        NSLog(@"****** arr %@ and %@",_relaysList,_relayDelegate);
//        _selectedUsers = [NSMutableArray new];
//        _listOfRelays.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
//        _listOfRelays.layer.borderWidth = 2.0;
//        _listOfRelays.layer.borderColor = [UIColor whiteColor].CGColor;
//        _listOfRelays.separatorColor = [UIColor whiteColor];
//        if ([_listOfRelays respondsToSelector:@selector(setSectionIndexColor:)]) {
//            _listOfRelays.sectionIndexColor = [UIColor whiteColor]; // some color
//            _listOfRelays.sectionIndexBackgroundColor = [UIColor clearColor];
//            _listOfRelays.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; // some other color
//            _listOfRelays.layer.borderWidth = 2.0;
//            _listOfRelays.layer.borderColor = [UIColor whiteColor].CGColor;
//            _listOfRelays.separatorColor = [UIColor whiteColor];
//        }
//    }
//    NSLog(@"****** arr %@",self.relaysList);
//    
//    // self.relayDelegate=obj;
//    
//    return self;
//}
//
//- (void)drawRectForView:(NSMutableArray *)yourArray{
//    NSLog(@"%@",yourArray);
//    if (yourArray != nil) {
//        _relaysList = yourArray;
//        NSLog(@"the relaysList is *** %@",_relaysList);
//        [self reload];
//    }
//    
//}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//NSLog(@"The relay list is %@",_relaysList);
//return  _relaysList.count;
    return  _optionList.count; //5;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cellIdentifier = @"CustomDropDown_Cell";
    //register cell xib
    [_tblOptions registerNib:[UINib nibWithNibName:@"CustomDropDown_Cell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    CustomDropDown_Cell *cell = (CustomDropDown_Cell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.lblOption.text = _optionList[indexPath.row];// @"Option 1" ;// [[_relaysList objectAtIndex:indexPath.row]relayName];
    
//    NSArray *arrayOfSelectedIndexPaths = _tblOptions.indexPathForSelectedRow;
//    if ([arrayOfSelectedIndexPaths containsObject:indexPath]) {
//        [self selectCell:YES andCell:cell];
//    } else {
//        [self selectCell:NO andCell:cell];
//    }
    
    cell.btnOption.userInteractionEnabled = NO;
    if (_tblOptions.indexPathForSelectedRow == indexPath ){
        [self selectCell:YES andCell:cell];
    } else {
        [self selectCell:NO andCell:cell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return  58;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  35*kRatio;
}


//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return _sections;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    return [_sections indexOfObject:title];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[AppManager showAlertWithTitle:@"" Body:@"Coming Soon"];
    CustomDropDown_Cell *cell = (CustomDropDown_Cell *) [tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.btnOption.currentTitle isEqual:@"S"]){
        [cell.btnOption setTitle:@"R" forState:UIControlStateNormal];
    }else{
        [cell.btnOption setTitle:@"S" forState:UIControlStateNormal];
    }
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}


- (void)reload {
//    selectedBboxes = nil;
//    selectedBboxes = [NSMutableArray new];
    [_tblOptions reloadData];
}

- (void)selectCell:(BOOL)selected andCell :(CustomDropDown_Cell *)cell{
    
    
    if (selected) {
        cell.btnOption.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
        [cell.btnOption setTitle:@"S" forState:UIControlStateNormal];
        
    } else {
        
        cell.btnOption.titleLabel.font = [UIFont fontWithName:@"loudhailer" size:20.0];
        [cell.btnOption setTitle:@"R" forState:UIControlStateNormal];
        
    }
}



@end
