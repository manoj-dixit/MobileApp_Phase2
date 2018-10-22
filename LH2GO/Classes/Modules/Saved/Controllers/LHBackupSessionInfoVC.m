//
//  LHBackupSessionInfoVC.m
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHBackupSessionInfoVC.h"
#import "UIView+Extra.h"
#import "UITextfield+Extra.h"
#import "AppManager.h"
#import "DBManager.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "BackUpManager.h"
#import "SavedViewController.h"
#import "LoaderView.h"
#import "BannerAlert.h"
#import "CommsViewController.h"
#import "ReplyViewController.h"
#import "ShoutManager.h"
@interface LHBackupSessionInfoVC ()<UITextViewDelegate,UITextFieldDelegate>
{
    __weak IBOutlet UITextField *_txtSessionName;
    __weak IBOutlet UILabel *_lblDate;
    __weak IBOutlet UILabel *_lblTime;
    __weak IBOutlet UITextView *_txtViewNotes;
    __weak IBOutlet TPKeyboardAvoidingScrollView  *scrollview;
    __weak IBOutlet NSLayoutConstraint *txtvwHeight;
      NSDateFormatter *formatter;
}

@end

@implementation LHBackupSessionInfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
  //  [self addTabbarWithTag: BarItemTag_Saved]; */
    
    [self initUI];
    [self popuLateData];
    _txtViewNotes.delegate  =self;
    _txtSessionName.delegate  =self;
    
    //[self scrollHeight];
    self.title = @"Backup Session Info";
    _txtViewNotes.autocorrectionType = UITextAutocorrectionTypeNo;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:k_GotuserSettings object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSettings) name:k_GotuserSettings object:nil];
    self.navigationItem.rightBarButtonItem = nil;
    [self setNavBarTitle];

}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self showCountOfNotifications];
    [self popuLateData];
    [self checkCountOfShouts];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoutArrived:) name:kNewShoutEncounterTemp object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewShoutEncounterTemp object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Other Methods

- (void)setNavBarTitle {
    
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Backup Session Info";
    titleLabel.textColor=[UIColor colorWithRed:(229.0f/225.0f) green:(0.0f/225.0f) blue:(28.0f/225.0f) alpha:1.0];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

-(void)gotSettings
{
    if ([PrefManager shouldOpenSaved] == NO)
    {
        [AppManager showAlertWithTitle:@"" Body:k_permissionAlertSaved];
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[SavedViewController class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }
}

-(NSString *)getBackUpName
{
    if (self.shoutBackUp)
    {
        return self.shoutBackUp.backupName;
    }
    else
    {
        return [self getDefaultBackUpName];
    }
}

-(NSString *)getDefaultBackUpName
{
    NSDate *currentDateTime = [NSDate date];
    NSString *backUpName = @"";
    NSString *txtSesionName=@"2GO Back-Up_";
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MM/dd/YYYY-hh:mm a"];;
    NSString *txtSesionDate = [dateformatter stringFromDate:currentDateTime];
    backUpName = [txtSesionName stringByAppendingString:txtSesionDate];
    return backUpName;
}

-(void)popuLateBackUpName
{
     [_txtSessionName setText:[self getBackUpName]];
}

-(NSDate *)getBackupDateTime
{
    NSDate *backUpDateTime;
    if (self.shoutBackUp)
    {
        backUpDateTime = self.shoutBackUp.backUpDate;
    }
    else
    {
        backUpDateTime = [NSDate date];
    }
    return backUpDateTime;
}

-(void)popuLateBackUpDateTime
{
    NSString *strDate = @"";
    NSDate *backUpDateTime = [self getBackupDateTime];
    strDate = [[self getDateFormate] stringFromDate:backUpDateTime];
    _lblTime.text = strDate;
}

-(NSString *)getBackUpNote
{
    NSString *strNote = @"";
    if (self.shoutBackUp)
    {
        strNote = self.shoutBackUp.backupNote;
    }
    else
    {
        strNote = @"";
    }
    return strNote;
}

-(void)populateBackUpNote
{
    _txtViewNotes.text = [self getBackUpNote];
    
    CGSize countentSize = _txtViewNotes.contentSize;
    int numberOfLinesNeeded = countentSize.height / _txtViewNotes.font.lineHeight;
    //int numberOfLinesInTextView = _txtViewNotes.frame.size.height / _txtViewNotes.font.lineHeight;
    CGRect textViewFrame= _txtViewNotes.frame;
    textViewFrame.size.height = numberOfLinesNeeded * _txtViewNotes.font.lineHeight + (15*kRatio);
    txtvwHeight.constant = textViewFrame.size.height ;
    //[_txtViewNotes setFrame:textViewFrame];
    //_txtViewNotes.translatesAutoresizingMaskIntoConstraints =  true;
}

-(void)popuLateData
{
    [self popuLateBackUpName];
    [self popuLateBackUpDateTime];
    [self populateBackUpNote];
}

- (void)scrollHeight
{
    float sizeOfContent = 0;
    UIView *lLast = [scrollview.subviews lastObject];
    NSInteger wd = lLast.frame.origin.y;
    NSInteger ht = lLast.frame.size.height;
    sizeOfContent = wd+ht;
    scrollview.contentSize = CGSizeMake(scrollview.frame.size.width, sizeOfContent);
}

-(NSDateFormatter *)getDateFormate//performance reason in cellForRow
{
    if (formatter)
    {
        return formatter;
    }
    else
    {
        formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM/dd/YYYY-hh:mm a"];
        return formatter;
    }
}

- (void)initUI
{   UIColor *whiteC = kColor(255, 255, 255, 0.3);
    [_txtViewNotes roundCorner:4 border:0.7 borderColor:whiteC];
    [_txtSessionName roundCorner:4 border:0.7 borderColor:whiteC];
    [_txtSessionName setMargin:10];
    _txtViewNotes.textContainerInset = UIEdgeInsetsMake(0, 5, 0, 5); //(top,left, bottom, right) /
    
    _txtSessionName.font = [_txtSessionName.font fontWithSize:[Common setFontSize:_txtSessionName.font]];
    // placeholder color
     UIColor *pClr = kColor(255, 255, 255, 0.3);

    [_txtSessionName setPlaceholderColor:pClr];
    _txtSessionName.tintColor = [UIColor whiteColor];
    
    
    UIBarButtonItem *lefttButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = lefttButton;

    
}

-(void)goBack{
    [self .navigationController popViewControllerAnimated:YES];
    
}
-(NSString *)removeNewLineAndWhiteSpace:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)refresh
{
    [self.view endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(RefreshBackUps)])
    {
        [self.delegate RefreshBackUps];
        self.delegate = nil;
    }
}

-(BOOL)isBkUpNameAlreadyExists
{
    BOOL isExists = NO;
    return isExists;
}

-(void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- IBoutlets

- (IBAction)cancelButtonClicked:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Are you sure you want to cancel?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                         {
                             [self dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action)
                          {
                              [PrefManager setBackUpStarted:NO];
                              for (Shout *sht in self.arrOfShoutsForBackUp)
                              {
                                  @autoreleasepool
                                  {
                                      [sht setIsBackup:[NSNumber numberWithBool:NO]];
                                  }
                              }
                              [DBManager save];
                              [self.view endEditing:YES];
                              [self.navigationController popViewControllerAnimated:YES];
                          }];
    
    [alert addAction:no];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    [LoaderView addLoaderToView:self.view];
    //back up name
    NSString *backUpName = [ self removeNewLineAndWhiteSpace:_txtSessionName.text];
    if (backUpName.length == 0)
    {
        backUpName = [self getDefaultBackUpName];
    }
    //back up name
    //validate bk name duplicacy only in case of adding
    if ([ShoutBackup isAlreadyShoutBackupWithName:backUpName] && !self.shoutBackUp)
    {
        [AppManager showAlertWithTitle:@"" Body:@"Backup name already exist."];
        [LoaderView removeLoader];
        return;
    }
    //validate bk up duplicaty
    //notes
    NSString *backUpNotes = [self removeNewLineAndWhiteSpace:_txtViewNotes.text];
    //notes
    //check if some thing change
    if ([self.shoutBackUp.backupNote isEqualToString:backUpNotes] && [self.shoutBackUp.backupName isEqualToString:backUpName])
    {
        //[self cancelButtonClicked:@""];
        [self cancelClicked];
        [LoaderView removeLoader];
        return;
    }
    //check if some thing change
    NSDate *date = [self getBackupDateTime];
    NSInteger bkId = [date timeIntervalSinceReferenceDate];
    if (self.shoutBackUp)
    {
        bkId = self.shoutBackUp.backupId.integerValue;
    }
    ShoutBackup *bck = [ShoutBackup ShoutBackupWithId:[NSString stringWithFormat:@"%ld", (long)bkId] shouldInsert:YES];
    bck.downloaded = [NSNumber numberWithBool:YES];
    if (self.shoutBackUp)
    {
        bck.synced = [NSNumber numberWithBool:NO];//when done button is clicked in back up edit then shout.synced is no
        bck.edited = [NSNumber numberWithBool:YES];
    }
    //back up name
    bck.backupName = backUpName;
    //back up name
    //notes
    bck.backupNote = backUpNotes;
    //notes
    ////back up date
    bck.backUpDate = [self getBackupDateTime];
    //back up date
    NSSet *set;
    NSArray *arrBackUp;
    BOOL isAdding;
    if (self.shoutBackUp)
    {
        arrBackUp = self.shoutBackUp.backupShouts.allObjects;
        set = [NSSet setWithArray:arrBackUp];
        isAdding = NO;
    }
    else
    {
        arrBackUp = self.arrOfShoutsForBackUp;
        set = [NSSet setWithArray:arrBackUp];
        isAdding = YES;
    }
    [bck addBackupShouts:set];
    [DBManager save];
    [BackUpManager ShoutsBackup:arrBackUp backup:bck onView:self.view isAdding:isAdding  andAutobackup:NO completion:^(BOOL status)
    {
        if (status) {
            NSArray *data = (NSArray *)bck.backupShouts;
            [ AppManager  addShoutsOnServer:data];
        }
        else
        {
            if ([AppManager isInternetShouldAlert:NO] == NO)
            {
                [AppManager showAlertWithTitle:@"" Body:@"Your backup will be saved locally. Internet is required to save your backup on cloud."];
                
            }
            else
                [AppManager showAlertWithTitle:@"" Body:@"Some error occured while saving your backup on cloud. Your backup will be saved locally."];
            
            }
        [self refresh];
        [self cancelClicked];
        [LoaderView removeLoader];
    }];
}

-(void)cancelClicked
{
    [PrefManager setBackUpStarted:NO];
    for (Shout *sht in self.arrOfShoutsForBackUp)
    {
        @autoreleasepool
        {
            [sht setIsBackup:[NSNumber numberWithBool:NO]];
        }
    }
    [DBManager save];
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark -Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField.text.length >= k_MAX_BACKUPNAME_LENGTH && ![string isEqualToString:@""]) {
        [AppManager showAlertWithTitle:@"Alert" Body:@"You have reached maximim limit"];
        return FALSE;
    }
    
    if([string  isEqual: @"\n"]){
        
        [textField resignFirstResponder];
    }
    return YES;
    
    
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if(textView.text.length >= k_MAX_SHOUT_LENGTH && ![text isEqualToString:@""]) {
        
        [AppManager showAlertWithTitle:@"Alert" Body:@"You have reached maximim limit"];
        return FALSE;
    }
    
    if([text  isEqual: @"\n"]){
        
        [textView resignFirstResponder];
        
        
    }
    return YES;
    
    
}

#pragma mark- Notifications Method

- (void)shoutArrived:(NSNotification *)notification
{
    [self checkCountOfShouts];
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

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict
{
    if (sht==nil)
    {
        //push to channel view controller
        
        ChanelViewController *channelVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ChanelViewController class])];
        [self.navigationController pushViewController:channelVC animated:YES];
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
