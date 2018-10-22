//
//  ImageCache.h
//  LH2GO
//
//  Created by Prakash Raj on 20/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ImageType_User = 0,
    ImageType_Group
} ImageType;


@interface ImageCache : NSObject

+ (instancetype)cache;

+ (NSString *)imageNameOf:(ImageType)type andId:(NSString *)imgId;

- (void)imageFromURL:(NSURL *)url WithName:(NSString *)name
     completionBlock:(void (^)(UIImage *image, NSData *data, NSError *error)) block;

- (void)imageFromData:(NSData *)data WithName:(NSString *)name
      completionBlock:(void (^)(UIImage *image, NSError *error)) block;

- (void)saveImageFromData:(NSData *)data WithName:(NSString *)name
          completionBlock:(void (^)(UIImage *image, NSError *error)) block;

- (void)saveImage:(UIImage *)image WithName:(NSString *)name;

- (UIImage *)imageWithName:(NSString *)name;

- (void)removeImage:(NSString *)name;

- (void)setLimit:(NSInteger)lim;

@end
