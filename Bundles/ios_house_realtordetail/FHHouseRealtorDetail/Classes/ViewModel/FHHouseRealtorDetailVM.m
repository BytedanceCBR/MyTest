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
#import <ios_house_im/IMManager.h>
#import "FHHorizontalPagingView.h"
#import "UIViewController+Refresh_ErrorHandler.h"

#define kSegmentViewHeight 44
@interface FHHouseRealtorDetailVM () <TTHorizontalPagingViewDelegate,FHHorizontalPagingViewDelegate>

@property (nonatomic, weak) FHHouseRealtorDetailVC *viewController;
@property (nonatomic, strong) FHHouseRealtorDetailBaseViewController *feedListController; //当前显示的feedVC
@property (nonatomic, strong) FHHouseRealtorDetailDataModel *data;
@property (nonatomic, strong) FHRealtorDetailBottomBar *bottomBar;
@property(nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property(nonatomic, assign) CGFloat headerViewHeight;
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
@property (nonatomic, assign) CGFloat placeHolderCellHeight;
@property (nonatomic) BOOL shouldShowUGcGuide;
@property (nonatomic, strong) FHHorizontalPagingView *pageView;
@property (nonatomic, strong) UIView *headerView;
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
        self.pageView = [[FHHorizontalPagingView alloc] initWithFrame:self.viewController.view.bounds];
        self.pageView.delegate = self;
    }
    return self;
}



- (void)requestDataWithRealtorId:(NSString *)realtorId refreshFeed:(BOOL)refreshFeed {
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:YES showToast:YES];
        [self updateNavBarWithAlpha:1];
        return;
    }
    NSMutableDictionary *params= [NSMutableDictionary new];
    params[@"realtor_id"] = realtorId;
    [self.viewController startLoading];
    // 详情页数据-Main
    [FHMainApi requestRealtorHomePage:params completion:^(FHHouseRealtorDetailModel * _Nonnull model, NSError * _Nonnull error) {
        if (model && error == NULL) {
            if (model.data) {
                self.viewController.emptyView.hidden = YES;
                //                [wSelf updateUIWithData];
                [self processDetailData:model];
            } else {
                [self addGoDetailLog];
                [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                [self.viewController endLoading];
            }
        } else {
            [self addGoDetailLog];
            [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            [self.viewController endLoading];
        }
    }];
}

- (void)processDetailData:(FHHouseRealtorDetailModel *)model {
    if (!self.viewController) {
            return;
    }
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
        [self.viewController endLoading];
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
        self.headerViewHeight = self.viewController.headerView.viewHeight;
        if (realtorLeave) {
            [self.viewController showRealtorLeaveHeader];
            return;
        }
        
        NSString *tips = [self.data.realtor btd_stringValueForKey:@"punish_tips"];
        BOOL isPunish = [[self.data.realtor btd_numberValueForKey:@"punish_status" default:@(0)] boolValue];
        BOOL isBlackmailRealtor = isPunish && tips.length > 0;
        [self.viewController showBottomBar:!isBlackmailRealtor];
        [self.viewController.blackmailReatorBottomBar show:isBlackmailRealtor WithHint:tips btnAction:^{
            // 点击埋点
            NSMutableDictionary *clickParams = [NSMutableDictionary dictionary];
            clickParams[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM];
            clickParams[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM];
            clickParams[UT_PAGE_TYPE] = self.tracerDict[UT_PAGE_TYPE];
            clickParams[UT_ELEMENT_TYPE] = @"find_other_realtor";
            clickParams[UT_CLICK_POSITION] = @"find_other_realtor";
            TRACK_EVENT(@"click_options",clickParams);
            //---
            [[IMManager shareInstance] jumpRealtorListH5PageWithUrl:self.data.redirect reportParam:clickParams];
        }];
        
        //初始化segment
        self.ugcTabList = model.data.ugcTabList.mutableCopy;
        FHHouseRealtorDetailRgcTabModel *models =  [[FHHouseRealtorDetailRgcTabModel alloc]init];
        models.showName = @"房源";
        models.tabName = @"house_list";
        [self.ugcTabList insertObject:models atIndex:0];
        [self initSegmentWithTabInfoArr:self.ugcTabList];
        //初始化vc
        [self initSubVCinitWithTabInfoArr:self.ugcTabList];
        [self updatePageView];
    }
}

- (void)updatePageView {
    [self.viewController.view insertSubview:self.pageView atIndex:0];
    if(self.viewController.blackmailReatorBottomBar.hidden == NO) {
        self.pageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.viewController.blackmailReatorBottomBar.top);
        self.pageView.scrollView.frame = self.pageView.frame;
    }
    else {
        self.pageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.viewController.bottomBar.top);
        self.pageView.scrollView.frame = self.pageView.frame;
    }
    
    NSMutableArray *tableViewArray = [NSMutableArray array];
    for(FHHouseRealtorDetailBaseViewController *vc in self.subVCs) {
        [vc view];
        [tableViewArray addObject:vc.tableView];
    }
    self.viewController.segmentView.height = kSegmentViewHeight;
    if(self.subVCs.count < 2) {
        self.viewController.segmentView = nil;
        self.headerView = self.viewController.headerView;
    } else {
        self.headerView = [[UIView alloc] init];
        self.headerView.backgroundColor = [UIColor themeGray7];
        self.headerView.height = self.viewController.headerView.height + 10;
        [self.headerView addSubview:self.viewController.headerView];
    }
    [self.pageView updateWithHeaderView:self.headerView segmentedView:self.viewController.segmentView navBar:self.viewController.customNavBarView tableViewArray:tableViewArray];
    [self.viewController.segmentView setNeedsLayout];
    [self.viewController.segmentView layoutIfNeeded];
    
    if(self.subVCs.count > 1) {
        for(FHHouseRealtorDetailBaseViewController *vc in self.subVCs) {
            vc.tableView.tableHeaderView.height = self.pageView.moveView.height + 10;
            vc.tableView.tableHeaderView.backgroundColor = [UIColor themeGray7];
        }
    }
    if(!(self.currentIndex >= 0 && self.currentIndex < self.subVCs.count)) {
        self.currentIndex = 0;
    }
    [self scrollToIndex:self.currentIndex];
    self.pageView.scrollView.backgroundColor = [UIColor themeGray7];
    
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
    if (tabListArr.count == 1) {
        self.placeHolderCellHeight = CGFLOAT_MIN;
    }else {
         self.placeHolderCellHeight = CGFLOAT_MIN;
    }
    
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
}

- (void)createFeedListController:(NSString *)tabName requestName:(NSString *)name {
    if (![tabName isEqualToString:@"房源"]) {
        FHHouseRealtorDetailController *realtorDetailController =  [[FHHouseRealtorDetailController alloc]init];
        realtorDetailController.realtorInfo = self.realtorInfo;
        realtorDetailController.tracerDict = self.tracerDict;
        realtorDetailController.placeHolderCellHeight = self.placeHolderCellHeight;
        realtorDetailController.tabName = name;
        //错误页高度
        if(self.ugcTabList && self.ugcTabList.count > 0){
            CGFloat errorViewHeight = [UIScreen mainScreen].bounds.size.height - self.viewController.customNavBarView.height;
            errorViewHeight -= kSegmentViewHeight;
            realtorDetailController.errorViewHeight = errorViewHeight;
        }
        realtorDetailController.pageView = self.pageView;
        [self.subVCs addObject:realtorDetailController];
    }else {
        FHHouseRealtorDetailHouseVC *realtorDetailController =  [[FHHouseRealtorDetailHouseVC alloc]init];
        realtorDetailController.realtorInfo = self.realtorInfo;
        realtorDetailController.tracerDict = self.tracerDict;
        realtorDetailController.tabName = name;
        realtorDetailController.placeHolderCellHeight = self.placeHolderCellHeight;
        //错误页高度
        if(self.ugcTabList && self.ugcTabList.count > 0){
            CGFloat errorViewHeight = [UIScreen mainScreen].bounds.size.height - self.viewController.customNavBarView.height;
            errorViewHeight -= kSegmentViewHeight;
            realtorDetailController.errorViewHeight = errorViewHeight;
        }
        realtorDetailController.pageView = self.pageView;
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
    UIImage *blackBackArrowImage = FHBackBlackImage;
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
    params[@"event_tracking_id"] = @"104153";
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

-(void)contentViewDidScroll:(CGFloat)offset {
    CGFloat delta = offset;
    CGFloat navBarH = self.viewController.customNavBarView.height;
    if ((delta + navBarH) > self.headerView.height || (delta + navBarH) == self.headerView.height) {
        [self.viewController.segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont, UIFont *__autoreleasing *selectedTitleFont) {
            *titleScrollViewColorKey  = @"Background4";
            *norColorKey = @"grey1";
            *selColorKey = @"grey1";
            *titleFont = [UIFont themeFontRegular:16];
            *selectedTitleFont = [UIFont themeFontMedium:18];
        }];
    }else {
        [self.viewController.segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont, UIFont *__autoreleasing *selectedTitleFont) {
            *titleScrollViewColorKey  = @"Background21";
            *norColorKey = @"grey1";
            *selColorKey = @"grey1";
            *titleFont = [UIFont themeFontRegular:16];
            *selectedTitleFont = [UIFont themeFontMedium:18];
        }];
    }
    [self refreshContentOffset:delta];
    if (self.isHeightScoreRealtor) {
        self.viewController.customNavBarView.title.hidden = delta<0;
        self.viewController.customNavBarView.leftBtn.hidden = delta<0;
    }
    [self.viewController.headerView updateWhenScrolledWithContentOffset:delta isScrollTop:NO scrollView:nil];
}


#pragma mark - segmentView 代理
- (void)segmentView:(TTHorizontalPagingSegmentView *)segmentView didSelectedItemAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex {
    [self.pageView updateSelectIndex:toIndex];
    if(toIndex >= 0 && toIndex < self.subVCs.count) {
        UIViewController *vc = [self.subVCs objectAtIndex:toIndex];
        [vc viewWillAppear:NO];
    }
}

-(void)scrollToIndex:(NSInteger)index {
    
//    //点击同一个不做处理
    if(index == self.currentIndex && !self.isFirstEnter){
        return;
    }
    self.currentIndex = index;
    if(self.isFirstEnter) {
        self.isFirstEnter = NO;
        [self.pageView updateSelectIndex:index];
    } else {
        //上报埋点
        NSString *position = @"be_null";
        if(index < self.ugcTabList.count){
            FHHouseRealtorDetailRgcTabModel *tabModel = self.ugcTabList[index];
            if(tabModel.tabName){
                position = [NSString stringWithFormat:@"%@",tabModel.tabName];
            }
        }
        [self addEnterCategoryLog:position];
    }
    [self.viewController.segmentView setSelectedIndexNoEvent:index];
    if(index >= 0 && index < self.subVCs.count) {
        UIViewController *vc = [self.subVCs objectAtIndex:index];
        [vc viewWillAppear:NO];
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
