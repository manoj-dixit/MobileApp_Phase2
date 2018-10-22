//
//  RelayView.h
//  LH2GO
//
//  Created by Himani Bathla on 12/07/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol RelayListDelegate <NSObject>
@optional
- (void)didCancelView;
-(void)relaySelectedWithMacId : (NSMutableArray *)macIds;
//- (void)didInviteUsers:(NSArray *)users andEmails:(NSArray *)emails;
@end

@interface RelayView : UIView{
    
}
@property (weak, nonatomic) IBOutlet UITableView *listOfRelays;
@property (weak, nonatomic) IBOutlet UIButton *doneClicked;
@property (weak, nonatomic) IBOutlet UIButton *cancelClicked;
@property (nonatomic, strong) NSMutableArray *relaysList;
@property (weak, nonatomic) IBOutlet UIButton *advancedSettings;

@property (weak, nonatomic) IBOutlet UILabel *selectBboxLbl;
@property (weak, nonatomic) IBOutlet UIView *optionsView;

- (void)drawRectForView:(NSMutableArray *)yourArray;

@property (strong, nonatomic) NSString *stringValue;
//@property (strong, nonatomic) CommsViewController *comsObj;
@property (nonatomic, weak) id <RelayListDelegate> relayDelegate;
- (void)reload;
//- (void)getUsersAll:(Network*)selectedNetwork;
//- (void)getUsersNotInGroup:(Group*)group;
//- (id)initWithFrame:(CGRect)frame andViewController: (CommsViewController *)comVC;
- (id)initWithFramer:(CGRect)frame andController:(UIViewController *)obj;

@end



