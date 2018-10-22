//
//  ShoutCell.h
//  LH2GO
//
//  Created by Linchpin on 11/8/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"
// Enum (globaly used).
typedef enum {
    CellButtonTag_All = 1,
   CellButtonTag_Reply,
   CellButtonTag_Fav,
   CellButtonTag_Profile,
   CellButtonTag_Video,
   CellButtonTag_Audio,
   CellButtonTag_Image,
   CellButtonTag_Video_Export,
   CellButtonTag_Report

} CellButtonTag;


@protocol ShoutCellDelegate;
@interface ShoutCell : UITableViewCell
{
    //__weak IBOutlet UIButton *_btnReport;
}
@property (nonatomic, assign) id <ShoutCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *_btnReport;

@property(nonatomic, weak) IBOutlet FLAnimatedImageView *_imgViewYGF;
-(void)hideFavIcon;
+ (instancetype)cellWithType:(ShoutType)type shouldFade:(BOOL)shouldFade;
- (void)showShout:(Shout *)sh forChieldCell:(BOOL)isChield;
//- (UIImage*)getCellImage;
-(void)hideRebroadCastAndReply;
-(void)showFavOnly;
- (void)updateCellVisibility:(Shout*)sh;
-(void)setDateLabelForSessionInfo:(NSString *)str;
- (void)updateReportIcon;
-(void)changeTheReportIcon;
-(void)hideAllButtons;

@end

@protocol ShoutCellDelegate <NSObject>
@optional
- (void)didClickButtonWithTag:(CellButtonTag)tag ForObject:(Shout*)sht;
@optional
- (void)removeShoutCellwithShoutInfo:(Shout *)sh;
-(void)showAlertForReport:(Shout *)sh;
@end

