//
//  MediaCommsViewController.m
//  LH2GO
//
//  Created by Prakash Raj on 06/05/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "MediaCommsViewController.h"
#import "ImagePickManager.h"
#import "ImageCropViewController.h"
#import "UIImage+Extra.h"
#import "SoundRecView.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+Extra.h"
#import "ShoutInfo.h"
#import "ShoutManager.h"
#import "BLEManager.h"
#import "LHVideoPlayer.h"
#import "LHAudioRecorderView.h"
#import "LHAudioPlayerView.h"
#import "DAKeyboardControl.h"
#include "FLAnimatedImage.h"
#include "FLAnimatedImageView.h"
#import "RelayView.h"
#import "SharedUtils.h"
#import "LoaderView.h"
#import "RelayObject.h"
#import "LHAudioPlayer.h"
#import "CryptLib.h"
#import "NSData+Base64.h"
#import "TimeConverter.h"
#import "CommsViewController.h"

#define MAX_BYTES_MEDIA 400000

@interface MediaCommsViewController ()<LHAudioRecorderViewDelegate,APICallProtocolDelegate>
{
    __weak IBOutlet UIImageView *_imageV;
    __weak IBOutlet UIView      *_textContainView;
    __weak IBOutlet UITextView  *_inputTxtView;
    __weak IBOutlet UILabel     *_leftLbl;
    __weak IBOutlet UIButton *_cancelBtn;
    __weak IBOutlet UIButton *_btnPlayVideo;
    __weak IBOutlet UIView *_statusView;
    __weak IBOutlet UIView *_baseView;
    __weak IBOutlet UIButton *shoutBtn;
    __weak IBOutlet UIView      *_viewForTextView; // by nim chat#3
    ShoutInfo *shoutSave;
    LHAudioRecorderView *recorderView;
    
    LHAudioPlayerView *player;
    LHAudioPlayer *player1;
    SoundRecView *_soundView;
    NSURL *_mediaUrl;
    SharedUtils *sharedUtils;
    NSString *groupID,*buttonName;
    NSMutableArray *a;
    NSString *typeOfMsg;
    NSString * mediaID;
}

@property (nonatomic, strong) FLAnimatedImageView *gifView;
@property (nonatomic, strong) NSData *gifData;
- (IBAction)shoutClicked:(id)sender;

@end

@implementation MediaCommsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.hidden = YES;
    a = [NSMutableArray new];
    _inputTxtView.autocorrectionType = UITextAutocorrectionTypeNo;
    if(IS_IPHONE_5)
    {
        CGRect favframe = _inputTxtView.frame;
        favframe.origin.x = favframe.origin.x - 10;
        favframe.size.width = favframe.size.width +20;
        _inputTxtView.frame =  favframe;
        _textContainView.frame = CGRectMake(_textContainView.frame.origin.x, self.view.frame.size.height-138, _textContainView.frame.size.width, _textContainView.frame.size.height);

    }
    if(IS_IPHONE_6P || IS_IPHONE_6)
    {
        CGRect leftlblfr  = _leftLbl.frame;
        leftlblfr.origin.x  = shoutBtn.frame.origin.x; // + 50
        leftlblfr.origin.y  = shoutBtn.frame.origin.y + shoutBtn.frame.size.height ;//- 25
       // _leftLbl.frame = leftlblfr; // by nim chat#3
    }
  /*  [_inputTxtView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_inputTxtView.layer setBorderWidth:2.0];
    _inputTxtView.layer.cornerRadius = 20;
    _inputTxtView.clipsToBounds = YES; */ // by nim chat#3
    _inputTxtView.textContainerInset = UIEdgeInsetsMake(5, 5, 10, 0);  //(top,left, bottom, right) // by nim chat#3

    _viewForTextView.layer.cornerRadius = 10;
    _viewForTextView.clipsToBounds = YES;

   // [self addTabbarWithTag: BarItemTag_Groups]; // add tab
   // [self addAdvanceSettingsView];  // by nim chat#3
    [self setUpView];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForgroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
//    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RelayView" owner:self options:nil];
//    self.relayView = [objects objectAtIndex:0];
//    self.relayView.stringValue = @"MEGHA";
//    self.relayView.relayDelegate = self;
//    [self.relayView setFrame:CGRectMake(0, _statusView.frame.origin.x + _statusView.frame.size.height +20, _baseView.frame.size.width, _textContainView.frame.origin.y)];
    sharedUtils = nil;
    sharedUtils = [[SharedUtils alloc] init];
    sharedUtils.delegate = self;
    [self shouldShowUserList:NO animated:NO];   // show user list NO
    // top bar
    [self addTopBarButtons];
    
    if([_msgString isEqualToString:@" start typing..."] || [_msgString isEqualToString:@""])
    {
        // nothing
    }else
    {
        _inputTxtView.text  = _msgString;
    }
    [self addNavigationBarViewComponents];
}

-(void) addAdvanceSettingsView
{
    CGSize sz = self.view.bounds.size;
    CGFloat tHieght = 61.3; //47;
    //CGFloat y = sz.height - tHieght;
    // CGRect frame = CGRectMake(0, sz.height-tHieght, sz.width, tHieght);
    
    CGRect frame = CGRectMake(0, sz.height-tHieght-62, sz.width, 61.3);//y
    _advanceSettingBottomView = [AdvanceSettingBottomView tabbarWithFrame:frame];
    [self.view addSubview:_advanceSettingBottomView];
    
    // _tabbar.selectedItemTag = barTag;
    [_advanceSettingBottomView addTarget:self andSelector:@selector(advanceSettingsClicked:)];
    
}

- (void)addTopBarButtons
{
    
    UIBarButtonItem *lefttButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [lefttButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = lefttButton;
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)addNavigationBarViewComponents {
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text=@"Preview";
    titleLabel.textColor= [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

-(void)goBack
{
   // [self.navigationController popViewControllerAnimated:true];
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[CommsViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:NO];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setUpKeyboard];
    validateUser = 1; //Set it to 0 if want to hit validate user API to check if user is blocked or not
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.mediaType!=MediaTypeSound)
    {
        [_inputTxtView becomeFirstResponder];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [player stopAudio];
    [recorderView forceStopRecording];
    [self.view removeKeyboardControl];
    [super viewWillDisappear:animated];
}

#pragma mark- Shout to cloud IBAction
- (IBAction)shoutToCloud:(id)sender
{
    buttonName = @"B-Box";
    if(validateUser == 0)
    {
        [LoaderView addLoaderToView:self.view];
        [self validateUserAPIMediaComms];
    }
    else
    {
        [self bboxButtonAction];
    }
}

- (void)setUpKeyboard
{
    __weak typeof(MediaCommsViewController *) cont = self;
    __weak typeof(UIView *) textBaseView = _textContainView;
    __weak typeof(UIView *) baseView = _baseView;
    __weak typeof (UIView*) statusView = _statusView;
    BOOL doesContain = [self.view.subviews containsObject:_relayView];
    if(doesContain)
    {
        [self test];
    }
    else
    {
        [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        // Try not to call "self" inside this block (retain cycle).But if you do, make sure to remove DAKeyboardControl when you are done with the view controller by calling:
        if(opening)
        {
            CGRect rect = textBaseView.frame;
            if (baseView.frame.size.height<=568&& (cont.mediaType==MediaTypeSound))
            {
                rect.origin.y = (keyboardFrameInView.origin.y - rect.size.height);//+86)+5;
                // rect.size.height = keyboardFrameInView.size.height - 185;
            }
            else if (baseView.frame.size.height<=568&& ((cont.mediaType==MediaTypeImageLibrary || cont.mediaType == MediaTypeImageCamera)))
            {
                rect.origin.y = (keyboardFrameInView.origin.y - rect.size.height);//+26;
                //rect.size.height = keyboardFrameInView.size.height - 185;
            }
            else if (baseView.frame.size.height<=568&&cont.mediaType==MediaTypeVideo)
            {
                rect.origin.y = (keyboardFrameInView.origin.y - rect.size.height);//+26;
                // rect.size.height = keyboardFrameInView.size.height - 185;
            }
            else if  (baseView.frame.size.height==480)
            {
                rect = [cont handleIphone4ScreensizeInFirstCompletionBlock:cont rect:rect keyboardFrameInView:keyboardFrameInView];//all QA related bug fixes
            }
            else if (baseView.frame.size.height<=568)
            {
                rect.origin.y = (keyboardFrameInView.origin.y - rect.size.height+36);
            }
            else
            {
                rect.origin.y = (keyboardFrameInView.origin.y - rect.size.height);
                //rect.size.height = keyboardFrameInView.size.height - 150;
            }
                textBaseView.frame = rect;
        }
        else
        {
            CGRect rect = textBaseView.frame;
            rect.origin.y = (baseView.frame.size.height - rect.size.height);// by nim chat#3 //-59
            textBaseView.frame = rect;
        }
        } constraintBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
            if (opening)
            {
                [UIView animateWithDuration:0.2 animations:^{
                CGRect rect = baseView.frame;
                CGRect textFrame = textBaseView.frame;
                if (rect.size.height<=568&&cont.mediaType==MediaTypeSound)
                {
                    rect.origin.y = 0;
                }
                else if (baseView.frame.size.height==480)
                {
                    rect = [cont handleIphone4ScreensizeInSecondCompletionBlock:cont rect:rect keyboardFrameInView:keyboardFrameInView];//all QA related bug fixes
                }
                else if (rect.size.height<=568)
                {
                    rect.origin.y = 0;
                }
                else
                {
                    textFrame.origin.y = (keyboardFrameInView.origin.y - textFrame.size.height);
                }
                    textBaseView.frame = textFrame;
                    baseView.frame = rect;
                    CGRect rect1 = statusView.frame;
                    rect1.origin.y = -rect.origin.y;
                    statusView.frame = rect1;
                }];
            }
            else
            {
                [UIView animateWithDuration:0.2 animations:^{
                CGRect rect = baseView.frame;
                rect.origin.y = 0;
                baseView.frame = rect;
                CGRect rect1 = statusView.frame;
                rect1.origin.y = 0;
                statusView.frame = rect1;
            }];
            }
        }];
    }
}

//all QA related bug fixes
- (CGRect)handleIphone4ScreensizeInFirstCompletionBlock:(MediaCommsViewController *)cont rect:(CGRect)rect
  keyboardFrameInView:(CGRect)keyboardFrameInView
{
    if (cont.mediaType==MediaTypeSound)
        rect.origin.y = (keyboardFrameInView.origin.y - rect.size.height+86+80);
    else if (cont.mediaType==MediaTypeVideo)
        rect.origin.y = (keyboardFrameInView.origin.y - rect.size.height+86+18);
    else if ((cont.mediaType==MediaTypeImageCamera || cont.mediaType==MediaTypeImageLibrary))
        rect.origin.y = (keyboardFrameInView.origin.y - rect.size.height+86);
    return rect;
}

//all QA related bug fixes
- (CGRect)handleIphone4ScreensizeInSecondCompletionBlock:(MediaCommsViewController *)cont rect:(CGRect)rect
  keyboardFrameInView:(CGRect)keyboardFrameInView
{
    if (cont.mediaType==MediaTypeSound)
    {
        rect.origin.y = -80-80;
    }
    else if (cont.mediaType==MediaTypeVideo)
        rect.origin.y = -80-18;
    else if ((cont.mediaType==MediaTypeImageCamera || cont.mediaType==MediaTypeImageLibrary))
    {
        rect.origin.y = -80;
    }
    return rect;
}

#pragma mark - Private methods

- (void)setUpView
{
    if (_mediaType == MediaTypeSound)
    {
        self.view.hidden = NO;
        [self setupVoiceRecorder]; // set up voice recording...
    }
    else if (_mediaType == MediaTypeVideo)
    {
        [self setupVideoRecorder];  // set up video recording...
    }
    else
    {
        // get image.
        [ImagePickManager presentImageSource:(_mediaType == MediaTypeImageCamera) forVideo:NO onController:self withCompletion:^(BOOL isSelected, UIImage *anImage, NSURL *videoURL)
         {
            if(isSelected)
            {
                if (anImage)
                {
                    CGSize sz = anImage.size;
                    float ratio = sz.height/sz.width;
                    sz.width = 180;//200;  // by nim
                    sz.height = (sz.width*ratio);
                    _imageV.image = [anImage imageByScalingAndCroppingForSize:sz];
                }
                else
                {
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"1.gif"]; //Add the file name
                    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                    self.gifData = pngData;
                    
                    if ([self.gifData length] > 2*kImageLimit)
                    {
                        [AppManager showAlertWithTitle:@"Size limit is less than 10 kb" Body:@"HHHH"];
                        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                        for (UIViewController *aViewController in allViewControllers) {
                            if ([aViewController isKindOfClass:[CommsViewController class]]) {
                                [self.navigationController popToViewController:aViewController animated:NO];
                            }
                        }
                        return;
                    }
                    
                    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:pngData];
                    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] initWithFrame:_imageV.frame];
                    imageView.contentMode =  UIViewContentModeScaleAspectFit;
                    imageView.animatedImage = image;
                    imageView.frame = _imageV.frame;
                    [_baseView addSubview:imageView];
                    [_baseView bringSubviewToFront:_statusView];
                }
                    self.view.hidden = NO;
                    _btnPlayVideo.hidden=YES;
            }
            else
            {
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                for (UIViewController *aViewController in allViewControllers) {
                    if ([aViewController isKindOfClass:[CommsViewController class]]) {
                        [self.navigationController popToViewController:aViewController animated:NO];
                    }
                }
               // [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (void)setupVideoRecorder
{
    // get video.
    __weak __typeof(self)weakSelf = self;
    [ImagePickManager presentImageSource:(_mediaType == MediaTypeVideo) forVideo:YES onController:weakSelf withCompletion:^(BOOL isSelected, UIImage *anImage, NSURL *videoURL)
     {
        if(isSelected)
        {
            _mediaUrl = [videoURL copy];
            UIImage *image = [AppManager getPreViewImg:_mediaUrl];
            CGSize sz = image.size;
            float ratio = sz.height/sz.width;
            sz.width = 100;
            sz.height = 100*ratio;
            _imageV.image = [image imageByScalingAndCroppingForSize:sz];
            self.view.hidden = NO;
            image = nil;
        }
        else
        {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)setupVoiceRecorder
{
    _imageV.hidden = YES;
    recorderView = [LHAudioRecorderView audioView];
    recorderView.delegate = self;
    CGRect rect = recorderView.frame;
    rect.origin.y = 40; // by nim
    if (_baseView.frame.size.height==480 || IS_IPHONE_5 || IS_IPHONE_4_OR_LESS)   // by nim chat#4
    {
        rect.origin.y = 20;
    }
    rect.origin.x = (self.view.frame.size.width/2)-(recorderView.frame.size.width/2);  // by nim chat#4
    recorderView.frame = rect;
    [_baseView addSubview:recorderView];
    rect = _cancelBtn.frame;
    rect.origin.y = recorderView.frame.origin.y+recorderView.frame.size.height-rect.size.height-2;
    _cancelBtn.frame = rect;
    [_baseView bringSubviewToFront:_cancelBtn];
    [_baseView bringSubviewToFront:_statusView];
}

-(void)sendButtonAction
{
    if ([[BLEManager sharedManager].centralM.connectedDevices count] >0 || [[BLEManager sharedManager].perM.connectedCentrals count]>0) {
        
#if TARGET_IPHONE_SIMULATOR
#else
    validateUser = YES;
    if ([[BLEManager sharedManager] on] == FALSE)
    {
        [AppManager showAlertWithTitle:@"Alert" Body:@"Please turn on Bluetooth in Settings, When the BT/BLE radio is off, shout will not be sent"];
        return;
    }
#endif
    NSString *txt = [_inputTxtView.text withoutWhiteSpaceString];
    ShoutType type;
    NSString *mediaPath=nil;
    NSData *content;
    if (_mediaType == MediaTypeImageCamera || _mediaType == MediaTypeImageLibrary)
    {
        type = ShoutTypeImage;
        if (self.gifData)
        {
            type = ShoutTypeGif;
            content = self.gifData;
        }
        else
        {
            //NSData *imgData = UIImageJPEGRepresentation(_imageV.image, 1); //1 it represents the quality of the image.
           // NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imgData length]);

            CGFloat compression = 0.9f;
            CGFloat maxCompression = 0.1f;
            int maxFileSize = kImageLimit;
            
            content = UIImageJPEGRepresentation(_imageV.image, compression);
            
            while ([content length] > maxFileSize && compression > maxCompression)
            {
                compression -= 0.1;
                content = UIImageJPEGRepresentation(_imageV.image, compression);
            }
        }
    }
    else if(_mediaType == MediaTypeVideo)
    {
        type = ShoutTypeVideo;
        content = [NSData dataWithContentsOfURL:_mediaUrl]; // video file data(NSData).
        {
            mediaPath = [[_mediaUrl filePathURL] absoluteString];
            [self saveDataToFile:content withFileName:@"video.mov"];
        }
    }
    else
    {
        type = ShoutTypeAudio;
        content = [NSData dataWithContentsOfURL:recorderView.audioURL]; // audio file data(NSData).
        if(content)
        {
            mediaPath = [[recorderView.audioURL filePathURL] absoluteString];
            recorderView = nil;
            [self saveDataToFile:content withFileName:@"audio.m4a"];
        }
    }
    if(content)
    {
        ShoutInfo *sh = [ShoutInfo composeText:txt type:type content:content groupId:_myGroup.grId parentShId:(_parentSh) ? _parentSh.shId : nil p2pChat:_myGroup.isP2PContact];
        sh.shout.mediaPath = mediaPath;
        // compose..
        _inputTxtView.text = @"";
        _leftLbl.numberOfLines = 0;
        _leftLbl.text = [NSString stringWithFormat:@" %i Left", k_MAX_SHOUT_LENGTH];
        [[BLEManager sharedManager] addSh:sh toQueueAt:YES];
        // enter in the list.
        [[ShoutManager sharedManager] enqueueShoutForSender:sh forUpdation:YES];
        self.myGroup = nil;
        self.parentSh = nil;
        _imageV = nil;
        
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        for (UIViewController *aViewController in allViewControllers) {
            if ([aViewController isKindOfClass:[CommsViewController class]]) {
                _inputTxtView.text  = nil;
                CommsViewController *obj = (CommsViewController *)aViewController;
                obj.isBackFromComms = YES;
                [self.navigationController popToViewController:aViewController animated:NO];
            }
        }
    }
    else
    {
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Please prepare media data." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alrt show]; alrt = nil;
    }
    }
    else
    {
        [AppManager showAlertWithTitle:@"Alert!" Body:@"You are not connected to any Buki-Box or iPhone via BLE. Please connect first to send"];
    }
}

-(void)bboxButtonAction
{
    [self.view endEditing:YES];
    ShoutType type;
    // NSString *mediaPath=nil;
    NSData *content;
    if (_mediaType == MediaTypeImageCamera || _mediaType == MediaTypeImageLibrary)
    {
        type = ShoutTypeImage;
        typeOfMsg = @"image";
        if (self.gifData)
        {
            type = ShoutTypeGif;
            content = self.gifData;
        }
        else
        {
            content = UIImageJPEGRepresentation(_imageV.image, 0.4);   // image file data(NSData).
            if(content.length > 0) {}
            else
            {
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Please prepare a media first." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show]; alrt = nil;
                return;
            }
        }
    }
    else if(_mediaType == MediaTypeVideo)
    {
        type = ShoutTypeVideo;
        typeOfMsg = @"video";
        content = [NSData dataWithContentsOfURL:_mediaUrl]; // video file data(NSData).
        if(content.length > 0 ){}//show loader
        else
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Please prepare a media first." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show]; alrt = nil;
            return;
        }
    }
    else
    {
        type = ShoutTypeAudio;
        typeOfMsg = @"audio";
        content = [NSData dataWithContentsOfURL:recorderView.audioURL]; // audio file data(NSData).
        if(content.length > 0 ){}
        else
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Please prepare a media first." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show]; alrt = nil;
            return;
        }
    }
    DLog(@"The Group id is %@",self.myGroup.grId);
    NSMutableArray *group_ids = [[NSMutableArray alloc]init];
    NSNumber *groupNumber;
    groupNumber = [NSNumber numberWithInt:[self.myGroup.grId intValue]];
    groupID = [NSString stringWithFormat:@"%@",groupNumber];
    [group_ids addObject: groupNumber];
    NSMutableDictionary * postDictionary = [[NSMutableDictionary alloc]init];
    [postDictionary setObject:group_ids forKey:@"group_id"];
    //Make api call
    if ([AppManager isInternetShouldAlert:YES])
    {
        //show loader...
        [LoaderView addLoaderToView:self.view];
        [sharedUtils makePostCloudAPICall:postDictionary andURL:GET_LIST_OF_RELAYS_URL];
    }
}

#pragma mark - IBAction

- (IBAction)advanceSettingsClicked:(id)sender {
  /*  AdvanceSettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AdvanceSettingsViewController"];
    vc.grp = _myGroup;
    vc.delegate = self;
    vc.previewTxt = [_inputTxtView.text withoutWhiteSpaceString];
    vc.previewImg = _imageV.image;
    vc.audioUrl = [[recorderView.audioURL filePathURL] absoluteString];
    vc.videoUrl = _mediaUrl;
    [self.navigationController pushViewController:vc animated:NO];*/
}

- (IBAction)mediaIconClicked:(id)sender
{
    if (_mediaType==MediaTypeVideo)
    {
        [LHVideoPlayer playVideoURL:_mediaUrl onController:self];
    }
}

- (void)saveDataToFile:(NSData*)data withFileName:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName]; //Add the file name
    [data writeToFile:filePath atomically:YES]; //Write the file
}

- (IBAction)shoutClicked:(id)sender
{
    [_inputTxtView resignFirstResponder];
    buttonName = @"Send";
    if(validateUser == 0)
    {
        [LoaderView addLoaderToView:self.view];
        [self validateUserAPIMediaComms];
    }
    else
    {
        [self sendButtonAction];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [_baseView bringSubviewToFront:_textContainView];
    _leftLbl.text = [NSString stringWithFormat:@" %i Left", k_MAX_SHOUT_LENGTH];
    if ([[BLEManager sharedManager] on] == FALSE)
    {
        return YES;
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //Compare backSpace....
    if(textView.text.length >= k_MAX_SHOUT_LENGTH && ![text isEqualToString:@""])
    {
        return FALSE;
    }
    if([text  isEqual: @"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length > k_MAX_SHOUT_LENGTH)
    {
        textView.text = [textView.text substringToIndex:k_MAX_SHOUT_LENGTH];
    }
    //text changed..
    _leftLbl.text = [NSString stringWithFormat:@" %li Left",(long)k_MAX_SHOUT_LENGTH - textView.text.length];
}

#pragma mark -- LHAudioRecorderViewDelegate --

- (void)audioRecorderDidFinishRecording:(NSURL*)url
{
    if(player == nil)
    {
        player = [LHAudioPlayerView playerView];
        [_baseView addSubview:player];
    }
    CGRect rect = player.frame;
    rect.size.width = _baseView.frame.size.width;
    rect.origin.y = recorderView.frame.origin.y + recorderView.frame.size.height + 5; //_cancelBtn.frame.origin.y+_cancelBtn.frame.size.height+7;  // by nim chat#4
    player.frame = rect;
    player.hidden = NO;
    [player setupAudioPlayer:url];
}

- (void)audioRecorderDidStartRecording
{
    [player stopAudio];
    player.hidden = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)appEnterForgroundNotification:(NSNotification*)note
{
    [self.view endEditing:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark- Show relay list

- (void)shouldShowUserList:(BOOL)show animated:(BOOL)animate
{
    _relayView.listOfRelays.tableFooterView= [[UIView alloc]initWithFrame:CGRectZero];    
    CGRect fr = _relayView.frame;
    fr.origin.y = (show)?   _statusView.frame.origin.x + _statusView.frame.size.height : self.view.frame.size.height;
    if (show)
    {
        [_relayView reload];
        [self.view bringSubviewToFront:_baseView];
        [_baseView addSubview:_relayView];
        [_baseView bringSubviewToFront:_textContainView];
        // [self.view bringSubviewToFront:_relayView];
    }
    if (!animate)
    {
        _relayView.frame = fr; return;
    }
    [UIView animateWithDuration:.4 animations:^{
        _relayView.frame = fr;
    } completion:^(BOOL finished) {}];
}


-(void)test
{
    DLog(@"working!");
}

#pragma mark- Shared Utils Delegate Method

- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL
{
    DLog(@"responseDict is --- %@",responseDict);
    if (![responseDict isKindOfClass:[NSNull class]])
    {
        BOOL status = [[responseDict objectForKey:@"status"] boolValue];
        NSString *msgStr= [responseDict objectForKey:@"status"];
        if (status || [msgStr isEqualToString:@"Success"])
        {
            if ([responseDict objectForKey:@"method"])
            {
                [AppManager showAlertWithTitle:@"Sent Successfully!!" Body:nil];
                //remove loader from view
                [LoaderView removeLoader];
                _inputTxtView.text = @"";
                self.myGroup = nil;
                self.parentSh = nil;
                _imageV = nil;
                [self.navigationController popViewControllerAnimated:YES];
                // enter in the list.
                [[ShoutManager sharedManager] enqueueShout:shoutSave forUpdation:NO];
            }
            else
            {
                //parse response
                NSMutableDictionary *dictOfRelays = [responseDict objectForKey:@"data"];
                NSMutableArray * arrayOfRelays = [dictOfRelays objectForKey:self.myGroup.network.netId];
                [LoaderView removeLoader];
                self.relayView.relaysList = [[NSMutableArray alloc] init];
                [arrayOfRelays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    RelayObject *relayObj = [[RelayObject alloc] initRelayObjectWithDic:obj];
                    [self.relayView.relaysList addObject:relayObj];
                }];
                DLog(@"The arrays is %@",self.relayView.relaysList);
                //remove loader from view
                [LoaderView removeLoader];
                [self.relayView.listOfRelays reloadData];
                if (self.relayView.relaysList.count > 0)
                {
                    //open relay view
                    [self shouldShowUserList:YES animated:YES];
                }
            }
        }
        else
        {
            //remove loader
            [LoaderView removeLoader];
            //show alert if relays are not connected
            [AppManager showAlertWithTitle:msgStr Body:nil];
        }
    }
    else
    {
        //remove loader
        [LoaderView removeLoader];
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"The response is null" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alrt show]; alrt = nil;
    }
}

#pragma mark- Relay View Delegate methods

- (void)didCancelView
{
    [self shouldShowUserList:NO animated:YES];
}

-(void)relaySelectedWithMacId : (NSMutableArray *)macIds
{
    DLog(@"The array of mac ids is %@",macIds);
    //Make api call to send data
    NSString *txt = [_inputTxtView.text withoutWhiteSpaceString];
    ShoutType type;
    NSString *mediaPath=nil;
    NSData *content;
    if (_mediaType == MediaTypeImageCamera | _mediaType == MediaTypeImageLibrary)
    {
        type = ShoutTypeImage;
        if (self.gifData)
        {
            type = ShoutTypeGif;
            content = self.gifData;
        }
        else
        {
            content = UIImageJPEGRepresentation(_imageV.image, 0.4);   // image file data(NSData).
            if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
            {
                //show loader
                [LoaderView addLoaderToView:self.view];
                [self saveDataToFile:content withFileName:@"image.png"];
            }
            else
            {
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show]; alrt = nil;
                return;
            }
        }
    }
    else if(_mediaType == MediaTypeVideo)
    {
        type = ShoutTypeVideo;
        content = [NSData dataWithContentsOfURL:_mediaUrl]; // video file data(NSData).
        if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
        {
            //show loader
            [LoaderView addLoaderToView:self.view];
            mediaPath = [[_mediaUrl filePathURL] absoluteString];
            [self saveDataToFile:content withFileName:@"video.mov"];
        }
        else
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show]; alrt = nil;
            return;
        }
    }
    else
    {
        type = ShoutTypeAudio;
        content = [NSData dataWithContentsOfURL:recorderView.audioURL]; // audio file data(NSData).
        if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
        {
            //show loader
            [LoaderView addLoaderToView:self.view];
            mediaPath = [[recorderView.audioURL filePathURL] absoluteString];
            //recorderView = nil;
            [self saveDataToFile:content withFileName:@"audio.m4a"];
        }
        else
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show]; alrt = nil;
            return;
        }
    }
    ShoutInfo *sh = [ShoutInfo composeText:txt type:type content:content groupId:_myGroup.grId parentShId:(_parentSh) ? _parentSh.shId : nil p2pChat:_myGroup.isP2PContact];
    sh.shout.mediaPath = mediaPath;
    // compose..
    _inputTxtView.text = @"";
    _leftLbl.numberOfLines = 0;
    _leftLbl.text = [NSString stringWithFormat:@" %i Left", k_MAX_SHOUT_LENGTH];
    shoutSave = sh;
    NSData *data = [ShoutManager dataFromObjectForShout:sh];
    NSString *iv = [PrefManager iv];
    const unsigned char *bytes = [data bytes];
    NSUInteger length = [data length];
    NSMutableArray *byteArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < length; i++)
    {
        [byteArray addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
    }
    
   // NSString *str = [NSString stringWithFormat:@"advertisement-%@",typeOfMsg];
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"advertisement",@"method",@"relays",@"type",macIds,@"ble_mac_ids", byteArray,@"message",[NSNumber numberWithInt:(int)length], @"length",iv,@"iv",typeOfMsg,@"message_type",nil];
    DLog(@"the send dict is %@",postDictionary);
    if ([AppManager isInternetShouldAlert:YES])
    {
        [sharedUtils makePostCloudAPICall:postDictionary andURL:SEND_DATA_TO_CLOUD_URL];
    }
    //hide view
    [self shouldShowUserList:NO animated:YES];
}

-(void)validateUserAPIMediaComms
{
    if(![AppManager isInternetShouldAlert:YES]) {
        [LoaderView removeLoader];
        return;
    }
    DLog(@"user id %@",[Global shared].currentUser.user_id);
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:VALIDATE_USER];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *postDictionary ;
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",nil];
    NSData *myData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:myData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        DLog(@"Response---------->>>>>>>:%@ %@\n", response, error);
        if(error == nil)
        {
            NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            DLog(@"responseDict is --- %@",dict);
            [LoaderView removeLoader];
            if(response != NULL)
            {
            BOOL sucess = [[dict objectForKey:@"status"]boolValue];
            NSString *msgStr= [dict objectForKey:@"status"];
            
            if([buttonName isEqualToString:@"B-Box"])
            {
                if (sucess || [msgStr isEqualToString:@"Success"])
                {
                    validateUser = 1;
                    [self bboxButtonAction];
                }
                else
                {
                    NSString *str = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
                    [AppManager showAlertWithTitle:nil Body:str];
                }
            }
            else if([buttonName isEqualToString:@"Send"])
            {
                if(sucess)
                {
                    validateUser = 1;
                    [self sendButtonAction];
                }
                else
                {
                    NSString *str = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
                    [AppManager showAlertWithTitle:nil Body:str];
                }
            }
        }
        }
    }];
    [dataTask resume];
    [defaultSession finishTasksAndInvalidate];
}
#pragma mark- Relay Delegate methods


-(void)relaySelectedWithMacIdForCMS:(NSMutableArray *)relays displayTime:(NSString*)displayTime startTime:(NSString*)startTime endTime:(NSString*)endTime duration:(NSString*)duration{
    
    // add loader..
    // [LoaderView addLoaderToView:self.view];
    NSString *typeOfMedia = nil;
    ShoutType type;
    
    
    
    NSString *mediaPath=nil;
    NSData *content;
    if (_mediaType == MediaTypeImageCamera | _mediaType == MediaTypeImageLibrary)
    {
        typeOfMedia = @"image";
        type = ShoutTypeImage;
        if (self.gifData)
        {
            type = ShoutTypeGif;
            content = self.gifData;
        }
        else
        {
            content = UIImageJPEGRepresentation(_imageV.image, 0.4);   // image file data(NSData).
            if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
            {
                //show loader
                [self saveDataToFile:content withFileName:@"image.png"];
            }
            else
            {
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show]; alrt = nil;
                return;
            }
        }
    }
    else if(_mediaType == MediaTypeVideo)
    {
        type = ShoutTypeVideo;
        typeOfMedia = @"Video";
        content = [NSData dataWithContentsOfURL:_mediaUrl]; // video file data(NSData).
        if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
        {
            mediaPath = [[_mediaUrl filePathURL] absoluteString];
            [self saveDataToFile:content withFileName:@"video.mov"];
        }
        else
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show]; alrt = nil;
            return;
        }
    }
    else
    {
        type = ShoutTypeAudio;
        typeOfMedia = @"Audio";
        content = [NSData dataWithContentsOfURL:recorderView.audioURL]; // audio file data(NSData).
        if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
        {
            mediaPath = [[recorderView.audioURL filePathURL] absoluteString];
            //recorderView = nil;
            [self saveDataToFile:content withFileName:@"audio.m4a"];
        }
        else
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show]; alrt = nil;
            return;
        }
    }
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject :  _myGroup.grId forKey : @"groupIds"];
    [param setObject:typeOfMedia forKey:@"mediaMessageType"];
    // add token..
    AFAppDotNetAPIClient *client = [AFAppDotNetAPIClient sharedClient];
    NSString *token = [PrefManager token];
    [client.requestSerializer  setValue:token forHTTPHeaderField:kTokenKey];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [client POST:SENDMEDIAMSG parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        DLog(@"Class%@",[param class]);
        [formData appendPartWithFileData:content name:@"image" fileName:@"cmsMedia.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *errorJson=nil;
        NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers |NSJSONReadingAllowFragments error:&errorJson];
        DLog(@"responseDict=%@",response);
        NSLog(@"error=%@",errorJson);
        if(response != NULL)
        {
        BOOL status = [response objectForKey:@"status"];
        if(status)
        {
            //    NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            //   [AppManager showAlertWithTitle:nil Body:str];
            NSMutableDictionary *data = [response objectForKey:@"data"];
            mediaID = [data objectForKey:@"id"];
            DLog(@"media id %@",mediaID);
            [self relayWithMacId:relays duration:duration startTime:startTime endTime:endTime displayTime:displayTime];
            // [self relayWithMacId:relays];
            
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@", [response objectForKey:@"message"]];
            [AppManager showAlertWithTitle:nil Body:str];
        }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoaderView removeLoader];
        [AppManager handleError:error withOpCode:operation.response.statusCode showMessageStatus:YES];
    }];
}


-(void)relayWithMacId : (NSMutableArray *)macIds duration:(NSString*)duration startTime:(NSString*)startTime endTime:(NSString*)endTime displayTime:(NSString*)displayTime{
    
    DLog(@"The array of mac ids is %@",macIds);
    //Make api call to send data
    NSString *txt = [_inputTxtView.text withoutWhiteSpaceString];
    ShoutType type;
    NSString *mediaPath=nil;
    NSData *content;
    typeOfMsg = nil;
    if (_mediaType == MediaTypeImageCamera | _mediaType == MediaTypeImageLibrary)
    {
        type = ShoutTypeImage;
        if (self.gifData)
        {
            type = ShoutTypeGif;
            content = self.gifData;
            
           // content = UIImageJPEGRepresentation(_imageV.image, 0.4);   // image file data(NSData).
            
        }
        else
        {
            content = UIImageJPEGRepresentation(_imageV.image, 0.4);   // image file data(NSData).
            typeOfMsg = @"image";
            if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
            {
                //show loader
                [self saveDataToFile:content withFileName:@"image.png"];
            }
            else
            {
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show]; alrt = nil;
                return;
            }
        }
    }
    else if(_mediaType == MediaTypeVideo)
    {
        type = ShoutTypeVideo;
        typeOfMsg = @"video";
        content = [NSData dataWithContentsOfURL:_mediaUrl]; // video file data(NSData).
        if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
        {
            mediaPath = [[_mediaUrl filePathURL] absoluteString];
            [self saveDataToFile:content withFileName:@"video.mov"];
        }
        else
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show]; alrt = nil;
            return;
        }
    }
    else
    {
        type = ShoutTypeAudio;
        typeOfMsg = @"audio";
        content = [NSData dataWithContentsOfURL:recorderView.audioURL]; // audio file data(NSData).
        if(content.length > 0 && content.length <= MAX_BYTES_MEDIA)
        {
            
            mediaPath = [[recorderView.audioURL filePathURL] absoluteString];
            //recorderView = nil;
            [self saveDataToFile:content withFileName:@"audio.m4a"];
        }
        else
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle: @"Alert" message:@"Maximum 400kb allowed. Please select another media." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show]; alrt = nil;
            return;
        }
    }
    ShoutInfo *sh = [ShoutInfo composeText:txt type:type content:content groupId:_myGroup.grId parentShId:(_parentSh) ? _parentSh.shId : nil p2pChat:_myGroup.isP2PContact];
    sh.shout.mediaPath = mediaPath;
    // compose..
    _inputTxtView.text = @"";
    _leftLbl.numberOfLines = 0;
    _leftLbl.text = [NSString stringWithFormat:@" %i Left", k_MAX_SHOUT_LENGTH];
    shoutSave = sh;
    NSData *data = [ShoutManager dataFromObjectForShout:sh];
    NSString *iv = [PrefManager iv];
    const unsigned char *bytes = [data bytes];
    NSUInteger length = [data length];
    NSMutableArray *byteArray = [NSMutableArray array];
    NSMutableDictionary *postDictionary;
    for (NSUInteger i = 0; i < length; i++)
    {
        [byteArray addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
    }
    
    postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"advertisement",@"method",@"relays",@"type",macIds,@"ble_mac_ids", byteArray,@"message",[NSNumber numberWithInt:(int)length], @"length",iv,@"iv",typeOfMsg,@"message_type",mediaID,@"mediaId",@"Scheduler",@"category",displayTime,@"app_display_time",duration,@"duration",startTime,@"start_date_time",endTime,@"end_date_time",_myGroup.grId,@"group_id",nil];
    
    
    DLog(@"the send dict is %@",postDictionary);
    if ([AppManager isInternetShouldAlert:YES])
    {
        [sharedUtils makePostCloudAPICall:postDictionary andURL:SENDVIASCHEDULER];
    }
    
    
}

@end
