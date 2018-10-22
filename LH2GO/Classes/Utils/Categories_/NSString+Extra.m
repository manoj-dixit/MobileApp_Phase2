//
//  NSString+Extra.m
//  KLoof
//
//  Created by Prakash Raj on 13/09/13.
//  Copyright (c) 2013 Loud hailer. All rights reserved.
//

#import "NSString+Extra.h"


@implementation NSString (Extra)

#pragma mark - Private Methods -

- (BOOL)isValidForEmail {
    //create an set of possible characters which can be contained by NSString object
	NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)isEmptyString {
    NSString* str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ([str isEqualToString:@""] || str.length == 0);
}

- (NSString *)withoutWhiteSpaceString {
    NSString *sText = [self stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return sText;
}

@end
