//
//  SonarTracker.m
//  LH2GO
//
//  Created by Sumit Kumar on 03/02/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "SonarTracker.h"
#import "BLEManager.h"

@implementation SonarTracker


- (void)startSonarTracking
{
    [[BLEManager sharedManager].sonarTrackerQue setObject:self forKey:self.sonarId];
    [self performSelector:@selector(distroyTrackerObject) withObject:nil afterDelay:k_MAX_WAIT_TIME];
}

- (void)distroyTrackerObject
{
    [[BLEManager sharedManager].sonarTrackerQue removeObjectForKey:self.sonarId];
}

- (void)startSonarResponseTracking:(NSString*)responderId
{
    if (_responserIdList== nil)
    {
        _responserIdList=[[NSMutableArray alloc]init];
    }
    [_responserIdList addObject:responderId];
    [[BLEManager sharedManager].sonarTrackerResponseQue setObject:self forKey:self.sonarId];
    [self performSelector:@selector(distroyResponseTrackerObject) withObject:nil afterDelay:k_MAX_WAIT_TIME];
}

- (void)distroyResponseTrackerObject
{    
    [[BLEManager sharedManager].sonarTrackerResponseQue removeObjectForKey:self.sonarId];
}


@end
