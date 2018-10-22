//
//  ImageCropViewController.m
//
//  Created by Prakash Raj on 02/09/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "ImageCropViewController.h"
#import "UIImage+Extra.h"

@interface ImageCropViewController () <UIScrollViewDelegate> {
    
    __weak IBOutlet UILabel     *_titleLabel;
    __weak IBOutlet UIButton    *_backButton;
    __weak IBOutlet UIButton    *_topCropButton;
    
     __weak IBOutlet UIImageView  *_gridImageView;
    
    __weak IBOutlet UIView      *_bottomView;
    __weak IBOutlet UIButton    *_bottomCropButton;
    
    UIImageView  *_imageView;
    UIScrollView *_scrollView;
    
    float _screenW;
}

- (IBAction)backAction:(id)sender;
- (IBAction)cropClicked:(id)sender;

// @method : to load photo.
- (void)loadPhoto;

@end

@implementation ImageCropViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpUI];

}

-(void)setUpUI
{
    CGSize result = [[UIScreen mainScreen] bounds].size;
    _screenW = result.width;
    
    CGRect fr =  _bottomView.frame;
    fr.size.height = self.view.bounds.size.height - 20 - _screenW;
    fr.origin.y = _screenW+20;
    if (IS_IPHONE_6P){
        //fr.origin.y -= 20;
    }
    _bottomView.frame = fr;
    [self loadPhoto];        // load image passed from previous view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


#pragma mark - IBAction
- (IBAction)backAction:(id)sender {
    // go to back.
    if(self.completionBlock) self.completionBlock(NO, nil, self);
    
}

- (IBAction)cropClicked:(id)sender {
    
    // calculate Zoom scale
    float zoomScale = 1.0 / [_scrollView zoomScale];
	
    // calculate desired (cropped) frame
	CGRect rect;
	rect.origin.x = [_scrollView contentOffset].x * zoomScale;
	rect.origin.y = [_scrollView contentOffset].y * zoomScale;
	rect.size.width = [_scrollView bounds].size.width * zoomScale;
	rect.size.height = [_scrollView bounds].size.height * zoomScale;
	
    // get CGImage->UIImage here
	CGImageRef cr = CGImageCreateWithImageInRect([[_imageView image] CGImage], rect);
	UIImage *cropedImage = [UIImage imageWithCGImage:cr];
	CGImageRelease(cr);
    
    if(self.completionBlock) self.completionBlock(YES, cropedImage, self);
}


#pragma mark - Private Methods

- (void)loadPhoto {
    
    if (self.image == nil) return;
    
    CGRect fr = CGRectMake(0.0, 64, _screenW, _screenW);
    _gridImageView.frame = fr;
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:fr];
    [_scrollView setBackgroundColor:[UIColor blackColor]];
    [_scrollView setDelegate:self];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setMaximumZoomScale:2.5];
    
    _imageView = [[UIImageView alloc] initWithImage:_image];
    CGRect rect = CGRectMake(0, 0, _image.size.width, _image.size.height);
    [_imageView setFrame:rect];
    
    [_scrollView setContentSize:[_imageView frame].size];
    [_scrollView setMinimumZoomScale:[_scrollView frame].size.width / [_imageView frame].size.width];
    [_scrollView setZoomScale:[_scrollView minimumZoomScale]];
    [_scrollView addSubview:_imageView];
    
    [self.view addSubview:_scrollView];
    
    [self.view bringSubviewToFront:_gridImageView];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

-(void)setMyChannel:(NSDictionary *)dic
{
    
    ChanelViewController *channelVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ChanelViewController class])];
    
    NSString *channelName = [[[dic objectForKey:@"Data"] componentsSeparatedByString:@":"] objectAtIndex:1];
    
    NSString *activeNetId = [PrefManager activeNetId];
    Network *net = [Network networkWithId:activeNetId shouldInsert:NO];
    
    //NSArray *channel  = [DBManager getChannelsForNetwork:net];
    
    // fetch the data for channe;
    NSArray *dataOfParticularChannl =  [DBManager getChannelDataFromNameAndId:channelName isName:NO Network:net];
    
    NSString *channelID;
    Channels *channel;
    if (dataOfParticularChannl.count>0)
    {
        channel = [dataOfParticularChannl objectAtIndex:0];
        channelID = channel.channelId;
    }
    else
        return;
    
    channelVC.myChannel = channel;
    
    [self.navigationController pushViewController:channelVC animated:YES];
}

- (void)goToComunicationScreenForShout:(Shout*)sht isForChannelContent:(BOOL)isForChannel dataDic:(NSDictionary *)dataDict
{
    
    if (sht==nil)
    {
        //push to channel view controller
        
        [self setMyChannel:dataDict];
        return;

//        ChanelViewController *channelVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ChanelViewController class])];
//        [self.navigationController pushViewController:channelVC animated:YES];
//        return;
    }
    // check owner
    Group *gr = sht.group;
    CommsViewController *gvc = nil;
    ReplyViewController *rvc = nil;
    if([self.navigationController.topViewController isKindOfClass:[ReplyViewController class]])//crash fix , please dont remove this code
    {
        //        ReplyViewController *rv = (ReplyViewController *)self.navigationController.topViewController;
        //        [self.navigationController popToRootViewControllerAnimated:YES];
        //        rv = nil;
    }
    if([self.navigationController.topViewController isKindOfClass:[CommsViewController class]])//crash fix , please dont remove this code
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KY" object:gr];
        return;
    }
    if(sht.parent_shout==nil)
    {
        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        gvc.myGroup = gr;
        
        NSMutableArray *nets = [NSMutableArray new];
        //   NSString *activeNetId = [PrefManager activeNetId];
        NSArray *networks = [DBManager getNetworks];
        for(Network *net in networks){
            NSArray *groups = [DBManager getShortedGroupsForNetwork:net];
            NSDictionary *d = @{ @"network" : net,
                                 @"groups"  : groups
                                 };
            [nets addObject:d];
            
        }
        
        NSDictionary  *d = [nets objectAtIndex:0];
        NSArray *groups = [d objectForKey:@"groups"];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"grId"
                                                     ascending:YES];
        NSArray *arr = [groups sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        __block BOOL isAvailable = false;
        __block NSUInteger index;
        
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            Group *gr1 = obj;
            if ([gr1.grId integerValue] == [gr.grId integerValue]) {
                isAvailable = YES;
                index       = idx;
            }
        }];
        
        if (isAvailable) {
            gvc.selectedGroupIndex = index;
        }
        // by nim
        UINavigationController * nvc = [[UINavigationController alloc]initWithRootViewController:gvc];
        [self.navigationController pushViewController:nvc animated:YES];
    }
    else
    {
        gvc = (CommsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"CommsViewController"];
        gvc.myGroup = gr;
        [self.navigationController pushViewController:gvc animated:NO];
        rvc = (ReplyViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
        rvc.pShout = sht.parent_shout;
        rvc.myGroup=gr;
        [self.navigationController pushViewController:rvc animated:YES];
    }
    //  clear badge on group.
    if (gr.totShoutsReceived)
    {
        [gr clearBadge:gr];
        //[self updateBadgeForGroup];
    }
}

@end
