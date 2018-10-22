//
//  TabBar.m
//  PinMe
//
//  Created by @Ayush on 16/03/14.
//
//

#import "TabBar.h"
#import "BadgeView.h"
#import "Common.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)


@interface TabBar ()
{
    __weak IBOutlet UIButton *_buttonItem1; //by nim//Channels
    __weak IBOutlet UIButton *_buttonItem2; //by nim// message
    __weak IBOutlet UIButton *_buttonItem3; // Sonar
    __weak IBOutlet UIButton *_buttonItem4; // Notification
    __weak IBOutlet UIButton *_buttonItem5; //
}

@property (nonatomic, assign) BarItemTag selectedItemTag;

@end

@implementation TabBar

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"TabBar" owner:self options:nil];
        UIView *mainView = (UIView *)[nibs objectAtIndex:0];
        [self addSubview:mainView];
        [mainView setFrame:self.bounds];
        [self checkFrame];
        
        if (IPAD)
        [self setFontSize];
    }
    return self;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    //[self setFontSize];
     // NSLog(@"%@",_buttonItem1);
}

-(void)setFontSize{
    _lbl_tab0.font = [_lbl_tab0.font fontWithSize:[Common setFontSize:_lbl_tab0.font]];
    _lbl_tab1.font = [_lbl_tab1.font fontWithSize:[Common setFontSize:_lbl_tab1.font]];
    _lbl_tab2.font = [_lbl_tab2.font fontWithSize:[Common setFontSize:_lbl_tab2.font]];
    _lbl_tab3.font = [_lbl_tab3.font fontWithSize:[Common setFontSize:_lbl_tab3.font]];
    _lbl_tab4.font = [_lbl_tab4.font fontWithSize:[Common setFontSize:_lbl_tab4.font]];

    
    _lblIcon_tab0.font = [_lblIcon_tab0.font fontWithSize:_lblIcon_tab0.font.pointSize + 2];
    _lblIcon_tab1.font = [_lblIcon_tab1.font fontWithSize:_lblIcon_tab1.font.pointSize + 2];
    _lblIcon_tab2.font = [_lblIcon_tab2.font fontWithSize:_lblIcon_tab2.font.pointSize + 2];
    _lblIcon_tab3.font = [_lblIcon_tab3.font fontWithSize:_lblIcon_tab3.font.pointSize + 2];
    _lblIcon_tab4.font = [_lblIcon_tab4.font fontWithSize:_lblIcon_tab4.font.pointSize + 2];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
   // NSLog(@"%@",_buttonItem1);
}

- (void)checkFrame
{
    if(IS_IPHONE_4_OR_LESS)
    {
        DLog(@"IS_IPHONE_4_OR_LESS");
    }
    if(IS_IPHONE_5)
    {
        DLog(@"IS_IPHONE_5");
    }
    else
    {
//        _nsConstraint.constant = 48;
//        _sbConstarint.constant = 55;
    }
}


+ (TabBar *)tabbarWithFrame:(CGRect)frame andSelectedTag:(BarItemTag)tag
{
    TabBar *tabbar = [[TabBar alloc] initWithFrame:frame];
    [tabbar tabButton:tag];
    return tabbar;
}

- (void)setSelectedItemTag:(BarItemTag)selectedItemTag
{
    [_buttonItem1 setSelected:(selectedItemTag == BarItemTag_Groups)];
    [_buttonItem2 setSelected:(selectedItemTag == BarItemTag_Channel)];
    [_buttonItem3 setSelected:(selectedItemTag == BarItemTag_Sonar)];
    [_buttonItem3 setSelected:(selectedItemTag == BarItemTag_Wallet)];
    [_buttonItem4 setSelected:(selectedItemTag == BarItemTag_Search)];

//    [_buttonItem4 setSelected:(selectedItemTag == BarItemTag_Saved)];
//    [_buttonItem5 setSelected:(selectedItemTag == BarItemTag_Setting)];
}

- (void)addTarget:(id)target andSelector:(SEL)selector
{
     [_buttonItem1 addTarget : target action : selector
            forControlEvents : UIControlEventTouchUpInside];
     [_buttonItem2 addTarget : target action : selector
            forControlEvents : UIControlEventTouchUpInside];
     [_buttonItem3 addTarget : target action : selector
            forControlEvents : UIControlEventTouchUpInside];
     [_buttonItem4 addTarget : target action : selector
            forControlEvents : UIControlEventTouchUpInside];
     [_buttonItem5 addTarget : target action : selector
            forControlEvents : UIControlEventTouchUpInside];
}

- (void)checkBadges
{
    Global *shared = [Global shared];
    NSInteger unreadShoutsCount =[DBManager getTotalReceivedShoutsFromShoutsTable:shared.currentUser.user_id]; //[DBManager getUnresdShoutsCount];
    [BadgeView addBadge:unreadShoutsCount toView:_lblIcon_tab1 inCorner:badgeCorner_TopDefault marginX:_lblIcon_tab1.frame.size.width/2-(_lblIcon_tab1.font.pointSize/2 +10) marginY:0];
}

- (void)showCount:(NSInteger)count
{
    [BadgeView addBadge:count toView:_lblIcon_tab3 inCorner:badgeCorner_TopDefault marginX:_lblIcon_tab3.frame.size.width/2-(_lblIcon_tab3.font.pointSize/2 + 10) marginY:0];
}

-(void)showCountOnNotfTab
{
    NSInteger unreadCountOfNotif =  12;//[[NSUserDefaults standardUserDefaults]integerForKey:k_NotifTabCount];//[AppManager getUnreadNotification];
    
    [BadgeView addBadge:unreadCountOfNotif toView:_lblIcon_tab3 inCorner:badgeCorner_TopDefault marginX:_lblIcon_tab3.frame.size.width/2-(_lblIcon_tab3.font.pointSize/2 + 10) marginY:0];
    

   
}

- (void)setLineColor:(BarItemTag)selectedItemTag
{
    //[_tabbarImage setHidden:YES];
    switch (selectedItemTag)
    {
        case BarItemTag_Groups: { //1
           // [_buttonItem1 setImage:[UIImage imageNamed:@"messagecolor.png"] forState:UIControlStateNormal];
            
        } break;
            
        case BarItemTag_Channel: // 0 by nim
        {
            //[_tabbarImage setHidden:NO];
           // [_tabbarImage setImage:[UIImage imageNamed:@"orangeline.png"]];
        } break;
        case BarItemTag_Sonar: //2
        {
           // [_tabbarImage setHidden:NO];
           // [_tabbarImage setImage:[UIImage imageNamed:@"yellowline.png"]];
        } break;
        case BarItemTag_Saved:
        {
           // [_tabbarImage setHidden:NO];
//[_tabbarImage setImage:[UIImage imageNamed:@"blueline.png"]];
        } break;
        case BarItemTag_None:
        {
            // [_buttonItem1 setBackgroundImage:[UIImage imageNamed:@"message.png"] forState:UIControlStateNormal];
        }break;
        case BarItemTag_Setting:
        {
            //[_tabbarImage setHidden:NO];
           // [_tabbarImage setImage:[UIImage imageNamed:@"whiteline.png"]];

        }break;
        default: break;
    }
    
}

- (void)tabButton:(BarItemTag)selectedItemTag
{
    UIColor *selected_color = [Common colorwithHexString:tabBarSelectedcolor alpha:1];

    [self resetAllTabs];
    switch (selectedItemTag)
    {
        case BarItemTag_Channel: //0
        {
            _lblIcon_tab0.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            _lbl_tab0.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            [_lblIcon_tab1 setText:@"e"];
            [_lblIcon_tab1 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab2 setText:@"n"];
            [_lblIcon_tab2 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab3 setText:@"8"];
            [_lblIcon_tab3 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab4 setText:@"g"];
            [_lblIcon_tab4 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            
        } break;
        case BarItemTag_Groups://1
        {
            _lblIcon_tab1.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            _lbl_tab1.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            [_lblIcon_tab0 setText:@"k"];
            [_lblIcon_tab0 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab1 setText:@"!"];
            [_lblIcon_tab1 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab2 setText:@"n"];
            [_lblIcon_tab2 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab3 setText:@"8"];
            [_lblIcon_tab3 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab4 setText:@"g"];
            [_lblIcon_tab4 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            
        } break;
        
        case BarItemTag_Sonar: //2
        {
            _lblIcon_tab2.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            _lbl_tab2.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            
            [_lblIcon_tab0 setText:@"k"];
            [_lblIcon_tab0 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab1 setText:@"e"];
            [_lblIcon_tab1 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab2 setText:@"9"];
            [_lblIcon_tab2 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab3 setText:@"8"];
            [_lblIcon_tab3 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab4 setText:@"g"];
            [_lblIcon_tab4 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
        } break;
        case BarItemTag_Wallet: //3
        {
            _lblIcon_tab3.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            _lbl_tab3.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            
            
            [_lblIcon_tab0 setText:@"k"];
            [_lblIcon_tab0 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab1 setText:@"e"];
            [_lblIcon_tab1 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab2 setText:@"9"];
            [_lblIcon_tab2 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab3 setText:@"7"];
            [_lblIcon_tab3 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab4 setText:@"g"];
            [_lblIcon_tab4 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
        } break;
        case BarItemTag_Saved:
        {
           // [_buttonItem4 setImage:[UIImage imageNamed:@"backupcolor.png"] forState:UIControlStateNormal];
        } break;
        case BarItemTag_None:
        {
           // [_buttonItem1 setBackgroundImage:[UIImage imageNamed:@"message.png"] forState:UIControlStateNormal];
        }
            break;
        case BarItemTag_Setting:
        {
            [_lblIcon_tab0 setText:@"k"];
            [_lblIcon_tab0 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab1 setText:@"e"];
            [_lblIcon_tab1 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab2 setText:@"n"];
            [_lblIcon_tab2 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab3 setText:@"8"];
            [_lblIcon_tab3 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab4 setText:@"g"];
            [_lblIcon_tab4 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            
        }break;
            
        case BarItemTag_Search:
        {
            _lblIcon_tab4.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            _lbl_tab4.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            
            [_lblIcon_tab0 setText:@"k"];
            [_lblIcon_tab0 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab1 setText:@"e"];
            [_lblIcon_tab1 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab2 setText:@"9"];
            [_lblIcon_tab2 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab3 setText:@"8"];
            [_lblIcon_tab3 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab4 setText:@"\""];
            [_lblIcon_tab4 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            
        }break;
        case BarItemTag_Notification:
        {
            _lblIcon_tab1.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            _lbl_tab1.textColor=[UIColor colorWithRed:(133.0f/225.0f) green:(189.0f/225.0f) blue:(64.0f/225.0f) alpha:1.0];
            [_lblIcon_tab0 setText:@"k"];
            [_lblIcon_tab0 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab1 setText:@"!"];
            [_lblIcon_tab1 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab2 setText:@"n"];
            [_lblIcon_tab2 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab3 setText:@"8"];
            [_lblIcon_tab3 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
            [_lblIcon_tab4 setText:@"g"];
            [_lblIcon_tab4 setFont:[UIFont fontWithName:@"loudhailer" size:20]];
        }break;
        default: break;
    }
}
-(void)resetAllTabs{
    UIColor *unselected_color = [Common colorwithHexString:tabBarUnSelectedcolor alpha:1];

    _vw_tab0.backgroundColor = unselected_color;
    _vw_tab1.backgroundColor = unselected_color;
    _vw_tab2.backgroundColor = unselected_color;
    _vw_tab3.backgroundColor = unselected_color;
    _vw_tab4.backgroundColor = unselected_color;

    
}

-(void)showCountOnChlTab
{
    NSInteger unreadCountOfNotif = [DBManager getUnreadChannelContentCount];
    [BadgeView addBadge:unreadCountOfNotif toView:_lblIcon_tab0 inCorner:badgeCorner_TopDefault marginX:_lblIcon_tab0.frame.size.width/2-(_lblIcon_tab0.font.pointSize/2 + 10) marginY:0];
}

@end
