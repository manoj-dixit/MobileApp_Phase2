//
//  PlaceListCollectionCell.m
//  LH2GO
//
//  Created by Parul Mankotia on 03/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "PlaceListCollectionCell.h"

@implementation PlaceListCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _cityCodeLabel.layer.cornerRadius = _cityCodeLabel.frame.size.width/2;
    _cityCodeLabel.layer.masksToBounds = YES;
}

-(void)changeCellForNewCity{

}

-(void)collectionCellManageData:(NSString*)cityString{
    if ([cityString isEqualToString:@"Add New"]) {
        _cityCodeLabel.backgroundColor = [UIColor clearColor];
        _cityCodeLabel.font = [UIFont fontWithName:@"loudhailer" size:30.0];
        _cityCodeLabel.text = @"v";
        _cityCodeLabel.textColor = [UIColor colorWithRed:(51.0f/255.0f) green:(51.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0];
        _cityCodeLabel.layer.borderColor = [UIColor colorWithRed:(51.0f/255.0f) green:(51.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0].CGColor;
        _cityCodeLabel.layer.borderWidth = 1.0;
        _cityNameLabel.text = @"Add New";
    }
    else{
        _cityCodeLabel.text=[cityString substringToIndex:1];
        _cityCodeLabel.font = [UIFont fontWithName:@"Aileron-Regular" size:25.0];
        _cityCodeLabel.textColor = [UIColor whiteColor];
        _cityNameLabel.text = cityString;
    }
}

@end
