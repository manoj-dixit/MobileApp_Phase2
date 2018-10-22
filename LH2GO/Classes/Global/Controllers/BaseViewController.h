//
//  BaseViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 16/02/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBar.h"
#import "SecondTabBar.h"
#import "REFrostedViewController.h"
#import "AdvanceSettingBottomView.h" // by nim
#import "Common.h"
#import "ChanelViewController.h"

static NSString *kUpdateGroupList     = @"kUpdateGroupListRequired";
static NSString *kActiveNetworkChange = @"kActiveNetworkChange";
extern BOOL validateUser;

@interface BaseViewController : UIViewController< UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating>
{
    NSString *movetoClassName;
    UIBarButtonItem * righttButton;
    UIBarButtonItem * leftButton;
    UISearchBar *searchBarGroup;
    
}
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, readonly) NSArray *searchResults;
@property (nonatomic, strong) NSMutableArray *blockedUsers;

@property (nonatomic,strong) NSOperationQueue *bleConnectionQueue;

   @property BOOL currentState;
+ (void)showLogin;
- (void)addTabbarWithTag : (BarItemTag)barTag;
-(void)checkCountOfShouts;
-(void)showCountOnChannelTab;
- (void)addSecondTabbarWithTag:(BarItem)barTag ;
- (CGFloat)tabHieght;
- (CGFloat)secondTabHeight;
- (void)presentLoginWithCompletion : (void(^)(BOOL sucess, NSError *error))block;
- (BOOL)checkVarification;
- (void)setLineColor: (NSInteger)barTag ;
- (void)setTabOneLineColor:(BarItemTag)barTag;
// on completion of login..
- (void)updateMe;
// on tabbar click..
- (void)refresh;
- (void)addRightButton;
- (void)addLefttButton;
-(void)addPanGesture;
- (void)addAdvanceSettingView; // by nim
-(void)showActionCount:(NSInteger)count;
-(void)showCountOfNotifications;
-(void)showCountOnNotificationsTab;
- (BOOL)isAlreadyInStack:(Class)myClass;
- (void)moveToVCClass:(NSString *)className;
- (UIViewController*)moveToChannel:(NSString *)className;
- (UIViewController*)getChannel:(NSString *)className;
- (UIViewController*)getTopVC;
- (void)popVC :(UIViewController*)vc;
- (void)setNavBarTitle;

@end
