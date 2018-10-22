//
//  Common.h
//  LH2GO
//
//  Created by kiwi on 26/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject
+(NSDate *)localDateFromTimeStamp:(NSTimeInterval)timestamp;
+(NSString *)localDateInStringFromTimeStamp:(NSTimeInterval)timestamp;
+ (NSInteger)numberOfDaysBetween:(NSDate *)startDate and:(NSDate *)endDate;
+(NSDate *)getPreviousDateOlderForDays:(NSInteger)days;
+(UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
+(CGFloat )setFontSize :(UIFont *)font;
+(CGRect)adjustRoundShapeFrame:(CGRect)frame;
+(UIImage *)resizeImage:(UIImage *)image1 imageSize:(CGSize)size;
+(NSMutableAttributedString *)getAttributedString:(NSString *)str withFontSize:(CGFloat)fontSize;
@end
