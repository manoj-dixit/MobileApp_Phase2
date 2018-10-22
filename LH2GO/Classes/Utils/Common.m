//
//  Common.m
//  LH2GO
//
//  Created by kiwi on 26/06/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "Common.h"


@implementation Common

+(NSDateFormatter* )getLh2goDateFormate
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormat setLocale:[NSLocale currentLocale]];
    return dateFormat;
}

+(NSDate *)localDateFromTimeStamp:(NSTimeInterval)timestamp{
   
    NSDate* dateLocal = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return dateLocal;
}
+(NSString *)localDateInStringFromTimeStamp:(NSTimeInterval)timestamp
{
    NSDate* dateLocal = [self localDateFromTimeStamp:timestamp];
    NSString *str = [[self getLh2goDateFormate] stringFromDate:dateLocal];
    return str;
}
+ (NSInteger)numberOfDaysBetween:(NSDate *)startDate and:(NSDate *)endDate {
    
    NSDate *aendDate = [NSDate date];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:aendDate
                                                         options:NSCalendarWrapComponents];
    NSInteger days = [components day];
    return days;
}

+(NSDate *)getPreviousDateOlderForDays:(NSInteger)days

{
    
    NSDate *currentDate = [NSDate date];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    [dateComponents setDay:-days];
    
    NSDate *daysAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    DLog(@"\ncurrentDate: %@\n days ago: %@", currentDate, daysAgo);
    
    return daysAgo;
    
}

+ (UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
{
    //-----------------------------------------
    // Convert hex string to an integer
    //-----------------------------------------
    unsigned int hexint = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet
                                       characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    
    //-----------------------------------------
    // Create color object, specifying alpha
    //-----------------------------------------
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}
//MARK:- FontSize According to screenRatio
+(CGFloat )setFontSize :(UIFont *)font{
    
    CGFloat fontSize = font.pointSize;
    CGFloat size;
    if(IPAD)
        size = (fontSize-2) * kRatio;
    else
        size = fontSize * kRatio;
    return size;
    
}

//MARK:- adjustheightwidth_ForRoundShape
+(CGRect)adjustRoundShapeFrame:(CGRect)frame{
    frame.size.height = frame.size.height *kRatio;
    frame.size.width = frame.size.width *kRatio;
    return frame;
}

//MARK:- Resizing Image
+(UIImage *)resizeImage:(UIImage *)image1 imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image1 drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
}

//MARK:- Detect Links[URLs,PhoneNos] in attributed strings
+(NSMutableAttributedString *)getAttributedString:(NSString *)str withFontSize:(CGFloat)fontSize{
    
    //trial strings
    /* str = @"This is a free online calculator which counts, url:  http://www.lettercount.com and phone 9898988988";//100
     str = @"This is a free online calculator which counts, url:  http://www.lettercount.com and phone 9898988988 988988 10";//110
     str = @"Mangalore (or Mangaluru) is an Arabian Sea port and a major commercial center in the Indian state of Karnataka. It's home to the Kadri Manjunath Temple,known for it.";//165 */
    
    if(str == nil)
        return nil;

    NSString *stringWithNSDataDetector = str;
    NSError *error = nil;
    NSDataDetector * dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink| NSTextCheckingTypeAddress                                                                    error:&error];
    //Check if (error) before (if required)
    
    __block NSMutableArray *phnMatches = [[NSMutableArray alloc] init];
    __block NSMutableArray *urlMatches = [[NSMutableArray alloc] init];
    
    //detecting whether string part is url or phoneNo
    [dataDetector enumerateMatchesInString:stringWithNSDataDetector
                                   options:NSMatchingWithTransparentBounds
                                     range:NSMakeRange(0, [stringWithNSDataDetector length])
                                usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
             
//        __block NSString *newStr;
         if ([match resultType] == NSTextCheckingTypePhoneNumber){
             if ([match phoneNumber])
                 [phnMatches addObject:[match phoneNumber]];
         }
         if ([match resultType] == NSTextCheckingTypeLink){
             if ([match URL])
                 [urlMatches addObject:[match URL]];
         }
         if ([match resultType] == NSTextCheckingTypeAddress){
             if ([match URL])
                 [urlMatches addObject:[match URL]];
         }
     }];
    
    //Formating StringPart
    NSDictionary *attrDict = @{ NSFontAttributeName : [UIFont fontWithName:@"Aileron-Regular" size:fontSize],
                                };
    NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:attrDict];
    
    if ([phnMatches count] > 0){
        
        for (int i=0; i<[phnMatches count]; i++)
        {
            NSString *boldStr_phn = (NSString* )[phnMatches objectAtIndex:i];
            NSRange boldRange = [str rangeOfString:boldStr_phn];
            boldStr_phn = [boldStr_phn stringByReplacingOccurrencesOfString:@" " withString:@""];

            NSString* actionStr = [NSString stringWithFormat:@"telprompt:%@", boldStr_phn];
            [yourAttributedString addAttribute: NSLinkAttributeName value:actionStr range:boldRange];
            [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"Aileron-SemiBold" size:fontSize] range:boldRange];
        }
    }
    
    if ([urlMatches count] > 0){
        NSRange boldRange1;
        for (int i=0; i<[urlMatches count]; i++) {
            NSURL *boldStr_url = (NSURL *)[urlMatches objectAtIndex:i];
            boldRange1 = [str rangeOfString:boldStr_url.absoluteString];
            if(boldRange1.length == 0){
                NSString *Txt = [boldStr_url.absoluteString substringFromIndex:7];
                boldRange1 = [str rangeOfString:Txt];
            }
            [yourAttributedString addAttribute: NSLinkAttributeName value:urlMatches[i] range:boldRange1];
            [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"Aileron-SemiBold" size:fontSize] range:boldRange1];
        }
    }
    
   // [urlMatches removeAllObjects];
    return yourAttributedString;
}

+ (BOOL)newVersionPresent {
    
    // 1. Get bundle identifier
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDict[@"CFBundleIdentifier"];
    
    // 2. Find version of app present at itunes store
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSDictionary* itunesVersionInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // if app present
    if ([itunesVersionInfo[@"resultCount"] integerValue] == 1){
        NSString* appStoreVersion = itunesVersionInfo[@"results"][0][@"version"];
        // 3. Find version of app currently running
        NSString* currentVersion = infoDict[@"CFBundleShortVersionString"];
        // 4. Compare both versions
        if ([appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending)
        {
                // app needs to be updated
                return YES;
        }
    }
    return NO;
}

+(void)goToAppStore
{
   // https://itunes.apple.com/in/app/providence2go/id1270610797?mt=8 // AppLink
    NSString *APP_STORE_ID = @"1270610797";
    static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    NSURL *appStoreLink = [NSURL URLWithString:[NSString stringWithFormat:iOSAppStoreURLFormat, APP_STORE_ID]];
    [[UIApplication sharedApplication] openURL:appStoreLink];
}

@end
