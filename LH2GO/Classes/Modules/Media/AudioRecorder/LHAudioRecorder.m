//
//  LHAudioRecorder.m
//  AudioDemo
//
//  Created by Sumit Kumar on 17/05/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "LHAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

@implementation NSString (TimeString)

+(NSString*)timeStringForTimeInterval:(NSTimeInterval)timeInterval
{
    NSInteger ti = (NSInteger)timeInterval;
    float fl = timeInterval-ti;
    if (fl>=0.5) {
        ti+=1;
    }
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if (hours > 0)
    {
        return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        return  [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
    }
}

@end

@interface LHAudioRecorder()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    CADisplayLink *playProgressDisplayLink;
    BOOL _shouldShowRemainingTime;
    NSURL *outputFileURL;
    
    NSTimeInterval recordedAudioLength;
}

@end

@implementation LHAudioRecorder

+ (instancetype)shared {
    static LHAudioRecorder *_shRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shRecorder = [[LHAudioRecorder alloc] init];
        [_shRecorder createPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:_shRecorder selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:_shRecorder selector:@selector(appEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_shRecorder selector:@selector(appEnterForgroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:_shRecorder selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];

    });
    return _shRecorder;
}


- (void)createPlayer{
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
//    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
//    
//    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
//    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
//    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
                                    nil];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSettings error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    recordedAudioLength=0;
    [recorder prepareToRecord];
}

- (NSTimeInterval)getRecordedAudioTime{
    return recordedAudioLength;
}

-(void)updatePlayProgress
{
    if(_playerStatus==Recording&&[_delegate respondsToSelector:@selector(updateProgress:)]){
        [_delegate updateProgress:recorder.currentTime];
        if (_recordingDuration<=recorder.currentTime) {
            [self stopRecording];
            return;
        }
    }
    else if(_playerStatus==Playing&&[_delegate respondsToSelector:@selector(updateProgress:)]){
        [_delegate updateProgress:player.currentTime];
        if (_recordingDuration<=player.currentTime) {
            [self stopPlaying];
            return;
        }
    }
}

- (void)recordingStart:(id)delegate{
    recordedAudioLength=0;
    _delegate=delegate;
    [playProgressDisplayLink invalidate];
    playProgressDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePlayProgress)];
    [playProgressDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        // Start recording
        [recorder record];
        _playerStatus = Recording;
    }
    if ([_delegate respondsToSelector:@selector(recordingStateChange:)]) {
        [_delegate recordingStateChange:recorder.recording];
    };
}

- (void)pauseRecording {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        _playerStatus = Recording;
    } else {
        // Pause recording
        [recorder pause];
        _playerStatus = Stoped;
    }
    
    if ([_delegate respondsToSelector:@selector(recordingStateChange:)]) {
        [_delegate recordingStateChange:recorder.recording];
    };
}

- (void)stopRecording {
    recordedAudioLength = recorder.currentTime;
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    _playerStatus = Stoped;
    [playProgressDisplayLink invalidate];
    playProgressDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePlayProgress)];
    [playProgressDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)playRecordinhg {
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        _playerStatus=Playing;
    }
}

- (void)stopPlaying{
    if (player) {
        [player stop];
        player=nil;
        _playerStatus=Stoped;
    }
}

- (void)playAudioUrl:(NSURL*)url {
    [self stopPlaying];
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [player setDelegate:self];
        [player play];
        _playerStatus=Playing;
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    _playerStatus=Stoped;
    if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishRecording:)]) {
        [_delegate audioRecorderDidFinishRecording:outputFileURL];
    };
}

#pragma mark - AVAudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    _playerStatus=Stoped;
    if ([_delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying)]) {
        [_delegate audioPlayerDidFinishPlaying];
    };
}

- (void) onAudioSessionEvent: (NSNotification *) notification
{
    //Check the type of notification, especially if you are sending multiple AVAudioSession events here
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        NSLog(@"Interruption notification received!");
        
        //Check to see if it was a Begin interruption
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]&&_playerStatus == Recording) {
            NSLog(@"Interruption began!");
            [self stopRecording];
            _playerStatus=Stoped;
            if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishRecording:)]) {
                [_delegate audioRecorderDidFinishRecording:outputFileURL];
            };
        } else {
            NSLog(@"Interruption ended!");
            //Resume your audio
        }
    }
}

-(void)appEnterBackgroundNotification:(NSNotification*)note
{
}

-(void)appEnterForgroundNotification:(NSNotification*)note
{
    
}

-(void)appWillTerminate:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
}

@end
