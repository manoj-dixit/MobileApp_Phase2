//
//  BukiFeedView.h
//  LH2GO
//
//  Created by Parul Mankotia on 01/11/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"

@interface BukiFeedView : UIView<UITableViewDelegate,UITableViewDataSource,ChannelDetailCellDelegate>{
    NSMutableArray *bukiFeedsArray;
}

@property(nonatomic, weak) IBOutlet UITableView *feedTableView;

@end
