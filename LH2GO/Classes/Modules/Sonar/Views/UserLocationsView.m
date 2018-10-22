//
//  MyView.m
//  test
//
//  Created by Kiwitech on 30/10/14.
//  Copyright (c) 2014 Kiwitech. All rights reserved.
//

#import "UserLocationsView.h"
#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "User.h"
#import "PlotUserView.h"
#import "UIView+Extra.h"
#import "SonarManager.h"

#define degreesToRadians(x)      (M_PI * x / 180.0)
#define radiandsToDegrees(x)     (x * 180.0 / M_PI)
#define kCLLoc(lt,ln)            CLLocationCoordinate2DMake(lt, ln);

#define CircleColour3 0/255.0, 104/255.0, 56/255.0, 0.5
#define CircleColour2 57/255.0, 181/255.0, 74/255.0, 0.8
#define CircleColour1 255/255.0, 255/255.0, 0/255.0, 1

@interface UserLocationsView () <PlotUserViewDelegate>
{
    UIButton *_meBtn;
}

@end

@implementation UserLocationsView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        [self setContentMode:UIViewContentModeRedraw];
        [self addMe];
        [self refreshUsers];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    double startAngle = - ((double)M_PI / 2); // 90 degrees
    double endAngle = (90 * (double)M_PI) + startAngle;
    // circle 1 small
    CGContextSetRGBStrokeColor(context, CircleColour1);
    double radius = rect.size.width/11.5;
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextStrokePath(context);
    // circle 2 medium
    CGContextSetRGBStrokeColor(context, CircleColour1);
    radius = rect.size.width/3.8;
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextStrokePath(context);
    // circle 3 large
    CGContextSetRGBStrokeColor(context, CircleColour1);
    radius = rect.size.width/2.12;
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextStrokePath(context);
}


#pragma mark - Public method

- (void)refreshUsers
{
    [self cleanSonarUsersFromUI];
    NSArray *list = [[SonarManager sharedManager] knownCurrentUsers];
    if (!list.count) return;
    // user's location..
    double lat = [LocationManager latitude];
    double lon = [LocationManager longitude];
    CLLocationCoordinate2D myLoc = kCLLoc(lat,lon);
    // calculate max distance...
    CLLocationDistance maxDist = 0;
    for (UserLocation *user in list)
    {
        CLLocationDistance distance = [self distanceBetweenCoordinate:myLoc andCoordinate:user.location];
        user.distance = distance;
        if (distance > maxDist)
        {
            maxDist = distance;
        }
    }
    // load users
    CGRect bnd = self.bounds;
    CGPoint center = CGPointMake(bnd.size.width/2, bnd.size.height/2);
    double rad = (bnd.size.width-20)/2;
    double oneMPerPix = rad/maxDist;
    for (UserLocation *user in list)
    {
        double angle = [self getHeadingForDirectionFromCoordinate:myLoc toCoordinate:user.location];
        double dis = user.distance;
        CGPoint center1 = CGPointMake(center.x + dis*oneMPerPix * cos(angle), center.y + dis*oneMPerPix * sin(angle));
        [self dropUser:user at:center1];
    }
}

- (void)cleanSonarUsersFromUI
{
    for (UIView *vv in self.subviews)
    {
        if ([vv isKindOfClass:[PlotUserView class]])
        {
                [vv removeFromSuperview];
        }
    }
}

#pragma mark - Private methods

- (void)addMe
{
    if (_meBtn == nil)
    {
        CGRect bnd = self.bounds;
        _meBtn = [[UIButton alloc] initWithFrame:CGRectMake(bnd.size.width/2-35, bnd.size.height/2-35, 70, 70)];
        [_meBtn roundCorner:_meBtn.frame.size.width/2 border:0 borderColor:[UIColor lightGrayColor]];
        [_meBtn addTarget:self action:@selector(meClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_meBtn addTarget:self action:@selector(meClicked:) forControlEvents:UIControlEventTouchUpOutside];
        [_meBtn addTarget:self action:@selector(mePressedClicked:) forControlEvents:UIControlEventTouchDown];
        [_meBtn addTarget:self action:@selector(mePressedCancel:) forControlEvents:UIControlEventTouchCancel];
        _meBtn.titleLabel.textAlignment =  NSTextAlignmentCenter;
        _meBtn.titleLabel.font = [UIFont fontWithName:@"Aileron-Regular" size:22.0f];
        User *user = [[Global shared] currentUser];
        [_meBtn.imageView sd_setImageWithURL:[NSURL URLWithString:user.picUrl] placeholderImage:_meBtn.imageView.image completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if (image)
                 [_meBtn setImage:image forState:UIControlStateNormal];
             else
                 [_meBtn setTitle:@"me" forState:UIControlStateNormal];
         }];
        [self addSubview:_meBtn];
    }
}

-(void)mePressedClicked:(UIButton *)btn
{
    [btn setBackgroundColor:[UIColor lightGrayColor]];
}

-(void)mePressedCancel:(UIButton *)btn
{
    [_meBtn setBackgroundColor:[UIColor clearColor]];
}

-(void)meClicked:(UIButton *)btn
{
    if (_delegate && [_delegate respondsToSelector:@selector(meClickedDelegate:)])
        [_delegate meClickedDelegate:btn];
    [_meBtn setBackgroundColor:[UIColor clearColor]];
}

- (void)dropUser:(UserLocation *)user at:(CGPoint)pt
{
    DLog(@"User - %@, Location (%lf, %lf) ", user.person.user_name, user.location.latitude,  user.location.longitude);
    PlotUserView *personV;
    for (UIView *vv in self.subviews)
    {
        if ([vv isKindOfClass:[PlotUserView class]])
        {
            if ([user.uId isEqualToString:[(PlotUserView *)vv userId]])
            {
                personV = (PlotUserView *)vv;
            }
        }
    }
    if (personV == nil)
    {
        // plot the view
        personV = [[PlotUserView alloc] initWithFrame:CGRectMake(150, 150, 50, 50)];
        [self addSubview:personV];
    }
    personV.delegate = self;
    [personV showUserLoc:user.person uId:user.uId];
    personV.center = pt;
}

- (CLLocationDistance)distanceBetweenCoordinate:(CLLocationCoordinate2D)originCoordinate andCoordinate:(CLLocationCoordinate2D)destinationCoordinate
{
    CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:originCoordinate.latitude longitude:originCoordinate.longitude];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destinationCoordinate.latitude longitude:destinationCoordinate.longitude];
    CLLocationDistance distance = [originLocation distanceFromLocation:destinationLocation];
    return distance;
}

- (double)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc
                                 toCoordinate:(CLLocationCoordinate2D)toLoc
{
    double lat1 = degreesToRadians(fromLoc.latitude);
    double lon1 = degreesToRadians(fromLoc.longitude);
    double lat2 = degreesToRadians(toLoc.latitude);
    double lon2 = degreesToRadians(toLoc.longitude);
    double dLon = lon2 - lon1;
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x)-M_PI_2;
    if(radiansBearing < 0.0)
    {
        radiansBearing += 2*M_PI;
    }
    return radiansBearing;
}

#pragma mark - Bekar...
- (void)loadDummyUsers
{
    NSArray *names = @[@"Jane", @"Jill", @"Jack", @"Carl", @"Misty", @"sean", @"George", @"Bill"];
    int yy[] = {120, 30, 200, 70, 260, 40, 240, 260};
    int xx[] = {30, 200, 140, 240, 80, 80, 220, 160};
    int k = 0;
    for (NSString *name in names)
    {
        PlotUserView *personV = [[PlotUserView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [personV showName:name];
        [self addSubview:personV];
        personV.center = CGPointMake(xx[k], yy[k]);
        k++;
    }
}

#pragma mark - PlotUserViewDelegate
- (void)didSelectUserWithId:(NSString *)uId
{
    NSArray *list = [[SonarManager sharedManager] knownCurrentUsers];
    // if this ping already recieved ignore. {}
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId = %@", uId];
    NSArray *array = [list filteredArrayUsingPredicate:predicate];
    UserLocation *user;
    if (array.count)
        user = [array firstObject];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectUser:)])
        [_delegate didSelectUser:user];
}

@end
