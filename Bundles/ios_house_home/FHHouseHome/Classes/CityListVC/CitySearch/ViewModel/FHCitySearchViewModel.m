//
//  FHCitySearchViewModel.m
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import "FHCitySearchViewModel.h"
#import "ToastManager.h"
#import "FHHouseTypeManager.h"
#import "FHUserTracker.h"
#import "FHHomeRequestAPI.h"
#import "FHCitySearchModel.h"
#import "FHBaseModelProtocol.h"
#import "FHCitySearchItemCell.h"

@interface FHCitySearchViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic , weak) FHCitySearchViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;

@property (nonatomic, strong , nullable) NSArray<FHCitySearchDataDataModel> *cityList;

@end

@implementation FHCitySearchViewModel

-(instancetype)initWithController:(FHCitySearchViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
    }
    return self;
}

- (void)clearTableView {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    self.cityList = NULL;
    [self.listController.tableView reloadData];
}

#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cityList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.cityList.count) {
        
        FHCitySearchItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fh_city_search_cell"];
        if (cell) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            FHCitySearchDataDataModel *model = (FHCitySearchDataDataModel *)self.cityList[indexPath.row];
            cell.cityNameLabel.text = model.name;
            cell.enabled = model.enable;
        }
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)requestSearchCityByQuery:(NSString *)query {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHomeRequestAPI requestCitySearchByQuery:query class:[FHCitySearchModel class] completion:^(FHCitySearchModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.cityList = model.data.data;
        } else {
            wself.cityList = NULL;
        }
        [wself.listController.tableView reloadData];
    }];
}

@end
