//
//  AttachmentPreviewCell.h
//  LH2GO
//
//  Created by Linchpin on 31/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHAudioPlayerView.h"
#import "ShoutCellReceiverCell.h"

@protocol AttachmentDelegate;

@interface AttachmentPreviewCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UIView *view_Audio;
@property (weak, nonatomic) IBOutlet UIView *view_Video;
@property (weak, nonatomic) IBOutlet UIImageView *ImageV_Audio;
@property (strong, nonatomic)  NSURL *videoUrl;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle_attch;
@property (nonatomic, assign) id <AttachmentDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *videoBtn;

- (void)addPlayer:(NSURL*)url;
-(void)playVideoInAttachment:(NSURL*)url;

@end

@protocol AttachmentDelegate <NSObject>

-(void)playVideo:(NSURL*)url;

@end
