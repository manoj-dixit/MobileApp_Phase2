//
//  ImagePickManager.h
//
//  Created by Prakash on 26/12/13.
//  Copyright (c) 2013 kiwitech. All rights reserved.
//

/* -----------------------------------------------------------
 * class is written to present camera/photo library to get a pic.
 -------------------------------------------------------------*/

#import <Foundation/Foundation.h>

@interface ImagePickManager : NSObject<UIPopoverControllerDelegate>
{
}

/*!
 @method : to return shared instance.
 */
+ (ImagePickManager *)sharedPicker;


/*!
 @method : check camera availability.
 */
+ (BOOL)isCameraAuailable;


/*!
 @method : show image library/camera.
 @param : isCam - yes in case you need camera.
 @param : controller - on cotroller present this.
 @param : block - completion block.
 */
+ (void)presentImageSource:(BOOL)isCam forVideo:(BOOL)isVideo onController:(UIViewController *)controller withCompletion:(void (^)(BOOL isSelected, UIImage *image, NSURL *videoURL))block;


/*!
 @method : save image to library.
 @param : block - completion block.
 */
+ (void)saveImage:(UIImage *)image withCompletion:(void (^)(BOOL success, NSError *error))block;
+(BOOL)checkUserPermission:(int)mType;

+(void)askPermission;
+(void)askCameraPermission;
+(void)askPhotoLibPermission;
+(void)askMicroPhonePermission;



+ (NSString *)contentTypeForImageData:(NSData *)data;
@end
