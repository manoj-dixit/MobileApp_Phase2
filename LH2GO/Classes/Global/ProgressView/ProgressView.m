//
//  ProgressView.m
//  progress
//
//  Created by Prakash Raj on 05/01/16.
//  Copyright © 2016 test. All rights reserved.
//

#import "ProgressView.h"
#import "CALayer+PersistenceAnimation.h"


#define kAnimationDuration 2.5

@interface ProgressView()
{
    __weak IBOutlet UIImageView *imgBar;
    __weak IBOutlet UIImageView *_imgProgress;
    __weak IBOutlet UIView *_progressLineView;
}
@end

@implementation ProgressView

- (void)setupView
{
    [self animateImages];
}

-(void)addProgress
{
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.duration=kAnimationDuration;
    theAnimation.repeatCount=INFINITY;
    theAnimation.fromValue=[NSNumber numberWithFloat:0];
    theAnimation.toValue=[NSNumber numberWithFloat:_progressLineView.frame.size.width];
    [_imgProgress.layer addAnimation:theAnimation forKey:@"animateLayer"];
    _imgProgress.layer.persistentAnimationKeys = @[@"animateLayer"];
}

#pragma mark - ImageArray

- (NSArray *)getImagesArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger index = 1; index <= 7; index++)
    {
        NSString *imageName = [NSString stringWithFormat:@"Progress%ld.png", (long)index];
        // Allocating images with imageWithContentsOfFile makes images to do not cache.
        UIImage *image = [UIImage imageNamed:imageName];
        [array addObject:(id)image.CGImage];
    }
    return array;
}

#pragma mark - AnimateImageArray

- (void)animateImages
{
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    keyframeAnimation.values = [self getImagesArray];
    keyframeAnimation.repeatCount = INFINITY;
    keyframeAnimation.duration = kAnimationDuration;
    keyframeAnimation.delegate = self;
    keyframeAnimation.removedOnCompletion = NO;
    keyframeAnimation.fillMode = kCAFillModeForwards;
    CALayer *layer = imgBar.layer;
    [layer addAnimation:keyframeAnimation forKey:@"girlAnimation"];
    layer.persistentAnimationKeys = @[@"girlAnimation"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        [imgBar removeFromSuperview];
        imgBar = nil;
        imgBar.image = [UIImage imageNamed:@"Progress1"];
        [imgBar.layer removeAnimationForKey:@"girlAnimation"];  // just in case
    }
}

@end
