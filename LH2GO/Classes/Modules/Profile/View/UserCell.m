//
//  UserCell.m
//  LH2GO
//
//  Created by Prakash Raj on 18/03/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "UserCell.h"

#define kNegativeXOffset -66
#define kAnimationDuration 0.2

static UserCell *prevCell;

@interface UserCell ()<UIGestureRecognizerDelegate>
{
    __weak IBOutlet UIView *_baseView;
    __weak IBOutlet UIImageView *_usrimgView;
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UILabel *_selectedLbl;
    CGPoint _originalCenter;
    User *tempUser;
}

@end

@implementation UserCell

+ (instancetype)cellWithGesture:(BOOL)add
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
    UserCell *cell = [objects objectAtIndex:0];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (add)
    {
        [cell addGesture];
    }
    return cell;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)addGesture
{
    UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    recognizer.delegate = self;
    [_baseView addGestureRecognizer:recognizer];
}

- (void)selectMe:(BOOL)selected
{
    _selectedLbl.hidden = !selected;
    _selectedLbl.text = @"Selected";
    _titleLbl.textColor = (selected) ? [_selectedLbl textColor] : [UIColor whiteColor];
}

- (void)inviteMe:(BOOL)selected
{
    _selectedLbl.hidden = !selected;
    _selectedLbl.text = @"pending";
    _titleLbl.textColor = (selected) ? [_selectedLbl textColor] : [UIColor whiteColor];
}

- (void)displayUser:(User *)user
{
    tempUser = user;
    _titleLbl.text = user.user_name;
    [_usrimgView sd_setImageWithURL:[NSURL URLWithString:user.picUrl]placeholderImage:nil];
}

- (void)displayEmail:(NSString *)email
{
    _titleLbl.text = email;
}

#pragma mark - horizontal pan gesture methods
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        return NO;
    }
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    // Check for horizontal gesture
    if (fabs(translation.x) > fabs(translation.y))
    {
        return YES;
    }
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // if the gesture has just started, record the current centre location
        _originalCenter = _baseView.center;
        [self beginDelete];
    }
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        //if user is not autherized to select stake
            CGPoint translation = [recognizer translationInView:_baseView];
            _baseView.center = CGPointMake(_originalCenter.x + translation.x/3.0, _originalCenter.y);
        if (_baseView.frame.origin.x >= 0)
        {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                _baseView.frame = CGRectMake(0, _baseView.frame.origin.y, _baseView.frame.size.width, _baseView.frame.size.height);
            }];
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_baseView.frame.origin.x>=kNegativeXOffset/2)
        {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                _baseView.frame = CGRectMake(5, _baseView.frame.origin.y, _baseView.frame.size.width, _baseView.frame.size.height);
            } completion:^(BOOL finished) {
            if (self!=prevCell)
            {
                [prevCell recetView];
            }
                prevCell = self;
            }];
        }
        else
        {
            [self recetView];
        }
    }
}

- (void)recetView
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        _baseView.frame = CGRectMake(kNegativeXOffset, _baseView.frame.origin.y, _baseView.frame.size.width, _baseView.frame.size.height);
    } completion:^(BOOL finished) {
        _titleLbl.textColor = [UIColor whiteColor];
    }];
}

- (void)beginDelete
{
    _titleLbl.textColor = kColor(237, 28, 36, 1);
}

#pragma mark ---IBActions---

- (IBAction)deleteButtonClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(deleteUser: withTableCell:)])
    {
        [_delegate deleteUser:tempUser withTableCell:self];
    }
}

@end
