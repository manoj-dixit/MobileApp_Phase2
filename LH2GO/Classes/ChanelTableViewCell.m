//
//  ChanelTableViewCell.m
//  LH2GO
//
//  Created by Linchpin on 6/17/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "ChanelTableViewCell.h"
#import "TimeConverter.h"
#import "EventLog.h"
#import "InternetCheck.h"
#import "SharedUtils.h"

@interface ChanelTableViewCell ()<APICallProtocolDelegate>
@end

@implementation ChanelTableViewCell:UITableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UITapGestureRecognizer *chanelImageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chanelImageTapped:)];
    chanelImageTapGesture.numberOfTapsRequired=1;
    [self addGestureRecognizer:chanelImageTapGesture];
    
    UITapGestureRecognizer  *coolViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coolViewTapped:)];
    coolViewGesture.numberOfTapsRequired=1;
    [_coolUserTapView addGestureRecognizer:coolViewGesture];
    
    UITapGestureRecognizer *contactViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contactViewTapped:)];
    contactViewGesture.numberOfTapsRequired=1;
    [_contactUserTapView addGestureRecognizer:contactViewGesture];
    
    _lblText.font = [_lblText.font fontWithSize:[Common setFontSize:_lblText.font]];
    _txtView.font = [_txtView.font fontWithSize:[Common setFontSize:_txtView.font]];
    _dateLabel.font = [_dateLabel.font fontWithSize:[Common setFontSize:_dateLabel.font]];
    _loadmoreBtn.titleLabel.font = [_loadmoreBtn.titleLabel.font fontWithSize:[Common setFontSize:_loadmoreBtn.titleLabel.font]];
    
    _txtView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    _coolLbl.font = [UIFont fontWithName:@"Aileron-Regular"  size:15];
    _contactLbl.font = [UIFont fontWithName:@"Aileron-Regular"  size:15];
    _shareLbl.font = [UIFont fontWithName:@"Aileron-Regular"  size:15];
}

-(void)chanelImageTapped:(UITapGestureRecognizer*)getureRecognizer
{
    ChanelTableViewCell *chanelCell = (ChanelTableViewCell*)getureRecognizer.view;
    NSInteger sectionOfCell = 0;
    if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))) {
        NSIndexPath *indexPathOfCell = [(UITableView *)[chanelCell superview] indexPathForCell:chanelCell];
        sectionOfCell = [indexPathOfCell row];
    }
    else{
        NSIndexPath *indexPathOfCell = [(UITableView*)[[chanelCell superview] superview] indexPathForCell:chanelCell];
        sectionOfCell = [indexPathOfCell row];
    }
    
    NSArray *totalChannelContent = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", [Global shared].currentChannel.channelId] descr:[NSSortDescriptor sortDescriptorWithKey:@"created_time" ascending:NO] isDistinctResults:YES];
    ChannelDetail *chanelDetail = [totalChannelContent objectAtIndex:sectionOfCell];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chanelImageTapped:)]) {
        [self.delegate chanelImageTapped:chanelDetail];
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
        
    
    NSArray *totalChannelContent = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", [Global shared].currentChannel.channelId] descr:[NSSortDescriptor sortDescriptorWithKey:@"created_time" ascending:NO] isDistinctResults:YES];
    ChannelDetail *chanelDetail = [totalChannelContent objectAtIndex:sectionOfCell];

    if ([_coolImageView.accessibilityIdentifier isEqualToString:@"cool_not_Selected"]) {
        _coolImageView.accessibilityIdentifier=@"cool_Selected";
        [_coolImageView setImage:[UIImage imageNamed:@"active_cool.png"]];
        chanelDetail.cool = YES;
        NSInteger coolCount = [chanelDetail.coolCount integerValue];
        coolCount++;
        NSNumber *coolValue = [NSNumber numberWithInteger:coolCount];
        chanelDetail.coolCount = coolValue;
        if(![chanelDetail.coolCount isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            chanelCell.coolLbl.text = [NSString stringWithFormat:@"%@ Cool",chanelDetail.coolCount];
        }
        else
            chanelCell.coolLbl.text = @"Cool";
        [self callSofKeysAPI:chanelDetail type:@"cool"];
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

    NSArray *totalChannelContent = [DBManager entities:@"ChannelDetail" pred:[NSString stringWithFormat:@"channelId = \"%@\" AND toBeDisplayed = YES", [Global shared].currentChannel.channelId] descr:[NSSortDescriptor sortDescriptorWithKey:@"created_time" ascending:NO] isDistinctResults:YES];
    ChannelDetail *chanelDetail = [totalChannelContent objectAtIndex:sectionOfCell];

    if ([_contactImageView.accessibilityIdentifier isEqualToString:@"contact_not_Selected"]) {
        _contactImageView.accessibilityIdentifier=@"contact_Selected";
        [_contactImageView setImage:[UIImage imageNamed:@"active_spark.png"]];
        chanelDetail.contact = YES;
        NSInteger contactCount = [chanelDetail.contactCount integerValue];
        contactCount++;
        NSNumber *contactValue = [NSNumber numberWithInteger:contactCount];
        chanelDetail.contactCount = contactValue;
        if(![chanelDetail.contactCount isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            chanelCell.contactLbl.text = [NSString stringWithFormat:@"%@ Contact",chanelDetail.contactCount];
        }
        else
            chanelCell.contactLbl.text = @"Contact";
        [AppManager showAlertWithTitle:@"" Body:@"Your Contact Request is under process."];
        [self callSofKeysAPI:chanelDetail type:@"contact"];
    }
    else{
        return;
         /*_contactImageView.accessibilityIdentifier=@"contact_not_Selected";
         [_contactImageView setImage:[UIImage imageNamed:@"inactive_spark.png"]];
         chanelDetail.contact = NO;*/
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

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
