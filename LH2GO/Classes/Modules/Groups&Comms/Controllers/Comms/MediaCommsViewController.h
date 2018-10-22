//
//  MediaCommsViewController.h
//  LH2GO
//
//  Created by Prakash Raj on 06/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+CommonActions.h"
#import "BaseViewController.h"
#import "RelayView.h"
//#import "AdvanceSettingsViewController.h"

typedef NS_ENUM(NSInteger, MediaType) {
    MediaTypeImageLibrary = 0,
    MediaTypeImageCamera,
    MediaTypeVideo,
    MediaTypeSound
};

@interface MediaCommsViewController : BaseViewController<RelayListDelegate>
{
    AdvanceSettingBottomView *_advanceSettingBottomView;
}
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, weak) Group *myGroup;
@property (nonatomic, strong) Shout *parentSh;
@property (strong, nonatomic) RelayView *relayView;

@property (nonatomic, strong) NSString *msgString;

@end


@protocol MediaCommsViewControllerDelegate <NSObject>
@optional
@end

