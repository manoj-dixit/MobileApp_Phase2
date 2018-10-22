//
//  RelayCell.m
//  LH2GO
//
//  Created by Himani Bathla on 13/07/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "RelayCell.h"

#define kNegativeXOffset -66
#define kAnimationDuration 0.2
static RelayCell *prevCell;
@interface RelayCell () <UIGestureRecognizerDelegate>{
    CGPoint _originalCenter;
    
}

@end
@implementation RelayCell

+ (instancetype)cellWithGesture:(BOOL)add {
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RelayCell" owner:self options:nil];
    RelayCell *cell = [objects objectAtIndex:0];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor lightGrayColor]);
    cell.layer.borderWidth = 2.0;
    if (add) {
        [cell addGesture];
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)addGesture {
    UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    recognizer.delegate = self;
    [_baseView addGestureRecognizer:recognizer];
}
//- (void)selectMe:(BOOL)selected andCell :(RelayCell *)cell{
////    _selectedLbl.hidden = !selected;
////    _selectedLbl.text = @"Selected";
//    cell.relayNameLbl.textColor = (selected) ? [_selectedLbl textColor] : [UIColor whiteColor];
//    if (selected) {
//        [cell.checkButton setBackgroundImage:[UIImage imageNamed:@"green_checked"] forState:UIControlStateNormal];
//    } else {
//        [cell.checkButton setBackgroundImage:[UIImage imageNamed:@"green_box"] forState:UIControlStateNormal];
//    }
//}
#pragma mark - horizontal pan gesture methods
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    // Check for horizontal gesture
    if (fabs(translation.x) > fabs(translation.y)) {
        return YES;
    }
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // if the gesture has just started, record the current centre location
        _originalCenter = _baseView.center;
       // [self beginDelete];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        //if user is not autherized to select stake
        CGPoint translation = [recognizer translationInView:_baseView];
        _baseView.center = CGPointMake(_originalCenter.x + translation.x/3.0, _originalCenter.y);
        
        if (_baseView.frame.origin.x >= 0) {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                _baseView.frame = CGRectMake(0, _baseView.frame.origin.y, _baseView.frame.size.width, _baseView.frame.size.height);
            }];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_baseView.frame.origin.x>=kNegativeXOffset/2) {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                _baseView.frame = CGRectMake(5, _baseView.frame.origin.y, _baseView.frame.size.width, _baseView.frame.size.height);
                
            } completion:^(BOOL finished) {
                if (self!=prevCell) {
                    [prevCell recetView];
                }
                prevCell = self;
            }];
            
        } else {
            [self recetView];
        }
    }
}

- (void)recetView{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        _baseView.frame = CGRectMake(kNegativeXOffset, _baseView.frame.origin.y, _baseView.frame.size.width, _baseView.frame.size.height);
    } completion:^(BOOL finished) {
        //        _usrimgView.backgroundColor = kColor(73, 103, 35, 1);//just commented this code we dont need to change any thing related to user image view
        _relayNameLbl.textColor = [UIColor whiteColor];
    }];
}

@end
