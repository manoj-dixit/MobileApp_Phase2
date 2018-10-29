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
    NSMutableArray *countryListArray;
    NSMutableArray *cityListArray;
    NSDictionary *dataDictionary;
    NSArray *selectedCityArray;
}

@end

@implementation SelectPlaceView 

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SelectPlaceView" owner:self options:nil] objectAtIndex:0];
        self.frame = frame;
    }
    [self getDataFromServer];
    countryListArray = [[NSMutableArray alloc] init];
    cityListArray = [[NSMutableArray alloc] init];
    selectedCityArray = [[NSMutableArray alloc] init];

    self.countryButton.layer.borderWidth = 1.0;
    self.countryButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.countryButton.titleEdgeInsets = UIEdgeInsetsMake(0,10,0,0);
    self.countryButton.selected = NO;
    
    self.cityButton.layer.borderWidth = 1.0;
    self.cityButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cityButton.titleEdgeInsets = UIEdgeInsetsMake(0,10,0,0);
    self.cityButton.selected = NO;
    
    return self;
}

-(void)initializeViews
{
    NSInteger calculateCountryTableHeight = [countryListArray count] * 44;
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
    
}

-(void)initializeCityFromCountrySelected{
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

-(void)getDataFromServer{
   SharedUtils *sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if ([AppManager isInternetShouldAlert:NO])
    {
        NSString *url = [NSString stringWithFormat:@"%@%@",BASE_API_URL,kCoutryCity_List];
        [sharedUtils makePostCloudAPICall:dic andURL:url];
    }
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
        return [countryListArray count];
    }
    else{
        return [cityListArray count];
    }
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
        cell.textLabel.text = [countryListArray objectAtIndex:indexPath.row];
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
    }else if ([[responseDict valueForKey:@"message"] isEqual:kResponseMessage_CityList])
     {
        dataDictionary = [responseDict valueForKey:@"data"];
         [countryListArray addObjectsFromArray:[dataDictionary allKeys]];
         [self initializeViews];
    }
}

-(void)taponRowGesture:(UITapGestureRecognizer*)gesture{
    UITableViewCell *tableCell = (UITableViewCell*)gesture.view;
    UITableView *tableView = (UITableView*)gesture.view.superview;
    NSIndexPath *indexPathOfCell = [tableView indexPathForCell:tableCell];
    NSInteger rowNumber = [indexPathOfCell row];
    if (tableView.tag == 100) {
        cityListArray = [dataDictionary valueForKey:[countryListArray objectAtIndex:rowNumber]];
        [self initializeCityFromCountrySelected];
        UITableView *tempTableView = [_selectionView viewWithTag:101];
        NSInteger calculateCityTableHeight = [cityListArray count] * 44;
        if (calculateCityTableHeight > 200) {
            calculateCityTableHeight = 200;
        }
        tempTableView.frame = CGRectMake(tempTableView.frame.origin.x, tempTableView.frame.origin.y, 269, calculateCityTableHeight);
        [tempTableView reloadData];
        [_selectionView viewWithTag:100].hidden=YES;
        [self.countryButton setTitle:[countryListArray objectAtIndex:rowNumber] forState:UIControlStateNormal];
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
    
    if (!_isFromSignUp) {
      /*  SharedUtils *sharedUtils = [[SharedUtils alloc] init];
        sharedUtils.delegate=self;
        NSMutableDictionary  *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",[[selectedCityArray firstObject] valueForKey:@"id"],@"default"
                                                ,[selectedCityArray valueForKey:@"id"],@"options",nil];
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,KSetUserCity_List];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];*/
    }
    else{
        //NSLog(@"if user from sign up");
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
