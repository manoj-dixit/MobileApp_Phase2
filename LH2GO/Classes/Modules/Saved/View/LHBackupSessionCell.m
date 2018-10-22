//
//  LHBackupSessionCell.m
//  LH2GO
//
//  Created by Sumit Kumar on 08/04/15.
//  Copyright (c) 2015 Kiwitech. All rights reserved.
//

#import "LHBackupSessionCell.h"

@interface LHBackupSessionCell()
{
    __weak IBOutlet UILabel *_name;
    __weak IBOutlet UILabel *_date;
    __weak IBOutlet UIButton *_btn_notes;

}

@end

@implementation LHBackupSessionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    _name.font = [_name.font fontWithSize:[Common setFontSize:_name.font]];

    _date.font = [_date.font fontWithSize:[Common setFontSize:_date.font]];
    _btn_notes.titleLabel.font = [_btn_notes.titleLabel.font fontWithSize:[Common setFontSize:_btn_notes.titleLabel.font]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (instancetype)cell
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LHBackupSessionCell" owner:self options:nil];
    LHBackupSessionCell *cell = [objects objectAtIndex:0];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

+ (instancetype)cellAtIndex:(NSInteger)index
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LHBackupSessionCell" owner:self options:nil];
    LHBackupSessionCell *cell = [objects objectAtIndex:index];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

NSDateFormatter *formatter;
-(NSDateFormatter *)getDateFormate//performance reason in cellForRow
{
    if (formatter)
    {
        return formatter;
    }
    else
    {
        formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM/dd/YYYY-hh:mm a"];
        return formatter;
    }
}

- (void)displayNotification:(ShoutBackup *)shoutBackup
{    
    _name.text = shoutBackup.backupName;
    //[_name setFont:[UIFont fontWithName:@"Aileron-Regular" size:14.0]];
    NSString *str = [[self getDateFormate] stringFromDate:shoutBackup.backUpDate];
    _date.text = str;
    if (IS_IPHONE_X) {
        [_name setFont:[UIFont fontWithName:@"Aileron-Regular" size:14.0]];
        [_date setFont:[UIFont fontWithName:@"Aileron-Regular" size:14.0]];
    }
}

#pragma mark -- IBoutlets ---

- (IBAction)viewBackupsClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(showBackupsonIndex:)])
    {
        [_delegate showBackupsonIndex:self.tag];
    }
}

- (IBAction)editBackupClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(editBackuponIndex:)])
    {
        [_delegate editBackuponIndex:self.tag];
    }
}

@end
