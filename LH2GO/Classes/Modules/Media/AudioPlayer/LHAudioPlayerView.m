//
//  LHAudioPlayerView.m
//  AudioPlayerTemplate
//
//  Created by Sumit Kumar on 21/05/15.
//  Copyright (c) 2015 ymc-thzi. All rights reserved.
//

#import "LHAudioPlayerView.h"
#import "LHAudioPlayer.h"

@interface LHAudioPlayerView(){
    
}
@property (nonatomic, strong) LHAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UISlider *currentTimeSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsed;


@property BOOL isPaused;
@property BOOL scrubbing;

@property NSTimer *timer;
@end

@implementation LHAudioPlayerView


+ (instancetype)playerView {
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil];
    LHAudioPlayerView *view = [objects objectAtIndex:0];
    
    return view;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize{
    self.audioPlayer = [[LHAudioPlayer alloc] init];
    
    [_currentTimeSlider setThumbImage:[UIImage imageNamed:@"circle_slider"] forState:UIControlStateNormal];
    [_currentTimeSlider setTintColor:kColor(0, 173, 238, 1)];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"PauseAudioNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopAudio)
                                                 name:@"PauseAudioNotification"
                                               object:nil];
}

/*
 * Setup the AudioPlayer with
 * Filename and FileExtension like mp3
 * Loading audioFile and sets the time Labels
 */
- (void)setupAudioPlayer:(NSURL*)fileURL
{
    [self stopAudio];
    
    //init the Player to get file properties to set the time labels
    [self.audioPlayer initPlayer:fileURL];
    self.currentTimeSlider.maximumValue = [self.audioPlayer getAudioDuration];
    
    //init the current timedisplay and the labels. if a current time was stored
    //for this player then take it and update the time display
    self.timeElapsed.text = @"0:00";
    
    self.duration.text = [NSString stringWithFormat:@"-%@",
                          [self.audioPlayer timeFormat:[self.audioPlayer getAudioDuration]]];
    
}

/*
 * PlayButton is pressed
 * plays or pauses the audio and sets
 * the play/pause Text of the Button
 */
- (IBAction)playAudioPressed:(id)playButton
{
    [self.timer invalidate];
    //play audio for the first time or if pause was pressed
    if (!self.isPaused) {
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"audioplayer_pause.png"]
                                   forState:UIControlStateNormal];
        
        //start a timer to update the time label display
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(updateTime:)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"PauseAudioNotification"
         object:self];
        [self.audioPlayer playAudio];
        self.isPaused = TRUE;
    } else {
        //player is paused and Button is pressed again
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"audioplayer_play.png"]
                                   forState:UIControlStateNormal];
        
        [self.audioPlayer pauseAudio];
        self.isPaused = FALSE;
    }
}

- (void)stopAudio{
    if (self.isPaused) {
        [self.audioPlayer pauseAudio];
        self.isPaused = FALSE;
    }
}

/*
 * Updates the time label display and
 * the current value of the slider
 * while audio is playing
 */
- (void)updateTime:(NSTimer *)timer {
    //to don't update every second. When scrubber is mouseDown the the slider will not set
    if (!self.scrubbing) {
        self.currentTimeSlider.value = [self.audioPlayer getCurrentAudioTime];
    }
    self.timeElapsed.text = [NSString stringWithFormat:@"%@",
                             [self.audioPlayer timeFormat:[self.audioPlayer getCurrentAudioTime]]];
    
    self.duration.text = [NSString stringWithFormat:@"-%@",
                          [self.audioPlayer timeFormat:[self.audioPlayer getAudioDuration] - [self.audioPlayer getCurrentAudioTime]]];
    
    //When resetted/ended reset the playButton
    if (![self.audioPlayer isPlaying]) {
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"audioplayer_play.png"]
                                   forState:UIControlStateNormal];
        [self.audioPlayer pauseAudio];
        self.isPaused = FALSE;
    }
}

/*
 * Sets the current value of the slider/scrubber
 * to the audio file when slider/scrubber is used
 */
- (IBAction)setCurrentTime:(id)scrubber {
    //if scrubbing update the timestate, call updateTime faster not to wait a second and dont repeat it
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:NO];
    
    [self.audioPlayer setCurrentAudioTime:self.currentTimeSlider.value];
    self.scrubbing = FALSE;
}

/*
 * Sets if the user is scrubbing right now
 * to avoid slider update while dragging the slider
 */
- (IBAction)userIsScrubbing:(id)sender {
    self.scrubbing = TRUE;
}

- (void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
