//
//  LHAudioRecorderView.h
//  AudioDemo
//
//  Created by Sumit Kumar on 19/05/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LHAudioRecorderViewDelegate <NSObject>

@optional
- (void)audioRecorderDidStartRecording;
- (void)audioRecorderDidFinishRecording:(NSURL*)url;
@end

@interface LHAudioRecorderView : UIView
@property (nonatomic,copy)NSURL *audioURL;
@property (nonatomic, assign)id<LHAudioRecorderViewDelegate>delegate;
+ (instancetype)audioView;
-(void)forceStopRecording;
@end
