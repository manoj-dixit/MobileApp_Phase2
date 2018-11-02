//
//  ImageOverlyViewController.m
//  LH2GO
//
//  Created by Sumit Kumar on 16/07/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "ImageOverlyViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ImagePickManager.h"
#import "LoaderView.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "TimeConverter.h"
#import "SharedUtils.h"
#import "EventLog.h"
#import "UIImage+animatedGIF.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageOverlyViewController ()
{
    __weak IBOutlet UIImageView *_imgContentView;
    __weak IBOutlet UIScrollView *_imgScrollView;
   __weak IBOutlet FLAnimatedImageView *_animatedImageView;

    NSString *gifPath;
    NSString *imagePathNew;
    UIImage *imageObject;
    SharedUtils *sharedUtils;
    BOOL accepted,saveButtonTapped;
    UIImageView *bigImage;
}
@property (nonatomic, strong) NSData *gifData;
@end

@implementation ImageOverlyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc]init];
    sharedUtils.delegate = self;
    [self initUI];
    saveButtonTapped = NO;
    

    
    //UIImage zoom in and out
    float minScale=_imgScrollView.frame.size.width / _imgContentView.frame.size.width;
    _imgScrollView.minimumZoomScale = minScale;
    _imgScrollView.maximumZoomScale = 3.0;
    _imgScrollView.contentSize = _imgContentView.frame.size;
    _imgScrollView.delegate = self;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [_imgScrollView addGestureRecognizer:doubleTap];

    // Do any additional setup after loading the view.

}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if(_imgScrollView.zoomScale > _imgScrollView.minimumZoomScale)
        [_imgScrollView setZoomScale:_imgScrollView.minimumZoomScale animated:YES];
    else
        [_imgScrollView setZoomScale:_imgScrollView.maximumZoomScale animated:YES];
}


- (void)initUI
{
//    CGRect scrollFrame = CGRectMake(0, 0, 375, 628);
//
//    // Create the UIScrollView to have the size of the window, matching its size
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
//    scrollView.minimumZoomScale = 0.5;
//    scrollView.maximumZoomScale = 3.0;
//    scrollView.delegate = self;
//
//    // In this example, the UIImage size is greater than the scrollFrame size
//    //UIImage *bigImage = [UIImage imageNamed:@"chanel_image4.png"];
//    bigImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375, 628)];
////    bigImage.frame=CGRectMake(0, 0, 375, 628);
//    //    largeImageView.center=scrollView.center;
//    // Tell the scrollView how big its subview is
//    scrollView.contentSize = bigImage.frame.size;   // Important
//    scrollView.backgroundColor=[UIColor redColor];
//    [scrollView addSubview:bigImage];
//
//    [self.view addSubview:scrollView];
//    _imgContentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375, 628)];
//    //    largeImageView.center=scrollView.center;
//    // Tell the scrollView how big its subview is
//    [_imgScrollView addSubview:_imgContentView];
     //_imgScrollView.contentSize = _imgContentView.frame.size;   // Important

    if(self.sht.type.integerValue == ShoutTypeGif)
    {
         [_imgScrollView setHidden:YES];
        NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:self.sht.contentUrl];
        NSData *pngData = [NSData dataWithContentsOfFile:path];
      //  _imgViewYGF.backgroundColor = [UIColor clearColor];
        self.gifData = pngData;
    }
    else if([_mediaType containsString:@"G"]){
        
       /* NSData *pngData = [NSData dataWithContentsOfFile:_mediaPath];
       // _imgViewYGF.backgroundColor = [UIColor clearColor];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:pngData];
        _imgViewYGF.animatedImage = image;
        
        
        NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        
        
        NSString* currentFile = [stringPath stringByAppendingPathComponent:[_mediaPath lastPathComponent]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
        
        NSData *gifdata = [NSData dataWithContentsOfFile:_mediaPath];
        if (!gifdata) {
            
            if (fileExists)
            {
                FLAnimatedImage *FLimage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:currentFile]];
                self.gifData = [NSData dataWithContentsOfFile:currentFile];
            }
            else
            {
                UIImage *img1 = [[SDImageCache sharedImageCache] diskImageForKey:_mediaPath];
                self.gifData = UIImagePNGRepresentation(img1);
            }
            [_imgContentView setImage:[UIImage imageWithData:self.gifData]];
        }
        else
        {
            self.gifData = pngData;

            FLAnimatedImage *FLimage;
            FLimage = [FLAnimatedImage animatedImageWithGIFData:gifdata];
            if (!FLimage) {
                FLimage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:currentFile]];
            }
            else{
                
            }
            [_imgContentView setImage:[UIImage imageWithData:self.gifData]];
        }
       // [_imgScrollView setHidden:YES];*/
        NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString* currentFile = [stringPath stringByAppendingPathComponent:[_mediaPath lastPathComponent]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
        FLAnimatedImage *animatedImage;
        if (fileExists) {
            animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:currentFile]];
        }
        else{
            NSData *gifdata = [NSData dataWithContentsOfFile:_mediaPath];
            animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifdata];
        }
        _animatedImageView.animatedImage = animatedImage;
    }  
    else if([_mediaType containsString:@"I"]){
        
        UIImage *img1 = [[SDImageCache sharedImageCache] diskImageForKey:_mediaPath];
        NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString* currentFile = [stringPath stringByAppendingPathComponent:[_mediaPath lastPathComponent]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:currentFile];
        
        if (!img1 && fileExists) {
            img1 = [UIImage imageWithData:[NSData dataWithContentsOfFile:currentFile]];
        }
        [_imgContentView setImage: img1];
        imageObject = bigImage.image;
    }
    else
    {
        [_imgContentView sd_setImageWithURL:[NSURL URLWithString:self.imagePath] placeholderImage:_imgContentView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imageObject = image;
        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    //_imgContentView = nil;
    self.imagePath = nil;
    self.sht = nil;
    self.gifData = nil;
}

#pragma mark IBActions

- (IBAction)cancleClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveClicked:(id)sender
{
    [self saveImage];
}

-(void)saveImage{
    
    if (saveButtonTapped == NO) {
        saveButtonTapped = YES;
        if (![ImagePickManager checkUserPermission:2]) {
            
            [self askPhotoLibPermission];
            return;
        }
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if(self.sht.type.integerValue == ShoutTypeGif)
        {
            [library saveImageData:self.gifData toAlbum:@"Buki Album" metadata:nil completion:^(NSURL *assetURL, NSError *error) {
                if (error==nil)
                {
                    DLog(@" Save image with asset url %@ (absolute path: %@), type: %@",assetURL, [assetURL absoluteString], [assetURL class]);
                    gifPath = [assetURL absoluteString];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self eventLogAPI];
                    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Success !" message:@"Image Saved Successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alrt show];
                }
            } failure:^(NSError *error) {
                NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                      __PRETTY_FUNCTION__, [error localizedDescription]);
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error !" message:@"Error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                saveButtonTapped = NO;
                [alrt show];
            }];
        }
        
        else if([_mediaType containsString:@"G"]){
            [library saveImageData:self.gifData toAlbum:@"Buki Album" metadata:nil completion:^(NSURL *assetURL, NSError *error) {
                if (error==nil)
                {
                    DLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
                         assetURL, [assetURL absoluteString], [assetURL class]);
                    gifPath = [assetURL absoluteString];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self eventLogAPIForChannels];
                    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Success !" message:@"Image Saved Successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alrt show];
                }
            } failure:^(NSError *error) {
                NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                      __PRETTY_FUNCTION__, [error localizedDescription]);
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error !" message:@"Error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                saveButtonTapped = NO;
                [alrt show];
            }];
            
        }
        
        else if([_mediaType containsString:@"I"]){
            
            [library saveImageData:UIImagePNGRepresentation([[SDImageCache sharedImageCache] diskImageForKey:_mediaPath]) toAlbum:@"Buki Album" metadata:nil completion:^(NSURL *assetURL, NSError *error) {
                
                NSLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
                      assetURL, [assetURL absoluteString], [assetURL class]);
                imagePathNew = [assetURL absoluteString];
                [self eventLogAPIForChannels];
                [self dismissViewControllerAnimated:YES completion:nil];
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Success !" message:@"Image Saved Successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alrt show];
                
                
            } failure:^(NSError *error) {
                
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error !" message:@"Error." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
                [alrt show];
                
                saveButtonTapped = NO;
            }];
            
            
            
            // The completion block to be executed after image taking action process done
            //            void (^completion)(NSURL* , NSError* ) = ^(NSURL *assetURL, NSError *error) {
            //                if (error)
            //                {
            //                    DLog(@"%s: Write the image data to the assets library (camera roll): %@",
            //                          __PRETTY_FUNCTION__, [error localizedDescription]);
            //                }
            //                           };
            //            void (^failure)(NSError *) = ^(NSError *error) {
            //                if (error)
            //                {
            //                    NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
            //                          __PRETTY_FUNCTION__, [error localizedDescription]);
            //                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && (UIScreen.mainScreen.nativeBounds.size.height == 2001 || UIScreen.mainScreen.nativeBounds.size.height == 2436))
            //                    {
            //                        //iPhone X
            //                        //Not Showing Popup as of now
            //                        [self dismissViewControllerAnimated:YES completion:nil];
            //                        [self eventLogAPI];
            //                        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Success !" message:@"Image Saved Successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //                        [alrt show];
            //                    }
            //                    else
            //                    {
            //                    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error !" message:@"Error." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
            //                    [alrt show];
            //                    }
            //                    saveButtonTapped = NO;
            //                }
            //            };
            //            [library saveImage:imageObject toAlbum:@"LH2GO Album" completion:completion failure:failure];
            
        }
        else
        {
            // The completion block to be executed after image taking action process done
            void (^completion)(NSURL* , NSError* ) = ^(NSURL *assetURL, NSError *error) {
                if (error)
                {
                    NSLog(@"%s: Write the image data to the assets library (camera roll): %@",
                          __PRETTY_FUNCTION__, [error localizedDescription]);
                }
                DLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
                     assetURL, [assetURL absoluteString], [assetURL class]);
                imagePathNew = [assetURL absoluteString];
                [self eventLogAPI];
                [self dismissViewControllerAnimated:YES completion:nil];
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Success !" message:@"Image Saved Successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alrt show];
            };
            void (^failure)(NSError *) = ^(NSError *error) {
                if (error)
                {
                    NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                          __PRETTY_FUNCTION__, [error localizedDescription]);
                    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error !" message:@"Error." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
                    saveButtonTapped = NO;
                    [alrt show];
                }
            };
            [library saveImage:imageObject toAlbum:@"Buki Album" completion:completion failure:failure];
        }
    }
}


#pragma mark API Call

-(void)eventLogAPI
{
   
    NSData *imageData = UIImagePNGRepresentation(imageObject);
    NSData *data;
    NSMutableDictionary *detailDict;
    NSMutableDictionary *detailDict1;

    int timeStamp = (int)[TimeConverter timeStamp];
    if(self.sht.type.integerValue == ShoutTypeGif)
    {
        data = self.gifData;

        detailDict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sht.shId,@"shoutId",_sht.group.grId,@"groupId",gifPath,@"text",nil];

        detailDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_save_image",@"log_sub_category",_sht.group.grId,@"groupId",_sht.shId,@"shoutId",gifPath,@"text",_sht.group.grId,@"category_id",detailDict1,@"details",nil];
    }
    else
    {
        data = imageData;
        
        detailDict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sht.group.grId,@"shoutId",_sht.group.grId,@"groupId",gifPath,@"text",nil];

        detailDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Group_Message",@"log_category",@"on_save_image",@"log_sub_category",_sht.group.grId,@"groupId",_sht.shId,@"shoutId",imagePathNew,@"content",_sht.group.grId,@"category_id",detailDict1,@"details",nil];
    }
    
    [AppManager saveEventLogInArray:detailDict];

    
//    [EventLog addEventWithDict:detailDict];
//
//    NSNumber *count = [Global shared].currentUser.eventCount;
//    int value = [count intValue];
//    count = [NSNumber numberWithInt:value + 1];
//    [[Global shared].currentUser setEventCount:count];
//    [DBManager save];
//    
//    
//    if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0)){          //show loader...
//        // [LoaderView addLoaderToView:self.view];
//           [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//    
//    }
    

    
    
}

-(void)eventLogAPIForChannels
{
    
    NSData *imageData = UIImagePNGRepresentation(imageObject);
    NSData *data;
    NSMutableDictionary *detailDict;
    NSMutableDictionary *detailDict1;

    int timeStamp = (int)[TimeConverter timeStamp];
    if([_mediaType containsString:@"G"])
    {
        data = self.gifData;
        detailDict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)_contentId],@"channelContentId",_channelId,@"channelId",gifPath,@"text",nil];

        detailDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_save_image",@"log_sub_category",_channelId,@"channelId",[NSString stringWithFormat:@"%ld",(long)_contentId],@"channelContentId",gifPath,@"text",_channelId,@"category_id",detailDict1,@"details",nil];
    }
    else
    {
        data = imageData;
        detailDict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)_contentId],@"channelContentId",_channelId,@"channelId",gifPath,@"text",nil];

        detailDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", timeStamp],@"timestamp",@"Channel",@"log_category",@"on_save_image",@"log_sub_category",_channelId,@"channelId",[NSString stringWithFormat:@"%ld",(long)_contentId],@"channelContentId",imagePathNew,@"content",_channelId,@"category_id",detailDict1,@"details",nil];
    }
    
    [AppManager saveEventLogInArray:detailDict];

//    [EventLog addEventWithDict:detailDict];
//    
//    NSNumber *count = [Global shared].currentUser.eventCount;
//    int value = [count intValue];
//    count = [NSNumber numberWithInt:value + 1];
//    [[Global shared].currentUser setEventCount:count];
//    [DBManager save];
//    
//    
//    if ([AppManager isInternetShouldAlert:NO] && ([count intValue]%10 == 0)){          //show loader...
//        // [LoaderView addLoaderToView:self.view];
//        [sharedUtils makeEventLogAPICall:TOPOLOGY_LOGS];
//        
//    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        if (alertView.tag == 1001001)
        {
            NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settings])
            {
                [[UIApplication sharedApplication] openURL:settings];
            }
            //sonal commented to remove warning
//            if (&UIApplicationOpenSettingsURLString != NULL)
//            {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//            }
        }
    }
}

#pragma mark ASK Permissions

//-(void)askCameraPermission
//{
//    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
//            // until iOS 8. So for iOS 7 permission will always be granted.
//            if (granted) {
//                // Permission has been granted. Use dispatch_async for any UI updating
//                // code because this block may be executed in a thread.
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    if(accepted){
//                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) { }
//                        if (k_EnableVideoRecording == 1)
//                        {
//                            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Capture Video", @"Click image from camera", @"Pick image from library", nil];
//                            [sheet showInView:self.view];
//                        }
//                        else
//                        {
//                            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Click image from camera", @"Pick image from library", nil];
//                            [sheet showInView:self.view];
//                        }
//                        
//                    }
//                });
//            } else {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to your camera. To enable access, tap Settings and turn on Camera." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
//                    alrt.tag = 1001001;
//                    [alrt show];
//                    alrt = nil;
//                });
//                // Permission has been denied.
//            }
//        }];
//    } else {
//        // We are on iOS <= 6. Just do what we need to do.
//        //        [self doStuff];
//    }
//}

-(void)askPhotoLibPermission
{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // NSLog(@"%li",(long)[group numberOfAssets]);
        
        if(*stop == NO)
        {
            accepted = 1;
           // [self askCameraPermission];
            *stop = YES;
        }
    } failureBlock:^(NSError *error) {
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            // NSLog(@"user denied access, code: %li",(long)error.code);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to Photos. To enable access, tap Settings and turn on Photos." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                alrt.tag = 1001001;
                [alrt show];
                alrt = nil;
            });
            
        }else{
            NSLog(@"Other error code: %li",(long)error.code);
        }
    }];
}

#pragma mark-
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imgContentView;
}

@end
