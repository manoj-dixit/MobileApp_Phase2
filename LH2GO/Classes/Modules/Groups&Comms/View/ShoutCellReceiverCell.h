//
//  ShoutCellReceiverCell.h
//  LH2GO
//
//  Created by Techbirds on 11/12/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"


// Enum (globaly used).
typedef enum {
    CellButtonReceiverTag_All = 1,
    CellButtonReceiverTag_Reply,
    CellButtonReceiverTag_Fav,
    CellButtonReceiverTag_Profile,
    CellButtonReceiverTag_Video,
    CellButtonReceiverTag_Audio,
    CellButtonReceiverTag_Image,
    CellButtonReceiverTag_Video_Export,
} CellButtonReceiverTag;


@protocol ShoutCellReceiverDelegate;
@interface ShoutCellReceiverCell : UITableViewCell
@property (nonatomic, assign) id <ShoutCellReceiverDelegate> delegate;

@property(nonatomic, weak) IBOutlet FLAnimatedImageView *_imgViewYGF;

+ (instancetype)cellWithType:(ShoutType)type shouldFade:(BOOL)shouldFade;
- (void)showShout:(Shout *)sh forChieldCell:(BOOL)isChield;
//- (UIImage*)getCellImage;
-(void)hideRebroadCastAndReply;
-(void)showFavOnly;
- (void)updateCellVisibility:(Shout*)sh;
-(void)setDateLabelForSessionInfo:(NSString *)str;
@end

@protocol ShoutCellReceiverDelegate <NSObject>
@optional
- (void)didClickReceiverButtonWithTag:(CellButtonReceiverTag)tag ForObject:(Shout*)sht;
@optional
- (void)removeShoutCellReceiverwithShoutInfo:(Shout *)sh;
@end


