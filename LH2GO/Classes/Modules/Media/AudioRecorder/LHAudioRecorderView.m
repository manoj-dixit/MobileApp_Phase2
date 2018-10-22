//
//  LHAudioRecorderView.m
//  AudioDemo
//
//  Created by Sumit Kumar on 19/05/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "LHAudioRecorderView.h"
#import "LHCircularView.h"
#import "LHAudioRecorder.h"


@interface LHAudioRecorderView(){
    __weak IBOutlet UIButton *_btnRecordAndStop;
    __weak IBOutlet UIButton *_btnPlay;
    
    __weak IBOutlet UILabel *_lblProgressTime;
    __weak IBOutlet UILabel *_lblRecorded;
    __weak IBOutlet UILabel *_lblTimeClock;
    __weak IBOutlet LHCircularView *cirView;
}

@end

@implementation LHAudioRecorderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)audioView {
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil];
    LHAudioRecorderView *view = [objects objectAtIndex:0];
    
    return view;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeCircularView];
    [self initializeRecorder];
}

- (void)initializeCircularView{
    // Disable Stop/Play button when application launches
    cirView.strokeValueRed=0.0;
    cirView.strokeValueGreen=0.0;
    cirView.strokeValueBlue=0.0;
    cirView.strokeValueAlpha=1.0;
    cirView.progress=0.0;
    cirView.lineWidth=cirView.frame.size.width/2;
}

- (void)initializeRecorder{
//    [LHAudioRecorder shared].recordingDuration = kRecordingTime;//commented here as it was premature initialization
    _lblTimeClock.text = [NSString stringWithFormat:@"%0.0f Sec Clock",kAudioRecordingMaxTime];
    [_btnRecordAndStop setSelected:NO];
    [_btnPlay setHidden:YES];
    [_lblProgressTime setHidden:YES];
    [_lblRecorded setHidden:YES];
}

- (IBAction)recordAndStopButtonClicked:(id)sender{
    
    [_lblProgressTime setHidden:NO];
    [_lblRecorded setHidden:NO];
    [_lblTimeClock setHidden:YES];
    
    if ([LHAudioRecorder shared].playerStatus==Recording) {
        [[LHAudioRecorder shared] stopRecording];
    }
    else{
        [LHAudioRecorder shared].recordingDuration = kAudioRecordingMaxTime;//add here as it is right initialization
        [[LHAudioRecorder shared] recordingStart:self];
        if ([_delegate respondsToSelector:@selector(audioRecorderDidStartRecording)]) {
            [_delegate audioRecorderDidStartRecording];
        }
    }
}

- (IBAction)playRecordingButtonClicked:(id)sender{
    [[LHAudioRecorder shared] playRecordinhg];
}

#pragma mark - LHAudioRecorderDelegate

- (void)updateProgress:(NSTimeInterval)interval{
    cirView.hidden=NO;
    _lblRecorded.text=@"-  remaining";
    NSString *time = [NSString timeStringForTimeInterval:kAudioRecordingMaxTime-interval];
    if ([LHAudioRecorder shared].playerStatus==Recording)
    _lblProgressTime.text = time;
    //[NSString stringWithFormat:@"%@", time];
    cirView.progress = interval/kAudioRecordingMaxTime;
    if (cirView.progress>=1.0) {
        cirView.progress=0.9999;
        cirView.hidden=YES;
    }
    [cirView setNeedsDisplay];
}

- (void)audioRecorderDidFinishRecording:(NSURL*)url{
    _lblRecorded.text=@"-  recorded";
    NSString *time = [NSString timeStringForTimeInterval:[[LHAudioRecorder shared] getRecordedAudioTime]];
    _lblProgressTime.text = time;
    _audioURL = url;
    [_btnRecordAndStop setSelected:NO];
    [_btnPlay setHidden:NO];
    if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishRecording:)]) {
        [_delegate audioRecorderDidFinishRecording:url];
    }
}

- (void)audioPlayerDidFinishPlaying{
    if (cirView.progress>=0.99) {
        cirView.progress=0.9999;
        cirView.hidden=YES;
    }
}

- (void)recordingStateChange:(BOOL)isRecording{
    if (isRecording) {
        [_btnRecordAndStop setSelected:YES];
        [_btnPlay setHidden:YES];
    }
}

- (void)dealloc{
    [LHAudioRecorder shared].playerStatus = Stoped;
    [[LHAudioRecorder shared] stopRecording];
    [LHAudioRecorder shared].delegate=nil;
}
-(void)forceStopRecording
{
    [LHAudioRecorder shared].playerStatus = Stoped;
    [[LHAudioRecorder shared] stopRecording];
    [LHAudioRecorder shared].delegate=nil;
}
@end
