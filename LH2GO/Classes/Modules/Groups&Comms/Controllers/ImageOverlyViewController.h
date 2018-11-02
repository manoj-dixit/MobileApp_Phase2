//
//  ImageOverlyViewController.h
//  LH2GO
//
//  Created by Sumit Kumar on 16/07/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "BaseViewController.h"
#import "SharedUtils.h"
@class Shout;
@interface ImageOverlyViewController : BaseViewController<APICallProtocolDelegate,UIScrollViewDelegate>
@property (nonatomic,assign)NSString *imagePath;
@property (nonatomic,assign)NSString *mediaType;
@property (nonatomic,assign)NSString *mediaPath;
@property(nonatomic, weak)Shout *sht;
@property (nonatomic,strong) NSString *channelId;
@property (nonatomic) NSInteger contentId;
-(void)saveImage;
@end
