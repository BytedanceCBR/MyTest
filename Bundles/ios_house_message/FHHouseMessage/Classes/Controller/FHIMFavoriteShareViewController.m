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
@interface FHIMFavoriteShareViewController ()
{
    UIScrollView* _containerView;
}
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSArray<NSNumber*>* supportHouseType;
@property (nonatomic, strong) FHIMFavoriteShareViewModel* shareViewModel;
@property (nonatomic, strong) UIButton* sendBtn;
@end

@implementation FHIMFavoriteShareViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj: paramObj];
    if (self) {
        self.supportHouseType = @[@(2), @(3), @(1)];
        self.shareViewModel = [[FHIMFavoriteShareViewModel alloc] init];

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
    [self.view addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
    }];

    [self initBottonBar];
    [self setupPageBySupportTypes:_supportHouseType];
}

-(void)setupNavBar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"二手房";
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

-(UITableView*)generateTableView {
    UITableView* tableView = [[UITableView alloc] init];
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
    _sendBtn.layer.cornerRadius = 4;
    _sendBtn.backgroundColor = [UIColor themeRed1];
    [_sendBtn setAttributedTitle:[self sendAttriTextByCount:0] forState:UIControlStateNormal];

    [bottonBg addSubview:_sendBtn];
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(44);
    }];
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

@end
