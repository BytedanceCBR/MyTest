//
//  FHUserTrackerDefine.h
//  Pods
//
//  Created by 春晖 on 2018/11/30.
//

#ifndef FHUserTrackerDefine_h
#define FHUserTrackerDefine_h

//keys
#define UT_EVENT_TYPE  @"event_type"
#define UT_ORIGIN_FROM @"origin_from"
#define UT_ENTER_FROM  @"enter_from"        //列表入口
#define UT_CATEGORY_NAME @"category_name"  //列表名
#define UT_ENTER_TYPE    @"enter_type"     //列表名
#define UT_ELEMENT_FROM  @"element_from"   //组件入口
#define UT_ENTER_CATEOGRY @"enter_category"


#define UT_SEARCH_ID     @"search_id"
#define UT_ORIGIN_SEARCH_ID @"origin_search_id"

#define UT_STAY_TIME    @"stay_time"  // 停留时长，单位毫秒


//values
#define UT_OF_RENTING_SEARCH @"renting_search"
#define UT_OF_RENTING_LIST   @"renting_list"
#define UT_OF_RENTING_ALL    @"renting_all"
#define UT_OF_RENTING_FULLY  @"renting_fully"
#define UT_OF_RENTING_JOINT  @"renting_joint"
#define UT_OF_RENTING_APARTMENT  @"renting_apartment"

#define UT_OF_SCHOOL_OPERATION  @"school_operation"
#define UT_OF_DISCOUNT_OPERATION  @"discount_operation"
#define UT_OF_SMALL_OPERATION     @"small_operation"

#define UT_OF_CITY_MARKET         @"city_market"


// main tab
#define UT_OF_MAIN_NEW            @"new"
#define UT_OF_MAIN_OLD            @"old"
#define UT_OF_MAIN_NEIGHBORHOOD   @"neighborhood"
#define UT_OF_MAIN_GANGXU         @"gangxufang"
#define UT_OF_MAIN_SEARCH         @"maintab_search"
#define UT_OF_MAIN_MIX_LIST       @"mix_list"
#define UT_OF_MAIN_NEW_LIST       @"new_list"

//find tab
#define UT_OF_FIND_SEARCH        @"findtab_find"
#define UT_OF_FIND_FIND          @"findtab_find"
#define UT_OF_FIND_HISTORY       @"findtab_history"


//message tab
#define UT_OF_MESSAGE_RECOMMEND   @"messagetab_recommend"
#define UT_OF_MESSAGE_RENT        @"messagetab_rent"
#define UT_OF_MESSAGE_NEW         @"messagetab_new"
#define UT_OF_MESSAGE_OLD         @"messagetab_old"
#define UT_OF_MESSAGE_NEIGHBORHOOD @"messagetab_neighborhood"

#define UT_OF_MINE_RENT           @"minetab_rent"
#define UT_OF_MINE_NEW            @"minetab_new"
#define UT_OF_MINE_OLD            @"minetab_old"
#define UT_OF_MINE_NEIGHBORHOOD   @"minetab_neighborhood"

#define UT_OF_PUSH               @"push"


/*
 
 origin_from：首次进入列表页或详情页的入口,{'租房大类页搜索': 'renting_search', '租房大类页推荐列表': 'renting_list', '租房大类页全部房源icon': 'renting_all', '租房大类页整租icon': 'renting_fully', '租房大类页合租icon': 'renting_joint', '租房大类页公寓icon': 'renting_apartment', '学区房运营位': 'school_operation', '降价房运营位': 'discount_operation', '小户型运营位': 'small_operation', '城市行情': 'city_market',
      '消息tab房源推荐消息': 'messagetab_recommend', '首页新房icon': 'new', '首页二手房icon': 'old', '首页小区icon': 'neighborhood',
 '首页刚需房icon': 'gangxufang', '首页搜索': 'maintab_search', '首页混排列表': 'mix_list',
 '首页混排列表查看更多': 'mixlist_loadmore', '首页二手房列表': 'old_list','首页新房列表': 'new_list',
  '找房tab搜索': 'findtab_search',
 '找房tab开始找房': 'findtab_find', '找房tab点击历史记录': 'findtab_history', 'push': 'push',
 '消息tab租房消息': 'messagetab_rent', '消息tab新房消息': 'messagetab_new',
 '消息tab二手房消息': 'messagetab_old', '消息tab小区消息': 'messagetab_neighborhood',
 '我的tab租房关注': 'minetab_rent', '我的tab新房关注': 'minetab_new',
 '我的tab二手房关注': 'minetab_old', '我的tab小区关注': 'minetab_neighborhood'}
 
 origin_search_id：首次进入列表页或详情页的search_id
 
 1. event_type：house_app2c_v2
 2. category_name（列表名）：rent_list（租房列表页）
 3. enter_from（列表入口）：maintab（首页）
 4. enter_type（进入列表方式）：click（点击）
 5. element_from（组件入口）：maintab_mixlist（首页混排列表）
 6. search_id
 7. origin_from：mixlist_loadmore（首页混排列表查看更多）
 8. origin_search_id
 9. stay_time（停留时长，单位毫秒）
 */

#endif /* FHUserTrackerDefine_h */
