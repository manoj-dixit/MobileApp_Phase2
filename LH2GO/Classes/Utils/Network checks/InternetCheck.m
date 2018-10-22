//
//  InternetCheck.m
//  Kloof
//
//  Created by Sachin Kamboj on 21/05/13.
//  Copyright (c) 2013 Segment technologies. All rights reserved.
//

#import "InternetCheck.h"
#import "Reachability.h"

@implementation InternetCheck

+ (InternetCheck*) sharedInstance {
    
    static InternetCheck *instance = nil;
    if (!instance) {
        @synchronized (self) {
                instance = [[InternetCheck alloc] init];
        }
    }
    return instance;
}

@end
