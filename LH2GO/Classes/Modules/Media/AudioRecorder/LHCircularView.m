//
//  LHCircularView.m
//  AudioDemo
//
//  Created by Sumit Kumar on 17/05/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "LHCircularView.h"

@implementation LHCircularView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)drawRect:(CGRect)rect
{
//    CGRect allRect = self.bounds;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Draw background
//    CGContextSetRGBStrokeColor(context, self.strokeValueRed, self.strokeValueGreen, self.strokeValueBlue, self.strokeValueAlpha); // white
//    CGContextSetLineWidth(context, 5);
//    
//    // Draw progress
//    CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
//    CGFloat radius = (allRect.size.width - 4) / 2;
//    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
//    CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
//    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
//    CGContextStrokePath(context);
    
    // Drawing code
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Draw background
    CGContextSetRGBStrokeColor(context, self.strokeValueRed, self.strokeValueGreen, self.strokeValueBlue, 0.0); // white
    CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.0f); // translucent white
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextFillEllipseInRect(context, circleRect);
    CGContextStrokeEllipseInRect(context, circleRect);
    
    // Draw progress
    CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
    CGFloat radius = (allRect.size.width - 4) / 2;
    CGFloat endAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat startAngle = (self.progress * 2 * (float)M_PI) + endAngle;
    CGContextSetRGBFillColor(context, self.strokeValueRed, self.strokeValueGreen, self.strokeValueBlue, self.strokeValueAlpha); // white
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end
