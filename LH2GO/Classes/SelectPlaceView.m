
//
//  SelectPlaceView.m
//  LH2GO
//
//  Created by Parul Mankotia on 04/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "SelectPlaceView.h"

@interface SelectPlaceView ()<APICallProtocolDelegate>
{
    NSMutableArray *cityListArray;
    NSArray *selectedCityArray;
    NSArray *country_cityDataArray;
}

@end

@implementation SelectPlaceView 

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SelectPlaceView" owner:self options:nil] objectAtIndex:0];
        self.frame = frame;
    }
    cityListArray = [[NSMutableArray alloc] init];
    selectedCityArray = [[NSMutableArray alloc] init];

    country_cityDataArray = [Country getAllCountry_CityList];
    [self initializeViews];
    
    
    return self;
}

-(void)initializeViews
{
    self.countryButton.layer.borderWidth = 1.0;
    Country *country = [country_cityDataArray firstObject];
    [self.countryButton setTitle:country.countryName forState:UIControlStateNormal];
    
    self.countryButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.countryButton.titleEdgeInsets = UIEdgeInsetsMake(0,10,0,0);
    self.countryButton.selected = NO;
    
    self.cityButton.layer.borderWidth = 1.0;
    [self.cityButton setTitle:[[country.cityNames valueForKey:@"city_name"] firstObject] forState:UIControlStateNormal];
    self.cityButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cityButton.titleEdgeInsets = UIEdgeInsetsMake(0,10,0,0);
    self.cityButton.selected = NO;
    
    NSInteger calculateCountryTableHeight = [country_cityDataArray count] * 44;
    if (calculateCountryTableHeight > 200) {
        calculateCountryTableHeight = 200;
    }
    UITableView *countryTableView = [[UITableView alloc] initWithFrame:CGRectMake(_countryButton.frame.origin.x, _countryButton.frame.origin.y+_countryButton.frame.size.height, 269, calculateCountryTableHeight)];
    countryTableView.tag = 100;
    countryTableView.dataSource=self;
    countryTableView.delegate=self;
    countryTableView.hidden = YES;
    countryTableView.backgroundColor = [Common colorwithHexString:@"333333" alpha:1.0];
    countryTableView.layer.borderWidth = 1.0;
    countryTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_selectionView addSubview:countryTableView];
    
    [cityListArray addObjectsFromArray:country.cityNames];
    NSInteger calculateCityTableHeight = [cityListArray count] * 44;
    if (calculateCityTableHeight > 200) {
        calculateCityTableHeight = 200;
    }
    UITableView *cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(_cityButton.frame.origin.x, _cityButton.frame.origin.y+_cityButton.frame.size.height, 269, calculateCityTableHeight)];
    cityTableView.tag = 101;
    cityTableView.dataSource=self;
    cityTableView.delegate=self;
    cityTableView.hidden = YES;
    cityTableView.backgroundColor = [Common colorwithHexString:@"333333" alpha:1.0];
    cityTableView.layer.borderWidth = 1.0;
    cityTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_selectionView addSubview:cityTableView];
}


-(IBAction)countryDropDownAction:(UIButton*)sender{
    if (self.countryButton.selected == NO) {
        self.countryButton.selected = YES;
        [_selectionView viewWithTag:100].hidden=NO;
    }
    else{
        self.countryButton.selected = NO;
        [_selectionView viewWithTag:100].hidden=YES;
    }
}

-(IBAction)cityDropDownAction:(UIButton*)sender{
    if (self.cityButton.selected == NO) {
        self.cityButton.selected = YES;
        [_selectionView viewWithTag:101].hidden=NO;
    }
    else{
        self.cityButton.selected = NO;
        [_selectionView viewWithTag:101].hidden=YES;
    }
}


#pragma mark-
#pragma mark- Table View Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 100) {
        return [country_cityDataArray count];
    }
    else{
        return [cityListArray count];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (tableView.tag == 100) {
        Country *country = [country_cityDataArray objectAtIndex:indexPath.row];
        cell.textLabel.text = country.countryName;
    }
    else{
        cell.textLabel.text = [[cityListArray valueForKey:@"city_name"] objectAtIndex:indexPath.row];
    }
    UITapGestureRecognizer *tapOnRow =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponRowGesture:)];
    [cell addGestureRecognizer:tapOnRow];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL{
    if ([[responseDict valueForKey:@"message"] isEqual:kResponseMessage_SetCity]) {
        [AppManager showAlertWithTitle:@"Alert" Body:@"City updated successfully."];
        [LoaderView removeLoader];
    }
}

-(void)taponRowGesture:(UITapGestureRecognizer*)gesture{
    UITableViewCell *tableCell = (UITableViewCell*)gesture.view;
    UITableView *tableView = (UITableView*)gesture.view.superview;
    NSIndexPath *indexPathOfCell = [tableView indexPathForCell:tableCell];
    NSInteger rowNumber = [indexPathOfCell row];
    if (tableView.tag == 100) {
        Country *country = [country_cityDataArray objectAtIndex:rowNumber];
        [cityListArray removeAllObjects];
        [cityListArray addObjectsFromArray:country.cityNames];
        UITableView *tempTableView = [_selectionView viewWithTag:101];
        NSInteger calculateCityTableHeight = [cityListArray count] * 44;
        if (calculateCityTableHeight > 200) {
            calculateCityTableHeight = 200;
        }
        tempTableView.frame = CGRectMake(tempTableView.frame.origin.x, tempTableView.frame.origin.y, 269, calculateCityTableHeight);
        [tempTableView reloadData];
        [_selectionView viewWithTag:100].hidden=YES;
        [self.countryButton setTitle:country.countryName forState:UIControlStateNormal];
    }
    else if (tableView.tag == 101){
        [self.cityButton setTitle:[[cityListArray objectAtIndex:rowNumber] valueForKey:@"city_name"] forState:UIControlStateNormal];
        NSMutableDictionary *tempDict = [[cityListArray objectAtIndex:rowNumber] mutableCopy];
//        if (_isSelected) {
//            _isSelected = NO;
//            [tempDict setValue:@"1" forKey:@"city_type"];
//        }
//        else{
//            [tempDict setValue:@"0" forKey:@"city_type"];
//        }
        [tempDict setValue:@"0" forKey:@"city_type"];
        selectedCityArray = [selectedCityArray arrayByAddingObject:tempDict];
        [_selectionView viewWithTag:101].hidden=YES;
    }
}


-(IBAction)applyButtonAction:(id)sender{
    self.hidden=YES;
    for (UIGestureRecognizer *recognizer in self.superview.gestureRecognizers) {
        [self.superview removeGestureRecognizer:recognizer];
    }
    [_selectionView viewWithTag:101].hidden=YES;
    [_selectionView viewWithTag:100].hidden=YES;
    if ([selectedCityArray count] == 0) {
        if ([country_cityDataArray count] > 0) {
            Country *country = [country_cityDataArray firstObject];
            NSMutableDictionary *tempDict = [[country.cityNames firstObject] mutableCopy];
            [tempDict setValue:@"0" forKey:@"city_type"];
            selectedCityArray = [selectedCityArray arrayByAddingObject:tempDict];
        }
    }
    if ([self delegate] && [self.delegate respondsToSelector:@selector(userSelectedCityList:)]) {
        [self.delegate userSelectedCityList:selectedCityArray];
    }
}

-(IBAction)cancelButtonAction:(id)sender{
    [self removeFromSuperview];

    [_selectionView viewWithTag:101].hidden=YES;
    [_selectionView viewWithTag:100].hidden=YES;
    
    for (UIGestureRecognizer *recognizer in self.superview.gestureRecognizers) {
        [self.superview removeGestureRecognizer:recognizer];
    }
}


@end
