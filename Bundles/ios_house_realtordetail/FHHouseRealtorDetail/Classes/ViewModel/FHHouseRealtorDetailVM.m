//
//  FHHouseRealtorDetailVM.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//
#import <TTBaseLib/UIButton+TTAdditions.h>
#import "FHHouseRealtorDetailVM.h"
#import "FHHouseRealtorDetailVC.h"
#import "FHCommunityDetailHeaderView.h"
#import "FHHouseRealtorDetailController.h"
#import "TTBaseMacro.h"
#import "FHHouseUGCAPI.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "UIImageView+BDWebImage.h"
#import "UILabel+House.h"
#import "FHUGCScialGroupModel.h"
#import "FHUGCConfig.h"
#import "TTAccountManager.h"
#import "FHUserTracker.h"
#import "FHCommunityDetailMJRefreshHeader.h"
#import "MJRefresh.h"
#import "FHCommonDefines.h"
#import "TTUIResponderHelper.h"
#import "TTUGCEmojiParser.h"
#import "TTAccount.h"
#import "TTAccount+Multicast.h"
#import "TTAccountManager.h"
#import "TTHorizontalPagingView.h"
#import "IMManager.h"
#import "TTThemedAlertController.h"
#import "FHFeedUGCCellModel.h"
#import "TTUGCDefine.h"
#import <FHUGCCategoryHelper.h>
#import "UIImage+FIconFont.h"
#import "FHHouseRealtorDetailBaseViewController.h"
#import "FHHouseRealtorDetailHouseVC.h"
#define kSegmentViewHeight 44
@interface FHHouseRealtorDetailVM () <TTHorizontalPagingViewDelegate>

@property (nonatomic, weak) FHHouseRealtorDetailVC *viewController;
@property (nonatomic, strong) FHHouseRealtorDetailBaseViewController *feedListController; //当前显示的feedVC
@property (nonatomic, assign) BOOL isViewAppear;
@property (nonatomic, strong) TTHorizontalPagingView *pagingView;
@property (nonatomic, strong) FHHouseRealtorDetailDataModel *data;
@property (nonatomic, strong) NSMutableArray *subVCs;
@property (nonatomic, strong) NSMutableArray *segmentTitles;
@property (nonatomic, copy) NSString *currentSegmentType;
@property (nonatomic, copy) NSString *defaultType;
@property (nonatomic, strong) NSDictionary *realtorInfo;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *ugcTabList;
//精华tab的index，默认是-1
@property (nonatomic, assign) NSInteger essenceIndex;
@property (nonatomic, assign) BOOL isFirstEnter;

//@property (nonatomic, strong) FHUGCGuideView *guideView;
@property (nonatomic) BOOL shouldShowUGcGuide;
@end
@implementation FHHouseRealtorDetailVM
- (instancetype)initWithController:(FHHouseRealtorDetailVC *)viewController tracerDict:(NSDictionary*)tracerDict realtorInfo:(NSDictionary *)realtorInfo {
    self = [super init];
    if (self) {
        self.tracerDict = tracerDict.mutableCopy;
        self.viewController = viewController;
        [self initView];
        self.shouldShowUGcGuide = YES;
        self.isViewAppear = YES;
        self.isFirstEnter = YES;
        self.viewController.segmentView.delegate = self;
        self.essenceIndex = -1;
        self.realtorInfo = realtorInfo;
        
        // 分享埋点
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
        params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
        params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
        params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
        params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
        self.shareTracerDict = [params copy];
        
        self.subVCs = [NSMutableArray array];
    }
    return self;
}

- (void)initView {
}

    


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear {

}

- (void)viewDidAppear {
    self.isViewAppear = YES;
    [self updateNavBarWithAlpha:self.viewController.customNavBarView.bgView.alpha];
}

- (void)viewWillDisappear {
    self.isViewAppear = NO;
}

- (void)endRefreshing {
  
}

- (void)requestDataWithRealtorId:(NSString *)realtorId refreshFeed:(BOOL)refreshFeed {
    
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:YES showToast:YES];
        return;
    }
    NSMutableDictionary *parmas= [NSMutableDictionary new];
    [parmas setValue:realtorId forKey:@"realtor_id"];
    // 详情页数据-Main
    __weak typeof(self) wSelf = self;
    [FHMainApi requestRealtorHomePage:parmas completion:^(FHHouseRealtorDetailModel * _Nonnull model, NSError * _Nonnull error) {
        if (model && error == NULL) {
            if (model.data) {
//                [wSelf updateUIWithData];
                [wSelf processDetailData:model];
            }
        }
    }];
}

- (void)processDetailData:(FHHouseRealtorDetailModel *)model {
    self.data = model.data;
    if(self.isFirstEnter){
           //初始化segment
        self.ugcTabList = model.data.ugcTabList.mutableCopy;
        FHHouseRealtorDetailRgcTabModel *models =  [[FHHouseRealtorDetailRgcTabModel alloc]init];
        models.showName = @"房源";
        models.tabName = @"house";
        [self.ugcTabList insertObject:models atIndex:0];
        [self initSegmentWithTabInfoArr:self.ugcTabList];
           //初始化vc
           [self initSubVCinitWithTabInfoArr:self.ugcTabList];
       }else{
           [self updateVC];
       }
}

-(void)onNetworError:(BOOL)showEmpty showToast:(BOOL)showToast{
    if(showEmpty){
        self.feedListController.view.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
    if(showToast){
        [[ToastManager manager] showToast:@"网络异常"];
    }
}



- (void)initSegmentWithTabInfoArr:(NSArray *)tabListArr {
    NSMutableArray *titles = [NSMutableArray array];
    NSInteger selectedIndex = 0;
    if(tabListArr && tabListArr.count > 0) {
        for(NSInteger i = 0;i < tabListArr.count;i++) {
            FHHouseRealtorDetailRgcTabModel *item = tabListArr[i];
            if(!isEmptyString(item.showName)) {
                [titles addObject:item.showName];
            }
            //这里记录一下精华tab的index,为了后面加精和取消加精时候，可以标记vc刷新
            if([item.tabName isEqualToString:tabEssence]){
                self.essenceIndex = i;
            }
            if(i == 0) {
                selectedIndex = i;
                self.currentSegmentType = item.tabName;
                self.defaultType = item.tabName;
            }
        }
        self.viewController.segmentView.hidden = NO;
    }else{
        self.viewController.segmentView.hidden = YES;
    }
    self.selectedIndex = selectedIndex;
    self.viewController.segmentView.selectedIndex = selectedIndex;
    self.viewController.segmentView.titles = titles;
    self.segmentTitles = titles;
}

- (void)initSubVCinitWithTabInfoArr:(NSArray *)tabListArr {
    [self.subVCs removeAllObjects];
    
    if(tabListArr && tabListArr.count > 0) {
        for(NSInteger i = 0;i < tabListArr.count;i++) {
            FHHouseRealtorDetailRgcTabModel *item = tabListArr[i];
            if(!isEmptyString(item.showName)) {
                [self createFeedListController:item.showName requestName:item.tabName];
            }
        }
    }else{
        [self createFeedListController:nil requestName:nil];
    }
    
    self.pagingView.delegate = self;
    //放到最下面
    [self.viewController.view insertSubview:self.pagingView atIndex:0];
    [self.pagingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.viewController.view);
         if (@available(iOS 11.0, *)) {
               make.bottom.mas_equalTo(self.viewController.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom -64);
           }else {
               make.bottom.mas_equalTo(-64);
           }
    }];
}

- (void)createFeedListController:(NSString *)tabName requestName:(NSString *)name {
    if (![tabName isEqualToString:@"房源"]) {
        FHHouseRealtorDetailController *realtorDetailController =  [[FHHouseRealtorDetailController alloc]init];
        realtorDetailController.tabName =
        realtorDetailController.realtorInfo = self.realtorInfo;
        realtorDetailController.tabName = name;
        //错误页高度
        if(self.ugcTabList && self.ugcTabList.count > 0){
            CGFloat errorViewHeight = [UIScreen mainScreen].bounds.size.height - self.viewController.customNavBarView.height;
            errorViewHeight -= kSegmentViewHeight;
            realtorDetailController.errorViewHeight = errorViewHeight;
        }
        [self.subVCs addObject:realtorDetailController];
    }else {
        FHHouseRealtorDetailHouseVC *realtorDetailController =  [[FHHouseRealtorDetailHouseVC alloc]init];
        realtorDetailController.realtorInfo = self.realtorInfo;
        realtorDetailController.tabName = name;
              //错误页高度
              if(self.ugcTabList && self.ugcTabList.count > 0){
                  CGFloat errorViewHeight = [UIScreen mainScreen].bounds.size.height - self.viewController.customNavBarView.height;
                  errorViewHeight -= kSegmentViewHeight;
                  realtorDetailController.errorViewHeight = errorViewHeight;
              }
              [self.subVCs addObject:realtorDetailController];
    }
}

- (void)updateVC {
//    for (FHCommunityFeedListController *feedListController in self.subVCs) {
//    }
}


- (void)refreshContentOffset:(CGFloat)offset {
    CGFloat alpha = offset / (80.0f);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    [self updateNavBarWithAlpha:alpha];
}

- (void)updateNavBarWithAlpha:(CGFloat)alpha {
    if (!self.isViewAppear) {
        return;
    }
    UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
    UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    if (alpha <= 0.1f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
        self.viewController.customNavBarView.title.textColor = [UIColor whiteColor];
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.viewController.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = NO;
    }
    if(self.viewController.emptyView.hidden == NO) {
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
    }
    [self.viewController.customNavBarView refreshAlpha:alpha];

//    NSMutableArray *tabArray = [self.socialGroupModel.data.tabInfo mutableCopy];
//    if(tabArray && tabArray.count > 1) {
//        self.viewController.customNavBarView.seperatorLine.hidden = YES;
//    }
}


//- (void)updateUIWithData {
//        [self.pagingView reloadHeaderViewHeight:self.viewController.headerView.height];
//}

#pragma UIScrollViewDelegate


//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if(decelerate){
//        CGFloat delta = self.pagingView.currentContentViewTopInset + scrollView.contentOffset.y;
//        if(delta <= -50){
//        }
//    }
//}

- (void)addGoDetailLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"click";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    [FHUserTracker writeEvent:@"go_detail_community" params:params];
}

- (void)addStayPageLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"click";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page_community" params:params];
}




- (void)addClickOptionsLog:(NSString *)position {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"enter_type"] =  @"click";
    params[@"click_position"] = position;
    [FHUserTracker writeEvent:@"click_options" params:params];
}



#pragma mark - lazy load

- (TTHorizontalPagingView *)pagingView {
    if(!_pagingView) {
        _pagingView = [[TTHorizontalPagingView alloc] init];
        _pagingView.delegate = self;
        _pagingView.frame = self.viewController.view.bounds;
        _pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pagingView.segmentTopSpace = CGRectGetMaxY(self.viewController.customNavBarView.frame);
        _pagingView.horizontalCollectionView.scrollEnabled = NO;
        _pagingView.clipsToBounds = YES;
    }
    return _pagingView;
}

#pragma mark - pagingView 代理

- (NSInteger)numberOfSectionsInPagingView:(TTHorizontalPagingView *)pagingView {
    return self.subVCs.count;
}

- (UIScrollView *)pagingView:(TTHorizontalPagingView *)pagingView viewAtIndex:(NSInteger)index {
    index = MIN(self.subVCs.count - 1, index);
    FHHouseRealtorDetailBaseViewController *feedVC = self.subVCs[index];
    if(!feedVC.tableView){
        [feedVC viewDidLoad];
    }
    return feedVC.tableView;
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView didSwitchIndex:(NSInteger)aIndex to:(NSInteger)toIndex {
    //前面的消失
    if(aIndex < self.subVCs.count && !self.isFirstEnter){
        FHHouseRealtorDetailBaseViewController *feedVC = self.subVCs[aIndex];
    }
    //新的展现
    if(toIndex < self.subVCs.count){
        FHHouseRealtorDetailBaseViewController *feedVC = self.subVCs[toIndex];
        [self.viewController addChildViewController:feedVC];
        [feedVC didMoveToParentViewController:self.viewController];
    }
}

- (UIView *)viewForHeaderInPagingView {
    return self.viewController.headerView;
}

- (CGFloat)heightForHeaderInPagingView {
    return self.viewController.headerView.height;
}

- (UIView *)viewForSegmentInPagingView {
    return self.viewController.segmentView;
}

- (CGFloat)heightForSegmentInPagingView {
    NSMutableArray *tabArray = [self.ugcTabList mutableCopy];
    if(tabArray && tabArray.count > 0) {
        return kSegmentViewHeight;
    }else{
        return 0;
    }
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView scrollTopOffset:(CGFloat)offset {
    CGFloat delta = self.pagingView.currentContentViewTopInset + offset;
    UIScrollView *scrollView = pagingView.currentContentView;
    [self refreshContentOffset:delta];
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView scrollViewDidEndDraggingOffset:(CGFloat)offset {
    CGFloat delta = self.pagingView.currentContentViewTopInset + offset;
    if(delta <= -50){
    
    }
}

#pragma mark - segmentView 代理
- (void)segmentView:(TTHorizontalPagingSegmentView *)segmentView didSelectedItemAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex {
    
    //点击同一个不做处理
    if(index == toIndex && !self.isFirstEnter){
        return;
    }
    
    if(toIndex < self.subVCs.count){
        self.selectedIndex = toIndex;
        self.feedListController = self.subVCs[toIndex];
        self.pagingView.headerView = self.viewController.headerView;
        self.pagingView.segmentView = self.viewController.segmentView;
    }
    
    if(self.isFirstEnter) {
        [self.pagingView scrollToIndex:toIndex withAnimation:NO];
        self.isFirstEnter = NO;
    } else {
        //上报埋点
        NSString *position = @"be_null";
//        if(toIndex < self.socialGroupModel.data.tabInfo.count){
//            FHUGCScialGroupDataTabInfoModel *tabModel = self.socialGroupModel.data.tabInfo[toIndex];
//            if(tabModel.tabName){
//                position = [NSString stringWithFormat:@"%@_list",tabModel.tabName];
//            }
//        }
//        [self addClickOptionsLog:position];
        [self.pagingView scrollToIndex:toIndex withAnimation:YES];
    }
}
@end
