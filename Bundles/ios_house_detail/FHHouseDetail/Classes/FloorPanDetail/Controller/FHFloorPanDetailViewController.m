//
//  FHFloorPanDetailViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanDetailViewController.h"
#import "FHHouseDetailBaseViewModel.h"
#import "TTReachability.h"
#import "FHDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "TTDeviceHelper.h"
#import "UIFont+House.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHFloorPanDetailViewModel.h"
#import "UIViewController+Track.h"

@interface FHFloorPanDetailViewController ()

@property (nonatomic, copy)   NSString* floorPanId; // 房源id
@property (nonatomic , strong) UITableView *infoListTable;
@property (nonatomic , strong) FHFloorPanDetailViewModel *coreInfoListViewModel;

@end

@implementation FHFloorPanDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttTrackStayEnable = YES;
        _floorPanId = paramObj.allParams[@"floorpanid"];
        
        [self processTracerData:paramObj.allParams[@"tracer"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpinfoListTable];
    
    [self addDefaultEmptyViewFullScreen];

    _coreInfoListViewModel = [[FHFloorPanDetailViewModel alloc] initWithController:self tableView:_infoListTable floorPanId:_floorPanId];
    
    self.coreInfoListViewModel.detailTracerDic = [self makeDetailTracerData];
    
    [_coreInfoListViewModel addGoDetailLog];
    

    // Do any additional setup after loading the view.
}

- (void)retryLoadData
{
    [self.coreInfoListViewModel startLoadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.coreInfoListViewModel addStayPageLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self.coreInfoListViewModel addStayPageLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}


// 构建详情页基础埋点数据
- (NSMutableDictionary *)makeDetailTracerData {
    NSMutableDictionary *detailTracerDic = [NSMutableDictionary new];
    detailTracerDic[@"page_type"] = @"house_model_detail";
    detailTracerDic[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
    detailTracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    detailTracerDic[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
    detailTracerDic[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    detailTracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    detailTracerDic[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    detailTracerDic[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
    // 以下3个参数都在:log_pb中
    // group_id
    // impr_id
    // search_id
    // 比如：element_show中添加："element_type": "trade_tips"
    // house_show 修改 rank、log_pb 等字段
    return detailTracerDic;
}

- (NSDictionary *)getDictionaryFromJSONString:(NSString *)jsonString {
    NSMutableDictionary *retDic = nil;
    if (jsonString.length > 0) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        retDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if ([retDic isKindOfClass:[NSDictionary class]] && error == nil) {
            return retDic;
        } else {
            return nil;
        }
    }
    return retDic;
}

// 埋点数据处理:1、paramObj.allParams中的"tracer"字段，2、allParams中的origin_from、report_params等字段
- (void)processTracerData:(NSDictionary *)allParams {
    // 原始数据放入：self.tracerDict
    // 取其他非"tracer"字段数据
    NSString *origin_from = allParams[@"origin_from"];
    if ([origin_from isKindOfClass:[NSString class]] && origin_from.length > 0) {
        self.tracerDict[@"origin_from"] = origin_from;
    }
    NSString *origin_search_id = allParams[@"origin_search_id"];
    if ([origin_search_id isKindOfClass:[NSString class]] && origin_search_id.length > 0) {
        self.tracerDict[@"origin_search_id"] = origin_search_id;
    }
    NSString *report_params = allParams[@"report_params"];
    if ([report_params isKindOfClass:[NSString class]]) {
        NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
        if (report_params_dic) {
            [self.tracerDict addEntriesFromDictionary:report_params_dic];
        }
    }

    self.tracerDict[@"card_type"] = allParams[@"card_type"] ?  : @"be_null";
    
    self.tracerDict[@"element_from"] = allParams[@"element_from"] ? : @"be_null";
    
     self.tracerDict[@"enter_from"] = allParams[@"enter_from"] ?  : @"be_null";
    
    self.tracerDict[@"origin_from"] = allParams[@"origin_from"] ? : @"be_null";
    
    self.tracerDict[@"origin_search_id"] = allParams[@"origin_search_id"] ? : @"be_null";

    NSString *log_pb_str = allParams[@"log_pb"];
    if ([log_pb_str isKindOfClass:[NSDictionary class]]) {
        self.tracerDict[@"log_pb"] = log_pb_str;
    } else {
        if ([log_pb_str isKindOfClass:[NSString class]] && log_pb_str.length > 0) {
            NSDictionary *log_pb_dic = [self getDictionaryFromJSONString:log_pb_str];
            if (log_pb_dic) {
                
            }
        }
    }
    
    // rank字段特殊处理：外部可能传入字段为rank和index不同类型的数据
    id index = allParams[@"index"];
    id rank = allParams[@"rank"];
    if (index != NULL && rank == NULL) {
        self.tracerDict[@"rank"] = index;
    }else
    {
        if (rank != NULL) {
            self.tracerDict[@"rank"] = rank;
        }
    }
    self.coreInfoListViewModel.detailTracerDic = self.tracerDict;
}


- (void)setUpinfoListTable
{
    _infoListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _infoListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _infoListTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _infoListTable.estimatedRowHeight = UITableViewAutomaticDimension;
        _infoListTable.estimatedSectionFooterHeight = 0;
        _infoListTable.estimatedSectionHeaderHeight = 0;
    }
    [_infoListTable setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_infoListTable];
    
    [_infoListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self getNaviBar].mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo([self getBottomBar].mas_top);
    }];
    
    [_infoListTable setBackgroundColor:[UIColor whiteColor]];
    
}

- (NSString *)pageTypeString
{
    return @"house_model_detail";
}

- (void)dealloc
{
    NSLog(@"FHFloorPanDetailViewController dealloc");
}

@end
