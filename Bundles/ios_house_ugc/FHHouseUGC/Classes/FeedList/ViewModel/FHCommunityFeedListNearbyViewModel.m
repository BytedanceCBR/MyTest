//
//  FHCommunityFeedListNearbyViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListNearbyViewModel.h"
#import "FHUGCBaseCell.h"
#import "FHTopicListModel.h"

@interface FHCommunityFeedListNearbyViewModel () <UITableViewDelegate, UITableViewDataSource>

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
        int x = arc4random() % 100;
        int y = x % 2;
        [self.dataList addObject:[NSString stringWithFormat:@"%i", y]];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    FHUGCFeedListCellType type = [self.dataList[indexPath.row] integerValue];

    NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:type data:nil]);
    FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        Class cellClass = NSClassFromString(cellIdentifier);
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:nil];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self jumpToTopicList];
}

- (void)jumpToTopicList {
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://topic_list?community_id=%@", @"12345"];
    NSURL *openUrl = [NSURL URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
}

@end
