//
//  LHAudioPlayer.h
//  AudioDemo
//
//  Created by Sumit Kumar on 17/05/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LHAudioPlayer : UIViewController

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

// Public methods
- (void)initPlayer:(NSURL*)audioFileLocationURL;
- (void)playAudio;
- (void)pauseAudio;
- (BOOL)isPlaying;
- (void)setCurrentAudioTime:(float)value;
- (float)getAudioDuration;
- (NSString*)timeFormat:(float)value;
- (NSTimeInterval)getCurrentAudioTime;
@end