//
//  CutomPopOverView.h
//  LH2GO
//
//  Created by Parul Mankotia on 13/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomPopOverViewDelegate<NSObject>
-(void)sendBackSelectedRowForCell:(NSString*)actionType withRow:(NSIndexPath*)indexPath;
@end

@interface CustomPopOverView : UIView

@property(nonatomic,strong) NSIndexPath *indexPathForRow;

@property(nonatomic,weak) IBOutlet UILabel *exitGroupLabel;
@property(nonatomic,weak) IBOutlet UILabel *deleteGroupLabel;
@property(nonatomic,weak) IBOutlet UILabel *manageGroupLabel;
@property(nonatomic,weak) IBOutlet UIButton *exitGroupButton;
@property(nonatomic,weak) IBOutlet UIButton *deleteGroupButton;
@property(nonatomic,weak) IBOutlet UIButton *manageGroupButton;

-(IBAction)exitGroupButtonAction:(UIButton*)sender;
-(IBAction)deleteGroupButtonAction:(UIButton*)sender;
-(IBAction)manageGroupButtonAction:(UIButton*)sender;

@property (weak,nonatomic) id<CustomPopOverViewDelegate>delegate;

@end
