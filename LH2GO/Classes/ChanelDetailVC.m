//
//  ChanelDetailVC.m
//  LH2GO
//
//  Created by VVDN on 11/10/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "ChanelDetailVC.h"
#import "ChannelDetail.h"
#import "TimeConverter.h"
#import "SharedUtils.h"
#import "EventLog.h"
#import "ImageOverlyViewController.h"
#import "FLAnimatedImage.h"
#import "InternetCheck.h"

@interface ChanelDetailVC ()<APICallProtocolDelegate>
{
    SharedUtils *sharedUtils;
    NSInteger reportedContentId;
    NSString *plistPath;
    NSTimer *expiryCounter;
    UILabel *expiryLabel;
    BOOL isClickedOnReport;
}
@end

@implementation ChanelDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    //self.title = @"Channel Content";
    reportedContentId = 0;
    [self addTopBarButtons];
    
    //Get the documents directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    plistPath = [documentsDirectory stringByAppendingPathComponent:@"ChannelContent.plist"];
    // Do any additional setup after loading the view.
    
    expiryCounter = nil;
    expiryCounter =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(setExpiryForContent:)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer: expiryCounter forMode:NSRunLoopCommonModes];
    
    _tblContent.backgroundColor = [Common colorwithHexString:themeColor alpha:1];
    
    [self setFontSize];
    
    if(![_mediaPath isEqualToString:@""] &&  _mediaPath != nil){
        _lblFileType.text = @"Image"; //any media
        _lblFileSize.text = @"File Size: 5KB";
        _vwFileInfo.hidden = false;
    }
    else{
        _vwFileInfo.hidden = true;
    }
    
    _vwFileInfo.hidden = true; //hide for all
    
    UITapGestureRecognizer  *coolViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coolViewTapped:)];
    coolViewGesture.numberOfTapsRequired=1;
    [_coolUserTapView addGestureRecognizer:coolViewGesture];
    
    UITapGestureRecognizer  *contactViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contactViewTapped:)];
    contactViewGesture.numberOfTapsRequired=1;
    [_contactUserTapView addGestureRecognizer:contactViewGesture];
    
    if(_isCool == YES){
        [_coolImageView setImage:[UIImage imageNamed:@"active_cool.png"]];
        _coolImageView.accessibilityIdentifier=@"cool_Selected";
    }
    else{
        [_coolImageView setImage:[UIImage imageNamed:@"inactive_cool.png"]];
        _coolImageView.accessibilityIdentifier=@"cool_not_Selected";
    }
    
    if(_isContact == YES){
        [_contactImageView setImage:[UIImage imageNamed:@"active_spark.png"]];
        _contactImageView.accessibilityIdentifier=@"contact_Selected";
    }
    else{
        [_contactImageView setImage:[UIImage imageNamed:@"inactive_spark.png"]];
        _contactImageView.accessibilityIdentifier=@"contact_not_Selected";
    }
    
    if(_isShare == YES){
        [_shareBtn setImage:[UIImage imageNamed:@"active_share.png"] forState:UIControlStateNormal];
        [_shareBtn setEnabled:NO];
        
    }
    else
        [_shareBtn setImage:[UIImage imageNamed:@"inactive_share.png"] forState:UIControlStateNormal];
    if(![_coolNumber isEqualToNumber:[NSNumber numberWithInt:0]])
        _coolCount.text = [NSString stringWithFormat:@"%ld Cool",(long)[_coolNumber integerValue]];
    if(![_shareNumber isEqualToNumber:[NSNumber numberWithInt:0]])
        _shareCount.text = [NSString stringWithFormat:@"%ld shares",(long)[_shareNumber integerValue]];
    if(![_contactNumber isEqualToNumber:[NSNumber numberWithInt:0]])
        _contactCount.text = [NSString stringWithFormat:@"%ld Contact",(long)[_contactNumber integerValue]];

    DLog(@"Channel details are %@",_currentContentDetail);
}

-(void)setFontSize{
    _lblFileSize.font = [_lblFileSize.font fontWithSize:[Common setFontSize:_lblFileSize.font]];
    _lblFileType.font = [_lblFileType.font fontWithSize:[Common setFontSize:_lblFileType.font]];
    _lblFileType_Head.font = [_lblFileType_Head.font fontWithSize:[Common setFontSize:_lblFileType_Head.font]];
    _coolCount.font = [UIFont fontWithName:@"Aileron-Regular"  size:15];
    _contactCount.font = [UIFont fontWithName:@"Aileron-Regular"  size:15];
    _shareCount.font = [UIFont fontWithName:@"Aileron-Regular"  size:15];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super  viewWillAppear:animated];
    expiryCounter = nil;
    expiryCounter =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(setExpiryForContent:)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer: expiryCounter forMode:NSRunLoopCommonModes];
    
    //for resizing table a/c to its cell height
    CGFloat tableHeight = 0.0f;
    for (int i = 0; i < 1; i ++) { //array count
        tableHeight += [self tableView:_tblContent heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    _tblContent.frame = CGRectMake(_tblContent.frame.origin.x, _tblContent.frame.origin.y, _tblContent.frame.size.width, tableHeight);
    _tblHeight.constant = tableHeight ;
    //_tblContent.translatesAutoresizingMaskIntoConstraints =  true;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChannelSoftKeyUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:@"ChannelSoftKeyUpdate" object:nil];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [expiryCounter invalidate];
    expiryCounter = nil;
}

- (void)addTopBarButtons
{
    UIBarButtonItem * lefttButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveChanges)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = lefttButton;
    
}

-(void)saveChanges{}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView{
    return 1;  //change accordingly
    
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section{
    return 1;
    //change accordingly
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat h = [self getTextviewHeightFromIndex:indexPath];
    //return (370-30);
    
    
    if(![_mediaPath isEqualToString:@""] &&  _mediaPath != nil){
        return (290*kRatio) +h; //370
    }
    else{
        return (65*kRatio) +h;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        //cell.backgroundColor = [UIColor clearColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![_mediaPath isEqualToString:@""] && _mediaPath != nil){
        static NSString *cellIdentifier = @"ChanelDetailCell";
        ChanelDetailCell *cell = (ChanelDetailCell *)  [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.lblText.text = _timeDisplay;
        CGFloat h = [self getTextviewHeightFromIndex:indexPath];
        cell.txtView_height.constant = h;
       cell.txtView.delegate = self;
        cell.img.hidden = NO;
        NSString *string = _mediaType;
        if ([string containsString:@"I"]){
            UIImage *img1 = [[SDImageCache sharedImageCache] diskImageForKey:_mediaPath];
            
            NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
            
            NSString* currentFile = [stringPath stringByAppendingPathComponent:[_mediaPath lastPathComponent]];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
            
            if (!img1 && fileExists) {
                img1 = [UIImage imageWithData:[NSData dataWithContentsOfFile:currentFile]];
            }
            /* CGFloat h1 =  cell.img.frame.size.height;
             CGFloat w1 =  cell.img.frame.size.width;
             CGSize size = CGSizeMake(w1, h1); // set the width and height
             UIImage *resizedImage = [Common resizeImage:img1 imageSize:size];*/
            [cell.img setImage:img1];
            cell.img.contentMode = UIViewContentModeScaleAspectFit;
        }
        else if([string containsString:@"G"]){
            
            //            NSData *gifdata = [NSData dataWithContentsOfFile:_mediaPath];
            
            
            NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
            
            
            NSString* currentFile = [stringPath stringByAppendingPathComponent:[_mediaPath lastPathComponent]];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
            
            NSData *gifdata = [NSData dataWithContentsOfFile:_mediaPath];
            if (!gifdata) {
                
                if (fileExists)
                {
                    FLAnimatedImage *FLimage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:currentFile]];
                    cell.img.contentMode =  UIViewContentModeScaleAspectFit;
                    cell.img.animatedImage = FLimage;                }
                else
                {
                    UIImage *img1 = [[SDImageCache sharedImageCache] diskImageForKey:_mediaPath];
                    [cell.img setImage:img1];
                    cell.img.contentMode = UIViewContentModeScaleAspectFit;
                }
            }
            else
            {
                FLAnimatedImage *FLimage;
                FLimage = [FLAnimatedImage animatedImageWithGIFData:gifdata];
                if (!FLimage) {
                    FLimage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:currentFile]];
                }
                cell.img.contentMode =  UIViewContentModeScaleAspectFit;
                cell.img.animatedImage = FLimage;
            }
        }
        
        //formatting: urls & phonenumber in bold
        NSMutableAttributedString *attributedTxt = [Common getAttributedString:_textToBeDisplayed withFontSize:cell.txtView.font.pointSize];
        [cell.txtView setAttributedText: attributedTxt];
        cell.txtView.dataDetectorTypes = UIDataDetectorTypeAll;
        cell.txtView.tag = indexPath.row;
        cell.reportBtn.tag = indexPath.row;
        [cell.reportBtn addTarget:self action:@selector(deleteContent:) forControlEvents:UIControlEventTouchUpInside];
        
        UIGestureRecognizer *recognizerImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        cell.img.userInteractionEnabled = YES;
        recognizerImage.delegate = self;
        [cell.img addGestureRecognizer:recognizerImage];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        expiryLabel = cell.lblText;
        cell.dateLabel.text = _dateStr;
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"ChanelDetailCell_txt";
        ChanelDetailCell *cell = (ChanelDetailCell *)  [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.lblText.text = _timeDisplay;
        CGFloat h = [self getTextviewHeightFromIndex:indexPath];
        cell.txtView_height.constant = h;
        cell.txtView.delegate = self;
        //formatting: urls & phonenumber in bold
        NSMutableAttributedString *attributedTxt = [Common getAttributedString:_textToBeDisplayed withFontSize:cell.txtView.font.pointSize];
        [cell.txtView setAttributedText: attributedTxt];
        
        cell.txtView.tag = indexPath.row;
        cell.reportBtn.tag = indexPath.row;
        [cell.reportBtn addTarget:self action:@selector(deleteContent:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        expiryLabel = cell.lblText;
        cell.dateLabel.text = _dateStr;
        return cell;
    }
}

-(void)coolViewTapped:(UITapGestureRecognizer*)getureRecognizer{
    
    ChannelDetail *chanelDetail = [DBManager entity:@"ChannelDetail" idName:@"contentId" idValue:[NSString stringWithFormat:@"\'%@\'", _cID]];
    
    if ([_coolImageView.accessibilityIdentifier isEqualToString:@"cool_not_Selected"]) {
        _coolImageView.accessibilityIdentifier=@"cool_Selected";
        [_coolImageView setImage:[UIImage imageNamed:@"active_cool.png"]];
        chanelDetail.cool=YES;
        NSInteger coolCount = [chanelDetail.coolCount integerValue];
        coolCount++;
        NSNumber *coolValue = [NSNumber numberWithInteger:coolCount];
        chanelDetail.coolCount = coolValue;
        if(![chanelDetail.coolCount isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            _coolCount.text = [NSString stringWithFormat:@"%@ Cool",chanelDetail.coolCount];
        }
        else
            _coolCount.text = @"Cool";
        [self callSofKeysAPI:chanelDetail type:@"cool"];
    }
    else{
        return;
        /* _coolImageView.accessibilityIdentifier=@"not_Selected";
         [_coolImageView setImage:[UIImage imageNamed:@"inactive_cool.png"]];
         chanelDetail.cool = NO;*/
    }
}

-(void)contactViewTapped:(UITapGestureRecognizer*)getureRecognizer{
    ChannelDetail *chanelDetail = [DBManager entity:@"ChannelDetail" idName:@"contentId" idValue:[NSString stringWithFormat:@"\'%@\'", _cID]];

    if ([_contactImageView.accessibilityIdentifier isEqualToString:@"contact_not_Selected"]) {
        _contactImageView.accessibilityIdentifier=@"contact_Selected";
        [_contactImageView setImage:[UIImage imageNamed:@"active_spark.png"]];
        [chanelDetail setContact:YES];
        NSInteger contactCount = [chanelDetail.contactCount integerValue];
        contactCount++;
        NSNumber *contactValue = [NSNumber numberWithInteger:contactCount];
        chanelDetail.contactCount = contactValue;
        if(![chanelDetail.contactCount isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            _contactCount.text = [NSString stringWithFormat:@"%@ Contact",chanelDetail.contactCount];
        }
        else
            _contactCount.text = @"Contact";
        [AppManager showAlertWithTitle:@"" Body:@"Your Contact Request is under process."];
        [self callSofKeysAPI:chanelDetail type:@"contact"];
    }
    else{
        return;
        /* _contactImageView.accessibilityIdentifier=@"not_Selected";
         [_contactImageView setImage:[UIImage imageNamed:@"inactive_spark.png"]];
         chanelDetail.cool = NO;*/
    }

}

- (void)tapImage:(UITapGestureRecognizer *)recognizer {
    
    
    
    ImageOverlyViewController *vc   = (ImageOverlyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ImageOverlyViewController"];
    vc.mediaType = _mediaType;
    vc.mediaPath = _mediaPath;
    vc.channelId = _currentChannel.channelId;
    vc.contentId = _cID.integerValue;
    
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark- ReportContentAction

-(void)deleteContent:(UIButton*)btn{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Content" message:@"Do you want to mark this content as abusive/inappropriate?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        
        isClickedOnReport = YES;
        //ChannelDetail *channeldetail = [DBManager entity:@"ChannelDetail" idName:@"contentId" idValue:[NSString stringWithFormat:@"\'%@\'", _cID]];
        reportedContentId = _currentContentDetail.contentId.integerValue;
        
        [DBManager save];
        
        [LoaderView addLoaderToView:self.view];
        
        [self reportContentToAdmin];
        
        _currentContentDetail.toBeDisplayed = NO;
        
        [LoaderView removeLoader];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

-(void)reportContentToAdmin{
    
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSString *contentId = [NSString stringWithFormat:@"%ld",(long)reportedContentId];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.loud_hailerid,@"loudhailer_id",_currentChannel.channelId,@"channel_id",contentId,@"content_id",nil];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)contentId],@"channelContentId",_currentChannel.channelId,@"channelId",@"offendedcontent",@"text",nil];
    
    NSMutableDictionary *postDictionary1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_report_content",@"log_sub_category",_currentChannel.channelId,@"channelId",[NSString stringWithFormat:@"%ld", (long)contentId],@"channelContentId",@"offendedcontent",@"text",_currentChannel.channelId,@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary1];
    
    //    [EventLog addEventWithDict:postDictionary1];
    //    _currentContentDetail.duration = 00;
    //    NSNumber *count = [Global shared].currentUser.eventCount;
    //    int value = [count intValue];
    //    count = [NSNumber numberWithInt:value + 1];
    //    [[Global shared].currentUser setEventCount:count];
    // [DBManager save];
    
    //    if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0))
    //    {
    //        //show loader...
    //        // [LoaderView addLoaderToView:self.view];
    //        [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
    //    }
    
    
    if ([AppManager isInternetShouldAlert:YES])
    {
        [sharedUtils makePostCloudAPICall:postDictionary andURL:REPORT_CHANNEL_CONTENT];
    }
}



-(CGFloat)getTextviewHeightFromIndex:(NSIndexPath *)indexPath
{
    // ChanelDetailCell *cell = [_tblContent cellForRowAtIndexPath:indexPath];
    if(!txtvw)
        txtvw= [[UITextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-40, 0)];
    [txtvw setFont:[UIFont fontWithName:@"Aileron-Regular" size:15*kRatio]];
    txtvw.text = _textToBeDisplayed;//@"This is channel new style feed : This is a free online calculator which counts, url:  http://www.lettercount.com and phone 9898988988.";
    CGSize contentSize = txtvw.contentSize;
    
    int numberOfLinesNeeded = contentSize.height / txtvw.font.lineHeight;
    CGRect textViewFrame= txtvw.frame;
    textViewFrame.size.height = numberOfLinesNeeded * txtvw.font.lineHeight + 15*kRatio   ;//
    return textViewFrame.size.height;
    //txtvwHeight.constant = textViewFrame.size.height ;
    //[_txtViewNotes setFrame:textViewFrame];
    //_txtViewNotes.translatesAutoresizingMaskIntoConstraints =  true;
}

-(void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)setExpiryForContent:(NSTimer*)timer
{
    int hours, minutes, seconds,secondsLeft,days;
    BOOL isContentValid;
    
    if (!isClickedOnReport) {
        
         if(([_currentContentDetail.duration intValue] == k_ForeverFeed_AppDisplayTime || [_currentContentDetail.duration intValue] == k_OLD_ForeverFeed_AppDisplayTime || !_currentContentDetail.toBeDisplayed) && _currentContentDetail.isForeverFeed ){
            _currentContentDetail.timeStr = @"";
            _currentContentDetail.toBeDisplayed = YES;
        }
        else{
            
            isContentValid =  [[NSDate date] timeIntervalSince1970] - [_currentContentDetail.received_timeStamp longLongValue] <=  [_currentContentDetail.duration intValue];
            
            
            if(isContentValid) {
                secondsLeft = [_currentContentDetail.duration intValue] - ([[NSDate date] timeIntervalSince1970] - [_currentContentDetail.created_time longLongValue]);
                
                days = secondsLeft/(60*60*24);
                if(days > 0)
                    secondsLeft = secondsLeft - (days * 60*60*24);
                hours = secondsLeft / (60*60);
                if(hours > 0)
                    secondsLeft = secondsLeft - (hours * 60*60);
                minutes = secondsLeft / 60;
                if(minutes > 0)
                    secondsLeft = secondsLeft - (minutes * 60);
                seconds = secondsLeft;
                NSString *str =[NSString stringWithFormat:@"%02d:%02d:%02d:%02d",days,hours, minutes, seconds];//Time Remaining
                
                _currentContentDetail.timeStr = str;
                _currentContentDetail.toBeDisplayed = YES;
                _timeDisplay = str;
                
                expiryLabel.text = str;
                
            }
            else {
                //            _currentContentDetail.toBeDisplayed = NO;
                //            [self createContentIdPlist:_currentContentDetail];
                //            [DBManager save];
                //            [_tblContent reloadData];
                [expiryCounter invalidate];
                expiryCounter = nil;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Content Expired! Press OK to go back." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
                    [self goBack];
                }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

-(void)createContentIdPlist:(ChannelDetail*)content{
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    NSMutableArray *expiredContent;
    if ([[NSFileManager defaultManager] fileExistsAtPath: plistPath]) {
        
        expiredContent = [[NSMutableArray alloc] initWithContentsOfFile: plistPath];
    }
    else {
        // If the file doesn’t exist, create an empty dictionary
        expiredContent = [[NSMutableArray alloc] init];
    }
    
    //To insert the data into the plist
    
    [data setObject:content.contentId forKey:@"contentId"];
    [data setObject:content.channelId forKey:@"channelId"];
    [expiredContent addObject:data];
    [expiredContent writeToFile:plistPath atomically:YES];
    [DBManager deleteOb:content];
}


#pragma mark- Shared Utils Delegate Method

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    if(responseDict !=  nil)
    {
        DLog(@"responseDict is --- %@",responseDict);
        BOOL status = [[responseDict objectForKey:@"status"]boolValue];
        NSString *msgStr= [responseDict objectForKey:@"status"];
        if (status || [msgStr isEqualToString:@"Success"])
        {
            NSString *message = [responseDict objectForKey:@"message"];
            if([message isEqualToString:@"Channel content reported successfully..!"] )
            {
                DLog(@"Content has been removed from cloud");
                
                [AppManager showAlertViewWithTitle:@"Acknowledgement" andMessage:@"Your concern has been reported to super admin and he will take the required action within 24 hours." firstButtonMsg:@"OK" andSecondBtnMsg:nil andVC:self noOfBtn:1 completion:^(BOOL isOkButton) {
                    if (isOkButton)
                    {
                        // move back to previous screen
                        [self.navigationController popViewControllerAnimated:true];
                    }
                }];
            }
            else if([message isEqualToString:@"Channel cool saved successfully.!"]){}
            else if([message isEqualToString:@"Channel contact saved successfully.!"])
            {
                [AppManager showAlertWithTitle:@"Acknowledgement" Body:@"Your contact request has been processed, admin will contact you within 24 hours."];
            }
            else if([message isEqualToString:@"Channel share saved successfully.!"])
            {
                [AppManager showAlertWithTitle:@"" Body:@"Coming Soon"];
            }
        }
        else if ([msgStr isEqualToString:@"Error"])
        {
            //            {
            //                message = "Invalid Content/Channel ID..!";
            //                status = Error;
            //            }
            NSString *message = [responseDict objectForKey:@"message"];
            if([message isEqualToString:@"Invalid Content/Channel ID..!"] )
            {
                reportedContentId = _currentContentDetail.contentId.integerValue;
                _currentContentDetail.toBeDisplayed = NO;
                
                [DBManager save];
                
                // move back to previous screen
                [self.navigationController popViewControllerAnimated:true];

            }
        }
    }
}

#pragma mark SoftKeysAction

- (IBAction)softKeysAction:(UIButton*)sender {
    
    ChannelDetail *channeldetail = [DBManager entity:@"ChannelDetail" idName:@"contentId" idValue:[NSString stringWithFormat:@"\'%@\'", _cID]];
    NSString *type = sender.currentTitle;
    if([type isEqualToString:@"a"]){
        [sender setImage:[UIImage imageNamed:@"active_cool.png"] forState:UIControlStateNormal];
        [channeldetail setCool:YES];
        [sender setEnabled:NO];
        
    }
    else if([type isEqualToString:@"b"]){
        [sender setImage:[UIImage imageNamed:@"active_spark.png"] forState:UIControlStateNormal];
        [channeldetail setContact:YES];
        [sender setEnabled:NO];
        [AppManager showAlertWithTitle:@"" Body:@"Your Contact Request is under process."];
    }
    else if([type isEqualToString:@"c"]){
        [sender setImage:[UIImage imageNamed:@"active_share.png"] forState:UIControlStateNormal];
        [channeldetail setShare:YES];
        [sender setEnabled:NO];
    }
    
    [self callSofKeysAPI:channeldetail type:type];
}

-(void)callSofKeysAPI:(ChannelDetail*)channelDetail type:(NSString*)type{
    
    NSMutableDictionary *postDictionary ;
    int timeStamp = (int)[TimeConverter timeStamp];
//    if([type isEqualToString:@"a"]){
//        type = @"cool";
//    }else if([type isEqualToString:@"b"]){
//        type = @"contact";
//    }else if([type isEqualToString:@"c"]){
//        type = @"share";
//    }
    
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",[Global shared].currentChannel.channelId,@"channel_id"
                      ,channelDetail.contentId,@"content_id",[NSString stringWithFormat:@"%d",timeStamp],@"timestamp",type,@"type",nil];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"selectSoftKey",@"text",nil];
    
    NSMutableDictionary *postDictionaryEventLog = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",[NSString stringWithFormat:@"on_click_%@",type],@"log_sub_category",[Global shared].currentChannel.channelId,@"channelId",channelDetail.contentId,@"channelContentId",@"selectSoftKey",@"text",[Global shared].currentChannel.channelId,@"category_id",detaildict,@"details",nil];
    [AppManager saveEventLogInArray:postDictionaryEventLog];

    BOOL isConnected = [[InternetCheck sharedInstance] internetWorking];
    if (isConnected)
    {
        [sharedUtils makePostCloudAPICall:postDictionary andURL:CHANNELCONTENTTYPE];
    }
    else
    {
        if([type isEqualToString:@"contact"])
        {
            [AppManager showAlertWithTitle:@"" Body:@"Your request will be processed as soon as you will be connected to the Internet"];
        }
        else if([type isEqualToString:@"cool"])
        {
            [AppManager showAlertWithTitle:@"" Body:@"Your selection will be recorded as soon as you will be connected to the Internet"];
        }
        [AppManager saveSoftKeyActionInDictionary:postDictionary];
    }
}

- (void)refreshTableView:(NSNotification *)noti
{
    DLog(@"Object is %@",noti.object);
    ChannelDetail *c = noti.object;
    if ([c.channelId isEqualToString:_currentContentDetail.channelId]) {
        
        NSNumber *time1 = [NSNumber numberWithDouble:([c.created_time doubleValue] - 3600)];
        NSTimeInterval interval = [time1 doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setLocale:[NSLocale currentLocale]];
        [dateformatter setDateFormat:@"MM-dd-yyyy"];
        NSString *dateString=[dateformatter stringFromDate:date];
        _dateStr  = dateString;
        _mediaPath = c.mediaPath;
        _textToBeDisplayed = c.text;
        if(([c.duration intValue] == k_ForeverFeed_AppDisplayTime || [c.duration intValue] == k_OLD_ForeverFeed_AppDisplayTime) && c.isForeverFeed){
            c.timeStr = @"";
            c.toBeDisplayed = YES;
            _timeDisplay = c.timeStr;
        }
        else
            _timeDisplay = c.timeStr;
        
        _cID = c.contentId;
        _mediaType = c.mediaType;
        _currentContentDetail = c;
        _isCool = c.cool;
        _isContact = c.contact;
        _isShare = c.share;
        _coolNumber = c.coolCount;
        _contactNumber = c.contactCount;
        _shareNumber = c.shareCount;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_tblContent reloadData];
            
        });
        
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    
    int timeStamp = (int)[TimeConverter timeStamp];
    
   // NSArray *totalChannelContent ; // = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", _myChannel.channelId] descr:[NSSortDescriptor sortDescriptorWithKey:@"received_timeStamp" ascending:NO] isDistinctResults:YES];
 //   totalChannelContent = [_detailsOfChannel copy];
 //   ChannelDetail *c = [totalChannelContent objectAtIndex:textView.tag];
    
    selectedContentIndex = _currentContentDetail.contentId.integerValue;
    
    NSString *urlString = [NSString stringWithFormat:@"%@",URL];
    NSMutableDictionary *postDictionary;
    NSMutableDictionary *detaildict;
    
    if([urlString hasPrefix:@"https://"] || ([urlString hasPrefix:@"http://"]))
    {
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",_currentChannel.channelId,@"channelId",textView.text,@"text",nil];
        
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_click_url",@"log_sub_category",_currentChannel.channelId,@"channelId",[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",textView.text,@"text",detaildict,@"details",nil];
    }
    else if([urlString hasPrefix:@"telprompt:"] || [urlString hasPrefix:@"tel:"])
    {
        detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:textView.text,@"text",nil];
        postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_click_phone_number",@"log_sub_category",_currentChannel.channelId,@"channelId",[NSString stringWithFormat:@"%ld", (long)selectedContentIndex],@"channelContentId",textView.text,@"text",@"",@"category_id",detaildict,@"details",nil];
        
        [[NSUserDefaults standardUserDefaults]setObject:urlString forKey:k_PhoneNumber];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    [AppManager saveEventLogInArray:postDictionary];
    
    //    [EventLog addEventWithDict:postDictionary];
    //
    //    NSNumber *count = [Global shared].currentUser.eventCount;
    //    int value = [count intValue];
    //    count = [NSNumber numberWithInt:value + 1];
    //    [[Global shared].currentUser setEventCount:count];
    //    [DBManager save];
    
    
    //    if (delegate && [delegate respondsToSelector:@selector(hitEventLog:)] && ([count intValue]%10 == 0)){
    //        [delegate hitEventLog:[Global shared].currentUser.user_id];
    //    }
    
    return YES;
    
    
}
@end
