//
//  LHAudioPlayerView.h
//  AudioPlayerTemplate
//
//  Created by Sumit Kumar on 21/05/15.
//  Copyright (c) 2015 ymc-thzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHAudioPlayerView : UIView
+ (instancetype)playerView;
- (void)setupAudioPlayer:(NSURL*)fileURL;
- (void)stopAudio;
@end
