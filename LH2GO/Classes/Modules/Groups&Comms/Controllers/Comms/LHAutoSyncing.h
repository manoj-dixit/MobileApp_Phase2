//
//  LHAutoSyncing.h
//  LH2GO
//
//  Created by Kiwitech on 19/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFURLSessionManager.h>
@interface LHAutoSyncing : NSObject
+ (instancetype)shared;
-(void)autoSyncingShoutsWithcallback:(void (^)(BOOL success, NSError *error)) block;
-(void)autoSyncingShoutBackUp;

@property(nonatomic, strong) Group *myGroup;
@property BOOL isAutoSyncingInProgress;

@end
