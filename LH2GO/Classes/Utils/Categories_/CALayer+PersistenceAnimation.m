//
//  CALayer+PersistenceAnimation.m
//WooHoo
//
//  Created by Sumit Kumar on 23/11/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <objc/runtime.h>
#import "CALayer+PersistenceAnimation.h"


@interface PersistentAnimationContainer : NSObject
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, copy) NSArray *persistentAnimationKeys;
@property (nonatomic, copy) NSDictionary *persistedAnimations;
- (id)initWithLayer:(CALayer *)layer;
@end


@interface CALayer (PersistenceAnimationPrivate)
@property (nonatomic, strong) PersistentAnimationContainer *animationContainer;
@end


@implementation CALayer (PersistenceAnimation)

#pragma mark - Public

- (NSArray *)persistentAnimationKeys {
    return self.animationContainer.persistentAnimationKeys;
}

- (void)setPersistentAnimationKeys:(NSArray *)persistentAnimationKeys {
    PersistentAnimationContainer *container = [self animationContainer];
    if (!container) {
        container = [[PersistentAnimationContainer alloc] initWithLayer:self];
        [self setAnimationContainer:container];
    }
    container.persistentAnimationKeys = persistentAnimationKeys;
}

- (void)setCurrentAnimationsPersistent {
    self.persistentAnimationKeys = [self animationKeys];
}

#pragma mark - Associated objects

- (void)setAnimationContainer:(PersistentAnimationContainer *)animationContainer {
    objc_setAssociatedObject(self, @selector(animationContainer), animationContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PersistentAnimationContainer *)animationContainer {
    return objc_getAssociatedObject(self, @selector(animationContainer));
}

#pragma mark - Pause and resume

- (void)pauseLayer {
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0;
    self.timeOffset = pausedTime;
}

- (void)resumeLayer {
    CFTimeInterval pausedTime = [self timeOffset];
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeSincePause;
}

@end

@implementation PersistentAnimationContainer

#pragma mark - Lifecycle

- (id)initWithLayer:(CALayer *)layer {
    self = [super init];
    if (self) {
        _layer = layer;
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromAppStateNotifications];
}

#pragma mark - Keys

- (void)setPersistentAnimationKeys:(NSArray *)persistentAnimationKeys {
    if (persistentAnimationKeys != _persistentAnimationKeys) {
        if (!_persistentAnimationKeys) {
            [self registerForAppStateNotifications];
        } else if (!persistentAnimationKeys) {
            [self unregisterFromAppStateNotifications];
        }
        _persistentAnimationKeys = persistentAnimationKeys;
    }
}

#pragma mark - Persistence

- (void)persistLayerAnimationsAndPause {
    CALayer *layer = self.layer;
    if (!layer) {
        return;
    }
    NSMutableDictionary *animations = [NSMutableDictionary new];
    for (NSString *key in self.persistentAnimationKeys) {
        CAAnimation *animation = [layer animationForKey:key];
        if (animation) {
            animations[key] = animation;
        }
    }
    if (animations.count > 0) {
        self.persistedAnimations = animations;
        [layer pauseLayer];
    }
}

- (void)restoreLayerAnimationsAndResume {
    CALayer *layer = self.layer;
    if (!layer) {
        return;
    }
    [self.persistedAnimations enumerateKeysAndObjectsUsingBlock:^(NSString *key, CAAnimation *animation, BOOL *stop) {
        [layer addAnimation:animation forKey:key];
    }];
    if (self.persistedAnimations.count > 0) {
        [layer resumeLayer];
    }
    self.persistedAnimations = nil;
}

#pragma mark - Notifications

- (void)registerForAppStateNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)unregisterFromAppStateNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground {
    [self persistLayerAnimationsAndPause];
}

- (void)applicationWillEnterForeground {
    [self restoreLayerAnimationsAndResume];
}

@end
