//
//  FHSecondHouseListViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHSecondHouseListViewModel.h"
#import <MJRefresh.h>
#import "NIHRefreshCustomFooter.h"
#import "TTHttpTask.h"
#import "FHHouseListAPI.h"
#import "FHSearchHouseModel.h"

#import "FHSingleImageInfoCell.h"
#import "FHPlaceHolderCell.h"
#import "FHHouseListViewController.h"
#import "TTReachability.h"
#import "FHMainManager+Toast.h"

@interface FHSecondHouseListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic , strong) FHErrorView *maskView;

@property(nonatomic, weak) FHHouseListViewController *listVC;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) NIHRefreshCustomFooter *refreshFooter;
@property(nonatomic , weak) TTHttpTask * requestTask;
@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , copy) NSString *searchId;

@property (nonatomic , assign) BOOL isRefresh;
@property (nonatomic , copy) NSString *query;
@property (nonatomic , copy) NSString *condition;
@property (nonatomic , assign) BOOL needEncode;

@end


@implementation FHSecondHouseListViewModel

-(void)setMaskView:(FHErrorView *)maskView {
    
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        
        [wself loadData:wself.isRefresh withQuery:wself.query condition:wself.condition needEncode:wself.needEncode];
    };
}

-(instancetype)initWithTableView:(UITableView *)tableView viewControler:(FHHouseListViewController *)vc routeParam:(TTRouteParamObj *)paramObj {

    self = [super init];
    if (self) {

        _listVC = vc;
        self.houseList = [NSMutableArray array];
        self.listVC.hasValidateData = NO;
        self.isRefresh = YES;
        self.tableView = tableView;
        
        [self configTableView];
        
    }
    return self;
}

-(void)configTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    __weak typeof(self)wself = self;
    self.refreshFooter = [NIHRefreshCustomFooter footerWithRefreshingBlock:^{
        wself.isRefresh = NO;
        [wself loadData:wself.isRefresh withQuery:wself.query condition:wself.condition needEncode:wself.needEncode];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    
    [self.tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kFHHouseListCellId];
    [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kFHHouseListPlaceholderCellId];

}
-(void)loadData:(BOOL)isRefresh withQuery:(NSString *)query condition:(NSString *)condition needEncode:(BOOL )needEncode
{
    self.query = query;
    self.condition = condition;
    self.needEncode = needEncode;
    
    NSMutableDictionary *param = [NSMutableDictionary new];

    if (self.searchId) {
        param[@"search_id"] = self.searchId;
    }

    if (needEncode) {

        query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    if (isRefresh) {
        
        [self.houseList removeAllObjects];
        [self.tableView reloadData];
        self.tableView.scrollEnabled = NO;
        self.tableView.mj_footer.hidden = YES;
    }
    
    if (![TTReachability isNetworkConnected]) {
        if (isRefresh) {
            [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            [self showMaskView:YES];
        }else{
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    __weak typeof(self) wself = self;

    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:param offset:self.houseList.count searchId:self.searchId sugParam:condition class:[FHSearchHouseModel class] completion:^(FHSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
  
        if (!wself) {
            return ;
        }

        wself.tableView.mj_footer.hidden = NO;
        wself.tableView.scrollEnabled = YES;

        FHSearchHouseDataModel *houseModel = model.data;

        if (!error && houseModel) {
            wself.searchId = houseModel.searchId;
//            if (showLoading) {
//                [wself addHouseListShowLog:wself.neighbor houseListModel:houseModel];
//            }
//
            if (wself.houseList.count == 0) {
                //first page
//                wself.currentNeighbor.onSaleCount = houseModel.total;
//                [wself.headerView updateWithMode:wself.currentNeighbor houseType:FHHouseTypeRentHouse];

                NSString *toast = [NSString stringWithFormat:@"共找到%@套房源",houseModel.total];
                if (wself.viewModelDelegate) {
                    [wself.viewModelDelegate showNotify:toast inViewModel:wself];
                }
            }

            [wself.houseList addObjectsFromArray:houseModel.items];
            wself.listVC.hasValidateData = wself.houseList.count > 0;
            [wself.tableView reloadData];
            if (houseModel.hasMore) {
                [wself.tableView.mj_footer endRefreshing];
            }else{
                [wself.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            if (wself.houseList.count == 0) {
                //没有数据 提示数据走丢了
                NSString *tip = nil;
                BOOL showRetry = YES;
//                if ([wself.configModel.conditionQuery containsString:@"&"]) {
//                    tip = @"没有找到相关信息，换个条件试试吧~";
//                    showRetry = NO;
//                }else{
//                    tip = @"数据走丢了";
//                }

                [wself.maskView showEmptyWithTip:tip errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:showRetry];
                [wself showMaskView:YES];
            }else{
                [wself showMaskView:NO];
            }
        }else {
            
            [wself.tableView.mj_footer endRefreshing];

            if (error) {
                
                if (wself.houseList.count > 0) {
                    
                    [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
                    [wself showMaskView:NO];

                }else {
                    [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
                    [wself showMaskView:YES];
                }

            }else{
                [wself showMaskView:NO];
            }
        }
    }];

    self.requestTask = task;
//    if (!showLoading) {
//        [self addHouseListLoadMoreLog];
//    }



}

-(void)showMaskView:(BOOL)show
{
    self.maskView.hidden = !show;
    
}


#pragma mark - filter delegate
-(void)onConditionChanged:(NSString *)condition
{
    NSLog(@"zjing - onConditionChanged condition-%@",condition);
}

-(void)onConditionWillPanelDisplay
{
    NSLog(@"onConditionWillPanelDisplay");

}



#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listVC.hasValidateData ? self.houseList.count : 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listVC.hasValidateData) {

        FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListCellId];
        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
        id model = self.houseList[indexPath.row];
        if ([model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
            
            [cell updateWithModel:model isLastCell:isLastCell];
        }
        return cell;
        
    }else {
        
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListPlaceholderCellId];
        cell.topOffset = indexPath.row == 0 ? 20.0 : 0.0;
        return cell;

    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self addHouseShowLog:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listVC.hasValidateData) {

        if (indexPath.row == self.houseList.count -1) {
            return 125;
        }
        return 105;
    }
    
    return indexPath.row == 0 ? 125 : 105;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    id model = self.houseList[indexPath.row];
    if([model isKindOfClass:[FHSearchHouseDataItemsModel class]]){
        FHSearchHouseDataItemsModel *houseModel = (FHSearchHouseDataItemsModel *)model;
//        if (self.listController.showHouseDetailBlock) {
//            self.listController.showHouseDetailBlock(model,indexPath.row);
//        }
    }
}



@end
