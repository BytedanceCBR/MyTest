//
//  FHEncyclopediaListViewModel.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/13.
//

#import "FHEncyclopediaListViewModel.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCBaseCell.h"
#import "FHHouseUGCAPI.h"
#import "TTHttpTask.h"
#import "FHFeedListModel.h"
#import "ToastManager.h"
#import "UIScrollView+Refresh.h"
#import "FHEnvContext.h"
#import "EncyclopediaModel.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import "FHHouseDislikeView.h"
#import "FHUGCEncyclopediaLynxCell.h"
#import "FHUGCencyclopediaTracerHelper.h"
#import "FHUtils.h"
#import "FHLynxManager.h"


@interface FHEncyclopediaListViewModel()<UITableViewDelegate,UITableViewDataSource,FHUGCEncyclopediaLynxCellDelegate>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, weak)FHEncyclopediaListViewController *listController;
@property(nonatomic, strong)FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong)NSMutableArray *dataList;
@property(nonatomic, weak)TTHttpTask *requestTask;
@property(nonatomic, copy)NSString *categoryId;
@property(nonatomic, strong)FHUGCencyclopediaTracerHelper *tracerHelper;
@property(nonatomic, strong)EncyclopediaDataModel *encyclopediaModel;
@property (nonatomic, strong)NSMutableDictionary *elementShowCaches;

@end
@implementation FHEncyclopediaListViewModel
- (instancetype)initWithWithController:(FHEncyclopediaListViewController *)viewController tableView:(UITableView *)table userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.tableView = table;
        self.dataList = [[NSMutableArray alloc] init];
        self.elementShowCaches = [NSMutableDictionary new];
        self.categoryId = @"f_house_encyclopedia";
        [self configTableView];
        [self configTracerHelper];
    }
    return self;
}

- (void)configTracerHelper {
    _tracerHelper = [[FHUGCencyclopediaTracerHelper alloc]init];
}

- (void)setTracerModel:(FHTracerModel *)tracerModel {
    _tracerModel = tracerModel;
    _tracerHelper.tracerModel = tracerModel;
}
- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if(self.listController.isLoadingData){
        return;
    }
    NSString *refreshType = @"be_null";
    if (isHead) {
        [self.tracerHelper trackCategoryRefresh];
    }
    self.listController.isLoadingData = YES;
    if(isFirst){
        [self.listController startLoading];
    }
    __weak typeof(self) wself = self;
    NSInteger listCount = self.dataList.count;
    if(isFirst){
        listCount = 0;
    }
    //
    NSInteger behotTime = [[self currentTimeStr] integerValue];
    NSString *groupId = NULL;
    if(!isHead && listCount > 0){
        NSDictionary *data = [self.dataList lastObject];
        behotTime = [NSString stringWithFormat:@"%@",data[@"publish_time"]].integerValue  ;
        groupId = data[@"group_id"];
    }
    //
    if(isHead && listCount > 0){
        NSDictionary *data = [self.dataList firstObject];
        behotTime = [NSString stringWithFormat:@"%@",data[@"publish_time"]].integerValue  ;
        groupId = data[@"group_id"];
    }
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }
    self.requestTask = [FHHouseUGCAPI requestEncyclopediaListWithCategory:self.categoryId channelid:self.channel_id lastGroupId:groupId behotTime:behotTime loadMore:!isHead isFirst:isFirst listCount:10 extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wself.listController.isLoadingData = NO;
        [wself.tableView finishPullDownWithSuccess:YES];
        
        if (error) {
            //TODO: show handle error
            if(isFirst){
                if(error.code != -999){
                    [wself.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
                    wself.listController.showenRetryButton = YES;
                    wself.refreshFooter.hidden = YES;
                }
            }else{
                [[ToastManager manager] showToast:@"网络异常"];
                [wself updateTableViewWithMoreData:YES];
            }
            return;
        }
        EncyclopediaDataModel *encyclopediaModel = [(EncyclopediaModel *)model data];
        wself.encyclopediaModel = encyclopediaModel;
        if(encyclopediaModel){
            if(isHead){
                if(encyclopediaModel.hasMore){
                    [wself.dataList removeAllObjects];
                }
                wself.tableView.hasMore = YES;
            }else{
                wself.tableView.hasMore = encyclopediaModel.hasMore;
            }
            if(isFirst){
                [wself.dataList removeAllObjects];
            }
            NSArray *result = encyclopediaModel.items;
//            [wself convertModel:encyclopediaModel.items isHead:isHead];
            if(isHead){
                [wself.dataList insertObjects:result atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
            }else {
                [wself.dataList addObjectsFromArray:result];
            }
            wself.listController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                [wself updateTableViewWithMoreData:wself.tableView.hasMore];
                [wself.listController.emptyView hideEmptyView];
            }else{
                [wself.listController.emptyView showEmptyWithTip:@"暂无新内容" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:YES];
                //                wself.viewController.showenRetryButton = YES;
                wself.refreshFooter.hidden = YES;
            }
            [wself.tableView reloadData];
            NSString *refreshTip = [NSString stringWithFormat:@"已为您更新 %ld 条数据",result.count];
            if (isHead && result.count > 0 && ![refreshTip isEqualToString:@""] && !wself.isRefreshingTip){
                wself.isRefreshingTip = YES;
                [wself.listController showNotify:refreshTip completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wself.isRefreshingTip = NO;
                    });
                }];
            }
        }
    }];
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[FHUGCEncyclopediaLynxCell class] forCellReuseIdentifier:@"FHUGCEncyclopediaLynxCell"];
    //    [FHEncyclopediaCellHelper registerAllCellsWithTable:self.tableView];
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    self.refreshFooter.hidden = YES;
    // 下拉刷新
    [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
        wself.isRefreshingTip = NO;
        [wself.listController hideImmediately];
        [wself requestData:YES first:NO];
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        NSString *cellIdentifier = @"FHUGCEncyclopediaLynxCell";
        FHUGCEncyclopediaLynxCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        [cell refreshWithData:self.dataList[indexPath.row]];
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
        if (!self.elementShowCaches[tempKey]) {
            self.elementShowCaches[tempKey] = @(YES);
            [self.tracerHelper trackClientShow:self.dataList[indexPath.row]];
        }
    }
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001f)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = (NSDictionary *)self.dataList[indexPath.row];
    NSArray *image_list = item[@"image_list"];
    if (image_list.count>0) {
        return 180;
    }
    return 140;
}



- (NSInteger)getCellIndex:(NSDictionary *)checkItem {
    for (NSInteger i = 0; i < self.dataList.count; i++) {
        NSDictionary *item = self.dataList[i];
        if([item[@"group_id"] isEqualToString:checkItem[@"group_id"]]){
            return i;
        }
    }
    return -1;
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore) {
        [self.tableView.mj_footer endRefreshing];
    }else {
        [self.refreshFooter setUpNoMoreDataText:@"暂无更多内容" offsetY:-30];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}


- (void)dislikeConfirm:(NSDictionary *)data cell:(FHUGCBaseCell *)cell {
    NSInteger row = [self getCellIndex:data];
    if(row < self.dataList.count && row >= 0){
        [self.dataList removeObjectAtIndex:row];
        if(self.dataList.count == 0){
            self.tableView.hasMore = NO;
            self.tableView.mj_footer.hidden = YES;
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            [self.tableView reloadData];
        }else{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:1];
            //            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //当数据少于一页的时候，拉下一页数据填充
            [self.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.dataList.count < 5 && self.tableView.hasMore){
                        [self requestData:YES first:NO];
                    }
                });
            });
        }
    }
}

- (void)tapCellAction:(NSDictionary *)data {
    NSString *openUrl = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&item_id=%@",data[@"group_id"],data[@"item_id"]];
    NSMutableDictionary *reportParams = [[NSMutableDictionary alloc]init];
    [reportParams setValue:self.tracerModel.enterFrom?:@"be_null" forKey:@"enter_from"];
    [reportParams setValue:self.tracerModel.originFrom?:@"be_null" forKey:@"origin_from"];
    [reportParams setValue:data[@"logPb"]?:@"be_null" forKey:@"log_pb"];
    openUrl = [openUrl stringByAppendingString:[NSString stringWithFormat:@"&report_params=%@",[FHUtils getJsonStrFrom:reportParams]]];
     [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:nil];
    __block NSInteger *index = -1;
     [self.dataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         NSDictionary *dic = (NSDictionary *)obj;
         if ([dic[@"group_id"] isEqualToString:data[@"group_id"]]) {
             index = idx;
         }
     }];
}
//获取当前时间戳
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

@end
