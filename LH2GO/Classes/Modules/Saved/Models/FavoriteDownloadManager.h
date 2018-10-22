//
//  FavoriteDownloadManager.h
//  LH2GO
//
//  Created by kiwi on 03/07/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteDownloadManager : NSObject

+ (void)downloadFavFromServerOnView:(UIView*)view completion:(void (^)(BOOL finished))completion;

@end
