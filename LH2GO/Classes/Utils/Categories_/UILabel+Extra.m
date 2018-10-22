//
//  UILabel+Extra.m
//  Test
//
//  Created by Prakash Raj on 30/01/14.
//  Copyright (c) 2014 Raj. All rights reserved.
//

#import "UILabel+Extra.h"
#import "NSString+Addition.h"

@implementation UILabel (Extra)

- (void)setFrameAsTextStickToWidth:(CGFloat)sWidth {
    [self setFrameAsTextStickToWidth:sWidth andHeight:MAXFLOAT];
}

- (void)setFrameAsTextStickToHeight:(CGFloat)sHeight {
    [self setFrameAsTextStickToWidth:MAXFLOAT andHeight:sHeight];
}

- (void)setFrameAsTextStickToWidth:(CGFloat)sWidth andHeight:(CGFloat)sHeight {
   
    CGSize sz = [self.text actualSizeWithFont:self.font stickToWidth:sWidth andHeight:sHeight];
    DLog(@"%f %f", sz.height, sz.width);
    
    CGRect frame = self.frame;
    frame.size.width  =  sz.width+5;
    frame.size.height =  sz.height+5;
    self.frame = frame;
}

- (void)boldRange:(NSRange)range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText;
    if (!self.attributedText) {
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    } else {
        attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font.pointSize]} range:range];
    self.attributedText = attributedText;
}

- (void)boldSubstring:(NSString*)substring {
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}

@end
