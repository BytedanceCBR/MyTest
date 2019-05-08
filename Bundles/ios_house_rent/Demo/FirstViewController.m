//
//  FirstViewController.m
//  Demo
//
//  Created by leo on 2018/11/16.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FirstViewController.h"
#import <Masonry/Masonry.h>
#import "MockRentHouseListDS.h"
#import <FHHouseRent/FHHouseRent.h>
#import "FHBTableViewDataSource.h"
#import <MJRefresh/MJRefresh.h>
@interface FirstViewController () <UIScrollViewDelegate>
{
    FHBTableViewDataSource* _houseRentDataSource;
    FHHouseRentCellCoordinator* _cellCoordinator;
}
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIScrollView* containerView;
@property (nonatomic, strong) MockRentHouseListDS* dataSource;
@property (nonatomic, strong) NestScrollViewControl* control;
@end

@implementation FirstViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[MockRentHouseListDS alloc] init];
    _cellCoordinator = [[FHHouseRentCellCoordinator alloc] init];
    _houseRentDataSource = [[FHBTableViewDataSource alloc] initWithCoordinator:_cellCoordinator withRespoitory:_dataSource];
    _containerView.showsHorizontalScrollIndicator = NO;
    self.containerView = [[UIScrollView alloc] init];
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide);
        } else {
            make.top.mas_equalTo(20);
        }
        make.left.right.bottom.mas_equalTo(self.view);
    }];

    FHSpringboardView* springboard = [[FHSpringboardView alloc] init];
    FHSpringboardIconItemView* item = [[FHSpringboardIconItemView alloc] init];
    item.nameLabel.text = @"整租";
    item.iconView.image = [UIImage imageNamed:@"group-1"];
    FHSpringboardIconItemView* item1 = [[FHSpringboardIconItemView alloc] init];
    item1.nameLabel.text = @"合租";
    item1.iconView.image = [UIImage imageNamed:@"group-3"];
    FHSpringboardIconItemView* item2 = [[FHSpringboardIconItemView alloc] init];
    item2.nameLabel.text = @"整租";
    item2.iconView.image = [UIImage imageNamed:@"group-1"];
    FHSpringboardIconItemView* item3 = [[FHSpringboardIconItemView alloc] init];
    item3.nameLabel.text = @"合租";
    item3.iconView.image = [UIImage imageNamed:@"group-3"];
    [springboard addItems:@[item, item1, item2, item3]];

    [_containerView addSubview:springboard];
    [springboard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(109);
        make.left.right.top.mas_equalTo(self.containerView);
    }];

    self.tableView = [[UITableView alloc] init];
    _tableView.dataSource = _houseRentDataSource;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_containerView addSubview:_tableView];
    CGFloat screenHight = [[UIScreen mainScreen] bounds].size.height - 100;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(screenHight);
        make.top.mas_equalTo(springboard.mas_bottom);
        make.width.mas_equalTo(self.containerView);
        make.left.right.bottom.mas_equalTo(self.containerView);
    }];
    [_tableView registerClass:[FHHouseRentCell class] forCellReuseIdentifier:@"item"];

    self.control = [NestScrollViewControl instanceWithMajorScrollView:_containerView
                                                   withNestScrollView:_tableView];
    _control.thresholdYOffset = 109;

    MJRefreshAutoFooter* footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    _tableView.mj_footer = footer;
}

-(void)loadMore {
    NSLog(@"loadMore");

    [_tableView.mj_footer endRefreshingWithNoMoreData];
}




@end
