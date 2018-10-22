//
//  AttachmentOptionView.h
//  LH2GO
//
//  Created by Linchpin on 25/07/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachmentOptionView : UIView

@property (strong, nonatomic) IBOutlet UIView *vw_tab0;
@property (strong, nonatomic) IBOutlet UIView *vw_tab1;
@property (strong, nonatomic) IBOutlet UIView *vw_tab2;
@property (strong, nonatomic) IBOutlet UIView *vw_tab3;

@property (strong, nonatomic) IBOutlet UILabel *lbl_tab0;
@property (strong, nonatomic) IBOutlet UILabel *lbl_tab1;
@property (strong, nonatomic) IBOutlet UILabel *lbl_tab2;
@property (strong, nonatomic) IBOutlet UILabel *lbl_tab3;
@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab0;
@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab1;
@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab2;
@property (strong, nonatomic) IBOutlet UILabel *lblIcon_tab3;

+ (AttachmentOptionView *)tabbarWithFrame:(CGRect)frame;
- (void)addTarget:(id)target andSelector:(SEL)selector;

@end
