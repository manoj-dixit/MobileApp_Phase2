//
//  ImageCache.m
//  LH2GO
//
//  Created by Prakash Raj on 20/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "ImageCache.h"


@interface ImageCache ()
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, assign) NSInteger max;
@end



@implementation ImageCache

+ (instancetype)cache {
    static ImageCache *_shCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shCache = [[ImageCache alloc] init];
        _shCache.queue = [NSMutableArray new];
        _shCache.max = 100;
    });
    return _shCache;
}

+ (NSString *)imageNameOf:(ImageType)type andId:(NSString *)imgId {
    NSString *str =  @"";
    if (type == ImageType_User) {
       str = @"User_";
    } else if (type == ImageType_Group) {
         str = @"Group_";
    }
    
    return [NSString stringWithFormat:@"%@%@", str, imgId];
}


- (void)imageFromURL:(NSURL *)url WithName:(NSString *)name
     completionBlock:(void (^)(UIImage *image, NSData *data, NSError *error)) block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        
        NSData * d = [[NSData alloc] initWithContentsOfURL:url];
        
        if(d) {
            UIImage *image = [[UIImage alloc] initWithData:d];
           if (block) block(image, d, nil);
            
        } else {
            NSError *error = [NSError errorWithDomain:@"Img_download_error" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Can't fetch data" forKey:NSLocalizedDescriptionKey]];
            if (block) block(nil, nil, error);
        }
    });
}

/*
- (void) downloadPlistForURL:(NSURL *) url completionBlock:(void (^)(NSArray *data, NSError *error)) block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        NSArray *returnArray = [NSArray arrayWithContentsOfURL:url];
        if(returnArray) {
            block(returnArray, nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"plist_download_error" code:1
                                             userInfo:[NSDictionary dictionaryWithObject:@"Can't fetch data" forKey:NSLocalizedDescriptionKey]];
            block(nil, error);
        }
        
    });
}*/


- (void)imageFromData:(NSData *)data WithName:(NSString *)name completionBlock:(void (^)(UIImage *image, NSError *error)) block {
    UIImage *img = [self imageWithName:name];
    if (img) {
        block(img , nil);
    } else {
        [self saveImageFromData:data WithName:name completionBlock:block];
    }
}

- (void)saveImageFromData:(NSData *)data WithName:(NSString *)name completionBlock:(void (^)(UIImage *image, NSError *error)) block {
    
    if (!data) {
       block(nil, nil);
        return;
    }
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        
        UIImage *image = [UIImage imageWithData:data];
        
        if(image) {
            [self saveImage:image WithName:name];
            if (block) block(image , nil);
            
        } else {
            NSError *error = [NSError errorWithDomain:@"Bad_data_error" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Can't convert to image" forKey:NSLocalizedDescriptionKey]];
            block(nil, error);
        }
    });
}


- (void)saveImage:(UIImage *)image WithName:(NSString *)name {
    
    [self removeImage:name];
    
    NSString *pstr = [NSString stringWithFormat:@"name = %@", [name lowercaseString]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pstr];
    NSArray *array = [_queue filteredArrayUsingPredicate:predicate];
    
    if (array.count)  {
        NSDictionary *d = [array lastObject];
        [_queue removeObject:d];
        [_queue addObject:d];
        
    } else {
        if (_queue.count >= _max) {
            [_queue removeObjectAtIndex:0];
        }
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: image, name, nil];
        [_queue addObject:dict];
    }
}

- (UIImage *)imageWithName:(NSString *)name {
    NSString *pstr = [NSString stringWithFormat:@"name = %@", [name lowercaseString]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pstr];
    NSArray *array = [_queue filteredArrayUsingPredicate:predicate];
    
    if (array.count)  {
        NSDictionary *d = [array lastObject];
        return [d objectForKey:name];
    }
    
    return nil;
}


- (void)removeImage:(NSString *)name {
    NSString *pstr = [NSString stringWithFormat:@"name = %@", [name lowercaseString]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pstr];
    NSArray *array = [_queue filteredArrayUsingPredicate:predicate];
    
    if (array.count)  {
        NSDictionary *d = [array lastObject];
        [_queue removeObject:d];
    }
}


- (void)setLimit:(NSInteger)lim {
    self.max = lim;
}

@end
