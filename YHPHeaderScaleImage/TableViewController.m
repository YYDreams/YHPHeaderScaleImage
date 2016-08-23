//
//  TableViewController.m
//  YHPHeaderScaleImage
//
//  Created by LOVE on 16/8/22.
//  Copyright © 2016年 LOVE. All rights reserved.
//

#import "TableViewController.h"
#import "UIScrollView+HeaderScaleImage.h"
@interface TableViewController ()

@end

@implementation TableViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self  setupTableView];
    
}
#pragma mark - OBJMethod
- (void)setupTableView{
    
    self.tableView.yhp_headerScaleImage = [UIImage imageNamed:@"background"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *headerView = [[UIView alloc]init];
    self.tableView.yhp_headerScaleImageHeight = 300;
    headerView.frame = CGRectMake(0, 0, 0, self.tableView.yhp_headerScaleImageHeight);
//    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
}

#pragma mark - <UITableViewDataSource>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 30;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    cell.textLabel.textColor = [UIColor redColor];

    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row + 1];
    return cell;
}
@end
