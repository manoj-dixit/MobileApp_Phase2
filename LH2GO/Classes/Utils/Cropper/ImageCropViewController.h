//
//  ImageCropViewController.h
//
//  Created by Prakash Raj on 02/09/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SucessBlock) (BOOL success, UIImage *image, UIViewController *controller);

@interface ImageCropViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) SucessBlock completionBlock;
- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict;
@end
