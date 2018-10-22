//
//  UILabel_FontControl.h
//  LH2GO
//
//  Created by Prakash Raj on 21/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel ()
@property (nonatomic, assign) BOOL checkFontInIphone6;

- (BOOL)setheckFontInIphone6:() {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    BOOL iphone6 = (screenHeight > 480)
    if (iphone6) {
        // ..
        UIFont *font = self.font;
        font = [font fontWithSize:font.pointSize * 3.4];
        return YES;
    }
    return YES;
}

@end
