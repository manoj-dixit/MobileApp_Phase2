//
//  LHVideoPlayer.h
//  LH2GO
//
//  Created by Sumit Kumar on 22/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LHVideoPlayer : NSObject
+ (void)playVideoURL:(NSURL*)url onController:(UIViewController*)cont;
@end
