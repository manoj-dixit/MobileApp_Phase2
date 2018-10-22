//
//  CustomTitleView.m
//  LH2GO
//
//  Created by Parul Mankotia on 02/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "CustomTitleView.h"


@implementation CustomTitleView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:self options:nil] objectAtIndex:0];
        self.frame = frame;
    }
    _collectionDataArray = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customViewDisappears) name:@"CustomViewClose" object:nil];
    [self initializeViews];
   return self;
}

-(void)initializeViews
{
    [_placeListingCollectionView registerNib:[UINib nibWithNibName:@"PlaceListCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"PlaceListCollectionCell"];
}

-(void)initializeData
{
    /*SharedUtils *sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate=self;
    NSMutableDictionary  *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",nil];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,kGetUserCity_List];
    [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];*/
     

    
    if(![_collectionDataArray containsObject:@"Add New"]){
        [_collectionDataArray addObject:@"Add New"];
    }
}

#pragma mark -
#pragma mark - Collection Cell Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [_collectionDataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PlaceListCollectionCell";
    
    PlaceListCollectionCell *cell = (PlaceListCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if ([[_collectionDataArray objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]){
        [cell collectionCellManageData:[_collectionDataArray  objectAtIndex:indexPath.row]];
        cell.cityNameLabel.textColor = [UIColor whiteColor];

    }
        else{
            if ([_collectionDataArray count] > 0) {
                if ([[[_collectionDataArray objectAtIndex:indexPath.row] valueForKey:@"city_type"] integerValue] == 1) {
                    cell.cityCodeLabel.layer.borderColor = [UIColor colorWithRed:(133.0f/255.0f) green:(189.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0].CGColor;
                    cell.cityCodeLabel.layer.borderWidth = 1.0;
                    cell.cityNameLabel.textColor = [UIColor colorWithRed:(133.0f/255.0f) green:(189.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0];
                }else{
                    cell.cityCodeLabel.layer.borderWidth = 1.0;
                    cell.cityNameLabel.textColor = [UIColor whiteColor];
                    cell.cityCodeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
                }
                [cell collectionCellManageData:[[_collectionDataArray  objectAtIndex:indexPath.row] valueForKey:@"city_name"]];
            }
        }
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongTapped:)];
    [cell addGestureRecognizer:longPressGesture];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [_collectionDataArray count]-1) {
        CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        selectPlaceView = [[SelectPlaceView alloc] initWithFrame:frame];
        selectPlaceView.delegate = self;
        selectPlaceView.isFromSignUp = fromSignUp;
        selectPlaceView.isSelected = isSelected;
        [self addSubview:selectPlaceView];
        UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnViewToDismiss:)];
        tapOnView.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapOnView];
    }
    else{
        NSString *userSelectedCity = [[_collectionDataArray objectAtIndex:indexPath.row] valueForKey:@"city_name"];
        if ([_collectionDataArray count] > 0) {
            [_collectionDataArray removeObject:@"Add New"];
        }
        for (NSDictionary *dic in [_collectionDataArray mutableCopy]) {
            NSMutableDictionary *tempDic = [dic mutableCopy];
            if ([[tempDic valueForKey:@"city_name"] isEqualToString:userSelectedCity]) {
                [tempDic removeObjectForKey:@"city_type"];
                [tempDic setObject:@"1" forKey:@"city_type"];
            }
            else{
                [tempDic removeObjectForKey:@"city_type"];
                [tempDic setObject:@"0" forKey:@"city_type"];
            }
            [_collectionDataArray removeObject:dic];
            [_collectionDataArray addObject:tempDic];
        }
        [_collectionDataArray addObject:@"Add New"];
        [_placeListingCollectionView reloadData];
    }
}

#pragma mark -
#pragma mark - Methods
-(void)showHideNextButton:(BOOL)isFromChannelScreen{
    if(isFromChannelScreen){
        _nextButton.hidden = YES;
        fromSignUp = NO;
    }
    else{
        _nextButton.hidden = NO;
        fromSignUp = YES;

    }
}

-(void)tapOnViewToDismiss:(UITapGestureRecognizer*)gesture{
    UIView* view = gesture.view;
    CGPoint location = [gesture locationInView:view];
    if (!CGRectContainsPoint(selectPlaceView.selectionView.frame, location)) {
        [selectPlaceView removeFromSuperview];
        [self removeGestureRecognizer:gesture];
    }
}

-(IBAction)nextButtonAction:(UIButton*)button{
    SharedUtils *sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate=self;
    if([_collectionDataArray containsObject:@"Add New"]){
        [_collectionDataArray removeObject:@"Add New"];
    }
    if ([_collectionDataArray count] == 0) {
        [AppManager showAlertWithTitle:@"Alert" Body:@"Select City to continue."];
    }

    NSMutableDictionary  *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",[[_collectionDataArray firstObject] valueForKey:@"id"],@"default"
                                            ,[_collectionDataArray valueForKey:@"id"],@"options",nil];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,KSetUserCity_List];
    [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
}

-(void)userSelectedCityList:(NSArray*)selectedArray {
    //if (fromSignUp) {
        if ([_collectionDataArray containsObject:@"Add New"]) {
            [_collectionDataArray removeObject:@"Add New"];
        }
        if(![[_collectionDataArray valueForKey:@"city_name"] containsObject:[[selectedArray valueForKey:@"city_name"] lastObject]]){
            [_collectionDataArray addObjectsFromArray:selectedArray];
        }
        else{
            [AppManager showAlertWithTitle:@"Alert" Body:@"City already added."];
        }
        [_collectionDataArray addObject:@"Add New"];
        [_placeListingCollectionView reloadData];
  //  }
}

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL{
    if ([[responseDict valueForKey:@"message"] isEqualToString:kResponseMessage_SetCity]) {
        if ([self delegate] && [self.delegate respondsToSelector:@selector(redirectToChannelScreen)]) {
            [self.delegate redirectToChannelScreen];
            [self removeFromSuperview];
        }
    }
    else if ([[responseDict valueForKey:@"message"] isEqualToString:kUserCityInformation]){
       // _collectionDataArray = [responseDict valueForKey:@"data"];
    }
}

-(void)cellLongTapped:(UILongPressGestureRecognizer*)gesture{
    NSLog(@"cell is long pressed");
}

-(void)customViewDisappears{
    
    SharedUtils *sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate=self;
    if([_collectionDataArray containsObject:@"Add New"]){
        [_collectionDataArray removeObject:@"Add New"];
    }
    if ([_collectionDataArray count] == 0) {
        [AppManager showAlertWithTitle:@"Alert" Body:@"Select City to continue."];
    }
    NSString *defaultCity = @"";
    for (NSDictionary *dic in _collectionDataArray) {
        if ([[dic valueForKey:@"city_type"] integerValue] == 1) {
          defaultCity = [dic valueForKey:@"id"];
        }
    }
    
    NSMutableDictionary  *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",defaultCity,@"default"
                                            ,[_collectionDataArray valueForKey:@"id"],@"options",nil];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,KSetUserCity_List];
    [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
}

@end

