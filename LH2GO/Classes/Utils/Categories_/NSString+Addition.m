//
//  NSString+Addition.m
//  LocktonAtlas
//
//  Created by Prakash Raj on 11/04/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "NSString+Addition.h"

@implementation NSString(Addition)

- (CGSize)actualSizeWithFont:(UIFont *)font stickToWidth:(CGFloat)sWidth {
    return [self actualSizeWithFont:font stickToWidth:sWidth andHeight:MAXFLOAT];
}

- (CGSize)actualSizeWithFont:(UIFont *)font stickToHeight:(CGFloat)sHeight {
    return [self actualSizeWithFont:font stickToWidth:MAXFLOAT andHeight:sHeight];
}

- (CGSize)actualSizeWithFont:(UIFont *)font
                stickToWidth:(CGFloat)sWidth andHeight:(CGFloat)sHeight {
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    // available only on ios7.0 sdk.
    CGRect rect = [self boundingRectWithSize:CGSizeMake(sWidth, sHeight)
                                     options: NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    return rect.size;
}

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    
    for (; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }
    
    return [self substringWithRange:NSMakeRange(location, length - location)];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    
    for (; length > 0; length--) {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    
    return [self substringWithRange:NSMakeRange(location, length - location)];
}

- (NSString*)stringByDeletingWhitespace
{
    NSString* str = [self stringByTrimmingLeadingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    str = [str stringByTrimmingTrailingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return str;
}

@end
