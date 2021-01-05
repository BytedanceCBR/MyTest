//
//  FHFloorPanListCollectionCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2021/1/4.
//

#import "FHFloorPanListCollectionCell.h"
#import "FHFloorPanListDetailViewModel.h"
#import "FHHomeBaseTableView.h"
#import "UIColor+Theme.h"

@interface FHFloorPanListCollectionCell ()
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) FHFloorPanListDetailViewModel *viewModel;
@end

@implementation FHFloorPanListCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initTableView];
    }
    return self;
}

- (void)initTableView {
    self.tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
    }

    [self.contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.contentView);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [self.tableView setBackgroundColor:[UIColor themeGray7]];
}

-(void)refreshDataWithItemArray:(NSArray *)itemArray subPageParams:(NSDictionary *)subPageParams {
    self.viewModel = [[FHFloorPanListDetailViewModel alloc] initWithTableView:self.tableView itemArray:itemArray subPageParams:subPageParams];
}

@end
