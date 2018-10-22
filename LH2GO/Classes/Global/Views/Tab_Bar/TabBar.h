//
//  TabBar.h
//  PinMe
//
//  Created by @Ayush on 16/03/14.
//
//

#import <UIKit/UIKit.h>

// Enum (globaly used).
typedef enum
{   BarItemTag_Channel = 0,// by nim
    BarItemTag_Groups,
    BarItemTag_Sonar,
    BarItemTag_Wallet, // added by nim
    BarItemTag_Saved,
    BarItemTag_Setting,
    BarItemTag_None,
    BarItemTag_Search,
    BarItemTag_Notification
} BarItemTag;

@interface TabBar : UIView

+ (TabBar *)tabbarWithFrame:(CGRect)frame andSelectedTag:(BarItemTag)tag;
- (void)addTarget:(id)target andSelector:(SEL)selector;
- (void)tabButton:(BarItemTag)selectedItemTag;
- (void)setLineColor:(BarItemTag)selectedItemTag;
- (void)checkBadges;
- (void)showCount:(NSInteger)count;
-(void)showCountOnNotfTab;
-(void)showCountOnChlTab;
//@property (strong, nonatomic) IBOutlet UIImageView *tabbarImage;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nsConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sbConstarint;

@property (strong, nonatomic) IBOutlet UIView *vw_tab0;
@property (strong, nonatomic) IBOutlet UIView *vw_tab1;
@property (strong, nonatomic) IBOutlet UIView *vw_tab2;
@property (strong, nonatomic) IBOutlet UIView *vw_tab3;
@property (strong, nonatomic) IBOutlet UIView *vw_tab4;

@property (strong, nonatomic) IBOutlet UILabel *lbl_tab0;
@property (strong, nonatomic) IBOutlet UILabel *lbl_tab1;
@property (strong, nonatomic) IBOutlet UILabel *lbl_tab2;
@property (strong, nonatomic) IBOutlet UILabel *lbl_tab3;
@property (strong, nonatomic) IBOutlet UILabel *lbl_tab4;

@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab0;
@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab1;
@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab2;
@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab3;
@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab4;

@end
