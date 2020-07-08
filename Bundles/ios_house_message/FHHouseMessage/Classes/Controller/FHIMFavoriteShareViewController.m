//
//  FHIMFavoriteShareViewController.m
//  FHHouseMessage
//
//  Created by leo on 2019/4/28.
//

#import "FHIMFavoriteShareViewController.h"
#import "Masonry.h"
#import "RXCollection.h"
#import "FHIMFavoriteShareViewModel.h"
#import "FHHouseType.h"
#import "extobjc.h"
#import "FHIMFavoriteSharePageViewModel1.h"
#import "TTDeviceHelper.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "HMSegmentedControl.h"
#import "ReactiveObjC.h"
#import "IMConsDefine.h"
#import "FHErrorView.h"
#import "IFHMyFavoriteController.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>

#import <FHHouseBase/FHBaseTableView.h>
#import "FHHouseErrorHubManager.h"

@interface FHIMFavoriteViewController : NSObject<IFHMyFavoriteController>

@property (nonatomic, strong) FHErrorView *emptyView;
@property (nonatomic , strong) NSMutableDictionary *tracerDict;
@property (nonatomic , assign) BOOL hasValidateData;

@end

@implementation FHIMFavoriteViewController


@end

@interface FHIMFavoriteShareViewController ()
{
    UIScrollView* _containerView;
    NSInteger _openCategoryIndex;
}
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSArray<NSNumber*>* supportHouseType;
@property (nonatomic, strong) FHIMFavoriteShareViewModel* shareViewModel;
@property (nonatomic, strong) UIButton* sendBtn;
@property (nonatomic, strong) NSArray<FHIMFavoriteViewController*>* controllers;
@end

@implementation FHIMFavoriteShareViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj: paramObj];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.supportHouseType = @[@(2), @(3), @(1)];
        self.shareViewModel = [[FHIMFavoriteShareViewModel alloc] init];
        self.shareViewModel.viewController = self;
        self.shareViewModel.conversactionId = [paramObj allParams][@"convId"];
        _openCategoryIndex = [self setCategoryByHouseType:[[paramObj allParams][@"houseType"] integerValue]];
        @weakify(self);
        self.shareViewModel.pageViewModels = [_supportHouseType rx_mapWithBlock:^id(id each) {
            @strongify(self);
            FHIMFavoriteSharePageViewModel1* result =  [self sharePageViewModelByType:[each integerValue]];
            result.selectedListener = self.shareViewModel;
            return result;
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
    _containerView = [[UIScrollView alloc] init];
    _containerView.pagingEnabled = YES;
    _containerView.bounces = NO;
    _containerView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
    }];

    [self initBottonBar];
    [self setupPageBySupportTypes:_supportHouseType];
    @weakify(self);
    //检测是否有选中项，设置发送按钮状态
    [[RACObserve(_shareViewModel, selectedItems) map:^id _Nullable(NSArray*  _Nullable value) {
        return @([value count]);
    }] subscribeNext:^(NSNumber*  _Nullable x) {
        @strongify(self);
        if ([x integerValue] != 0) {
            [self.sendBtn setEnabled:YES];
            self.sendBtn.alpha = 1;
        } else {
            [self.sendBtn setEnabled:NO];
            self.sendBtn.alpha = 0.3;
        }
        [self.sendBtn setAttributedTitle:[self sendAttriTextByCount:[x integerValue]] forState:UIControlStateNormal];
    }];

    [[[RACObserve(_containerView, contentOffset) map:^id _Nullable(NSValue*  _Nullable value) {
//    [[[[RACObserve(_containerView, contentOffset) throttle:0.1] map:^id _Nullable(NSValue*  _Nullable value) {
        @strongify(self);
        CGPoint point = [value CGPointValue];
        return @(abs((point.x + SCREEN_WIDTH / 2) / SCREEN_WIDTH));
    }] skip:1] subscribeNext:^(NSNumber*  _Nullable x) {
        if (self.shareViewModel.currentPage != [x unsignedIntegerValue]) {
            NSUInteger index = [x unsignedIntegerValue];
            self->_openCategoryIndex = index;
            self.shareViewModel.currentPage = index;
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.shareViewModel.currentPage = _openCategoryIndex;
    [self scrollToPageAtIndex:_openCategoryIndex];
}

-(void)resetSendBtnStateAtPageIndex:(NSUInteger)index {
    if ([self.shareViewModel.pageViewModels count] > index) {
        FHIMFavoriteSharePageViewModel1* viewModel = self.shareViewModel.pageViewModels[index];
        if ([viewModel.dataList count] == 0) {
            [self.sendBtn setHidden:YES];
        } else {
            [self.sendBtn setHidden:NO];
        }
    }
}

-(void)setupNavBar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.title setHighlighted:YES];
    NSArray* titles = [_supportHouseType rx_mapWithBlock:^id(id each) {
        return [FHIMFavoriteShareViewController titleByHouseType:[each integerValue]];
    }];
    HMSegmentedControl* segmented = [[HMSegmentedControl alloc] initWithSectionTitles:titles];
    segmented.selectionIndicatorHeight = 4;
    segmented.selectionIndicatorCornerRadius = 2.5f;
    segmented.selectionIndicatorColor = [UIColor themeOrange4];
    segmented.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmented.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    segmented.isNeedNetworkCheck = NO;
    segmented.selectionIndicatorWidth = 25;
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:16],NSFontAttributeName,
                                     [UIColor themeGray3],NSForegroundColorAttributeName,nil];

    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:16],NSFontAttributeName,
                                     [UIColor blackColor],NSForegroundColorAttributeName,nil];
    segmented.titleTextAttributes = attributeNormal;
    segmented.selectedTitleTextAttributes = attributeSelect;
    //    _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(-10, 5, 0, 5);
    segmented.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    segmented.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [self.customNavBarView addSubview:segmented];
    [segmented mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.customNavBarView.leftBtn.mas_right).mas_offset(5);
        make.centerX.mas_equalTo(self.customNavBarView);
        make.bottom.mas_equalTo(self.customNavBarView).mas_offset(-1);
        make.height.mas_equalTo(35);
    }];

    @weakify(segmented);
    [RACObserve(self.shareViewModel, currentPage) subscribeNext:^(id  _Nullable x) {
        @strongify(segmented);
        [segmented setSelectedSegmentIndex:[x integerValue] animated:YES];
    }];
    @weakify(self);
    segmented.indexChangeBlock = ^(NSInteger index) {
        @strongify(self);
        if (self.shareViewModel.currentPage != index) {
            self->_openCategoryIndex = index;
            self.shareViewModel.currentPage = index;
            [self scrollToPageAtIndex:index];
//            [self resetPageDisplayState];
        }
    };


}

-(void)scrollToPageAtIndex:(NSUInteger)index {
    CGPoint contentOffset = CGPointMake(index * CGRectGetWidth(_containerView.frame), 0);
    if (contentOffset.x != _containerView.contentOffset.x) {
        _containerView.contentOffset = contentOffset;
    }
}

-(void)resetPageDisplayState {
    [self.shareViewModel.pageViewModels enumerateObjectsUsingBlock:^(FHIMFavoriteSharePageViewModel1 * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isDisplay = NO;
    }];

    if ([self.shareViewModel.pageViewModels count] > self.shareViewModel.currentPage) {
        FHIMFavoriteSharePageViewModel1* viewModel = self.shareViewModel.pageViewModels[self.shareViewModel.currentPage];
        viewModel.isDisplay = YES;
        [viewModel traceDisplayCell];
    }
}

-(FHIMFavoriteSharePageViewModel1*)sharePageViewModelByType:(FHHouseType)type {
    FHIMFavoriteSharePageViewModel1* model = [[FHIMFavoriteSharePageViewModel1 alloc] initWithTableView:nil
                                                                                             controller:nil
                                                                                                   type:type];
    return model;
}

-(void)setupPageBySupportTypes:(NSArray<NSNumber*>*)supportTypes {
    if (_supportHouseType.count == 1) {
        UITableView* tableView = [self generateTableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_containerView);
            make.width.height.mas_equalTo(_containerView);
        }];
        [self.shareViewModel.pageViewModels.firstObject bindTableView:tableView];
        [self.shareViewModel.pageViewModels.firstObject requestData:YES];
    } else {
        NSArray<UITableView*>* tables = [_supportHouseType rx_mapWithBlock:^id(id each) {
            UITableView* theTable = [self generateTableView];
            return theTable;
        }];

        [tables mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                            withFixedSpacing:0
                                 leadSpacing:0
                                 tailSpacing:0];
        [tables mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(_containerView);
            make.top.bottom.mas_equalTo(_containerView);
        }];
        @weakify(self);
        self.controllers = [_supportHouseType rx_mapWithBlock:^id(id each) {
            @strongify(self);
            FHErrorView* errorView = [[FHErrorView alloc] init];
            errorView.retryBlock = ^{
                @strongify(self);
                [self retryLoadData];
            };
            FHIMFavoriteViewController* controller = [[FHIMFavoriteViewController alloc] init];
            controller.emptyView = errorView;
            controller.tracerDict = self.tracerDict;
            return controller;
        }];

        [_controllers enumerateObjectsUsingBlock:^(FHIMFavoriteViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHErrorView* maskView = obj.emptyView;
            maskView.hidden = YES;
            [_containerView addSubview:maskView];
            [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(tables[idx]);
            }];
            FHIMFavoriteSharePageViewModel1* viewModel = _shareViewModel.pageViewModels[idx];
            viewModel.viewController = obj;
        }];

        [tables enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([_shareViewModel.pageViewModels count] > idx) {
                FHIMFavoriteSharePageViewModel1* viewModel = _shareViewModel.pageViewModels[idx];
                [viewModel bindTableView:obj];
                [viewModel requestData:YES];
            }
        }];
    }
}

-(void)retryLoadData {
    [self.shareViewModel.pageViewModels enumerateObjectsUsingBlock:^(FHIMFavoriteSharePageViewModel1 * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj requestData:NO];
    }];
}

-(UITableView*)generateTableView {
    UITableView* tableView = [[FHBaseTableView alloc] init];
    [_containerView addSubview:tableView];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;

    if (@available(iOS 7.0, *)) {
        tableView.estimatedSectionFooterHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedRowHeight = 0;
    } else {
        // Fallback on earlier versions
    }

    tableView.sectionFooterHeight = 0;
    tableView.sectionHeaderHeight = 0;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    return tableView;
}

-(void)initBottonBar {

    UIView* bottonBg = [[UIView alloc] init];
    bottonBg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottonBg];

    [bottonBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo([self bottonAreaHeight]);
    }];

    self.sendBtn = [[UIButton alloc] init];
    _sendBtn.layer.cornerRadius = 22; //4;
    _sendBtn.backgroundColor = [UIColor themeOrange4];
    [_sendBtn setAttributedTitle:[self sendAttriTextByCount:0] forState:UIControlStateNormal];

    [bottonBg addSubview:_sendBtn];
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(44);
    }];
    [_sendBtn addTarget:self action:@selector(sendSelectedItemToIM) forControlEvents:UIControlEventTouchUpInside];
}

-(NSAttributedString*)sendAttriTextByCount:(NSUInteger)count {
    NSString* text = @"";
    if (count != 0) {
        text = [NSString stringWithFormat:@"发送(%d)", count];
    } else {
        text = @"发送";
    }
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:text]
                                           attributes:@{
                                                        NSFontAttributeName: [UIFont themeFontRegular:16],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        }];
}

-(CGFloat)bottonAreaHeight {
    CGFloat safeBottomPandding = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        if (@available(iOS 11.0, *)) {
            safeBottomPandding = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        } else {
            // Fallback on earlier versions
        }
    }
    return safeBottomPandding + 64;
}

+(NSString*)titleByHouseType:(NSInteger)houseType {
    switch (houseType) {
        case 1:
            return @"新房";
        case 3:
            return @"租房";
        default:
            return @"二手房";
    }
}

-(NSUInteger)setCategoryByHouseType:(NSInteger)houseType {
    NSInteger index = [_supportHouseType indexOfObject:@(houseType)];
    return index;
}

-(void)sendSelectedItemToIM {
    [self.shareViewModel sendSelectedItemToIM];
    [self traceClickSend];
}

-(void)traceClickSend {
    NSMutableDictionary* trace = [NSMutableDictionary dictionaryWithCapacity:6];
    trace[@"event_type"] = @"house_app2c_v2";
    trace[@"page_type"] = @"conversation_detail";
    trace[@"house_type"] = [self houseTypeByIndex:self.shareViewModel.currentPage];
    trace[@"conversation_id"] = self.shareViewModel.conversactionId ? : @"";
    trace[@"log_pb"] = @"be_null";
    trace[@"send_total"] = @([self.shareViewModel.selectedItems count]);
    [[FHHouseErrorHubManager sharedInstance] checkBuryingPointWithEvent:@"click_send" Params:trace];
    [BDTrackerProtocol eventV3:@"click_send" params:trace];
}

-(NSString*)houseTypeByIndex:(NSUInteger)index {
    if ([_supportHouseType count] > index) {
        NSInteger type = [_supportHouseType[index] integerValue];
        switch (type) {
            case 2:
                return @"old";
            case 3:
                return @"rent";
            case 1:
                return @"new";
            default:
                return @"old";
        }
    } else {
        return @"old";
    }
}

@end
