//
//  MsgPreviewCell.h
//  LH2GO
//
//  Created by Linchpin on 31/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgPreviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle_msg;
@property (weak, nonatomic) IBOutlet UIView *view_msgPrev;
@property (weak, nonatomic) IBOutlet UITextView *txtview_msgPrev;
@end
