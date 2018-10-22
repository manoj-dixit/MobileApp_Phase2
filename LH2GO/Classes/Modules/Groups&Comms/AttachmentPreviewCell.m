//
//  AttachmentPreviewCell.m
//  LH2GO
//
//  Created by Linchpin on 31/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "AttachmentPreviewCell.h"

@interface AttachmentPreviewCell (){
   
    LHAudioPlayerView *player;
 
}

@end

@implementation AttachmentPreviewCell
@synthesize delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    

    _ImageV_Audio.layer.cornerRadius = 4.0;
    _ImageV_Audio.layer.masksToBounds = true;
    
 }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addPlayer:(NSURL*)url
{
    if(player == nil)
    {
        player = [LHAudioPlayerView playerView];
        
         CGRect rect1 =  CGRectMake(self.frame.size.width/2+10, _view_Audio.frame.size.height/2 - 20 , self.frame.size.width/2+20, 50);
        
            player.frame = rect1;
    
        [self addSubview:player];
    }
    
    player.hidden = NO;
    
    [player setupAudioPlayer:url];
    
}

- (IBAction)videoPlay:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(playVideo:)]){
        [delegate playVideo:_videoUrl];
        
    }
}

-(void)playVideoInAttachment:(NSURL *)url{}


@end
