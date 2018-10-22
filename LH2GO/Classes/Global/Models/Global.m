//
//  Global.m
//  LH2GO
//
//  Created by Prakash Raj on 13/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "Global.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ImagePickManager.h"

@implementation Global

+ (instancetype)shared
{
    static Global *_shGlobal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shGlobal = [[Global alloc] init];
    });
    return _shGlobal;
}

+ (NSString *)apiIS :(NSString *)baseURL :(NSString *)server :(NSString *)apiName
{
    NSString *apiNameIS = [NSString stringWithFormat:@"%@%@/api/index.php/%@",baseURL,server,apiName];
    return apiNameIS;
}

+ (NSString *)currentTransService_UUID
{
    NSString *activeNetId = [PrefManager activeNetId];
    Network *actNet = [Network networkWithId:activeNetId shouldInsert:NO];
    // NSLog(@"Actnet service %@",actNet);
    if (actNet && actNet.netTransKey.length)
    {
      //  NSString *trimmedService_UUIDString = [actNet.netTransKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //        NSLog(@"Return trimmedService_UUIDString %@",trimmedService_UUIDString);
        return @"CBDA";//@"A893A32D-0D1D-EDE8-AFEF-BCADC64AA572";//trimmedService_UUIDString;
    }
    //    NSLog(@"Return Default $$$$$");
    return @"CBDA";//@"A893A32D-0D1D-EDE8-AFEF-BCADC64AA572";//@"E20A39F4-73F5-4BC4-A12F-17D1AD07A968"; // default
}

+ (NSString *)currentCharacteristic_UUID
{
    NSString *activeNetId = [PrefManager activeNetId];
    Network *actNet = [Network networkWithId:activeNetId shouldInsert:NO];
    //  NSLog(@"Actnet characteristic %@",actNet);
    
    if (actNet && actNet.netCharKey.length)
    {
        NSString *trimmedCharacteristic_UUIDString = [actNet.netCharKey stringByTrimmingCharactersInSet:
                                                      [NSCharacterSet whitespaceCharacterSet]];
        DLog(@"Return trimmedCharacteristic_UUIDString %@",trimmedCharacteristic_UUIDString);
        return @"38E4C000-9D8C-2964-70B3-2CFD9E63774A";//trimmedCharacteristic_UUIDString;
        
    }
    DLog(@"Return Default #######");
    return @"38E4C000-9D8C-2964-70B3-2CFD9E63774A";//@"08590F7E-DB05-467E-8757-72F6FAEB13D8"; // default
}

- (void)saveVideo:(Shout*)_shoutObj
{
    if (_shoutObj.contentUrl==nil)
    {
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error !" message:@"Video URL Error." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrt show];
        return;
    }
    if (![ImagePickManager checkUserPermission:2])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Alert !" message:@"App does not have access to Photos. To enable access, tap Settings and turn on Photos." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            alrt.tag = 1001001;
            [alrt show];
            alrt = nil;
        });
        return;
    }
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // The completion block to be executed after image taking action process done
    void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        if (error)
        {
            NSLog(@"%s: Write the image data to the assets library (camera roll): %@",
                  __PRETTY_FUNCTION__, [error localizedDescription]);
        }
        DLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
              assetURL, [assetURL absoluteString], [assetURL class]);
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Success !" message:@"Video Saved Successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrt show];
    };
    void (^failure)(NSError *) = ^(NSError *error) {
        if (error)
        {
            DLog(@"%s: Failed to add the asset to the custom photo album: %@",
                  __PRETTY_FUNCTION__, [error localizedDescription]);
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error !" message:@"Error." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alrt show];
        }
    };
    NSString *path = [[SDImageCache sharedImageCache] getMediaPathForKey:_shoutObj.contentUrl];
    [library saveVideo:[NSURL URLWithString:path] toAlbum:@"LH2GO Video" completion:completion failure:failure];
}

@end
