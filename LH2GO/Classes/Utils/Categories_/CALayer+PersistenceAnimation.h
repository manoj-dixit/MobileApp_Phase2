//
//  CALayer+PersistenceAnimation.h
//WooHoo
//
//  Created by Sumit Kumar on 23/11/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@interface CALayer (PersistenceAnimation)


@property (nonatomic, strong) NSArray *persistentAnimationKeys;

- (void)setCurrentAnimationsPersistent;

@end
