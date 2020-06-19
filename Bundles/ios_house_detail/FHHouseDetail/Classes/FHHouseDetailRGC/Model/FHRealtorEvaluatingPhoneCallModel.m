//
//  FHRealtorEvaluatingPhoneCallModel.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/17.
//

#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "FHAssociateIMModel.h"
#import "FHHouseIMClueHelper.h"
#import "FHHousePhoneCallUtils.h"
#define IM_OPEN_URL @"im_open_url"
@interface FHRealtorEvaluatingPhoneCallModel ()
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, strong) NSMutableDictionary *imParams; //用于IM跟前端交互的字段
@end
@implementation FHRealtorEvaluatingPhoneCallModel
- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId
{
    self = [super init];
    if (self) {
        _houseType = houseType;
        _houseId = houseId;
//        _rnIsUnAvalable = NO;
    }
    return self;
}

// extra:realtor_position element_from item_id
- (void)imchatActionWithPhone:(FHFeedUGCCellRealtorModel *)realtorModel realtorRank:(NSString *)rank extraDic:(NSDictionary *)extra {
    
    // IM 透传数据模型
    FHAssociateIMModel *associateIMModel = [FHAssociateIMModel new];
    associateIMModel.houseId = self.houseId;
    associateIMModel.houseType = self.houseType;
    associateIMModel.associateInfo = realtorModel.associateInfo.imInfo[kFHAssociateInfo];
    NSMutableDictionary *tempExtra = extra.mutableCopy;
    tempExtra[kFHAssociateInfo] = nil;
    extra = tempExtra.copy;
    
    // IM 相关埋点上报参数
    FHAssociateReportParams *reportParams = [FHAssociateReportParams new];
    reportParams.enterFrom = self.tracerDict[@"enter_from"] ? : @"be_null";
    reportParams.elementFrom = self.tracerDict[@"element_from"] ? : @"be_null";
    reportParams.originFrom = self.tracerDict[@"origin_from"] ? : @"be_null";
    reportParams.logPb = self.tracerDict[@"log_pb"];
    reportParams.originSearchId = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    reportParams.rank = (rank.length > 0) ? rank : (self.tracerDict[@"rank"] ? : @"be_null");
    reportParams.cardType = self.tracerDict[@"card_type"] ? : @"be_null";
    reportParams.pageType = self.tracerDict[@"page_type"] ?: @"be_null";
    reportParams.realtorId = realtorModel.realtorId;
    reportParams.realtorRank = rank ?[NSNumber numberWithInt:rank.intValue]: 0;
    reportParams.realtorLogpb = realtorModel.realtorLogpb;
    reportParams.conversationId = @"be_null";
    reportParams.extra = extra;
    reportParams.realtorPosition = extra[@"realtor_position"];
    reportParams.searchId = self.tracerDict[@"search_id"] ? : @"be_null";
    
    if(self.tracerDict[@"group_id"]) {
        reportParams.groupId = self.tracerDict[@"group_id"];
    } else if([self.tracerDict[@"log_pb"] isKindOfClass:NSDictionary.class]) {
        reportParams.groupId = (self.tracerDict[@"log_pb"][@"group_id"] ? : @"be_null");
    } else {
        reportParams.groupId = @"be_null";
    }
    
    associateIMModel.reportParams = reportParams;
    
    // IM跳转链接
    associateIMModel.imOpenUrl = extra[IM_OPEN_URL]?:realtorModel.chatOpenurl;
    
    // 配置静默关注回调
    WeakSelf;
    associateIMModel.slientFollowCallbackBlock = ^(BOOL isSuccess) {
        if (isSuccess) {
            wself.isEnterIM = YES;
        }
    };
    // 跳转IM
    [FHHouseIMClueHelper jump2SessionPageWithAssociateIM:associateIMModel];
}

- (void)phoneChatActionWithAssociateModel:(FHAssociatePhoneModel *)associatePhoneModel {
    [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhoneModel completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
    }];
}

@end
