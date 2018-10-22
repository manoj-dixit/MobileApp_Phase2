//
//  LHAudioPlayer.m
//  AudioDemo
//
//  Created by Sumit Kumar on 17/05/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//


#import "LHAudioPlayer.h"

@implementation LHAudioPlayer


/*
 * Init the Player with Filename and FileExtension
 */
- (void)initPlayer:(NSURL*)audioFileLocationURL
{
    NSError *error;
    if (self.audioPlayer !=nil) {
        [self.audioPlayer stop];
        self.audioPlayer =nil;
    }
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    [AppManager configureAVAudioSession];
}

/*
 * Simply fire the play Event
 */
- (void)playAudio {
    [self.audioPlayer play];
}

/*
 * Simply fire the pause Event
 */
- (void)pauseAudio {
    [self.audioPlayer pause];
}

/*
 * get playingState
 */
- (BOOL)isPlaying {
    return [self.audioPlayer isPlaying];
}

/*
 * Format the float time values like duration
 * to format with minutes and seconds
 */
-(NSString*)timeFormat:(float)value{
    
    float minutes = floor(lroundf(value)/60);
    float seconds = lroundf(value) - (minutes * 60);
    
    int roundedSeconds = (int)lroundf(seconds);
    int roundedMinutes = (int)lroundf(minutes);
    
    NSString *time = [[NSString alloc]
                      initWithFormat:@"%d:%02d",
                      roundedMinutes, roundedSeconds];
    return time;
}

/*
 * To set the current Position of the
 * playing audio File
 */
- (void)setCurrentAudioTime:(float)value {
    [self.audioPlayer setCurrentTime:value];
}

/*
 * Get the time where audio is playing right now
 */
- (NSTimeInterval)getCurrentAudioTime {
    return [self.audioPlayer currentTime];
}

/*
 * Get the whole length of the audio file
 */
- (float)getAudioDuration {
    return [self.audioPlayer duration];
}


@end
