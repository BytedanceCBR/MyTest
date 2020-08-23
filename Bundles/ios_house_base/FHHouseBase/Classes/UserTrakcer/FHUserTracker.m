//
//  FHUserTracker.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHUserTracker.h"
#import "FHErrorHubManagerUtil.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import "FHEnvContext.h"

@interface FHUserTracker ()

@end
@implementation FHUserTracker

+(NSDictionary *)basicParam
{
    NSMutableDictionary *basic = [NSMutableDictionary dictionary];
    basic[@"event_type"] = @"house_app2c_v2";
    //统计增加当前选中的城市id，为了让需要城市区分的数据更准确，原因是applog是延时上报，上报时候的城市可能已经切换到其他城市了
    NSString *currentCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(currentCityId.length > 0){
        basic[@"f_current_city_id"] = currentCityId;
    }
    
    return [basic copy];
}

+(void)writeEvent:(NSString *)event params:(NSDictionary *)param
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:param];
    [params addEntriesFromDictionary:[self basicParam]];
    [FHErrorHubManagerUtil checkBuryingPointWithEvent:event Params:params];
    [BDTrackerProtocol eventV3:event params:params];
}

+(void)writeEvent:(NSString *)event withModel:(FHTracerModel *_Nullable)model
{
    if (event.length == 0) {
        return;
    }    
    NSMutableDictionary *param = [model logDict];
    [param addEntriesFromDictionary:[self basicParam]];
    [FHErrorHubManagerUtil checkBuryingPointWithEvent:event Params:param];
    [BDTrackerProtocol eventV3:event params:param];
}

@end
//#define UT_EVENT_TYPE  @"event_type"
NSString *const UT_EVENT_TYPE = @"event_type";
NSString *const UT_ORIGIN_FROM = @"origin_from";
NSString *const UT_ENTER_FROM = @"enter_from";
NSString *const UT_CATEGORY_NAME = @"category_name";
NSString *const UT_CATEGORY_REFRESH = @"category_refresh";
NSString *const UT_ENTER_TYPE = @"enter_type";
NSString *const UT_ELEMENT_FROM = @"element_from";
NSString *const UT_ELEMENT_TYPE = @"element_type";
NSString *const UT_ENTER_CATEOGRY = @"enter_category";
NSString *const UT_STAY_CATEOGRY = @"stay_category";
NSString *const UT_SEARCH_ID = @"search_id";
NSString *const UT_ORIGIN_SEARCH_ID = @"origin_search_id";
NSString *const UT_STAY_TIME = @"stay_time";
NSString *const UT_PAGE_TYPE = @"page_type";
NSString *const UT_LOG_PB = @"log_pb";
NSString *const UT_HOUSE_TYPE = @"house_type";
NSString *const UT_GROUP_ID = @"group_id";
NSString *const UT_RANK = @"rank";
NSString *const UT_REFRESH_TYPE = @"refresh_type";

NSString *const UT_OF_RENTING_SEARCH = @"renting_search";
NSString *const UT_OF_RENTING_LIST = @"renting_list";
NSString *const UT_OF_RENTING_ALL = @"renting_all";
NSString *const UT_OF_RENTING_FULLY = @"renting_fully";
NSString *const UT_OF_RENTING_JOINT = @"renting_joint";
NSString *const UT_OF_RENTING_APARTMENT = @"renting_apartment";
NSString *const UT_OF_SCHOOL_OPERATION = @"school_operation";
NSString *const UT_OF_DISCOUNT_OPERATION = @"discount_operation";
NSString *const UT_OF_SMALL_OPERATION = @"small_operation";
NSString *const UT_OF_CITY_MARKET = @"city_market";
// main  tab
NSString *const UT_OF_MAIN_NEW = @"new";
NSString *const UT_OF_MAIN_OLD = @"old";
NSString *const UT_OF_MAIN_NEIGHBORHOOD = @"neighborhood";
NSString *const UT_OF_MAIN_GANGXU = @"gangxufang";
NSString *const UT_OF_MAIN_SEARCH = @"maintab_search";
NSString *const UT_OF_MAIN_MIX_LIST = @"mix_list";
NSString *const UT_OF_MAIN_NEW_LIST = @"new_list";

NSString *const UT_OF_FIND_SEARCH = @"findtab_find";
NSString *const UT_OF_FIND_FIND = @"findtab_find";
NSString *const UT_OF_FIND_HISTORY = @"findtab_history";

NSString *const UT_OF_MESSAGE_RECOMMEND = @"messagetab_recommend";
NSString *const UT_OF_MESSAGE_RENT = @"messagetab_rent";
NSString *const UT_OF_MESSAGE_NEW = @"messagetab_new";
NSString *const UT_OF_MESSAGE_OLD = @"messagetab_old";
NSString *const UT_OF_MESSAGE_NEIGHBORHOOD = @"messagetab_neighborhood";
NSString *const UT_OF_MINE_RENT = @"minetab_rent";
NSString *const UT_OF_MINE_NEW = @"minetab_new";
NSString *const UT_OF_MINE_OLD = @"minetab_old";
NSString *const UT_OF_MINE_NEIGHBORHOOD = @"minetab_neighborhood";
NSString *const UT_OF_PUSH = @"push";

NSString *const UT_OF_COMMUTE = @"commuter";

//COMMON ACTION
NSString *const UT_OF_ELEMENT_SHOW = @"element_show";
NSString *const UT_GO_DETAIL = @"go_detail";
NSString *const UT_BE_NULL = @"be_null";
NSString *const UT_CLICK_POSITION = @"click_position";


