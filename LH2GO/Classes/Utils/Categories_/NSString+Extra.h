//
//  NSString+Extra.h
//  KLoof
//
//  Created by Prakash Raj on 13/09/13.
//  Copyright (c) 2013 Loud hailer. All rights reserved.
//

/*
 * A Class to handle NSString validations etc.
 */


#import <Foundation/Foundation.h>


@interface NSString (Extra)

// @method : to check email string validation.
- (BOOL)isValidForEmail;

// @method : to check the empty string.
- (BOOL)isEmptyString;

//
- (NSString *)withoutWhiteSpaceString;

@end
