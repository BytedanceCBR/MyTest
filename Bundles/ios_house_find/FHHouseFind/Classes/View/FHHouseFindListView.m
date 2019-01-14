//
//  FHHouseFindListView.m
//  Pods
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindListView.h"
#import "ArticleListNotifyBarView.h"
#import "FHErrorView.h"
#import "FHConditionFilterViewModel.h"
#import "FHHouseFilterBridge.h"
#import "Masonry.h"
#import "FHHouseListViewModel.h"
#import "FHHouseBridgeManager.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHHouseType.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "FHHouseListRedirectTipView.h"

@interface FHHouseFindListView () <FHHouseListViewModelDelegate, UIViewControllerErrorHandler>

@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UIView *filterContainerView;
@property (nonatomic , strong) UIView *filterPanel;
@property (nonatomic , strong) UIControl *filterBgControl;
@property (nonatomic , strong) FHConditionFilterViewModel *houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;
@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;
@property (nonatomic , strong) FHHouseListRedirectTipView *redirectTipView;
@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) FHHouseListViewModel *viewModel;
@property (nonatomic , strong) TTRouteParamObj *paramObj;

@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , copy) NSString *openUrl;
@property (nonatomic , strong) FHHouseFindSectionItem *item;
@property(nonatomic , assign) BOOL needRefresh;
@property(nonatomic , assign) BOOL hasValidateData;

@end

@implementation FHHouseFindListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.needRefresh = YES;
        self.hasValidateData = NO;
        [self startLoading];
        [self setupUI];
        [self setupConstraints];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.viewModel viewWillDisappear:animated];
    [self.houseFilterBridge closeConditionFilterPanel];

}

- (void)setShowRedirectTip:(BOOL)showRedirectTip
{
    self.viewModel.showRedirectTip = showRedirectTip;
}

- (void)updateDataWithItem: (FHHouseFindSectionItem *)item
{
    if (!self.needRefresh) {
        return;
    }
    _houseType = item.houseType;
    _openUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%ld",self.houseType];
    self.paramObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:self.openUrl]];
    TTRouteUserInfo *userInfo = nil;
    if (self.tracerDict) {
        
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:@{@"tracer":self.tracerDict}];
    }
    self.paramObj.userInfo = userInfo;
    self.viewModel = [[FHHouseListViewModel alloc]initWithTableView:self.tableView routeParam:self.paramObj];
    self.viewModel.fromFindTab = YES;
    [self.viewModel setMaskView:self.errorMaskView];
    [self.viewModel setRedirectTipView:self.redirectTipView];
    [self setupViewModelBlock];
    [self resetFilter:self.paramObj];
    [self.houseFilterBridge trigerConditionChanged];
    self.needRefresh = NO;
    self.hasValidateData = YES;
//    [self endLoading];

}

- (void)addClickHouseSearchLog
{
    [self.viewModel addClickHouseSearchLog];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData
{
    return _hasValidateData;
}

- (void)startLoading
{
    [self tt_startUpdate];
}

- (void)endLoading
{
    [self tt_endUpdataData];
}

- (void)setHasValidateData:(BOOL)hasValidateData
{
    _hasValidateData = hasValidateData;
    [self endLoading];
}

- (void)initFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:self.houseType showAllCondition:YES showSort:YES safeBottomPandding:0];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    
    [self.houseFilterViewModel setFilterConditions:self.paramObj.queryParams];
    
    self.viewModel.viewModelDelegate = self;
    [bridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
    
    [bridge showBottomLine:NO];

    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor themeGray6];
    [self.filterPanel addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)resetFilter:(TTRouteParamObj *)paramObj
{
    [self.filterBgControl removeFromSuperview];
    [self.filterContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self initFilter];
    
    [self addSubview:self.filterBgControl];
    [self.filterContainerView addSubview:self.filterPanel];
    
    CGFloat bottomHeight = 49;
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self).mas_offset(-bottomHeight);
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
    }];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.filterContainerView);
    }];
    
    self.viewModel.houseType = self.houseType;
    [self.houseFilterViewModel setFilterConditions:paramObj.queryParams];
    [self.houseFilterBridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
}

- (void)setupViewModelBlock
{
    __weak typeof(self) wself = self;
    _viewModel.conditionNoneFilterBlock = ^NSString * _Nullable(NSDictionary * _Nonnull params) {
        return [wself.houseFilterBridge getNoneFilterQueryParams:params];
    };
    
    _viewModel.closeConditionFilter = ^{
        [wself.houseFilterBridge closeConditionFilterPanel];
    };
    
    _viewModel.clearSortCondition = ^{
        [wself.houseFilterBridge clearSortCondition];
    };
    
    _viewModel.getConditions = ^NSString * _Nonnull{
        return [wself.houseFilterBridge getConditions];
    };
    _viewModel.setConditionsBlock = ^(NSDictionary * _Nonnull params) {
        
        [wself.houseFilterBridge setFilterConditions:params];
        [wself.houseFilterBridge trigerConditionChanged];
    };
    _viewModel.getAllQueryString = ^NSString * _Nonnull {
        
        return [wself.houseFilterBridge getAllQueryString];
    };
    _viewModel.getSortTypeString = ^NSString * _Nullable {
        if ([wself.houseFilterViewModel isLastSearchBySort]) {
            return [wself.houseFilterViewModel sortType] ? : @"default";
        }
        return nil;
    };
    
    _viewModel.houseListOpenUrlUpdateBlock = ^(TTRouteParamObj * _Nonnull paramObj, BOOL isFromMap) {
        
        [wself handleListOpenUrlUpdate:paramObj];
 
    };
    _viewModel.sugSelectBlock = ^(TTRouteParamObj * _Nonnull paramObj) {
        
        [wself handleSugSelection:paramObj];
    };
    _viewModel.showNotify = ^(NSString * _Nonnull message) {
        //        [wself showNotify:message];
    };
    
}

- (void)handleSugSelection:(TTRouteParamObj *)paramObj
{
    self.viewModel.isEnterCategory = YES;
    [self handleListOpenUrlUpdate:paramObj];
    [self.houseFilterBridge trigerConditionChanged];
    
}

- (void)handleListOpenUrlUpdate:(TTRouteParamObj *)paramObj
{
    if (self.houseListOpenUrlUpdateBlock) {
        self.houseListOpenUrlUpdateBlock(paramObj);
    }
    [self.houseFilterBridge setFilterConditions:paramObj.queryParams];
    
}

// findTab过来的houseSearch需要单独处理下埋点数据
-(void)updateHouseSearchDict:(NSDictionary *)houseSearchDic
{
    [self.viewModel updateHouseSearchDict:houseSearchDic];
}

- (NSDictionary *)categoryLogDict
{
    return [self.viewModel categoryLogDict];
}

- (BOOL)isEnterCategory
{
    return self.viewModel.isEnterCategory;
}
- (void)showNotify:(NSString *)message inViewModel:(FHBaseHouseListViewModel *)viewModel
{
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            
            UIEdgeInsets inset = self.tableView.contentInset;
            inset.top = 0;
            self.tableView.contentInset = inset;
        }];
    });
    
}

- (void)setupUI
{
    _containerView = [[UIView alloc] init];

    [self addSubview:_containerView];
    
    [_containerView addSubview:self.tableView];

    //error view
    _errorMaskView = [[FHErrorView alloc] init];
    [_containerView addSubview:_errorMaskView];
    self.errorMaskView.hidden = YES;
    
    //notifyview
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self addSubview:self.notifyBarView];
    
    self.redirectTipView = [[FHHouseListRedirectTipView alloc]initWithFrame:CGRectZero];
    [self addSubview:self.redirectTipView];

    [self addSubview:self.filterBgControl];
    
    _filterContainerView = [[UIView alloc]init];
    [self addSubview:_filterContainerView];
    
    [_filterContainerView addSubview:self.filterPanel];
    [self bringSubviewToFront:self.filterBgControl];
}

- (void)setupConstraints
{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.mas_equalTo(self);
        make.top.mas_equalTo(self);
    }];
    
    CGFloat bottomHeight = 49;
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self).mas_offset(-bottomHeight);
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
    }];
    
    [self.errorMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];

    [self.filterContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.containerView);
        make.height.mas_equalTo(@40);
    }];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.filterContainerView);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.redirectTipView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.containerView);
    }];
    
    [self.redirectTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
    
}

#pragma mark - lazy load

- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        if (@available(iOS 11.0, *)) {
            
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
    }
    return _tableView;
}

@end
