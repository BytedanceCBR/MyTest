//
//  FHCommunityFeedListNearbyViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListNearbyViewModel.h"

@interface FHCommunityFeedListNearbyViewModel ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation FHCommunityFeedListNearbyViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController {
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
        self.dataList = [[NSMutableArray alloc] init];
    
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    return self;
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    [super requestData:isHead first:isFirst];
    
    for (NSInteger i = 0; i < 50; i++) {
        [self.dataList addObject:[NSString stringWithFormat:@"附近的%li",(long)i]];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row < self.dataList.count){
        cell.textLabel.text = self.dataList[indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

@end
