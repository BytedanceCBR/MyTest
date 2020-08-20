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
#import "UIDevice+BTDAdditions.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "TTURLUtils.h"
#import "NSObject+YYModel.h"
#import "NSDictionary+BTDAdditions.h"
#define kSegmentViewHeight 44
@interface FHHouseRealtorDetailVM () <TTHorizontalPagingViewDelegate,TTHorizontalPagingSegmentViewDelegate>

@property (nonatomic, weak) FHHouseRealtorDetailVC *viewController;
@property (nonatomic, strong) FHHouseRealtorDetailBaseViewController *feedListController; //当前显示的feedVC
@property (nonatomic, strong) TTHorizontalPagingView *pagingView;
@property (nonatomic, strong) FHHouseRealtorDetailDataModel *data;
@property (nonatomic, strong) FHRealtorDetailBottomBar *bottomBar;
@property(nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property (nonatomic, strong) NSMutableArray *subVCs;
@property (nonatomic, strong) NSMutableArray *segmentTitles;
@property (nonatomic, copy) NSString *currentSegmentType;
@property (nonatomic, copy) NSString *defaultType;
@property (nonatomic, strong) NSDictionary *realtorInfo;
@property (nonatomic, strong) NSDictionary *realtorLogpb;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *ugcTabList;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isFirstEnter;
@property (nonatomic, assign) BOOL isHeightScoreRealtor;
@property (nonatomic) BOOL shouldShowUGcGuide;
@end
@implementation FHHouseRealtorDetailVM
- (instancetype)initWithController:(FHHouseRealtorDetailVC *)viewController tracerDict:(NSDictionary*)tracerDict realtorInfo:(NSDictionary *)realtorInfo bottomBar:(FHRealtorDetailBottomBar *)bottomBar {
    self = [super init];
    if (self) {
        self.tracerDict = tracerDict.mutableCopy;
        self.viewController = viewController;
        self.bottomBar = bottomBar;
        self.realtorPhoneCallModel = [[FHRealtorEvaluatingPhoneCallModel alloc]initWithHouseType:[NSString stringWithFormat:@"%@",realtorInfo[@"house_type"]].intValue houseId:realtorInfo[@"house_id"]];
        self.realtorPhoneCallModel.tracerDict = tracerDict;
        self.realtorPhoneCallModel.belongsVC = viewController;
        self.isFirstEnter = YES;
        self.isHeightScoreRealtor = NO;
        self.viewController.segmentView.delegate = self;
        self.realtorInfo = realtorInfo;
        __weak typeof(self)ws = self;
        self.bottomBar.imAction = ^{
            [ws imAction];
        };
        self.bottomBar.phoneAction = ^{
            [ws phoneAction];
        };
        self.subVCs = [NSMutableArray array];
    }
    return self;
}



- (void)requestDataWithRealtorId:(NSString *)realtorId refreshFeed:(BOOL)refreshFeed {
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:YES showToast:YES];
        [self updateNavBarWithAlpha:1];
        return;
    }
    NSMutableDictionary *parmas= [NSMutableDictionary new];
    [parmas setValue:realtorId forKey:@"realtor_id"];
    // 详情页数据-Main
    __weak typeof(self) wSelf = self;
    [FHMainApi requestRealtorHomePage:parmas completion:^(FHHouseRealtorDetailModel * _Nonnull model, NSError * _Nonnull error) {
        if (model && error == NULL) {
            if (model.data) {
                wSelf.viewController.emptyView.hidden = YES;
                //                [wSelf updateUIWithData];
                [wSelf processDetailData:model];
            }else {
                [wSelf addGoDetailLog];
                [wSelf.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        }else {
            [wSelf addGoDetailLog];
            [wSelf.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
    }];
}

- (void)processDetailData:(FHHouseRealtorDetailModel *)model {
    //    if (!self.viewController) {
    //        return;
    //    }
    self.realtorLogpb = model.data.realtorLogpb;
    [self addGoDetailLog];
    self.data = model.data;
    BOOL realtorLeave = [model.data.realtor.allKeys containsObject:@"is_leave"]?[model.data.realtor[@"is_leave"] boolValue]:NO;
    
    if (model.data.realtorTab) {
        self.currentIndex = [model.data.realtorTab integerValue];
    }
    
    if(self.isFirstEnter){
        NSMutableDictionary *dic = [model.data toDictionary].mutableCopy;
        NSMutableDictionary *dicm = model.data.scoreInfo.mutableCopy;
        if (dicm && [dicm.allKeys containsObject:@"open_url"]) {
            NSString *openUrl = dicm[@"open_url"];
            openUrl = [openUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
            
            NSString *unencodedString = openUrl;
            NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                            (CFStringRef)unencodedString,
                                                                                                            NULL,
                                                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                            kCFStringEncodingUTF8));
            NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@",encodedString];
            [dicm setObject:urlStr forKey:@"open_url"];
        }
        [dic setObject:dicm?:@"" forKey:@"score_info"];
        [dic setObject:@{@"realtor_id":self.realtorInfo[@"realtor_id"]?:@"",@"screen_width":@([UIScreen mainScreen].bounds.size.width)} forKey:@"common_params"];
        [dic setObject:self.tracerDict?:@"" forKey:@"report_params"];
        if (self.tracerDict) {
            NSString *lynxReortParams= [self.tracerDict yy_modelToJSONString];
            lynxReortParams = [lynxReortParams stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
            [dic setObject:lynxReortParams forKey:@"encoded_report_params"];
        }
        [self.viewController.headerView reloadDataWithDic:dic];
        if ([model.data.realtor.allKeys containsObject:@"is_preferred_realtor"]) {
            BOOL isHightScore = [model.data.realtor btd_boolValueForKey:@"is_preferred_realtor"];
            if (isHightScore) {
                self.isHeightScoreRealtor = isHightScore;
                [self.viewController.headerView updateRealtorWithHeightScore];
                self.viewController.headerView.titleImage.hidden = NO;
                self.viewController.customNavBarView.title.textColor = [UIColor colorWithHexStr:@"#E7C494"];
                UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor colorWithHexStr:@"#E7C494"]);
                [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
                [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
            }
        }
        
        self.viewController.headerView.height = self.viewController.headerView.viewHeight;
        if (realtorLeave) {
            [self.viewController showRealtorLeaveHeader];
            return;
        }
        [self.viewController showBottomBar:YES];
        //初始化segment
        self.ugcTabList = model.data.ugcTabList.mutableCopy;
        FHHouseRealtorDetailRgcTabModel *models =  [[FHHouseRealtorDetailRgcTabModel alloc]init];
        models.showName = @"房源";
        models.tabName = @"house_list";
        [self.ugcTabList insertObject:models atIndex:0];
        [self initSegmentWithTabInfoArr:self.ugcTabList];
        //初始化vc
        [self initSubVCinitWithTabInfoArr:self.ugcTabList];
    }
}

-(void)onNetworError:(BOOL)showEmpty showToast:(BOOL)showToast{
    if(showEmpty){
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
    if(showToast){
        [[ToastManager manager] showToast:@"网络异常"];
    }
}



- (void)initSegmentWithTabInfoArr:(NSArray *)tabListArr {
    NSMutableArray *titles = [NSMutableArray array];
    if(tabListArr && tabListArr.count > 0) {
        for(NSInteger i = 0;i < tabListArr.count;i++) {
            FHHouseRealtorDetailRgcTabModel *item = tabListArr[i];
            if(!isEmptyString(item.showName)) {
                [titles addObject:item.showName];
            }
        }
    }else{
        self.viewController.segmentView.hidden = YES;
    }
    if (tabListArr && tabListArr.count>1) {
        if (self.currentIndex < tabListArr.count) {
            self.viewController.segmentView.selectedIndex = self.currentIndex;
        }else {
            self.viewController.segmentView.selectedIndex = 0;
        }
        
        [self addEnterCategoryLog:@"realtor_all_list"];
    }
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
        realtorDetailController.realtorInfo = self.realtorInfo;
        realtorDetailController.tracerDict = self.tracerDict;
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
        realtorDetailController.tracerDict = self.tracerDict;
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


- (void)refreshContentOffset:(CGFloat)offset {
    CGFloat alpha = offset / (80.0f);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    [self updateNavBarWithAlpha:alpha];
}

- (void)updateNavBarWithAlpha:(CGFloat)alpha {
    UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a",self.isHeightScoreRealtor?[UIColor colorWithHexStr:@"#E7C494"]:[UIColor whiteColor]);
    UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    if (alpha <= 0.1f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
        self.viewController.customNavBarView.title.textColor = self.isHeightScoreRealtor?[UIColor colorWithHexStr:@"#E7C494"]: [UIColor whiteColor];
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
    self.viewController.customNavBarView.bgView.alpha = alpha;
}


#pragma UIScrollViewDelegate


- (void)addGoDetailLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    params[@"event_type"] = @"house_app2c_v2";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"click";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"realtor_id"] = self.realtorInfo[@"realtor_id"] ?: @"be_null";
    params[@"realtor_logpb"] = self.realtorLogpb?:@"be_null";
    params[@"event_tracking_id"] = @"93412";
    [FHUserTracker writeEvent:@"go_detail" params:params];
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
    FHHouseRealtorDetailBaseViewController *feedVC = self.subVCs[index];
    if(!feedVC.tableView){
        [feedVC viewDidLoad];
    }
    return feedVC.tableView;
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView didSwitchIndex:(NSInteger)aIndex to:(NSInteger)toIndex {
    //前面的消失
    if(aIndex < self.subVCs.count && !self.isFirstEnter){
        //        FHHouseRealtorDetailBaseViewController *feedVC = self.subVCs[aIndex];
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
    if(tabArray && tabArray.count > 1) {
        return kSegmentViewHeight;
    }else{
        return 0;
    }
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView scrollTopOffset:(CGFloat)offset {
    CGFloat delta = self.pagingView.currentContentViewTopInset + offset;
    CGFloat navBarH = [UIDevice btd_isIPhoneXSeries]?84:64;
    if ((delta + navBarH) >self.pagingView.headerViewHeight || (delta + navBarH) == self.pagingView.headerViewHeight) {
        [self.viewController.segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont, UIFont *__autoreleasing *selectedTitleFont) {
            *titleScrollViewColorKey  = @"Background4";
            *norColorKey = @"grey3"; //
            *selColorKey = @"grey1";//grey1
            *titleFont = [UIFont themeFontRegular:16];
            *selectedTitleFont = [UIFont themeFontSemibold:16];
        }];
    }else {
        [self.viewController.segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont, UIFont *__autoreleasing *selectedTitleFont) {
            *titleScrollViewColorKey  = @"Background21";
            *norColorKey = @"grey3"; //
            *selColorKey = @"grey1";//grey1
            *titleFont = [UIFont themeFontRegular:16];
            *selectedTitleFont = [UIFont themeFontSemibold:16];
        }];
    }
    [self refreshContentOffset:delta];
    if (self.isHeightScoreRealtor) {
        self.viewController.customNavBarView.title.hidden = delta<0;
        self.viewController.customNavBarView.leftBtn.hidden = delta<0;
    }
    [self.viewController.headerView updateWhenScrolledWithContentOffset:delta isScrollTop:NO scrollView:pagingView.currentContentView];
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
        if(toIndex < self.ugcTabList.count){
            FHHouseRealtorDetailRgcTabModel *tabModel = self.ugcTabList[toIndex];
            if(tabModel.tabName){
                position = [NSString stringWithFormat:@"%@",tabModel.tabName];
            }
        }
        [self addEnterCategoryLog:position];
        [self.pagingView scrollToIndex:toIndex withAnimation:YES];
    }
}


- (void)imAction{
    FHFeedUGCCellRealtorModel *realtorModel =  [[FHFeedUGCCellRealtorModel alloc]init];
    realtorModel.associateInfo = [self.data.associateInfo copy];
    realtorModel.realtorId = self.realtorInfo[@"realtor_id"];
    realtorModel.chatOpenurl = self.data.chatOpenUrl;
    realtorModel.realtorLogpb = @{};
    [self.realtorPhoneCallModel imchatActionWithPhone:realtorModel realtorRank:@"0" extraDic:self.tracerDict];
}

- (void)phoneAction{
    //     NSDictionary *houseInfo = dataModel.extraDic;
    NSMutableDictionary *extraDict = self.tracerDict.mutableCopy;
    extraDict[@"realtor_id"] = self.realtorInfo[@"realtor_id"];
    extraDict[@"realtor_rank"] = @"be_null";
    extraDict[@"realtor_logpb"] = @"be_null";
    extraDict[@"realtor_position"] = @"realtor_realtorDetail";
    extraDict[@"log_pb"] = extraDict[@"log_pb"]?:@"be_null";
    NSDictionary *associateInfoDict = self.data.associateInfo.phoneInfo;
    extraDict[kFHAssociateInfo] = associateInfoDict;
    FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
    associatePhone.reportParams = extraDict;
    associatePhone.associateInfo = associateInfoDict;
    associatePhone.realtorId = self.realtorInfo[@"realtor_id"];
    //     associatePhone.searchId = houseInfo[@"searchId"];
    //     associatePhone.imprId = houseInfo[@"imprId"];
    associatePhone.houseType = [NSString  stringWithFormat:@"%@",self.realtorInfo[@"house_type"]].intValue;
    associatePhone.houseId = self.realtorInfo[@"house_id"];
    [self.realtorPhoneCallModel phoneChatActionWithAssociateModel:associatePhone];
}

- (void)addEnterCategoryLog:(NSString *)categoryName {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [tracerDict setObject:categoryName forKey:@"category_name"];
    [tracerDict setObject:@"house_app2c_v2" forKey:@"event_type"];
    [tracerDict setObject:self.realtorInfo[@"realtor_id"] forKey:@"realtor_id"];
    TRACK_EVENT(@"enter_category", tracerDict);
}
@end
