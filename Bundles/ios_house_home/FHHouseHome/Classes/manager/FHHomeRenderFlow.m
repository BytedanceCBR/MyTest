//
//  FHHomeRenderFlow.m
//  FHHouseHome
//
//  Created by bytedance on 2020/11/17.
//

#import "FHHomeRenderFlow.h"
#import "FHCommonDefines.h"

@interface FHHomeRequestFlow()
@property (nonatomic, assign) long sendRequestTs;
@property (nonatomic, assign) long receiveResponseTs;
@property (nonatomic, assign) long beginParseDataTs;
@property (nonatomic, assign) long endParseDataTs;
@end

@implementation FHHomeRequestFlow

- (void)traceSendRequest {
    self.sendRequestTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceReceiveRequest {
    self.receiveResponseTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceBeginParseData {
    self.beginParseDataTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceEndParseData {
    self.endParseDataTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

@end


#import <objc/runtime.h>

@implementation FHHomeHouseModel(RenderFlow)
static const char fh_requestFlow_key;

- (FHHomeRequestFlow *)requestFlow {
    return objc_getAssociatedObject(self, &fh_requestFlow_key);
}

- (void)setRequestFlow:(FHHomeRequestFlow *)requestFlow {
    objc_setAssociatedObject(self, &fh_requestFlow_key, requestFlow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@protocol FHHomeItemRenderFlowDelegate <NSObject>

- (void)itemRenderFlowWillSumbit:(FHHomeItemRenderFlow *)itemRenderFlow;

@end

@interface FHHomeItemRenderFlow()
@property (nonatomic, assign) NSInteger houseType;
@property (nonatomic, assign) long initTs;
@property (nonatomic, assign) long viewDidLoadTs;
@property (nonatomic, assign) long sendRequestTs;
@property (nonatomic, assign) long receiveResponseTs;
@property (nonatomic, assign) long endTs;
@property (nonatomic, strong) FHHomeRequestFlow *requestFlow;
@property (nonatomic, assign) id<FHHomeItemRenderFlowDelegate> delegate;
@end

@implementation FHHomeItemRenderFlow

- (instancetype)initWithHouseType:(NSInteger)houseType {
    self = [super init];
    if (self) {
        _houseType = houseType;
    }
    return self;
}

- (void)traceInit {
    self.initTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceViewDidLoad {
    self.viewDidLoadTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceSendRequest {
    self.sendRequestTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceReceiveResponse:(FHHomeRequestFlow *)requestFlow {
    self.receiveResponseTs = [[NSDate date] timeIntervalSince1970] * 1000;
    self.requestFlow = requestFlow;
}

- (void)traceReloadData {
    self.endTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)submit {
    if ([self.delegate respondsToSelector:@selector(itemRenderFlowWillSumbit:)]) {
        [self.delegate itemRenderFlowWillSumbit:self];
    }
}

@end

@implementation FHHomeItemViewController(RenderFlow)

static const char fh_renderFlow_key;

- (FHHomeItemRenderFlow *)renderFlow {
    return objc_getAssociatedObject(self, &fh_renderFlow_key);
}

- (void)setRenderFlow:(FHHomeItemRenderFlow *)renderFlow {
    objc_setAssociatedObject(self, &fh_renderFlow_key, renderFlow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#import <Heimdallr/HMDTTMonitor.h>
#import "NSDictionary+BTDAdditions.h"


@interface FHHomeRenderFlow()<FHHomeItemRenderFlowDelegate>
@property (nonatomic, assign) long homeMainInitTs;
@property (nonatomic, assign) long homeMainViewDidLoadTs;
@property (nonatomic, assign) long homeInitTs;
@property (nonatomic, assign) long homeViewDidLoadTs;
@property (nonatomic, assign) BOOL submited;
@end

@implementation FHHomeRenderFlow

+ (instancetype)sharedInstance {
    static FHHomeRenderFlow *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FHHomeRenderFlow alloc] init];
    });
    
    return instance;
}

- (void)traceHomeMainInit {
    self.homeMainInitTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceHomeMainViewDidLoad {
    self.homeMainViewDidLoadTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceHomeInit {
    self.homeInitTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)traceHomeViewDidLoad {
    self.homeViewDidLoadTs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (FHHomeItemRenderFlow *)traceHomeItemWithHouseType:(NSInteger)houseType {
    if (self.submited) return nil;
    FHHomeItemRenderFlow *itemRenderFlow = [[FHHomeItemRenderFlow alloc] initWithHouseType:houseType];
    itemRenderFlow.delegate = self;
    [itemRenderFlow traceInit];
    return itemRenderFlow;
}

- (void)submitWithItemRenderFlow:(FHHomeItemRenderFlow *)itemRenderFlow {
    if (self.submited) return;
    self.submited = YES;
    
    /*
     * 起始点: [FHHomeMainViewController viewDidLoad]
     * 结束点: house_type == 2 && [FHHomeItemViewController reloadData]
     */

    long business_request_duration = itemRenderFlow.receiveResponseTs - itemRenderFlow.sendRequestTs;
    long network_request_duration = itemRenderFlow.requestFlow.receiveResponseTs - itemRenderFlow.requestFlow.sendRequestTs;
    
    
    NSMutableDictionary *metricDict = [NSMutableDictionary dictionary];
    metricDict[@"homemain_before_render_duration"] = @(self.homeMainViewDidLoadTs - self.homeMainInitTs);
    metricDict[@"home_before_render_duration"] = @(self.homeViewDidLoadTs - self.homeInitTs);
    metricDict[@"item_before_render_duration"] = @(itemRenderFlow.viewDidLoadTs - itemRenderFlow.initTs);
    
    metricDict[@"between_homemain_and_home_duration"] = @(self.homeViewDidLoadTs - self.homeMainViewDidLoadTs);
    metricDict[@"between_home_and_item_duration"] = @(itemRenderFlow.viewDidLoadTs - self.homeViewDidLoadTs);
    metricDict[@"item_before_request_duration"] = @(itemRenderFlow.sendRequestTs - itemRenderFlow.viewDidLoadTs);
    metricDict[@"business_request_duration"] = @(business_request_duration);
    metricDict[@"after_response_duration"] = @(itemRenderFlow.endTs - itemRenderFlow.receiveResponseTs);
    
    metricDict[@"before_request_duration"] = @(itemRenderFlow.sendRequestTs - self.homeMainViewDidLoadTs);
    metricDict[@"network_request_duration"] = @(network_request_duration);
    metricDict[@"request_gap_duration"] = @(business_request_duration - network_request_duration);
    metricDict[@"json_parse_duration"] = @(itemRenderFlow.requestFlow.endParseDataTs - itemRenderFlow.requestFlow.beginParseDataTs);
    
    metricDict[@"item_duration"] = @(itemRenderFlow.endTs - itemRenderFlow.initTs);
    metricDict[@"home_duration"] = @(itemRenderFlow.endTs - self.homeInitTs);
    metricDict[@"homemain_duration"] = @(itemRenderFlow.endTs - self.homeMainViewDidLoadTs);
    
    NSMutableDictionary *categoryDict = [NSMutableDictionary new];
    categoryDict[@"house_type"] = @(itemRenderFlow.houseType);
    categoryDict[@"request_type"] = @(itemRenderFlow.requestType);
    categoryDict[@"op_version"] = @(2);

    [[HMDTTMonitor defaultManager] hmdTrackService:@"pss_homepage_v2" metric:metricDict category:categoryDict extra:nil];

#if DEBUG
    NSString *metricString = [metricDict btd_safeJsonStringEncoded];
    NSString *categoryString = [categoryDict btd_safeJsonStringEncoded];

    NSLog(@"pss_homepage_op %@ %@", categoryString, metricString);
#endif
}

#pragma mark - FHHomeItemRenderFlowDelegate
- (void)itemRenderFlowWillSumbit:(FHHomeItemRenderFlow *)itemRenderFlow {
    [self submitWithItemRenderFlow:itemRenderFlow];
}

@end
