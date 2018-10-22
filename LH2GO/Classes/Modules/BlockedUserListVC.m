//
//  BlockedUserListVC.m
//  LH2GO
//
//  Created by Linchpin on 26/09/17.
//  Copyright © 2017 Kiwitech. All rights reserved.
//

#import "BlockedUserListVC.h"

@interface BlockedUserListVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *blockedUserList;
    NSMutableArray *blockersMutableList;
}
@end

@implementation BlockedUserListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Blocked Users";
    blockedUserList = nil;
    blockersMutableList = nil;
    blockersMutableList = [[NSMutableArray alloc]init];
    blockedUserList = [[NSArray alloc]init];

    [self addPanGesture];
    [self addLeftAndRightButton];
    [self fetchBlockedUsers];
    [self setNavBarTitle];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavBarTitle {
    
    // create title label
    UILabel * titleLabel = [[UILabel alloc]init]; //initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.text = @"Blocked Users";
    titleLabel.textColor=[UIColor whiteColor];
    [titleLabel sizeToFit];
    
    // set the label to the titleView of nav bar
    self.navigationItem.titleView = titleLabel;
}

-(void)addLeftAndRightButton{
    
    
    leftButton = [[UIBarButtonItem alloc]
                  initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(popView)];
    [leftButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"loudhailer" size:20.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    righttButton = nil;
    self.navigationItem.rightBarButtonItem = righttButton;
}

-(void)popView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)fetchBlockedUsers
{
    [blockersMutableList removeAllObjects];
    blockedUserList = [DBManager entities:@"User" pred:nil descr:nil  isDistinctResults:YES];
    for(User *u in blockedUserList)
    {
        if ([u.isBlocked isEqualToNumber:[NSNumber numberWithInteger:1]])
            [blockersMutableList addObject:u];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return blockersMutableList.count;
}

- (UITableViewCell *)tableView:(UITableView* )tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"BlockedUserList_cell";
    BlockedUserList_cell *cell = (BlockedUserList_cell* ) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    User *user = [blockersMutableList objectAtIndex:indexPath.row];
    cell.label_onCell.text = user.user_name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.btn_onCell.tag = 100+indexPath.row;
   [cell.btn_onCell addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
       return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPAD){
        cell.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return  44;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kRatio * 70;//tableView.rowHeight;// assuming that the image will stretch across the width of the screen
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}

- (void)buttonTapped:(UIButton *)button
{
    NSArray *arr = blockersMutableList;
    if (arr.count>=(button.tag-100)) {
    User *u = [arr objectAtIndex:(button.tag-100)];
//    dispatch_async(dispatch_get_main_queue(), ^{
       [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"blockedUser"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        [u setIsBlocked:[NSNumber numberWithInteger:0]];
        [DBManager save];
//    });
    if([self.blockedUsers containsObject:u]){
        [self.blockedUsers removeObject:u];
    }
    [self fetchBlockedUsers];
    
    dispatch_async(dispatch_get_main_queue(), ^{

    [_table_List reloadData];
    
    });
    }
}


@end
