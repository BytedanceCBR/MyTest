//
//  FHCommutePOISearchViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import "FHCommutePOISearchViewController.h"
#import "FHCommutePOISearchViewModel.h"
#import "FHCommutePOIInputBar.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/FHFakeInputNavbar.h>
#import <TTReachability/TTReachability.h>
#import <TTUIWidget/TTNavigationController.h>

@interface FHCommutePOISearchViewController ()

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) FHCommutePOIInputBar *inputBar;
@property(nonatomic , strong) FHCommutePOISearchViewModel *viewModel;


@end

@implementation FHCommutePOISearchViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSHashTable *table = paramObj.allParams[COMMUTE_POI_DELEGATE_KEY];
        if (table) {
            self.sugDelegate = UNWRAP_WEAK(table);
        }
    }
    return self;
}

-(void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _inputBar = [[FHCommutePOIInputBar alloc] initWithFrame:CGRectZero];
    _inputBar.placeHolder = @"设置你的公司或其它目的地";
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UIEdgeInsets safeInsets = UIEdgeInsetsZero;
        safeInsets.bottom =  ([[[[UIApplication sharedApplication]delegate] window] safeAreaInsets]).bottom;
        _tableView.contentInset = safeInsets;
    }

    
    _viewModel = [[FHCommutePOISearchViewModel alloc] initWithTableView:_tableView inputBar:_inputBar];
    _viewModel.viewController = self;
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_inputBar];

    [self initConstraints];
    
    [_inputBar becomeFirstResponder];
    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.emptyView.hidden = YES;
    
    if (![TTReachability isNetworkConnected]) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self) wself = self;
    self.panBeginAction = ^{
        [wself.inputBar resignFirstResponder];
    };
    
}

- (void)retryLoadData {
    // 重新加载数据
    [self.viewModel tryReload];
}


-(void)initConstraints
{
    CGFloat barHeight = [FHFakeInputNavbar perferredHeight];
    
    [self.inputBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.height.mas_equalTo(barHeight);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.inputBar.mas_bottom);
    }];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

@end

NSString *const COMMUTE_POI_DELEGATE_KEY = @"_commute_poi_delegate_";