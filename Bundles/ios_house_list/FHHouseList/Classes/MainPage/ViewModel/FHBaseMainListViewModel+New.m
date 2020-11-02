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
#import "FHMainListTopView.h"

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
        [self updateTopViewLayoutIfNeed];
    };
    topView.clipsToBounds = YES;
    [self.houseNewTopViewModel startLoading];
    self.topBannerView = topView;
}

/**
 更新新房大类页头部
 新房大类页头部包含榜单/banner等内容，其高度是动态计算的，依赖接口返回的数据
 因此需要对新房大类页头部内容及其高度进行更新
 */
- (void)updateTopViewLayoutIfNeed {
    if (self.topView.superview == self.tableView) {
        if (self.houseType == FHHouseTypeNewHouse) {
            ///保存变化前的状态
            CGFloat originOffsetY = self.tableView.contentOffset.y;
            CGFloat originContentInsetsTop = self.tableView.contentInset.top;
            ///根据model计算新房大类页头部高度
            CGFloat height = [FHHouseNewTopContainer viewHeightWithViewModel:self.houseNewTopViewModel];
            height += [self.topView filterHeight];
            ///更新tableView的contentInset
            UIEdgeInsets insets = self.tableView.contentInset;
            insets.top = height;
            self.tableView.contentInset = insets;
            ///更新tableView的contentOffset
            CGPoint offset = self.tableView.contentOffset;
            offset.y = originOffsetY + originContentInsetsTop - height;
            self.tableView.contentOffset = offset;
            ///更新topView的高度和y值
            self.topView.height = height;
            self.topView.top = -height;
            
            if ([self.topView respondsToSelector:@selector(relayout)]) {
                [self.topView relayout];
                [self.tableView scrollsToTop];
            }
        }
    }
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
