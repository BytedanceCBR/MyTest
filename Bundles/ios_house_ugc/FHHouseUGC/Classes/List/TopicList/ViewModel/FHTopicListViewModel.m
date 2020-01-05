//
// Created by zhulijun on 2019-06-03.
//

#import "FHTopicListViewModel.h"
#import "TTHttpTask.h"
#import "FHTopicListController.h"
#import "FHTopicCell.h"
#import "TTAccountLoginPCHHeader.h"
#import "FHHouseUGCAPI.h"
#import "FHTopicListModel.h"
#import "MJRefreshConst.h"
#import "TTReachability.h"
#import "FHRefreshCustomFooter.h"
#import "ToastManager.h"
#import "UIScrollView+Refresh.h"
#import "FHUserTracker.h"

@interface FHTopicListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHTopicListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;

@end

@implementation FHTopicListViewModel

- (instancetype)initWithController:(FHTopicListController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataList = [NSMutableArray array];
    }
    return self;
}

- (void)requestData:(BOOL)isRefresh {
    if (![TTReachability isNetworkConnected]) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        return;
    }

    WeakSelf;
    [FHHouseUGCAPI requestAllForumWithClass:FHTopicListResponseModel.class completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        StrongSelf;
        
        if (model) {
            if (isRefresh) {
                [wself.dataList removeAllObjects];
                [wself.tableView finishPullDownWithSuccess:YES];
            } else {
                [wself.tableView.mj_footer endRefreshing];
            }

            FHTopicListResponseModel *responseModel = model;

            [wself.dataList addObjectsFromArray:responseModel.data.list];
            wself.tableView.hidden = NO;
            if(wself.dataList.count <= 0) {
                [wself.viewController.emptyView showEmptyWithTip:@"话题暂未开通" errorImage:[UIImage imageNamed:@"group-9"] showRetry:NO];
            } else {
                [wself.viewController.emptyView hideEmptyView];
            }
            [wself.tableView reloadData];
        } else {
            if (isRefresh) {
                [wself.tableView finishPullDownWithSuccess:NO];
            } else {
                [wself.tableView.mj_footer endRefreshing];
            }
            if (isRefresh) {
                wself.tableView.hidden = YES;
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            }
            [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        }
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row < 0 || indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHTopicListResponseDataListModel *item = [self.dataList objectAtIndex:indexPath.row];
    
    // 点击话题内容
    NSMutableDictionary *param = self.viewController.tracerDict.mutableCopy;
    param[UT_CATEGORY_NAME] = [self categoryName];
    param[UT_LOG_PB] = item.logPb?:UT_BE_NULL;
    param[@"rank"] = @(indexPath.row);
    param[@"concern_id"] = item.forumId;
    param[@"click_position"] = @"topic_select";
    TRACK_EVENT(@"click_select_topic", param);
    // ---
    
    if([self.viewController.delegate respondsToSelector:@selector(didSelectedHashtag:)]) {
        [self.viewController.delegate didSelectedHashtag:item];
        [self.viewController goBack];
    } else {
        if(item.schema.length > 0) {
            NSURL *url = [NSURL URLWithString:item.schema];
    
            NSMutableDictionary *dict = @{}.mutableCopy;
            // 埋点
            NSMutableDictionary *traceParam = @{}.mutableCopy;

            dict[TRACER_KEY] = traceParam;
            
            if (url) {
                BOOL isOpen = YES;
                if ([url.absoluteString containsString:@"concern"]) {
                    // 话题
                    traceParam[UT_ENTER_FROM] = [self categoryName];
                    traceParam[UT_ELEMENT_FROM] = UT_BE_NULL;
                    traceParam[UT_ENTER_TYPE] = @"click";
                    traceParam[UT_LOG_PB] = UT_BE_NULL;
                    traceParam[@"rank"] = @(indexPath.row);
                }
                else if([url.absoluteString containsString:@"profile"]) {
                    // JOKER:
                }
                else if([url.absoluteString containsString:@"webview"]) {
                    
                }
                else {
                    isOpen = NO;
                }
                
                if(isOpen) {
                    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
                    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
                }
            }
    
        }
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self traceClientShowAtIndexPath:indexPath];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = NSStringFromClass(FHTopicCell.class);
    FHTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        Class cellClass = NSClassFromString(cellIdentifier);
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row]];
        [cell configHeaderImageTagViewBackgroundWithIndex:indexPath.row];
    }

    return cell;
}

#pragma mark category log

-(void)addEnterCategoryLog {
    TRACK_EVENT(UT_ENTER_CATEOGRY, [self categoryLogDict]);
}

-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(UT_STAY_CATEOGRY, tracerDict);
}

- (NSDictionary *)categoryLogDict
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_CATEGORY_NAME] = [self categoryName];
    tracerDict[UT_ENTER_TYPE] = self.viewController.tracerModel.enterType?:UT_BE_NULL;
    tracerDict[UT_ELEMENT_FROM] = self.viewController.tracerModel.elementFrom?:UT_BE_NULL;
    tracerDict[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom?:UT_BE_NULL;
    return tracerDict;
}

- (void)addCategoryRefreshLog: (BOOL)isLoadMore {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[UT_REFRESH_TYPE] = isLoadMore ? @"pre_load_more" : @"pull";
    TRACK_EVENT(UT_CATEGORY_REFRESH, tracerDict);
}

- (NSString *)categoryName {
    return @"topic_list";
}

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHTopicListResponseDataListModel *model = self.dataList[indexPath.row];
    
    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *forumId = model.forumId;
    if(forumId){
        if (self.clientShowDict[forumId]) {
            return;
        }
        
        self.clientShowDict[forumId] = @(indexPath.row);
        [self trackClientShow:model rank:indexPath.row];
    }
}

- (void)trackClientShow:(FHTopicListResponseDataListModel *)model rank:(NSInteger)rank {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    
    tracerDict[UT_PAGE_TYPE] = @"topic_list";
    tracerDict[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom;
    tracerDict[UT_ELEMENT_FROM] = self.viewController.tracerModel.elementFrom?:UT_BE_NULL;
    tracerDict[UT_LOG_PB] = model.logPb?:UT_BE_NULL;
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"concern_id"] = model.forumId;
    
    TRACK_EVENT(@"topic_show", tracerDict);
}

@end
