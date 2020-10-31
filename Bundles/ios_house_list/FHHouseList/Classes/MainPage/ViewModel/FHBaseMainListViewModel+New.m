//
//  FHBaseMainListViewModel+New.m
//  FHHouseList
//
//  Created by wangxinyu on 2020/10/29.
//

#import "FHBaseMainListViewModel+New.h"
#import <MJRefresh/MJRefresh.h>
#import "FHCommonDefines.h"
#import "NSObject+FHTracker.h"
#import "UIViewAdditions.h"
#import "FHBaseMainListViewModel+Internal.h"
#import "FHSearchHouseModel.h"
#import "FHHouseListAPI.h"
#import "FHSearchChannelTypes.h"

@implementation FHBaseMainListViewModel (New)

#pragma mark - 公共方法

/**
 新房大类页topView
 */
- (void)addNewHouseTopViewWithTracerModel:(FHTracerModel *)tracerModel {
    self.houseNewTopViewModel = [[FHHouseNewTopContainerViewModel alloc] init];
    self.houseNewTopViewModel.fh_trackModel = tracerModel;
    CGFloat height = [FHHouseNewTopContainer viewHeightWithViewModel:self.houseNewTopViewModel];
    FHHouseNewTopContainer *topView = [[FHHouseNewTopContainer alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    topView.viewModel = self.houseNewTopViewModel;
    WeakSelf;
    topView.onStateChanged = ^{
        StrongSelf;
        self.topBannerView.top = 0;
        self.topBannerView.height = [FHHouseNewTopContainer viewHeightWithViewModel:self.houseNewTopViewModel];
    };
    topView.clipsToBounds = YES;
    [self.houseNewTopViewModel startLoading];
    self.topBannerView = topView;
}

/**
 准备新房大类页埋点参数
 */
- (FHTracerModel *)prepareForTracerModel {
    FHTracerModel *tracerModel = [[FHTracerModel alloc] init];
    tracerModel.originSearchId = self.originSearchId;
    tracerModel.searchId = self.searchId;
    tracerModel.pageType = [self pageTypeString];
    tracerModel.categoryName = [self categoryName];
    tracerModel.originFrom = self.tracerModel.originFrom;
    tracerModel.enterFrom = self.tracerModel.enterFrom;
    tracerModel.elementFrom = self.tracerModel.elementFrom;
    
    return tracerModel;
}

#pragma mark - 网络接口

/**
 新房search接口
 */
- (TTHttpTask *)requestNewData:(BOOL)isRefresh query:(NSString *)query completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion {
    NSInteger offset = 0;
    
    if (isRefresh) {
        if (!self.isFirstLoad && self.canChangeHouseSearchDic) {
            if (self.houseSearchDic.count <= 0) {
                // pageType 默认就是 [self pageTypeString]
                self.houseSearchDic = @{
                                        @"enter_query":@"be_null",
                                        @"search_query":@"be_null",
                                        @"page_type": [self pageTypeString],
                                        @"query_type":@"filter"
                                        };
            } else {
                NSMutableDictionary *dic = [self.houseSearchDic mutableCopy];
                dic[@"query_type"] = @"filter";
                self.houseSearchDic = dic;
            }
        }
        self.tableView.mj_footer.hidden = YES;
        self.searchId = nil;
    } else {
        if ([self.houseDataModel isKindOfClass:[FHListSearchHouseDataModel class]]) {
            FHListSearchHouseDataModel *model = (FHListSearchHouseDataModel *)self.houseDataModel;
            offset = model.offset;
        }
    }
    
    NSString *searchId = self.searchId;
    return [self requestNewHouseListData:isRefresh query:query offset:offset searchId:searchId completion:completion];
}

- (TTHttpTask *)requestNewHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion {
    NSDictionary *param = @{
        @"house_type": @(self.houseType),
        @"channel_id": CHANNEL_ID_SEARCH_COURT_WITH_BANNER,
    };
    
    if (isRefresh) {
        if (query) {
            self.subScribeQuery = [NSString stringWithString:query];
        }
        self.subScribeOffset = offset;
        if (searchId) {
            self.subScribeSearchId = [NSString stringWithString:searchId];
        }
    }

    TTHttpTask *task = [FHHouseListAPI searchNewHouseList:query params:param offset:offset searchId:searchId sugParam:nil class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (completion) {
            completion(model , error);
        }
        
    }];
    
    return task;
}

#pragma mark - 动态成员

- (void)setHouseNewTopViewModel:(FHHouseNewTopContainerViewModel *)houseNewTopViewModel {
    objc_setAssociatedObject(self, @selector(houseNewTopViewModel), houseNewTopViewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FHHouseNewTopContainerViewModel *)houseNewTopViewModel {
    return objc_getAssociatedObject(self, @selector(houseNewTopViewModel));
}

@end
