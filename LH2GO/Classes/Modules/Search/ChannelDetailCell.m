//
//  ChannelDetailCell.m
//  LH2GO
//
//  Created by Parul Mankotia on 02/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "ChannelDetailCell.h"

@implementation ChannelDetailCell

+ (instancetype)cellAtIndex:(NSInteger)index
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ChannelDetailCell" owner:self options:nil];
    ChannelDetailCell *cell = [objects objectAtIndex:index];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _channelIconImageView.layer.cornerRadius = _channelIconImageView.frame.size.width/2;
    _channelIconImageView.layer.masksToBounds = YES;
        
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    
    UITapGestureRecognizer *chanelImageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chanelImageTapped:)];
    chanelImageTapGesture.numberOfTapsRequired=1;
    [self addGestureRecognizer:chanelImageTapGesture];
    
    UITapGestureRecognizer  *coolViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coolViewTapped:)];
    coolViewGesture.numberOfTapsRequired=1;
    [_coolView addGestureRecognizer:coolViewGesture];
    
    UITapGestureRecognizer *contactViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contactViewTapped:)];
    contactViewGesture.numberOfTapsRequired=1;
    [_contactView addGestureRecognizer:contactViewGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark-
#pragma mark- Button Action Methods
-(IBAction)reportAbuseButton:(UIButton*)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Content" message:@"Do you want to mark this content as abusive/inappropriate?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
        [LoaderView addLoaderToView:self];
        [self reportToAdminForContent:_channelDetail];
        _channelDetail.toBeDisplayed = NO;
        [DBManager save];

        if ([self delegate] && [self.delegate respondsToSelector:@selector(refreshData)]) {
            [self.delegate refreshData];
            [LoaderView removeLoader];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action){
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    NSArray *allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
    if ([[allVc lastObject] isKindOfClass:[ChanelViewController class]]) {
        [[allVc lastObject] presentViewController:alert animated:YES completion:nil];
    }
    else if ([[allVc lastObject] isKindOfClass:[ChannelDetailViewController class]]){
        [[allVc lastObject] presentViewController:alert animated:YES completion:nil];
    }
}

-(void)reportToAdminForContent:(ChannelDetail*)channelData{
    int timeStamp = (int)[TimeConverter timeStamp];
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.loud_hailerid,@"loudhailer_id",channelData.channelId,@"channel_id",channelData.contentId,@"content_id",nil];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",channelData.contentId],@"channelContentId",channelData.channelId,@"channelId",@"offendedcontent",@"text",nil];
    
    NSMutableDictionary *postDictionary1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_report_content",@"log_sub_category",channelData.channelId,@"channelId",[NSString stringWithFormat:@"%@",channelData.contentId],@"channelContentId",@"offendedcontent",@"text",channelData.channelId,@"category_id",detaildict,@"details",nil];
    
    [AppManager saveEventLogInArray:postDictionary1];
    if ([AppManager isInternetShouldAlert:YES])
    {
        NSString *urlString =[NSString stringWithFormat:@"%@%@",BASE_API_URL,REPORT_CHANNEL_CONTENT];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
    }
}

-(void)chanelImageTapped:(UITapGestureRecognizer*)getureRecognizer
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ChannelDetailCell *chanelCell = (ChannelDetailCell*)getureRecognizer.view;
        NSInteger rowForCell = 0;
        if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))) {
            NSIndexPath *indexPathOfCell = [(UITableView *)[chanelCell superview] indexPathForCell:chanelCell];
            rowForCell = [indexPathOfCell row];
        }
        else{
            NSIndexPath *indexPathOfCell = [(UITableView*)[[chanelCell superview] superview] indexPathForCell:chanelCell];
            rowForCell = [indexPathOfCell row];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(chanelImageTappedOnCell:)]) {
            [self.delegate chanelImageTappedOnCell:_channelDetail];
        }
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(saveTappedForChannelImageOnCell:)]) {
            [self.delegate saveTappedForChannelImageOnCell:_channelDetail];
        }
    }]];
    
    NSArray *allVc = [(UINavigationController *)[((REFrostedViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)contentViewController] viewControllers];
    if ([[allVc lastObject] isKindOfClass:[ChanelViewController class]]) {
        [[allVc lastObject] presentViewController:actionSheet animated:YES completion:nil];
    }
    else if ([[allVc lastObject] isKindOfClass:[ChannelDetailViewController class]]){
        [[allVc lastObject] presentViewController:actionSheet animated:YES completion:nil];
    }

}

-(void)coolViewTapped:(UITapGestureRecognizer*)getureRecognizer{
    UIView *tappedView = (UIView*)[getureRecognizer.view superview];
    ChanelTableViewCell *chanelCell =(ChanelTableViewCell *)[(UITableViewCell *)[tappedView superview] superview];
    NSInteger sectionOfCell = 0;
    if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))) {
        NSIndexPath *indexPathOfCell = [(UITableView *)[chanelCell superview] indexPathForCell:chanelCell];
        sectionOfCell = [indexPathOfCell row];
    }
    else{
        NSIndexPath *indexPathOfCell = [(UITableView*)[[chanelCell superview] superview] indexPathForCell:chanelCell];
        sectionOfCell = [indexPathOfCell row];
    }
    
    if ([_coolView.accessibilityIdentifier isEqualToString:@"cool_not_Selected"]) {
        _coolView.accessibilityIdentifier=@"cool_Selected";
        _coolColorLabel.textColor = [UIColor colorWithRed:(229.0f/255.0f) green:(0.0f/255.0f) blue:(28.0f/255.0f) alpha:1.0];
        _channelDetail.cool = YES;
        NSInteger coolCount = [_channelDetail.coolCount integerValue];
        coolCount++;
        NSNumber *coolValue = [NSNumber numberWithInteger:coolCount];
        _channelDetail.coolCount = coolValue;
        if(![_channelDetail.coolCount isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            _coolNumberLabel.text = [NSString stringWithFormat:@"%@ Cool",_channelDetail.coolCount];
        }
        else
            _coolNumberLabel.text = @"Cool";
        [self callSofKeysAPI:_channelDetail type:@"cool"];
    }
    else{
        return;
        /* _coolImageView.accessibilityIdentifier=@"cool_not_Selected";
         [_coolImageView setImage:[UIImage imageNamed:@"inactive_cool.png"]];
         chanelDetail.cool = NO;*/
    }
}

-(void)contactViewTapped:(UITapGestureRecognizer*)getureRecognizer{
    UIView *tappedView = (UIView*)[getureRecognizer.view superview];
    ChanelTableViewCell *chanelCell =(ChanelTableViewCell *)[(UITableViewCell *)[tappedView superview] superview];
    NSInteger sectionOfCell = 0;
    if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))) {
        NSIndexPath *indexPathOfCell = [(UITableView *)[chanelCell superview] indexPathForCell:chanelCell];
        sectionOfCell = [indexPathOfCell row];
    }
    else{
        NSIndexPath *indexPathOfCell = [(UITableView*)[[chanelCell superview] superview] indexPathForCell:chanelCell];
        sectionOfCell = [indexPathOfCell row];
    }
    
    if ([_contactView.accessibilityIdentifier isEqualToString:@"contact_not_Selected"]) {
        _contactView.accessibilityIdentifier=@"contact_Selected";
        _contactColorLabel.textColor = [UIColor colorWithRed:(245.0f/255.0f) green:(187.0f/255.0f) blue:(66.0f/255.0f) alpha:1.0];
        _channelDetail.contact = YES;
        NSInteger contactCount = [_channelDetail.contactCount integerValue];
        contactCount++;
        NSNumber *contactValue = [NSNumber numberWithInteger:contactCount];
        _channelDetail.contactCount = contactValue;
        if(![_channelDetail.contactCount isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            _contactNumberLabel.text = [NSString stringWithFormat:@"%@ Contact",_channelDetail.contactCount];
        }
        else
            _contactNumberLabel.text = @"Contact";
        [AppManager showAlertWithTitle:@"" Body:@"Your Contact Request is under process."];
        [self callSofKeysAPI:_channelDetail type:@"contact"];
    }
    else{
        return;
        /*_contactImageView.accessibilityIdentifier=@"contact_not_Selected";
         [_contactImageView setImage:[UIImage imageNamed:@"inactive_spark.png"]];
         chanelDetail.contact = NO;*/
    }
    
}

//method is the class which calls the post API for type=cool and type=contact 
-(void)callSofKeysAPI:(ChannelDetail*)channelDetail type:(NSString*)type{
    int timeStamp = (int)[TimeConverter timeStamp];
    
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",[Global shared].currentChannel.channelId,@"channel_id"
                                           ,channelDetail.contentId,@"content_id",[NSString stringWithFormat:@"%d",timeStamp],@"timestamp",type,@"type",nil];
    
    NSMutableDictionary *detaildict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"selectSoftKey",@"text",nil];
    NSMutableDictionary *postDictionaryEventLog = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",[NSString stringWithFormat:@"on_click_%@",type],@"log_sub_category",[Global shared].currentChannel.channelId,@"channelId",channelDetail.contentId,@"channelContentId",@"selectSoftKey",@"text",[Global shared].currentChannel.channelId,@"category_id",detaildict,@"details",nil];
    [AppManager saveEventLogInArray:postDictionaryEventLog];
    
    BOOL isConnected = [[InternetCheck sharedInstance] internetWorking];
    if (isConnected)
    {
        SharedUtils *sharedUtils = nil;
        sharedUtils = [[SharedUtils alloc] init];
        sharedUtils.delegate = self;
        NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,CHANNELCONTENTTYPE];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:urlString];
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

// the response call back for post request. The call back manages code for cool and contact request of user and send an acknowledgment back to the user via pop up.
- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    BOOL status;
    if(responseDict != nil)
    {
        status = [[responseDict objectForKey:@"status"]boolValue];
        if(status)
        {
            NSString *message = [responseDict objectForKey:@"message"];
            if([message isEqualToString:@"Channel cool saved successfully.!"]){
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"testDefault"];
                [App_delegate.softKeyActionArray removeAllObjects];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSoftKeyAction];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else if([message isEqualToString:@"Channel contact saved successfully.!"])
            {
                [AppManager showAlertWithTitle:@"Acknowledgement" Body:@"Your contact request has been processed, admin will contact you within 24 hours."];
            }
            else if([message isEqualToString:@"Channel share saved successfully.!"])
            {
                [AppManager showAlertWithTitle:@"" Body:@"Coming Soon"];
            }
        }
    }
}

@end
