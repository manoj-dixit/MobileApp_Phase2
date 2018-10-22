//
//  RelayCell.h
//  LH2GO
//
//  Created by Himani Bathla on 13/07/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RelayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UILabel *relayNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *selectedLbl;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bukiboxconstaraint;


+ (instancetype)cellWithGesture:(BOOL)add;


@end
