//
//  ImagePickManager.m
//
//  Created by Prakash on 26/12/13.
//  Copyright (c) 2013 kiwitech. All rights reserved.
//

#import "ImagePickManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
/*!
 * @block : to perform task on completion.
 * @arg : isSelected - YES/NO    (user selected an image/cancelled).
 * @arg : image - selected image (nil in case user cancelled).
 */
typedef void (^CompletionImageSelection)(BOOL isSelected, UIImage *image, NSURL *videoURL);


@interface ImagePickManager () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) CompletionImageSelection block;
@end

@implementation ImagePickManager

// @method : to return shared instance.
+ (ImagePickManager *)sharedPicker {
    static ImagePickManager *picker = nil;
    @synchronized (self) {
        if (!picker) {
            picker = [[ImagePickManager alloc] init];
        }
    }
    return picker;
}

// check camera availability.
+ (BOOL)isCameraAuailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

//1 = video, camera
//2= library
//3 = audio
+(BOOL)checkUserPermission:(int)mType
{
    if (mType == 1) {
        return [self checkCamera];
    }
    else if (mType == 2)
    {
        return [self checkLibrary];
    }
    else
    {
        return [self checkAudioPermission];
    }
}

+(BOOL)checkCamera{
    BOOL __block isPermission = NO;

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        isPermission = YES;
    }else {
        isPermission = NO;
    }
    return isPermission;
}

+(BOOL)checkLibrary{
    BOOL __block isPermission = NO;
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (status == ALAuthorizationStatusAuthorized) {
        return isPermission = YES;
    }else{
        return isPermission = NO;
    }
}


+(BOOL)checkAudioPermission
{
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(recordPermission)])//ios 8
    {
        BOOL __block isPermission = NO;
        
        switch ([[AVAudioSession sharedInstance] recordPermission]) {
            case AVAudioSessionRecordPermissionGranted:
                isPermission = YES;
                break;
            case AVAudioSessionRecordPermissionDenied:
                isPermission = NO;
                break;
            case AVAudioSessionRecordPermissionUndetermined:
                // This is the initial state before a user has made any choice
                // You can use this spot to request permission here if you want
                isPermission = NO;
                break;
            default:
                break;
        }
        return isPermission;
    }else
    {
        return YES;
    }
    
}

// show image library/camera..
+ (void)presentImageSource:(BOOL)isCam forVideo:(BOOL)isVideo onController:(UIViewController *)controller withCompletion:(void (^)(BOOL isSelected, UIImage *image, NSURL *videoURL))block {
    
//    if(isCam && ![ImagePickManager isCameraAuailable]) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"Device does not support camera." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alrt show]; alrt = nil;
//        });
//        
//        if (block) block(NO, nil, nil);
//        return;
//    }
    // check if user ask for camera and its availability.
    if(isCam && ![ImagePickManager isCameraAuailable]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"Device does not support camera." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alrt show]; alrt = nil;
        });
        
        if (block) block(NO, nil, nil);
        return;
    }
    
    ImagePickManager *picker = [ImagePickManager sharedPicker];
    picker.block = block;
    
    // open image library/camera.
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = picker;
    //Video Recording
    if (isVideo) {
        pickerController.videoMaximumDuration = kVideoRecordingMaxTime;
        pickerController.videoQuality = UIImagePickerControllerQualityType640x480; //Sonal Changed Low to Medium
        pickerController.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
    }
    
   pickerController.sourceType = (isCam) ? UIImagePickerControllerSourceTypeCamera : (UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum);
//    if(pickerController.sourceType == (UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum))
//        pickerController.mediaTypes = [NSArray arrayWithObject:@"public.AlbumImage"];
//    else if(pickerController.sourceType == UIImagePickerControllerSourceTypeCamera)
//    pickerController.mediaTypes = [NSArray arrayWithObject:@"public.image"] ;
    [controller presentViewController:pickerController animated:YES completion:nil];
    
}


// @method : save image to library.
+ (void)saveImage:(UIImage *)image withCompletion:(void (^)(BOOL success, NSError *error))block {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
        if(!error)  {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"Image is saved to Image Library." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alrt show]; alrt = nil;
            
            if(block) block ((error == Nil), error);
        }
    }];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"])
    {
        UIImage *anImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (anImage==nil && UIImagePickerControllerOriginalImage != nil ) {
            anImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
       // if(self.block) self.block(YES, anImage, nil);

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
                 resultBlock:^(ALAsset *asset)
         {
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
             NSString *filePath = [documentsPath stringByAppendingPathComponent:@"1.gif"]; //Add the file name
             [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
             ALAssetRepresentation *representation = [asset defaultRepresentation];
             
             DLog(@"size of asset in bytes: %lld", [representation size]);
             
             unsigned char bytes[4];
             [representation getBytes:bytes fromOffset:0 length:4 error:nil];
             DLog(@"first four bytes: %02x (%c) %02x (%c) %02x (%c) %02x (%c)",
                   bytes[0], bytes[0],
                   bytes[1], bytes[1],
                   bytes[2], bytes[2],
                   bytes[3], bytes[3]);
             
             Byte *buffer = (Byte*)malloc((NSUInteger)representation.size);
             NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:(NSUInteger)representation.size error:nil];
             NSData *gifData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
             NSInteger lengthGifInKB = (unsigned long)gifData.length/1024;
             NSString *amediaType = [ImagePickManager contentTypeForImageData:gifData];

             if (lengthGifInKB > kGifLimit && [amediaType isEqualToString:@"image/gif"]) {
                 [AppManager showAlertWithTitle:@"Alert" Body:[NSString stringWithFormat:@"Image is too large for attachement. Please attach image less than %d KB.", kGifLimit]];
                 gifData = nil;
                 if(self.block) self.block(NO, nil, nil);
                 return;
             }
             if ([amediaType isEqualToString:@"image/gif"]) {
                 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                 NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                 NSString *filePath = [documentsPath stringByAppendingPathComponent:@"1.gif"]; //Add the file name
                 [gifData writeToFile:filePath atomically:YES]; //Write the file
                 gifData = nil;
                 if(self.block) self.block(YES, nil, nil);
             }else
             {
                 UIImage *anImage = [info objectForKey:UIImagePickerControllerEditedImage];
                 if (anImage==nil && UIImagePickerControllerOriginalImage != nil) {
                     anImage = [info objectForKey:UIImagePickerControllerOriginalImage];
                 }
                 if(self.block) self.block(YES, anImage, nil);
             }
             
         }
                failureBlock:^(NSError *error)
         {
             NSLog(@"couldn't get asset: %@", error);
         }
         ];
        
        
    }
    else if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info valueForKey:UIImagePickerControllerMediaURL];
        if(self.block) self.block(YES, nil, videoUrl);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    
    // handle error.
    if (error) {
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrt show]; alrt = nil; return;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(self.block) self.block(NO, nil, nil);
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationItem setTitle:@"Select Photo"];
}

//ask permission
+(void)askPermission
{
    [ImagePickManager askCameraPermission];
    [ImagePickManager askPhotoLibPermission];
    [ImagePickManager askMicroPhonePermission];
}
+(void)askCameraPermission
{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
            // until iOS 8. So for iOS 7 permission will always be granted.
            if (granted) {
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    [self doStuff];
                });
            } else {
                // Permission has been denied.
            }
        }];
    } else {
        // We are on iOS <= 6. Just do what we need to do.
        //        [self doStuff];
    }
}
+(void)askPhotoLibPermission
{
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        DLog(@"%li",(long)[group numberOfAssets]);
        
    } failureBlock:^(NSError *error) {
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            NSLog(@"user denied access, code: %li",(long)error.code);
        }else{
            NSLog(@"Other error code: %li",(long)error.code);
        }
    }];
}

+(void)askMicroPhonePermission
{
    //audio
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSLog(@"Permission granted");
        }
        else {
            NSLog(@"Permission denied");
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to Microphone. To enable access, tap Settings and turn on Microphone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            alrt.tag = 1001001;
            [alrt show];
            alrt = nil;

        }
    }];
}

//this method returns resource type
+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

@end
