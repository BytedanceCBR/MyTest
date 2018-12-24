//
//  FHSuggestionListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewModel.h"
#import "FHSuggestionListViewController.h"
#import "ToastManager.h"

@interface FHSuggestionListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic , weak) FHSuggestionListViewController *listController;
@property(nonatomic , weak) TTHttpTask *sugHttpTask;
@property(nonatomic , weak) TTHttpTask *historyHttpTask;
@property(nonatomic , weak) TTHttpTask *guessHttpTask;
@property(nonatomic , weak) TTHttpTask *delHistoryHttpTask;

@property (nonatomic, strong , nullable) NSArray<FHSuggestionResponseDataModel> *sugListData;
@property (nonatomic, strong , nullable) NSArray<FHSuggestionSearchHistoryResponseDataDataModel> *historyData;
@property (nonatomic, strong , nullable) NSMutableArray<FHGuessYouWantResponseDataDataModel> *guessYouWantData;

@end

@implementation FHSuggestionListViewModel

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.loadRequestTimes = 0;
        self.guessYouWantData = [NSMutableArray new];
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
        if (indexPath.row < self.historyData.count) {
            FHSuggestionSearchHistoryResponseDataDataModel *model  = self.historyData[indexPath.row];
            cell.textLabel.text = model.text;
        }
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

- (void)clearHistoryTableView {
    if (self.historyHttpTask) {
        [self.historyHttpTask cancel];
    }
    self.historyData = NULL;
    if (self.guessHttpTask) {
        [self.guessHttpTask cancel];
    }
    [self.guessYouWantData removeAllObjects];
    [self reloadHistoryTableView];
}

- (void)reloadSugTableView {
    if (self.listController.suggestTableView != NULL) {
        [self.listController.suggestTableView reloadData];
    }
}

- (void)reloadHistoryTableView {
    if (self.listController.historyTableView != NULL && self.loadRequestTimes >= 2) {
        [self.listController.historyTableView reloadData];
    }
}

#pragma mark - Request

- (void)requestSearchHistoryByHouseType:(NSString *)houseType {
    if (self.historyHttpTask) {
        [self.historyHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.historyHttpTask = [FHHouseListAPI requestSearchHistoryByHouseType:houseType class:[FHSuggestionSearchHistoryResponseModel class] completion:^(FHSuggestionSearchHistoryResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.historyData = model.data.data;
            [wself reloadHistoryTableView];
//            // 刷新数据
//            // 埋点？
        } else {
            
        }
    }];
}

- (void)requestGuessYouWant:(NSInteger)cityId houseType:(NSInteger)houseType {
    if (self.guessHttpTask) {
        [self.guessHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.guessHttpTask = [FHHouseListAPI requestGuessYouWant:cityId houseType:houseType class:[FHGuessYouWantResponseModel class] completion:^(FHGuessYouWantResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        if (model != NULL && error == NULL) {
            // 构建数据源
            [wself.guessYouWantData removeAllObjects];
            if (model.data.data.count > 0) {
                [wself.guessYouWantData addObjectsFromArray:model.data.data];
            }
            [wself reloadHistoryTableView];
        } else {
            
        }
    }];
}

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

// 删除历史记录
- (void)requestDeleteHistoryByHouseType:(NSString *)houseType {
    if (self.delHistoryHttpTask) {
        [self.delHistoryHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.delHistoryHttpTask = [FHHouseListAPI requestDeleteSearchHistoryByHouseType:houseType class:[FHSuggestionClearHistoryResponseModel class] completion:^(FHSuggestionClearHistoryResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            wself.historyData = NULL;
            [wself reloadHistoryTableView];
        } else {
            [[ToastManager manager] showToast:@"历史记录删除失败"];
        }
    }];
}

@end
