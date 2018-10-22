//
//  LHAudioRecorder.h
//  AudioDemo
//
//  Created by Sumit Kumar on 17/05/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PlayerState{
    Stoped,
    Recording,
    Playing,
    Pause,
}PlayerState;

@protocol LHAudioRecorderDelegate <NSObject>

@optional
- (void)audioRecorderDidFinishRecording:(NSURL*)url;
- (void)audioPlayerDidFinishPlaying;
- (void)recordingStateChange:(BOOL)isPaused;
- (void)updateProgress:(NSTimeInterval)interval;
@end

@interface LHAudioRecorder : NSObject
@property (nonatomic, assign)id<LHAudioRecorderDelegate>delegate;
@property (nonatomic, assign)NSTimeInterval recordingDuration;
@property (nonatomic, assign)PlayerState playerStatus;
+ (instancetype)shared;
- (void)recordingStart:(id)delegate;
- (void)stopRecording;
- (void)playRecordinhg;
- (void)playAudioUrl:(NSURL*)url;
- (NSTimeInterval)getRecordedAudioTime;
- (void)createPlayer;
@end

@interface NSString (TimeString)

+(NSString*)timeStringForTimeInterval:(NSTimeInterval)timeInterval;

@end
