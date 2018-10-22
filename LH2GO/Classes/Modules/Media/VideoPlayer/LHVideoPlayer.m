//
//  LHVideoPlayer.m
//  LH2GO
//
//  Created by Sumit Kumar on 22/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHVideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation LHVideoPlayer
+ (void)playVideoURL:(NSURL*)url onController:(UIViewController*)cont{
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [cont presentMoviePlayerViewControllerAnimated:moviePlayerController];
}
@end
