//
//  FHDetailEvaluationListViewController.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/16.
//

#import "FHDetailEvaluationListViewController.h"
#import "FHBaseTableView.h"
#import "Masonry.h"
#import "UIDevice+BTDAdditions.h"
#import "FHDetailEvaluationListViewModel.h"
#import "UIImage+FIconFont.h"
#import "UIViewController+Track.h"
@interface FHDetailEvaluationListViewController ()
@property (weak, nonatomic) UITableView *mainTable;
@property (strong, nonatomic) FHDetailEvaluationListViewModel *viewModel;
@property (weak, nonatomic) FHDetailEvaluationListViewHeader *evaluationHeader;
@property (copy, nonatomic) NSString *houseType;
@property (copy, nonatomic) NSString *houseId;
@property (copy, nonatomic) NSString *channelId;
@property (copy, nonatomic) NSString *vcTitle;
@property (strong, nonatomic) NSArray *tabsInfo;
@property(nonatomic, strong) TTRouteParamObj *paramObj;
@end

@implementation FHDetailEvaluationListViewController
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _paramObj = paramObj;
        NSDictionary *allParams = paramObj.allParams;
        _houseId = allParams[@"houseId"];
        _houseType = allParams[@"houseType"];
        _channelId = allParams[@"category_name"];
        _tabsInfo = [self arrayWithJsonString:allParams[@"tab_list"]];
        _vcTitle = allParams[@"title"];
        self.ttTrackStayEnable = YES;
        self.tracerDict = allParams [@"tracer"];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initViewModel];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_viewModel addGoDtailTracer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    [_viewModel addStayPageTracerWithTimer:[NSNumber numberWithInteger:duration]];
}


- (void)trackEndedByAppWillEnterBackground {
    
    [self.viewModel addStayPageTracerWithTimer:[NSNumber numberWithInteger:self.ttTrackStayTime * 1000.0]];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}
// 重新加载
- (void)retryLoadData {
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}
- (void)initViewModel {
    _viewModel = [[FHDetailEvaluationListViewModel alloc] initWithController:self tableView:self.mainTable headerView:self.evaluationHeader userInfo:_paramObj.allParams];;
    _viewModel.tracerDic = [self makeDetailTracerData];
}

- (void)startLoadData {
    [_viewModel reloadData];
}

- (void)initUI {
    [self setupDefaultNavBar:NO];
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#f8f8f8"];
    self.customNavBarView.title.text = self.vcTitle;
    [self.evaluationHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.height.mas_offset(70);
    }];
    [self.mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
                if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
        if (self.tabsInfo.count>2) {
            make.top.equalTo(self.evaluationHeader.mas_bottom);
        }else {
           make.top.equalTo(self.evaluationHeader);
        }
    }];
    if (self.tabsInfo.count<3) {
        self.evaluationHeader.hidden = YES;
        self.mainTable.contentInset = UIEdgeInsetsMake(16, 0, 0, 0);
    }
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(70, 0, 0, 0)];
}

- (FHDetailEvaluationListViewHeader *)evaluationHeader {
    if (!_evaluationHeader) {
        FHDetailEvaluationListViewHeader *evaluationHeader = [[FHDetailEvaluationListViewHeader alloc]init];
        evaluationHeader.tabInfoArr = self.tabsInfo;
        [self.view addSubview:evaluationHeader];
        _evaluationHeader = evaluationHeader;
    }
    return _evaluationHeader;
}


- (UITableView *)mainTable {
    if (!_mainTable) {
        UITableView * mainTable = [[FHBaseTableView alloc]init];
        mainTable.backgroundColor = [UIColor clearColor];
        mainTable.showsVerticalScrollIndicator = NO;
        mainTable.estimatedRowHeight = 0;
        mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0 , *)) {
            mainTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            
        }
        if (@available(iOS 11.0 , *)) {
            mainTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            mainTable.estimatedRowHeight = 0;
            mainTable.estimatedSectionFooterHeight = 0;
            mainTable.estimatedSectionHeaderHeight = 0;
        }else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        if ([UIDevice btd_isIPhoneXSeries]) {
            mainTable.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        mainTable.tableFooterView = footerView;
        [self.view addSubview:mainTable];
        _mainTable = mainTable;
    }
    return _mainTable;
}

// 构建基础埋点数据
- (NSMutableDictionary *)makeDetailTracerData {
    NSMutableDictionary *detailTracerDic = [NSMutableDictionary new];
    detailTracerDic[@"page_type"] = [self pageTypeString];
    detailTracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    detailTracerDic[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
    detailTracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    detailTracerDic[@"from_gid"] = self.tracerDict[@"from_gid"];
    detailTracerDic[@"log_pb"] = self.tracerDict[@"log_pb"];
    return detailTracerDic;
}
-(NSString *)pageTypeString {
    return @"realtor_evaluate_list";
}

- (NSArray *)arrayWithJsonString:(NSString *)jsonString{
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                    error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
    
}
@end
