//
//  FHSuggestionListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewModel.h"
#import "FHSuggestionListViewController.h"

@interface FHSuggestionListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic , weak) FHSuggestionListViewController *listController;
@property(nonatomic , weak) TTHttpTask *sugHttpTask;

@property (nonatomic, strong , nullable) NSArray<FHSuggestionResponseDataModel> *sugListData;
@property (nonatomic, strong , nullable) NSArray<FHSuggestionSearchHistoryResponseDataDataModel> *historyData;

@end

@implementation FHSuggestionListViewModel

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
    }
    return self;
}


#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        // 历史记录
        return self.historyData.count;
    } else if (tableView.tag == 2) {
        // 联想词
        return self.sugListData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        // 历史记录
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestItemCell" forIndexPath:indexPath];
        return cell;
    } else if (tableView.tag == 2) {
        // 联想词
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestItemCell" forIndexPath:indexPath];
        if (indexPath.row < self.sugListData.count) {
            FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
            cell.textLabel.text = model.text;
        }
        return cell;
    }
}

#pragma mark - reload

- (void)clearSugTableView {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.sugListData = NULL;
    [self reloadSugTableView];
}

- (void)reloadSugTableView {
    if (self.listController.suggestTableView != NULL) {
        [self.listController.suggestTableView reloadData];
    }
}

- (void)reloadHistoryTableView {
    if (self.listController.historyTableView != NULL) {
        [self.listController.historyTableView reloadData];
    }
}

#pragma mark - Request

- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.sugHttpTask = [FHHouseListAPI requestSuggestionCityId:cityId houseType:houseType query:query class:[FHSuggestionResponseModel class] completion:^(FHSuggestionResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.sugListData = model.data;
            [wself reloadSugTableView];
            // 刷新数据
            // 埋点？
        } else {
            
        }
    }];
}


@end
