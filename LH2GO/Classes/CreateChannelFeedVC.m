//
//  CreateChannelFeedVC.m
//  LH2GO
//
//  Created by VVDN on 30/10/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "CreateChannelFeedVC.h"

@interface CreateChannelFeedVC ()

@end

@implementation CreateChannelFeedVC
bool buttonIsHighlighted;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTopBarButtons];
    self.title = @"Channel Content";
    _dropDown.dropdown_delegate = self;
    //tabletap gesture : It will work like view touchevent.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTap)];
    [_tblFeed addGestureRecognizer:tap];
}
#pragma mark - UITableViewDataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2; //2;  by nim Adv#1
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentifier = @"CreateChannelFeedCell_1";
//    CreateChannelFeedCell *cell = (CreateChannelFeedCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//
//    [cell.btnDropDown1 addTarget:self action:@selector(dropDownBtn_Tapped:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnDropDown2 addTarget:self action:@selector(dropDownBtn_Tapped:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnDropDown3 addTarget:self action:@selector(dropDownBtn_Tapped:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnDropDown4 addTarget:self action:@selector(dropDownBtn_Tapped:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnDropDown5 addTarget:self action:@selector(dropDownBtn_Tapped:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btn_broadcast addTarget:self action:@selector(checkBroadCast:) forControlEvents:UIControlEventTouchUpInside];
//
//
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
//
    return nil;
}
#pragma mark - UITableViewDelegate



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (IPAD)
    //        return 665*kRatio;
    return 750* kRatio;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1){
        
        
    }
    
    if(indexPath.section == 2){
        //    AdvanceSettingPart2Cell *cell = (AdvanceSettingPart2Cell *) [tableView cellForRowAtIndexPath:indexPath];
        
        
    }
    
    
    
}
- (void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1){
        
        
        
    }
    
}
#pragma mark - view touch events
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (buttonIsHighlighted){
        //    NSIndexPath *indexPathHighlight = [NSIndexPath indexPathForRow:0 inSection:0];
        //    CreateChannelFeedCell *cell =  [_tblFeed cellForRowAtIndexPath:indexPathHighlight];
        buttonIsHighlighted =  !buttonIsHighlighted;
        CustomDropDownView *bView = (CustomDropDownView *) [self.view viewWithTag:120];
        [bView removeFromSuperview];
    }
    
}

#pragma mark- IBAction

- (IBAction)goToNext:(id)sender {
    
//    CreateFeed_uploadVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateFeed_uploadVC"];
  //  [self.navigationController pushViewController:vc animated:NO];
}
#pragma mark - private methods
-(void)saveChanges{
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)dropDownBtn_Tapped:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CustomDropDownView" owner:self options:nil];
    _dropDown = [objects objectAtIndex:0];
    // _dropDown.optionList = [[NSMutableArray alloc] init];
    
    CGFloat boxHeight , boxWidth ;
    
    boxWidth = 185*kRatio;
    boxHeight = 200*kRatio;
    
    /*
     add array list accordingly
     
     */
    switch (btn.tag) {
        case 1:
            [_dropDown setFrame:CGRectMake(btn.frame.origin.x-boxWidth + 20, btn.frame.origin.y+15 + 10, boxWidth + 10,boxHeight)];
            _dropDown.optionList = [[NSMutableArray alloc]initWithObjects:@"Via Group",@"Via Channel",@"Via Buki-Box",@"Via App",@"Via Network",nil];
            break;
        case 2:
            [_dropDown setFrame:CGRectMake(btn.frame.origin.x-boxWidth + 20, btn.frame.origin.y+15 + 10, boxWidth + 10,boxHeight)];
            _dropDown.optionList = [[NSMutableArray alloc]initWithObjects:@"Via Group",@"Via Channel",@"Via Buki-Box",@"Via App",@"Via Network",nil];
            break;
        case 3:
            [_dropDown setFrame:CGRectMake(btn.frame.origin.x-boxWidth + 20, btn.frame.origin.y+15 + 10, boxWidth + 10,boxHeight)];
            _dropDown.optionList = [[NSMutableArray alloc]initWithObjects:@"Via Group",@"Via Channel",@"Via Buki-Box",@"Via App",@"Via Network",nil];
            break;
        case 4:
            [_dropDown setFrame:CGRectMake(btn.frame.origin.x-boxWidth + 20, btn.frame.origin.y+15 + 10, boxWidth + 10,boxHeight)];
            _dropDown.optionList = [[NSMutableArray alloc]initWithObjects:@"Via Group",@"Via Channel",@"Via Buki-Box",@"Via App",@"Via Network",nil];
            break;
        case 5:
            if (IPAD)
                [_dropDown setFrame:CGRectMake(btn.frame.origin.x-boxWidth + 20, btn.frame.origin.y+15 + 10, boxWidth + 10,boxHeight)];
            else
                [_dropDown setFrame:CGRectMake(btn.frame.origin.x-boxWidth + 20, btn.frame.origin.y- boxHeight, boxWidth + 10,boxHeight)];
            
            _dropDown.optionList = [[NSMutableArray alloc]initWithObjects:@"Via Group",@"Via Channel",@"Via Buki-Box",@"Via App",@"Via Network",nil];
            break;
            
        default:
            break;
    }
    _dropDown.layer.cornerRadius = 5.0;
    
    if (!buttonIsHighlighted){
        [self.view addSubview:_dropDown]; // added on view
        //            [self.tblFeed addSubview:_dropDown];  //added on table
        buttonIsHighlighted = YES;
        _dropDown.tag = 120;
    }else{
        CustomDropDownView *bView = (CustomDropDownView *) [self.view viewWithTag:120];
        [bView removeFromSuperview];
        buttonIsHighlighted = NO;
    }
    
}
- (void)checkBroadCast:(id)sender{
    
//    UIButton *btn  =  (UIButton*)sender;
//    NSIndexPath *indexPathHighlight = [NSIndexPath indexPathForRow:0 inSection:0];
//    CreateChannelFeedCell *cell = [_tblFeed cellForRowAtIndexPath:indexPathHighlight];
//    cell.vw_broadcast.hidden =  !cell.vw_broadcast.hidden;
//    if(cell.vw_broadcast.isHidden){
//        [btn setTitle:@"y" forState:UIControlStateNormal];
//    }else{
//        [btn setTitle:@"w" forState:UIControlStateNormal];
//    }
}


-(void)tableTap {
    if (buttonIsHighlighted){
        //    NSIndexPath *indexPathHighlight = [NSIndexPath indexPathForRow:0 inSection:0];
        //    CreateChannelFeedCell *cell =  [_tblFeed cellForRowAtIndexPath:indexPathHighlight];
        buttonIsHighlighted =  !buttonIsHighlighted;
        CustomDropDownView *bView = (CustomDropDownView *) [self.view viewWithTag:120];
        [bView removeFromSuperview];
    }
}
- (void)addTopBarButtons
{
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [leftButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    
    /* UIBarButtonItem * righttButton = [[UIBarButtonItem alloc]
     initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveChanges)];
     righttButton.tintColor = [UIColor whiteColor];
     */
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = leftButton;
    //    self.navigationItem.rightBarButtonItem.enabled = NO;
    
}


//delegate
-(void)optionSelectedwithIndex:(NSIndexPath *)indexPath
{
    //    //show loader
    //    [LoaderView addLoaderToView:self.view];
    //    //NSLog(@"The array of mac ids is %@",macIds);
    //    //Make api call to send data
    //    NSString *txt = [_shInputFld.text withoutWhiteSpaceString];
    //    ShoutInfo *sh = [ShoutInfo composeText:txt type:ShoutTypeTextMsg content:nil groupId:groupID parentShId:nil];
    //    shoutSave = sh;
    //    NSData *data = [ShoutManager dataFromObjectForShout:sh];
    //    NSString *iv = [PrefManager iv];
    //    const unsigned char *bytes = [data bytes];
    //    NSUInteger length = [data length];
    //    NSMutableArray *byteArray = [NSMutableArray array];
    //    for (NSUInteger i = 0; i < length; i++)
    //    {
    //        [byteArray addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
    //    }
    //    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"advertisement",@"method",@"relays",@"type",macIds,@"ble_mac_ids", byteArray,@"message",[NSNumber numberWithInt:(int)length], @"length",iv,@"iv",@"text",@"message_type",nil];
    //    if ([AppManager isInternetShouldAlert:YES])
    //    {
    //        [sharedUtils makePostCloudAPICall:postDictionary andURL:SEND_DATA_TO_CLOUD_URL];
    //    }
    //hide view
    [self shouldShowUserList:NO animated:YES];
}

- (void)shouldShowUserList:(BOOL)show animated:(BOOL)animate
{
    _dropDown.tblOptions.tableFooterView= [[UIView alloc]initWithFrame:CGRectZero];
    CGRect fr = _dropDown.frame;
    fr.origin.y = (show)?_tblFeed.frame.origin.y : self.view.frame.size.height;
    // NSLog(@"comms self.view height --- %f",self.view.frame.size.height);
    if (show) [_dropDown reload];
    if (!animate){
        _dropDown.frame = fr; return;
    }
    [UIView animateWithDuration:.4 animations:^{
        _dropDown.frame = fr;
    } completion:^(BOOL finished) {}];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
